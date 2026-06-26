/// N12 — Alerting policy catalog (pinned helper).
///
/// **Why this exists**: today alerts are emitted ad-hoc — Sentry
/// fires on any exception, Slack `#incidents` gets every webhook,
/// pager is reserved for the founder phone tree. Without a pinned
/// per-signal policy:
///   * Noise drowns out the signal (every 5xx pages the on-call).
///   * Suppression windows aren't documented, so the same incident
///     fires three times.
///   * A safety-critical signal can land in a low-priority channel.
///
/// This catalog pins per-signal: severity, target channel(s),
/// suppression window, who owns the response. Same shape as N7
/// access-review schedule and N11 DR drill schedule.
///
/// **Out of scope** (separate PRs):
///   * Alert router Cloud Function that picks the channel.
///   * PagerDuty / Slack webhook wire-up.
///   * Sentry alert rule generator that emits these as YAML.
library;

import '../../models/incident_severity.dart';

/// Where the alert lands.
enum AlertChannel {
  /// PagerDuty — wakes the on-call.
  pager,

  /// Slack #incidents — visible to the team.
  slack,

  /// Sentry issue — captured but not paged.
  sentry,

  /// Email to ops mailbox.
  email,
}

/// One pinned alert policy.
class AlertPolicyRecord {
  const AlertPolicyRecord({
    required this.id,
    required this.signalLabel,
    required this.severity,
    required this.channels,
    required this.suppressionMinutes,
    required this.responseOwner,
    required this.runbookId,
    required this.regulatoryRefs,
  });

  /// Stable id used by the router + the alert generator.
  final String id;

  /// Human-readable description of the signal that fires the alert.
  final String signalLabel;

  /// Mapped to the same P0..P4 vocabulary as incident_severity.dart.
  final IncidentSeverity severity;

  /// Where the alert lands. Multiple channels allowed; the first
  /// in the list is the primary, the rest are echoes.
  final List<AlertChannel> channels;

  /// Suppression window — how many minutes the router waits before
  /// firing the same signal again. Prevents stampede.
  final int suppressionMinutes;

  /// Single accountable owner. Routes to on-call for severity ≤
  /// p1, to a specific role for the rest.
  final String responseOwner;

  /// Stable id of the runbook the on-call follows (matches
  /// `on_call_runbook.dart` IncidentKind names — parity pinned).
  final String runbookId;

  final List<String> regulatoryRefs;
}

class AlertingPolicyCatalog {
  const AlertingPolicyCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policies. Append-only — deprecated rows stay so historic
  /// alert logs still resolve their policy.
  static const List<AlertPolicyRecord> policies = [
    AlertPolicyRecord(
      id: 'alert-chain-break',
      signalLabel: 'Audit chain integrity break detected',
      severity: IncidentSeverity.p0,
      channels: [AlertChannel.pager, AlertChannel.slack],
      suppressionMinutes: 0, // never suppress safety-critical
      responseOwner: 'on_call',
      runbookId: 'chainBreak',
      regulatoryRefs: [
        'HIPAA §164.316(b)(2)(i) audit retention',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
    AlertPolicyRecord(
      id: 'alert-breach-72h-window-opening',
      signalLabel: 'Breach notification 72h window opening',
      severity: IncidentSeverity.p0,
      channels: [AlertChannel.pager, AlertChannel.slack, AlertChannel.email],
      suppressionMinutes: 0,
      responseOwner: 'dpo',
      runbookId: 'breach',
      regulatoryRefs: [
        'GDPR Art. 33 supervisory authority notification',
        'HIPAA §164.410 breach reporting',
      ],
    ),
    AlertPolicyRecord(
      id: 'alert-ai-output-blocked',
      signalLabel: 'AI output guard blocked a clinical suggestion',
      severity: IncidentSeverity.p1,
      channels: [AlertChannel.slack, AlertChannel.sentry],
      suppressionMinutes: 15,
      responseOwner: 'clinical_advisor',
      runbookId: 'aiOutputBlock',
      regulatoryRefs: [
        'EU AI Act Art. 14 human oversight',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    AlertPolicyRecord(
      id: 'alert-dsar-overdue',
      signalLabel: 'DSAR request overdue (internal target breached)',
      severity: IncidentSeverity.p2,
      channels: [AlertChannel.slack, AlertChannel.email],
      suppressionMinutes: 60,
      responseOwner: 'dpo',
      runbookId: 'dsarOverdue',
      regulatoryRefs: ['GDPR Art. 12(3) one-month response', 'KVKK md. 13'],
    ),
    AlertPolicyRecord(
      id: 'alert-supply-chain-vuln',
      signalLabel: 'New high-severity CVE in pinned dependency',
      severity: IncidentSeverity.p2,
      channels: [AlertChannel.slack, AlertChannel.sentry],
      suppressionMinutes: 120,
      responseOwner: 'ciso',
      runbookId: 'supplyChain',
      regulatoryRefs: [
        'SOC 2 CC7.1 system operations',
        'NIST SP 800-53 SI-2 flaw remediation',
      ],
    ),
    AlertPolicyRecord(
      id: 'alert-ransomware-indicators',
      signalLabel: 'Ransomware indicators (mass file rewrites in cold store)',
      severity: IncidentSeverity.p0,
      channels: [AlertChannel.pager, AlertChannel.slack, AlertChannel.email],
      suppressionMinutes: 0,
      responseOwner: 'on_call',
      runbookId: 'ransomware',
      regulatoryRefs: ['HIPAA §164.308(a)(7) contingency plan', 'SOC 2 CC9.2'],
    ),
    AlertPolicyRecord(
      id: 'alert-vendor-status-degraded',
      signalLabel: 'Upstream vendor status page degraded',
      severity: IncidentSeverity.p2,
      channels: [AlertChannel.slack],
      suppressionMinutes: 30,
      responseOwner: 'on_call',
      // fallback runbook for unmapped third-party degradation.
      runbookId: 'aiOutputBlock',
      regulatoryRefs: ['SOC 2 CC9.2 vendor management'],
    ),
    AlertPolicyRecord(
      id: 'alert-error-rate-spike',
      signalLabel: 'Error rate > 5x baseline for 5 min',
      severity: IncidentSeverity.p1,
      channels: [AlertChannel.pager, AlertChannel.slack],
      suppressionMinutes: 15,
      responseOwner: 'on_call',
      // generic ops escalation — no specific incident-kind runbook.
      runbookId: 'aiOutputBlock',
      regulatoryRefs: ['SOC 2 CC7.2'],
    ),
  ];

  static AlertPolicyRecord? byId(String id) {
    for (final p in policies) {
      if (p.id == id) return p;
    }
    return null;
  }

  static List<AlertPolicyRecord> bySeverity(IncidentSeverity severity) {
    return policies.where((p) => p.severity == severity).toList();
  }
}

/// Known-good runbook id set — mirrors `on_call_runbook.dart`
/// IncidentKind values (N3, PR #118). Parity pinned in tests; once
/// N3 is on main a follow-up wires the import directly.
const knownRunbookIds = {
  'chainBreak',
  'dsarOverdue',
  'aiOutputBlock',
  'breach',
  'ransomware',
  'supplyChain',
};

/// True when the policy targets a wake-up channel (pager). Drives
/// the "did anyone get paged?" stat on the ops dashboard.
bool wakesOnCall(AlertPolicyRecord r) =>
    r.channels.contains(AlertChannel.pager);
