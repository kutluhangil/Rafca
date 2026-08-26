import 'dart:math' as math;

/// A point in image pixel space. Origin is top-left, y grows downward.
class Point2 {
  const Point2(this.x, this.y);

  final double x;
  final double y;

  Point2 operator -(Point2 other) => Point2(x - other.x, y - other.y);

  double dot(Point2 other) => x * other.x + y * other.y;

  double get length => math.sqrt(x * x + y * y);

  @override
  String toString() => '(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})';
}

/// Axis-aligned bounding box in image pixel space.
class BBox {
  const BBox(this.left, this.top, this.right, this.bottom);

  factory BBox.fromPoints(List<Point2> points) {
    if (points.isEmpty) {
      throw ArgumentError.value(points, 'points', 'must not be empty');
    }
    var left = points.first.x;
    var right = points.first.x;
    var top = points.first.y;
    var bottom = points.first.y;
    for (final p in points.skip(1)) {
      if (p.x < left) left = p.x;
      if (p.x > right) right = p.x;
      if (p.y < top) top = p.y;
      if (p.y > bottom) bottom = p.y;
    }
    return BBox(left, top, right, bottom);
  }

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  double get area => width * height;
  Point2 get center => Point2((left + right) / 2, (top + bottom) / 2);

  /// Intersection-over-union with [other]. Returns 0 when they do not overlap.
  double iou(BBox other) {
    final ix = math.min(right, other.right) - math.max(left, other.left);
    final iy = math.min(bottom, other.bottom) - math.max(top, other.top);
    if (ix <= 0 || iy <= 0) return 0;
    final intersection = ix * iy;
    final union = area + other.area - intersection;
    if (union <= 0) return 0;
    return intersection / union;
  }

  BBox expand(double margin) =>
      BBox(left - margin, top - margin, right + margin, bottom + margin);

  BBox clampTo(int imageWidth, int imageHeight) => BBox(
        left.clamp(0, imageWidth.toDouble()),
        top.clamp(0, imageHeight.toDouble()),
        right.clamp(0, imageWidth.toDouble()),
        bottom.clamp(0, imageHeight.toDouble()),
      );

  @override
  String toString() =>
      'BBox(${left.toStringAsFixed(0)}, ${top.toStringAsFixed(0)}, '
      '${right.toStringAsFixed(0)}, ${bottom.toStringAsFixed(0)})';
}

/// Maps a point from an image rotated clockwise by [rotationDegrees] back into
/// the coordinate space of the unrotated image of size [width] x [height].
///
/// [width] and [height] are the dimensions of the ORIGINAL (unrotated) image.
/// Only 0, 90, 180 and 270 are accepted.
Point2 unrotatePoint(
  Point2 p,
  int rotationDegrees,
  int width,
  int height,
) {
  switch (rotationDegrees) {
    case 0:
      return p;
    case 90:
      // CW 90: rotated canvas is (height, width). Original top-left lands on
      // the rotated top-right, so (x', y') maps back to (y', height-1-x').
      return Point2(p.y, height - 1 - p.x);
    case 180:
      return Point2(width - 1 - p.x, height - 1 - p.y);
    case 270:
      return Point2(width - 1 - p.y, p.x);
    default:
      throw ArgumentError.value(
        rotationDegrees,
        'rotationDegrees',
        'must be one of 0, 90, 180, 270',
      );
  }
}

/// Direction of the text baseline in radians, derived from the first two
/// corner points (top-left -> top-right).
double baselineAngle(List<Point2> corners) {
  if (corners.length < 2) {
    throw ArgumentError.value(corners, 'corners', 'needs at least 2 points');
  }
  final v = corners[1] - corners[0];
  return math.atan2(v.y, v.x);
}

/// Wraps [radians] into [0, pi). Axial data: a line at 10 deg and one at
/// 190 deg have the same orientation.
double axialNormalize(double radians) {
  var a = radians % math.pi;
  if (a < 0) a += math.pi;
  return a;
}

/// Shortest angular distance between two axial (mod pi) orientations.
double axialDistance(double a, double b) {
  final d = (axialNormalize(a) - axialNormalize(b)).abs();
  return math.min(d, math.pi - d);
}

/// Axial median orientation: the observed angle minimising the summed axial
/// distance to every other angle. Robust to outlier detections, unlike a mean.
///
/// This is SPINE_BLUEPRINT.md 7.3 step 4 ("element acilarinin medyani") made
/// well-defined for angles, which wrap around.
double axialMedianAngle(List<double> angles) {
  if (angles.isEmpty) {
    throw ArgumentError.value(angles, 'angles', 'must not be empty');
  }
  var bestAngle = angles.first;
  var bestCost = double.infinity;
  for (final candidate in angles) {
    var cost = 0.0;
    for (final other in angles) {
      cost += axialDistance(candidate, other);
    }
    if (cost < bestCost) {
      bestCost = cost;
      bestAngle = candidate;
    }
  }
  return axialNormalize(bestAngle);
}

/// Median of a numeric list. Does not mutate [values].
double median(List<double> values) {
  if (values.isEmpty) {
    throw ArgumentError.value(values, 'values', 'must not be empty');
  }
  final sorted = List<double>.of(values)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return (sorted[mid - 1] + sorted[mid]) / 2;
}

/// Unit vector pointing along [radians].
Point2 unitVector(double radians) => Point2(math.cos(radians), math.sin(radians));

/// Unit vector perpendicular to [radians], rotated a quarter turn.
Point2 perpendicularVector(double radians) =>
    Point2(-math.sin(radians), math.cos(radians));

/// Wraps [radians] into (-pi, pi].
double wrapToPi(double radians) {
  var a = radians % (2 * math.pi);
  if (a > math.pi) a -= 2 * math.pi;
  if (a <= -math.pi) a += 2 * math.pi;
  return a;
}
