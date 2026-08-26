import 'dart:math' as math;

import 'geometry.dart';
import 'models.dart';

/// Segments OCR text elements into book spine candidates.
///
/// Implements SPINE_BLUEPRINT.md 7.3. [elements] must already be mapped into
/// the coordinate space of the unrotated image; see [unrotatePoint].
///
/// Returns candidates ordered along the shelf (left to right for a horizontal
/// shelf), ids `c1`..`cN`.
List<SpineCandidate> segmentSpines(
  List<OcrTextElement> elements, {
  ClusteringConfig config = const ClusteringConfig(),
}) {
  if (elements.isEmpty) return const [];

  // Step 2b — one physical word detected at several rotations collapses to
  // the single best detection.
  final deduped = _dedupe(elements, config.dedupeIouThreshold);

  // Step 3 — drop noise.
  final denoised = _dropNoise(deduped, config);
  if (denoised.isEmpty) return const [];

  // Step 4 — dominant spine orientation, then the direction lettering is
  // actually read in. The axial median is robust but discards the sign, so
  // the sign is recovered by majority vote over the raw OCR angles.
  final spineAngle = _dominantReadingAngle(denoised);
  final along = unitVector(spineAngle);
  final across = _canonicalAcross(spineAngle);

  final glyphHeight = median([
    for (final e in denoised) e.extentAlong(perpendicularVector(e.angle)),
  ]);

  // Step 5 — project every centre onto the axis across the spines.
  final projected = [
    for (final e in denoised) (element: e, pos: e.projectCenter(across)),
  ]..sort((a, b) => a.pos.compareTo(b.pos));

  // Step 6 — decide where a gap means "next spine" rather than "next line".
  final gapThreshold = switch (config.gapStrategy) {
    GapStrategy.blueprint => _blueprintGapThreshold(projected, glyphHeight, config),
    GapStrategy.otsu => _otsuGapThreshold(projected, glyphHeight, config),
  };
  var groups = _splitOnGaps(projected, gapThreshold);

  // Step 7 — a group far wider than its peers is two touching thin spines.
  groups = _splitWideGroups(groups, config.wideCandidateFactor);

  // Steps 8 and 9 — reading order, both directions, pixel box.
  final candidates = <SpineCandidate>[];
  for (var i = 0; i < groups.length; i++) {
    final ordered = _readingOrder(
      groups[i].map((e) => e.element).toList(),
      along: along,
      across: across,
      lineGap: glyphHeight * config.lineGapFactor,
    );
    final tokens = [
      for (final e in ordered)
        if (e.text.trim().isNotEmpty) e.text.trim(),
    ];
    if (tokens.isEmpty) continue;
    candidates.add(
      SpineCandidate(
        id: 'c${candidates.length + 1}',
        elements: ordered,
        bbox: BBox.fromPoints([for (final e in ordered) ...e.corners]),
        rawTextForward: tokens.join(' '),
        rawTextReverse: tokens.reversed.join(' '),
      ),
    );
  }
  return candidates;
}

/// The direction spine lettering runs in, in radians.
///
/// [axialMedianAngle] answers "which line are the spines aligned to" robustly
/// but collapses a direction and its opposite. Reading order needs the sign,
/// so it is taken back from the raw element angles by majority vote.
double _dominantReadingAngle(List<OcrTextElement> elements) {
  final axial = axialMedianAngle([for (final e in elements) e.angle]);
  var agreeing = 0;
  for (final e in elements) {
    if (wrapToPi(e.angle - axial).abs() <= math.pi / 2) agreeing++;
  }
  return agreeing * 2 >= elements.length ? axial : axial + math.pi;
}

/// Axis used to lay candidates out along the shelf.
///
/// Its sign must not depend on which way the lettering happens to run, or two
/// shelves photographed with the text upside down would come back ordered
/// right to left. Canonicalised to point right, or down for a vertical shelf.
Point2 _canonicalAcross(double spineAngle) {
  final v = perpendicularVector(spineAngle);
  const epsilon = 1e-9;
  final pointsLeft = v.x < -epsilon || (v.x.abs() <= epsilon && v.y < 0);
  return pointsLeft ? Point2(-v.x, -v.y) : v;
}

