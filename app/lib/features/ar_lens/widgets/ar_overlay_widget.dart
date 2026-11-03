import 'package:flutter/material.dart';

import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../models/ar_lens_models.dart';

/// Interactive HUD layer rendered on top of the live camera preview.
class ArOverlayWidget extends StatelessWidget {
  const ArOverlayWidget({
    super.key,
    required this.items,
    this.onTapItem,
    this.isProcessing = false,
  });

  final List<ArDetectedItem> items;
  final ValueChanged<ArDetectedItem>? onTapItem;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. HUD Canvas Painter
            CustomPaint(
              size: size,
              painter: _ArHudPainter(
                items: items,
                semantic: context.spineColors,
              ),
            ),

            // 2. Interactive Badges Layer
            for (final item in items) _buildInteractiveBadge(context, item, size),

            // 3. Status indicator pill in top-right
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpineSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(SpineRadius.chip),
                  border: Border.all(
                    color: isProcessing ? context.spineColors.brass : Colors.white30,
                    width: SpineBorders.hairline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isProcessing
                            ? context.spineColors.brass
                            : const Color(0xFF2F5D2C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isProcessing ? 'TARANIYOR' : 'CANLI AR LENSİ',
                      style: SpineTypography.metadataCaps.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInteractiveBadge(
    BuildContext context,
    ArDetectedItem item,
    Size size,
  ) {
    final rect = Rect.fromLTRB(
      item.normalizedRect.left * size.width,
      item.normalizedRect.top * size.height,
      item.normalizedRect.right * size.width,
      item.normalizedRect.bottom * size.height,
    );

    final semantic = context.spineColors;
    final color = switch (item.status) {
      ArBookStatus.ownedRead => const Color(0xFF2F5D2C),
      ArBookStatus.ownedUnread => semantic.brass,
      ArBookStatus.notOwned => const Color(0xFFE8E1DD),
    };

    final icon = switch (item.status) {
      ArBookStatus.ownedRead => Icons.check_circle,
      ArBookStatus.ownedUnread => Icons.bookmark,
      ArBookStatus.notOwned => Icons.add_circle_outline,
    };

    final label = switch (item.status) {
      ArBookStatus.ownedRead => 'KÜTÜPHANEDE (OKUNDU)',
      ArBookStatus.ownedUnread => 'OKUNACAK',
      ArBookStatus.notOwned => 'LİSTEYE EKLE',
    };

    final top = (rect.top - 28).clamp(10.0, size.height - 40);
    final left = rect.left.clamp(10.0, size.width - 160);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => onTapItem?.call(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(SpineRadius.chip),
            border: Border.all(color: color, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: SpineTypography.metadataCaps.copyWith(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArHudPainter extends CustomPainter {
  const _ArHudPainter({
    required this.items,
    required this.semantic,
  });

  final List<ArDetectedItem> items;
  final SpineSemanticColors semantic;

  @override
  void paint(Canvas canvas, Size size) {
    for (final item in items) {
      final rect = Rect.fromLTRB(
        item.normalizedRect.left * size.width,
        item.normalizedRect.top * size.height,
        item.normalizedRect.right * size.width,
        item.normalizedRect.bottom * size.height,
      );

      final color = switch (item.status) {
        ArBookStatus.ownedRead => const Color(0xFF2F5D2C),
        ArBookStatus.ownedUnread => semantic.brass,
        ArBookStatus.notOwned => const Color(0xFFE8E1DD),
      };

      // Shaded background box
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(SpineRadius.thumbnail)),
        fillPaint,
      );

      // Border outline
      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(SpineRadius.thumbnail)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArHudPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}
