import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// B17 — i18n parity guard. Every key in the English template MUST
/// have a translation in every shipped locale. The test fails loudly
/// the moment a developer adds a new EN key without translating it,
/// which is the most common i18n bug we see.
///
/// Reads the .arb files directly from disk so the assertion runs
/// in pure Dart (no Flutter widget tree). Metadata keys (anything
/// starting with `@`) are excluded.
void main() {
  late Map<String, String> en;
  late Map<String, Map<String, String>> others;

  setUpAll(() {
    en = _loadArb('lib/l10n/intl_en.arb');
    others = {'tr': _loadArb('lib/l10n/intl_tr.arb')};
  });

  group('i18n parity', () {
    test('every English key has a non-empty translation in every locale', () {
      for (final entry in others.entries) {
        final localeCode = entry.key;
        final translations = entry.value;
        final missing = <String>[];
        final blank = <String>[];
        for (final key in en.keys) {
          if (!translations.containsKey(key)) {
            missing.add(key);
          } else if (translations[key]!.trim().isEmpty) {
            blank.add(key);
          }
        }
        expect(
          missing,
          isEmpty,
          reason: '$localeCode is missing keys: $missing',
        );
        expect(
          blank,
          isEmpty,
          reason: '$localeCode has blank translations: $blank',
        );
      }
    });

    test('translation files do not introduce stray keys not in English', () {
      for (final entry in others.entries) {
        final stray = entry.value.keys.where((k) => !en.containsKey(k));
        expect(
          stray,
          isEmpty,
          reason: '${entry.key} has keys not in English template: $stray',
        );
      }
    });

    test('locale tag on every file matches its filename', () {
      // Spot-check — guard against intl_de.arb that accidentally says
      // "@@locale": "fr" inside.
      final enRaw =
          jsonDecode(File('lib/l10n/intl_en.arb').readAsStringSync())
              as Map<String, dynamic>;
      expect(enRaw['@@locale'], 'en');
      final trRaw =
          jsonDecode(File('lib/l10n/intl_tr.arb').readAsStringSync())
              as Map<String, dynamic>;
      expect(trRaw['@@locale'], 'tr');
    });
  });
}

Map<String, String> _loadArb(String path) {
  final raw = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final out = <String, String>{};
  for (final entry in raw.entries) {
    if (entry.key.startsWith('@')) continue; // metadata
    if (entry.value is String) {
      out[entry.key] = entry.value as String;
    }
  }
  return out;
}
