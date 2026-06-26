/// O1 — Clinician activation funnel + cohort math.
///
/// **North-star activation**: a clinician becomes "activated" when
/// they generate their first SOAP draft inside the first 7 days
/// from signup. Everything before that is onboarding latency;
/// everything after is retention quality.
///
/// This file pins the funnel definition + the cohort math so the
/// dashboard widget, the activation-cohort review meeting, and
/// the email-sequence trigger logic (drip on stage drop-off) all
/// read from one source. A rename of an event id silently breaks
/// all three otherwise.
///
/// **Out of scope** (separate PRs):
///   * Live PostHog query → `ActivationStageObservation`.
///   * Cohort dashboard widget.
///   * Email-sequence trigger wire (drop-off >= warning %).
library;

/// Funnel stages, ordered from earliest to latest. Pinned —
/// inserting a stage in the middle forces the dashboard layout +
/// the email triggers to be reviewed together.
enum ActivationStage {
  /// Account created (`auth.signup_completed`).
  signup,

  /// Clinician logged in at least once after signup
  /// (`auth.signin_completed`).
  firstLogin,

  /// First patient intake captured (`intake.created`).
  firstIntake,

  /// First SOAP draft produced — north-star
  /// (`session.first_soap_generated`).
  firstSoap,

  /// First Stanley-Brown safety plan saved
  /// (`safety_plan.save`).
  firstSafetyPlan,

  /// Still active on day 7 (`auth.signin_completed` post-D7).
  d7Retention,

  /// Still active on day 30.
  d30Retention,
}

/// Definition of one stage in the funnel.
class ActivationStageDefinition {
  const ActivationStageDefinition({
    required this.stage,
    required this.label,
    required this.requiredEventId,
    required this.expectedDayFromSignup,
    required this.dropoffWarningPercent,
  });

  final ActivationStage stage;

  /// Display label rendered on the dashboard.
  final String label;

  /// PostHog / Sentry event id that signals the stage is reached.
  final String requiredEventId;

  /// Soft expectation — by this many days from signup, a healthy
  /// cohort should have crossed the stage. Used to colour the
  /// dashboard cells (green if ahead, amber if behind, red if
  /// past the next stage's deadline).
  final int expectedDayFromSignup;

  /// Conversion drop above this % between this stage and the
  /// PREVIOUS stage triggers the email-sequence drip + on-call
  /// product alert. 0 = no warning.
  final double dropoffWarningPercent;
}

/// Pinned funnel catalogue. Append-only.
class ActivationFunnel {
  const ActivationFunnel._();

  static const List<ActivationStageDefinition> stages = [
    ActivationStageDefinition(
      stage: ActivationStage.signup,
      label: 'Signed up',
      requiredEventId: 'auth.signup_completed',
      expectedDayFromSignup: 0,
      dropoffWarningPercent: 0,
    ),
    ActivationStageDefinition(
      stage: ActivationStage.firstLogin,
      label: 'First sign-in',
      requiredEventId: 'auth.signin_completed',
      expectedDayFromSignup: 0,
      // A signup that never logs in is a wasted email.
      dropoffWarningPercent: 30,
    ),
    ActivationStageDefinition(
      stage: ActivationStage.firstIntake,
      label: 'First patient intake',
      requiredEventId: 'intake.created',
      expectedDayFromSignup: 2,
      dropoffWarningPercent: 40,
    ),
    ActivationStageDefinition(
      stage: ActivationStage.firstSoap,
      label: 'First SOAP draft (north-star)',
      requiredEventId: 'session.first_soap_generated',
      expectedDayFromSignup: 7,
      // North-star drop-off. Anything > 50% of intakes that fail
      // to produce a SOAP in week 1 trips a deep review.
      dropoffWarningPercent: 50,
    ),
    ActivationStageDefinition(
      stage: ActivationStage.firstSafetyPlan,
      label: 'First safety plan saved',
      requiredEventId: 'safety_plan.save',
      expectedDayFromSignup: 14,
      // Most caseloads don't need a safety plan at all — this is
      // an upper-funnel feature signal, not a drop-off alarm.
      dropoffWarningPercent: 0,
    ),
    ActivationStageDefinition(
      stage: ActivationStage.d7Retention,
      label: 'D7 retention',
      requiredEventId: 'auth.signin_completed_d7',
      expectedDayFromSignup: 7,
      dropoffWarningPercent: 40,
    ),
    ActivationStageDefinition(
      stage: ActivationStage.d30Retention,
      label: 'D30 retention',
      requiredEventId: 'auth.signin_completed_d30',
      expectedDayFromSignup: 30,
      dropoffWarningPercent: 50,
    ),
  ];

  static ActivationStageDefinition byStage(ActivationStage s) =>
      stages.firstWhere((d) => d.stage == s);

  /// First stage that meets / exceeds [dropoffWarningPercent].
  /// Returns null when no stage trips its threshold. Used by the
  /// product-alert trigger.
  static ActivationStageDefinition? firstWarning(
    List<ActivationStageResult> results,
  ) {
    for (final r in results) {
      if (r.definition.dropoffWarningPercent <= 0) continue;
      if (r.dropoffPercentFromPrevious >= r.definition.dropoffWarningPercent) {
        return r.definition;
      }
    }
    return null;
  }
}

/// Cohort header — every clinician that signed up on [startDate].
class ActivationCohort {
  const ActivationCohort({required this.startDate, required this.signupCount});

  final DateTime startDate;
  final int signupCount;
}

/// Per-stage result for one cohort.
class ActivationStageResult {
  const ActivationStageResult({
    required this.definition,
    required this.reachedCount,
    required this.conversionPercentFromSignup,
    required this.dropoffPercentFromPrevious,
  });

  final ActivationStageDefinition definition;

  /// Number of clinicians from the cohort that crossed this stage.
  final int reachedCount;

  /// `reachedCount / cohort.signupCount × 100`, 0.0 when the
  /// cohort is empty.
  final double conversionPercentFromSignup;

  /// `(prevReached - reachedCount) / prevReached × 100`. 0 for
  /// the signup stage itself.
  final double dropoffPercentFromPrevious;
}

/// Evaluate a cohort against a per-stage reached-count map. Pure:
/// the caller supplies the reached counts (from PostHog / a SQL
/// roll-up); this helper does the math + coverage assertions.
List<ActivationStageResult> evaluateActivationCohort({
  required ActivationCohort cohort,
  required Map<ActivationStage, int> reachedByStage,
}) {
  final results = <ActivationStageResult>[];
  int previousReached = cohort.signupCount;
  for (final def in ActivationFunnel.stages) {
    final reached = reachedByStage[def.stage] ?? 0;
    final conversion = cohort.signupCount == 0
        ? 0.0
        : 100 * reached / cohort.signupCount;
    final dropoff =
        (previousReached == 0 || def.stage == ActivationStage.signup)
        ? 0.0
        : (100 * (previousReached - reached) / previousReached)
              .clamp(0, 100)
              .toDouble();
    results.add(
      ActivationStageResult(
        definition: def,
        reachedCount: reached,
        conversionPercentFromSignup: conversion,
        dropoffPercentFromPrevious: dropoff,
      ),
    );
    previousReached = reached;
  }
  return results;
}
