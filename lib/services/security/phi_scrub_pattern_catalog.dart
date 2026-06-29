/// L9 — PHI scrub pattern catalog (pinned helper).
///
/// **Why this exists**: today `lib/utils/phi_redaction.dart` keeps
/// 12+ PHI-detection regexes as private static fields. They work,
/// but the auditor can't read them, the trust page can't quote them,
/// and a new identifier class (insurance card number, Medicare
/// Beneficiary Identifier) cannot be added without a code review of
/// hidden state. This catalog pins every pattern with:
///   1. The HIPAA §164.514(b)(2) Safe Harbor identifier number it
///      addresses (1–18).
///   2. A category (phone / email / date / mrn / ssn / kvnr / ip /
///      npi / app-minted) for telemetry without echoing the match.
///   3. A synthetic example match so the test corpus covers every
///      pattern individually.
///
/// **Distinct from L6 jailbreak patterns**: L6 detects attacker
/// intent; L9 detects identifiers we MUST redact before relay.
///
/// **Out of scope** (separate PRs):
///   * Patch `phi_redaction.dart` to read its regex set from here.
///   * Server-side TS port parity test (mirror of
///     `functions/src/lib/phi_scrub.ts`).
///   * Trust-center widget rendering the Safe Harbor coverage.
library;

/// Coarse category for telemetry. Logging the category instead of
/// the raw match keeps PHI out of the audit log while the analytics
/// team can still see "we scrubbed 432 phone numbers this week".
enum PhiCategory {
  phone,
  email,
  date,
  medicalRecordNumber,
  ssn,
  insuranceCardNumber,
  ipAddress,
  npi,
  appMintedId,
}

/// One pinned PHI pattern.
class PhiScrubPattern {
  const PhiScrubPattern({
    required this.id,
    required this.pattern,
    required this.category,
    required this.safeHarborIdentifierNumber,
    required this.exampleMatch,
    required this.regulatoryRefs,
  });

  /// Stable id used by tests + the redaction logger.
  final String id;

  /// The actual regex applied. Always case-insensitive unless the
  /// identifier (e.g. KVNR) is case-sensitive by spec.
  final RegExp pattern;

  final PhiCategory category;

  /// HIPAA §164.514(b)(2) Safe Harbor identifier number (1..18).
  /// `0` for identifiers that are not in the Safe Harbor list but
  /// are still PII the platform redacts (e.g. app-minted patient
  /// id formats).
  final int safeHarborIdentifierNumber;

  /// Synthetic example that MUST match the pattern. Tests assert
  /// this so the regex never silently drifts.
  final String exampleMatch;

  final List<String> regulatoryRefs;
}

