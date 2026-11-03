import 'package:flutter/material.dart';
import 'package:spine_clustering/spine_clustering.dart';

import '../../../design/motion/motion.dart';
import '../../../design/tokens/colors.dart';

/// Animated spine candidates overlay for the processing screen.
///
/// SPINE_BLUEPRINT.md 4.7: each spine rectangle is stroked in sequence (120ms),
/// then gets an 8% brass fill.
class SpineOverlay extends StatefulWidget {
  const SpineOverlay({
    super.key,
    required this.candidates,
    required this.originalImageSize,
    required this.viewportSize,
  });

  final List<SpineCandidate> candidates;
  final Size originalImageSize;
  final Size viewportSize;

  @override
  State<SpineOverlay> createState() => _SpineOverlayState();
}

class _SpineOverlayState extends State<SpineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _restartAnimation();
  }

  @override
  void didUpdateWidget(covariant SpineOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candidates.length != widget.candidates.length) {
      _restartAnimation();
    }
  }

  void _restartAnimation() {
    if (widget.candidates.isEmpty) return;
    final totalDuration = SpineMotion.segmentationPerSpine * widget.candidates.length;
    _controller.duration = totalDuration;
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final motion = context.motion;

    if (motion.reduceMotion) {
      return CustomPaint(
        size: widget.viewportSize,
        painter: _SpineOverlayPainter(
          candidates: widget.candidates,
          originalSize: widget.originalImageSize,
          progress: 1.0,
          brassColor: semantic.brass,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: widget.viewportSize,
          painter: _SpineOverlayPainter(
            candidates: widget.candidates,
            originalSize: widget.originalImageSize,
            progress: _controller.value,
            brassColor: semantic.brass,
          ),
        );
      },
    );
  }
}

class _SpineOverlayPainter extends CustomPainter {
  const _SpineOverlayPainter({
    required this.candidates,
    required this.originalSize,
    required this.progress,
    required this.brassColor,
  });

  final List<SpineCandidate> candidates;
  final Size originalSize;
  final double progress;
  final Color brassColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (candidates.isEmpty || originalSize.width <= 0 || originalSize.height <= 0) {
      return;
    }

    final scaleX = size.width / originalSize.width;
    final scaleY = size.height / originalSize.height;

    final visibleCount = (candidates.length * progress).ceil();

    final fillPaint = Paint()
      ..color = brassColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = brassColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < visibleCount && i < candidates.length; i++) {
      final cand = candidates[i];
      final rect = Rect.fromLTRB(
        cand.bbox.left * scaleX,
        cand.bbox.top * scaleY,
        cand.bbox.right * scaleX,
        cand.bbox.bottom * scaleY,
      );

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpineOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.candidates != candidates ||
        oldDelegate.brassColor != brassColor;
  }
}
