import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../share/models/share_models.dart';
import '../../share/widgets/share_bottom_sheet.dart';
import '../data/library_repository.dart';
import '../widgets/shelf_card.dart';
import 'library_screen.dart';

/// Shelves management screen per SPINE_BLUEPRINT.md and shelves_list mockup (Image 14).
class ShelvesScreen extends ConsumerStatefulWidget {
  const ShelvesScreen({super.key});

  @override
  ConsumerState<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends ConsumerState<ShelvesScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showCreateShelfDialog(BuildContext context) {
    _nameController.clear();
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text(l10n?.createShelf ?? 'Yeni Raf Oluştur', style: SpineTypography.headlineSmall),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n?.shelfNamePlaceholder ?? 'Raf Adı',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.cancel ?? 'İptal'),
          ),
          PrimaryButton(
            label: l10n?.confirm ?? 'Oluştur',
            expand: false,
            variant: SpineButtonVariant.primary,
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                await ref.read(libraryRepositoryProvider).createShelf(name);
              }
              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShelf(BuildContext context, String shelfId, String shelfName) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text(l10n?.deleteShelfTitle ?? 'Rafı Sil', style: SpineTypography.headlineSmall),
        content: Text(
          l10n?.deleteShelfMessage(shelfName) ??
              '"$shelfName" rafını silmek istediğinize emin misiniz? (Raftaki kitaplar silinmez, sahipsiz kalır.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.cancel ?? 'İptal'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(libraryRepositoryProvider).deleteShelf(shelfId);
            },
            child: Text(l10n?.delete ?? 'Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final shelvesAsync = ref.watch(libraryShelvesProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n?.shelvesTitle ?? 'Raflarınız / Shelves'),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateShelfDialog(context),
        backgroundColor: semantic.brass,
        foregroundColor: semantic.onBrass,
        icon: const Icon(Icons.add),
        label: Text(
          l10n?.createShelf ?? 'YENİ RAF',
          style: SpineTypography.metadataCaps.copyWith(
            color: semantic.onBrass,
          ),
        ),
      ),
      body: shelvesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Center(child: Text('Hata: $e')),
        data: (shelves) {
          if (shelves.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(SpineSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shelves,
                      size: 64,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: SpineSpacing.base),
                    Text(
                      l10n?.noShelves ?? 'Henüz raf oluşturulmadı.',
                      style: SpineTypography.headlineSmall,
                    ),
                    const SizedBox(height: SpineSpacing.sm),
                    Text(
                      l10n?.noShelvesDesc ??
                          'Kitaplarınızı temalarına, odalarınıza veya türlerine göre düzenlemek için bir raf oluşturun.',
                      style: SpineTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpineSpacing.xl),
                    PrimaryButton(
                      label: l10n?.createShelf ?? 'İlk Rafı Oluştur',
                      variant: SpineButtonVariant.primary,
                      expand: false,
                      onPressed: () => _showCreateShelfDialog(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpineSpacing.pageMargin,
                  vertical: SpineSpacing.base,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 200,
                    crossAxisSpacing: SpineSpacing.base,
                    mainAxisSpacing: SpineSpacing.base,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final shelf = shelves[index];
                      return ShelfCard(
                        shelf: shelf,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text(shelf.name),
                                  backgroundColor: scheme.surface,
                                ),
                                body: LibraryScreen(
                                  initialShelfId: shelf.id,
                                  initialShelfName: shelf.name,
                                ),
                              ),
                            ),
                          );
                        },
                        onShare: () {
                          ShareBottomSheet.show(
                            context,
                            data: ShareCollectionData(
                              title: shelf.name,
                              subtitle: shelf.name,
                              bookCount: shelf.bookCount,
                              spineColors: shelf.spineColors,
                            ),
                          );
                        },
                        onDelete: () => _confirmDeleteShelf(context, shelf.id, shelf.name),
                      );
                    },
                    childCount: shelves.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }
}
