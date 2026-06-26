/// N3 — pins the on-call runbook contract.
///
/// A Sentry alert at 03:00 must link to a stable playbook. Step
/// renaming or severity drift breaks the alert template; pin
/// every incident class + cross-link.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/on_call_runbook.dart';

void main() {
  group('runbookFor — coverage', () {
    test('every IncidentKind has a runbook', () {
      for (final i in IncidentKind.values) {
        final r = runbookFor(i);
        expect(r.incident, i);
        expect(
          r.steps,
          isNotEmpty,
          reason:
              'IncidentKind ${i.name} has no runbook steps; add at '
              'least an acknowledge step.',
        );
      }
    });

    test('every runbook cites at least one regulatory ref', () {
      for (final i in IncidentKind.values) {
        final r = runbookFor(i);
        expect(
          r.regulatoryRefs,
          isNotEmpty,
          reason:
              'IncidentKind ${i.name} runbook ships without a '
              'regulatory reference — audit evidence gap.',
        );
      }
    });

    test('totalTargetMinutes matches sum of step targets', () {
      for (final i in IncidentKind.values) {
        final r = runbookFor(i);
        final sum = r.steps.fold<int>(0, (a, s) => a + s.targetMinutes);
        expect(
          r.totalTargetMinutes,
          sum,
          reason:
              'totalTargetMinutes drifted from the sum of step '
              'targets for IncidentKind ${i.name}',
        );
      }
    });

    test('every step.ownerRole resolves to an OpsRunbookRoles const', () {
      const validRoles = <String>{
        OpsRunbookRoles.onCall,
        OpsRunbookRoles.dpo,
        OpsRunbookRoles.cto,
        OpsRunbookRoles.legal,
        OpsRunbookRoles.customerSuccess,
        OpsRunbookRoles.support,
        OpsRunbookRoles.infra,
      };
      for (final i in IncidentKind.values) {
        for (final s in runbookFor(i).steps) {
          expect(
            validRoles,
            contains(s.ownerRole),
            reason:
                'IncidentKind ${i.name} step "${s.label}" carries '
                'unknown ownerRole "${s.ownerRole}" — add it to '
                'OpsRunbookRoles or fix the typo.',
          );
        }
      }
    });
  });

  group('severity policy', () {
    test('chainTamper + breach72hApproaching are critical', () {
      expect(
        runbookFor(IncidentKind.chainTamper).severity,
        IncidentSeverity.critical,
      );
      expect(
        runbookFor(IncidentKind.breach72hApproaching).severity,
        IncidentSeverity.critical,
      );
    });

    test('cssrsSurge + mirrorOutage are high', () {
      expect(
        runbookFor(IncidentKind.cssrsSurge).severity,
        IncidentSeverity.high,
      );
      expect(
        runbookFor(IncidentKind.mirrorOutage).severity,
        IncidentSeverity.high,
      );
    });

    test('paymentFailureSpike + dsarSlaApproaching are medium', () {
      expect(
        runbookFor(IncidentKind.paymentFailureSpike).severity,
        IncidentSeverity.medium,
      );
      expect(
        runbookFor(IncidentKind.dsarSlaApproaching).severity,
        IncidentSeverity.medium,
      );
    });
  });

  group('chainTamper runbook specifics', () {
    test('first step targets ≤ 5 min (acknowledge fast)', () {
      final r = runbookFor(IncidentKind.chainTamper);
      expect(r.steps.first.targetMinutes, lessThanOrEqualTo(5));
    });

    test('escalates to breach72hApproaching on DPO triage failure', () {
      final r = runbookFor(IncidentKind.chainTamper);
      final dpoStep = r.steps.firstWhere(
        (s) => s.ownerRole == OpsRunbookRoles.dpo,
      );
      expect(dpoStep.escalateOnFailure, contains('breach72hApproaching'));
    });

    test('cites HIPAA integrity controls', () {
      final r = runbookFor(IncidentKind.chainTamper);
      expect(r.regulatoryRefs.join(' '), contains('§164.312(c)(1)'));
    });
  });

  group('breach72hApproaching runbook specifics', () {
    test('war-room step at minute 0 (CTO-owned)', () {
      final r = runbookFor(IncidentKind.breach72hApproaching);
      expect(r.steps.first.targetMinutes, 0);
      expect(r.steps.first.ownerRole, OpsRunbookRoles.cto);
    });

    test('cross-references K4 buildNotificationTemplate', () {
      final r = runbookFor(IncidentKind.breach72hApproaching);
      final dpoStep = r.steps.firstWhere(
        (s) => s.ownerRole == OpsRunbookRoles.dpo,
      );
      expect(dpoStep.action, contains('buildNotificationTemplate'));
    });

    test('legal step cites GDPR Art. 33', () {
      final r = runbookFor(IncidentKind.breach72hApproaching);
      expect(r.regulatoryRefs.join(' '), contains('GDPR Art. 33'));
      expect(r.regulatoryRefs.join(' '), contains('KVKK md. 12/5'));
    });
  });

  group('dsarSlaApproaching runbook specifics', () {
    test('cross-references the dsarExport Cloud Function', () {
      final r = runbookFor(IncidentKind.dsarSlaApproaching);
      expect(r.steps.any((s) => s.action.contains('dsarExport')), isTrue);
    });

    test('cites both GDPR Art. 12(3) + KVKK md. 13/2', () {
      final r = runbookFor(IncidentKind.dsarSlaApproaching);
      final refs = r.regulatoryRefs.join(' ');
      expect(refs, contains('GDPR Art. 12(3)'));
      expect(refs, contains('KVKK md. 13/2'));
    });
  });
}
