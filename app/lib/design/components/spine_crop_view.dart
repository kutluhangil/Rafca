import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// A spine crop, framed the way the review screens frame it.
///
/// The four brass corner brackets are the point: they say "this is the exact
/// region the app read", which is what makes a wrong match correctable instead
/// of merely wrong. Mockup: `review_correct_spine`.
///
/// The image itself is supplied by the caller as an [ImageProvider] rather
/// than a path, so that Faz 6 can hand it a file, Faz 7 a memory buffer and
/// the gallery a painted placeholder without this widget knowing where crops
/// live. SPINE_BLUEPRINT.md 5 keeps them on the device either way.
class SpineCropView extends StatelessWidget {
  const SpineCropView({
    required this.image,
    this.aspectRatio = 3 / 4,
    this.brackets = true,
    this.semanticLabel,
    this.placeholder,
    super.key,
  });

  /// The crop to show. Null draws [placeholder], for a spine that failed to
  /// crop at all.
  final ImageProvider? image;

  /// Width over height. Defaults to a portrait frame, since a spine crop
  /// rotated upright is always taller than it is wide.
  final double aspectRatio;

  /// Whether to draw the corner brackets. Off for a thumbnail inside a card,
  /// where they would be smaller than the hairline around them.
  final bool brackets;

  /// What a screen reader announces. Null marks the crop decorative.
  final String? semanticLabel;

  /// Drawn when [image] is null.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hairline = context.spineColors.hairline;

    Widget frame = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
        border: Border.all(color: hairline, width: SpineBorders.hairline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
        child: image == null
            ? Center(
                child:
                    placeholder ??
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: scheme.outline,
                    ),
              )
            : Image(image: image!, fit: BoxFit.cover),
      ),
    );

    if (brackets) {
      frame = CustomPaint(
        foregroundPainter: _CornerBracketPainter(
          color: context.spineColors.brass,
        ),
        child: frame,
      );
    }

    frame = AspectRatio(aspectRatio: aspectRatio, child: frame);

    return semanticLabel == null
        ? ExcludeSemantics(child: frame)
        : Semantics(label: semanticLabel, image: true, child: frame);
  }
}

/// Four L-shaped brackets, one per corner, inset from the frame edge.
class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({required this.color});

  final Color color;

  /// How far the bracket sits inside the frame, and how long each arm is.
  static const _inset = SpineSpacing.md;
  static const _arm = SpineSpacing.lg;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Arms shrink on a small crop so the brackets never meet in the middle and
    // turn into a full border.
    final arm = _arm.clamp(0.0, size.shortestSide / 2 - _inset);
    if (arm <= 0) return;

    final left = _inset;
    final top = _inset;
    final right = size.width - _inset;
    final bottom = size.height - _inset;

    for (final (x, y, dx, dy) in [
      (left, top, 1.0, 1.0),
      (right, top, -1.0, 1.0),
      (left, bottom, 1.0, -1.0),
      (right, bottom, -1.0, -1.0),
    ]) {
      canvas
        ..drawLine(Offset(x, y), Offset(x + arm * dx, y), paint)
        ..drawLine(Offset(x, y), Offset(x, y + arm * dy), paint);
    }
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color;
}
