import 'dart:js_interop';
import 'dart:js_interop_unsafe';

Future<bool> shareText(String title, String text) async {
  try {
    final nav = globalContext['navigator'] as JSObject?;
    if (nav == null || !nav.has('share')) return false;
    final data = JSObject();
    data['title'] = title.toJS;
    data['text'] = text.toJS;
    // Sofort (synchron) aufrufen, damit der Tipp als Nutzeraktion zählt.
    final p = nav.callMethod<JSPromise<JSAny?>>('share'.toJS, data);
    try {
      await p.toDart;
    } catch (_) {
      // Abgebrochen vom Nutzer = trotzdem „geteilt-Menü war da“.
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> openIcsFile(String filename, String ics) async {
  try {
    final blobCtor = globalContext['Blob'] as JSFunction;
    final opts = JSObject();
    opts['type'] = 'text/calendar;charset=utf-8'.toJS;
    final blob = blobCtor.callAsConstructor<JSObject>(<JSAny>[ics.toJS].toJS, opts);
    final urlObj = globalContext['URL'] as JSObject;
    final url = urlObj.callMethod<JSString>('createObjectURL'.toJS, blob);
    final doc = globalContext['document'] as JSObject;
    final a = doc.callMethod<JSObject>('createElement'.toJS, 'a'.toJS);
    a['href'] = url;
    a['download'] = filename.toJS;
    a['target'] = '_blank'.toJS;
    final body = doc['body'] as JSObject;
    body.callMethod<JSAny?>('appendChild'.toJS, a);
    a.callMethod<JSAny?>('click'.toJS);
    body.callMethod<JSAny?>('removeChild'.toJS, a);
    return true;
  } catch (_) {
    return false;
  }
}
