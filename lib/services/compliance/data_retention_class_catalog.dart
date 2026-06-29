/// K15 — Data retention class catalog (pinned helper).
///
/// **Why this exists**: GDPR Art. 5(1)(e) storage-limitation +
/// HIPAA §164.316(b)(2)(i) 6-year audit retention + ISO 27001
/// A.18.1.3 records-protection + national health-records statutes
/// all require a documented retention schedule per data category.
/// `TenantIsolationPolicyCatalog` (O8) says which domains are in
/// the tenant-deletion cascade but does not pin the regulatory
/// retention floor. This catalog pins the floor + ceiling per
/// data category so the purge job runner has a single source of
/// truth.
///
/// This catalog pins per data category:
///   1. Retention class id + category (clinicalRecord / auditLog /
///      consentRecord / etc.).
///   2. Minimum retention years REQUIRED by regulation.
///   3. Maximum retention years allowed (GDPR Art. 5(1)(e) storage
///      limitation — must not exceed without justification).
///   4. Disposition action at end of retention (hardDelete /
///      anonymise / coldArchive).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `TenantIsolationPolicyCatalog` (O8) — whether a domain is
///     IN the tenant-deletion cascade; K15 governs WHEN a record
///     is purged at end of life regardless of tenant offboarding.
///   * `RopaRegistry` (GDPR Art. 30) — describes WHAT is processed;
///     K15 pins HOW LONG.
///   * `EncryptionKeyRotationSchedule` (N20) — key cryptoperiod;
///     K15 is data lifecycle, not key lifecycle.
///
/// **Out of scope** (separate PRs):
///   * Retention job runner.
///   * Per-tenant retention override (legal-hold workflow).
///   * Cold-archive backend selection.
library;

/// Data categories the platform stores.
enum DataCategory {
  /// Patient clinical record (SOAP notes, assessments, treatment
  /// plans, sessions, copilot drafts).
  clinicalRecord,

  /// Tamper-evident audit log entry.
  auditLog,

  /// Consent record (consent given / withdrawn / refreshed).
  consentRecord,

  /// Authentication event (login, MFA challenge, password change).
  authEvent,

  /// Billing record (invoice, payment attempt, dunning email).
  billingRecord,

  /// Marketing / product analytics event.
  productAnalytics,

  /// Crash + error telemetry.
  errorTelemetry,

  /// Backup blob (offsite cold storage).
  backupBlob,
}

/// Disposition action at end of retention.
enum DispositionAction {
  /// Cryptographic hard delete — record + key destroyed.
  hardDelete,

  /// Anonymise — strip direct + indirect identifiers, keep
  /// statistical shape (Art. 4(5) pseudonymisation NOT enough;
  /// must be irreversible per Recital 26).
  anonymise,

  /// Move to long-term cold archive for legal/regulator access;
  /// no further processing.
  coldArchive,
}

class DataRetentionRecord {
  const DataRetentionRecord({
    required this.id,
    required this.category,
    required this.description,
    required this.minRetentionYears,
    required this.maxRetentionYears,
    required this.dispositionAtEnd,
    required this.regulatoryRefs,
  });

  final String id;
  final DataCategory category;
  final String description;

  /// Minimum years the record MUST be retained (regulatory floor).
  /// Tests pin per-category.
  final int minRetentionYears;

  /// Maximum years the record MAY be retained without fresh
  /// justification (GDPR Art. 5(1)(e) storage limitation).
  final int maxRetentionYears;

  final DispositionAction dispositionAtEnd;

  final List<String> regulatoryRefs;
}

