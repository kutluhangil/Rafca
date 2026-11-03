import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spine_clustering/spine_clustering.dart';

class OcrEngine {
  OcrEngine()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  /// Runs OCR on [imagePath] rotated clockwise by [rotationDegrees] (0, 90, 180, 270),
  /// and returns recognized elements mapped back to original image coordinates.
  Future<List<OcrTextElement>> recognizePath(
    String imagePath, {
    int rotationDegrees = 0,
    int? imageWidth,
    int? imageHeight,
  }) async {
    final originalFile = File(imagePath);
    if (!originalFile.existsSync()) {
      throw ArgumentError('Image file does not exist at $imagePath');
    }

    int origW = imageWidth ?? 0;
    int origH = imageHeight ?? 0;

    String targetPath = imagePath;
    File? tempFile;

    if (origW == 0 || origH == 0 || rotationDegrees != 0) {
      final bytes = await originalFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw StateError('Cannot decode image at $imagePath');
      }
      origW = decoded.width;
      origH = decoded.height;

      if (rotationDegrees != 0) {
        final rotated = img.copyRotate(decoded, angle: rotationDegrees);
        final tempDir = await getTemporaryDirectory();
        final tempFilename =
            'rot_${rotationDegrees}_${p.basenameWithoutExtension(imagePath)}.jpg';
        tempFile = File(p.join(tempDir.path, tempFilename));
        await tempFile.writeAsBytes(img.encodeJpg(rotated, quality: 90));
        targetPath = tempFile.path;
      }
    }

    try {
      final inputImage = InputImage.fromFilePath(targetPath);
      final recognizedText = await _recognizer.processImage(inputImage);

      final elements = <OcrTextElement>[];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final lineCorners = line.cornerPoints;
          if (lineCorners.length != 4) continue;

          // Map rotated points back to unrotated original image space
          final unrotatedCorners = <Point2>[];
          for (final pt in lineCorners) {
            final mapped = unrotatePoint(
              Point2(pt.x.toDouble(), pt.y.toDouble()),
              rotationDegrees,
              origW,
              origH,
            );
            unrotatedCorners.add(mapped);
          }

          final text = line.text.trim();
          if (text.isNotEmpty) {
            elements.add(
              OcrTextElement(
                text: text,
                corners: unrotatedCorners,
                sourceRotation: rotationDegrees,
                confidence: line.confidence,
              ),
            );
          }
        }
      }

      return elements;
    } finally {
      if (tempFile != null && tempFile.existsSync()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