typedef _Projected = ({OcrTextElement element, double pos});

/// Greedy non-maximum suppression over overlapping detections. The strongest
/// detection wins: higher engine confidence first, then longer text.
List<OcrTextElement> _dedupe(List<OcrTextElement> elements, double iouThreshold) {
  final ranked = List<OcrTextElement>.of(elements)
    ..sort((a, b) {
      final byConfidence = (b.confidence ?? 0).compareTo(a.confidence ?? 0);
      if (byConfidence != 0) return byConfidence;
      return b.text.length.compareTo(a.text.length);
    });

  final kept = <OcrTextElement>[];
  final keptBoxes = <BBox>[];
  for (final candidate in ranked) {
    final box = candidate.bbox;
    var duplicate = false;
    for (final other in keptBoxes) {
      if (box.iou(other) >= iouThreshold) {
        duplicate = true;
        break;
      }
    }
    if (duplicate) continue;
    kept.add(candidate);
    keptBoxes.add(box);
  }
  return kept;
}

final RegExp _alphanumeric = RegExp(r'[\p{L}\p{N}]', unicode: true);

List<OcrTextElement> _dropNoise(
  List<OcrTextElement> elements,
  ClusteringConfig config,
) {
  final byLength = [
    for (final e in elements)
      if (e.text.trim().length >= config.minTextLength &&
          _alphanumeric.hasMatch(e.text))
        e,
  ];
  if (byLength.isEmpty) return const [];

  final heights = [
    for (final e in byLength) e.extentAlong(perpendicularVector(e.angle)),
  ];
  final cutoff = median(heights) * config.noiseHeightFraction;
  return [
    for (var i = 0; i < byLength.length; i++)
      if (heights[i] >= cutoff) byLength[i],
  ];
}

/// Splits a position-sorted list wherever the gap to the next element exceeds
/// [maxGap].
List<List<_Projected>> _splitOnGaps(List<_Projected> sorted, double maxGap) {
  if (sorted.isEmpty) return const [];
  final groups = <List<_Projected>>[];
  var current = <_Projected>[sorted.first];
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i].pos - sorted[i - 1].pos > maxGap) {
      groups.add(current);
      current = <_Projected>[];
    }
    current.add(sorted[i]);
  }
  groups.add(current);
  return groups;
}

/// SPINE_BLUEPRINT.md 7.3 step 6. A first pass splits on glyph height alone
/// to estimate how wide a spine is, then the blueprint factor is applied.
double _blueprintGapThreshold(
  List<_Projected> projected,
  double glyphHeight,
  ClusteringConfig config,
) {
  final coarse = _splitOnGaps(projected, glyphHeight * config.coarseGapFactor);
  return _estimateSpineWidth(coarse, glyphHeight) * config.spineGapFactor;
}

/// Otsu threshold over the consecutive-gap distribution. Assumes the gaps
/// split into a tight low group (line breaks within one spine) and a spread
/// high group (spine boundaries), and cuts between them.
///
/// Unlike the blueprint rule this needs no spine-width estimate, so a spine
/// carrying two lines of lettering cannot halve the estimate and cascade into
/// over-segmentation.
double _otsuGapThreshold(
  List<_Projected> projected,
  double glyphHeight,
  ClusteringConfig config,
) {
  final gaps = [
    for (var i = 1; i < projected.length; i++)
      projected[i].pos - projected[i - 1].pos,
  ];
  final positive = gaps.where((g) => g > 0).toList()..sort();
  if (positive.length < 4) {
    return _blueprintGapThreshold(projected, glyphHeight, config);
  }

  final total = positive.length;
  final sumAll = positive.reduce((a, b) => a + b);
  var bestThreshold = positive.last;
  var bestVariance = -1.0;
  var countLow = 0;
  var sumLow = 0.0;

  for (var i = 0; i < total - 1; i++) {
    countLow++;
    sumLow += positive[i];
    if (positive[i] == positive[i + 1]) continue;
    final countHigh = total - countLow;
    final meanLow = sumLow / countLow;
    final meanHigh = (sumAll - sumLow) / countHigh;
    final delta = meanLow - meanHigh;
    final variance = countLow * countHigh * delta * delta;
    if (variance > bestVariance) {
      bestVariance = variance;
      // Cut between the two populations, not on a sample.
      bestThreshold = (positive[i] + positive[i + 1]) / 2;
    }
  }
  return bestThreshold;
}

