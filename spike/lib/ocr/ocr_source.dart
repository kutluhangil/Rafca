import 'package:spine_clustering/spine_clustering.dart';

/// One OCR pass over one rotation of one image.
class OcrPass {
  const OcrPass({
    required this.rotation,
    required this.originalWidth,
    required this.originalHeight,
    required this.elements,
  });

  final int rotation;
  final int originalWidth;
  final int originalHeight;

  /// Elements already mapped into the ORIGINAL image's coordinate space.
  final List<OcrTextElement> elements;
}

/// An OCR engine the spike can run against.
///
/// The desktop spike uses Apple Vision; the app uses ML Kit on device. The
/// numbers are not identical, which is why the Faz 0 report records which
/// engine produced them and Faz 5 re-measures on device.
abstract interface class OcrSource {
  String get engineName;

  /// Runs OCR on [imagePath] rotated clockwise by [rotation] degrees.
  Future<OcrPass> recognize(String imagePath, int rotation);
}

/// Runs all four rotations and returns every element in original image space.
///
/// SPINE_BLUEPRINT.md 7.3 steps 1 and 2.
Future<List<OcrTextElement>> recognizeAllRotations(
  OcrSource source,
  String imagePath, {
  List<int> rotations = const [0, 90, 180, 270],
}) async {
  final all = <OcrTextElement>[];
  for (final rotation in rotations) {
    final pass = await source.recognize(imagePath, rotation);
    all.addAll(pass.elements);
  }
  return all;
}
