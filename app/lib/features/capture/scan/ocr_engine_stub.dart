import 'package:spine_clustering/spine_clustering.dart';

/// Web stub for OCR engine. Throws UnsupportedError per CLAUDE.md.
class OcrEngine {
  const OcrEngine();

  Future<List<OcrTextElement>> recognizePath(
    String imagePath, {
    int rotationDegrees = 0,
    int? imageWidth,
    int? imageHeight,
  }) async {
    throw UnsupportedError(
      'OCR (google_mlkit_text_recognition) is only supported on mobile platforms.',
    );
  }

  void dispose() {}
}
