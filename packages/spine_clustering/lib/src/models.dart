import 'geometry.dart';

/// One OCR text element (a word or short run) as returned by an OCR engine,
/// already mapped back into the coordinate space of the unrotated image.
class OcrTextElement {
  const OcrTextElement({
    required this.text,
    required this.corners,
    required this.sourceRotation,
    this.confidence,
  });

  /// Raw recognised text.
  final String text;

  /// Four corner points, clockwise from top-left, in original image space.
  final List<Point2> corners;

  /// Which rotation of the image produced this element: 0, 90, 180 or 270.
  final int sourceRotation;

  /// Engine confidence in [0, 1], when the engine reports one.
  final double? confidence;

  BBox get bbox => BBox.fromPoints(corners);

  /// Orientation of the text baseline in radians.
  double get angle => baselineAngle(corners);

  /// Extent of this element measured along [direction].
  double extentAlong(Point2 direction) {
    var lo = double.infinity;
    var hi = double.negativeInfinity;
    for (final c in corners) {
      final v = c.dot(direction);
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    return hi - lo;
  }

  /// Projection of this element's centre onto [direction].
  double projectCenter(Point2 direction) => bbox.center.dot(direction);

  @override
  String toString() => 'OcrTextElement("$text", rot=$sourceRotation)';
}

/// A single detected book spine: the elements that belong to it plus the
/// query strings and crop geometry the matching service needs.
class SpineCandidate {
  const SpineCandidate({
    required this.id,
    required this.elements,
    required this.bbox,
    required this.rawTextForward,
    required this.rawTextReverse,
  });

  /// Stable id within one scan, e.g. `c1`, `c2`.
  final String id;

  /// The OCR elements assigned to this spine, in reading order.
  final List<OcrTextElement> elements;

  /// Axis-aligned pixel box of the spine in original image space.
  final BBox bbox;

  /// Text read in the dominant reading direction.
  final String rawTextForward;

  /// Text read in the opposite direction. Spine lettering runs both ways, so
  /// both are sent to the matcher and the higher score wins.
  final String rawTextReverse;

  @override
  String toString() => 'SpineCandidate($id, "$rawTextForward", $bbox)';
}

/// Tunable thresholds for [segmentSpines]. Defaults come from
/// SPINE_BLUEPRINT.md 7.3; Faz 0 sweeps them against the ground-truth set.
class ClusteringConfig {
  const ClusteringConfig({
    this.minTextLength = 2,
    this.noiseHeightFraction = 0.25,
    this.dedupeIouThreshold = 0.5,
    this.coarseGapFactor = 1.2,
    this.spineGapFactor = 0.6,
    this.wideCandidateFactor = 2.5,
    this.lineGapFactor = 0.8,
    this.gapStrategy = GapStrategy.blueprint,
  });

  /// Elements shorter than this many characters are dropped (step 3).
  final int minTextLength;

  /// Elements whose height is below `median * noiseHeightFraction` are
  /// dropped as noise (step 3, blueprint says median/4).
  final double noiseHeightFraction;

  /// Two detections from different rotations are the same element when their
  /// boxes overlap by at least this IoU (step 2b).
  final double dedupeIouThreshold;

  /// First-pass split threshold, as a multiple of median glyph height. Used
  /// only to estimate spine width; not the final segmentation.
  final double coarseGapFactor;

  /// Final split threshold as a multiple of the estimated spine width
  /// (step 6).
  final double spineGapFactor;

  /// A candidate wider than `median * wideCandidateFactor` is split in two
  /// (step 7).
  final double wideCandidateFactor;

  /// Within one candidate, elements more than `median glyph height * this`
  /// apart across the spine start a new text line (step 8).
  final double lineGapFactor;

  /// Which rule decides a spine boundary. Faz 0 sweeps both and reports
  /// which one scores higher on the ground-truth set.
  final GapStrategy gapStrategy;
}

/// How [segmentSpines] decides that a gap between two projected elements is a
/// spine boundary rather than a line break inside one spine.
enum GapStrategy {
  /// SPINE_BLUEPRINT.md 7.3 step 6 as written: estimate the median spine
  /// width, split where the gap exceeds `spineWidth * spineGapFactor`.
  blueprint,

  /// Otsu threshold over the observed gap distribution. Gaps fall into two
  /// populations — line breaks inside a spine, and boundaries between spines —
  /// and this picks the cut between them without assuming a spine width.
  otsu,
}
