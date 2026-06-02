import 'phq9_item9_router.dart';

/// Closes the §8 finding from the rapor 09 audit: turns the PHQ-9
/// item-9 router output into an auditable chain of state transitions
/// the supervising clinician can replay later. The chain is the
/// substrate behind the auto-modal trigger in the patient chart —
/// the widget is a thin presentation layer.
///
/// State machine (irreversible forward, reversible only via
/// clinicianHandoff event):
///   triggered → cssrsAdministered → safetyPlanDrafted →
///   clinicianAcknowledged → resolved
class RiskEscalationChain {
  RiskEscalationChain({
    required this.patientId,
    required this.encounterId,
    required this.startedAt,
    required this.trigger,
    this.events = const [],
    this.state = RiskEscalationState.triggered,
  });

  final String patientId;
  final String encounterId;
  final DateTime startedAt;
  final Phq9Item9Recommendation trigger;
  final List<RiskEscalationEvent> events;
  final RiskEscalationState state;

  bool get requiresImmediateAttention =>
      trigger.primaryAction == Phq9Item9Action.showCrisisModal;

  bool get isResolved => state == RiskEscalationState.resolved;

  /// Apply [event] and return the next chain. Throws [StateError] when
  /// the transition is illegal (forward-only ordering except for the
  /// explicit `clinicianHandoff` rollback). The HIPAA audit trail
  /// depends on this guard — a resolved chain MUST be immutable.
  RiskEscalationChain advance(RiskEscalationEvent event) {
    if (isResolved) {
      throw StateError(
          'RiskEscalationChain is already resolved; the audit chain is '
          'immutable after resolution. Start a new chain instead.');
    }
    final next = _nextState(event);
    if (event.kind != RiskEscalationEventKind.clinicianHandoff &&
        next.index < state.index) {
      throw StateError(
          'Illegal transition: cannot move from ${state.name} '
          'back to ${next.name} via ${event.kind.name}. '
          'Use clinicianHandoff to roll back explicitly.');
    }
    return RiskEscalationChain(
      patientId: patientId,
      encounterId: encounterId,
      startedAt: startedAt,
      trigger: trigger,
      events: List.unmodifiable([...events, event]),
      state: next,
    );
  }

  RiskEscalationState _nextState(RiskEscalationEvent event) {
    switch (event.kind) {
      case RiskEscalationEventKind.cssrsAdministered:
        return RiskEscalationState.cssrsAdministered;
      case RiskEscalationEventKind.safetyPlanDrafted:
        return RiskEscalationState.safetyPlanDrafted;
      case RiskEscalationEventKind.clinicianAcknowledged:
        return RiskEscalationState.clinicianAcknowledged;
      case RiskEscalationEventKind.resolved:
        return RiskEscalationState.resolved;
      case RiskEscalationEventKind.clinicianHandoff:
        return RiskEscalationState.clinicianAcknowledged;
    }
  }

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'encounter_id': encounterId,
        'started_at': startedAt.toUtc().toIso8601String(),
        'trigger': {
          'severity': trigger.severity.name,
          'primary_action': trigger.primaryAction.name,
          'secondary_actions':
              trigger.secondaryActions.map((a) => a.name).toList(),
          'reason': trigger.reason,
        },
        'state': state.name,
        'events': events.map((e) => e.toJson()).toList(),
      };
}

enum RiskEscalationState {
  triggered,
  cssrsAdministered,
  safetyPlanDrafted,
  clinicianAcknowledged,
  resolved,
}

enum RiskEscalationEventKind {
  cssrsAdministered,
  safetyPlanDrafted,
  clinicianAcknowledged,
  clinicianHandoff,
  resolved,
}

class RiskEscalationEvent {
  const RiskEscalationEvent({
    required this.kind,
    required this.at,
    required this.clinicianId,
    this.note,
  });

  final RiskEscalationEventKind kind;
  final DateTime at;
  final String clinicianId;
  final String? note;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'at': at.toUtc().toIso8601String(),
        'clinician_id': clinicianId,
        if (note != null) 'note': note,
      };
}