/// Median centre-to-centre distance between neighbouring coarse groups. Falls
/// back to twice the glyph height when there is only one group to measure.
double _estimateSpineWidth(List<List<_Projected>> coarse, double glyphHeight) {
  if (coarse.length < 2) return glyphHeight * 2;
  final centers = [
    for (final group in coarse)
      group.map((e) => e.pos).reduce((a, b) => a + b) / group.length,
  ];
  final spacings = [
    for (var i = 1; i < centers.length; i++) centers[i] - centers[i - 1],
  ];
  final width = median(spacings);
  return width > 0 ? width : glyphHeight * 2;
}

/// Repeatedly halves any group much wider than its peers. Splitting once is
/// not enough when three or more thin spines merged, so this iterates until
/// the widest group is in range or [maxRounds] is exhausted.
List<List<_Projected>> _splitWideGroups(
  List<List<_Projected>> groups,
  double wideFactor, {
  int maxRounds = 4,
}) {
  var current = groups;
  for (var round = 0; round < maxRounds; round++) {
    final spans = [for (final g in current) _span(g)];
    final limit = median(spans) * wideFactor;
    if (limit <= 0) return current;
    final next = <List<_Projected>>[];
    var didSplit = false;
    for (var i = 0; i < current.length; i++) {
      if (spans[i] > limit && current[i].length > 1) {
        next.addAll(_splitAtWidestGap(current[i]));
        didSplit = true;
      } else {
        next.add(current[i]);
      }
    }
    current = next;
    if (!didSplit) break;
  }
  return current;
}

double _span(List<_Projected> group) {
  if (group.isEmpty) return 0;
  return group.last.pos - group.first.pos;
}

/// Cuts a group in two at its largest internal gap, or at the midpoint when
/// the positions are evenly spread.
List<List<_Projected>> _splitAtWidestGap(List<_Projected> group) {
  var cutIndex = group.length ~/ 2;
  var widest = 0.0;
  for (var i = 1; i < group.length; i++) {
    final gap = group[i].pos - group[i - 1].pos;
    if (gap > widest) {
      widest = gap;
      cutIndex = i;
    }
  }
  if (cutIndex == 0 || cutIndex >= group.length) {
    cutIndex = group.length ~/ 2;
  }
  return [group.sublist(0, cutIndex), group.sublist(cutIndex)];
}

/// Orders the elements of one spine: text lines across the spine first, then
/// words along the spine within each line.
List<OcrTextElement> _readingOrder(
  List<OcrTextElement> elements, {
  required Point2 along,
  required Point2 across,
  required double lineGap,
}) {
  if (elements.length <= 1) return elements;

  final byLine = [
    for (final e in elements) (element: e, pos: e.projectCenter(across)),
  ]..sort((a, b) => a.pos.compareTo(b.pos));

  final lines = _splitOnGaps(byLine, lineGap);
  final ordered = <OcrTextElement>[];
  for (final line in lines) {
    final words = line.map((e) => e.element).toList()
      ..sort(
        (a, b) => a.projectCenter(along).compareTo(b.projectCenter(along)),
      );
    ordered.addAll(words);
  }
  return ordered;
}
