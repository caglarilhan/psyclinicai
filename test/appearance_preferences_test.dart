import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/appearance_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppearancePreferences.setTestInstance(SharedPreferences.getInstance);
  });
  tearDown(AppearancePreferences.resetTestInstance);

  group('AppearancePreferences', () {
    test('defaults to ThemeMode.dark before load (landing parity)',
        () async {
      expect(AppearancePreferences.instance.themeMode, ThemeMode.dark);
    });

    test('load reads persisted value', () async {
      SharedPreferences.setMockInitialValues(
          <String, Object>{'appearance.theme_mode': 'dark'});
      AppearancePreferences.setTestInstance(SharedPreferences.getInstance);
      await AppearancePreferences.instance.load();
      expect(AppearancePreferences.instance.themeMode, ThemeMode.dark);
    });

    test('setThemeMode persists + notifies listeners', () async {
      var notified = 0;
      AppearancePreferences.instance.addListener(() => notified++);
      await AppearancePreferences.instance.setThemeMode(ThemeMode.light);
      expect(notified, 1);
      expect(AppearancePreferences.instance.themeMode, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('appearance.theme_mode'), 'light');
    });

    test('setThemeMode same value is a no-op', () async {
      await AppearancePreferences.instance.setThemeMode(ThemeMode.light);
      var notified = 0;
      AppearancePreferences.instance.addListener(() => notified++);
      await AppearancePreferences.instance.setThemeMode(ThemeMode.light);
      expect(notified, 0);
    });
  });
}
