import 'dart:typed_data';

import 'barcode_photo_decode_stub.dart'
    if (dart.library.js_interop) 'barcode_photo_decode_web.dart' as _impl;

/// Liest einen Barcode aus einem Foto (nur Web; sonst immer null).
Future<String?> decodeBarcodeFromPhoto(Uint8List bytes, String mime) =>
    _impl.decodeBarcodeFromPhoto(bytes, mime);

bool barcodeLibLoaded() => _impl.barcodeLibLoaded();
