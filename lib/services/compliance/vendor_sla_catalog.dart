/// N6 — Vendor SLA + outage credit catalog (pinned helper).
///
/// **Why this exists**: every sub-processor in `subprocessor_registry`
/// carries a contractual uptime promise + an outage-credit policy.
/// Auditors (SOC 2 CC9.2 vendor risk) + the trust-center uptime
/// ribbon + the procurement questionnaire all need the same numbers.
/// Pinning them here:
///   1. Forces parity with the subprocessor registry — a new vendor
///      cannot ship without its SLA row + the test failing.
///   2. Renders the same numbers everywhere (trust page, DPA, CISO
///      questionnaire).
///   3. Lets a Cloud Function compare measured uptime against the
///      promised number to decide when to file an outage credit.
///
/// **Out of scope** (separate PRs):
///   * Cloud Function that polls vendor status pages.
///   * Trust-center widget rendering the uptime ribbon.
///   * Outage-credit submission helper (per-vendor portal flow).
library;

/// Whether the vendor's contract grants outage credit + on what
/// shape.
enum OutageCreditPolicy {
  /// Service credits granted automatically per the vendor's SLA
  /// (Google Cloud, AWS).
  automatic,

  /// Credits must be requested in writing within a window (Stripe,
  /// Cloudflare, Sentry).
  requestWithinWindow,

  /// No contractual credit. Notification + post-mortem only.
  notificationOnly,
}

/// One pinned vendor SLA record.
class VendorSlaRecord {
  const VendorSlaRecord({
    required this.subprocessorId,
    required this.slaPercentString,
    required this.slaPercent,
    required this.measurementWindowDays,
    required this.statusUrl,
    required this.notificationSlaHours,
    required this.outageCreditPolicy,
    required this.outageCreditRequestWindowDays,
    required this.slaDocUrl,
  });

  /// MUST match an id in
  /// `lib/services/compliance/subprocessor_registry.dart`. Parity is
  /// pinned by a test.
  final String subprocessorId;

  /// Human-readable percentage shown on the trust page. E.g. "99.95%".
  /// Kept as a string so the rendering layer doesn't lose precision
  /// on values like "99.999%".
  final String slaPercentString;

  /// Numeric form for math. Range [0.0, 1.0]. E.g. 0.9995 for 99.95.
  final double slaPercent;

  /// Window the vendor measures the SLA against. Monthly = 30 by
  /// convention.
  final int measurementWindowDays;

  /// Vendor's status page (where we read live state).
  final String statusUrl;

  /// How fast the vendor's contract says they will notify us of an
  /// outage. We track this so the on-call knows when to escalate
  /// to the vendor's support channel for missing notifications.
  final int notificationSlaHours;

  final OutageCreditPolicy outageCreditPolicy;

  /// For `requestWithinWindow`, how many days from the incident we
  /// have to file the credit request. 0 for the other policies.
  final int outageCreditRequestWindowDays;

  /// URL of the vendor's published SLA document — auditors follow
  /// this verbatim.
  final String slaDocUrl;
}

class VendorSlaCatalog {
  const VendorSlaCatalog._();