class PhiScrubPatternCatalog {
  const PhiScrubPatternCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned patterns. Append-only — deprecated rows stay so the
  /// historic scrub logs still resolve to a category.
  static final List<PhiScrubPattern> patterns = [
    // ────────── PHONE (Safe Harbor §2 telephone) ──────────
    PhiScrubPattern(
      id: 'phone-e164',
      pattern: RegExp(r'\+\d{8,15}\b'),
      category: PhiCategory.phone,
      safeHarborIdentifierNumber: 2,
      exampleMatch: '+14155552671',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(B) telephone numbers'],
    ),
    PhiScrubPattern(
      id: 'phone-us',
      pattern: RegExp(r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b'),
      category: PhiCategory.phone,
      safeHarborIdentifierNumber: 2,
      exampleMatch: '415-555-2671',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(B)'],
    ),
    // ────────── EMAIL (Safe Harbor §6 email address) ──────────
    PhiScrubPattern(
      id: 'email',
      pattern: RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b'),
      category: PhiCategory.email,
      safeHarborIdentifierNumber: 6,
      exampleMatch: 'jane.doe@example.com',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(F) email addresses'],
    ),
    // ────────── DATE (Safe Harbor §3 dates — month/day) ──────────
    PhiScrubPattern(
      id: 'date-iso',
      pattern: RegExp(r'\b(19|20)\d{2}-\d{2}-\d{2}\b'),
      category: PhiCategory.date,
      safeHarborIdentifierNumber: 3,
      exampleMatch: '1985-04-12',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(C) dates'],
    ),
    PhiScrubPattern(
      id: 'date-us',
      pattern: RegExp(r'\b\d{1,2}/\d{1,2}/(19|20)\d{2}\b'),
      category: PhiCategory.date,
      safeHarborIdentifierNumber: 3,
      exampleMatch: '04/12/1985',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(C)'],
    ),
    PhiScrubPattern(
      id: 'date-de',
      pattern: RegExp(r'\b\d{1,2}\.\d{1,2}\.(19|20)\d{2}\b'),
      category: PhiCategory.date,
      safeHarborIdentifierNumber: 3,
      exampleMatch: '12.04.1985',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(C)'],
    ),
    // ────────── MRN / SSN / KVNR / IP / NPI ──────────
    PhiScrubPattern(
      id: 'medical-record-number',
      pattern: RegExp(r'\b(MRN|mrn|Mrn)[#:\s]*\d{4,12}\b'),
      category: PhiCategory.medicalRecordNumber,
      safeHarborIdentifierNumber: 8,
      exampleMatch: 'MRN: 1234567',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(H) medical record numbers'],
    ),
    PhiScrubPattern(
      id: 'ssn',
      pattern: RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      category: PhiCategory.ssn,
      safeHarborIdentifierNumber: 7,
      exampleMatch: '123-45-6789',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(G) social security numbers'],
    ),
    PhiScrubPattern(
      id: 'kvnr',
      pattern: RegExp(r'\b[A-Z]\d{9}\b'),
      category: PhiCategory.insuranceCardNumber,
      safeHarborIdentifierNumber: 9,
      exampleMatch: 'X123456789',
      regulatoryRefs: [
        'HIPAA §164.514(b)(2)(I) health plan beneficiary',
        'DE §291 SGB V Krankenversichertennummer',
      ],
    ),
    PhiScrubPattern(
      id: 'ip-v4',
      pattern: RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b'),
      category: PhiCategory.ipAddress,
      safeHarborIdentifierNumber: 16,
      exampleMatch: '203.0.113.42',
      regulatoryRefs: ['HIPAA §164.514(b)(2)(P) IP addresses'],
    ),
    PhiScrubPattern(
      id: 'npi',
      // CMS NPI format: 10 digits starting with 1 or 2 (Luhn-valid
      // in practice; we strip on shape match alone).
      pattern: RegExp(r'\b[12]\d{9}\b'),
      category: PhiCategory.npi,
      // provider id, not Safe Harbor.
      safeHarborIdentifierNumber: 0,
      exampleMatch: '1234567890',
      regulatoryRefs: ['CMS NPI registry'],
    ),
    // ─── APP-MINTED IDS (not Safe Harbor; pinned for our PHI flow) ───
    PhiScrubPattern(
      id: 'app-patient-id',
      pattern: RegExp(r'\bpat-[a-z0-9]{6,}\b'),
      category: PhiCategory.appMintedId,
      safeHarborIdentifierNumber: 0,
      exampleMatch: 'pat-abc1234567',
      regulatoryRefs: ['Internal: app-minted patient id format'],
    ),
    PhiScrubPattern(
      id: 'app-consent-id',
      pattern: RegExp(r'\bce-[a-z0-9]{6,}\b'),
      category: PhiCategory.appMintedId,
      safeHarborIdentifierNumber: 0,
      exampleMatch: 'ce-abc1234567',
      regulatoryRefs: ['Internal: app-minted consent entry id format'],
    ),
    PhiScrubPattern(
      id: 'app-audit-id',
      pattern: RegExp(r'\baudit-[a-z0-9]{6,}\b'),
      category: PhiCategory.appMintedId,
      safeHarborIdentifierNumber: 0,
      exampleMatch: 'audit-abc1234567',
      regulatoryRefs: ['Internal: app-minted audit entry id format'],
    ),
    PhiScrubPattern(
      id: 'app-kvkk-patient-id',
      pattern: RegExp(r'\bkvkk-pat-[a-z0-9]{6,}\b'),
      category: PhiCategory.appMintedId,
      safeHarborIdentifierNumber: 0,
      exampleMatch: 'kvkk-pat-abc1234567',
      regulatoryRefs: ['Internal: KVKK md. 6 patient id format', 'KVKK md. 12'],
    ),
  ];

  static PhiScrubPattern? byId(String id) {
    for (final p in patterns) {
      if (p.id == id) return p;
    }
    return null;
  }

  static List<PhiScrubPattern> byCategory(PhiCategory category) {
    return patterns.where((p) => p.category == category).toList();
  }
}

/// First-matching pattern + its category, or null when the text
/// contains no recognised PHI. Callers log the category, never
/// the raw match.
PhiScrubPattern? detectPhi(String text) {
  if (text.isEmpty) return null;
  for (final p in PhiScrubPatternCatalog.patterns) {
    if (p.pattern.hasMatch(text)) return p;
  }
  return null;
}

/// Convenience boolean for gate-style call sites.
bool hasPhi(String text) => detectPhi(text) != null;
