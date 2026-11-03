import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/tables.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../data/library_repository.dart';
import '../models/library_models.dart';

/// Book detail screen per SPINE_BLUEPRINT.md and book_detail mockup (Image 1).
class BookDetailScreen extends ConsumerStatefulWidget {
  const BookDetailScreen({
    super.key,
    required this.userBookId,
  });

  final String userBookId;

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _showEditDialog(BuildContext context, LibraryBook book) {
    _titleController.text = book.title;
    _authorController.text = book.author;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text('Kitap Detaylarını Düzenle', style: SpineTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Kitap Başlığı'),
            ),
            const SizedBox(height: SpineSpacing.md),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Yazar'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('İptal'),
          ),
          PrimaryButton(
            label: 'Kaydet',
            expand: false,
            variant: SpineButtonVariant.primary,
            onPressed: () async {
              final newTitle = _titleController.text.trim();
              final newAuthor = _authorController.text.trim();
              if (newTitle.isNotEmpty) {
                await ref.read(libraryRepositoryProvider).updateBookDetails(
                      widget.userBookId,
                      title: newTitle,
                      author: newAuthor.isNotEmpty ? newAuthor : 'Bilinmeyen Yazar',
                    );
              }
              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text('Kitabı Sil', style: SpineTypography.headlineSmall),
        content: const Text(
          'Bu kitabı arşivinizden kaldırmak istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(libraryRepositoryProvider).deleteBook(widget.userBookId);
              if (context.mounted) {
                Navigator.of(context).maybePop();
              }
            },
            child: const Text('Kaldır / Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    final bookStream = ref.watch(libraryRepositoryProvider).watchBook(widget.userBookId);
    final shelvesStream = ref.watch(libraryShelvesProvider);
    final shelves = shelvesStream.valueOrNull ?? const [];

    return StreamBuilder<LibraryBook?>(
      stream: bookStream,
      builder: (context, snapshot) {
        final book = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: SizedBox.shrink());
        }

        if (book == null) {
          return Scaffold(
            backgroundColor: scheme.surface,
            appBar: AppBar(
              title: const Text('Kitap Bulunamadı'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              backgroundColor: scheme.surface,
            ),
            body: const Center(
              child: Text('Kitap kaydı silinmiş veya bulunamadı.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            title: const Text('Kitap Detayı'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Düzenle',
                onPressed: () => _showEditDialog(context, book),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: scheme.error),
                tooltip: 'Kaldır',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;

                final leftColumn = Column(
                  children: [
                    // Book Cover
                    _buildCover(book, scheme, semantic),
                    const SizedBox(height: SpineSpacing.xl),

                    // Proof of Capture
                    _buildProofOfCapture(book, scheme, semantic),
                  ],
                );

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Author
                    Text(
                      book.title,
                      style: SpineTypography.headlineMedium.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: SpineSpacing.xs),
                    Text(
                      book.author,
                      style: SpineTypography.headlineSmall.copyWith(
                        color: semantic.brass,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: SpineSpacing.base),

                    // Metadata chips
                    Wrap(
                      spacing: SpineSpacing.sm,
                      runSpacing: SpineSpacing.sm,
                      children: [
                        if (book.publishYear != null)
                          _MetaChip(
                            icon: Icons.calendar_today_outlined,
                            label: '${book.publishYear}',
                          ),
                        if (book.publisher != null)
                          _MetaChip(
                            icon: Icons.business_outlined,
                            label: book.publisher!,
                          ),
                        _MetaChip(
                          icon: Icons.verified_outlined,
                          label: book.confidence.name.toUpperCase(),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpineSpacing.lg),

                    // Shelf and Reading Status selectors
                    Container(
                      padding: const EdgeInsets.all(SpineSpacing.base),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(SpineRadius.card),
                        border: Border.all(
                          color: semantic.hairline,
                          width: SpineBorders.hairline,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RAF YERLEŞİMİ / SHELF ASSIGNMENT',
                            style: SpineTypography.metadataCaps.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: SpineSpacing.xs),
                          DropdownButtonFormField<String?>(
                            isExpanded: true,
                            initialValue: book.shelfId,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: scheme.surfaceContainerHigh,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(SpineRadius.chip),
                                borderSide: BorderSide(
                                  color: semantic.hairline,
                                  width: SpineBorders.hairline,
                                ),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Rafsız / No Shelf'),
                              ),
                              for (final s in shelves)
                                DropdownMenuItem<String?>(
                                  value: s.id,
                                  child: Text(s.name),
                                ),
                            ],
                            onChanged: (newShelfId) {
                              ref
                                  .read(libraryRepositoryProvider)
                                  .updateBookShelf(widget.userBookId, newShelfId);
                            },
                          ),
                          const SizedBox(height: SpineSpacing.lg),

                          Text(
                            'OKUMA DURUMU / READING STATUS',
                            style: SpineTypography.metadataCaps.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: SpineSpacing.xs),
                          DropdownButtonFormField<ReadingStatus>(
                            isExpanded: true,
                            initialValue: book.status,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: scheme.surfaceContainerHigh,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(SpineRadius.chip),
                                borderSide: BorderSide(
                                  color: semantic.hairline,
                                  width: SpineBorders.hairline,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: ReadingStatus.unread,
                                child: Text('Okunacak / Want to Read'),
                              ),
                              DropdownMenuItem(
                                value: ReadingStatus.reading,
                                child: Text('Okunuyor / Reading'),
                              ),
                              DropdownMenuItem(
                                value: ReadingStatus.read,
                                child: Text('Okundu / Read'),
                              ),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                ref
                                    .read(libraryRepositoryProvider)
                                    .updateReadingStatus(widget.userBookId, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpineSpacing.xl),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Düzenle',
                            variant: SpineButtonVariant.primary,
                            onPressed: () => _showEditDialog(context, book),
                          ),
                        ),
                        const SizedBox(width: SpineSpacing.md),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Kaldır',
                            variant: SpineButtonVariant.secondary,
                            onPressed: () => _confirmDelete(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 280, child: leftColumn),
                      const SizedBox(width: SpineSpacing.xxl),
                      Expanded(child: rightColumn),
                    ],
                  );
                }

                return Column(
                  children: [
                    leftColumn,
                    const SizedBox(height: SpineSpacing.xl),
                    rightColumn,
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(LibraryBook book, ColorScheme scheme, SpineSemanticColors semantic) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SpineRadius.card),
        border: Border.all(
          color: semantic.hairline,
          width: SpineBorders.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: semantic.brass.withValues(alpha: 0.15),
            blurRadius: 32,
            spreadRadius: -8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: book.coverUrl != null
          ? Image.network(
              book.coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildCoverPlaceholder(book, semantic),
            )
          : _buildCoverPlaceholder(book, semantic),
    );
  }

  Widget _buildCoverPlaceholder(LibraryBook book, SpineSemanticColors semantic) {
    return Container(
      color: const Color(0xFF1C1916),
      padding: const EdgeInsets.all(SpineSpacing.base),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, color: semantic.brass, size: 36),
          const SizedBox(height: SpineSpacing.md),
          Text(
            book.title,
            style: SpineTypography.headlineSmall.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpineSpacing.xs),
          Text(
            book.author,
            style: SpineTypography.bodySmall.copyWith(
              color: semantic.brass,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProofOfCapture(LibraryBook book, ColorScheme scheme, SpineSemanticColors semantic) {
    final hasCapture = book.capturePath != null && File(book.capturePath!).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpineSpacing.base),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SpineRadius.card),
        border: Border.all(
          color: semantic.hairline,
          width: SpineBorders.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROOF OF CAPTURE (FİZİKSEL SIRT)',
            style: SpineTypography.metadataCaps.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpineSpacing.sm),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SpineRadius.card),
              border: Border.all(
                color: semantic.hairline,
                width: SpineBorders.hairline,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasCapture
                ? Image.file(
                    File(book.capturePath!),
                    fit: BoxFit.contain,
                  )
                : Center(
                    child: Text(
                      'SIRT FOTOĞRAFI BULUNAMADI',
                      style: SpineTypography.labelMono.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpineSpacing.md,
        vertical: SpineSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(SpineRadius.chip),
        border: Border.all(
          color: semantic.hairline,
          width: SpineBorders.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: semantic.brass),
          const SizedBox(width: SpineSpacing.xs),
          Text(
            label,
            style: SpineTypography.labelMono.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
