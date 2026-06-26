/// N1 — Service Level Objective (SLO) catalog + error-budget math.
///
/// **Why this exists**: the on-call dashboard (N3) tells you what
/// to DO when an alert fires. This file tells you whether an alert
/// SHOULD fire at all — and how much "budget" we have to burn
/// before we cross into a release-stopping breach of an SLO.
///
/// Each SLO is one row: the indicator we track, the success target
/// (e.g. 99.5%), and the rolling evaluation window (e.g. 30 days).
/// The error budget is derived: `(1 - target) × window`. When the
/// budget is consumed, deploys freeze until the next window opens.
///
/// **Why a pinned catalog**: the same definitions feed (1) the
/// Sentry alert rules, (2) the trust-center status page, and (3)
/// the executive dashboard. A drift between any two of those
/// silently breaks SLO accounting. Pinning them here + invariant
/// tests forces synchronised renames.
///
/// **Out of scope** (separate PRs):
///   * Live observation feed wiring (Sentry/PostHog query).
///   * SLO dashboard widget (renders this catalog + a percentile).
///   * Sentry rule terraform that consumes these IDs.
library;

/// Reporting window for SLO measurement. Pinned set so a future
/// "30 minute" hot-path SLI doesn't slip in without dashboard
/// support.
enum SloWindow {
  rolling7d(7),
  rolling30d(30),
  rolling90d(90);

  const SloWindow(this.days);
  final int days;

  /// Total minutes in the rolling window. The numerator for the
  /// error-budget calculation.
  int get totalMinutes => days * 24 * 60;
}

/// One Service Level Objective. Pure data — no Firestore, no
/// Sentry, no network.
class SloDefinition {
  const SloDefinition({
    required this.id,
    required this.name,
    required this.indicator,
    required this.targetPercent,
    required this.window,
    required this.rationale,
  });

  /// Stable id — used by the dashboard route + the Sentry rule
  /// terraform. Snake_case, < 40 chars.
  final String id;

  /// Display name for the dashboard row.
  final String name;

  /// What we measure — one short sentence, references the source
  /// telemetry event or audit row.
  final String indicator;

  /// Success target (e.g. 99.5). 0–100 inclusive.
  final double targetPercent;

  /// Rolling evaluation window.
  final SloWindow window;

  /// One-sentence rationale — why this target, what regulatory
  /// or contractual obligation drives it. Lives in source so the
  /// trust-center status page can render it verbatim.
  final String rationale;

  /// Minutes of allowed failure inside the window.
  /// `(1 - target/100) × windowMinutes`. Rounded down so the
  /// budget never overshoots.
  int get errorBudgetMinutes {
    final allowed = window.totalMinutes * (1 - targetPercent / 100);
    return allowed.floor();
  }
}

/// One observation snapshot over the SLO's window. Total events =
/// numerator + denominator combined; failures = numerator only.
/// The caller computes these from Sentry / PostHog / Firestore;
/// this helper only does the math.
class SloObservation {
  const SloObservation({
    required this.totalEvents,
    required this.failureEvents,
  });

  final int totalEvents;
  final int failureEvents;
}

/// Status bucket after evaluating an SLO against an observation.
///
/// Single-window evaluation — multi-window burn (e.g. 7d-fast vs
/// 28d-slow) is a follow-up PR. In a single window the math
/// collapses to 3 buckets: 0 - 50% burn → healthy, 50 - 100% →
/// warning, > 100% → breached. (A "budget-exhausted but not
/// breached" intermediate exists only at the exact mathematical
/// boundary, which IEEE 754 makes unstable in practice.)
enum SloStatus {
  /// Below 50% of error budget consumed.
  healthy,

  /// 50% – 100% of error budget consumed. Yellow chip on the
  /// dashboard; PR review extra-careful.
  warning,

  /// Actual failure ratio is at or above the allowed rate.
  /// Trigger the executive dashboard banner + the dpo brief.
  breached,
}

