import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'adaptive_platform.dart';

/// A page shell that follows each platform's navigation conventions.
///
/// SPINE_BLUEPRINT.md 4.6:
/// * Android — large collapsing app bar, Material navigation bar.
/// * iOS — large title that collapses to inline on scroll, Cupertino tab bar.
///
/// Feature code calls this and never branches on the platform itself.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.leading,
    this.bottomBar,
    this.floatingAction,
    this.largeTitle = true,
  });

  /// Shown in the app bar or navigation bar.
  final String title;

  /// Page content. Must be a sliver-friendly widget when [largeTitle] is set,
  /// since both platforms build the collapsing header out of slivers.
  final Widget body;

  final List<Widget> actions;
  final Widget? leading;
  final Widget? bottomBar;
  final Widget? floatingAction;

  /// Whether the title starts large and collapses on scroll.
  final bool largeTitle;

  @override
  Widget build(BuildContext context) {
    return switch (AdaptivePlatform.current) {
      AdaptivePlatform.material => _buildMaterial(context),
      AdaptivePlatform.cupertino => _buildCupertino(context),
    };
  }

  Widget _buildMaterial(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(title),
            leading: leading,
            actions: actions,
            expandedHeight: largeTitle ? null : kToolbarHeight,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpineSpacing.pageMargin,
            ),
            sliver: SliverToBoxAdapter(child: body),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingAction,
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.surface,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text(title, style: SpineTypography.headlineMedium),
                leading: leading,
                trailing: actions.isEmpty
                    ? null
                    : Row(mainAxisSize: MainAxisSize.min, children: actions),
                backgroundColor: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: SpineBorders.hairline,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpineSpacing.pageMargin,
                ),
                sliver: SliverToBoxAdapter(child: body),
              ),
            ],
          ),
          if (bottomBar != null)
            Align(alignment: Alignment.bottomCenter, child: bottomBar!),
        ],
      ),
    );
  }
}
