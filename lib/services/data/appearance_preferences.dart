import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted UI preferences (theme mode, density). Held in a
/// [ChangeNotifier] so the root MaterialApp rebuilds when the
/// clinician toggles dark mode from Settings.
class AppearancePreferences extends ChangeNotifier {
  AppearancePreferences._({Future<SharedPreferences> Function()? prefs})
      : _prefsFactory = prefs;

  static AppearancePreferences instance = AppearancePreferences._();

  @visibleForTesting
  static void setTestInstance(
      Future<SharedPreferences> Function() prefs) {
    instance = AppearancePreferences._(prefs: prefs);
  }

  @visibleForTesting
  static void resetTestInstance() {
    instance = AppearancePreferences._();
  }

  final Future<SharedPreferences> Function()? _prefsFactory;

  static const _themeModeKey = 'appearance.theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  bool _loaded = false;

  Future<SharedPreferences> _prefs() =>
      _prefsFactory?.call() ?? SharedPreferences.getInstance();

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await _prefs();
    _themeMode = _parse(prefs.getString(_themeModeKey));
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await _prefs();
    await prefs.setString(_themeModeKey, _serialize(mode));
  }

  static ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
