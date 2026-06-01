import 'dart:async';

import '../../models/clinical_scale.dart';
import '../data/telemetry_service.dart';

/// What the clinician should do next given a C-SSRS screener result.
///
/// Ordered from least to most urgent so callers can compare with `>` if they
/// want — but the recommended pattern is to read the dedicated booleans on
/// [CssrsEscalation] (`requiresImmediateAction`, `requiresSafetyPlan`,
/// `blockPatientRelease`) instead of branching on the enum directly.
enum CssrsEscalationTier {
  /// No ideation or behavior endorsed — routine monitoring is sufficient.
  none,

  /// Passive death wish or non-specific active ideation (items 1–2). Continue
  /// to monitor; consider drafting a safety plan if clinical context warrants.
  monitor,

  /// Ideation with method (item 3). A collaborative safety plan should be
  /// built with the client before the session ends.
  initiateSafetyPlan,

  /// Ideation with intent or plan (items 4–5). A full clinical risk
  /// assessment is required immediately; the patient should not leave until
  /// safety is established.
  immediate,

  /// Any suicidal behavior — preparatory acts, aborted, interrupted, or
  /// actual attempt — at any point (item 6). Highest urgency.
  imminent,
}

/// Concrete recommendation derived from a [ScaleResult] of the C-SSRS.
class CssrsEscalation {
  const CssrsEscalation({
    required this.tier,
    required this.severity,
    required this.headline,
    required this.guidance,
    required this.requiresImmediateAction,
    required this.requiresSafetyPlan,
    required this.blockPatientRelease,
    required this.supervisorHint,
  });

  final CssrsEscalationTier tier;

  /// Original severity band from the C-SSRS scorer.
  final ScaleSeverity severity;

  /// Short label ("Imminent risk — act now", "Build a safety plan", ...).
  final String headline;

  /// One paragraph the clinician can read aloud or quote in the note.
  final String guidance;

  /// True when the clinician should not delay (severe / critical bands).
  final bool requiresImmediateAction;

  /// True when a Stanley-Brown safety plan should be started in this session.
  final bool requiresSafetyPlan;

  /// True when the patient must not be left alone or discharged until a full
  /// risk assessment is complete (intent / plan / behavior endorsed).
  final bool blockPatientRelease;

  /// Suggested next administrative step — paging a supervisor, looping in a
  /// crisis team, etc. Always shown as guidance, never auto-executed.
  final String supervisorHint;

  /// `true` for any tier above [CssrsEscalationTier.none].
  bool get hasAnyRisk => tier != CssrsEscalationTier.none;
}

/// Maps a C-SSRS [ScaleResult] to a concrete [CssrsEscalation] and reports
/// the event to telemetry (PHI-free).
///
/// This is intentionally a thin policy layer: the C-SSRS scorer in
/// `clinical_scales.dart` already categorises items 1–6 into a
/// [ScaleSeverity] band per the published manual. This service translates
/// that band into a workflow action so the UI doesn't have to.
class CssrsEscalationService {
  CssrsEscalationService({TelemetryService? telemetry})
      : _telemetry = telemetry ?? TelemetryService.instance;

  final TelemetryService _telemetry;

