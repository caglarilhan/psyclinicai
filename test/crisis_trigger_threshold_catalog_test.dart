import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/crisis_trigger_threshold_catalog.dart';

void main() {
  group('CrisisTriggerThresholdCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(CrisisTriggerThresholdCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = CrisisTriggerThresholdCatalog.records
          .map((r) => r.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in CrisisTriggerThresholdCatalog.records) {
        expect(CrisisTriggerThresholdCatalog.byId(r.id), same(r));
      }
      expect(CrisisTriggerThresholdCatalog.byId('does-not-exist'), isNull);
    });

    test('every ClinicalInstrument has at least one pinned threshold', () {
      final pinned = CrisisTriggerThresholdCatalog.records
          .map((r) => r.instrument)
          .toSet();
      for (final i in ClinicalInstrument.values) {
        expect(
          pinned,
          contains(i),
          reason: '${i.name}: no threshold pinned — coverage gap',
        );
      }
    });

    test('every record has populated fields + anchors + positive cutoff', () {
      for (final r in CrisisTriggerThresholdCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.cutoff, greaterThan(0), reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'PHQ-9 item 9 positive MUST be immediateCrisis (suicidal ideation hard floor)',
      () {
        final r = CrisisTriggerThresholdCatalog.byId('phq9-item9-positive')!;
        expect(r.action, EscalationAction.immediateCrisis);
        expect(
          r.cutoff,
          1,
          reason: 'PHQ-9 item 9 cutoff MUST be 1 (any positive — no soft pass)',
        );
      },
    );

    test('C-SSRS ideation with plan or intent MUST be immediateCrisis', () {
      final r = CrisisTriggerThresholdCatalog.byId(
        'cssrs-ideation-with-plan-or-intent',
      )!;
      expect(r.action, EscalationAction.immediateCrisis);
      expect(
        r.cutoff,
        greaterThanOrEqualTo(4),
        reason: 'C-SSRS level >= 4 = plan/intent per Posner 2011',
      );
    });

    test(
      'every immediateCrisis record MUST cite Joint Commission NPSG 15.01.01',
      () {
        for (final r in CrisisTriggerThresholdCatalog.records) {
          if (r.action != EscalationAction.immediateCrisis) continue;
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('Joint Commission NPSG 15.01.01'),
            isTrue,
            reason:
                '${r.id}: immediateCrisis MUST cite NPSG 15.01.01 suicide risk reduction',
          );
        }
      },
    );

    test('every immediateCrisis record MUST cite FDA CDS Guidance', () {
      for (final r in CrisisTriggerThresholdCatalog.records) {
        if (r.action != EscalationAction.immediateCrisis) continue;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('FDA CDS Guidance'),
          isTrue,
          reason:
              '${r.id}: immediateCrisis decision-support MUST cite FDA CDS Guidance',
        );
      }
    });

    test(
      'PHQ-9 cutoffs MUST be moderate=10 < moderately-severe=15 (Kroenke 2001)',
      () {
        final moderate = CrisisTriggerThresholdCatalog.byId(
          'phq9-moderate',
        )!.cutoff;
        final moderatelySevere = CrisisTriggerThresholdCatalog.byId(
          'phq9-moderately-severe',
        )!.cutoff;
        expect(moderate, 10);
        expect(moderatelySevere, 15);
        expect(moderate, lessThan(moderatelySevere));
      },
    );

    test('GAD-7 cutoffs MUST be moderate=10 < severe=15 (Spitzer 2006)', () {
      final moderate = CrisisTriggerThresholdCatalog.byId(
        'gad7-moderate',
      )!.cutoff;
      final severe = CrisisTriggerThresholdCatalog.byId('gad7-severe')!.cutoff;
      expect(moderate, 10);
      expect(severe, 15);
    });

    test(
      'AUDIT cutoffs MUST be harmful=8 < dependence-likely=20 (Saunders 1993)',
      () {
        final harmful = CrisisTriggerThresholdCatalog.byId(
          'audit-harmful-use',
        )!.cutoff;
        final dependence = CrisisTriggerThresholdCatalog.byId(
          'audit-dependence-likely',
        )!.cutoff;
        expect(harmful, 8);
        expect(dependence, 20);
      },
    );

    test('PCL-5 probable PTSD cutoff MUST be 33 (Weathers 2013)', () {
      final r = CrisisTriggerThresholdCatalog.byId('pcl5-probable-ptsd')!;
      expect(r.cutoff, 33);
    });

    test('WHO-5 MUST use lowerBoundInclusive=false (inverted scale)', () {
      final r = CrisisTriggerThresholdCatalog.byId('who5-poor-wellbeing')!;
      expect(
        r.lowerBoundInclusive,
        isFalse,
        reason:
            'WHO-5 is LOWER=worse; lowerBoundInclusive must be false (matched when score <= cutoff)',
      );
    });

    test(
      'every non-WHO-5 record MUST use lowerBoundInclusive=true (standard scales)',
      () {
        for (final r in CrisisTriggerThresholdCatalog.records) {
          if (r.instrument == ClinicalInstrument.who5) continue;
          expect(
            r.lowerBoundInclusive,
            isTrue,
            reason:
                '${r.id}: only WHO-5 is inverted; mistakenly inverting another scale would silently miss positives',
          );
        }
      },
    );

    test(
      'every record MUST cite primary validation reference (Kroenke/Spitzer/Posner/Saunders/Weathers/Topp)',
      () {
        const validators = [
          'Kroenke',
          'Spitzer',
          'Posner',
          'Saunders',
          'Weathers',
          'Topp',
        ];
        for (final r in CrisisTriggerThresholdCatalog.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            validators.any(blob.contains),
            isTrue,
            reason: '${r.id}: needs primary instrument validation reference',
          );
        }
      },
    );
  });

  group('actionAtLeast + escalationForScore helpers', () {
    test('actionAtLeast monotonic across the 4-rung ladder', () {
      const ladder = [
        EscalationAction.none,
        EscalationAction.clinicianReview,
        EscalationAction.sameDayClinicianContact,
        EscalationAction.immediateCrisis,
      ];
      for (var i = 0; i < ladder.length; i++) {
        for (var j = 0; j < ladder.length; j++) {
          expect(
            actionAtLeast(ladder[i], ladder[j]),
            i >= j,
            reason: '${ladder[i]} >= ${ladder[j]} should be ${i >= j}',
          );
        }
      }
    });

    test('PHQ-9 score 5 → none (sub-clinical)', () {
      expect(
        escalationForScore(ClinicalInstrument.phq9, 5),
        EscalationAction.none,
      );
    });

    test('PHQ-9 score 10 → clinicianReview (moderate band)', () {
      expect(
        escalationForScore(ClinicalInstrument.phq9, 10),
        EscalationAction.clinicianReview,
      );
    });

    test('PHQ-9 score 15 → sameDayClinicianContact (moderately severe)', () {
      expect(
        escalationForScore(ClinicalInstrument.phq9, 15),
        EscalationAction.sameDayClinicianContact,
      );
    });

    test('C-SSRS score 4 → immediateCrisis (plan or intent)', () {
      expect(
        escalationForScore(ClinicalInstrument.cssrs, 4),
        EscalationAction.immediateCrisis,
      );
    });

    test('WHO-5 score 30 → none (above the 28 threshold)', () {
      expect(
        escalationForScore(ClinicalInstrument.who5, 30),
        EscalationAction.none,
      );
    });

    test(
      'WHO-5 score 20 → clinicianReview (below the 28 threshold; inverted)',
      () {
        expect(
          escalationForScore(ClinicalInstrument.who5, 20),
          EscalationAction.clinicianReview,
        );
      },
    );
  });

  group('escalationForSubItem helper (PHQ-9 item 9)', () {
    test('PHQ-9 item 9 value 0 → none (denies SI)', () {
      expect(
        escalationForSubItem('phq9-item9-positive', 0),
        EscalationAction.none,
      );
    });

    test('PHQ-9 item 9 value 1 → immediateCrisis (any positive)', () {
      expect(
        escalationForSubItem('phq9-item9-positive', 1),
        EscalationAction.immediateCrisis,
      );
    });

    test('PHQ-9 item 9 value 3 → immediateCrisis (max positive)', () {
      expect(
        escalationForSubItem('phq9-item9-positive', 3),
        EscalationAction.immediateCrisis,
      );
    });

    test('escalationForSubItem returns none when recordId is a total-score rule '
        '(misuse safety)', () {
      expect(
        escalationForSubItem('phq9-moderate', 999),
        EscalationAction.none,
        reason:
            'phq9-moderate is a TOTAL-score rule; escalationForSubItem must refuse to apply it',
      );
    });

    test('escalationForSubItem returns none for unknown recordId', () {
      expect(escalationForSubItem('does-not-exist', 99), EscalationAction.none);
    });
  });

  group('appliesToTotalScore invariant', () {
    test('phq9-item9-positive is the ONLY sub-item rule '
        '(catalog scope keeps the helper contract narrow)', () {
      final subItem = CrisisTriggerThresholdCatalog.records
          .where((r) => !r.appliesToTotalScore)
          .toList();
      expect(
        subItem.length,
        1,
        reason:
            'only phq9-item9-positive is currently a SUB-item rule; adding more requires updating escalationForSubItem signature',
      );
      expect(subItem.first.id, 'phq9-item9-positive');
    });
  });
}
