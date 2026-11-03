import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spine_clustering/spine_clustering.dart';

import 'ocr_engine.dart';

class ScanResult {
  const ScanResult({
    required this.candidates,
    required this.cropPaths,
    required this.dominantColors,
  });

  final List<SpineCandidate> candidates;
  final Map<String, String> cropPaths;
  final Map<String, String> dominantColors;
}

typedef ScanProgressCallback = void Function(
  double progress,
  String log, {
  List<SpineCandidate>? detectedSoFar,
});

class ScanController {
  ScanController({OcrEngine? engine}) : _engine = engine ?? OcrEngine();

  final OcrEngine _engine;

  Future<ScanResult> runScan({
    required String imagePath,
    required ScanProgressCallback onProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Scan pipeline is not supported on web; runs on device.',
      );
    }

    final file = File(imagePath);
    if (!file.existsSync()) {
      throw ArgumentError('Image file not found at $imagePath');
    }

    onProgress(0.05, 'GÖRÜNTÜ YÜKLENİYOR...');
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Görüntü çözülemedi.');
    }

    final origW = decoded.width;
    final origH = decoded.height;
    final allElements = <OcrTextElement>[];

    // 4 rotations for text detection per SPINE_BLUEPRINT.md 7.3 step 1
    const rotations = [0, 90, 180, 270];
    for (var i = 0; i < rotations.length; i++) {
      final rot = rotations[i];
      final prog = 0.10 + (i / rotations.length) * 0.45;
      onProgress(prog, 'OCR ÇALIŞTIRILIYOR [$rot°]...');

      final elements = await _engine.recognizePath(
        imagePath,
        rotationDegrees: rot,
        imageWidth: origW,
        imageHeight: origH,
      );
      allElements.addAll(elements);
    }

    onProgress(0.60, 'METİN BLOKLARI KÜMELENİYOR...');
    final candidates = segmentSpines(allElements);

    onProgress(
      0.70,
      '${candidates.length} SIRT ADAYI TESPİT EDİLDİ.',
      detectedSoFar: candidates,
    );

    // Step 9: Crop candidates and extract dominant colors
    final appDir = await getApplicationDocumentsDirectory();
    final capturesDir = Directory(p.join(appDir.path, 'spine', 'captures'));
    if (!capturesDir.existsSync()) {
      capturesDir.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cropPaths = <String, String>{};
    final dominantColors = <String, String>{};

    for (var i = 0; i < candidates.length; i++) {
      final cand = candidates[i];
      final prog = 0.70 + (i / math.max(1, candidates.length)) * 0.25;
      onProgress(prog, 'SIRT AYRIŞTIRILIYOR [${cand.id}]...');

      final margin = cand.bbox.width * 0.04;
      final clampedBox =
          cand.bbox.expand(margin).clampTo(decoded.width, decoded.height);

      final cropW = clampedBox.width.round();
      final cropH = clampedBox.height.round();

      if (cropW >= 2 && cropH >= 2) {
        final cropped = img.copyCrop(
          decoded,
          x: clampedBox.left.round(),
          y: clampedBox.top.round(),
          width: cropW,
          height: cropH,
        );

        final cropFilename = 'spine_${timestamp}_${cand.id}.png';
        final cropFile = File(p.join(capturesDir.path, cropFilename));
        await cropFile.writeAsBytes(img.encodePng(cropped));

        cropPaths[cand.id] = cropFile.path;
        dominantColors[cand.id] = _extractDominantColor(cropped);
      }
    }

    onProgress(1.0, 'İŞLEM TAMAMLANDI.');

    return ScanResult(
      candidates: candidates,
      cropPaths: cropPaths,
      dominantColors: dominantColors,
    );
  }

  void dispose() {
    _engine.dispose();
  }

  static String _extractDominantColor(img.Image image, {int sampleSize = 64}) {
    final small = image.width > sampleSize || image.height > sampleSize
        ? img.copyResize(
            image,
            width: image.width >= image.height ? sampleSize : null,
            height: image.height > image.width ? sampleSize : null,
          )
        : image;

    final counts = <int, int>{};
    final sums = <int, List<int>>{};
    for (final pixel in small) {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final bucket = (r >> 4) << 8 | (g >> 4) << 4 | (b >> 4);
      counts[bucket] = (counts[bucket] ?? 0) + 1;
      final sum = sums[bucket] ??= [0, 0, 0];
      sum[0] += r;
      sum[1] += g;
      sum[2] += b;
    }
    if (counts.isEmpty) return '#3A332A';

    var bestBucket = counts.keys.first;
    var bestCount = 0;
    counts.forEach((bucket, count) {
      if (count > bestCount) {
        bestCount = count;
        bestBucket = bucket;
      }
    });

    final sum = sums[bestBucket]!;
    final r = (sum[0] / bestCount).round().clamp(0, 255);
    final g = (sum[1] / bestCount).round().clamp(0, 255);
    final b = (sum[2] / bestCount).round().clamp(0, 255);
    return '#${_hex(r)}${_hex(g)}${_hex(b)}';
  }

  static String _hex(int value) => value.toRadixString(16).padLeft(2, '0');
}
