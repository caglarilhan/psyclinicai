/// N19 — Vendor risk tier catalog (pinned helper).
///
/// **Why this exists**: `SubprocessorRegistry` lists WHICH vendors
/// we use. It does NOT spell out the diligence each vendor must
/// pass before onboarding (SOC 2 report? pen test? BAA? DPA?).
/// SOC 2 CC9.2, ISO 27001 A.15 (supplier relationships), GDPR
/// Art. 28 (processor obligations), and HIPAA §164.308(b)(1)
/// (business associate contracts) all require a documented,
/// tier-based vendor risk policy. This catalog pins that policy.
///
/// This catalog pins per vendor risk tier:
///   1. Tier (critical / elevated / standard / minimal).
///   2. Which diligence artifacts are MANDATORY at onboarding.
///   3. Re-review cadence in months.
///   4. Whether continuous monitoring (SOC 2 bridge letter, breach
///      feed) is required.
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `SubprocessorRegistry` — names + locations of the vendors we
///     engage; N19 spells out the *policy gate* each tier must pass.
///   * `IdentityVerificationPolicy` (K13) — verifies the END USER
///     making a data-subject request; N19 verifies the VENDOR
///     receiving data.
///   * `CrossBorderTransferRegister` (K12) — Schrems II measures for
///     specific transfers; N19 is the upstream gate that decides
///     whether the transfer is even allowed.
///
/// **Out of scope** (separate PRs):
///   * Vendor onboarding workflow UI.
///   * Continuous monitoring webhook ingestion.
///   * Per-vendor risk-score model.
library;

/// Four-tier vendor risk ladder. Higher tier = stricter diligence.
enum VendorRiskTier {
  /// Processes plain-text PHI or holds production database access.
  /// SOC 2 Type II + pen test + BAA + DPA + continuous monitoring
  /// MANDATORY. Reviewed every 6 months.
  critical,

  /// Processes pseudonymised PHI or has limited production access
  /// (e.g. observability vendor seeing log metadata). SOC 2 Type II
  /// + DPA REQUIRED. Reviewed every 12 months.
  elevated,

  /// No PHI, but holds business confidential data (e.g. billing,
  /// internal SSO IdP, employee chat). SOC 2 Type II OR ISO 27001
  /// REQUIRED. Reviewed every 12 months.
  standard,

  /// No PHI, no business confidential data (e.g. public CDN, blog
  /// embed). Self-attestation only. Reviewed every 24 months.
  minimal,
}

/// Required diligence artifacts. Tests pin the per-tier set.
enum VendorDiligenceArtifact {
  /// SOC 2 Type II report current within 12 months.
  soc2TypeII,

  /// ISO 27001 certificate, current.
  iso27001,

  /// Independent penetration test, current within 12 months.
  penTestReport,

  /// HIPAA Business Associate Agreement, signed.
  baa,

  /// GDPR Art. 28 Data Processing Agreement with SCC module 2 if
  /// transfer leaves EEA.
  dpa,

  /// Vendor-completed security questionnaire (CAIQ-Lite or
  /// internal short form).
  securityQuestionnaire,
}

/// One pinned tier policy.
class VendorRiskTierRecord {
  const VendorRiskTierRecord({
    required this.id,
    required this.tier,
    required this.description,
    required this.mandatoryArtifacts,
    required this.reviewCadenceMonths,
    required this.continuousMonitoringRequired,
    required this.regulatoryRefs,
  });

  final String id;
  final VendorRiskTier tier;
  final String description;
  final List<VendorDiligenceArtifact> mandatoryArtifacts;

  /// Months between full re-reviews. Higher tier = shorter cadence.
  final int reviewCadenceMonths;

  /// True when CISO must wire a continuous monitoring feed (breach
  /// alerting + SOC 2 bridge letter watching). Critical tier only.
  final bool continuousMonitoringRequired;

  final List<String> regulatoryRefs;
}

