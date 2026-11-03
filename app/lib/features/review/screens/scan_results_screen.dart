import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/router/app_router.dart';
import '../../../design/components/confidence_badge.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/components/shelf_strip.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../models/review_models.dart';
import '../state/review_controller.dart';
import '../widgets/review_bottom_sheet.dart';
import 'manual_search_screen.dart';

/// The core transactional screen of Rafça: review, correct, and add scanned books.
///
/// Implements SPINE_BLUEPRINT.md 9 (FAZ 7) and scan_results mockup.
class ScanResultsScreen extends ConsumerStatefulWidget {
  const ScanResultsScreen({
    super.key,
    required this.initialBatch,
  });

  final ReviewBatch initialBatch;

  @override
  ConsumerState<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends ConsumerState<ScanResultsScreen> {
  bool _isSourceExpanded = false;
  bool _isSaving = false;

  void _openReviewSheet(ReviewItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ReviewBottomSheet(
          item: item,
          onSelectAlternative: (selected) {
            ref
                .read(reviewControllerProvider(widget.initialBatch).notifier)
                .selectAlternative(item.id, selected);
          },
          onSearchManually: () {
            _openManualSearch(item);
          },
          onDiscard: () {
            ref
                .read(reviewControllerProvider(widget.initialBatch).notifier)
                .discardItem(item.id);
          },
        );
      },
    );
  }

  void _openManualSearch(ReviewItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ManualSearchScreen(
          initialQuery: item.rawText,
          onBookSelected: (book, manualTitle, manualAuthor) {
            final notifier =
                ref.read(reviewControllerProvider(widget.initialBatch).notifier);
            if (book != null) {
              notifier.selectAlternative(item.id, book);
            } else if (manualTitle != null && manualAuthor != null) {
              notifier.setManualEntry(item.id, manualTitle, manualAuthor);
            }
          },
        ),
      ),
    );
  }

  Future<void> _saveAllMatched(ReviewBatch batch) async {
    setState(() => _isSaving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final count = await ref
          .read(reviewControllerProvider(widget.initialBatch).notifier)
          .saveMatchedToLibrary(db);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count kitap koleksiyonunuza eklendi.'),
          backgroundColor: context.spineColors.matched,
        ),
      );

      // Return to home
      context.go(Routes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt hatası: $e'),
            backgroundColor: context.spineColors.unknown,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final batch = ref.watch(reviewControllerProvider(widget.initialBatch));
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    final matched = batch.matchedItems;
    final needsReview = batch.reviewItems;
    final unrecognized = batch.unknownItems;

    // Build mini ShelfStrip bars from active items
    final shelfBars = [
      for (final item in batch.activeItems)
        ShelfStripBar(
          color: _parseColor(item.spineColor),
          width: 1.0,
          semanticLabel: item.displayTitle,
        ),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Tarama Sonuçları'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpineSpacing.pageMargin,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Collapsible Source Image
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(SpineRadius.card),
                    border: Border.all(
                      color: semantic.hairline,
                      width: SpineBorders.hairline,
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() => _isSourceExpanded = !_isSourceExpanded);
                        },
                        borderRadius: BorderRadius.circular(SpineRadius.card),
                        child: Padding(
                          padding: const EdgeInsets.all(SpineSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 20,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: SpineSpacing.sm),
                              Text(
                                'KAYNAK GÖRSEL - ${batch.items.length} ÖĞE TESPİT EDİLDİ',
                                style: SpineTypography.metadataCaps.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _isSourceExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isSourceExpanded &&
                          File(batch.sourceImagePath).existsSync())
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: semantic.hairline,
                                width: SpineBorders.hairline,
                              ),
                            ),
                          ),
                          child: Image.file(
                            File(batch.sourceImagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: SpineSpacing.md),

                // 2. ShelfStrip Visual Index
                if (shelfBars.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
                    child: ShelfStrip(
                      bars: shelfBars,
                      variant: ShelfStripVariant.compact,
                    ),
                  ),

                const SizedBox(height: SpineSpacing.xl),

                // 3. MATCHED GROUP
                if (matched.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Eşleşen Kitaplar / Matched',
                    count: matched.length,
                    color: semantic.matched,
                  ),
                  const SizedBox(height: SpineSpacing.sm),
                  for (final item in matched)
                    _ResultBookCard(
                      item: item,
                      onTap: () => _openReviewSheet(item),
                    ),
                  const SizedBox(height: SpineSpacing.xl),
                ],

                // 4. NEEDS REVIEW GROUP
                if (needsReview.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'İnceleme Gerekenler / Needs Review',
                    count: needsReview.length,
                    color: semantic.review,
                  ),
                  const SizedBox(height: SpineSpacing.sm),
                  for (final item in needsReview)
                    _ResultBookCard(
                      item: item,
                      onTap: () => _openReviewSheet(item),
                    ),
                  const SizedBox(height: SpineSpacing.xl),
                ],

                // 5. UNRECOGNIZED GROUP
                if (unrecognized.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Tanınamayanlar / Unrecognized',
                    count: unrecognized.length,
                    color: semantic.unknown,
                  ),
                  const SizedBox(height: SpineSpacing.sm),
                  for (final item in unrecognized)
                    _ResultBookCard(
                      item: item,
                      onTap: () => _openReviewSheet(item),
                    ),
                  const SizedBox(height: SpineSpacing.xl),
                ],

                const SizedBox(height: 100), // Space for bottom action bar
              ]),
            ),
          ),
        ],
      ),

      // 6. Sticky Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpineSpacing.pageMargin,
          vertical: SpineSpacing.md,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(
              color: semantic.hairline,
              width: SpineBorders.hairline,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (batch.totalIssuesCount > 0)
                Expanded(
                  child: PrimaryButton(
                    label: '${batch.totalIssuesCount} SORUNU İNCELE',
                    variant: SpineButtonVariant.secondary,
                    onPressed: () {
                      final firstIssue = needsReview.isNotEmpty
                          ? needsReview.first
                          : unrecognized.first;
                      _openReviewSheet(firstIssue);
                    },
                  ),
                ),
              if (batch.totalIssuesCount > 0)
                const SizedBox(width: SpineSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: _isSaving
                      ? 'KAYDEDİLİYOR...'
                      : '${matched.length} KİTABI EKLE',
                  variant: SpineButtonVariant.primary,
                  onPressed: _isSaving || matched.isEmpty
                      ? null
                      : () => _saveAllMatched(batch),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFC9963F);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: SpineTypography.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: SpineSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(SpineRadius.chip),
          ),
          child: Text(
            '$count',
            style: SpineTypography.labelMono.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ResultBookCard extends StatelessWidget {
  const _ResultBookCard({
    required this.item,
    required this.onTap,
  });

  final ReviewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    final confidenceLevel = switch (item.confidence) {
      MatchConfidence.matched => ConfidenceLevel.matched,
      MatchConfidence.review => ConfidenceLevel.review,
      MatchConfidence.unknown => ConfidenceLevel.unknown,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: SpineSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpineRadius.card),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SpineRadius.card),
            border: Border.all(
              color: semantic.hairline,
              width: SpineBorders.hairline,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Cropped spine preview strip
                Container(
                  width: 36,
                  color: Colors.black,
                  child: File(item.cropPath).existsSync()
                      ? Image.file(
                          File(item.cropPath),
                          fit: BoxFit.cover,
                        )
                      : Container(color: _parseHex(item.spineColor)),
                ),

                // 2. Book cover thumbnail (or placeholder)
                Container(
                  width: 52,
                  margin: const EdgeInsets.all(SpineSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
                    border: Border.all(
                      color: semantic.hairline,
                      width: SpineBorders.hairline,
                    ),
                  ),
                  child: item.displayCoverUrl != null
                      ? Image.network(
                          item.displayCoverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.book_outlined, size: 24),
                        )
                      : const Center(
                          child: Icon(Icons.book_outlined, size: 24),
                        ),
                ),

                // 3. Metadata & Confidence
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(SpineSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.displayTitle,
                                style: SpineTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ConfidenceBadge(
                              level: confidenceLevel,
                              label: item.confidence.name,
                            ),
                          ],
                        ),
                        const SizedBox(height: SpineSpacing.xs),
                        Text(
                          item.displayAuthor,
                          style: SpineTypography.bodySmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: SpineSpacing.xs),
                        Text(
                          'CONF: ${(item.confidenceScore).toStringAsFixed(2)}',
                          style: SpineTypography.labelMono.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ],
                    ),
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
