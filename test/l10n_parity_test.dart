import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// B17 — i18n parity guard. Every key in the English template MUST
/// have a translation in every fully-shipped locale (today: `tr`).
/// Partial locales (`de`, `fr`) only need to **not introduce stray
/// keys** — their coverage gap is reported so reviewers know how far
/// behind they are.
///
/// Reads the .arb files directly from disk so the assertion runs in
/// pure Dart (no Flutter widget tree). Metadata keys (`@key`) are
/// excluded.
void main() {
  /// Locales the product ships in full — these MUST hit 100% parity
  /// against the English template before a build is considered
  /// release-quality. CI fails if any key is missing or blank.
  const fullLocales = <String>{'tr'};

  /// Locales we expose but knowingly translate incrementally. Stray
  /// keys still fail; missing keys produce a coverage report rather
  /// than a hard failure. Add to [fullLocales] once translated.
  const partialLocales = <String>{'de', 'fr'};

  late Map<String, String> en;
  late Map<String, Map<String, String>> others;

  setUpAll(() {
    en = _loadArb('lib/l10n/intl_en.arb');
    others = {
      for (final code in {...fullLocales, ...partialLocales})
        code: _loadArb('lib/l10n/intl_$code.arb'),
    };
  });

  group('i18n parity — full locales', () {
    test('every English key has a non-empty translation', () {
      for (final code in fullLocales) {
        final translations = others[code]!;
        final missing = <String>[];
        final blank = <String>[];
        for (final key in en.keys) {
          if (!translations.containsKey(key)) {
            missing.add(key);
          } else if (translations[key]!.trim().isEmpty) {
            blank.add(key);
          }
        }
        expect(missing, isEmpty, reason: '$code is missing keys: $missing');
        expect(blank, isEmpty, reason: '$code has blank translations: $blank');
      }
    });
  });

  group('i18n parity — every locale (full + partial)', () {
    test('no stray keys outside the English template', () {
      for (final entry in others.entries) {
        final stray = entry.value.keys.where((k) => !en.containsKey(k));
        expect(
          stray,
          isEmpty,
          reason: '${entry.key} has keys not in English template: $stray',
        );
      }
    });

    test('locale tag on every arb file matches its filename', () {
      for (final code in {'en', ...fullLocales, ...partialLocales}) {
        final raw =
            jsonDecode(File('lib/l10n/intl_$code.arb').readAsStringSync())
                as Map<String, dynamic>;
        expect(
          raw['@@locale'],
          code,
          reason: 'intl_$code.arb declares the wrong @@locale tag',
        );
      }
    });
  });

  group('i18n coverage report — partial locales', () {
    test('coverage % is reported so reviewers see the gap', () {
      final report = StringBuffer('\n');
      for (final code in partialLocales) {
        final translations = others[code]!;
        final translated = en.keys
            .where((k) => (translations[k] ?? '').trim().isNotEmpty)
            .length;
        final total = en.keys.length;
        final pct = (translated * 100 / total).toStringAsFixed(1);
        report.writeln('  $code: $translated/$total ($pct%)');
      }
      // Print-only — pure record so a reviewer sees the gap in the
      // CI log without failing the build.
      // ignore: avoid_print
      print('i18n partial-locale coverage:$report');
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