class DataRetentionClassCatalog {
  const DataRetentionClassCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned retention class table. Append-only.
  static const List<DataRetentionRecord> records = [
    DataRetentionRecord(
      id: 'clinical-record',
      category: DataCategory.clinicalRecord,
      description:
          'Patient clinical record (SOAP, assessments, treatment plans, copilot drafts). Default 10 years; some jurisdictions require longer (UK NHS 20y minors, US state laws vary).',
      minRetentionYears: 10,
      maxRetentionYears: 30,
      dispositionAtEnd: DispositionAction.anonymise,
      regulatoryRefs: [
        'GDPR Art. 5(1)(e) storage limitation',
        'GDPR Art. 9 special category (basis for longer retention)',
        'HIPAA §164.530(j)(2) documentation 6-year minimum',
        'NHS England Records Management Code (2023) — 10y adult, 20y minors',
        'ISO 27001 A.18.1.3 protection of records',
        'Recital 26 anonymisation guidance',
      ],
    ),
    DataRetentionRecord(
      id: 'audit-log',
      category: DataCategory.auditLog,
      description:
          'Tamper-evident audit log entry. HIPAA §164.316 6-year minimum; SOC 2 expects 7y; we pin 7y to dual-cover.',
      minRetentionYears: 7,
      maxRetentionYears: 10,
      dispositionAtEnd: DispositionAction.coldArchive,
      regulatoryRefs: [
        'HIPAA §164.316(b)(2)(i) 6-year retention',
        'SOC 2 CC7.2 system monitoring (7-year industry norm)',
        'EU AI Act Art. 12 record-keeping',
        'ISO 27001 A.12.4.1 event logging',
      ],
    ),
    DataRetentionRecord(
      id: 'consent-record',
      category: DataCategory.consentRecord,
      description:
          'Consent given / withdrawn / refreshed. GDPR Art. 7(1) requires demonstrable consent; bookkeeping until challenge window expires.',
      minRetentionYears: 7,
      maxRetentionYears: 10,
      dispositionAtEnd: DispositionAction.coldArchive,
      regulatoryRefs: [
        'GDPR Art. 7(1) demonstrable consent',
        'GDPR Art. 30 records of processing (consent is processing)',
        'HIPAA §164.530(j) documentation 6-year',
        'EDPB Guidelines 05/2020 on consent §5.1.4',
      ],
    ),
    DataRetentionRecord(
      id: 'auth-event',
      category: DataCategory.authEvent,
      description:
          'Authentication event (login, MFA challenge, password change). Security investigation window + SOC 2 audit support.',
      minRetentionYears: 1,
      maxRetentionYears: 7,
      dispositionAtEnd: DispositionAction.hardDelete,
      regulatoryRefs: [
        'HIPAA §164.312(b) audit controls',
        'SOC 2 CC7.2 system monitoring',
        'ISO 27001 A.12.4.3 administrator + operator logs',
        'NIST SP 800-92 log management',
      ],
    ),
    DataRetentionRecord(
      id: 'billing-record',
      category: DataCategory.billingRecord,
      description:
          'Invoice, payment, dunning record. EU tax law 10y (DE HGB §257) / US IRS 7y norm.',
      minRetentionYears: 7,
      maxRetentionYears: 10,
      dispositionAtEnd: DispositionAction.coldArchive,
      regulatoryRefs: [
        'DE HGB §257 books + records 10-year',
        'US IRS guidance 7-year (typical norm)',
        'PCI DSS v4.0 §3.2 retain only what is needed',
        'GDPR Art. 6(1)(c) legal obligation basis',
      ],
    ),
    DataRetentionRecord(
      id: 'product-analytics',
      category: DataCategory.productAnalytics,
      description:
          'Pseudonymised funnel + activation events. Short retention by design — drives reports, not audits.',
      minRetentionYears: 0,
      maxRetentionYears: 2,
      dispositionAtEnd: DispositionAction.anonymise,
      regulatoryRefs: [
        'GDPR Art. 5(1)(c) data minimisation',
        'GDPR Art. 5(1)(e) storage limitation',
        'ePrivacy Directive Art. 5(3) non-essential analytics',
      ],
    ),
    DataRetentionRecord(
      id: 'error-telemetry',
      category: DataCategory.errorTelemetry,
      description:
          'Crash + error reports. Long enough to triage + ship fix + verify lack of regression.',
      minRetentionYears: 0,
      maxRetentionYears: 1,
      dispositionAtEnd: DispositionAction.hardDelete,
      regulatoryRefs: [
        'GDPR Art. 5(1)(c) data minimisation',
        'GDPR Art. 5(1)(e) storage limitation',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
    DataRetentionRecord(
      id: 'backup-blob',
      category: DataCategory.backupBlob,
      description:
          'Offsite cold backup blob. Encrypted with backup-encryption-key (N20). 90 days hot + 1 year cold for disaster recovery + ransomware rollback.',
      minRetentionYears: 1,
      maxRetentionYears: 1,
      dispositionAtEnd: DispositionAction.hardDelete,
      regulatoryRefs: [
        'HIPAA §164.308(a)(7) contingency plan',
        'ISO 27001 A.17.1.3 verify, review and evaluate continuity',
        'SOC 2 A1.2 environmental + technical recovery',
      ],
    ),
  ];

  static DataRetentionRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static DataRetentionRecord? byCategory(DataCategory c) {
    for (final r in records) {
      if (r.category == c) return r;
    }
    return null;
  }
}

/// True when the provided retention duration satisfies the
/// regulatory floor for the data category. Drives the purge job
/// runner to refuse early deletion requests.
bool meetsMinRetention(DataCategory c, int years) {
  final r = DataRetentionClassCatalog.byCategory(c);
  if (r == null) return false;
  return years >= r.minRetentionYears;
}
