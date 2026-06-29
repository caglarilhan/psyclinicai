/// N25 — API rate limit policy catalog (pinned helper).
///
/// **Why this exists**: OWASP API Top-10 API4:2023 (unrestricted
/// resource consumption), PCI DSS v4.0 §6.5.10 (broken
/// authentication brute-force defense), and SOC 2 CC6.6 (boundary
/// protection) all require a documented rate-limit policy. The
/// LLM-backed copilot is also a cost-multiplier surface — one
/// runaway loop can hit a tenant's monthly budget in minutes. This
/// catalog pins per endpoint class the per-tenant rate ceiling +
/// burst allowance + window so the rate-limit middleware (out of
/// scope) has a single source of truth.
///
/// This catalog pins per endpoint class:
///   1. Stable class id + plain-English description.
///   2. Per-tenant requests-per-minute ceiling.
///   3. Burst allowance (token-bucket capacity above the steady-
///      state rate).
///   4. Whether the class is a brute-force-sensitive auth surface
///      (requires lockout-after-N policy alongside throttle).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `UsageBudgetCatalog` (L10) — finite LLM token budget per
///     tenant; N25 is per-request rate ceiling.
///   * `SecurityHeadersCatalog` (N24) — HTTP response hardening;
///     N25 is HTTP request throttle.
///   * `PentestScopeCatalog` (N21) — pen test scope; N25 is the
///     runtime defense that the pen tester will try to bypass.
///
/// **Out of scope** (separate PRs):
///   * Rate-limit middleware implementation (Cloud Functions
///     interceptor + client back-off).
///   * Per-tenant overage billing policy.
///   * Adaptive throttle (auto-tightening on attack signal).
library;

/// API endpoint class.
enum ApiEndpointClass {
  /// Authentication endpoints (login, MFA verify, password reset).
  /// Brute-force sensitive — pin tight + pair with lockout.
  authLogin,

  /// Public unauthenticated endpoints (signup, marketing form,
  /// status page).
  publicUnauthenticated,

  /// Read-heavy clinician dashboard endpoints (chart load,
  /// schedule fetch).
  clinicianDashboardRead,

  /// AI copilot inference endpoints (LLM-backed draft, treatment
  /// plan, summary).
  aiCopilotInference,

  /// DSAR + portal endpoints (data-subject-rights request fetch,
  /// portal status check).
  portalDsar,

  /// Internal cross-tenant admin readonly (O8 platform-admin-
  /// readonly).
  internalAdmin,

  /// Webhook ingestion (Stripe, EHR connector).
  webhookIngestion,
}

class ApiRateLimitRecord {
  const ApiRateLimitRecord({
    required this.id,
    required this.endpointClass,
    required this.description,
    required this.perTenantRequestsPerMinute,
    required this.burstAllowance,
    required this.bruteForceSensitive,
    required this.regulatoryRefs,
  });

  final String id;
  final ApiEndpointClass endpointClass;
  final String description;

  /// Steady-state per-tenant requests/min ceiling. Test pins
  /// monotonic ladder (auth tightest, webhook loosest).
  final int perTenantRequestsPerMinute;

  /// Token-bucket capacity above the steady-state. 0 = strict.
  final int burstAllowance;

  /// True when the endpoint class requires lockout-after-N (in
  /// addition to throttle) due to brute-force sensitivity (e.g.
  /// auth, MFA verify).
  final bool bruteForceSensitive;

  final List<String> regulatoryRefs;
}

class ApiRateLimitCatalog {
  const ApiRateLimitCatalog._();

