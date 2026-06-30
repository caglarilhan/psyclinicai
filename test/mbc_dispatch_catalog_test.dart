import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/outcome_measure_catalog.dart';
import 'package:psyclinicai/services/mbc/mbc_dispatch_catalog.dart';

void main() {
  group('MbcDispatchCatalog invariants', () {
    test('catalog is non-empty + every rule has a known scale id', () {
      expect(MbcDispatchCatalog.rules, isNotEmpty);
      for (final r in MbcDispatchCatalog.rules) {
        final outcome = OutcomeMeasureCatalog.byScaleId(r.scaleId);
        expect(outcome, isNotNull,
            reason: '${r.scaleId}: unknown to OutcomeMeasureCatalog');
      }
    });

    test('intervalDays matches OutcomeMeasureCatalog.readminInterval', () {
      for (final r in MbcDispatchCatalog.rules) {
        final outcome = OutcomeMeasureCatalog.byScaleId(r.scaleId)!;
        expect(r.intervalDays, outcome.readminInterval,
            reason: '${r.scaleId}: drift vs OutcomeMeasureCatalog');
      }
    });

    test('reminderAtHours <= linkLifetimeHours (reminders never dead)', () {
      for (final r in MbcDispatchCatalog.rules) {
        expect(r.reminderAtHours <= r.linkLifetimeHours, isTrue,
            reason: '${r.scaleId}: reminder would point at expired link');
      }
    });

    test('every rule pins at least one audience + channel', () {
      for (final r in MbcDispatchCatalog.rules) {
        expect(r.audiences, isNotEmpty);
        expect(r.channels, isNotEmpty);
      }
    });

    test('every rule pins a non-empty payerCadenceLabel', () {
      for (final r in MbcDispatchCatalog.rules) {
        expect(r.payerCadenceLabel.trim(), isNotEmpty);
      }
    });

    test('every rule pins regulatoryRefs', () {
      for (final r in MbcDispatchCatalog.rules) {
        expect(r.regulatoryRefs, isNotEmpty,
            reason: '${r.scaleId} missing regulatory anchor');
      }
    });

    test('maxItemsPerSession > 0', () {
      for (final r in MbcDispatchCatalog.rules) {
        expect(r.maxItemsPerSession > 0, isTrue);
      }
    });

    test('schemaVersion positive', () {
      expect(MbcDispatchCatalog.schemaVersion > 0, isTrue);
    });

    test('lastReviewed is YYYY-MM', () {
      expect(MbcDispatchCatalog.lastReviewed,
          matches(RegExp(r'^\d{4}-\d{2}$')));
    });

    test('byScaleId returns the matching rule', () {
      final r = MbcDispatchCatalog.byScaleId('phq9');
      expect(r.scaleId, 'phq9');
    });

    test('byScaleId throws for unknown id', () {
      expect(() => MbcDispatchCatalog.byScaleId('nonsense'),
          throwsStateError);
    });
  });

  group('isDueForDispatch', () {
    final rule = MbcDispatchCatalog.byScaleId('phq9'); // 14-day interval

    test('returns true when never dispatched', () {
      expect(
        isDueForDispatch(
          rule: rule,
          lastDispatchedAt: null,
          now: DateTime.utc(2026, 6, 30),
        ),
        isTrue,
      );
    });

    test('returns false when still inside the interval', () {
      expect(
        isDueForDispatch(
          rule: rule,
          lastDispatchedAt: DateTime.utc(2026, 6, 25),
          now: DateTime.utc(2026, 6, 30),
        ),
        isFalse,
      );
    });

    test('returns true on the boundary', () {
      expect(
        isDueForDispatch(
          rule: rule,
          lastDispatchedAt: DateTime.utc(2026, 6, 16),
          now: DateTime.utc(2026, 6, 30),
        ),
        isTrue,
      );
    });
  });

  group('tokenExpiryFor', () {
    test('adds catalog hours to dispatchedAt', () {
      final rule = MbcDispatchCatalog.byScaleId('phq9'); // 72h
      final exp = tokenExpiryFor(
        rule: rule,
        dispatchedAt: DateTime.utc(2026, 6, 30, 12),
      );
      expect(exp, DateTime.utc(2026, 7, 3, 12));
    });
  });
}
