/// L2 — Clinical runbook for C-SSRS escalations.
///
/// `CssrsEscalationService` (existing) reads the screener result
/// and returns the recommended action *band* (none / monitor /
/// initiateSafetyPlan / immediate / imminent). It does NOT spell
/// out the ordered steps a clinician must execute inside that
/// band, with timings, owners, and escalation-on-failure paths.
///
/// **Why a separate runbook helper**: an audit (Joint Commission
/// NPSG 15.01.01 + APA Practice Guideline for the Assessment and
/// Treatment of Patients with Suicidal Behaviors) flags a positive
/// CSSRS screen as a sentinel-event-adjacent moment; the response
/// must follow a documented, time-boxed protocol — not a free-text
/// "guidance" paragraph. This helper produces that protocol as a
/// structured list the UI can render as a timeline and the audit
/// trail can replay verbatim.
///
/// **Out of scope** (separate PRs):
///   * UI surfacing — modal / drawer / on-call dashboard render.
///   * Telephony fallback wiring — pager + crisis-line dial intent.
///   * Auto-prompt of the safety-plan screen — handoff intent.
library;

import 'cssrs_escalation_service.dart';

/// One step in a CSSRS escalation runbook. Pure data so the test
/// can pin the ordered protocol byte-for-byte.
class CssrsRunbookStep {
  const CssrsRunbookStep({
    required this.label,
    required this.ownerRole,
    required this.targetMinutes,
    required this.action,
    this.escalateOnFailure,
  });

  /// Short label rendered as the timeline marker — keep < 40 chars
  /// so the dashboard chip fits on a phone-width row.
  final String label;

  /// Who owns this step: `clinician`, `supervisor`, `crisis_team`,
  /// `emergency_services`. Drives the avatar + pager target.
  final String ownerRole;

  /// Soft target — how many minutes from the *runbook start* this
  /// step should be completed. Used to render the red urgency chip
  /// when the step slips past target.
  final int targetMinutes;

  /// Action body — what the owner does. One short sentence; the
  /// audit trail captures it verbatim.
  final String action;

  /// Optional pointer to the next runbook step if THIS step
  /// cannot be completed (patient refuses, supervisor unreachable,
  /// telephony failure). The on-call dashboard renders this as a
  /// "fallback" sub-row.
  final String? escalateOnFailure;
}

/// Full runbook for one tier of escalation.
class CssrsRunbook {
  const CssrsRunbook({
    required this.tier,
    required this.steps,
    required this.totalTargetMinutes,
    required this.regulatoryRefs,
  });

  final CssrsEscalationTier tier;

  /// Ordered protocol. Index 0 is the first action; the last step
  /// closes the loop (handoff, sign-off, documentation).
  final List<CssrsRunbookStep> steps;

  /// Sum of all `targetMinutes` — used by the on-call dashboard to
  /// show the protocol's total duration budget.
  final int totalTargetMinutes;

  /// Citations the runbook is grounded in. Surfaced in the audit
  /// trail so a JCAHO surveyor can trace the evidence base.
  final List<String> regulatoryRefs;
}

