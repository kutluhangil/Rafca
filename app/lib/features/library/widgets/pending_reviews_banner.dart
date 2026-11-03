import 'package:flutter/material.dart';

import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';

/// Top banner displayed when items require user review or correction.
///
/// Implements BLUEPRINT §8 invariant: UNKNOWN and REVIEW items never pollute
/// the clean library catalog, staying in this banner until resolved.
class PendingReviewsBanner extends StatelessWidget {
  const PendingReviewsBanner({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: SpineSpacing.pageMargin,
        vertical: SpineSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(SpineRadius.card),
        border: Border.all(
          color: semantic.review,
          width: SpineBorders.hairline,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpineRadius.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpineSpacing.base,
              vertical: SpineSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpineSpacing.xs),
                  decoration: BoxDecoration(
                    color: semantic.review.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: semantic.review,
                    size: 20,
                  ),
                ),
                const SizedBox(width: SpineSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count BEKLEYEN ÖĞE / PENDING ISSUES',
                        style: SpineTypography.metadataCaps.copyWith(
                          color: semantic.review,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'İnceleme veya düzeltme gerektiren taranmış kitap sırtları var.',
                        style: SpineTypography.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: semantic.review,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
