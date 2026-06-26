/// L2 — pins the CSSRS escalation runbook contract.
///
/// A clinician's response to a positive CSSRS screen is sentinel-
/// event-adjacent; the protocol order, owners, and total time
/// budget must NOT drift silently. Pin every band.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/cssrs_escalation_runbook.dart';
import 'package:psyclinicai/services/assessments/cssrs_escalation_service.dart';

void main() {
  group('runbookForTier — none', () {
    test('returns an empty runbook (no protocol needed)', () {
      final r = runbookForTier(CssrsEscalationTier.none);
      expect(r.tier, CssrsEscalationTier.none);
      expect(r.steps, isEmpty);
      expect(r.totalTargetMinutes, 0);
      expect(r.regulatoryRefs, isEmpty);
    });
  });

  group('runbookForTier — monitor', () {
    test('3 steps, clinician-owned, 20 min budget', () {
      final r = runbookForTier(CssrsEscalationTier.monitor);
      expect(r.steps, hasLength(3));
      expect(r.steps.map((s) => s.ownerRole).toSet(), {
        CssrsRunbookRoles.clinician,
      });
      expect(r.totalTargetMinutes, 20);
    });

    test('last step escalates to initiateSafetyPlan on failure', () {
      final r = runbookForTier(CssrsEscalationTier.monitor);
      expect(r.steps.last.escalateOnFailure, contains('initiateSafetyPlan'));
    });

    test('cites APA + Joint Commission', () {
      final r = runbookForTier(CssrsEscalationTier.monitor);
      expect(r.regulatoryRefs.join(' '), contains('APA Practice Guideline'));
      expect(r.regulatoryRefs.join(' '), contains('Joint Commission'));
    });
  });

  group('runbookForTier — initiateSafetyPlan', () {
    test('4 steps, 42 min budget, last step escalates to immediate', () {
      final r = runbookForTier(CssrsEscalationTier.initiateSafetyPlan);
      expect(r.steps, hasLength(4));
      expect(r.totalTargetMinutes, 42);
      expect(r.steps.last.escalateOnFailure, contains('immediate'));
    });

    test('means restriction step is present (lethal-means counselling)', () {
      final r = runbookForTier(CssrsEscalationTier.initiateSafetyPlan);
      final labels = r.steps.map((s) => s.label.toLowerCase()).toList();
      expect(labels.any((l) => l.contains('means')), isTrue);
    });

    test('cites Stanley-Brown framework', () {
      final r = runbookForTier(CssrsEscalationTier.initiateSafetyPlan);
      expect(r.regulatoryRefs.join(' '), contains('Stanley-Brown'));
    });
  });

  group('runbookForTier — immediate', () {
    test('4 steps spread across clinician + supervisor roles', () {
      final r = runbookForTier(CssrsEscalationTier.immediate);
      expect(r.steps, hasLength(4));
      final roles = r.steps.map((s) => s.ownerRole).toSet();
      expect(roles, contains(CssrsRunbookRoles.clinician));
      expect(roles, contains(CssrsRunbookRoles.supervisor));
    });

    test('first step is "do not leave patient" at minute 0', () {
      final r = runbookForTier(CssrsEscalationTier.immediate);
      expect(r.steps.first.targetMinutes, 0);
      expect(r.steps.first.label.toLowerCase(), contains('do not leave'));
    });

    test('disposition step falls back to imminent tier', () {
      final r = runbookForTier(CssrsEscalationTier.immediate);
      expect(r.steps.last.escalateOnFailure, contains('imminent'));
    });
  });

  group('runbookForTier — imminent', () {
    test('4 steps, 95 min total, covers ED warm-handoff', () {
      final r = runbookForTier(CssrsEscalationTier.imminent);
      expect(r.steps, hasLength(4));
      expect(r.totalTargetMinutes, 95);
      final labels = r.steps.map((s) => s.label.toLowerCase()).toList();
      expect(labels.any((l) => l.contains('handoff')), isTrue);
    });

    test('emergency services step has targetMinutes ≤ 5 (no delay)', () {
      final r = runbookForTier(CssrsEscalationTier.imminent);
      final ems = r.steps.firstWhere(
        (s) => s.ownerRole == CssrsRunbookRoles.emergencyServices,
      );
      expect(ems.targetMinutes, lessThanOrEqualTo(5));
    });

    test('cites Joint Commission Sentinel Event Policy', () {
      final r = runbookForTier(CssrsEscalationTier.imminent);
      expect(r.regulatoryRefs.join(' '), contains('Sentinel Event'));
    });

    test('post-event documentation closes the loop', () {
      final r = runbookForTier(CssrsEscalationTier.imminent);
      expect(r.steps.last.label.toLowerCase(), contains('documentation'));
    });
  });

  group('totalTargetMinutes invariant', () {
    test('matches sum of step.targetMinutes for every tier', () {
      for (final tier in CssrsEscalationTier.values) {
        final r = runbookForTier(tier);
        final sum = r.steps.fold<int>(0, (acc, s) => acc + s.targetMinutes);
        expect(
          r.totalTargetMinutes,
          sum,
          reason:
              'totalTargetMinutes drifted from the sum of step targets '
              'for tier ${tier.name}',
        );
      }
    });
  });

  group('owner role labels are stable string consts', () {
    test('every step.ownerRole matches a CssrsRunbookRoles constant', () {
      final validRoles = <String>{
        CssrsRunbookRoles.clinician,
        CssrsRunbookRoles.supervisor,
        CssrsRunbookRoles.crisisTeam,
        CssrsRunbookRoles.emergencyServices,
      };
      for (final tier in CssrsEscalationTier.values) {
        for (final s in runbookForTier(tier).steps) {
          expect(
            validRoles,
            contains(s.ownerRole),
            reason:
                'tier ${tier.name} has step "${s.label}" with '
                'unknown role "${s.ownerRole}" — add it to '
                'CssrsRunbookRoles or fix the typo',
          );
        }
      }
    });
  });
}
