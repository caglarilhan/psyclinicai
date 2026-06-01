/// Severity tiers for the incident-response runbook, plus the recovery
/// and communication targets each tier carries.
///
/// HIPAA Breach Notification Rule mandates a 60-day notification to
/// affected individuals; we target 72 hours so legal has buffer to
/// confirm the breach classification before the clock runs out.
library;

/// Operational severity. P0 is the highest — total outage or confirmed
/// PHI breach. P4 is informational and rarely surfaces to customers.
enum IncidentSeverity {
  p0,
  p1,
  p2,
  p3,
  p4;

  static IncidentSeverity fromId(String? id) {
    for (final s in IncidentSeverity.values) {
      if (s.name == id) return s;
    }
    return IncidentSeverity.p3;
  }
}

class IncidentTargets {
  const IncidentTargets({
    required this.severity,
    required this.rto,
    required this.rpo,
    required this.acknowledgeWithin,
    required this.customerNotifyWithin,
    required this.postMortemRequired,
  });

  final IncidentSeverity severity;

  /// Recovery Time Objective — how quickly service is restored.
  final Duration rto;

  /// Recovery Point Objective — maximum acceptable data loss measured in
  /// minutes.
  final Duration rpo;

  /// How fast the on-call must publicly acknowledge the incident (status
  /// page or in-product banner).
  final Duration acknowledgeWithin;

  /// Maximum delay before affected customers are notified. For PHI
  /// incidents this MUST be ≤ 72h to give legal buffer ahead of the
  /// 60-day HIPAA statutory deadline.
  final Duration customerNotifyWithin;

  /// Whether a written post-mortem is mandatory after recovery. P0/P1
  /// always require one; lower tiers only if customer-visible impact
  /// occurred.
  final bool postMortemRequired;
}

/// Canonical targets keyed by severity. Values are conservative — when a
/// tenant has a tighter SLA in their contract, that contract wins.
const Map<IncidentSeverity, IncidentTargets> incidentTargets = {
  IncidentSeverity.p0: IncidentTargets(
    severity: IncidentSeverity.p0,
    rto: Duration(hours: 1),
    rpo: Duration(minutes: 15),
    acknowledgeWithin: Duration(minutes: 15),
    customerNotifyWithin: Duration(hours: 4),
    postMortemRequired: true,
  ),
  IncidentSeverity.p1: IncidentTargets(
    severity: IncidentSeverity.p1,
    rto: Duration(hours: 4),
    rpo: Duration(minutes: 30),
    acknowledgeWithin: Duration(minutes: 30),
    customerNotifyWithin: Duration(hours: 24),
    postMortemRequired: true,
  ),
  IncidentSeverity.p2: IncidentTargets(
    severity: IncidentSeverity.p2,
    rto: Duration(hours: 8),
    rpo: Duration(hours: 1),
    acknowledgeWithin: Duration(hours: 1),
    customerNotifyWithin: Duration(hours: 48),
    postMortemRequired: false,
  ),
  IncidentSeverity.p3: IncidentTargets(
    severity: IncidentSeverity.p3,
    rto: Duration(days: 1),
    rpo: Duration(hours: 4),
    acknowledgeWithin: Duration(hours: 4),
    customerNotifyWithin: Duration(days: 5),
    postMortemRequired: false,
  ),
  IncidentSeverity.p4: IncidentTargets(
    severity: IncidentSeverity.p4,
    rto: Duration(days: 5),
    rpo: Duration(days: 1),
    acknowledgeWithin: Duration(days: 1),
    customerNotifyWithin: Duration(days: 14),
    postMortemRequired: false,
  ),
};

/// HIPAA Breach Notification Rule (45 CFR §164.404) — 60-day statutory
/// limit. Internal target is 72 h so legal has slack.
const Duration hipaaBreachStatutoryDeadline = Duration(days: 60);
const Duration hipaaBreachInternalTarget = Duration(hours: 72);

/// Returns the [IncidentTargets] for a severity. Defaults to P3 if the
/// severity is somehow missing from the table.
IncidentTargets targetsFor(IncidentSeverity severity) =>
    incidentTargets[severity] ??
    incidentTargets[IncidentSeverity.p3]!;

/// True when [elapsed] since the incident was opened still leaves enough
/// time to notify the customer within the SLA. Pass this to the banner
/// that nudges the on-call.
bool isWithinNotificationWindow(
  IncidentSeverity severity,
  Duration elapsed,
) {
  return elapsed < targetsFor(severity).customerNotifyWithin;
}
