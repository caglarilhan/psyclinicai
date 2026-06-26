/// K7 — Data classification policy catalog (pinned helper).
///
/// **Why this exists**: every helper in the platform that touches
/// data needs to know *what class* it's handling — backup retention
/// (N4), breach 72h severity (K4), DSAR export groupings (K1),
/// access-review scope (N7), encryption floor (HIPAA §164.312(a)(2)
/// (iv)). Today each helper makes that decision inline; this catalog
/// pins the contract so:
///   1. A new collection cannot ship without picking a class.
///   2. Every downstream policy (encryption, retention, transfer)
///      reads the floor from one source.
///   3. The trust-center "what data we hold" page renders the matrix.
///
/// **Out of scope** (separate PRs):
///   * Patch backup_recovery_plan to read retention floor from here.
///   * Patch breach_notification to map class → notification window.
///   * Trust-center widget rendering the matrix.
library;

/// What sensitivity tier the data belongs to.
enum DataSensitivity {
  /// Protected Health Information — HIPAA §164.103. Highest tier.
  phi,

  /// Personal data under GDPR Art. 4(1) that is NOT special-category.
  /// E.g. clinician email, phone, login metadata.
  personalData,

  /// Business operational data — Stripe customer IDs, landing
  /// waitlist signups, beta participants. Not PHI, not free.
  businessOps,

  /// Public data — published marketing copy, trust-center JSON,
  /// pricing page.
  publicData,
}

/// Minimum encryption requirement.
enum EncryptionRequirement {
  /// AES-256 at rest + TLS 1.3 in transit. Mandatory for PHI.
  aes256AtRestTls13InTransit,

  /// Symmetric encryption at rest + TLS 1.3 in transit. Acceptable
  /// for personal-data + business-ops.
  symmetricAtRestTls13InTransit,

  /// TLS in transit only; storage encryption optional. Acceptable
  /// for public data.
  tls13InTransitOnly,
}

/// Cross-border transfer posture.
enum CrossBorderPolicy {
  /// Must stay within EU/EEA (Hetzner Frankfurt, Firebase EU
  /// multi-region).
  euOnly,

  /// SCCs + supplementary measures required (Schrems II compliant).
  /// Used for Anthropic / OpenAI relay of pseudonymised PHI.
  sccPlusSupplementary,

  /// No restriction (public data + non-personal business metadata).
  unrestricted,
}

/// One pinned classification record.
class DataClassRecord {
  const DataClassRecord({
    required this.id,
    required this.label,
    required this.sensitivity,
    required this.exampleCollections,
    required this.encryption,
    required this.minRetentionDays,
    required this.maxRetentionDays,
    required this.crossBorder,
    required this.requiresExplicitConsent,
    required this.regulatoryRefs,
  });

  /// Stable id used by downstream helpers as the class key.
  final String id;
  final String label;
  final DataSensitivity sensitivity;

  /// Concrete examples — Firestore collection names + on-device
  /// stores. Drives reviewer intuition.
  final List<String> exampleCollections;

  final EncryptionRequirement encryption;

  /// Lower bound the platform must keep the data for (compliance
  /// floor — HIPAA 6y audit, KVKK 10y for some categories).
  final int minRetentionDays;

  /// Upper bound after which the data MUST be purged (GDPR Art. 5
  /// (1)(e) storage limitation + ROPA-declared windows).
  final int maxRetentionDays;

  final CrossBorderPolicy crossBorder;

  /// True when GDPR Art. 9 / KVKK md. 6 require explicit opt-in
  /// before the platform can process the data.
  final bool requiresExplicitConsent;

  final List<String> regulatoryRefs;
}

