import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'isbn_validator.dart';

/// Native ML Kit Barcode engine scanning EAN-13 and EAN-8 barcodes.
class BarcodeEngine {
  BarcodeEngine()
      : _scanner = BarcodeScanner(
          formats: [
            BarcodeFormat.ean13,
            BarcodeFormat.ean8,
          ],
        );

  final BarcodeScanner _scanner;

  /// Scans [filePath] for EAN barcodes and returns validated ISBN-13 strings.
  Future<List<String>> scanFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw ArgumentError('Barcode target file does not exist at $filePath');
    }

    final inputImage = InputImage.fromFilePath(filePath);
    final barcodes = await _scanner.processImage(inputImage);

    final results = <String>[];
    for (final barcode in barcodes) {
      final raw = barcode.rawValue ?? barcode.displayValue;
      if (raw == null) continue;

      final normalized = IsbnValidator.normalizeToIsbn13(raw);
      if (normalized != null && !results.contains(normalized)) {
        results.add(normalized);
      }
    }

    return results;
  }

  void dispose() {
    _scanner.close();
  }
}
