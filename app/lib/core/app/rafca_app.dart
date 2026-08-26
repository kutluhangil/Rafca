import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/theme/spine_theme.dart';
import '../router/app_router.dart';
import '../theme/theme_mode_controller.dart';

/// Application root.
class RafcaApp extends ConsumerWidget {
  const RafcaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rafça',
      debugShowCheckedModeBanner: false,
      theme: SpineTheme.light,
      darkTheme: SpineTheme.dark,
      themeMode: ref.watch(themeModeControllerProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
