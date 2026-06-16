/// PHQ-9 item 9 ("thoughts of being better off dead or hurting
/// yourself") is the single highest-yield patient-safety signal on the
/// scale — a positive score must NEVER be left implicit. Whether the
/// total score lands in "mild" or "severe", a positive item 9
/// requires an immediate clinician decision before the workflow
/// continues.
///
/// This service evaluates raw PHQ-9 responses and returns the
/// recommended next action — the UI surfaces the matching modal
/// (`/scales/cssrs` redirect, Stanley-Brown safety plan, or local
/// crisis line) and records the decision in the audit chain.
///
/// Pure functions only — no I/O, no Firebase, no Flutter dependency.
library;

/// Severity buckets for the item-9 response (PHQ-9 scoring 0..3).
enum Phq9Item9Severity {
  /// Score 0 — not at all.
  none,

  /// Score 1 — several days. Suggest C-SSRS; do not block the visit.
  several,

  /// Score 2 — more than half the days. Strongly suggest C-SSRS +
  /// safety plan review.
  moreThanHalf,

  /// Score 3 — nearly every day. Auto-open C-SSRS + crisis modal.
  nearlyEveryDay,
}

/// One actionable next step the UI must surface.
enum Phq9Item9Action {
  /// No action required.
  none,

  /// Open the C-SSRS clinical scale.
  openCssrs,

  /// Open the Stanley-Brown safety plan for revision.
  openSafetyPlan,

  /// Show the crisis-resource modal (region-aware hotlines + means
  /// restriction checklist + "Document decision" capture).
  showCrisisModal,
}

/// Combined recommendation the UI consumes.
class Phq9Item9Recommendation {
  const Phq9Item9Recommendation({
    required this.severity,
    required this.primaryAction,
    required this.secondaryActions,
    required this.reason,
  });

  final Phq9Item9Severity severity;
  final Phq9Item9Action primaryAction;
  final List<Phq9Item9Action> secondaryActions;

  /// One-line clinical reason rendered on the modal so the clinician
  /// sees WHY the workflow is interrupting them. Plain text — the
  /// UI is responsible for i18n / formatting.
  final String reason;
}

class Phq9Item9Router {
  const Phq9Item9Router();

  /// Returns the recommendation for the given PHQ-9 responses map.
  /// The map may carry the response either as `phq9_9`, `item_9`, or
  /// `q9` — we tolerate all three because different intake tools
  /// emit different keys.
  Phq9Item9Recommendation evaluate(Map<String, int> responses) {
    final value = responses['phq9_9'] ?? responses['item_9'] ?? responses['q9'];
    if (value == null || value <= 0) {
      return const Phq9Item9Recommendation(
        severity: Phq9Item9Severity.none,
        primaryAction: Phq9Item9Action.none,
        secondaryActions: [],
        reason: '',
      );
    }
    if (value == 1) {
      return const Phq9Item9Recommendation(
        severity: Phq9Item9Severity.several,
        primaryAction: Phq9Item9Action.openCssrs,
        secondaryActions: [],
        reason:
            'Patient reported suicidal thoughts on several days. '
            'Run the C-SSRS to characterise ideation dimensionally.',
      );
    }
    if (value == 2) {
      return const Phq9Item9Recommendation(
        severity: Phq9Item9Severity.moreThanHalf,
        primaryAction: Phq9Item9Action.openCssrs,
        secondaryActions: [Phq9Item9Action.openSafetyPlan],
        reason:
            'Patient reported suicidal thoughts more than half the '
            'days. Run the C-SSRS and revisit the safety plan.',
      );
    }
    // value >= 3 — clamp to the most severe bucket.
    return const Phq9Item9Recommendation(
      severity: Phq9Item9Severity.nearlyEveryDay,
      primaryAction: Phq9Item9Action.showCrisisModal,
      secondaryActions: [
        Phq9Item9Action.openCssrs,
        Phq9Item9Action.openSafetyPlan,
      ],
      reason:
          'Patient reported suicidal thoughts nearly every day. '
          'Open the crisis-resource modal and document a decision '
          'before continuing.',
    );
  }
}
