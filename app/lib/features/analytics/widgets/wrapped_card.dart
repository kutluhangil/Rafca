import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design/components/shelf_strip.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../models/analytics_models.dart';

/// Infographic card presenting the user's library analytics in Nocturnal Archivist aesthetic.
/// Designed for high-res PNG capture via [RepaintBoundary].
class WrappedCard extends StatelessWidget {
  const WrappedCard({
    super.key,
    required this.analytics,
    this.format = WrappedCardFormat.story,
  });

  final CollectionAnalytics analytics;
  final WrappedCardFormat format;

  Color _parseHex(String hex) {
    var c = hex.replaceAll('#', '').trim();
    if (c.length == 6) c = 'FF$c';
    final val = int.tryParse(c, radix: 16);
    return val != null ? Color(val) : const Color(0xFFC9963F);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isStory = format == WrappedCardFormat.story;
    final width = 360.0;
    final height = isStory ? 640.0 : 420.0;

    final date = DateTime.now();
    final monthStr = DateFormat('MMMM yyyy', l10n?.localeName ?? 'tr').format(date).toUpperCase();

    final archetypeName = switch (analytics.archetype) {
      ArchivistArchetype.grandArchivist => l10n?.archetypeGrandArchivist ?? 'Büyük Arşiv Muhafızı',
      ArchivistArchetype.devotedReader => l10n?.archetypeDevotedReader ?? 'Edebi Gezgin',
      ArchivistArchetype.passionateCurator => l10n?.archetypePassionateCurator ?? 'Tutkulu Küratör',
      ArchivistArchetype.nocturnalSeeker => l10n?.archetypeNocturnalSeeker ?? 'Gece Arşivcisi',
    };

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(SpineSpacing.xl),
      decoration: BoxDecoration(
        color: SpineColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpineColors.darkPrimaryContainer.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Brand & Archetype
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_stories, size: 16, color: SpineColors.darkPrimary),
                  const SizedBox(width: SpineSpacing.xs),
                  Text(
                    'RAFÇA',
                    style: SpineTypography.metadataCaps.copyWith(
                      color: SpineColors.darkPrimary,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: SpineSpacing.sm),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpineSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: SpineColors.darkPrimaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(SpineRadius.chip),
                    border: Border.all(
                      color: SpineColors.darkPrimaryContainer,
                      width: SpineBorders.hairline,
                    ),
                  ),
                  child: Text(
                    uppercaseForLocale(archetypeName, Localizations.maybeLocaleOf(context)),
                    style: SpineTypography.labelMono.copyWith(
                      color: SpineColors.darkPrimary,
                      fontSize: 9,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpineSpacing.lg),

          // 2. Hero: Book Count & Physical Meter
          Text(
            uppercaseForLocale(
              l10n?.bookCount(analytics.totalBooks) ?? '${analytics.totalBooks} Cilt',
              Localizations.maybeLocaleOf(context),
            ),
            style: SpineTypography.displayLarge.copyWith(
              color: Colors.white,
              fontSize: isStory ? 38 : 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.05,
            ),
          ),
          const SizedBox(height: SpineSpacing.xs),
          Text(
            l10n?.shelfMetersEstimate(analytics.estimatedShelfMeters) ??
                '${analytics.estimatedShelfMeters} METRE FİZİKSEL RAF',
            style: SpineTypography.metadataCaps.copyWith(
              color: SpineColors.darkPrimary,
              fontSize: 11,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: SpineSpacing.md),

          // 3. Mini ShelfStrip (Signature visual)
          ClipRRect(
            borderRadius: BorderRadius.circular(SpineRadius.chip),
            child: SizedBox(
              height: isStory ? 72 : 48,
              child: ShelfStrip(
                bars: [
                  for (final hex in analytics.representativeSpineColors)
                    ShelfStripBar(
                      color: _parseHex(hex),
                      width: 1.0,
                    ),
                ],
                variant: ShelfStripVariant.compact,
              ),
            ),
          ),
          const SizedBox(height: SpineSpacing.lg),

          // 4. Color Spectrum Harmony Bar
          if (analytics.colorSpectrum.isNotEmpty) ...[
            Text(
              l10n?.colorHarmonyTitle ?? 'RENK SPEKTRUMU & AURA',
              style: SpineTypography.metadataCaps.copyWith(
                color: SpineColors.darkOnSurfaceVariant,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: SpineSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    for (final entry in analytics.colorSpectrum)
                      Expanded(
                        flex: (entry.percentage * 10).round().clamp(1, 1000),
                        child: Container(
                          color: entry.family.representativeColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SpineSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${analytics.dominantColor.defaultLabel} (%${analytics.colorSpectrum.first.percentage.toStringAsFixed(0)})',
                    style: SpineTypography.labelMono.copyWith(
                      color: SpineColors.darkPrimary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: SpineSpacing.sm),
                Text(
                  l10n?.dominantPalette ?? 'Baskın Karakter',
                  style: SpineTypography.labelMono.copyWith(
                    color: SpineColors.darkOnSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpineSpacing.md),
          ],

          // 5. Literary DNA (Authors & Publishers)
          if (analytics.topAuthor != null || analytics.topPublisher != null) ...[
            Container(
              padding: const EdgeInsets.all(SpineSpacing.md),
              decoration: BoxDecoration(
                color: SpineColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(SpineRadius.card),
                border: Border.all(
                  color: SpineColors.darkOutlineVariant.withValues(alpha: 0.5),
                  width: SpineBorders.hairline,
                ),
              ),
              child: Column(
                children: [
                  if (analytics.topAuthor != null)
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: SpineColors.darkPrimary),
                        const SizedBox(width: SpineSpacing.xs),
                        Text(
                          l10n?.topAuthorLabel ?? 'Baş Yazar: ',
                          style: SpineTypography.labelMono.copyWith(
                            color: SpineColors.darkOnSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${analytics.topAuthor} (${analytics.topAuthorCount})',
                            style: SpineTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (analytics.topAuthor != null && analytics.topPublisher != null)
                    const SizedBox(height: SpineSpacing.xs),
                  if (analytics.topPublisher != null)
                    Row(
                      children: [
                        Icon(Icons.business, size: 14, color: SpineColors.darkPrimary),
                        const SizedBox(width: SpineSpacing.xs),
                        Text(
                          l10n?.topPublisherLabel ?? 'Yayınevi: ',
                          style: SpineTypography.labelMono.copyWith(
                            color: SpineColors.darkOnSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${analytics.topPublisher} (${analytics.topPublisherCount})',
                            style: SpineTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: SpineSpacing.md),
          ],

          // 6. Story-only: Extra Archival Metrics
          if (isStory) ...[
            const Spacer(),
            Row(
              children: [
                _StatTile(
                  title: l10n?.readCountLabel ?? 'OKUNDU',
                  value: '%${analytics.readingProgress.readRatio.toStringAsFixed(0)}',
                ),
                const SizedBox(width: SpineSpacing.md),
                _StatTile(
                  title: l10n?.authorsLabel ?? 'YAZAR',
                  value: '${analytics.uniqueAuthorsCount}',
                ),
                const SizedBox(width: SpineSpacing.md),
                _StatTile(
                  title: l10n?.onLoanStatLabel ?? 'ÖDÜNÇTE',
                  value: '${analytics.activeLoansCount}',
                ),
              ],
            ),
            const SizedBox(height: SpineSpacing.lg),
          ] else ...[
            const Spacer(),
          ],

          // 7. Footer: Date & Monogram
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthStr,
                style: SpineTypography.labelMono.copyWith(
                  color: SpineColors.darkOnSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'rafca.app',
                style: SpineTypography.labelMono.copyWith(
                  color: SpineColors.darkPrimary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpineSpacing.sm,
          vertical: SpineSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: SpineColors.darkSurfaceContainerLow,
          borderRadius: BorderRadius.circular(SpineRadius.chip),
          border: Border.all(
            color: SpineColors.darkOutlineVariant.withValues(alpha: 0.3),
            width: SpineBorders.hairline,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: SpineTypography.headlineSmall.copyWith(
                color: SpineColors.darkPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              title,
              style: SpineTypography.labelMono.copyWith(
                color: SpineColors.darkOnSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
