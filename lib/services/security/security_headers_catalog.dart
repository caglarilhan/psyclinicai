/// N24 — Security HTTP headers catalog (pinned helper).
///
/// **Why this exists**: OWASP ASVS V14.4 (HTTP security headers),
/// NIST SP 800-95 (web services security), and OWASP Top-10
/// A05:2021 (security misconfiguration) all require a documented
/// set of HTTP security headers on every response. Missing a CSP
/// is the #1 XSS-amplifier; missing HSTS is the #1
/// downgrade-attack vector. This catalog pins every required
/// header + its production value so the response middleware has
/// a single source of truth.
///
/// This catalog pins per header:
///   1. Stable header name (case-insensitive).
///   2. Required production value.
///   3. Plain-English why-we-need-it.
///   4. Whether the header is REQUIRED on every response (true
///      for hardening headers) or optional (CORS-style).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `EncryptionKeyRotationSchedule` (N20) — key lifecycle; N24
///     is the response-time defense surface.
///   * `PentestScopeCatalog` (N21) — pen test scope; N24 is the
///     baseline the pen tester checks against.
///   * `RequiredEnvVarCatalog` (O9) — env var presence; N24 is
///     HTTP response header presence.
///
/// **Out of scope** (separate PRs):
///   * Header middleware implementation (Flutter web + Cloud
///     Functions).
///   * CSP report-only rollout + nonce generation.
///   * Per-route header overrides (e.g. iframe-embed pages).
library;

class SecurityHeaderRecord {
  const SecurityHeaderRecord({
    required this.name,
    required this.requiredValue,
    required this.description,
    required this.requiredOnEveryResponse,
    required this.regulatoryRefs,
  });

  /// Stable header name (case-insensitive at the HTTP layer; we
  /// pin the canonical hyphenated form for grep + audit trail).
  final String name;

  /// Required production value. Exact string match — tests pin
  /// the canonical form.
  final String requiredValue;

  final String description;

  /// True when the header MUST be set on EVERY HTTP response (vs.
  /// situational headers like CORS that only fire on cross-origin).
  final bool requiredOnEveryResponse;

  final List<String> regulatoryRefs;
}

class SecurityHeadersCatalog {
  const SecurityHeadersCatalog._();

  /// YYYY-MM stamp — drives the security "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned header table. Append-only.
  static const List<SecurityHeaderRecord> records = [
    SecurityHeaderRecord(
      name: 'Strict-Transport-Security',
      requiredValue: 'max-age=63072000; includeSubDomains; preload',
      description:
          'HSTS — force HTTPS for 2 years (63072000s), include subdomains, opt in to browser preload list. Blocks downgrade attacks.',
      requiredOnEveryResponse: true,
      regulatoryRefs: [
        'OWASP ASVS V14.4.2',
        'RFC 6797 HSTS',
        'NIST SP 800-52 Rev. 2 TLS recommendations',
        'PCI DSS v4.0 §4.2.1 strong cryptography',
      ],
    ),
    SecurityHeaderRecord(
      name: 'Content-Security-Policy',
      requiredValue:
          "default-src 'self'; script-src 'self' 'strict-dynamic'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'; upgrade-insecure-requests",
      description:
          'CSP — strict-dynamic baseline; no inline JS; no plugins; no iframe embedding; auto-upgrade HTTP→HTTPS. Strongest XSS amplifier defense.',
      requiredOnEveryResponse: true,
      regulatoryRefs: [
        'OWASP ASVS V14.4.3',
        'W3C Content Security Policy Level 3',
        'OWASP Top-10 A03:2021 injection',
      ],
    ),
    SecurityHeaderRecord(
      name: 'X-Content-Type-Options',
      requiredValue: 'nosniff',
      description:
          'Disable MIME sniffing — browser must honor declared Content-Type. Blocks MIME-confusion attacks.',
      requiredOnEveryResponse: true,
      regulatoryRefs: ['OWASP ASVS V14.4.6', 'WHATWG Fetch Standard'],
    ),
    SecurityHeaderRecord(
      name: 'X-Frame-Options',
      requiredValue: 'DENY',
      description:
          'Block all iframe embedding — clickjacking defense for browsers that do not yet honor CSP frame-ancestors.',
      requiredOnEveryResponse: true,
      regulatoryRefs: ['OWASP ASVS V14.4.7', 'RFC 7034 X-Frame-Options'],
    ),
    SecurityHeaderRecord(
      name: 'Referrer-Policy',
      requiredValue: 'strict-origin-when-cross-origin',
      description:
          'Send full referrer same-origin; only origin (not path) cross-origin; nothing cross-origin downgraded HTTPS→HTTP. Blocks referrer leakage of PHI URLs.',
      requiredOnEveryResponse: true,
      regulatoryRefs: [
        'OWASP ASVS V14.4.5',
        'W3C Referrer Policy',
        'HIPAA §164.502(b) minimum necessary',
      ],
    ),
    SecurityHeaderRecord(
      name: 'Permissions-Policy',
      requiredValue:
          'camera=(), microphone=(self), geolocation=(), payment=(), usb=(), accelerometer=(), gyroscope=(), magnetometer=()',
      description:
          'Permissions policy — disable camera/geolocation/payment/USB/sensors by default. Microphone allowed for self (telehealth audio capture only).',
      requiredOnEveryResponse: true,
      regulatoryRefs: [
        'OWASP ASVS V14.4.8',
        'W3C Permissions Policy',
        'GDPR Art. 25 privacy by default',
      ],
    ),
    SecurityHeaderRecord(
      name: 'Cross-Origin-Opener-Policy',
      requiredValue: 'same-origin',
      description:
          'Isolate browsing context group — prevents same-origin cross-window attacks (e.g. SharedArrayBuffer abuse, window-name leak).',
      requiredOnEveryResponse: true,
      regulatoryRefs: ['OWASP ASVS V14.4.4', 'HTML Living Standard COOP'],
    ),
    SecurityHeaderRecord(
      name: 'Cross-Origin-Embedder-Policy',
      requiredValue: 'require-corp',
      description:
          'Require explicit cross-origin opt-in via Cross-Origin-Resource-Policy / CORS. Pairs with COOP for cross-origin isolation.',
      requiredOnEveryResponse: true,
      regulatoryRefs: ['OWASP ASVS V14.4.4', 'HTML Living Standard COEP'],
    ),
  ];

  static SecurityHeaderRecord? byName(String name) {
    final n = name.toLowerCase();
    for (final r in records) {
      if (r.name.toLowerCase() == n) return r;
    }
    return null;
  }
}

/// True when every response in the platform MUST emit the header
/// with the canonical pinned value.
bool isRequiredOnEveryResponse(String name) {
  final r = SecurityHeadersCatalog.byName(name);
  return r?.requiredOnEveryResponse ?? false;
}
