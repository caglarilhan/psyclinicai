/// N27 — CORS allowed-origin policy catalog (pinned helper).
///
/// **Why this exists**: A permissive `Access-Control-Allow-Origin:
/// *` defeats the same-origin policy and lets any site read PHI
/// from authenticated XHR. OWASP API Top-10 API8:2023 (security
/// misconfiguration) + OWASP ASVS V13.2.5 + W3C Fetch CORS spec
/// require an explicit per-environment allowlist. Cloud Functions
/// CORS middleware reads from this catalog so a typo in an env
/// config can't widen the allowlist.
///
/// This catalog pins per origin entry:
///   1. Stable id + plain description.
///   2. Origin URL (scheme + host + port, no path).
///   3. Which deployment slots accept it (local/preview/staging/
///      production).
///   4. Whether credentials are allowed (Cookie / Authorization).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `SecurityHeadersCatalog` (N24) — response-side hardening;
///     N27 is request-side cross-origin allowlist.
///   * `RequiredEnvVarCatalog` (O9) — env var presence; N27 is
///     origin-allowlist per env.
///   * `SubresourceIntegrityCatalog` (N26) — outbound asset
///     integrity; N27 is inbound origin gate.
///
/// **Out of scope** (separate PRs):
///   * CORS middleware implementation.
///   * Per-route Access-Control-Allow-Methods narrowing.
///   * Preflight cache TTL tuning.
library;

/// Deployment slot — matches O9 `DeploymentSlot`.
enum CorsDeploymentSlot { local, preview, staging, production }

class CorsAllowedOriginRecord {
  const CorsAllowedOriginRecord({
    required this.id,
    required this.origin,
    required this.description,
    required this.allowedSlots,
    required this.allowCredentials,
    required this.regulatoryRefs,
  });

  final String id;

  /// Origin in canonical form: scheme + host + optional port.
  /// No trailing slash, no path. Tests pin the format.
  final String origin;

  final String description;

  final List<CorsDeploymentSlot> allowedSlots;

  /// True when the origin may send Cookie/Authorization (CORS
  /// `Access-Control-Allow-Credentials: true`). Reserved for
  /// authenticated app surfaces.
  final bool allowCredentials;

  final List<String> regulatoryRefs;
}

class CorsAllowedOriginCatalog {
  const CorsAllowedOriginCatalog._();

  /// YYYY-MM stamp — drives the security "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned allowlist. Append-only.
  static const List<CorsAllowedOriginRecord> records = [
    CorsAllowedOriginRecord(
      id: 'production-app',
      origin: 'https://app.psyclinicai.com',
      description:
          'Production Flutter web app — authenticated clinician + patient surfaces. Credentials required.',
      allowedSlots: [CorsDeploymentSlot.production],
      allowCredentials: true,
      regulatoryRefs: [
        'OWASP API Top-10 API8:2023 security misconfiguration',
        'OWASP ASVS V13.2.5',
        'W3C Fetch CORS Living Standard',
        'HIPAA §164.312(a)(1) access control',
      ],
    ),
    CorsAllowedOriginRecord(
      id: 'production-marketing',
      origin: 'https://www.psyclinicai.com',
      description:
          'Production marketing site — unauthenticated lead forms. Credentials NOT allowed (no auth surface).',
      allowedSlots: [CorsDeploymentSlot.production],
      allowCredentials: false,
      regulatoryRefs: [
        'OWASP API Top-10 API8:2023',
        'GDPR Art. 25 privacy by default',
      ],
    ),
    CorsAllowedOriginRecord(
      id: 'staging-app',
      origin: 'https://staging.psyclinicai.com',
      description:
          'Staging Flutter web — internal QA only. Credentials allowed for full auth-flow testing.',
      allowedSlots: [CorsDeploymentSlot.staging],
      allowCredentials: true,
      regulatoryRefs: [
        'OWASP API Top-10 API8:2023',
        'SOC 2 CC8.1 change management',
      ],
    ),
    CorsAllowedOriginRecord(
      id: 'preview-app',
      origin: 'https://preview.psyclinicai.com',
      description:
          'CI preview deploy — per-PR ephemeral build. Credentials allowed for end-to-end test fixtures only.',
      allowedSlots: [CorsDeploymentSlot.preview],
      allowCredentials: true,
      regulatoryRefs: ['OWASP API Top-10 API8:2023', 'SOC 2 CC8.1'],
    ),
    CorsAllowedOriginRecord(
      id: 'local-dev',
      origin: 'http://localhost:8080',
      description:
          'Local developer workstation. Plain HTTP allowed ONLY because localhost is exempt from secure-context requirements.',
      allowedSlots: [CorsDeploymentSlot.local],
      allowCredentials: true,
      regulatoryRefs: ['W3C Secure Contexts §3 localhost exception'],
    ),
  ];

  static CorsAllowedOriginRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Origins allowed in the given slot.
  static List<CorsAllowedOriginRecord> forSlot(CorsDeploymentSlot s) {
    return records.where((r) => r.allowedSlots.contains(s)).toList();
  }
}

/// True when the origin is on the allowlist for the given slot.
/// Drives the CORS middleware decision.
bool isOriginAllowed(String origin, CorsDeploymentSlot slot) {
  for (final r in CorsAllowedOriginCatalog.records) {
    if (r.origin == origin && r.allowedSlots.contains(slot)) return true;
  }
  return false;
}
