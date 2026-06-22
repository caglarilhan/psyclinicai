import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/supported_locales.dart';

void main() {
  group('supportedLocales', () {
    test('always includes English as the first / fallback locale', () {
      expect(supportedLocales.first, english);
      expect(english.languageCode, 'en');
    });

    test('contains the EU + TR clinical-market set', () {
      final codes = supportedLocales.map((s) => s.languageCode).toSet();
      expect(codes, containsAll(['en', 'tr', 'de', 'fr', 'nl', 'it', 'es']));
    });

    test('every entry exposes ISO 639-1 (two lowercase letters)', () {
      for (final s in supportedLocales) {
        expect(s.languageCode, matches(RegExp(r'^[a-z]{2}$')));
        expect(s.englishName, isNotEmpty);
        expect(s.nativeName, isNotEmpty);
      }
    });

    test('locale getter wraps the language code into a Locale', () {
      final tr = supportedLocales.firstWhere((s) => s.languageCode == 'tr');
      expect(tr.locale, const Locale('tr'));
    });
  });

  group('resolveSupportedLocale', () {
    test('returns the matching locale (case-insensitive)', () {
      expect(resolveSupportedLocale('tr').languageCode, 'tr');
      expect(resolveSupportedLocale('TR').languageCode, 'tr');
    });

    test('falls back to English for null / empty / unknown codes', () {
      expect(resolveSupportedLocale(null), english);
      expect(resolveSupportedLocale(''), english);
      expect(resolveSupportedLocale('zz'), english);
    });
  });

  group('bestMatchForDeviceLocale', () {
    test('matches a known language family even when the country differs', () {
      expect(
        bestMatchForDeviceLocale(const Locale('tr', 'CY')).languageCode,
        'tr',
      );
      expect(
        bestMatchForDeviceLocale(const Locale('de', 'AT')).languageCode,
        'de',
      );
    });

    test('falls back to English for an unknown locale', () {
      expect(bestMatchForDeviceLocale(const Locale('xx', 'YY')), english);
      expect(bestMatchForDeviceLocale(null), english);
    });
  });

  group('isLocaleSupported', () {
    test('true for shipped languages', () {
      expect(isLocaleSupported('es'), isTrue);
    });

    test('false for null and unknown codes', () {
      expect(isLocaleSupported(null), isFalse);
      expect(isLocaleSupported('xx'), isFalse);
    });
  });
}