/// Returns the runbook a clinician follows when the CSSRS escalates
/// to [tier]. Pure: same input → same output, byte-for-byte.
CssrsRunbook runbookForTier(CssrsEscalationTier tier) {
  switch (tier) {
    case CssrsEscalationTier.none:
      return const CssrsRunbook(
        tier: CssrsEscalationTier.none,
        steps: [],
        totalTargetMinutes: 0,
        regulatoryRefs: [],
      );
    case CssrsEscalationTier.monitor:
      return const CssrsRunbook(
        tier: CssrsEscalationTier.monitor,
        steps: [
          CssrsRunbookStep(
            label: 'Document ideation',
            ownerRole: 'clinician',
            targetMinutes: 5,
            action:
                'Record the passive / non-specific ideation in the '
                'session note with timestamp, severity, and trigger.',
          ),
          CssrsRunbookStep(
            label: 'Risk-factor inventory',
            ownerRole: 'clinician',
            targetMinutes: 10,
            action:
                'Review modifiable risk factors (sleep, substance '
                'use, recent loss) and protective factors with the '
                'patient. Record both lists.',
          ),
          CssrsRunbookStep(
            label: 'Schedule follow-up',
            ownerRole: 'clinician',
            targetMinutes: 5,
            action:
                'Book the next session within 7 days and document '
                'the rationale for the interval.',
            escalateOnFailure: 'Escalate to initiateSafetyPlan tier',
          ),
        ],
        totalTargetMinutes: 20,
        regulatoryRefs: [
          'APA Practice Guideline §I.A.2 (routine monitoring)',
          'Joint Commission NPSG 15.01.01',
        ],
      );
    case CssrsEscalationTier.initiateSafetyPlan:
      return const CssrsRunbook(
        tier: CssrsEscalationTier.initiateSafetyPlan,
        steps: [
          CssrsRunbookStep(
            label: 'Open safety plan',
            ownerRole: 'clinician',
            targetMinutes: 2,
            action:
                'Launch the Stanley-Brown safety-plan screen and '
                'introduce the framework to the patient.',
          ),
          CssrsRunbookStep(
            label: 'Build plan WITH client',
            ownerRole: 'clinician',
            targetMinutes: 25,
            action:
                'Co-create warning signs, coping strategies, social '
                'supports, professionals, and crisis lines. Patient '
                'reads each section aloud to confirm understanding.',
          ),
          CssrsRunbookStep(
            label: 'Means restriction',
            ownerRole: 'clinician',
            targetMinutes: 10,
            action:
                'Discuss removing / securing access to lethal means '
                '(firearms, medications, sharp objects). Document '
                'who will action it and by when.',
          ),
          CssrsRunbookStep(
            label: 'Sign + share',
            ownerRole: 'clinician',
            targetMinutes: 5,
            action:
                'Patient signs the plan, takes a copy, and confirms '
                'they can locate it on their device.',
            escalateOnFailure: 'Escalate to immediate tier',
          ),
        ],
        totalTargetMinutes: 42,
        regulatoryRefs: [
          'Stanley-Brown Safety Planning Intervention (2012)',
          'APA Practice Guideline §I.A.3 (active ideation w/ method)',
          'Joint Commission NPSG 15.01.01',
        ],
      );
    case CssrsEscalationTier.immediate:
      return const CssrsRunbook(
        tier: CssrsEscalationTier.immediate,
        steps: [
          CssrsRunbookStep(
            label: 'Do not leave patient',
            ownerRole: 'clinician',
            targetMinutes: 0,
            action:
                'Maintain continuous line of sight. Do not exit the '
                'room. If you must, hand off to another clinician '
                'in person before leaving.',
          ),
          CssrsRunbookStep(
            label: 'Page supervisor',
            ownerRole: 'supervisor',
            targetMinutes: 5,
            action:
                'Notify the on-call supervisor by pager + secure '
                'message. Confirm receipt before continuing the '
                'risk assessment.',
            escalateOnFailure: 'Dial crisis team direct line',
          ),
          CssrsRunbookStep(
            label: 'Full risk assessment',
            ownerRole: 'clinician',
            targetMinutes: 30,
            action:
                'Conduct a structured risk assessment (CSSRS '
                'full-version + SAD PERSONS / CAMS chronological '
                'review). Document plan, intent, means, timeline.',
          ),
          CssrsRunbookStep(
            label: 'Disposition decision',
            ownerRole: 'supervisor',
            targetMinutes: 15,
            action:
                'Supervisor + clinician agree disposition: outpatient '
                'with safety plan + 24h re-check, partial-hospital '
                'referral, or ED transfer.',
            escalateOnFailure: 'Default to imminent tier ED transfer',
          ),
        ],
        totalTargetMinutes: 50,
        regulatoryRefs: [
          'APA Practice Guideline §I.A.4 (ideation w/ intent or plan)',
          'Joint Commission NPSG 15.01.01',
          'Zero Suicide Care Pathway',
        ],
      );
    case CssrsEscalationTier.imminent:
      return const CssrsRunbook(
        tier: CssrsEscalationTier.imminent,
        steps: [
          CssrsRunbookStep(
            label: 'Initiate 1:1 observation',
            ownerRole: 'clinician',
            targetMinutes: 0,
            action:
                'Stay with the patient. Remove or secure any items '
                'in the room that could be used for self-harm. Do '
                'not leave under any circumstance.',
          ),
          CssrsRunbookStep(
            label: 'Activate emergency response',
            ownerRole: 'emergency_services',
            targetMinutes: 5,
            action:
                'Call 911 / 112 / local emergency line. Request a '
                'mental-health-trained dispatch team if available.',
            escalateOnFailure: 'Page on-call psychiatrist for crisis bridge',
          ),
          CssrsRunbookStep(
            label: 'Warm handoff to ED',
            ownerRole: 'crisis_team',
            targetMinutes: 60,
            action:
                'Stay on the line / in person until ED clinician '
                'receives the patient. Verbal SBAR handoff covering '
                'CSSRS items endorsed, means, and current safety.',
            escalateOnFailure:
                'Document declined-handoff per APA §V.B and notify '
                'supervisor + family contact (if consented)',
          ),
          CssrsRunbookStep(
            label: 'Post-event documentation',
            ownerRole: 'clinician',
            targetMinutes: 30,
            action:
                'Within 24h: complete the sentinel-event log, file '
                'the safety event in the audit trail, schedule a '
                'CAPA (corrective + preventive action) review.',
          ),
        ],
        totalTargetMinutes: 95,
        regulatoryRefs: [
          'APA Practice Guideline §I.A.5 (suicidal behavior)',
          'Joint Commission NPSG 15.01.01',
          'Joint Commission Sentinel Event Policy SE-A',
          'Zero Suicide Care Pathway',
        ],
      );
  }
}

/// Owner roles the runbook uses. Pinned const so the UI can switch
/// on a stable string when picking the avatar / pager target.
class CssrsRunbookRoles {
  const CssrsRunbookRoles._();
  static const String clinician = 'clinician';
  static const String supervisor = 'supervisor';
  static const String crisisTeam = 'crisis_team';
  static const String emergencyServices = 'emergency_services';
}
