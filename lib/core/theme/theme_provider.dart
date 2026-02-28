import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

// Provides the shared preferences instance synchronously.
// It must be overridden in the ProviderScope at the top of the app.
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError();
}

enum AppThemeMode { system, light, dark }

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _themeModeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getString(_themeModeKey);
    if (value != null) {
      return AppThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppThemeMode.system,
      );
    }
    return AppThemeMode.system;
  }

  Future<void> setMode(AppThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeModeKey, mode.name);
    state = mode;
  }

  ThemeMode get flutterThemeMode {
    switch (state) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
