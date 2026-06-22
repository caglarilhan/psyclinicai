import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/phq9_item9_router.dart';
import 'package:psyclinicai/services/assessments/risk_escalation_chain.dart';

void main() {
  const trigger = Phq9Item9Recommendation(
    severity: Phq9Item9Severity.nearlyEveryDay,
    primaryAction: Phq9Item9Action.showCrisisModal,
    secondaryActions: [
      Phq9Item9Action.openCssrs,
      Phq9Item9Action.openSafetyPlan,
    ],
    reason: 'Daily ideation reported',
  );

  RiskEscalationChain newChain() => RiskEscalationChain(
    patientId: 'p-1',
    encounterId: 'enc-1',
    startedAt: DateTime.utc(2026, 6, 2, 10),
    trigger: trigger,
  );

  group('RiskEscalationChain', () {
    test('starts in triggered state with no events', () {
      final c = newChain();
      expect(c.state, RiskEscalationState.triggered);
      expect(c.events, isEmpty);
      expect(c.isResolved, isFalse);
      expect(c.requiresImmediateAttention, isTrue);
    });

    test('forward chain: triggered → cssrs → safetyPlan → ack → resolved', () {
      final start = newChain();
      final at1 = DateTime.utc(2026, 6, 2, 10, 5);
      final c1 = start.advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.cssrsAdministered,
          at: at1,
          clinicianId: 'doc-1',
        ),
      );
      final c2 = c1.advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.safetyPlanDrafted,
          at: at1.add(const Duration(minutes: 15)),
          clinicianId: 'doc-1',
        ),
      );
      final c3 = c2.advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.clinicianAcknowledged,
          at: at1.add(const Duration(minutes: 20)),
          clinicianId: 'doc-1',
        ),
      );
      final c4 = c3.advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.resolved,
          at: at1.add(const Duration(hours: 1)),
          clinicianId: 'doc-1',
          note: 'Safety plan reviewed with patient',
        ),
      );

      expect(c1.state, RiskEscalationState.cssrsAdministered);
      expect(c2.state, RiskEscalationState.safetyPlanDrafted);
      expect(c3.state, RiskEscalationState.clinicianAcknowledged);
      expect(c4.state, RiskEscalationState.resolved);
      expect(c4.isResolved, isTrue);
      expect(c4.events.length, 4);
    });

    test('clinicianHandoff brings state back to acknowledged', () {
      final c = newChain().advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.clinicianHandoff,
          at: DateTime.utc(2026, 6, 2, 10, 10),
          clinicianId: 'supervisor-1',
          note: 'Handed off to on-call',
        ),
      );
      expect(c.state, RiskEscalationState.clinicianAcknowledged);
    });

    test('resolved chain refuses further events (audit immutability)', () {
      final at = DateTime.utc(2026, 6, 2, 10, 5);
      final c = newChain()
          .advance(
            RiskEscalationEvent(
              kind: RiskEscalationEventKind.cssrsAdministered,
              at: at,
              clinicianId: 'doc-1',
            ),
          )
          .advance(
            RiskEscalationEvent(
              kind: RiskEscalationEventKind.safetyPlanDrafted,
              at: at.add(const Duration(minutes: 10)),
              clinicianId: 'doc-1',
            ),
          )
          .advance(
            RiskEscalationEvent(
              kind: RiskEscalationEventKind.clinicianAcknowledged,
              at: at.add(const Duration(minutes: 20)),
              clinicianId: 'doc-1',
            ),
          )
          .advance(
            RiskEscalationEvent(
              kind: RiskEscalationEventKind.resolved,
              at: at.add(const Duration(hours: 1)),
              clinicianId: 'doc-1',
            ),
          );
      expect(
        () => c.advance(
          RiskEscalationEvent(
            kind: RiskEscalationEventKind.cssrsAdministered,
            at: at.add(const Duration(hours: 2)),
            clinicianId: 'doc-1',
          ),
        ),
        throwsStateError,
      );
    });

    test('illegal backward transition is rejected', () {
      final at = DateTime.utc(2026, 6, 2, 10, 5);
      final c = newChain().advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.safetyPlanDrafted,
          at: at,
          clinicianId: 'doc-1',
        ),
      );
      expect(
        () => c.advance(
          RiskEscalationEvent(
            kind: RiskEscalationEventKind.cssrsAdministered,
            at: at.add(const Duration(minutes: 5)),
            clinicianId: 'doc-1',
          ),
        ),
        throwsStateError,
      );
    });

    // M-8 fix coverage — duplicate event-kind on the same state
    // pollutes the audit trail. Reject by default.
    test('duplicate cssrsAdministered on same state is rejected (M-8)', () {
      final at = DateTime.utc(2026, 6, 2, 10, 5);
      final c = newChain().advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.cssrsAdministered,
          at: at,
          clinicianId: 'doc-1',
        ),
      );
      expect(
        () => c.advance(
          RiskEscalationEvent(
            kind: RiskEscalationEventKind.cssrsAdministered,
            at: at.add(const Duration(minutes: 1)),
            clinicianId: 'doc-1',
          ),
        ),
        throwsStateError,
      );
    });

    test('clinicianHandoff can repeat (explicit rollback path)', () {
      final at = DateTime.utc(2026, 6, 2, 10, 5);
      final c = newChain()
          .advance(
            RiskEscalationEvent(
              kind: RiskEscalationEventKind.cssrsAdministered,
              at: at,
              clinicianId: 'doc-1',
            ),
          )
          .advance(
            RiskEscalationEvent(
              kind: RiskEscalationEventKind.clinicianHandoff,
              at: at.add(const Duration(minutes: 1)),
              clinicianId: 'doc-1',
            ),
          );
      // A second handoff is allowed (the rollback semantics permit it).
      expect(
        () => c.advance(
          RiskEscalationEvent(
            kind: RiskEscalationEventKind.clinicianHandoff,
            at: at.add(const Duration(minutes: 2)),
            clinicianId: 'doc-1',
          ),
        ),
        returnsNormally,
      );
    });

    test('toJson preserves trigger severity + action chain', () {
      final c = newChain();
      final j = c.toJson();
      expect(j['patient_id'], 'p-1');
      expect(j['state'], 'triggered');
      final trigger = j['trigger'] as Map<String, dynamic>;
      expect(trigger['primary_action'], 'showCrisisModal');
      expect(
        (trigger['secondary_actions'] as List).cast<String>(),
        containsAll(['openCssrs', 'openSafetyPlan']),
      );
    });

    test('events list is immutable after advance (no mutation surprises)', () {
      final base = newChain();
      final advanced = base.advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.cssrsAdministered,
          at: DateTime.utc(2026, 6, 2, 10, 5),
          clinicianId: 'doc-1',
        ),
      );
      expect(
        () => advanced.events.add(
          RiskEscalationEvent(
            kind: RiskEscalationEventKind.resolved,
            at: DateTime.utc(2026, 6, 2, 11),
            clinicianId: 'doc-1',
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
