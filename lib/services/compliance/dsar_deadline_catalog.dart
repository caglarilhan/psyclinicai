/// K17 — DSAR (data-subject rights) deadline catalog (pinned).
///
/// **Why this exists**: GDPR Art. 12(3) sets a 1-month default
/// deadline for responding to data-subject rights requests, with a
/// 2-month extension for complexity. Art. 15-22 enumerate the
/// specific rights (access, rectification, erasure, restriction,
/// portability, object). Missing a deadline is an Art. 83(5) fine
/// (up to 4% global turnover). HIPAA §164.524 + §164.526 set US-
/// flavored deadlines for access (30 days, one 30-day extension)
/// and amendment (60 days, one 30-day extension). The DSAR queue
/// gate needs to know per-right: what's the floor deadline, what's
/// the max extension, what triggers fee-or-refusal eligibility.
/// This catalog pins those numbers.
///
/// This catalog pins per right:
///   1. Right id + GDPR article + plain description.
///   2. Default response deadline in days.
///   3. Max extension allowed in days (one-shot per Art. 12(3)).
///   4. Whether the right may be refused on "manifestly unfounded
///      or excessive" grounds (Art. 12(5)(b)).
///   5. Whether the right is in scope for a HIPAA equivalent.
///   6. Regulatory anchor.
///
/// **Distinct from**:
///   * `IdentityVerificationPolicy` (K13) — verifies WHO is making
///     the request; K17 pins the deadline once verified.
///   * `LawfulBasisCatalog` (K16) — what lawful basis the activity
///     uses; K17 governs the response timeline for each right.
///   * `RopaRegistry` — names processing activities; K17 is about
///     the response cycle to the data subject.
///
/// **Out of scope** (separate PRs):
///   * DSAR queue gate runner.
///   * Per-jurisdiction deadline overlay (CCPA / LGPD / PIPEDA).
///   * Fee-collection workflow.
library;

/// GDPR data-subject rights covered by the catalog.
enum DataSubjectRight {
  /// Art. 15 — right of access (copy of personal data).
  access,

  /// Art. 16 — right to rectification (correction).
  rectification,

  /// Art. 17 — right to erasure (right to be forgotten).
  erasure,

  /// Art. 18 — right to restriction of processing.
  restriction,

  /// Art. 20 — right to data portability (machine-readable export).
  portability,

  /// Art. 21 — right to object (e.g. to direct marketing).
  objection,
}

class DsarDeadlineRecord {
  const DsarDeadlineRecord({
    required this.id,
    required this.right,
    required this.description,
    required this.defaultDeadlineDays,
    required this.maxExtensionDays,
    required this.refusableForManifestlyUnfounded,
    required this.hipaaEquivalent,
    required this.regulatoryRefs,
  });

  final String id;
  final DataSubjectRight right;
  final String description;

  /// Default response deadline in days (GDPR 30; HIPAA 30 for
  /// access, 60 for amendment).
  final int defaultDeadlineDays;

  /// Max extension days available under Art. 12(3). Zero if no
  /// extension allowed.
  final int maxExtensionDays;

  /// True when the controller may refuse / charge a fee for the
  /// request being "manifestly unfounded or excessive" (Art.
  /// 12(5)(b)).
  final bool refusableForManifestlyUnfounded;

  /// True when HIPAA has an equivalent deadline (drives US-region
  /// compliance bridge messaging).
  final bool hipaaEquivalent;

  final List<String> regulatoryRefs;
}

