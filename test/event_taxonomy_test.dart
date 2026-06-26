import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/analytics/event_taxonomy.dart';

void main() {
  group('AnalyticsEventTaxonomy — catalog invariants', () {
    test('catalog is non-empty', () {
      expect(AnalyticsEventTaxonomy.events, isNotEmpty);
    });

    test('every event name is unique', () {
      final names = AnalyticsEventTaxonomy.events.map((e) => e.name).toList();
      expect(names.toSet().length, names.length, reason: 'duplicate names');
    });

    test('byName resolves every entry', () {
      for (final e in AnalyticsEventTaxonomy.events) {
        expect(AnalyticsEventTaxonomy.byName(e.name), same(e));
      }
      expect(AnalyticsEventTaxonomy.byName('does-not-exist'), isNull);
    });

    test('every event has populated fields', () {
      for (final e in AnalyticsEventTaxonomy.events) {
        expect(e.description, isNotEmpty, reason: e.name);
        expect(e.properties, isNotEmpty, reason: e.name);
      }
    });

    test('every event name is snake_case (no spaces, no upper-case)', () {
      final snake = RegExp(r'^[a-z][a-z0-9_]*$');
      for (final e in AnalyticsEventTaxonomy.events) {
        expect(
          snake.hasMatch(e.name),
          isTrue,
          reason: '${e.name}: event name must be snake_case',
        );
      }
    });

    test('every property name is snake_case', () {
      final snake = RegExp(r'^[a-z][a-z0-9_]*$');
      for (final e in AnalyticsEventTaxonomy.events) {
        for (final p in e.properties) {
          expect(
            snake.hasMatch(p.name),
            isTrue,
            reason: '${e.name}.${p.name}: property name must be snake_case',
          );
        }
      }
    });

    test('every property name is unique within its event', () {
      for (final e in AnalyticsEventTaxonomy.events) {
        final names = e.properties.map((p) => p.name).toList();
        expect(
          names.toSet().length,
          names.length,
          reason: '${e.name}: duplicate property name',
        );
      }
    });

    test('string + isoDate properties carry a positive maxLength', () {
      for (final e in AnalyticsEventTaxonomy.events) {
        for (final p in e.properties) {
          if (p.type == AnalyticsPropertyType.string ||
              p.type == AnalyticsPropertyType.isoDate) {
            expect(
              p.maxLength,
              greaterThan(0),
              reason: '${e.name}.${p.name}: string/isoDate need a maxLength',
            );
          }
        }
      }
    });

    test('non-string properties leave maxLength at 0', () {
      for (final e in AnalyticsEventTaxonomy.events) {
        for (final p in e.properties) {
          if (p.type != AnalyticsPropertyType.string &&
              p.type != AnalyticsPropertyType.isoDate) {
            expect(
              p.maxLength,
              0,
              reason: '${e.name}.${p.name}: non-string maxLength must be 0',
            );
          }
        }
      }
    });

    test('every property has a synthetic example (never PHI)', () {
      for (final e in AnalyticsEventTaxonomy.events) {
        for (final p in e.properties) {
          expect(p.example, isNotEmpty, reason: '${e.name}.${p.name}');
        }
      }
    });

    test('no event property name is on the PHI deny-list', () {
      for (final e in AnalyticsEventTaxonomy.events) {
        for (final p in e.properties) {
          expect(
            isPhiBannedProperty(p.name),
            isFalse,
            reason: '${e.name}.${p.name}: property name is on the PHI ban list',
          );
        }
      }
    });
  });

  group('surface gating', () {
    test('no event fires on a clinical (chart) surface', () {
      // The enum intentionally excludes clinical/PHI surfaces.
      // Tests pin no surface value drifts in past those.
      const allowed = {
        AnalyticsSurface.publicMarketing,
        AnalyticsSurface.authFlow,
        AnalyticsSurface.clinicianMeta,
        AnalyticsSurface.patientPortalMeta,
      };
      for (final e in AnalyticsEventTaxonomy.events) {
        expect(
          allowed,
          contains(e.surface),
          reason:
              '${e.name}: surface ${e.surface.name} is not in the allowed '
              'set — analytics is BANNED on clinical surfaces',
        );
      }
    });

    test('bySurface slices correctly', () {
      for (final s in AnalyticsSurface.values) {
        for (final e in AnalyticsEventTaxonomy.bySurface(s)) {
          expect(e.surface, s);
        }
      }
    });
  });

  group('consent gating', () {
    test('publicMarketing + clinicianMeta default to analyticsOptIn', () {
      // Marketing + meta analytics are non-essential under K9 +
      // ePrivacy Art. 5(3); MUST require opt-in unless they are
      // explicitly contract-related (e.g. waitlist signup is the
      // contract action itself).
      const contractEssential = {'waitlist_signup_completed'};
      for (final e in AnalyticsEventTaxonomy.events) {
        if (e.surface != AnalyticsSurface.publicMarketing &&
            e.surface != AnalyticsSurface.clinicianMeta) {
          continue;
        }
        if (contractEssential.contains(e.name)) continue;
        expect(
          e.consentGate,
          AnalyticsConsentGate.analyticsOptIn,
          reason:
              '${e.name}: non-contract marketing/clinician-meta event MUST '
              'require analytics opt-in (K9 + ePrivacy Art. 5(3))',
        );
      }
    });

    test('auth + portal signup events are essential (contract action)', () {
      const essential = [
        'auth_signup_started',
        'auth_signup_completed',
        'patient_portal_signed_in',
        'waitlist_signup_completed',
      ];
      for (final name in essential) {
        final e = AnalyticsEventTaxonomy.byName(name);
        expect(e, isNotNull, reason: name);
        expect(
          e!.consentGate,
          AnalyticsConsentGate.essentialOnly,
          reason:
              '$name: contract / signup action is essential under K9 + '
              'ePrivacy Art. 5(3)',
        );
      }
    });
  });

  group('isPhiBannedProperty', () {
    test('returns true for the canonical PHI names', () {
      for (final name in phiBannedPropertyNames) {
        expect(isPhiBannedProperty(name), isTrue, reason: name);
      }
    });

    test('case-insensitive match', () {
      expect(isPhiBannedProperty('Patient_Id'), isTrue);
      expect(isPhiBannedProperty('EMAIL'), isTrue);
    });

    test('returns false for benign property names', () {
      expect(isPhiBannedProperty('route'), isFalse);
      expect(isPhiBannedProperty('tier'), isFalse);
      expect(isPhiBannedProperty('region'), isFalse);
    });
  });

  group('propertySpec helper', () {
    test('returns the spec when the property is in the schema', () {
      final e = AnalyticsEventTaxonomy.byName('landing_viewed')!;
      final spec = propertySpec(e, 'route');
      expect(spec, isNotNull);
      expect(spec!.required, isTrue);
      expect(spec.type, AnalyticsPropertyType.string);
    });

    test('returns null when the property is unknown (typo guard)', () {
      final e = AnalyticsEventTaxonomy.byName('landing_viewed')!;
      expect(propertySpec(e, 'rute_typo'), isNull);
    });
  });
}
