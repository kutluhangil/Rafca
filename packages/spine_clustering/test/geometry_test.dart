import 'dart:math' as math;

import 'package:spine_clustering/spine_clustering.dart';
import 'package:test/test.dart';

void main() {
  group('unrotatePoint', () {
    const width = 400;
    const height = 300;

    test('0 degrees is the identity', () {
      const p = Point2(10, 20);
      final back = unrotatePoint(p, 0, width, height);
      expect(back.x, 10);
      expect(back.y, 20);
    });

    test('maps the rotated top-right back to the original top-left', () {
      // Rotating clockwise by 90 puts the original (0,0) at (height-1, 0).
      final back = unrotatePoint(const Point2(height - 1, 0), 90, width, height);
      expect(back.x, closeTo(0, 0.001));
      expect(back.y, closeTo(0, 0.001));
    });

    test('180 degrees maps the far corner back to the origin', () {
      final back = unrotatePoint(
        const Point2(width - 1, height - 1),
        180,
        width,
        height,
      );
      expect(back.x, closeTo(0, 0.001));
      expect(back.y, closeTo(0, 0.001));
    });

    test('270 degrees maps the rotated bottom-left back to the origin', () {
      final back = unrotatePoint(const Point2(0, width - 1), 270, width, height);
      expect(back.x, closeTo(0, 0.001));
      expect(back.y, closeTo(0, 0.001));
    });

    test('rejects angles that are not multiples of 90', () {
      expect(
        () => unrotatePoint(const Point2(0, 0), 45, width, height),
        throwsArgumentError,
      );
    });
  });

  group('axialMedianAngle', () {
    test('treats an angle and its opposite as the same orientation', () {
      final a = axialMedianAngle([math.pi / 2, -math.pi / 2, math.pi / 2]);
      expect(axialDistance(a, math.pi / 2), closeTo(0, 0.001));
    });

    test('ignores a minority of outliers', () {
      final angles = [
        for (var i = 0; i < 9; i++) -math.pi / 2 + (i - 4) * 0.01,
        0.0,
        0.2,
      ];
      final a = axialMedianAngle(angles);
      expect(axialDistance(a, -math.pi / 2), lessThan(0.05));
    });

    test('rejects an empty list', () {
      expect(() => axialMedianAngle(const []), throwsArgumentError);
    });
  });

  group('BBox', () {
    test('iou is 1 for identical boxes and 0 when disjoint', () {
      const a = BBox(0, 0, 10, 10);
      expect(a.iou(a), closeTo(1, 0.001));
      expect(a.iou(const BBox(20, 20, 30, 30)), 0);
    });

    test('iou of half-overlapping boxes is one third', () {
      const a = BBox(0, 0, 10, 10);
      const b = BBox(5, 0, 15, 10);
      // intersection 50, union 150.
      expect(a.iou(b), closeTo(1 / 3, 0.001));
    });
  });

  group('median', () {
    test('averages the middle pair for an even count', () {
      expect(median([4, 1, 3, 2]), 2.5);
    });

    test('does not mutate its input', () {
      final input = [3.0, 1.0, 2.0];
      median(input);
      expect(input, [3.0, 1.0, 2.0]);
    });
  });
}
