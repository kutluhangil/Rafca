import 'package:flutter/material.dart';

import '../../../design/components/shelf_strip.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../models/library_models.dart';

/// Shelf card per SPINE_BLUEPRINT.md and shelves_list mockup (Image 14).
class ShelfCard extends StatelessWidget {
  const ShelfCard({
    super.key,
    required this.shelf,
    required this.onTap,
    this.onDelete,
    this.onShare,
  });

  final LibraryShelf shelf;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

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
                            l10n?.bookCount(shelf.bookCount) ??
                                '${shelf.bookCount} CİLT',
                            style: SpineTypography.metadataCaps.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null || onShare != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onSelected: (val) {
                          if (val == 'share') onShare?.call();
                          if (val == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          if (onShare != null)
                            PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share_outlined,
                                      color: semantic.brass, size: 18),
                                  const SizedBox(width: SpineSpacing.sm),
                                  Text(
                                    l10n?.shareShelf ?? 'Rafı Paylaş',
                                    style: SpineTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: scheme.error, size: 18),
                                  const SizedBox(width: SpineSpacing.sm),
                                  Text(
                                    l10n?.deleteShelfTitle ?? 'Rafı Sil',
                                    style: SpineTypography.bodySmall
                                        .copyWith(color: scheme.error),
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
