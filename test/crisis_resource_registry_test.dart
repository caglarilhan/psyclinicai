import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/crisis_resource.dart';
import 'package:psyclinicai/services/crisis/crisis_resource_registry.dart';

void main() {
  group('CrisisResourceRegistry', () {
    test('all returns every defined resource and IDs are unique', () {
      final all = CrisisResourceRegistry.all;
      expect(all, isNotEmpty);
      final ids = all.map((r) => r.id).toSet();
      expect(ids.length, all.length, reason: 'resource ids must be unique');
    });

    test('forCountry("US") surfaces 988 first', () {
      final list = CrisisResourceRegistry.forCountry('US');
      expect(list.first.id, 'us-988');
      expect(
        list.any((r) => r.id == 'us-741741'),
        isTrue,
        reason: 'Crisis Text Line should be in the US set',
      );
      expect(list.any((r) => r.kind == CrisisResourceKind.emergency), isTrue);
    });

    test('forCountry("TR") includes 112 as emergency', () {
      final list = CrisisResourceRegistry.forCountry('TR');
      expect(list.any((r) => r.id == 'tr-112'), isTrue);
      final t112 = list.firstWhere((r) => r.id == 'tr-112');
      expect(t112.kind, CrisisResourceKind.emergency);
      expect(t112.dialUri, 'tel:112');
    });

    test('forCountry is case-insensitive', () {
      final upper = CrisisResourceRegistry.forCountry('DE');
      final lower = CrisisResourceRegistry.forCountry('de');
      expect(upper.map((r) => r.id), lower.map((r) => r.id));
    });

    test('unknown country falls back to the universal set', () {
      final fallback = CrisisResourceRegistry.forCountry('ZZ');
      expect(fallback, CrisisResourceRegistry.universal);
      // Universal must always include an international directory so the
      // clinician can find a vetted local line for any country.
      expect(
        fallback.any((r) => r.kind == CrisisResourceKind.directory),
        isTrue,
      );
    });

    test('null country also returns universal', () {
      expect(
        CrisisResourceRegistry.forCountry(null),
        CrisisResourceRegistry.universal,
      );
    });

    test('forLocale honors country code when present', () {
      final list = CrisisResourceRegistry.forLocale(const Locale('en', 'GB'));
      expect(list.any((r) => r.id == 'uk-116123'), isTrue);
    });

    test('forLocale falls back to language when no country', () {
      final list = CrisisResourceRegistry.forLocale(const Locale('tr'));
      expect(list.any((r) => r.id == 'tr-112'), isTrue);
    });

    test('forLocale with null locale returns universal', () {
      expect(
        CrisisResourceRegistry.forLocale(null),
        CrisisResourceRegistry.universal,
      );
    });

    test('every dialable resource uses a tel: URI', () {
      for (final r in CrisisResourceRegistry.all) {
        if (r.dialUri != null) {
          expect(
            r.dialUri,
            startsWith('tel:'),
            reason: '${r.id} should dial via tel: scheme',
          );
        }
      }
    });

    test('every directory resource has a web URI', () {
      for (final r in CrisisResourceRegistry.all) {
        if (r.kind == CrisisResourceKind.directory) {
          expect(
            r.webUri,
            isNotNull,
            reason: '${r.id} is a directory and needs a webUri',
          );
        }
      }
    });

    test('lastReviewed is a YYYY-MM stamp', () {
      expect(
        CrisisResourceRegistry.lastReviewed,
        matches(RegExp(r'^\d{4}-\d{2}$')),
      );
    });

    // KRİTİK-7 safety invariant: a patient in crisis must NEVER see an empty
    // hotline list. We assert exhaustively across the configured locales +
    // a sentinel unknown locale.
    group('invariant: never returns an empty list', () {
      const supportedCountries = <String?>[
        'US',
        'GB',
        'DE',
        'FR',
        'NL',
        'IT',
        'ES',
        'TR',
        'ZZ',
        null,
      ];

      for (final cc in supportedCountries) {
        test('forCountry(${cc ?? "null"}) is non-empty', () {
          final list = CrisisResourceRegistry.forCountry(cc);
          expect(list, isNotEmpty);
        });
      }

      const supportedLocales = <Locale?>[
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('de'),
        Locale('fr'),
        Locale('nl'),
        Locale('it'),
        Locale('es'),
        Locale('tr'),
        Locale('xx'),
        null,
      ];

      for (final loc in supportedLocales) {
        test('forLocale($loc) is non-empty', () {
          final list = CrisisResourceRegistry.forLocale(loc);
          expect(list, isNotEmpty);
        });
      }

      test(
        'universal set is non-empty and includes international directory',
        () {
          expect(CrisisResourceRegistry.universal, isNotEmpty);
          expect(
            CrisisResourceRegistry.universal.any(
              (r) => r.kind == CrisisResourceKind.directory,
            ),
            isTrue,
          );
        },
      );
    });
  });
}
