import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

const _kZxingCdn = 'https://unpkg.com/@zxing/library@0.19.1';

bool barcodeLibLoaded() => globalContext.has('ZXing');

Future<bool> _ensureZxing() async {
  if (globalContext.has('ZXing')) return true;
  if (await _loadScript(Uri.base.resolve('zxing.min.js').toString(), 'sol-zxing-local')) {
    return true;
  }
  return _loadScript(_kZxingCdn, 'sol-zxing-cdn');
}

Future<bool> _loadScript(String src, String id) async {
  if (globalContext.has('ZXing')) return true;
  final doc = globalContext['document'] as JSObject;
  final existing = doc.callMethod<JSAny?>(
      'getElementById'.toJS, id.toJS);
  final c = Completer<bool>();
  final script = existing as JSObject? ??
      doc.callMethod<JSObject>('createElement'.toJS, 'script'.toJS);
  script['onload'] = ((JSAny? _) {
    if (!c.isCompleted) c.complete(true);
  }).toJS;
  script['onerror'] = ((JSAny? _) {
    if (!c.isCompleted) c.complete(false);
  }).toJS;
  if (existing == null) {
    script['id'] = id.toJS;
    script['src'] = src.toJS;
    (doc['head'] as JSObject).callMethod<JSAny?>('appendChild'.toJS, script);
  }
  final ok = await c.future
      .timeout(const Duration(seconds: 12), onTimeout: () => false);
  return ok && globalContext.has('ZXing');
}

const String _kDecodeJs = r'''
window.solDecodeBarcode = async function (url) {
  var Z = window.ZXing; if (!Z) return null;
  var img = new Image(); img.src = url;
  try { await img.decode(); } catch (e) { return null; }
  var W = img.naturalWidth, H = img.naturalHeight;
  var hints = new Map(); hints.set(Z.DecodeHintType.TRY_HARDER, true);
  function tryCanvas(c) {
    var bins = [Z.HybridBinarizer, Z.GlobalHistogramBinarizer];
    for (var i = 0; i < bins.length; i++) {
      try {
        var src = new Z.HTMLCanvasElementLuminanceSource(c);
        var bmp = new Z.BinaryBitmap(new bins[i](src));
        var r = new Z.MultiFormatReader().decode(bmp, hints);
        if (r && r.getText()) return r.getText();
      } catch (e) {}
    }
    return null;
  }
  // Ausschnitte: ganzes Bild, Mitte 60 %, Mitte 40 % (Barcode ist meist mittig)
  var crops = [1, 0.6, 0.4];
  var sizes = [1400, 900];
  for (var ci = 0; ci < crops.length; ci++) {
    var f = crops[ci];
    var cw = W * f, ch = H * f, cx = (W - cw) / 2, cy = (H - ch) / 2;
    for (var s = 0; s < sizes.length; s++) {
      var k = Math.min(1, sizes[s] / Math.max(cw, ch));
      var w = Math.max(1, Math.round(cw * k)), h = Math.max(1, Math.round(ch * k));
      for (var rot = 0; rot < 2; rot++) {
        var c = document.createElement('canvas');
        var ctx = c.getContext('2d');
        if (rot === 0) { c.width = w; c.height = h; ctx.drawImage(img, cx, cy, cw, ch, 0, 0, w, h); }
        else { c.width = h; c.height = w; ctx.translate(h, 0); ctx.rotate(Math.PI / 2); ctx.drawImage(img, cx, cy, cw, ch, 0, 0, w, h); }
        var t = tryCanvas(c);
        if (t) return t;
      }
    }
  }
  return null;
};
''';

void _ensureHelper() {
  if (globalContext.has('solDecodeBarcode')) return;
  final doc = globalContext['document'] as JSObject;
  final script = doc.callMethod<JSObject>('createElement'.toJS, 'script'.toJS);
  script['textContent'] = _kDecodeJs.toJS;
  (doc['head'] as JSObject).callMethod<JSAny?>('appendChild'.toJS, script);
}

Future<String?> decodeBarcodeFromPhoto(Uint8List bytes, String mime) async {
  try {
    if (!await _ensureZxing()) return null;
    _ensureHelper();
    final fn = globalContext['solDecodeBarcode'] as JSFunction?;
    if (fn == null) return null;
    final url =
        'data:${mime.isEmpty ? 'image/jpeg' : mime};base64,${base64Encode(bytes)}';
    final res = await (fn.callAsFunction(null, url.toJS) as JSPromise<JSAny?>).toDart;
    if (res == null) return null;
    final text = (res as JSString).toDart;
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  }
}
