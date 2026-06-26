/// N1 — pins the SLO catalog + error-budget math contract.
///
/// The same definitions feed Sentry rules, the trust-center
/// status page, and the executive dashboard. A drift between any
/// two of those silently breaks SLO accounting. Pin everything.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/slo_catalog.dart';

void main() {
  group('SloCatalog.entries — coverage', () {
    test('lists the six pinned SLOs', () {
      const expectedIds = [
        'audit_log_mirror_success',
        'chain_tamper_zero',
        'dsar_export_30d_sla',
        'ai_service_availability',
        'breach_72h_compliance',
        'safety_plan_save_success',
      ];
      final actualIds = SloCatalog.entries.map((s) => s.id).toSet();
      for (final id in expectedIds) {
        expect(
          actualIds.contains(id),
          isTrue,
          reason:
              'SLO "$id" missing from catalog — Sentry rule + '
              'dashboard route depend on it.',
        );
      }
    });

    test('every SLO has a rationale + non-empty indicator', () {
      for (final s in SloCatalog.entries) {
        expect(s.indicator, isNotEmpty);
        expect(s.rationale, isNotEmpty);
      }
    });

    test('id is unique', () {
      final ids = SloCatalog.entries.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId returns the entry for known id, null for unknown', () {
      expect(SloCatalog.byId('audit_log_mirror_success'), isNotNull);
      expect(SloCatalog.byId('does_not_exist'), isNull);
    });
  });

  group('target percent invariants', () {
    test('targetPercent is in [0, 100]', () {
      for (final s in SloCatalog.entries) {
        expect(s.targetPercent, greaterThanOrEqualTo(0));
        expect(s.targetPercent, lessThanOrEqualTo(100));
      }
    });

    test('chain_tamper_zero + breach_72h_compliance are 100% targets', () {
      expect(SloCatalog.byId('chain_tamper_zero')!.targetPercent, 100);
      expect(SloCatalog.byId('breach_72h_compliance')!.targetPercent, 100);
    });

    test('safety_plan_save_success has the strictest non-100 target', () {
      expect(SloCatalog.byId('safety_plan_save_success')!.targetPercent, 99.9);
    });
  });

  group('errorBudgetMinutes', () {
    test('30d at 99.5% target → 216 min of allowed failure', () {
      final s = SloCatalog.byId('audit_log_mirror_success')!;
      // 30 × 24 × 60 = 43200; 0.005 × 43200 = 216
      expect(s.errorBudgetMinutes, 216);
    });

    test('100% target → 0 minute budget', () {
      final s = SloCatalog.byId('chain_tamper_zero')!;
      expect(s.errorBudgetMinutes, 0);
    });

    test('7d at 99% → 100.8 min → floors to 100', () {
      final s = SloCatalog.byId('ai_service_availability')!;
      // 7 × 24 × 60 = 10080; 0.01 × 10080 = 100.8 → 100
      expect(s.errorBudgetMinutes, 100);
    });
  });

  group('evaluateSlo — math', () {
    final slo = SloCatalog.byId('audit_log_mirror_success')!;

    test('zero observations → healthy + 100% success', () {
      final e = evaluateSlo(
        slo: slo,
        observation: const SloObservation(totalEvents: 0, failureEvents: 0),
      );
      expect(e.status, SloStatus.healthy);
      expect(e.actualSuccessPercent, 100);
      expect(e.burnRatio, 0);
    });

    test('no failures over a busy window → healthy + 100%', () {
      final e = evaluateSlo(
        slo: slo,
        observation: const SloObservation(totalEvents: 10000, failureEvents: 0),
      );
      expect(e.status, SloStatus.healthy);
      expect(e.actualSuccessPercent, 100);
      expect(e.burnRatio, 0);
    });

    test('burnRatio between 0.5 and 1 → warning', () {
      // Allowed failure ratio = 0.005. To land burnRatio ~0.6 →
      // actual ratio 0.003 → 3 failures out of 1000.
      final e = evaluateSlo(
        slo: slo,
        observation: const SloObservation(totalEvents: 1000, failureEvents: 3),
      );
      expect(e.status, SloStatus.warning);
      expect(e.burnRatio, greaterThan(0.5));
      expect(e.burnRatio, lessThan(1));
    });

    test('burnRatio >= 1 → breached', () {
      // 10 failures / 1000 = 1.0%, success = 99.0%, target = 99.5%
      // → burn ratio = 0.01/0.005 = 2.0 → breached.
      final e = evaluateSlo(
        slo: slo,
        observation: const SloObservation(totalEvents: 1000, failureEvents: 10),
      );
      expect(e.status, SloStatus.breached);
      expect(e.burnRatio, closeTo(2.0, 1e-6));
      expect(e.actualSuccessPercent, 99.0);
    });

    test('100% target + a single failure → breached + infinite burn', () {
      final slo100 = SloCatalog.byId('chain_tamper_zero')!;
      final e = evaluateSlo(
        slo: slo100,
        observation: const SloObservation(totalEvents: 1000, failureEvents: 1),
      );
      expect(e.status, SloStatus.breached);
      expect(e.burnRatio, double.infinity);
    });

    test('100% target with zero failures over a busy window → healthy', () {
      final slo100 = SloCatalog.byId('chain_tamper_zero')!;
      final e = evaluateSlo(
        slo: slo100,
        observation: const SloObservation(totalEvents: 1000, failureEvents: 0),
      );
      expect(e.status, SloStatus.healthy);
      expect(e.burnRatio, 0.0);
    });
  });

  group('SloWindow.totalMinutes', () {
    test('rolling7d / 30d / 90d math', () {
      expect(SloWindow.rolling7d.totalMinutes, 7 * 24 * 60);
      expect(SloWindow.rolling30d.totalMinutes, 30 * 24 * 60);
      expect(SloWindow.rolling90d.totalMinutes, 90 * 24 * 60);
    });
  });
}
