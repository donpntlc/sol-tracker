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


const String _kLiveJs = r"""
window.solLiveScan = function (L) {
  return new Promise(async function (resolve) {
    var Z = window.ZXing;
    var done = false, stream = null, timer = null;
    var ov = document.createElement('div');
    ov.style.cssText = 'position:fixed;inset:0;z-index:99999;background:#000;display:flex;flex-direction:column;align-items:center;justify-content:center;font-family:-apple-system,Roboto,sans-serif';
    var v = document.createElement('video');
    v.setAttribute('playsinline', ''); v.setAttribute('muted', ''); v.muted = true; v.autoplay = true;
    v.style.cssText = 'position:absolute;inset:0;width:100%;height:100%;object-fit:cover';
    ov.appendChild(v);
    var shade = document.createElement('div');
    shade.style.cssText = 'position:absolute;left:8%;right:8%;top:38%;height:22%;border:3px solid #C9A24A;border-radius:16px;box-shadow:0 0 0 9999px rgba(0,0,0,.55)';
    var line = document.createElement('div');
    line.style.cssText = 'position:absolute;left:6%;right:6%;top:50%;height:2px;background:rgba(201,162,74,.8)';
    shade.appendChild(line);
    ov.appendChild(shade);
    var tip = document.createElement('div');
    tip.textContent = L.hint;
    tip.style.cssText = 'position:absolute;top:calc(38% - 56px);left:0;right:0;text-align:center;color:#fff;font-size:17px;font-weight:600';
    ov.appendChild(tip);
    var bar = document.createElement('div');
    bar.style.cssText = 'position:absolute;bottom:calc(36px + env(safe-area-inset-bottom));left:0;right:0;display:flex;justify-content:center;gap:12px';
    function btn(txt, gold, fn) {
      var b = document.createElement('button'); b.textContent = txt;
      b.style.cssText = 'padding:14px 20px;border-radius:14px;font-size:15px;font-weight:700;border:' + (gold ? 'none;background:#C9A24A;color:#111' : '1.5px solid rgba(255,255,255,.6);background:rgba(0,0,0,.4);color:#fff');
      b.onclick = fn; bar.appendChild(b);
    }
    function finish(val) {
      if (done) return; done = true;
      if (timer) clearTimeout(timer);
      try { stream && stream.getTracks().forEach(function (t) { t.stop(); }); } catch (e) {}
      ov.remove(); resolve(val);
    }
    btn(L.cancel, false, function () { finish(null); });
    btn(L.other, true, function () { finish('__other__'); });
    ov.appendChild(bar);
    document.body.appendChild(ov);
    try {
      stream = await navigator.mediaDevices.getUserMedia({ audio: false, video: { facingMode: { ideal: 'environment' }, width: { ideal: 1920 }, height: { ideal: 1080 } } });
    } catch (e) { tip.textContent = L.denied; return; }
    v.srcObject = stream;
    try { await v.play(); } catch (e) {}
    var det = null;
    try { if ('BarcodeDetector' in window) det = new window.BarcodeDetector({ formats: ['ean_13', 'ean_8', 'upc_a', 'upc_e', 'code_128'] }); } catch (e) { det = null; }
    var hints = null, reader = null;
    if (Z) {
      hints = new Map();
      hints.set(Z.DecodeHintType.POSSIBLE_FORMATS, [Z.BarcodeFormat.EAN_13, Z.BarcodeFormat.EAN_8, Z.BarcodeFormat.UPC_A, Z.BarcodeFormat.UPC_E, Z.BarcodeFormat.CODE_128]);
      reader = new Z.MultiFormatReader(); reader.setHints(hints);
    }
    var c = document.createElement('canvas'), ctx = c.getContext('2d', { willReadFrequently: true });
    var n = 0;
    async function tick() {
      if (done) return;
      var W = v.videoWidth, H = v.videoHeight;
      if (W && H) {
        try {
          if (det) {
            var r0 = await det.detect(v);
            if (r0 && r0.length && r0[0].rawValue) { try { navigator.vibrate && navigator.vibrate(80); } catch (e) {} return finish(r0[0].rawValue); }
          } else if (reader) {
            // Mittlerer Streifen (wo der Rahmen ist), abwechselnd groß/klein.
            var f = (n++ % 2) ? 0.9 : 0.65;
            var cw = W * f, ch = Math.min(H, cw * 0.45), cx = (W - cw) / 2, cy = (H - ch) / 2;
            var k = Math.min(1, 1000 / cw);
            c.width = Math.round(cw * k); c.height = Math.round(ch * k);
            ctx.drawImage(v, cx, cy, cw, ch, 0, 0, c.width, c.height);
            var bins = [Z.HybridBinarizer, Z.GlobalHistogramBinarizer];
            for (var i = 0; i < bins.length; i++) {
              try {
                var src = new Z.HTMLCanvasElementLuminanceSource(c);
                var res = reader.decodeWithState(new Z.BinaryBitmap(new bins[i](src)));
                if (res && res.getText()) { try { navigator.vibrate && navigator.vibrate(80); } catch (e) {} return finish(res.getText()); }
              } catch (e) {}
            }
          }
        } catch (e) {}
      }
      timer = setTimeout(tick, 120);
    }
    tick();
  });
};
""";

void _ensureLiveHelper() {
  if (globalContext.has('solLiveScan')) return;
  final doc = globalContext['document'] as JSObject;
  final script = doc.callMethod<JSObject>('createElement'.toJS, 'script'.toJS);
  script['textContent'] = _kLiveJs.toJS;
  (doc['head'] as JSObject).callMethod<JSAny?>('appendChild'.toJS, script);
}

/// Live-Kamera mit laufendem Scan. Ergebnis: Code, '__other__' (Foto/eintippen) oder null (abgebrochen).
Future<String?> liveScanBarcode(Map<String, String> labels) async {
  try {
    await _ensureZxing();
    _ensureLiveHelper();
    final fn = globalContext['solLiveScan'] as JSFunction?;
    if (fn == null) return '__other__';
    final l = JSObject();
    labels.forEach((k, v) => l[k] = v.toJS);
    final res = await (fn.callAsFunction(null, l) as JSPromise<JSAny?>).toDart;
    if (res == null) return null;
    return (res as JSString).toDart;
  } catch (_) {
    return '__other__';
  }
}
