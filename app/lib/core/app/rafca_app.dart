import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/theme/spine_theme.dart';
import '../../l10n/app_localizations.dart';
import '../localization/locale_controller.dart';
import '../router/app_router.dart';
import '../theme/theme_mode_controller.dart';

/// The languages Rafça ships in.
///
/// Turkish is first because it is the fallback: an unsupported device
/// language lands on `tr`, not on English (CLAUDE.md, "Yerelleştirme").
const rafcaSupportedLocales = AppLocalizations.supportedLocales;

/// Application root.
class RafcaApp extends ConsumerWidget {
  const RafcaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rafça',
      debugShowCheckedModeBanner: false,
      locale: ref.watch(localeControllerProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: SpineTheme.light,
      darkTheme: SpineTheme.dark,
      themeMode: ref.watch(themeModeControllerProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