  /// YYYY-MM stamp — drives the trust-page "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned catalog. Order mirrors `SubprocessorRegistry.entries`.
  /// Append-only; deprecated rows stay so historic uptime reports
  /// still resolve.
  static const List<VendorSlaRecord> entries = [
    VendorSlaRecord(
      subprocessorId: 'hetzner',
      slaPercentString: '99.9%',
      slaPercent: 0.999,
      measurementWindowDays: 30,
      statusUrl: 'https://status.hetzner.com',
      notificationSlaHours: 1,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 30,
      slaDocUrl: 'https://www.hetzner.com/legal/terms-and-conditions/',
    ),
    VendorSlaRecord(
      subprocessorId: 'aws-ses',
      slaPercentString: '99.9%',
      slaPercent: 0.999,
      measurementWindowDays: 30,
      statusUrl: 'https://health.aws.amazon.com/health/status',
      notificationSlaHours: 1,
      outageCreditPolicy: OutageCreditPolicy.automatic,
      outageCreditRequestWindowDays: 0,
      slaDocUrl: 'https://aws.amazon.com/messaging/sla/',
    ),
    VendorSlaRecord(
      subprocessorId: 'cloudflare',
      slaPercentString: '100% (Enterprise) / 99.9% (Pro)',
      slaPercent: 0.999,
      measurementWindowDays: 30,
      statusUrl: 'https://www.cloudflarestatus.com',
      notificationSlaHours: 1,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 30,
      slaDocUrl: 'https://www.cloudflare.com/business-sla/',
    ),
    VendorSlaRecord(
      subprocessorId: 'firebase-auth',
      slaPercentString: '99.95%',
      slaPercent: 0.9995,
      measurementWindowDays: 30,
      statusUrl: 'https://status.firebase.google.com',
      notificationSlaHours: 1,
      outageCreditPolicy: OutageCreditPolicy.automatic,
      outageCreditRequestWindowDays: 0,
      slaDocUrl: 'https://firebase.google.com/terms/service-level-agreement',
    ),
    VendorSlaRecord(
      subprocessorId: 'anthropic',
      slaPercentString: '99.5%',
      slaPercent: 0.995,
      measurementWindowDays: 30,
      statusUrl: 'https://status.anthropic.com',
      notificationSlaHours: 4,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 30,
      slaDocUrl: 'https://www.anthropic.com/legal/commercial-terms',
    ),
    VendorSlaRecord(
      subprocessorId: 'openai',
      slaPercentString: '99.9% (Enterprise)',
      slaPercent: 0.999,
      measurementWindowDays: 30,
      statusUrl: 'https://status.openai.com',
      notificationSlaHours: 4,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 30,
      slaDocUrl: 'https://openai.com/policies/enterprise-privacy',
    ),
    VendorSlaRecord(
      subprocessorId: 'stripe',
      slaPercentString: '99.99%',
      slaPercent: 0.9999,
      measurementWindowDays: 30,
      statusUrl: 'https://status.stripe.com',
      notificationSlaHours: 1,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 60,
      slaDocUrl: 'https://stripe.com/legal/ssa',
    ),
    VendorSlaRecord(
      subprocessorId: 'sentry',
      slaPercentString: '99.95% (Business)',
      slaPercent: 0.9995,
      measurementWindowDays: 30,
      statusUrl: 'https://status.sentry.io',
      notificationSlaHours: 4,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 30,
      slaDocUrl: 'https://sentry.io/legal/terms/',
    ),
    VendorSlaRecord(
      subprocessorId: 'posthog',
      slaPercentString: '99.5%',
      slaPercent: 0.995,
      measurementWindowDays: 30,
      statusUrl: 'https://status.posthog.com',
      notificationSlaHours: 8,
      outageCreditPolicy: OutageCreditPolicy.notificationOnly,
      outageCreditRequestWindowDays: 0,
      slaDocUrl: 'https://posthog.com/terms',
    ),
    VendorSlaRecord(
      subprocessorId: 'daily-co',
      slaPercentString: '99.95%',
      slaPercent: 0.9995,
      measurementWindowDays: 30,
      statusUrl: 'https://status.daily.co',
      notificationSlaHours: 1,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 30,
      slaDocUrl: 'https://www.daily.co/legal/sla/',
    ),
    VendorSlaRecord(
      subprocessorId: 'twilio',
      slaPercentString: '99.95%',
      slaPercent: 0.9995,
      measurementWindowDays: 30,
      statusUrl: 'https://status.twilio.com',
      notificationSlaHours: 1,
      outageCreditPolicy: OutageCreditPolicy.requestWithinWindow,
      outageCreditRequestWindowDays: 30,
      slaDocUrl: 'https://www.twilio.com/legal/service-level-agreement',
    ),
  ];

  static VendorSlaRecord? bySubprocessorId(String id) {
    for (final r in entries) {
      if (r.subprocessorId == id) return r;
    }
    return null;
  }
}

/// Max downtime in minutes the vendor's SLA tolerates over its
/// measurement window before a credit becomes claimable. Tests pin
/// the arithmetic so an SLA edit can't silently bump the budget.
int allowedDowntimeMinutes(VendorSlaRecord r) {
  final totalMinutes = r.measurementWindowDays * 24 * 60;
  return (totalMinutes * (1 - r.slaPercent)).round();
}
