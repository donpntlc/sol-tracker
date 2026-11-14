import 'web_share_stub.dart' if (dart.library.js_interop) 'web_share_web.dart'
    as _impl;

/// Öffnet das System-Teilen-Menü (Web Share API). false = nicht verfügbar.
/// Muss direkt im Tipp-Handler aufgerufen werden (ohne vorheriges await).
Future<bool> shareText(String title, String text) =>
    _impl.shareText(title, text);

/// Kalender-Datei (.ics) öffnen/herunterladen — iPhone bietet „Zum Kalender hinzufügen“.
Future<bool> openIcsFile(String filename, String ics) =>
    _impl.openIcsFile(filename, ics);
