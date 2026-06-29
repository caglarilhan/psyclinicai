/// K10 — Responsible disclosure policy catalog (pinned helper).
///
/// **Why this exists**: `web/.well-known/security.txt` (RFC 9116)
/// gives researchers a contact + expiry, but the rest of the policy
/// — per-severity response SLA, what is in scope, the safe-harbor
/// language that says "we will not sue you for good-faith research"
/// — lives in scattered places. Auditors (SOC 2 CC2.3 external
/// communications) + ISO 27001 A.16.1.3 vulnerability disclosure
/// expect a documented, public policy. Pinning it here:
///   1. The `/security` trust page renders the same numbers a
///      researcher reads from the security.txt + the public policy.
///   2. The expiry-monitor cron diffs the pinned expiry against the
///      static file (early-warning if security.txt is going stale).
///   3. A future bug-bounty PR adds a row instead of editing prose.
///
/// **Out of scope** (separate PRs):
///   * Trust-center widget rendering the matrix.
///   * Cron that auto-rotates security.txt expiry when ≤ 60d.
///   * Public hall-of-fame page (researcher acknowledgements).
library;

/// Severity of an inbound vulnerability report.
enum VulnSeverity { critical, high, medium, low, informational }

/// One pinned per-severity policy.
class VulnSeverityPolicy {
  const VulnSeverityPolicy({
    required this.severity,
    required this.acknowledgeWithinHours,
    required this.remediationTargetDays,
    required this.publicDisclosureAfterDays,
    required this.exampleVulnClass,
  });

  final VulnSeverity severity;

  /// Max hours from receipt to a human ack to the researcher.
  /// Drives the security@ inbox SLA banner.
  final int acknowledgeWithinHours;

  /// Target days to ship a fix (or document a workaround if the
  /// fix is impossible inside the window).
  final int remediationTargetDays;

  /// Days from remediation to public disclosure (90 days is the
  /// industry-standard coordinated disclosure window).
  final int publicDisclosureAfterDays;

  /// Example so the researcher knows where their report lands.
  final String exampleVulnClass;
}

/// What surfaces are eligible for a disclosure report.
class DisclosureScope {
  const DisclosureScope({
    required this.id,
    required this.surface,
    required this.inScope,
    required this.exampleVuln,
  });

  /// Stable id for the trust page renderer.
  final String id;

  /// Plain description of the surface.
  final String surface;

  /// True when the surface is eligible for a report.
  final bool inScope;

  /// Concrete vuln that would be welcomed for in-scope rows, or
  /// the reason it is out-of-scope for the others.
  final String exampleVuln;
}

class ResponsibleDisclosurePolicy {
  const ResponsibleDisclosurePolicy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Security contact, mirrored from `web/.well-known/security.txt`.
  /// Tests pin the file content matches this constant.
  static const String contactEmail = 'security@psyclinicai.com';

  /// security.txt `Expires:` value. Tests pin the file matches +
  /// fail when the deadline is < 60 days away (rotation reminder).
  static const String securityTxtExpiresIso = '2027-05-23T00:00:00.000Z';

  /// Languages we will accept reports in. Mirrors security.txt
  /// `Preferred-Languages`.
  static const List<String> preferredLanguages = ['en', 'tr', 'de'];

  /// Safe-harbor language for researchers. Verbatim — the public
  /// `/security` page renders this string.
  static const String researcherSafeHarbor =
      'We will not pursue civil or criminal action against researchers '
      'who report a vulnerability in good faith, respect this scope, '
      'do not exfiltrate data beyond what is needed to demonstrate the '
      'issue, and give us a reasonable remediation window before any '
      'public disclosure.';

