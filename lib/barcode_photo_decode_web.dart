import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

const _kZxingUrl = 'https://unpkg.com/@zxing/library@0.19.1';

Future<bool> _ensureZxing() async {
  if (globalContext.has('ZXing')) return true;
  final doc = globalContext['document'] as JSObject;
  final existing = doc.callMethod<JSAny?>(
      'getElementById'.toJS, 'sol-zxing-photo'.toJS);
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
    script['id'] = 'sol-zxing-photo'.toJS;
    script['src'] = _kZxingUrl.toJS;
    (doc['head'] as JSObject).callMethod<JSAny?>('appendChild'.toJS, script);
  }
  final ok = await c.future
      .timeout(const Duration(seconds: 12), onTimeout: () => false);
  return ok && globalContext.has('ZXing');
}

Future<String?> decodeBarcodeFromPhoto(Uint8List bytes, String mime) async {
  try {
    if (!await _ensureZxing()) return null;
    final zx = globalContext['ZXing'] as JSObject;
    // Hints: TRY_HARDER (3) = gründlicher suchen.
    final hints = (globalContext['Map'] as JSFunction).callAsConstructor<JSObject>();
    final tryHarder = (zx['DecodeHintType'] as JSObject)['TRY_HARDER'];
    hints.callMethod<JSAny?>('set'.toJS, tryHarder, true.toJS);
    final reader = (zx['BrowserMultiFormatReader'] as JSFunction)
        .callAsConstructor<JSObject>(hints);
    final url = 'data:${mime.isEmpty ? 'image/jpeg' : mime};base64,${base64Encode(bytes)}';
    final res = await reader
        .callMethod<JSPromise<JSObject>>('decodeFromImageUrl'.toJS, url.toJS)
        .toDart;
    final text = res.callMethod<JSString>('getText'.toJS).toDart;
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  }
}
