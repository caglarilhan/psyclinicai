/// M4 — Public status-page component registry (pinned helper).
///
/// **Why this exists**: the status page at `psyclinicai.com/status`
/// shows customers which surfaces are healthy / degraded / down.
/// Today the page is rendered ad-hoc; this catalog pins:
///   1. Which components surface to the public (some internal pieces
///      stay invisible — the Sentry ingest pipeline does not need to
///      surface to a clinician).
///   2. Which vendor each component depends on
///      (`vendorSubprocessorId` parity with N6 vendor SLA catalog)
///      so a vendor outage auto-degrades the component.
///   3. Which SLO each component is graded against (parity with N1
///      slo_catalog) — the public uptime number is the SLO target,
///      not an arbitrary marketing number.
///
/// **Distinct from**:
///   * `incident_severity.dart` — internal P0..P4 the on-call uses.
///   * `incident_comms_templates.dart` (M2) — the COPY published on
///     the page; this catalog is the COMPONENT LIST the copy targets.
///
/// **Out of scope** (separate PRs):
///   * Status-page poster Cloud Function.
///   * Public widget that renders the registry + live state.
///   * Status-page-component dashboard for the on-call.
library;

/// Where the component sits in the customer mental model. Drives
/// grouping on the public page.
enum StatusComponentGroup {
  webApp,
  patientPortal,
  api,
  ragHub,
  authentication,
  payment,
  telehealth,
}

/// One pinned status-page component.
class StatusPageComponent {
  const StatusPageComponent({
    required this.id,
    required this.publicLabel,
    required this.group,
    required this.vendorSubprocessorId,
    required this.sloId,
    required this.publicHealthcheckUrl,
    required this.degradeOnVendorOutage,
  });

  /// Stable id used by the poster + dashboard.
  final String id;

  /// Customer-facing label on the status page. Plain English / TR.
  final String publicLabel;

  final StatusComponentGroup group;

  /// MUST match an id in `SubprocessorRegistry.entries` (N6 vendor
  /// SLA catalog mirrors it). Parity is pinned by the known-good
  /// vendor id set in tests — same approach as N11.
  final String vendorSubprocessorId;

  /// MUST match an id in `slo_catalog.dart` (N1). Parity pinned.
  final String sloId;

  /// Public URL probed every 60 seconds by the poster cron. Never
  /// embeds an API key — these are unauthenticated health endpoints.
  final String publicHealthcheckUrl;

  /// True when an upstream vendor outage should auto-degrade this
  /// component on the status page even if the local healthcheck
  /// still returns 200. False for components whose vendor outage
  /// has no customer impact (e.g. Sentry telemetry).
  final bool degradeOnVendorOutage;
}

class StatusPageComponentRegistry {
  const StatusPageComponentRegistry._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned public component list. Append-only.
  static const List<StatusPageComponent> components = [
    StatusPageComponent(
      id: 'web-app-flutter',
      publicLabel: 'Clinician web app',
      group: StatusComponentGroup.webApp,
      vendorSubprocessorId: 'firebase-auth',
      sloId: 'ai_service_availability',
      publicHealthcheckUrl: 'https://psyclinicai.web.app',
      degradeOnVendorOutage: true,
    ),
    StatusPageComponent(
      id: 'patient-portal-pwa',
      publicLabel: 'Patient portal (PWA)',
      group: StatusComponentGroup.patientPortal,
      vendorSubprocessorId: 'firebase-auth',
      sloId: 'ai_service_availability',
      publicHealthcheckUrl: 'https://psyclinicai.web.app/#/portal',
      degradeOnVendorOutage: true,
    ),
    StatusPageComponent(
      id: 'rag-hub-fastapi',
      publicLabel: 'Clinical RAG hub',
      group: StatusComponentGroup.ragHub,
      vendorSubprocessorId: 'hetzner',
      sloId: 'ai_service_availability',
      publicHealthcheckUrl: 'https://rag.psyclinicai.com/api/rag/health',
      degradeOnVendorOutage: true,
    ),
    StatusPageComponent(
      id: 'cloud-functions-api',
      publicLabel: 'Cloud Functions API',
      group: StatusComponentGroup.api,
      vendorSubprocessorId: 'firebase-auth',
      sloId: 'ai_service_availability',
      publicHealthcheckUrl: 'https://psyclinicai.web.app/__/health',
      degradeOnVendorOutage: true,
    ),
    StatusPageComponent(
      id: 'authentication-firebase',
      publicLabel: 'Sign-in',
      group: StatusComponentGroup.authentication,
      vendorSubprocessorId: 'firebase-auth',
      sloId: 'ai_service_availability',
      publicHealthcheckUrl: 'https://status.firebase.google.com',
      degradeOnVendorOutage: true,
    ),
    StatusPageComponent(
      id: 'payment-stripe',
      publicLabel: 'Billing + payment',
      group: StatusComponentGroup.payment,
      vendorSubprocessorId: 'stripe',
      sloId: 'ai_service_availability',
      publicHealthcheckUrl: 'https://status.stripe.com',
      degradeOnVendorOutage: true,
    ),
    StatusPageComponent(
      id: 'telehealth-daily',
      publicLabel: 'Telehealth video',
      group: StatusComponentGroup.telehealth,
      vendorSubprocessorId: 'daily-co',
      sloId: 'ai_service_availability',
      publicHealthcheckUrl: 'https://status.daily.co',
      degradeOnVendorOutage: true,
    ),
    StatusPageComponent(
      id: 'audit-log-mirror',
      publicLabel: 'Audit log mirror',
      group: StatusComponentGroup.api,
      vendorSubprocessorId: 'firebase-auth',
      sloId: 'audit_log_mirror_success',
      publicHealthcheckUrl: 'https://psyclinicai.web.app/__/audit/health',
      // Mirror failure is operational; we keep accepting writes via
      // the queue. Do not auto-degrade on Firebase outage.
      degradeOnVendorOutage: false,
    ),
  ];

  static StatusPageComponent? byId(String id) {
    for (final c in components) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<StatusPageComponent> byGroup(StatusComponentGroup group) {
    return components.where((c) => c.group == group).toList();
  }
}

/// Known-good vendor id set — mirrors `SubprocessorRegistry.entries`
/// (N6 vendor SLA catalog uses the same). Once both PRs are on main,
/// a follow-up wires this to import the registry directly.
const knownVendorIds = {
  'hetzner',
  'aws-ses',
  'cloudflare',
  'firebase-auth',
  'anthropic',
  'openai',
  'stripe',
  'sentry',
  'posthog',
  'daily-co',
  'twilio',
};

/// Known-good SLO id set — mirrors `SloCatalog.entries` (N1, PR #119).
const knownSloIds = {
  'audit_log_mirror_success',
  'chain_tamper_zero',
  'dsar_export_30d_sla',
  'ai_service_availability',
  'breach_72h_compliance',
  'safety_plan_save_success',
};
