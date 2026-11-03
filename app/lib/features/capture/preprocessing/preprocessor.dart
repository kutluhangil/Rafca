import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Preprocessing pipeline for spine capture according to SPINE_BLUEPRINT.md 7.2.
///
/// 1. Quad perspective warp (homography/bilinear)
/// 2. Grayscale conversion
/// 3. Local contrast enhancement (CLAHE-like)
/// 4. Rescaling so the longer edge is capped at 4000px
class CapturePreprocessor {
  const CapturePreprocessor();

  /// Warps a quadrilateral region defined by [corners] (top-left, top-right,
  /// bottom-right, bottom-left) in [src] into an upright rectangular image.
  ///
  /// Output dimensions can be provided or estimated from the quad edge lengths.
  img.Image warpPerspective(
    img.Image src,
    List<math.Point<double>> corners, {
    int? targetWidth,
    int? targetHeight,
  }) {
    assert(corners.length == 4, 'Corners list must contain exactly 4 points.');

    final p0 = corners[0]; // Top-left
    final p1 = corners[1]; // Top-right
    final p2 = corners[2]; // Bottom-right
    final p3 = corners[3]; // Bottom-left

    // If target dimensions not supplied, estimate from average opposite edges
    final topLen = _distance(p0, p1);
    final bottomLen = _distance(p3, p2);
    final leftLen = _distance(p0, p3);
    final rightLen = _distance(p1, p2);

    final outW = targetWidth ?? math.max(1, ((topLen + bottomLen) / 2).round());
    final outH =
        targetHeight ?? math.max(1, ((leftLen + rightLen) / 2).round());

    final dst = img.Image(width: outW, height: outH);

    for (var y = 0; y < outH; y++) {
      final v = outH > 1 ? y / (outH - 1) : 0.0;
      for (var x = 0; x < outW; x++) {
        final u = outW > 1 ? x / (outW - 1) : 0.0;

        // Bilinear inverse mapping: map destination (u, v) back to source (sx, sy)
        final sx = (1.0 - u) * (1.0 - v) * p0.x +
            u * (1.0 - v) * p1.x +
            u * v * p2.x +
            (1.0 - u) * v * p3.x;

        final sy = (1.0 - u) * (1.0 - v) * p0.y +
            u * (1.0 - v) * p1.y +
            u * v * p2.y +
            (1.0 - u) * v * p3.y;

        final pixel = _sampleBilinear(src, sx, sy);
        dst.setPixel(x, y, pixel);
      }
    }

    return dst;
  }

  /// Converts an image to grayscale.
  img.Image toGrayscale(img.Image src) {
    return img.grayscale(src);
  }

  /// Scales the image down so its maximum dimension is at most [maxSide].
  /// Does not upscale.
  img.Image capMaxDimension(img.Image src, {int maxSide = 4000}) {
    final maxDim = math.max(src.width, src.height);
    if (maxDim <= maxSide) return src;

    final factor = maxSide / maxDim;
    final newW = math.max(1, (src.width * factor).round());
    final newH = math.max(1, (src.height * factor).round());

    return img.copyResize(
      src,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Simple block-based local contrast enhancement (CLAHE approximation).
  img.Image enhanceLocalContrast(
    img.Image src, {
    int tileSize = 64,
  }) {
    final dst = img.Image.from(src);
    final w = src.width;
    final h = src.height;

    for (var ty = 0; ty < h; ty += tileSize) {
      for (var tx = 0; tx < w; tx += tileSize) {
        final bw = math.min(tileSize, w - tx);
        final bh = math.min(tileSize, h - ty);

        var minLum = 255.0;
        var maxLum = 0.0;

        for (var y = 0; y < bh; y++) {
          for (var x = 0; x < bw; x++) {
            final p = src.getPixel(tx + x, ty + y);
            final lum = p.luminanceNormalized * 255.0;
            if (lum < minLum) minLum = lum;
            if (lum > maxLum) maxLum = lum;
          }
        }

        final range = maxLum - minLum;
        if (range > 15) {
          for (var y = 0; y < bh; y++) {
            for (var x = 0; x < bw; x++) {
              final p = src.getPixel(tx + x, ty + y);
              final r = _stretch(p.r, minLum, range);
              final g = _stretch(p.g, minLum, range);
              final b = _stretch(p.b, minLum, range);
              dst.setPixelRgb(tx + x, ty + y, r, g, b);
            }
          }
        }
      }
    }

    return dst;
  }

  int _stretch(num val, double minLum, double range) {
    final normalized = (val - minLum) / range;
    return (normalized.clamp(0.0, 1.0) * 255.0).round();
  }

  double _distance(math.Point<double> a, math.Point<double> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  img.Color _sampleBilinear(img.Image src, double x, double y) {
    final clampedX = x.clamp(0.0, src.width - 1.0);
    final clampedY = y.clamp(0.0, src.height - 1.0);

    final x0 = clampedX.floor();
    final y0 = clampedY.floor();
    final x1 = math.min(x0 + 1, src.width - 1);
    final y1 = math.min(y0 + 1, src.height - 1);

    final fx = clampedX - x0;
    final fy = clampedY - y0;

    final p00 = src.getPixel(x0, y0);
    final p10 = src.getPixel(x1, y0);
    final p01 = src.getPixel(x0, y1);
    final p11 = src.getPixel(x1, y1);

    num interp(num c00, num c10, num c01, num c11) {
      final top = (1.0 - fx) * c00 + fx * c10;
      final bottom = (1.0 - fx) * c01 + fx * c11;
      return (1.0 - fy) * top + fy * bottom;
    }

    final r = interp(p00.r, p10.r, p01.r, p11.r).round().clamp(0, 255);
    final g = interp(p00.g, p10.g, p01.g, p11.g).round().clamp(0, 255);
    final b = interp(p00.b, p10.b, p01.b, p11.b).round().clamp(0, 255);
    final a = interp(p00.a, p10.a, p01.a, p11.a).round().clamp(0, 255);

    return img.ColorRgba8(r, g, b, a);
  }
}
