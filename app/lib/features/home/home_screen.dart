import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../library/screens/library_screen.dart';
import '../library/screens/shelves_screen.dart';

/// The root home screen hosting the Library and Shelves views.
///
/// Implements SPINE_BLUEPRINT.md §8 (FAZ 8) and Nocturnal Archivist navigation.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.spineColors;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          'Rafça',
          style: SpineTypography.headlineMedium.copyWith(
            color: semantic.brass,
          ),
        ),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(themeModeControllerProvider.notifier).cycle(),
            icon: Icon(switch (mode) {
              ThemeMode.system => Icons.brightness_auto_outlined,
              ThemeMode.dark => Icons.dark_mode_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
            }),
            tooltip: 'Theme: ${mode.name}',
          ),
          IconButton(
            onPressed: () => context.push(Routes.gallery),
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Design Gallery',
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          LibraryScreen(),
          ShelvesScreen(),
        ],
      ),
      bottomNavigationBar: Container(
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
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.library_books,
                  label: 'Kütüphane',
                  isActive: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                // Center Scan Action
                GestureDetector(
                  onTap: () => context.push(Routes.capture),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: semantic.brass,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: semantic.brass.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.photo_camera,
                      color: semantic.onBrass,
                      size: 26,
                    ),
                  ),
                ),
                _NavBarItem(
                  icon: Icons.shelves,
                  label: 'Raflar',
                  isActive: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    final color = isActive ? semantic.brass : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: SpineTypography.metadataCaps.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
