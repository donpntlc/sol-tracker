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
