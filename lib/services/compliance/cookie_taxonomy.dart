/// K9 — Cookie + tracker taxonomy (pinned helper).
///
/// **Why this exists**: today the landing-page cookie notice is a
/// single binary acknowledgement ("got it"). The ePrivacy Directive
/// Art. 5(3) + GDPR Art. 6(1)(a) require *per-category* opt-in for
/// any non-essential cookie or tracker. Pinning the taxonomy means:
///   1. A new tracker cannot ship without a row + a category.
///   2. The consent UI renders the same vocabulary the cookie
///      preference center reads back.
///   3. A DSAR cookie request gets a deterministic list to redact.
///
/// **Out of scope** (separate PRs):
///   * Per-category opt-in UI replacement for the binary widget.
///   * Cookie preference center page.
///   * Cookie audit script that diffs runtime cookies against the
///     pinned taxonomy in CI.
library;

/// Cookie / tracker category per ePrivacy Directive Art. 5(3).
enum CookieCategory {
  /// Strictly necessary for the service to function — no consent
  /// needed (ePrivacy Art. 5(3) "strictly necessary" exemption).
  essential,

  /// Improves UX but service works without it (language, layout).
  /// Opt-in required for new visitors; cookieless default works.
  functional,

  /// Aggregate analytics on usage patterns; never per-user identity.
  /// Opt-in required.
  analytics,

  /// Behavioural advertising or third-party tracking. Opt-in
  /// required; banned by default for clinical surfaces.
  marketing,
}

/// One pinned cookie / tracker.
class CookieRecord {
  const CookieRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.vendor,
    required this.purpose,
    required this.retentionDays,
    required this.requiresOptIn,
    required this.regulatoryRefs,
  });

  /// Stable id used by the consent center + preference reader.
  final String id;

  /// Actual cookie name as it appears in `document.cookie` or the
  /// SDK identifier (e.g. `_ph_id`, `__stripe_mid`).
  final String name;

  final CookieCategory category;

  /// Whose tracker it is. `firstParty` for our own; vendor name
  /// for everything else.
  final String vendor;

  /// What we use it for, in plain language for the preference UI.
  final String purpose;

  /// Days the cookie persists. 0 = session cookie (cleared on
  /// browser close).
  final int retentionDays;

  /// True when the category requires explicit opt-in before the
  /// cookie is set. Essential cookies set without consent.
  final bool requiresOptIn;

  final List<String> regulatoryRefs;
}

class CookieTaxonomy {
  const CookieTaxonomy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned cookies + trackers. Append-only.
  static const List<CookieRecord> cookies = [
    // ────────── ESSENTIAL ──────────
    CookieRecord(
      id: 'firebase-auth-session',
      name: '__session',
      category: CookieCategory.essential,
      vendor: 'firstParty',
      purpose: 'Maintains the signed-in clinician session.',
      retentionDays: 14,
      requiresOptIn: false,
      regulatoryRefs: [
        'ePrivacy Directive Art. 5(3) "strictly necessary"',
        'GDPR Art. 6(1)(b) contract performance',
      ],
    ),
    CookieRecord(
      id: 'csrf-token',
      name: '__Host-csrf',
      category: CookieCategory.essential,
      vendor: 'firstParty',
      purpose: 'CSRF protection on the sign-in + portal forms.',
      retentionDays: 0,
      requiresOptIn: false,
      regulatoryRefs: [
        'ePrivacy Directive Art. 5(3) "strictly necessary"',
        'OWASP ASVS 13.2.3',
      ],
    ),
    CookieRecord(
      id: 'cookie-consent-acknowledged',
      name: 'psy_cookie_consent_v1',
      category: CookieCategory.essential,
      vendor: 'firstParty',
      purpose: 'Records the visitor has been shown the consent banner.',
      retentionDays: 365,
      requiresOptIn: false,
      regulatoryRefs: ['ePrivacy Directive Art. 5(3) "strictly necessary"'],
    ),
    // ────────── FUNCTIONAL ──────────
    CookieRecord(
      id: 'language-preference',
      name: 'psy_locale',
      category: CookieCategory.functional,
      vendor: 'firstParty',
      purpose: "Remembers the visitor's preferred locale.",
      retentionDays: 365,
      requiresOptIn: true,
      regulatoryRefs: [
        'GDPR Art. 6(1)(a) consent',
        'ePrivacy Directive Art. 5(3)',
      ],
    ),
    CookieRecord(
      id: 'theme-preference',
      name: 'psy_theme',
      category: CookieCategory.functional,
      vendor: 'firstParty',
      purpose: "Remembers the visitor's light / dark theme choice.",
      retentionDays: 365,
      requiresOptIn: true,
      regulatoryRefs: ['GDPR Art. 6(1)(a)'],
    ),
    // ────────── ANALYTICS ──────────
    CookieRecord(
      id: 'posthog-distinct-id',
      name: 'ph_distinct_id',
      category: CookieCategory.analytics,
      vendor: 'posthog',
      purpose:
          'Aggregate usage analytics on the landing + marketing pages '
          'only; never set on clinical surfaces.',
      retentionDays: 365,
      requiresOptIn: true,
      regulatoryRefs: [
        'GDPR Art. 6(1)(a) consent',
        'ePrivacy Directive Art. 5(3)',
        'TTDSG §25 (DE national implementation)',
      ],
    ),
    // ────────── MARKETING ──────────
    // Today we ship zero marketing trackers. The category exists
    // in the enum so a future "add Meta Pixel" PR has a place to
    // land + the test pins zero-as-of-now.
  ];

  static CookieRecord? byId(String id) {
    for (final c in cookies) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<CookieRecord> byCategory(CookieCategory category) {
    return cookies.where((c) => c.category == category).toList();
  }
}

/// True when [category] never sets a cookie on a clinical-data
/// surface. Marketing + analytics MUST stay off the patient portal
/// + the clinician workspace; only the landing / public marketing
/// pages may set them after opt-in.
bool isAllowedOnClinicalSurface(CookieCategory category) =>
    category == CookieCategory.essential;