  /// Evaluate the screener result. Pure — does not emit telemetry. Use
  /// [recordEscalation] separately when you actually surface the banner.
  ///
  /// The mapping mirrors the C-SSRS escalation ladder:
  /// - `critical` (item 6, behavior) → [CssrsEscalationTier.imminent]
  /// - `severe`   (items 4–5, intent/plan) → [CssrsEscalationTier.immediate]
  /// - `moderate` (item 3, method) → [CssrsEscalationTier.initiateSafetyPlan]
  /// - `mild`     (items 1–2, ideation) → [CssrsEscalationTier.monitor]
  /// - `minimal`  → [CssrsEscalationTier.none]
  CssrsEscalation evaluate(ScaleResult result) {
    switch (result.severity) {
      case ScaleSeverity.critical:
        return const CssrsEscalation(
          tier: CssrsEscalationTier.imminent,
          severity: ScaleSeverity.critical,
          headline: 'Imminent risk — act now',
          guidance:
              'Suicidal behavior endorsed. Do not leave the patient alone. '
              'Conduct a full clinical risk assessment and arrange transfer '
              'to emergency services or an inpatient setting per protocol. '
              'Build the safety plan together once acute safety is secured.',
          requiresImmediateAction: true,
          requiresSafetyPlan: true,
          blockPatientRelease: true,
          supervisorHint:
              'Page your supervisor or on-call psychiatrist and document '
              'the handoff.',
        );
      case ScaleSeverity.severe:
        return const CssrsEscalation(
          tier: CssrsEscalationTier.immediate,
          severity: ScaleSeverity.severe,
          headline: 'High risk — full assessment required',
          guidance:
              'Active ideation with intent and/or plan. Complete a structured '
              'suicide risk assessment before the patient leaves. Build a '
              'collaborative safety plan and confirm means restriction.',
          requiresImmediateAction: true,
          requiresSafetyPlan: true,
          blockPatientRelease: true,
          supervisorHint:
              'Loop in your supervisor; consider involving family or a crisis '
              'team if disposition is unclear.',
        );
      case ScaleSeverity.moderate:
        return const CssrsEscalation(
          tier: CssrsEscalationTier.initiateSafetyPlan,
          severity: ScaleSeverity.moderate,
          headline: 'Build a safety plan with the client',
          guidance:
              'Ideation with method endorsed. Conduct a clinical risk '
              'assessment and start a Stanley-Brown safety plan with the '
              'client in this session. Reassess at the next visit.',
          requiresImmediateAction: false,
          requiresSafetyPlan: true,
          blockPatientRelease: false,
          supervisorHint:
              'Document the safety plan and schedule a short-interval '
              'follow-up.',
        );
      case ScaleSeverity.mild:
        return const CssrsEscalation(
          tier: CssrsEscalationTier.monitor,
          severity: ScaleSeverity.mild,
          headline: 'Positive screen — monitor and consider a safety plan',
          guidance:
              'Passive or non-specific active ideation. Assess context and '
              'risk factors, monitor closely, and consider drafting a '
              'safety plan if clinical judgement supports it.',
          requiresImmediateAction: false,
          requiresSafetyPlan: false,
          blockPatientRelease: false,
          supervisorHint:
              'Reassess at next visit; document monitoring plan in the note.',
        );
      case ScaleSeverity.minimal:
        return const CssrsEscalation(
          tier: CssrsEscalationTier.none,
          severity: ScaleSeverity.minimal,
          headline: 'No ideation endorsed',
          guidance:
              'No suicidal ideation or behavior endorsed on the screener. '
              'Continue routine monitoring at standard intervals.',
          requiresImmediateAction: false,
          requiresSafetyPlan: false,
          blockPatientRelease: false,
          supervisorHint: '',
        );
    }
  }

  /// Emit a PHI-free telemetry event. Item answers, score totals, and
  /// patient identifiers are deliberately excluded — analytics only need to
  /// know an escalation happened and at what tier.
  void recordEscalation(CssrsEscalation escalation) {
    if (!escalation.hasAnyRisk) return;
    unawaited(_telemetry.capture(
      TelemetryEvents.cssrsRiskEscalated,
      properties: {
        'tier': escalation.tier.name,
        'severity': escalation.severity.name,
        'requires_immediate_action': escalation.requiresImmediateAction,
        'requires_safety_plan': escalation.requiresSafetyPlan,
        'block_patient_release': escalation.blockPatientRelease,
      },
    ));
  }

  /// The clinician chose to start a safety plan from the escalation banner.
  void recordSafetyPlanInitiated(CssrsEscalation escalation) {
    unawaited(_telemetry.capture(
      TelemetryEvents.safetyPlanInitiatedFromCssrs,
      properties: {
        'tier': escalation.tier.name,
        'severity': escalation.severity.name,
      },
    ));
  }

  /// The clinician dismissed the high-risk modal without acting. We never
  /// block dismissal — clinical autonomy is intentional — but we count it.
  void recordModalDismissed(CssrsEscalation escalation,
      {required String reason}) {
    unawaited(_telemetry.capture(
      TelemetryEvents.cssrsEscalationModalDismissed,
      properties: {
        'tier': escalation.tier.name,
        'severity': escalation.severity.name,
        'reason': reason,
      },
    ));
  }
}