/// Pure evaluator — turns an observation into a status + the
/// numeric burn ratio the dashboard renders as a progress bar.
SloEvaluation evaluateSlo({
  required SloDefinition slo,
  required SloObservation observation,
}) {
  if (observation.totalEvents == 0) {
    return SloEvaluation(
      slo: slo,
      observation: observation,
      status: SloStatus.healthy,
      burnRatio: 0,
      actualSuccessPercent: 100,
    );
  }
  final actualSuccessPercent =
      100 *
      (observation.totalEvents - observation.failureEvents) /
      observation.totalEvents;
  final allowedFailureRatio = 1 - slo.targetPercent / 100;
  final actualFailureRatio =
      observation.failureEvents / observation.totalEvents;
  final burnRatio = allowedFailureRatio == 0
      ? (actualFailureRatio > 0 ? double.infinity : 0.0)
      : actualFailureRatio / allowedFailureRatio;

  final SloStatus status;
  if (burnRatio >= 1.0) {
    status = SloStatus.breached;
  } else if (burnRatio >= 0.5) {
    status = SloStatus.warning;
  } else {
    status = SloStatus.healthy;
  }

  return SloEvaluation(
    slo: slo,
    observation: observation,
    status: status,
    burnRatio: burnRatio,
    actualSuccessPercent: actualSuccessPercent,
  );
}

class SloEvaluation {
  const SloEvaluation({
    required this.slo,
    required this.observation,
    required this.status,
    required this.burnRatio,
    required this.actualSuccessPercent,
  });

  final SloDefinition slo;
  final SloObservation observation;
  final SloStatus status;

  /// 0.0 = no budget consumed, 1.0 = budget exhausted, >1.0 =
  /// breached. `double.infinity` when target is 100% and any
  /// failure exists.
  final double burnRatio;

  final double actualSuccessPercent;
}

/// Pinned catalog. Append-only; renaming an id forces every
/// downstream consumer (Sentry rule, dashboard route, trust page)
/// to update in lockstep.
class SloCatalog {
  const SloCatalog._();

  static const List<SloDefinition> entries = [
    SloDefinition(
      id: 'audit_log_mirror_success',
      name: 'Audit log mirror — success rate',
      indicator:
          'audit_log.mirror_success ÷ (audit_log.mirror_success + '
          'audit_log.mirror_failed) over 30d',
      targetPercent: 99.5,
      window: SloWindow.rolling30d,
      rationale:
          'HIPAA §164.316(b)(2)(i) 6-year retention requires every '
          'sealed audit row to land in the per-clinic Firestore '
          'mirror. 0.5% slack covers transient Firestore quota '
          'blips; anything more triggers an mirrorOutage incident.',
    ),
    SloDefinition(
      id: 'chain_tamper_zero',
      name: 'Audit chain tamper detections',
      indicator: 'audit_chain.tamper_detected events over 30d',
      targetPercent: 100,
      window: SloWindow.rolling30d,
      rationale:
          'Any tamper detection is a chain integrity breach; the '
          'target is zero events. A single hit triggers the '
          'chainTamper runbook (N3).',
    ),
    SloDefinition(
      id: 'dsar_export_30d_sla',
      name: 'DSAR 30-day SLA compliance',
      indicator:
          'DSAR requests completed within 30d ÷ total DSAR requests '
          'over 90d',
      targetPercent: 99,
      window: SloWindow.rolling90d,
      rationale:
          'GDPR Art. 12(3) + KVKK md. 13/2 set a 30-day response '
          'deadline. Missing even 1% is a contractual + regulatory '
          'breach risk.',
    ),
    SloDefinition(
      id: 'ai_service_availability',
      name: 'AI service availability',
      indicator:
          'Successful AI completion rate (per copilot/* service) '
          'over 7d',
      targetPercent: 99,
      window: SloWindow.rolling7d,
      rationale:
          'AI copilot outages do not block clinical care (clinician '
          'owns the decision) but burn user trust. 1% headroom '
          'absorbs Anthropic outages without alarming.',
    ),
    SloDefinition(
      id: 'breach_72h_compliance',
      name: 'Breach notification 72h compliance',
      indicator:
          'Breach incidents notified within 72h ÷ total notifiable '
          'breaches over 90d',
      targetPercent: 100,
      window: SloWindow.rolling90d,
      rationale:
          'GDPR Art. 33 + KVKK md. 12/5 set a 72h hard deadline; '
          'missing it converts the breach into a separately '
          'reportable failure of organisational measures.',
    ),
    SloDefinition(
      id: 'safety_plan_save_success',
      name: 'Safety plan save success rate',
      indicator: 'safety_plan.save_success ÷ safety_plan.save over 7d',
      targetPercent: 99.9,
      window: SloWindow.rolling7d,
      rationale:
          'A failed Stanley-Brown save during a CSSRS escalation '
          'is the worst case the app can produce — patient is in '
          'crisis and the plan does not persist. 0.1% slack only.',
    ),
  ];

  /// Look up by id. Returns null when unknown.
  static SloDefinition? byId(String id) {
    for (final s in entries) {
      if (s.id == id) return s;
    }
    return null;
  }
}
