import 'dart:math' as math;

import 'package:spine_clustering/spine_clustering.dart';

/// Builds one OCR element as an oriented rectangle.
///
/// [angle] is the direction the text runs, in radians. [alongLength] is the
/// word's extent in that direction, [acrossHeight] its glyph height.
OcrTextElement word(
  String text, {
  required double centerX,
  required double centerY,
  required double angle,
  double alongLength = 35,
  double acrossHeight = 30,
  int sourceRotation = 0,
  double? confidence,
}) {
  final along = unitVector(angle);
  final across = perpendicularVector(angle);
  final halfAlong = alongLength / 2;
  final halfAcross = acrossHeight / 2;

  Point2 corner(double a, double c) => Point2(
        centerX + along.x * a + across.x * c,
        centerY + along.y * a + across.y * c,
      );

  return OcrTextElement(
    text: text,
    corners: [
      corner(-halfAlong, -halfAcross),
      corner(halfAlong, -halfAcross),
      corner(halfAlong, halfAcross),
      corner(-halfAlong, halfAcross),
    ],
    sourceRotation: sourceRotation,
    confidence: confidence,
  );
}

/// Text running bottom-to-top, the usual orientation of lettering on a spine
/// standing on a horizontal shelf.
const spineTextAngle = -math.pi / 2;

/// A horizontal shelf of vertical spines.
///
/// [titles] is one word list per spine, ordered as the words appear reading
/// from the bottom of the spine upwards. Spines are laid out left to right at
/// [spineWidth] pixel centres starting at [firstSpineX].
List<OcrTextElement> shelf(
  List<List<String>> titles, {
  double firstSpineX = 200,
  double spineWidth = 140,
  double baselineY = 1200,
  double wordSpacing = 90,
  double glyphHeight = 50,
}) {
  final elements = <OcrTextElement>[];
  for (var s = 0; s < titles.length; s++) {
    final x = firstSpineX + s * spineWidth;
    for (var w = 0; w < titles[s].length; w++) {
      elements.add(
        word(
          titles[s][w],
          // Slight horizontal wobble, as real lettering is never perfectly
          // centred on the spine.
          centerX: x + ((w % 3) - 1) * 3,
          centerY: baselineY - w * wordSpacing,
          angle: spineTextAngle,
          alongLength: titles[s][w].length * 24,
          acrossHeight: glyphHeight,
        ),
      );
    }
  }
  return elements;
}
