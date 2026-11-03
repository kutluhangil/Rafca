import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/tables.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    _titleController.text = book.title;
    _authorController.text = book.author;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text(l10n?.editDetails ?? 'Kitap Detaylarını Düzenle', style: SpineTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n?.titleLabel ?? 'Kitap Başlığı'),
            ),
            const SizedBox(height: SpineSpacing.md),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: l10n?.authorLabel ?? 'Yazar'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.cancel ?? 'İptal'),
          ),
          PrimaryButton(
            label: l10n?.save ?? 'Kaydet',
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
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text(l10n?.deleteConfirmTitle ?? 'Kitabı Kaldır', style: SpineTypography.headlineSmall),
        content: Text(
          l10n?.deleteConfirmMessage ??
              'Bu kitabı arşivinizden kaldırmak istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.cancel ?? 'Vazgeç'),
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
            child: Text(l10n?.remove ?? 'Kaldır'),
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
        final l10n = AppLocalizations.of(context);
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
            title: Text(l10n?.bookDetailTitle ?? 'Kitap Detayı'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n?.edit ?? 'Düzenle',
                onPressed: () => _showEditDialog(context, book),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: scheme.error),
                tooltip: l10n?.remove ?? 'Kaldır',
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
                    _buildProofOfCapture(context, book, scheme, semantic),
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
                        if (book.shelfPosition != null)
                          _MetaChip(
                            icon: Icons.format_list_numbered,
                            label: l10n?.shelfPositionBadge(book.shelfPosition!) ??
                                'RAF #${book.shelfPosition}',
                          ),
                        if (book.isOnLoan)
                          _MetaChip(
                            icon: Icons.person_outline,
                            label:
                                '${uppercaseForLocale(l10n?.filterOnLoan ?? "Ödünçte", Localizations.maybeLocaleOf(context))}: ${uppercaseForLocale(book.activeLoan!.borrowerName, Localizations.maybeLocaleOf(context))}',
                          ),
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
                            l10n?.shelfLabel ?? 'RAF YERLEŞİMİ',
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
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(l10n?.unassignedShelf ?? 'Rafsız / No Shelf'),
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
                            l10n?.readingStatusLabel ?? 'OKUMA DURUMU',
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
                            items: [
                              DropdownMenuItem(
                                value: ReadingStatus.unread,
                                child: Text(l10n?.filterUnread ?? 'Okunacak'),
                              ),
                              DropdownMenuItem(
                                value: ReadingStatus.reading,
                                child: Text(l10n?.filterReading ?? 'Okunuyor'),
                              ),
                              DropdownMenuItem(
                                value: ReadingStatus.read,
                                child: Text(l10n?.filterRead ?? 'Okundu'),
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
                    const SizedBox(height: SpineSpacing.lg),

                    // Faz 11: Lending Tracker Card
                    _buildLoanCard(context, book, scheme, semantic),
                    const SizedBox(height: SpineSpacing.xl),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: l10n?.edit ?? 'Düzenle',
                            variant: SpineButtonVariant.primary,
                            onPressed: () => _showEditDialog(context, book),
                          ),
                        ),
                        const SizedBox(width: SpineSpacing.md),
                        Expanded(
                          child: PrimaryButton(
                            label: l10n?.remove ?? 'Kaldır',
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

  Widget _buildProofOfCapture(BuildContext context, LibraryBook book, ColorScheme scheme, SpineSemanticColors semantic) {
    final l10n = AppLocalizations.of(context);
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
            l10n?.proofOfCapture ?? 'PROOF OF CAPTURE',
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

  void _showLoanDialog(BuildContext context, LibraryBook book) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.spineColors;

    final borrowerNameController = TextEditingController();
    final borrowerContactController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDueDate;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: scheme.surfaceContainerHigh,
          title: Text(
            l10n?.loanBook ?? 'Ödünç Ver',
            style: SpineTypography.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: borrowerNameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '${l10n?.borrowerName ?? "Ödünç Alan Kişi"} *',
                    hintText: l10n?.borrowerNameHint ?? 'Örn: Ahmet Yılmaz',
                  ),
                ),
                const SizedBox(height: SpineSpacing.md),
                TextField(
                  controller: borrowerContactController,
                  decoration: InputDecoration(
                    labelText: l10n?.borrowerContact ?? 'İletişim (Telefon / E-posta)',
                    hintText: l10n?.borrowerContactHint ?? 'İsteğe bağlı',
                  ),
                ),
                const SizedBox(height: SpineSpacing.md),
                Text(
                  l10n?.loanDueDate ?? 'Beklenen İade Tarihi',
                  style: SpineTypography.metadataCaps.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: SpineSpacing.xs),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 14)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDueDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(SpineRadius.chip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpineSpacing.md,
                      vertical: SpineSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(SpineRadius.chip),
                      border: Border.all(
                        color: semantic.hairline,
                        width: SpineBorders.hairline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_outlined, size: 18, color: semantic.brass),
                        const SizedBox(width: SpineSpacing.sm),
                        Text(
                          selectedDueDate != null
                              ? _formatDate(selectedDueDate!)
                              : (l10n?.borrowerContactHint ?? 'İsteğe bağlı'),
                          style: SpineTypography.bodyMedium,
                        ),
                        const Spacer(),
                        if (selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setDialogState(() => selectedDueDate = null),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SpineSpacing.md),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n?.loanNotes ?? 'Notlar',
                    hintText: l10n?.loanNotesHint ?? 'İsteğe bağlı not...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n?.cancel ?? 'İptal'),
            ),
            PrimaryButton(
              label: l10n?.loanBook ?? 'Ödünç Ver',
              expand: false,
              variant: SpineButtonVariant.primary,
              onPressed: () async {
                final name = borrowerNameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.borrowerNameRequired ?? 'Lütfen ödünç alan kişinin adını girin.',
                      ),
                      backgroundColor: scheme.error,
                    ),
                  );
                  return;
                }
                Navigator.of(dialogCtx).pop();
                await ref.read(libraryRepositoryProvider).loanBook(
                      userBookId: book.id,
                      borrowerName: name,
                      borrowerContact: borrowerContactController.text.trim().isNotEmpty
                          ? borrowerContactController.text.trim()
                          : null,
                      dueDate: selectedDueDate,
                      notes: notesController.text.trim().isNotEmpty
                          ? notesController.text.trim()
                          : null,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n?.loanSuccess ?? 'Kitap ödünç verildi olarak kaydedildi.'),
                      backgroundColor: semantic.matched,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(
    BuildContext context,
    LibraryBook book,
    ColorScheme scheme,
    SpineSemanticColors semantic,
  ) {
    final l10n = AppLocalizations.of(context);
    final activeLoan = book.activeLoan;

    return Container(
      padding: const EdgeInsets.all(SpineSpacing.base),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SpineRadius.card),
        border: Border.all(
          color: activeLoan != null ? semantic.brass.withValues(alpha: 0.5) : semantic.hairline,
          width: SpineBorders.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.supervised_user_circle_outlined,
                size: 16,
                color: activeLoan != null ? semantic.brass : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: SpineSpacing.xs),
              Text(
                l10n?.loanSectionTitle ?? 'ÖDÜNÇ TAKİPÇİSİ',
                style: SpineTypography.metadataCaps.copyWith(
                  color: activeLoan != null ? semantic.brass : scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpineSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (activeLoan != null ? semantic.brass : semantic.matched)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(SpineRadius.chip),
                ),
                child: Text(
                  uppercaseForLocale(
                    activeLoan != null
                        ? (l10n?.loanStatusActive ?? 'Ödünç Verildi')
                        : (l10n?.loanStatusAvailable ?? 'Kütüphanede Mevcut'),
                    Localizations.maybeLocaleOf(context),
                  ),
                  style: SpineTypography.labelMono.copyWith(
                    color: activeLoan != null ? semantic.brass : semantic.matched,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpineSpacing.md),
          if (activeLoan != null) ...[
            Text(
              activeLoan.borrowerName,
              style: SpineTypography.headlineSmall.copyWith(
                color: scheme.onSurface,
              ),
            ),
            if (activeLoan.borrowerContact != null && activeLoan.borrowerContact!.isNotEmpty) ...[
              const SizedBox(height: SpineSpacing.xs),
              Row(
                children: [
                  Icon(Icons.contact_mail_outlined, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: SpineSpacing.xs),
                  Text(
                    activeLoan.borrowerContact!,
                    style: SpineTypography.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: SpineSpacing.sm),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: SpineSpacing.xs),
                Text(
                  '${l10n?.loanDate ?? "Veriliş Tarihi"}: ${_formatDate(activeLoan.loanedAt)}',
                  style: SpineTypography.labelMono.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (activeLoan.dueDate != null) ...[
              const SizedBox(height: SpineSpacing.xs),
              Row(
                children: [
                  Icon(Icons.alarm_outlined, size: 14, color: semantic.brass),
                  const SizedBox(width: SpineSpacing.xs),
                  Text(
                    '${l10n?.loanDueDate ?? "Beklenen İade"}: ${_formatDate(activeLoan.dueDate!)}',
                    style: SpineTypography.labelMono.copyWith(
                      color: semantic.brass,
                    ),
                  ),
                ],
              ),
            ],
            if (activeLoan.notes != null && activeLoan.notes!.isNotEmpty) ...[
              const SizedBox(height: SpineSpacing.xs),
              Text(
                '“${activeLoan.notes}”',
                style: SpineTypography.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: SpineSpacing.md),
            PrimaryButton(
              label: l10n?.returnBook ?? 'İade Al',
              variant: SpineButtonVariant.secondary,
              icon: Icons.assignment_return_outlined,
              expand: true,
              onPressed: () async {
                await ref.read(libraryRepositoryProvider).returnBook(activeLoan.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n?.returnSuccess ?? 'Kitap kütüphaneye iade alındı.'),
                      backgroundColor: semantic.matched,
                    ),
                  );
                }
              },
            ),
          ] else ...[
            PrimaryButton(
              label: l10n?.loanBook ?? 'Ödünç Ver',
              variant: SpineButtonVariant.secondary,
              icon: Icons.person_add_outlined,
              expand: true,
              onPressed: () => _showLoanDialog(context, book),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
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
