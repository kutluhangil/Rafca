import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../design/adaptive/adaptive_scaffold.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../models/review_models.dart';

/// Screen for searching catalog or entering custom book details manually.
///
/// Implements manual_search mockup and SPINE_BLUEPRINT.md 9 (FAZ 7).
class ManualSearchScreen extends ConsumerStatefulWidget {
  const ManualSearchScreen({
    super.key,
    this.initialQuery = '',
    required this.onBookSelected,
  });

  final String initialQuery;
  final void Function(ReviewCandidateBook? book, String? manualTitle, String? manualAuthor)
      onBookSelected;

  @override
  ConsumerState<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends ConsumerState<ManualSearchScreen> {
  late TextEditingController _searchController;
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _customAuthorController = TextEditingController();

  List<ReviewCandidateBook> _results = [];
  bool _isSearching = false;
  bool _showCustomEntry = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customTitleController.dispose();
    _customAuthorController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final db = ref.read(appDatabaseProvider);
      // Search local catalog
      final rows = await (db.select(db.catalogBooks)
            ..where((tbl) =>
                tbl.title.like('%$trimmed%') | tbl.authors.like('%$trimmed%'))
            ..limit(15))
          .get();

      final list = rows
          .map((r) => ReviewCandidateBook(
                id: r.id,
                title: r.title,
                author: r.authors.isNotEmpty ? r.authors.first : '',
                publisher: r.publisher,
                publishYear: r.publishYear,
                coverUrl: r.coverUrl,
                score: 1.0,
              ))
          .toList();

      if (mounted) {
        setState(() {
          _results = list;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AdaptiveScaffold(
      title: l10n?.manualSearchTitle ?? 'Kitap Ara',
      largeTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Minimalist Search Field
          Text(
            (l10n?.searchPlaceholder ?? 'KATALOGDA ARA').toUpperCase(),
            style: SpineTypography.metadataCaps.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpineSpacing.xs),
          TextField(
            controller: _searchController,
            style: SpineTypography.bodyLarge.copyWith(color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n?.searchPlaceholder ?? 'Kitap adı veya yazar yazın...',
              hintStyle: SpineTypography.bodyLarge.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(Icons.search, color: semantic.brass),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: semantic.hairline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: semantic.brass, width: 2.0),
              ),
            ),
            onChanged: _performSearch,
          ),
          const SizedBox(height: SpineSpacing.lg),

          // 2. Results List or Custom Entry Form
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _showCustomEntry
                    ? _buildCustomEntryForm(semantic, scheme, l10n)
                    : _buildSearchResults(semantic, scheme),
          ),

          // 3. Toggle Custom Book Form
          if (!_showCustomEntry)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: SpineSpacing.sm),
              child: TextButton.icon(
                icon: const Icon(Icons.edit_note_outlined),
                label: Text(l10n?.customBookTitle ?? 'Özel Kitap Girişi'),
                onPressed: () => setState(() => _showCustomEntry = true),
              ),
            ),
          const SizedBox(height: SpineSpacing.base),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SpineSemanticColors semantic, ColorScheme scheme) {
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpineSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined, size: 48, color: scheme.outline),
              const SizedBox(height: SpineSpacing.md),
              Text(
                'Eşleşen kitap bulunamadı.',
                style: SpineTypography.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpineSpacing.sm),
              Text(
                'Arama sorgusunu değiştirin veya aşağıdaki butondan elle ekleyin.',
                style: SpineTypography.bodySmall.copyWith(
                  color: scheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final book = _results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: SpineSpacing.sm),
          child: InkWell(
            onTap: () {
              widget.onBookSelected(book, null, null);
              context.pop();
            },
            borderRadius: BorderRadius.circular(SpineRadius.card),
            child: Container(
              padding: const EdgeInsets.all(SpineSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(SpineRadius.card),
                border: Border.all(
                  color: semantic.hairline,
                  width: SpineBorders.hairline,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 60,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
                    ),
                    child: const Icon(Icons.book, size: 20, color: Colors.grey),
                  ),
                  const SizedBox(width: SpineSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: SpineTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          book.author,
                          style: SpineTypography.bodySmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_outline, color: semantic.brass),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomEntryForm(SpineSemanticColors semantic, ColorScheme scheme, AppLocalizations? l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (l10n?.customBookTitle ?? 'ELLE KİTAP GİRİŞİ').toUpperCase(),
                style: SpineTypography.metadataCaps.copyWith(
                  color: semantic.brass,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showCustomEntry = false),
              ),
            ],
          ),
          const SizedBox(height: SpineSpacing.md),
          TextField(
            controller: _customTitleController,
            decoration: InputDecoration(
              labelText: l10n?.titleLabel ?? 'Kitap Başlığı *',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SpineSpacing.md),
          TextField(
            controller: _customAuthorController,
            decoration: InputDecoration(
              labelText: l10n?.authorLabel ?? 'Yazar Adı *',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SpineSpacing.xl),
          PrimaryButton(
            label: l10n?.confirm ?? 'Bu Kitabı Eşle',
            variant: SpineButtonVariant.primary,
            onPressed: () {
              final title = _customTitleController.text.trim();
              final author = _customAuthorController.text.trim();
              if (title.isNotEmpty) {
                widget.onBookSelected(null, title, author);
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
