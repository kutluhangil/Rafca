import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/theme/spine_theme.dart';
import '../router/app_router.dart';
import '../theme/theme_mode_controller.dart';

/// The languages Rafça ships in.
///
/// Turkish is first because it is the fallback: an unsupported device
/// language lands on `tr`, not on English (CLAUDE.md, "Yerelleştirme").
const rafcaSupportedLocales = [Locale('tr'), Locale('en')];

/// Application root.
class RafcaApp extends ConsumerWidget {
  const RafcaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rafça',
      debugShowCheckedModeBanner: false,
      supportedLocales: rafcaSupportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: SpineTheme.light,
      darkTheme: SpineTheme.dark,
      themeMode: ref.watch(themeModeControllerProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
