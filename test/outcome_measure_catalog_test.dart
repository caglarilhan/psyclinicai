import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/outcome_measure_catalog.dart';

void main() {
  group('OutcomeMeasureCatalog — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(OutcomeMeasureCatalog.measures, isNotEmpty);
    });

    test('every scaleId is unique', () {
      final ids = OutcomeMeasureCatalog.measures.map((m) => m.scaleId).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate scaleId');
    });

    test('byScaleId resolves every entry', () {
      for (final m in OutcomeMeasureCatalog.measures) {
        expect(OutcomeMeasureCatalog.byScaleId(m.scaleId), same(m));
      }
      expect(OutcomeMeasureCatalog.byScaleId('does-not-exist'), isNull);
    });

    test('every record has populated fields + anchors', () {
      for (final m in OutcomeMeasureCatalog.measures) {
        expect(m.fullName, isNotEmpty, reason: m.scaleId);
        expect(m.bands, isNotEmpty, reason: m.scaleId);
        expect(m.runbookId, isNotEmpty, reason: m.scaleId);
        expect(m.validatedPopulation, isNotEmpty, reason: m.scaleId);
        expect(m.regulatoryRefs, isNotEmpty, reason: m.scaleId);
        expect(m.readminInterval, greaterThan(0), reason: m.scaleId);
        expect(m.maxScore, greaterThan(0), reason: m.scaleId);
      }
    });

    test('every measure has its scaleId in the known ClinicalScales set', () {
      const knownClinicalScales = {
        'phq9',
        'gad7',
        'who5',
        'audit',
        'pcl5',
        'wsas',
        'core10',
      };
      for (final m in OutcomeMeasureCatalog.measures) {
        expect(
          knownClinicalScales,
          contains(m.scaleId),
          reason:
              '${m.scaleId} not in the known ClinicalScales id set — fix '
              'parity (clinical_scales.dart)',
        );
      }
    });

    test('bands cover [0, maxScore] contiguously with no gaps or overlaps', () {
      for (final m in OutcomeMeasureCatalog.measures) {
        final sorted = [...m.bands]
          ..sort((a, b) => a.minScore.compareTo(b.minScore));
        expect(
          sorted.first.minScore,
          0,
          reason: '${m.scaleId}: bands must start at 0',
        );
        expect(
          sorted.last.maxScore,
          m.maxScore,
          reason: '${m.scaleId}: bands must end at maxScore',
        );
        for (var i = 1; i < sorted.length; i++) {
          expect(
            sorted[i].minScore,
            sorted[i - 1].maxScore + 1,
            reason:
                '${m.scaleId}: band gap/overlap between '
                '${sorted[i - 1].maxScore} and ${sorted[i].minScore}',
          );
        }
      }
    });

    test('alarmThreshold is inside [0, maxScore] for every record', () {
      for (final m in OutcomeMeasureCatalog.measures) {
        expect(m.alarmThreshold, greaterThanOrEqualTo(0), reason: m.scaleId);
        expect(
          m.alarmThreshold,
          lessThanOrEqualTo(m.maxScore),
          reason: m.scaleId,
        );
      }
    });

    test('every record cites at least one validation / guideline anchor', () {
      const must = [
        'NICE',
        'WHO',
        'Kroenke',
        'Spitzer',
        'Topp',
        'Weathers',
        'Saunders',
      ];
      for (final m in OutcomeMeasureCatalog.measures) {
        final blob = m.regulatoryRefs.join(' | ');
        expect(
          must.any(blob.contains),
          isTrue,
          reason:
              '${m.scaleId}: regulatoryRefs cite no recognised validation '
              'or guideline source',
        );
      }
    });

    test(
      'PHQ-9 alarm routes to the cssrs / phq9 item-9 escalation runbook',
      () {
        final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
        expect(phq.runbookId, contains('phq9'));
      },
    );

    test(
      'PHQ-9 alarm threshold is at the published moderate boundary (10)',
      () {
        final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
        expect(phq.alarmThreshold, 10);
      },
    );

    test(
      'GAD-7 alarm threshold is at the published moderate boundary (10)',
      () {
        final gad = OutcomeMeasureCatalog.byScaleId('gad7')!;
        expect(gad.alarmThreshold, 10);
      },
    );

    test('at least one record is validated for the adult population', () {
      final adult = OutcomeMeasureCatalog.measures
          .where((m) => m.validatedPopulation == 'adult')
          .toList();
      expect(adult, isNotEmpty);
    });
  });

  group('bandForScore', () {
    test('PHQ-9 5 lands in mild', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(bandForScore(phq, 5)?.severity, OutcomeSeverity.mild);
    });

    test('PHQ-9 14 lands in moderate', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(bandForScore(phq, 14)?.severity, OutcomeSeverity.moderate);
    });

    test('PHQ-9 27 (max) lands in severe', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(bandForScore(phq, 27)?.severity, OutcomeSeverity.severe);
    });

    test('PHQ-9 -1 (impossible) returns null', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(bandForScore(phq, -1), isNull);
    });

    test('PHQ-9 28 (over max) returns null', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(bandForScore(phq, 28), isNull);
    });

    test('WHO-5 lower scores are MORE severe (inverted scale)', () {
      final who = OutcomeMeasureCatalog.byScaleId('who5')!;
      expect(bandForScore(who, 0)?.severity, OutcomeSeverity.severe);
      expect(bandForScore(who, 25)?.severity, OutcomeSeverity.none);
    });
  });

  group('requiresClinicianAlarm', () {
    test('true when at threshold', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(requiresClinicianAlarm(phq, 10), isTrue);
    });

    test('true when above threshold', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(requiresClinicianAlarm(phq, 27), isTrue);
    });

    test('false when below threshold', () {
      final phq = OutcomeMeasureCatalog.byScaleId('phq9')!;
      expect(requiresClinicianAlarm(phq, 9), isFalse);
    });
  });
}
