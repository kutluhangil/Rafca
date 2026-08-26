import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:spine_clustering/spine_clustering.dart';

/// SPINE_BLUEPRINT.md 7.3 step 9: crop each candidate's pixel box and pull its
/// dominant colour, which becomes that book's bar in the ShelfStrip.
class CropResult {
  const CropResult({required this.path, required this.dominantColor});

  final String path;

  /// `#RRGGBB`, the value stored in `user_books.spine_color`.
  final String dominantColor;
}

/// Writes one crop per candidate under [outputDir] and returns them by
/// candidate id.
Map<String, CropResult> writeCrops({
  required img.Image source,
  required List<SpineCandidate> candidates,
  required String outputDir,
  required String photoName,
  double marginFraction = 0.04,
}) {
  Directory(outputDir).createSync(recursive: true);
  final results = <String, CropResult>{};

  for (final candidate in candidates) {
    final margin = candidate.bbox.width * marginFraction;
    final box = candidate.bbox.expand(margin).clampTo(source.width, source.height);
    final width = box.width.round();
    final height = box.height.round();
    if (width < 2 || height < 2) continue;

    final crop = img.copyCrop(
      source,
      x: box.left.round(),
      y: box.top.round(),
      width: width,
      height: height,
    );
    final file = p.join(outputDir, '${photoName}_${candidate.id}.png');
    File(file).writeAsBytesSync(img.encodePng(crop));

    results[candidate.id] = CropResult(
      path: file,
      dominantColor: dominantColor(crop),
    );
  }
  return results;
}

/// Modal colour of an image, as `#RRGGBB`.
///
/// Buckets to 4 bits per channel so that near-identical shades of a leather
/// spine count as one colour, then averages the winning bucket for a value
/// that is not visibly quantised.
String dominantColor(img.Image image, {int sampleSize = 64}) {
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
  if (counts.isEmpty) return '#000000';

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

String _hex(int value) => value.toRadixString(16).padLeft(2, '0');
