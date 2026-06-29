import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/incident_severity.dart';
import 'package:psyclinicai/services/ops/alerting_policy_catalog.dart';

void main() {
  group('AlertingPolicyCatalog — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(AlertingPolicyCatalog.policies, isNotEmpty);
    });

    test('every policy has a unique id', () {
      final ids = AlertingPolicyCatalog.policies.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final p in AlertingPolicyCatalog.policies) {
        expect(AlertingPolicyCatalog.byId(p.id), same(p));
      }
      expect(AlertingPolicyCatalog.byId('does-not-exist'), isNull);
    });

    test('every policy has populated fields + anchors', () {
      for (final p in AlertingPolicyCatalog.policies) {
        expect(p.signalLabel, isNotEmpty, reason: p.id);
        expect(p.channels, isNotEmpty, reason: p.id);
        expect(p.responseOwner, isNotEmpty, reason: p.id);
        expect(p.runbookId, isNotEmpty, reason: p.id);
        expect(p.regulatoryRefs, isNotEmpty, reason: p.id);
        expect(p.suppressionMinutes, greaterThanOrEqualTo(0), reason: p.id);
      }
    });

    test('every runbookId resolves in the known runbook id set', () {
      for (final p in AlertingPolicyCatalog.policies) {
        expect(
          knownRunbookIds,
          contains(p.runbookId),
          reason:
              '${p.id}: runbookId `${p.runbookId}` not in known on_call_'
              'runbook IncidentKind set — fix parity (N3, PR #118)',
        );
      }
    });

    test('P0 policies page the on-call (pager in channels)', () {
      for (final p in AlertingPolicyCatalog.bySeverity(IncidentSeverity.p0)) {
        expect(
          p.channels,
          contains(AlertChannel.pager),
          reason:
              '${p.id}: P0 MUST include pager channel — on-call wake-up '
              'is the contract',
        );
        expect(wakesOnCall(p), isTrue, reason: '${p.id}: helper agrees');
      }
    });

    test('P0 policies have zero suppression (never miss safety signal)', () {
      for (final p in AlertingPolicyCatalog.bySeverity(IncidentSeverity.p0)) {
        expect(
          p.suppressionMinutes,
          0,
          reason:
              '${p.id}: P0 suppression > 0 would let a second event slip '
              'past the on-call',
        );
      }
    });

    test('P2 + P3 policies do not wake the on-call', () {
      for (final sev in [IncidentSeverity.p2, IncidentSeverity.p3]) {
        for (final p in AlertingPolicyCatalog.bySeverity(sev)) {
          expect(
            p.channels,
            isNot(contains(AlertChannel.pager)),
            reason:
                '${p.id}: ${sev.name} should never reach the pager — '
                'noise floor',
          );
        }
      }
    });

    test(
      'breach + chain-break + ransomware are owned (not the generic on-call)',
      () {
        final breach = AlertingPolicyCatalog.byId(
          'alert-breach-72h-window-opening',
        )!;
        expect(breach.responseOwner, 'dpo');
        final chain = AlertingPolicyCatalog.byId('alert-chain-break')!;
        expect(chain.responseOwner, 'on_call');
        final ransom = AlertingPolicyCatalog.byId(
          'alert-ransomware-indicators',
        )!;
        expect(ransom.responseOwner, 'on_call');
      },
    );

    test('AI output block routes to clinical advisor (not the SRE)', () {
      final ai = AlertingPolicyCatalog.byId('alert-ai-output-blocked')!;
      expect(ai.responseOwner, 'clinical_advisor');
    });

    test('every policy ships a regulatory anchor of some kind', () {
      const knownStandards = [
        'HIPAA',
        'GDPR',
        'KVKK',
        'SOC 2',
        'NIST',
        'EU AI Act',
        'FDA',
        'PCI',
      ];
      for (final p in AlertingPolicyCatalog.policies) {
        final blob = p.regulatoryRefs.join(' | ');
        expect(
          knownStandards.any(blob.contains),
          isTrue,
          reason: '${p.id}: regulatoryRefs cite no known standard',
        );
      }
    });

    test('bySeverity slices correctly', () {
      for (final sev in IncidentSeverity.values) {
        final slice = AlertingPolicyCatalog.bySeverity(sev);
        for (final p in slice) {
          expect(p.severity, sev);
        }
      }
    });
  });

  group('wakesOnCall helper', () {
    test('true when pager is in channels', () {
      final chainBreak = AlertingPolicyCatalog.byId('alert-chain-break')!;
      expect(wakesOnCall(chainBreak), isTrue);
    });

    test('false when only Slack + Sentry', () {
      final ai = AlertingPolicyCatalog.byId('alert-ai-output-blocked')!;
      expect(wakesOnCall(ai), isFalse);
    });
  });
}
