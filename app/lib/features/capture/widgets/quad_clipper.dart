import 'package:flutter/material.dart';

import '../../../design/tokens/colors.dart';

/// The four corners of the perspective crop quadrilateral.
class QuadPoints {
  const QuadPoints({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;

  QuadPoints copyWith({
    Offset? topLeft,
    Offset? topRight,
    Offset? bottomRight,
    Offset? bottomLeft,
  }) {
    return QuadPoints(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomRight: bottomRight ?? this.bottomRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
    );
  }

  Path toPath() {
    return Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();
  }
}

/// Interactive 4-corner perspective quad editor.
class QuadEditor extends StatefulWidget {
  const QuadEditor({
    super.key,
    required this.size,
    required this.initialQuad,
    required this.onChanged,
  });

  final Size size;
  final QuadPoints initialQuad;
  final ValueChanged<QuadPoints> onChanged;

  @override
  State<QuadEditor> createState() => _QuadEditorState();
}

class _QuadEditorState extends State<QuadEditor> {
  late QuadPoints _quad;
  int? _activeCorner; // 0: TL, 1: TR, 2: BR, 3: BL

  @override
  void initState() {
    super.initState();
    _quad = widget.initialQuad;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;

    return GestureDetector(
      onPanStart: (details) {
        final pos = details.localPosition;
        _activeCorner = _findNearestCorner(pos);
      },
      onPanUpdate: (details) {
        if (_activeCorner == null) return;
        final pos = details.localPosition;
        final clamped = Offset(
          pos.dx.clamp(0.0, widget.size.width),
          pos.dy.clamp(0.0, widget.size.height),
        );

        setState(() {
          switch (_activeCorner!) {
            case 0:
              _quad = _quad.copyWith(topLeft: clamped);
              break;
            case 1:
              _quad = _quad.copyWith(topRight: clamped);
              break;
            case 2:
              _quad = _quad.copyWith(bottomRight: clamped);
              break;
            case 3:
              _quad = _quad.copyWith(bottomLeft: clamped);
              break;
          }
        });
        widget.onChanged(_quad);
      },
      onPanEnd: (_) {
        _activeCorner = null;
      },
      child: CustomPaint(
        size: widget.size,
        painter: _QuadPainter(
          quad: _quad,
          brassColor: semantic.brass,
          activeCorner: _activeCorner,
        ),
      ),
    );
  }

  int? _findNearestCorner(Offset pos) {
    const touchRadius = 40.0;
    final corners = [_quad.topLeft, _quad.topRight, _quad.bottomRight, _quad.bottomLeft];
    for (var i = 0; i < corners.length; i++) {
      if ((corners[i] - pos).distance <= touchRadius) {
        return i;
      }
    }
    return null;
  }
}

class _QuadPainter extends CustomPainter {
  const _QuadPainter({
    required this.quad,
    required this.brassColor,
    this.activeCorner,
  });

  final QuadPoints quad;
  final Color brassColor;
  final int? activeCorner;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dim background outside quad
    final fullRect = Offset.zero & size;
    final quadPath = quad.toPath();
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);

    final outsidePath = Path.combine(
      PathOperation.difference,
      Path()..addRect(fullRect),
      quadPath,
    );
    canvas.drawPath(outsidePath, dimPaint);

    // 2. Stroke quad border
    final borderPaint = Paint()
      ..color = brassColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(quadPath, borderPaint);

    // 3. Draw corner handles
    final handlePaint = Paint()
      ..color = brassColor
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final corners = [quad.topLeft, quad.topRight, quad.bottomRight, quad.bottomLeft];
    for (var i = 0; i < corners.length; i++) {
      final pt = corners[i];
      final isSelected = activeCorner == i;
      final radius = isSelected ? 14.0 : 10.0;

      canvas.drawCircle(pt, radius, handlePaint);
      canvas.drawCircle(pt, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuadPainter oldDelegate) {
    return oldDelegate.quad != quad ||
        oldDelegate.brassColor != brassColor ||
        oldDelegate.activeCorner != activeCorner;
  }
}
