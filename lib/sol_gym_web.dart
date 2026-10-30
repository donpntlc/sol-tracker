import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// true, wenn PREPIT in einem Rahmen (SOL-GYM) läuft.
bool solGymEmbedded() {
  try {
    final top = globalContext['top'];
    final self = globalContext['self'];
    if (top == null || self == null) return false;
    return !top.strictEquals(self).toDart;
  } catch (_) {
    return false;
  }
}

/// Sagt SOL-GYM: zum anderen Bereich (REPIT) wechseln.
void solGymSwitch() {
  try {
    final p = globalContext['parent'] as JSObject?;
    p?.callMethod<JSAny?>('postMessage'.toJS, 'solgym:switch'.toJS, '*'.toJS);
  } catch (_) {}
}
