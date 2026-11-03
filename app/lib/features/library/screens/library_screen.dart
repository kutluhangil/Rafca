import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/tables.dart';
import '../../../core/router/app_router.dart';
import '../../../design/components/book_card.dart';
import '../../../design/components/confidence_badge.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/components/shelf_strip.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../share/models/share_models.dart';
import '../../share/widgets/share_bottom_sheet.dart';
import '../data/library_repository.dart';
import '../models/library_models.dart';
import '../widgets/pending_reviews_banner.dart';

/// The core library view of Rafça.
///
/// Implements SPINE_BLUEPRINT.md §8 (FAZ 8), Image 3 (empty state), and Image 4 (populated).
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({
    super.key,
    this.initialShelfId,
    this.initialShelfName,
  });

  final String? initialShelfId;
  final String? initialShelfName;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  ReadingStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    final booksAsync = ref.watch(
      libraryBooksProvider(
        (
          shelfId: widget.initialShelfId,
          statusFilter: _selectedStatus,
          search: _searchQuery,
        ),
      ),
    );

    final pendingCountAsync = ref.watch(pendingReviewCountProvider);
    final pendingCount = pendingCountAsync.valueOrNull ?? 0;

    return booksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => Center(child: Text('Hata: $e')),
      data: (books) {
        if (books.isEmpty && _searchQuery.isEmpty && _selectedStatus == null && widget.initialShelfId == null) {
          return _buildEmptyState(context);
        }

        return _buildPopulatedState(
          context: context,
          books: books,
          pendingCount: pendingCount,
          semantic: semantic,
          scheme: scheme,
        );
      },
    );
  }

  /// Empty state per Image 3 & SPINE_BLUEPRINT.md 4.4.
  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpineSpacing.pageMargin,
              vertical: SpineSpacing.xl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Greeting
                Text(
                  l10n?.goodEvening ?? 'İyi akşamlar.',
                  style: SpineTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpineSpacing.xs),
                Text(
                  l10n?.emptyLibraryDesc ??
                      'Arşiv raflarınız kürasyonunuzu bekliyor.',
                  style: SpineTypography.bodyLarge.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpineSpacing.xxl),

                // Faint outline ShelfStrip representing empty books
                Opacity(
                  opacity: 0.35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(SpineRadius.card),
                    child: const ShelfStrip(
                      bars: [],
                      variant: ShelfStripVariant.empty,
                    ),
                  ),
                ),
                const SizedBox(height: SpineSpacing.xxl),

                // CTA
                Text(
                  l10n?.libraryQuiet ?? 'Kütüphane sessiz.',
                  style: SpineTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpineSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Text(
                    l10n?.emptyLibraryDesc ??
                        'Raflarınızdaki fiziksel kitapları fotoğraflayarak arşivleme yolculuğunuza başlayın.',
                    style: SpineTypography.bodyMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: SpineSpacing.xl),

                // Scan Button
                PrimaryButton(
                  label: l10n?.scanFirstShelf ?? 'İlk Rafınızı Tarayın',
                  variant: SpineButtonVariant.primary,
                  expand: false,
                  onPressed: () => context.push(Routes.capture),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Populated library state per Image 4 & SPINE_BLUEPRINT.md 4.4 / §8.
  Widget _buildPopulatedState({
    required BuildContext context,
    required List<LibraryBook> books,
    required int pendingCount,
    required SpineSemanticColors semantic,
    required ColorScheme scheme,
  }) {
    final l10n = AppLocalizations.of(context);

    // Build full-bleed ShelfStrip bars from books
    final shelfBars = [
      for (final book in books)
        ShelfStripBar(
          color: _parseHex(book.spineColor),
          width: 1.0,
          semanticLabel: book.title,
        ),
    ];

    return CustomScrollView(
      slivers: [
        // 1. Full-Bleed Hero ShelfStrip
        if (shelfBars.isNotEmpty)
          SliverToBoxAdapter(
            child: ShelfStrip(
              bars: shelfBars,
              variant: ShelfStripVariant.hero,
              onBarTap: (index) {
                if (index < books.length) {
                  _openBookDetail(context, books[index].id);
                }
              },
            ),
          ),

        // 2. Pending Reviews Banner (BLUEPRINT §8 invariant)
        if (pendingCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: SpineSpacing.md),
              child: PendingReviewsBanner(
                count: pendingCount,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.pendingReviewBanner(pendingCount) ??
                            '$pendingCount bekleyen sırt bulunuyor.',
                      ),
                      backgroundColor: semantic.review,
                    ),
                  );
                },
              ),
            ),
          ),

        // 3. Header, Search & Filter Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(SpineSpacing.pageMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.initialShelfName ?? (l10n?.libraryTab ?? 'Kütüphane'),
                        style: SpineTypography.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      tooltip: l10n?.shareCollectionTitle ?? 'Paylaş',
                      color: semantic.brass,
                      onPressed: () {
                        ShareBottomSheet.show(
                          context,
                          data: ShareCollectionData(
                            title: widget.initialShelfName ?? 'Rafça',
                            subtitle: widget.initialShelfName ??
                                (l10n?.autumnCollection ?? 'Koleksiyon'),
                            bookCount: books.length,
                            spineColors: books
                                .map((b) => b.spineColor ?? '#C9963F')
                                .toList(),
                          ),
                        );
                      },
                    ),
                    Text(
                      l10n?.bookCount(books.length) ?? '${books.length} CİLT',
                      style: SpineTypography.metadataCaps.copyWith(
                        color: semantic.brass,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpineSpacing.base),

                // Search field
                TextField(
                  controller: _searchController,
                  style: SpineTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: l10n?.searchPlaceholder ?? 'Başlık, yazar veya yayınevi ara...',
                    hintStyle: SpineTypography.bodyMedium.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: scheme.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SpineSpacing.base,
                      vertical: SpineSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SpineRadius.chip),
                      borderSide: BorderSide(
                        color: semantic.hairline,
                        width: SpineBorders.hairline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SpineRadius.chip),
                      borderSide: BorderSide(
                        color: semantic.hairline,
                        width: SpineBorders.hairline,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
                const SizedBox(height: SpineSpacing.md),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: l10n?.filterAll ?? 'Tümü',
                        isSelected: _selectedStatus == null,
                        onTap: () => setState(() => _selectedStatus = null),
                      ),
                      const SizedBox(width: SpineSpacing.sm),
                      _FilterChip(
                        label: l10n?.filterUnread ?? 'Okunacak',
                        isSelected: _selectedStatus == ReadingStatus.unread,
                        onTap: () => setState(() => _selectedStatus = ReadingStatus.unread),
                      ),
                      const SizedBox(width: SpineSpacing.sm),
                      _FilterChip(
                        label: l10n?.filterReading ?? 'Okunuyor',
                        isSelected: _selectedStatus == ReadingStatus.reading,
                        onTap: () => setState(() => _selectedStatus = ReadingStatus.reading),
                      ),
                      const SizedBox(width: SpineSpacing.sm),
                      _FilterChip(
                        label: l10n?.filterRead ?? 'Okundu',
                        isSelected: _selectedStatus == ReadingStatus.read,
                        onTap: () => setState(() => _selectedStatus = ReadingStatus.read),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Responsive Books Grid (60fps lazy rendering via SliverPadding + SliverGrid)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: SpineSpacing.pageMargin),
          sliver: books.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(SpineSpacing.xxl),
                    child: Center(
                      child: Text(
                        l10n?.noResults ?? 'Aramanızla eşleşen kitap bulunamadı.',
                        style: SpineTypography.bodyMedium.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 190,
                    crossAxisSpacing: SpineSpacing.base,
                    mainAxisSpacing: SpineSpacing.base,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = books[index];
                      return BookCard(
                        title: book.title,
                        author: book.author,
                        level: switch (book.confidence) {
                          MatchConfidence.matched => ConfidenceLevel.matched,
                          MatchConfidence.review => ConfidenceLevel.review,
                          MatchConfidence.unknown => ConfidenceLevel.unknown,
                        },
                        levelLabel: book.confidence.name.toUpperCase(),
                        crop: _buildCropWidget(book, scheme),
                        footer: book.publishYear != null
                            ? '${book.publishYear} BASKISI'
                            : (book.publisher ?? 'ARŞİV KAYDI'),
                        trailingFooter: Icon(
                          switch (book.status) {
                            ReadingStatus.read => Icons.bookmark,
                            ReadingStatus.reading => Icons.bookmark_added,
                            ReadingStatus.unread => Icons.bookmark_border,
                          },
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () => _openBookDetail(context, book.id),
                        onMore: () => _openBookDetail(context, book.id),
                        moreTooltip: 'Detayları Görüntüle',
                      );
                    },
                    childCount: books.length,
                  ),
                ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 120), // Bottom nav space
        ),
      ],
    );
  }

  Widget? _buildCropWidget(LibraryBook book, ColorScheme scheme) {
    if (book.capturePath != null && File(book.capturePath!).existsSync()) {
      return Image.file(
        File(book.capturePath!),
        fit: BoxFit.cover,
      );
    }

    return Container(
      color: _parseHex(book.spineColor),
      alignment: Alignment.center,
      child: Text(
        book.title.characters.firstOrNull ?? '?',
        style: SpineTypography.headlineMedium.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  void _openBookDetail(BuildContext context, String userBookId) {
    context.push('${Routes.bookDetail}?id=$userBookId');
  }

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFC9963F);
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFC9963F);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpineRadius.chip),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpineSpacing.base,
            vertical: SpineSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? semantic.brass.withValues(alpha: 0.2)
                : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(SpineRadius.chip),
            border: Border.all(
              color: isSelected ? semantic.brass : semantic.hairline,
              width: SpineBorders.hairline,
            ),
          ),
          child: Text(
            label,
            style: SpineTypography.bodySmall.copyWith(
              color: isSelected ? semantic.brass : scheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
