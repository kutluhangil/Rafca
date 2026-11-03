/// Web and test stub for Barcode engine. Throws UnsupportedError per CLAUDE.md.
class BarcodeEngine {
  const BarcodeEngine();

  Future<List<String>> scanFile(String filePath) async {
    throw UnsupportedError(
      'Barcode scanning (google_mlkit_barcode_scanning) is only supported on mobile platforms.',
    );
  }

  void dispose() {}
}
