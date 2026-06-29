/// M6 — Status-page audience tier catalog (pinned helper).
///
/// **Why this exists**: `IncidentSeverity` (P0..P4) pins the
/// severity ladder + recovery/comm targets. But who gets notified
/// in which channel at each severity is policy, not implementation.
/// HIPAA §164.404 breach notification (60-day clock), ISO 27001
/// A.16.1.5 (response to information security incidents) and SOC 2
/// CC2.3 (communication of objectives) all require a documented
/// notification matrix. This catalog pins per severity tier: which
/// audience cohorts are notified, through which channels, with
/// which max latency, and whether a regulator-facing breach
/// notification is required.
///
/// This catalog pins per severity tier:
///   1. Tier id + severity it maps to (P0..P4).
///   2. Audience cohorts notified (statusPageSubscribers /
///      affectedTenantAdmins / internalOncall / regulator).
///   3. Channels used (in-app banner / email / SMS / status-page
///      component / regulator notification).
///   4. Max notification latency in minutes from incident
///      declaration.
///   5. Whether regulator breach notification is required (HIPAA
///      §164.404 / GDPR Art. 33).
///   6. Regulatory anchor.
///
/// **Distinct from**:
///   * `IncidentSeverity` model — defines the P0..P4 ladder + RTO/
///     RPO targets; M6 pins WHO gets told + HOW + HOW FAST.
///   * `TenantIsolationPolicyCatalog` (O8) — governs in-process
///     per-tenant data routing; M6 is incident-time notification.
///   * `EnvironmentInventory` — names environments; M6 is severity
///     tier × audience matrix.
///
/// **Out of scope** (separate PRs):
///   * Status-page renderer.
///   * Notifier implementation + delivery retries.
///   * Per-region regulator-routing override.
library;

import '../../models/incident_severity.dart';

/// Audience cohorts that may be notified during an incident.
enum NotificationAudience {
  /// Public status-page subscribers (web + RSS).
  statusPageSubscribers,

  /// Tenant admins of affected tenants (in-app + email).
  affectedTenantAdmins,

  /// Internal oncall + incident commander (PagerDuty + Slack).
  internalOncall,

  /// Regulator-facing notification (HIPAA Secretary, lead
  /// supervisory authority under GDPR Art. 33).
  regulator,
}

/// Delivery channels.
enum NotificationChannel {
  /// In-app banner inside the platform UI.
  inAppBanner,

  /// Email to known recipients.
  email,

  /// SMS to admin + oncall numbers.
  sms,

  /// Status-page component update (operational / degraded / outage).
  statusPageComponent,

  /// Formal regulator notification (HIPAA Secretary form, GDPR
  /// 72-hour Art. 33 notice).
  regulatorNotification,
}

class AudienceTierRecord {
  const AudienceTierRecord({
    required this.id,
    required this.severity,
    required this.audiences,
    required this.channels,
    required this.maxLatencyMinutes,
    required this.regulatorBreachNotification,
    required this.regulatoryRefs,
  });

  final String id;
  final IncidentSeverity severity;
  final List<NotificationAudience> audiences;
  final List<NotificationChannel> channels;

  /// Max minutes from incident declaration to first notification.
  /// Tests pin the ladder (P0 fastest, P4 slowest).
  final int maxLatencyMinutes;

  /// True when the tier requires regulator-facing breach
  /// notification per HIPAA §164.404 / GDPR Art. 33.
  final bool regulatorBreachNotification;

  final List<String> regulatoryRefs;
}

class StatusPageAudienceTierCatalog {
  const StatusPageAudienceTierCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned tier table. Append-only.
  static const List<AudienceTierRecord> records = [
    AudienceTierRecord(
      id: 'tier-p0',
      severity: IncidentSeverity.p0,
      audiences: [
        NotificationAudience.internalOncall,
        NotificationAudience.affectedTenantAdmins,
        NotificationAudience.statusPageSubscribers,
        NotificationAudience.regulator,
      ],
      channels: [
        NotificationChannel.inAppBanner,
        NotificationChannel.email,
        NotificationChannel.sms,
        NotificationChannel.statusPageComponent,
        NotificationChannel.regulatorNotification,
      ],
      maxLatencyMinutes: 15,
      regulatorBreachNotification: true,
      regulatoryRefs: [
        'HIPAA §164.404 breach notification to individuals',
        'HIPAA §164.408 breach notification to Secretary',
        'GDPR Art. 33 supervisory authority within 72h',
        'GDPR Art. 34 communication to data subject',
        'ISO 27001 A.16.1.5 response to incidents',
        'SOC 2 CC2.3 communication of objectives',
      ],
    ),
    AudienceTierRecord(
      id: 'tier-p1',
      severity: IncidentSeverity.p1,
      audiences: [
        NotificationAudience.internalOncall,
        NotificationAudience.affectedTenantAdmins,
        NotificationAudience.statusPageSubscribers,
      ],
      channels: [
        NotificationChannel.inAppBanner,
        NotificationChannel.email,
        NotificationChannel.statusPageComponent,
      ],
      maxLatencyMinutes: 30,
      regulatorBreachNotification: false,
      regulatoryRefs: [
        'ISO 27001 A.16.1.5 response to incidents',
        'SOC 2 CC2.3 communication of objectives',
        'SOC 2 CC7.4 incident response',
      ],
    ),
    AudienceTierRecord(
      id: 'tier-p2',
      severity: IncidentSeverity.p2,
      audiences: [
        NotificationAudience.internalOncall,
        NotificationAudience.affectedTenantAdmins,
      ],
      channels: [
        NotificationChannel.inAppBanner,
        NotificationChannel.statusPageComponent,
      ],
      maxLatencyMinutes: 60,
      regulatorBreachNotification: false,
      regulatoryRefs: [
        'ISO 27001 A.16.1.5 response to incidents',
        'SOC 2 CC7.4 incident response',
      ],
    ),
    AudienceTierRecord(
      id: 'tier-p3',
      severity: IncidentSeverity.p3,
      audiences: [NotificationAudience.internalOncall],
      channels: [NotificationChannel.inAppBanner],
      maxLatencyMinutes: 120,
      regulatorBreachNotification: false,
      regulatoryRefs: [
        'SOC 2 CC7.2 system monitoring',
        'ISO 27001 A.12.4.1 event logging',
      ],
    ),
    AudienceTierRecord(
      id: 'tier-p4',
      severity: IncidentSeverity.p4,
      audiences: [NotificationAudience.internalOncall],
      channels: [],
      maxLatencyMinutes: 1440,
      regulatorBreachNotification: false,
      regulatoryRefs: [
        'SOC 2 CC7.2 system monitoring',
        'ISO 27001 A.12.4.1 event logging',
      ],
    ),
  ];

  static AudienceTierRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static AudienceTierRecord? bySeverity(IncidentSeverity s) {
    for (final r in records) {
      if (r.severity == s) return r;
    }
    return null;
  }
}

/// True when the severity tier requires a regulator-facing breach
/// notification. Drives the incident commander checklist.
bool requiresRegulatorNotification(IncidentSeverity s) {
  final r = StatusPageAudienceTierCatalog.bySeverity(s);
  return r?.regulatorBreachNotification ?? false;
}