class DataClassificationCatalog {
  const DataClassificationCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned classification. Append-only.
  static const List<DataClassRecord> classes = [
    DataClassRecord(
      id: 'phi-clinical',
      label: 'PHI — clinical records',
      sensitivity: DataSensitivity.phi,
      exampleCollections: [
        'firestore://patients',
        'firestore://sessions',
        'firestore://assessments',
        'firestore://safety_plans',
        'on-device://encrypted_chart_cache',
      ],
      encryption: EncryptionRequirement.aes256AtRestTls13InTransit,
      // HIPAA 6y minimum (45 CFR §164.316(b)(2)(i)); we hold to 7y
      // to match KVKK md. 7 silme talebi izlenebilirliği window.
      minRetentionDays: 2555,
      // 30 years upper bound — many US states require longer for
      // minor records; cap matches our DPA storage-limitation note.
      maxRetentionDays: 10950,
      crossBorder: CrossBorderPolicy.sccPlusSupplementary,
      requiresExplicitConsent: true,
      regulatoryRefs: [
        'HIPAA §164.103 ePHI definition',
        'HIPAA §164.312(a)(2)(iv) encryption + decryption',
        'HIPAA §164.316(b)(2)(i) 6-year retention',
        'GDPR Art. 9(2)(a) explicit consent for health data',
        'KVKK md. 6 özel nitelikli kişisel veri',
      ],
    ),
    DataClassRecord(
      id: 'phi-audit-chain',
      label: 'PHI — forensic audit chain',
      sensitivity: DataSensitivity.phi,
      exampleCollections: [
        'firestore://clinic_audit_logs',
        'gs://psyclinicai-audit-cold-eu',
      ],
      encryption: EncryptionRequirement.aes256AtRestTls13InTransit,
      minRetentionDays: 2555,
      // exact 7y — chain integrity demands a fixed window.
      maxRetentionDays: 2555,
      crossBorder: CrossBorderPolicy.euOnly,
      // audit log is not consented; it is operational under
      // GDPR Art. 6(1)(c) legal obligation.
      requiresExplicitConsent: false,
      regulatoryRefs: [
        'HIPAA §164.316(b)(2)(i)',
        'KVKK md. 12 veri güvenliği yükümlülüğü',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
    DataClassRecord(
      id: 'personal-clinician-account',
      label: 'Personal data — clinician account',
      sensitivity: DataSensitivity.personalData,
      exampleCollections: ['firestore://clinicians', 'firebase-auth://users'],
      encryption: EncryptionRequirement.symmetricAtRestTls13InTransit,
      // Account-lifecycle data; SOC 2 expects 1y retention of
      // deactivated accounts for access-review trails.
      minRetentionDays: 365,
      // align with audit chain so deactivation events resolve.
      maxRetentionDays: 2555,
      crossBorder: CrossBorderPolicy.euOnly,
      // Art. 6(1)(b) contract performance — no separate consent.
      requiresExplicitConsent: false,
      regulatoryRefs: [
        'GDPR Art. 4(1) personal data',
        'GDPR Art. 6(1)(b) contract performance',
        'KVKK md. 5/2 sözleşmenin kurulması',
      ],
    ),
    DataClassRecord(
      id: 'personal-consent-ledger',
      label: 'Personal data — consent ledger',
      sensitivity: DataSensitivity.personalData,
      exampleCollections: [
        'firestore://consent_records',
        'firestore://consent_entries',
      ],
      encryption: EncryptionRequirement.aes256AtRestTls13InTransit,
      // matches K6.helper revoke SLA + DPA narrative.
      minRetentionDays: 2555,
      maxRetentionDays: 2555,
      crossBorder: CrossBorderPolicy.euOnly,
      requiresExplicitConsent: false,
      regulatoryRefs: [
        'GDPR Art. 7(1) burden of proof',
        'GDPR Art. 30 records of processing',
        'KVKK md. 7 silme talebi izlenebilirliği',
      ],
    ),
    DataClassRecord(
      id: 'business-billing',
      label: 'Business ops — billing + payment metadata',
      sensitivity: DataSensitivity.businessOps,
      exampleCollections: [
        'firestore://invoices',
        'firestore://stripe_customers',
      ],
      encryption: EncryptionRequirement.symmetricAtRestTls13InTransit,
      // 7y financial retention is the EU floor (most member states).
      minRetentionDays: 2555,
      maxRetentionDays: 3650,
      crossBorder: CrossBorderPolicy.sccPlusSupplementary,
      requiresExplicitConsent: false,
      regulatoryRefs: [
        'PCI DSS v4.0 §3.2 storage',
        'EU Directive 2006/112/EC §244 (VAT records 10y / 7y floor)',
      ],
    ),
    DataClassRecord(
      id: 'business-marketing-waitlist',
      label: 'Business ops — landing waitlist + beta signups',
      sensitivity: DataSensitivity.businessOps,
      exampleCollections: [
        'firestore://landing_waitlist',
        'firestore://beta_signups',
      ],
      encryption: EncryptionRequirement.symmetricAtRestTls13InTransit,
      // 12 months from last engagement; ad-hoc longer retention
      // requires DPO sign-off.
      minRetentionDays: 30,
      maxRetentionDays: 365,
      crossBorder: CrossBorderPolicy.euOnly,
      requiresExplicitConsent: true, // CAN-SPAM + KVKK md. 5/1
      regulatoryRefs: [
        'GDPR Art. 6(1)(a)',
        'CAN-SPAM Act §7704',
        'KVKK md. 5/1 ticari elektronik ileti',
      ],
    ),
    DataClassRecord(
      id: 'public-trust-marketing',
      label: 'Public — trust center JSON + marketing copy',
      sensitivity: DataSensitivity.publicData,
      exampleCollections: [
        'cdn://trust',
        'cdn://pricing',
        'gs://psyclinicai-public',
      ],
      encryption: EncryptionRequirement.tls13InTransitOnly,
      minRetentionDays: 0,
      // effectively unbounded — public commitment record.
      maxRetentionDays: 36500,
      crossBorder: CrossBorderPolicy.unrestricted,
      requiresExplicitConsent: false,
      regulatoryRefs: ['n/a — public surface'],
    ),
  ];

  static DataClassRecord? byId(String id) {
    for (final c in classes) {
      if (c.id == id) return c;
    }
    return null;
  }
}

/// True when the class requires AES-256 at rest. Drives the backup
/// catalog's encryption attestation invariant.
bool requiresStrongEncryption(DataClassRecord r) =>
    r.encryption == EncryptionRequirement.aes256AtRestTls13InTransit;

/// True when storing the class outside the EU/EEA requires SCC +
/// supplementary measures. Drives the cross-border audit step in
/// the DPIA register.
bool requiresSccForTransfer(DataClassRecord r) =>
    r.crossBorder == CrossBorderPolicy.sccPlusSupplementary;
