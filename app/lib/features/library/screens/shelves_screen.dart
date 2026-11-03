import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
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

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text('Yeni Raf Oluştur', style: SpineTypography.headlineSmall),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Raf Adı (örn. Tarih, Felsefe, Okunacaklar)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('İptal'),
          ),
          PrimaryButton(
            label: 'Oluştur',
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
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text('Rafı Sil', style: SpineTypography.headlineSmall),
        content: Text(
          '"$shelfName" rafını silmek istediğinize emin misiniz? Raftaki kitaplar arşivinizde kalır, sadece raf bağlantısı kaldırılır.',
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
              await ref.read(libraryRepositoryProvider).deleteShelf(shelfId);
            },
            child: const Text('Sil / Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;
    final shelvesAsync = ref.watch(libraryShelvesProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Raflarınız / Shelves'),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateShelfDialog(context),
        backgroundColor: semantic.brass,
        foregroundColor: semantic.onBrass,
        icon: const Icon(Icons.add),
        label: Text(
          'YENİ RAF',
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
                      'Henüz raf oluşturulmadı.',
                      style: SpineTypography.headlineSmall,
                    ),
                    const SizedBox(height: SpineSpacing.sm),
                    Text(
                      'Kitaplarınızı temalarına, odalarınıza veya türlerine göre düzenlemek için bir raf oluşturun.',
                      style: SpineTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpineSpacing.xl),
                    PrimaryButton(
                      label: 'İlk Rafı Oluştur',
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