  /// YYYY-MM stamp — drives the security "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned rate limit table. Append-only.
  static const List<ApiRateLimitRecord> records = [
    ApiRateLimitRecord(
      id: 'auth-login',
      endpointClass: ApiEndpointClass.authLogin,
      description:
          'Login + MFA verify + password reset. Brute-force sensitive — pair throttle with lockout-after-5 failures (account or IP).',
      perTenantRequestsPerMinute: 10,
      burstAllowance: 0,
      bruteForceSensitive: true,
      regulatoryRefs: [
        'OWASP API Top-10 API4:2023 unrestricted resource consumption',
        'OWASP API Top-10 API2:2023 broken authentication',
        'PCI DSS v4.0 §6.5.10 broken authentication',
        'NIST SP 800-63B §5.2.2 rate-limiting authenticators',
        'HIPAA §164.308(a)(5)(ii)(C) log-in monitoring',
      ],
    ),
    ApiRateLimitRecord(
      id: 'public-unauthenticated',
      endpointClass: ApiEndpointClass.publicUnauthenticated,
      description:
          'Signup form, marketing form, status page. Coarse throttle to defeat scraping + form-spam.',
      perTenantRequestsPerMinute: 60,
      burstAllowance: 30,
      bruteForceSensitive: false,
      regulatoryRefs: [
        'OWASP API Top-10 API4:2023',
        'SOC 2 CC6.6 boundary protection',
      ],
    ),
    ApiRateLimitRecord(
      id: 'clinician-dashboard-read',
      endpointClass: ApiEndpointClass.clinicianDashboardRead,
      description:
          'Read-heavy chart + schedule + lists endpoints. Loose to support real-time use; cache + ETag relieve load.',
      perTenantRequestsPerMinute: 600,
      burstAllowance: 300,
      bruteForceSensitive: false,
      regulatoryRefs: [
        'OWASP API Top-10 API4:2023',
        'SOC 2 A1.1 availability commitments',
      ],
    ),
    ApiRateLimitRecord(
      id: 'ai-copilot-inference',
      endpointClass: ApiEndpointClass.aiCopilotInference,
      description:
          'LLM-backed copilot. Tight per-minute throttle independent of L10 monthly token budget — prevents runaway loops from burning the budget in minutes.',
      perTenantRequestsPerMinute: 30,
      burstAllowance: 10,
      bruteForceSensitive: false,
      regulatoryRefs: [
        'OWASP API Top-10 API4:2023',
        'EU AI Act Art. 14 human oversight',
        'SOC 2 CC6.6 boundary protection',
      ],
    ),
    ApiRateLimitRecord(
      id: 'portal-dsar',
      endpointClass: ApiEndpointClass.portalDsar,
      description:
          'DSAR portal endpoints. Throttle prevents enumeration scraping; deadline policy (K17) handles legitimate queue.',
      perTenantRequestsPerMinute: 20,
      burstAllowance: 5,
      bruteForceSensitive: false,
      regulatoryRefs: [
        'GDPR Art. 12(5)(b) manifestly unfounded refusal',
        'OWASP API Top-10 API4:2023',
      ],
    ),
    ApiRateLimitRecord(
      id: 'internal-admin',
      endpointClass: ApiEndpointClass.internalAdmin,
      description:
          'Cross-tenant readonly admin (O8 platform-admin-readonly). Looser cap because legitimate admin work spans many tenants in short windows; pair with AAL3 (N23).',
      perTenantRequestsPerMinute: 300,
      burstAllowance: 100,
      bruteForceSensitive: false,
      regulatoryRefs: [
        'SOC 2 CC6.3 access change management',
        'HIPAA §164.308(a)(4) information access management',
        'OWASP API Top-10 API4:2023',
      ],
    ),
    ApiRateLimitRecord(
      id: 'webhook-ingestion',
      endpointClass: ApiEndpointClass.webhookIngestion,
      description:
          'Inbound webhook (Stripe, EHR connector). Throttle high to absorb bursts; signature verify (Stripe webhook secret) handles authenticity.',
      perTenantRequestsPerMinute: 600,
      burstAllowance: 600,
      bruteForceSensitive: false,
      regulatoryRefs: [
        'OWASP API Top-10 API4:2023',
        'PCI DSS v4.0 §6.5.4 broken authentication',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
  ];

  static ApiRateLimitRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static ApiRateLimitRecord? byEndpointClass(ApiEndpointClass c) {
    for (final r in records) {
      if (r.endpointClass == c) return r;
    }
    return null;
  }
}

/// True when the endpoint class requires lockout-after-N alongside
/// the throttle (brute-force-sensitive surface).
bool requiresBruteForceLockout(ApiEndpointClass c) {
  final r = ApiRateLimitCatalog.byEndpointClass(c);
  return r?.bruteForceSensitive ?? false;
}
