import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// Which theme the app is showing.
///
/// Held in memory for now. Persisting the choice belongs to the settings
/// screen in Faz 9, which is also where the store of record for user
/// preferences is introduced; wiring a second one here would mean two.
@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;

  /// Cycles system -> dark -> light -> system.
  ///
  /// Dark comes first because it is the primary experience: a user reaching
  /// for the toggle from `system` on a light phone is asking to see the dark
  /// theme the product was designed in.
  void cycle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
    };
  }
}
