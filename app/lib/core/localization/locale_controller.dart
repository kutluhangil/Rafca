import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported locales for manual selection.
enum RafcaLanguage {
  system,
  turkish,
  english;

  Locale? get locale {
    switch (this) {
      case RafcaLanguage.system:
        return null;
      case RafcaLanguage.turkish:
        return const Locale('tr');
      case RafcaLanguage.english:
        return const Locale('en');
    }
  }
}

/// State notifier managing the application locale.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null); // Defaults to system locale (with TR fallback)

  void setLocale(Locale? locale) {
    state = locale;
  }

  void setLanguage(RafcaLanguage language) {
    state = language.locale;
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController();
});