  /// Pinned per-severity policy. Append-only.
  static const List<VulnSeverityPolicy> severities = [
    VulnSeverityPolicy(
      severity: VulnSeverity.critical,
      acknowledgeWithinHours: 4,
      remediationTargetDays: 7,
      publicDisclosureAfterDays: 90,
      exampleVulnClass:
          'RCE on a clinical surface, full Firestore rules bypass, '
          'audit chain integrity break',
    ),
    VulnSeverityPolicy(
      severity: VulnSeverity.high,
      acknowledgeWithinHours: 24,
      remediationTargetDays: 30,
      publicDisclosureAfterDays: 90,
      exampleVulnClass:
          "Authn bypass against one role, IDOR exposing another clinic's "
          'row, stored XSS in a clinician surface',
    ),
    VulnSeverityPolicy(
      severity: VulnSeverity.medium,
      acknowledgeWithinHours: 72,
      remediationTargetDays: 90,
      publicDisclosureAfterDays: 90,
      exampleVulnClass:
          'CSRF on a non-PHI endpoint, missing rate-limit on a '
          'low-impact API, reflected XSS in a marketing page',
    ),
    VulnSeverityPolicy(
      severity: VulnSeverity.low,
      acknowledgeWithinHours: 168,
      remediationTargetDays: 180,
      publicDisclosureAfterDays: 90,
      exampleVulnClass: 'Missing security header on a public page',
    ),
    VulnSeverityPolicy(
      severity: VulnSeverity.informational,
      acknowledgeWithinHours: 168,
      remediationTargetDays: 365,
      publicDisclosureAfterDays: 0,
      exampleVulnClass: 'Best-practice nudge, e.g. add a CAA record',
    ),
  ];

  /// Pinned in-scope + out-of-scope surfaces. Append-only.
  static const List<DisclosureScope> scopes = [
    DisclosureScope(
      id: 'web-app',
      surface: 'https://psyclinicai.web.app + https://psyclinicai.com',
      inScope: true,
      exampleVuln: 'Authn bypass, IDOR, stored XSS, CSRF on PHI endpoints',
    ),
    DisclosureScope(
      id: 'rag-hub',
      surface: 'https://rag.psyclinicai.com',
      inScope: true,
      exampleVuln: 'API authn bypass, prompt-injection that leaks PHI',
    ),
    DisclosureScope(
      id: 'cloud-functions',
      surface: 'Cloud Functions on psyclinicai project',
      inScope: true,
      exampleVuln: 'IAM mis-configuration, callable function authn bypass',
    ),
    DisclosureScope(
      id: 'firestore-rules',
      surface: 'firestore.rules (cross-tenant + audit chain)',
      inScope: true,
      exampleVuln: 'Cross-tenant read, append-only bypass, role escalation',
    ),
    DisclosureScope(
      id: 'denial-of-service',
      surface: 'Volumetric attacks on any psyclinicai.com surface',
      inScope: false,
      exampleVuln:
          'DDoS / floods are out of scope — please report via abuse@ '
          'instead of the security disclosure channel.',
    ),
    DisclosureScope(
      id: 'social-engineering',
      surface: 'Staff or clinician social-engineering attempts',
      inScope: false,
      exampleVuln:
          'Phishing the founder is out of scope; report attempted '
          'phishing to security@ as an awareness-training input.',
    ),
    DisclosureScope(
      id: 'third-party-domains',
      surface: 'status pages, Stripe checkout, Anthropic API',
      inScope: false,
      exampleVuln: 'Vendor-owned surfaces — report directly to the vendor.',
    ),
  ];

  static VulnSeverityPolicy forSeverity(VulnSeverity s) {
    for (final p in severities) {
      if (p.severity == s) return p;
    }
    throw StateError('No policy for ${s.name}');
  }

  static DisclosureScope? scopeById(String id) {
    for (final s in scopes) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Days remaining until the security.txt Expires deadline given
/// [today]. Negative when already expired. The expiry-monitor cron
/// fires when this is ≤ 60.
int daysUntilSecurityTxtExpiry(DateTime today) {
  final exp = DateTime.parse(ResponsibleDisclosurePolicy.securityTxtExpiresIso);
  return exp.difference(today).inDays;
}