class VendorRiskTierCatalog {
  const VendorRiskTierCatalog._();

  /// YYYY-MM stamp — drives the trust center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policy table. Append-only.
  static const List<VendorRiskTierRecord> records = [
    VendorRiskTierRecord(
      id: 'tier-critical',
      tier: VendorRiskTier.critical,
      description:
          'Vendor processes plain-text PHI or holds production database access. Examples: primary cloud host, EHR connector, AI inference proxy.',
      mandatoryArtifacts: [
        VendorDiligenceArtifact.soc2TypeII,
        VendorDiligenceArtifact.penTestReport,
        VendorDiligenceArtifact.baa,
        VendorDiligenceArtifact.dpa,
        VendorDiligenceArtifact.securityQuestionnaire,
      ],
      reviewCadenceMonths: 6,
      continuousMonitoringRequired: true,
      regulatoryRefs: [
        'SOC 2 CC9.2 vendor risk management',
        'ISO 27001 A.15.1 supplier relationships',
        'GDPR Art. 28 processor obligations',
        'HIPAA §164.308(b)(1) business associate contracts',
        'HIPAA §164.314(a) BAA content requirements',
      ],
    ),
    VendorRiskTierRecord(
      id: 'tier-elevated',
      tier: VendorRiskTier.elevated,
      description:
          'Vendor processes pseudonymised PHI or has limited production access (e.g. observability seeing log metadata, email delivery, error tracker).',
      mandatoryArtifacts: [
        VendorDiligenceArtifact.soc2TypeII,
        VendorDiligenceArtifact.dpa,
        VendorDiligenceArtifact.securityQuestionnaire,
      ],
      reviewCadenceMonths: 12,
      continuousMonitoringRequired: false,
      regulatoryRefs: [
        'SOC 2 CC9.2 vendor risk management',
        'ISO 27001 A.15.1 supplier relationships',
        'GDPR Art. 28 processor obligations',
      ],
    ),
    VendorRiskTierRecord(
      id: 'tier-standard',
      tier: VendorRiskTier.standard,
      description:
          'No PHI, but holds business confidential data (billing processor, SSO IdP for staff, internal chat).',
      mandatoryArtifacts: [
        VendorDiligenceArtifact.soc2TypeII,
        VendorDiligenceArtifact.dpa,
      ],
      reviewCadenceMonths: 12,
      continuousMonitoringRequired: false,
      regulatoryRefs: [
        'SOC 2 CC9.2 vendor risk management',
        'ISO 27001 A.15.1 supplier relationships',
      ],
    ),
    VendorRiskTierRecord(
      id: 'tier-minimal',
      tier: VendorRiskTier.minimal,
      description:
          'No PHI, no business confidential data (public CDN, blog embed, status page widget).',
      mandatoryArtifacts: [VendorDiligenceArtifact.securityQuestionnaire],
      reviewCadenceMonths: 24,
      continuousMonitoringRequired: false,
      regulatoryRefs: ['SOC 2 CC9.2 vendor risk management'],
    ),
  ];

  static VendorRiskTierRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static VendorRiskTierRecord? byTier(VendorRiskTier t) {
    for (final r in records) {
      if (r.tier == t) return r;
    }
    return null;
  }
}

/// True when the vendor tier requires a BAA (US HIPAA gate). Drives
/// the vendor onboarding form to surface the BAA upload field.
bool requiresBaa(VendorRiskTier t) {
  final r = VendorRiskTierCatalog.byTier(t);
  return r?.mandatoryArtifacts.contains(VendorDiligenceArtifact.baa) ?? false;
}

/// True when the vendor tier requires a DPA (EU GDPR gate).
bool requiresDpa(VendorRiskTier t) {
  final r = VendorRiskTierCatalog.byTier(t);
  return r?.mandatoryArtifacts.contains(VendorDiligenceArtifact.dpa) ?? false;
}
