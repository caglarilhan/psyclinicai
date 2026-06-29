/// M3 — Customer support escalation matrix (pinned helper).
///
/// **Why this exists**: every paying tier carries a different response
/// SLA + escalation path. Today these promises live in scattered
/// places (pilot agreement, sales deck, support-team Slack). Pinning
/// them here means:
///   1. Sales decks + the pricing page + customer DPA all render the
///      same numbers (tests pin parity).
///   2. The support dashboard can route an incoming ticket to the
///      right SLA timer without hard-coding the tier mapping.
///   3. A breach of SLA fires the right escalation step automatically
///      (Zendesk integration ships in a follow-up PR).
///
/// **Distinct from `incident_severity.dart`**: that file defines the
/// operational P0..P4 the on-call uses internally. This file defines
/// the *customer-facing* response promise per support tier
/// (free / pilot / enterprise) per ticket severity.
///
/// **Distinct from the clinical-risk escalation chain**: the files
/// in `lib/services/assessments/*escalation*` deal with patient
/// suicide risk; this file deals with customer support tickets.
///
/// **Out of scope** (separate PRs):
///   * Zendesk webhook that auto-routes tickets by tier.
///   * Support-dashboard widget that renders the matrix.
///   * Sales deck + pricing page wire-up.
library;

/// Support tier the customer is on. Tiers are billing tiers, not
/// usage tiers — a free user on a paid trial still maps to `free`
/// until billing activates.
enum SupportTier { free, pilot, enterprise }

/// Severity the customer assigns to their ticket. Maps roughly to
/// `incident_severity.dart` but lives in the customer's vocabulary
/// (urgent / high / normal / low).
enum TicketSeverity { urgent, high, normal, low }

/// One promise the contract makes for a (tier × severity) pair.
class SupportSla {
  const SupportSla({
    required this.tier,
    required this.severity,
    required this.firstResponseHours,
    required this.resolutionTargetHours,
    required this.afterHoursCoverage,
    required this.escalationOwner,
    required this.contactChannel,
  });

  final SupportTier tier;
  final TicketSeverity severity;

  /// Max hours between ticket creation + a human reply. The clock
  /// starts at the ticket's `created_at` regardless of timezone.
  final int firstResponseHours;

  /// Target hours to a working fix or a documented workaround. Not
  /// a guarantee — only a target the dashboard reports against.
  final int resolutionTargetHours;

  /// True when the SLA clock ticks 24/7 (no pause for weekends or
  /// out-of-hours). Enterprise urgent + high are 24/7; free is
  /// always business-hours only.
  final bool afterHoursCoverage;

  /// Whoever owns the escalation if the first-response SLA breaches.
  /// Single accountable role per cell.
  final String escalationOwner;

  /// Where the customer files the ticket / where we reply.
  /// `email` | `support_portal` | `shared_slack` | `pager` |
  /// `customer_specific_channel`.
  final String contactChannel;
}

class SupportEscalationMatrix {
  const SupportEscalationMatrix._();

  /// YYYY-MM stamp — drives the trust-page "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned matrix. Order: free → pilot → enterprise, each with
  /// urgent → low. Append-only. 12 entries total
  /// (3 tiers × 4 severities).
  static const List<SupportSla> entries = [
    // ────────── FREE ──────────
    SupportSla(
      tier: SupportTier.free,
      severity: TicketSeverity.urgent,
      firstResponseHours: 48,
      resolutionTargetHours: 168,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'support_portal',
    ),
    SupportSla(
      tier: SupportTier.free,
      severity: TicketSeverity.high,
      firstResponseHours: 72,
      resolutionTargetHours: 336,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'support_portal',
    ),
    SupportSla(
      tier: SupportTier.free,
      severity: TicketSeverity.normal,
      firstResponseHours: 120,
      resolutionTargetHours: 720,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'support_portal',
    ),
    SupportSla(
      tier: SupportTier.free,
      severity: TicketSeverity.low,
      firstResponseHours: 168,
      resolutionTargetHours: 720,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'support_portal',
    ),
    // ────────── PILOT ──────────
    SupportSla(
      tier: SupportTier.pilot,
      severity: TicketSeverity.urgent,
      firstResponseHours: 4,
      resolutionTargetHours: 24,
      afterHoursCoverage: true,
      escalationOwner: 'on_call',
      contactChannel: 'shared_slack',
    ),
    SupportSla(
      tier: SupportTier.pilot,
      severity: TicketSeverity.high,
      firstResponseHours: 8,
      resolutionTargetHours: 48,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'shared_slack',
    ),
    SupportSla(
      tier: SupportTier.pilot,
      severity: TicketSeverity.normal,
      firstResponseHours: 24,
      resolutionTargetHours: 120,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'email',
    ),
    SupportSla(
      tier: SupportTier.pilot,
      severity: TicketSeverity.low,
      firstResponseHours: 48,
      resolutionTargetHours: 240,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'email',
    ),
    // ────────── ENTERPRISE ──────────
    SupportSla(
      tier: SupportTier.enterprise,
      severity: TicketSeverity.urgent,
      firstResponseHours: 1,
      resolutionTargetHours: 8,
      afterHoursCoverage: true,
      escalationOwner: 'on_call',
      contactChannel: 'pager',
    ),
    SupportSla(
      tier: SupportTier.enterprise,
      severity: TicketSeverity.high,
      firstResponseHours: 4,
      resolutionTargetHours: 24,
      afterHoursCoverage: true,
      escalationOwner: 'on_call',
      contactChannel: 'customer_specific_channel',
    ),
    SupportSla(
      tier: SupportTier.enterprise,
      severity: TicketSeverity.normal,
      firstResponseHours: 8,
      resolutionTargetHours: 72,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'customer_specific_channel',
    ),
    SupportSla(
      tier: SupportTier.enterprise,
      severity: TicketSeverity.low,
      firstResponseHours: 24,
      resolutionTargetHours: 168,
      afterHoursCoverage: false,
      escalationOwner: 'customer_success',
      contactChannel: 'customer_specific_channel',
    ),
  ];

  /// Resolve the SLA promise for a (tier, severity) pair. Throws
  /// `StateError` if no entry is pinned — the matrix MUST be
  /// complete (12 entries = 3 tiers × 4 severities).
  static SupportSla forTierAndSeverity(
    SupportTier tier,
    TicketSeverity severity,
  ) {
    for (final e in entries) {
      if (e.tier == tier && e.severity == severity) return e;
    }
    throw StateError(
      'No SupportSla pinned for ${tier.name}/${severity.name} — every '
      '(tier × severity) pair MUST have a row.',
    );
  }
}

/// True when the [sla.firstResponseHours] window has already
/// elapsed for a ticket opened at [openedAt] and viewed at [now].
/// Drives the support dashboard's "breach imminent" banner.
bool isFirstResponseBreached({
  required SupportSla sla,
  required DateTime openedAt,
  required DateTime now,
}) {
  final elapsedHours = now.difference(openedAt).inMinutes / 60;
  return elapsedHours > sla.firstResponseHours;
}
