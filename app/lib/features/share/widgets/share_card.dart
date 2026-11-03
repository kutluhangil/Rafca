import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../models/share_models.dart';

/// Shareable collection card matching Nocturnal Archivist Image 13.
/// Designed to be rendered to PNG via [RepaintBoundary].
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.data,
  });

  final ShareCollectionData data;

  Color _parseHex(String hex) {
    var c = hex.replaceAll('#', '');
    if (c.length == 6) {
      c = 'FF$c';
    }
    final val = int.tryParse(c, radix: 16);
    return val != null ? Color(val) : SpineColors.darkSecondaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countText = l10n?.bookCount(data.bookCount) ?? '${data.bookCount} Books';
    final colors = data.spineColors.isNotEmpty
        ? data.spineColors
        : ['#2C251D', '#8B2323', '#1E262B', '#C9963F', '#3B4238', '#1A1816'];

    final date = data.captureDate ?? DateTime.now();
    final monthStr = DateFormat('MMM', l10n?.localeName ?? 'tr').format(date).toUpperCase();
    final yearStr = DateFormat('yy').format(date);
    final capturedStr = l10n?.capturedDate(monthStr, yearStr) ?? 'CAPTURED $monthStr $yearStr';

    final rawCategories = data.categories.isNotEmpty
        ? data.categories.join(' / ')
        : 'LITERATURE / ARCHIVE / DISCOVERY';
    final categoriesStr = uppercaseForLocale(rawCategories, Localizations.maybeLocaleOf(context));

    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: SpineColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SpineColors.darkOutlineVariant, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpineSpacing.xl,
              vertical: SpineSpacing.lg,
            ),
            child: Column(
              children: [
                Text(
                  countText,
                  style: SpineTypography.displayLarge.copyWith(
                    color: SpineColors.darkPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpineSpacing.xs),
                Text(
                  uppercaseForLocale(data.subtitle, Localizations.maybeLocaleOf(context)),
                  style: SpineTypography.metadataCaps.copyWith(
                    color: SpineColors.darkOnSurfaceVariant,
                    fontSize: 11,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // The Shelf Strip (Signature visual)
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: SpineColors.darkSurfaceContainerLowest,
              border: Border.symmetric(
                horizontal: BorderSide(color: SpineColors.darkOutlineVariant, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < colors.length; i++)
                  Expanded(
                    flex: (i % 3 == 0) ? 3 : ((i % 2 == 0) ? 2 : 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _parseHex(colors[i]),
                        border: const Border(
                          right: BorderSide(color: Color(0x33000000), width: 1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom section
          Padding(
            padding: const EdgeInsets.all(SpineSpacing.xl),
            child: Column(
              children: [
                Text(
                  categoriesStr,
                  style: SpineTypography.labelMono.copyWith(
                    color: SpineColors.darkOnSurface.withValues(alpha: 0.85),
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpineSpacing.xs),
                Text(
                  capturedStr,
                  style: SpineTypography.labelMono.copyWith(
                    color: SpineColors.darkOnSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpineSpacing.lg),
                // Watermark divider
                Container(
                  width: 120,
                  height: 1,
                  color: SpineColors.darkOutlineVariant,
                ),
                const SizedBox(height: SpineSpacing.md),
                Text(
                  'RAFÇA',
                  style: SpineTypography.headlineMedium.copyWith(
                    color: SpineColors.darkPrimary.withValues(alpha: 0.4),
                    fontSize: 18,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
