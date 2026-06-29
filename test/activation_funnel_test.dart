/// O1 — pins the activation funnel catalogue + cohort math.
///
/// Three downstream consumers share this contract:
///   * the dashboard widget rendering the cohort table,
///   * the activation-cohort review meeting export,
///   * the email-sequence trigger that drips on drop-off.
///
/// A rename of an event id or a math drift breaks all three.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/analytics/activation_funnel.dart';

void main() {
  group('ActivationFunnel.stages — coverage', () {
    test('lists the 7 pinned stages in north-star order', () {
      final ordered = ActivationFunnel.stages.map((d) => d.stage).toList();
      expect(ordered, [
        ActivationStage.signup,
        ActivationStage.firstLogin,
        ActivationStage.firstIntake,
        ActivationStage.firstSoap,
        ActivationStage.firstSafetyPlan,
        ActivationStage.d7Retention,
        ActivationStage.d30Retention,
      ]);
    });

    test('every stage has a non-empty label + requiredEventId', () {
      for (final d in ActivationFunnel.stages) {
        expect(d.label, isNotEmpty);
        expect(d.requiredEventId, isNotEmpty);
      }
    });

    test('north-star stage points at the existing first-SOAP event', () {
      final ns = ActivationFunnel.byStage(ActivationStage.firstSoap);
      expect(ns.requiredEventId, 'session.first_soap_generated');
      expect(ns.label, contains('north-star'));
      expect(ns.dropoffWarningPercent, 50);
    });

    test('signup stage carries dropoffWarningPercent: 0', () {
      expect(
        ActivationFunnel.byStage(ActivationStage.signup).dropoffWarningPercent,
        0,
      );
    });
  });

  group('evaluateActivationCohort — math', () {
    final cohort = ActivationCohort(
      startDate: DateTime.utc(2026, 6, 1),
      signupCount: 100,
    );

    test('empty cohort → 0 reached + 0 conversion + 0 dropoff', () {
      final r = evaluateActivationCohort(
        cohort: ActivationCohort(
          startDate: DateTime.utc(2026, 6, 1),
          signupCount: 0,
        ),
        reachedByStage: const {},
      );
      for (final s in r) {
        expect(s.reachedCount, 0);
        expect(s.conversionPercentFromSignup, 0);
        expect(s.dropoffPercentFromPrevious, 0);
      }
    });

    test('100% conversion through the funnel → 0 dropoff at every stage', () {
      final r = evaluateActivationCohort(
        cohort: cohort,
        reachedByStage: const {
          ActivationStage.signup: 100,
          ActivationStage.firstLogin: 100,
          ActivationStage.firstIntake: 100,
          ActivationStage.firstSoap: 100,
          ActivationStage.firstSafetyPlan: 100,
          ActivationStage.d7Retention: 100,
          ActivationStage.d30Retention: 100,
        },
      );
      for (final s in r) {
        expect(s.conversionPercentFromSignup, 100);
        expect(s.dropoffPercentFromPrevious, 0);
      }
    });

    test('typical funnel — math is byte-exact', () {
      final r = evaluateActivationCohort(
        cohort: cohort,
        reachedByStage: const {
          ActivationStage.signup: 100,
          ActivationStage.firstLogin: 80,
          ActivationStage.firstIntake: 60,
          ActivationStage.firstSoap: 30,
          ActivationStage.firstSafetyPlan: 12,
          ActivationStage.d7Retention: 25,
          ActivationStage.d30Retention: 15,
        },
      );

      // signup → firstLogin: 100 → 80 = 20% dropoff, 80% conversion
      expect(r[1].conversionPercentFromSignup, 80);
      expect(r[1].dropoffPercentFromPrevious, 20);

      // firstLogin → firstIntake: 80 → 60 = 25% dropoff, 60% conversion
      expect(r[2].conversionPercentFromSignup, 60);
      expect(r[2].dropoffPercentFromPrevious, 25);

      // firstIntake → firstSoap: 60 → 30 = 50% dropoff (the north-star
      // warning), 30% conversion
      expect(r[3].conversionPercentFromSignup, 30);
      expect(r[3].dropoffPercentFromPrevious, 50);
    });

    test('signup stage always has 0 dropoff', () {
      final r = evaluateActivationCohort(
        cohort: cohort,
        reachedByStage: const {ActivationStage.signup: 100},
      );
      expect(r.first.dropoffPercentFromPrevious, 0);
    });

    test('reached > previous (event count anomaly) clamps dropoff to 0', () {
      // Should not happen in practice but a noisy event source can
      // double-count d7 vs firstSafetyPlan; clamp to 0 to keep the
      // dashboard non-negative.
      final r = evaluateActivationCohort(
        cohort: cohort,
        reachedByStage: const {
          ActivationStage.signup: 100,
          ActivationStage.firstLogin: 80,
          ActivationStage.firstIntake: 60,
          ActivationStage.firstSoap: 30,
          ActivationStage.firstSafetyPlan: 12,
          ActivationStage.d7Retention: 25, // > firstSafetyPlan (12)
          ActivationStage.d30Retention: 15,
        },
      );
      // firstSafetyPlan = 12 → d7Retention = 25 ⇒ would be
      // (12-25)/12 = -108% → clamped to 0.
      expect(r[5].dropoffPercentFromPrevious, 0);
    });
  });

  group('firstWarning', () {
    final cohort = ActivationCohort(
      startDate: DateTime.utc(2026, 6, 1),
      signupCount: 100,
    );

    test('returns null when every stage is under its threshold', () {
      final r = evaluateActivationCohort(
        cohort: cohort,
        reachedByStage: const {
          ActivationStage.signup: 100,
          ActivationStage.firstLogin: 90,
          ActivationStage.firstIntake: 80,
          ActivationStage.firstSoap: 70,
          ActivationStage.firstSafetyPlan: 12,
          ActivationStage.d7Retention: 65,
          ActivationStage.d30Retention: 50,
        },
      );
      expect(ActivationFunnel.firstWarning(r), isNull);
    });

    test('returns the first stage at/above its dropoff threshold', () {
      final r = evaluateActivationCohort(
        cohort: cohort,
        reachedByStage: const {
          ActivationStage.signup: 100,
          ActivationStage.firstLogin: 60, // 40% dropoff vs 30% threshold
          ActivationStage.firstIntake: 30,
          ActivationStage.firstSoap: 10,
          ActivationStage.firstSafetyPlan: 5,
          ActivationStage.d7Retention: 3,
          ActivationStage.d30Retention: 1,
        },
      );
      final w = ActivationFunnel.firstWarning(r);
      expect(w, isNotNull);
      expect(w!.stage, ActivationStage.firstLogin);
    });

    test('signup stage with dropoffWarningPercent 0 is skipped', () {
      final r = evaluateActivationCohort(
        cohort: cohort,
        reachedByStage: const {ActivationStage.signup: 100},
      );
      // No other stages reached, but signup has threshold 0; skipped.
      // firstLogin = 0 → 100% dropoff, threshold 30 → trips.
      expect(
        ActivationFunnel.firstWarning(r)?.stage,
        ActivationStage.firstLogin,
      );
    });
  });
}
