import 'package:flutter/material.dart';

import '../../../design/components/shelf_strip.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../models/library_models.dart';

/// Shelf card per SPINE_BLUEPRINT.md and shelves_list mockup (Image 14).
class ShelfCard extends StatelessWidget {
  const ShelfCard({
    super.key,
    required this.shelf,
    required this.onTap,
    this.onDelete,
  });

  final LibraryShelf shelf;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    final bars = shelf.spineColors.isNotEmpty
        ? [
            for (final hex in shelf.spineColors)
              ShelfStripBar(
                color: _parseHex(hex),
                width: 1.0,
              ),
          ]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SpineRadius.card),
        border: Border.all(
          color: semantic.hairline,
          width: SpineBorders.hairline,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpineRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(SpineSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shelf.name,
                            style: SpineTypography.headlineSmall.copyWith(
                              color: semantic.brass,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: SpineSpacing.xs),
                          Text(
                            '${shelf.bookCount} CİLT / VOLUMES',
                            style: SpineTypography.metadataCaps.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onSelected: (val) {
                          if (val == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: scheme.error, size: 18),
                                const SizedBox(width: SpineSpacing.sm),
                                Text(
                                  'Rafı Sil',
                                  style: SpineTypography.bodySmall.copyWith(color: scheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: SpineSpacing.md),
                // Mini Shelf Strip
                ClipRRect(
                  borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
                  child: bars != null && bars.isNotEmpty
                      ? ShelfStrip(
                          bars: bars,
                          variant: ShelfStripVariant.compact,
                        )
                      : const ShelfStrip(
                          bars: [],
                          variant: ShelfStripVariant.empty,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFC9963F);
    }
  }
}
