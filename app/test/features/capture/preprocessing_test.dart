import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:rafca/features/capture/preprocessing/preprocessor.dart';

void main() {
  group('CapturePreprocessor', () {
    const preprocessor = CapturePreprocessor();

    test('toGrayscale converts color image to 1-channel or luminance image', () {
      final colorImg = img.Image(width: 10, height: 10);
      colorImg.setPixelRgb(0, 0, 255, 0, 0); // Red pixel

      final gray = preprocessor.toGrayscale(colorImg);
      final pixel = gray.getPixel(0, 0);

      // In grayscale, R, G and B channels should match the luminance
      expect(pixel.r, equals(pixel.g));
      expect(pixel.g, equals(pixel.b));
    });

    test('capMaxDimension leaves smaller images unchanged', () {
      final small = img.Image(width: 800, height: 600);
      final capped = preprocessor.capMaxDimension(small, maxSide: 4000);

      expect(capped.width, equals(800));
      expect(capped.height, equals(600));
    });

    test('capMaxDimension downscales images with dimension > 4000', () {
      final large = img.Image(width: 5000, height: 2500);
      final capped = preprocessor.capMaxDimension(large, maxSide: 4000);

      expect(capped.width, equals(4000));
      expect(capped.height, equals(2000));
    });

    test('warpPerspective performs rectangular mapping without crashing', () {
      final src = img.Image(width: 100, height: 100);
      img.fill(src, color: img.ColorRgb8(120, 120, 120));

      final corners = [
        const math.Point<double>(10, 10),
        const math.Point<double>(90, 10),
        const math.Point<double>(90, 90),
        const math.Point<double>(10, 90),
      ];

      final warped = preprocessor.warpPerspective(
        src,
        corners,
        targetWidth: 80,
        targetHeight: 80,
      );

      expect(warped.width, equals(80));
      expect(warped.height, equals(80));
    });
  });
}