class DsarDeadlineCatalog {
  const DsarDeadlineCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned deadline table. Append-only.
  static const List<DsarDeadlineRecord> records = [
    DsarDeadlineRecord(
      id: 'access',
      right: DataSubjectRight.access,
      description:
          'Right of access — copy of personal data being processed. GDPR Art. 15; HIPAA §164.524 (30+30 day equivalent).',
      defaultDeadlineDays: 30,
      maxExtensionDays: 60,
      refusableForManifestlyUnfounded: true,
      hipaaEquivalent: true,
      regulatoryRefs: [
        'GDPR Art. 15 right of access',
        'GDPR Art. 12(3) 1-month default + 2-month extension',
        'GDPR Art. 12(5)(b) manifestly unfounded refusal',
        'HIPAA §164.524 access of individuals to PHI',
        'EDPB Guidelines 01/2022 on Art. 15',
      ],
    ),
    DsarDeadlineRecord(
      id: 'rectification',
      right: DataSubjectRight.rectification,
      description:
          'Right to rectification — correction of inaccurate personal data. GDPR Art. 16; HIPAA §164.526 amendment (60+30 days).',
      defaultDeadlineDays: 30,
      maxExtensionDays: 60,
      refusableForManifestlyUnfounded: true,
      hipaaEquivalent: true,
      regulatoryRefs: [
        'GDPR Art. 16 right to rectification',
        'GDPR Art. 12(3) deadline',
        'HIPAA §164.526 amendment of PHI',
      ],
    ),
    DsarDeadlineRecord(
      id: 'erasure',
      right: DataSubjectRight.erasure,
      description:
          'Right to erasure ("right to be forgotten") — except where overridden by retention obligation (K15 clinical-record floor).',
      defaultDeadlineDays: 30,
      maxExtensionDays: 60,
      refusableForManifestlyUnfounded: true,
      hipaaEquivalent: false,
      regulatoryRefs: [
        'GDPR Art. 17 right to erasure',
        'GDPR Art. 17(3)(b) legal obligation exception',
        'GDPR Art. 17(3)(c) public-health exception',
        'GDPR Art. 12(3) deadline',
      ],
    ),
    DsarDeadlineRecord(
      id: 'restriction',
      right: DataSubjectRight.restriction,
      description:
          'Right to restriction of processing — pause processing while accuracy is contested.',
      defaultDeadlineDays: 30,
      maxExtensionDays: 60,
      refusableForManifestlyUnfounded: true,
      hipaaEquivalent: false,
      regulatoryRefs: [
        'GDPR Art. 18 right to restriction',
        'GDPR Art. 12(3) deadline',
      ],
    ),
    DsarDeadlineRecord(
      id: 'portability',
      right: DataSubjectRight.portability,
      description:
          'Right to data portability — machine-readable export (DSAR ZIP per current dsar_export_zip implementation).',
      defaultDeadlineDays: 30,
      maxExtensionDays: 60,
      refusableForManifestlyUnfounded: true,
      hipaaEquivalent: false,
      regulatoryRefs: [
        'GDPR Art. 20 right to portability',
        'GDPR Art. 12(3) deadline',
        'EDPB Guidelines on portability WP242 rev.01',
      ],
    ),
    DsarDeadlineRecord(
      id: 'objection',
      right: DataSubjectRight.objection,
      description:
          'Right to object — e.g. to direct marketing (Art. 21(2) must stop immediately) or to legitimate-interest processing.',
      defaultDeadlineDays: 30,
      maxExtensionDays: 0,
      refusableForManifestlyUnfounded: true,
      hipaaEquivalent: false,
      regulatoryRefs: [
        'GDPR Art. 21 right to object',
        'GDPR Art. 21(2) direct marketing — no extension',
        'GDPR Art. 12(3) general deadline',
      ],
    ),
  ];

  static DsarDeadlineRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static DsarDeadlineRecord? byRight(DataSubjectRight r) {
    for (final rec in records) {
      if (rec.right == r) return rec;
    }
    return null;
  }
}

/// Effective max-deadline in days for the given right after any
/// allowed extension.
int maxDeadlineDays(DataSubjectRight r) {
  final rec = DsarDeadlineCatalog.byRight(r);
  if (rec == null) return 0;
  return rec.defaultDeadlineDays + rec.maxExtensionDays;
}
