/// N4 — Backup catalog + DR (disaster recovery) runbook.
///
/// **Why this exists**: SOC 2 CC9.1 + ISO 27001 A.17 + HIPAA
/// §164.308(a)(7) all require the controller to document
/// (a) what is backed up, (b) on what cadence, (c) how long it
/// is kept, (d) how recovery is exercised, and (e) the RTO/RPO
/// commitments the customer can read on the trust center.
///
/// **Three downstream consumers** share this catalog:
///   1. Quarterly DR drill — the on-call follows
///      `recoveryStepsFor(target)` step by step + records actual
///      times.
///   2. Trust-center status page — renders RTO/RPO per target.
///   3. Customer DPA — copy-pastes the retention windows.
///
/// **Out of scope** (separate PRs):
///   * Cloud Function that runs `gcloud firestore export ...` on
///     the catalog's schedule.
///   * Terraform that provisions the GCS retention-locked
///     buckets per target.
///   * Quarterly drill scheduler + result log.
library;

/// What data class the target preserves.
enum BackupDataClass {
  /// Clinical records keyed by patient (intake, sessions,
  /// assessments, safety plans). PHI in scope.
  clinicalRecords,

  /// Forensic audit chain (clinic_audit_logs subcollection).
  /// PHI in `entity` field; hash chain integrity is the
  /// preservation invariant.
  auditChain,

  /// Consent records (consent_records + per-kind consent_entries).
  /// PHI-light but legally load-bearing under KVKK md. 12 +
  /// GDPR Art. 30.
  consentRecords,

  /// App secrets (Sentry DSN, Stripe webhook secret, Anthropic
  /// vendor keys). Never PHI but a compromise here equals total
  /// platform compromise.
  appSecrets,

  /// Marketing + billing data (Stripe customer ids, landing
  /// waitlist). PHI-free, business-continuity tier.
  businessOps,
}

/// Pinned backup target record.
class BackupTarget {
  const BackupTarget({
    required this.id,
    required this.name,
    required this.dataClass,
    required this.source,
    required this.sink,
    required this.scheduleHours,
    required this.retentionDays,
    required this.rpoMinutes,
    required this.rtoMinutes,
    required this.encryptionAtRest,
    required this.regulatoryRefs,
  });

  /// Stable id — used by the Cloud Function scheduler + the
  /// trust-center status page row.
  final String id;

  final String name;
  final BackupDataClass dataClass;

  /// Source path or system name (e.g. `firestore://default`,
  /// `firestore://clinic_audit_logs`, `kms://psyclinicai-secrets`).
  final String source;

  /// Sink (cold-storage target). E.g.
  /// `gs://psyclinicai-backups-eu/firestore-daily/`.
  final String sink;

  /// Backup cadence in hours. 24 = daily, 168 = weekly.
  final int scheduleHours;

  /// Retention in days. 2555 = 7 years (HIPAA §164.316(b)(2)(i)).
  final int retentionDays;

  /// Recovery Point Objective — max acceptable data loss in
  /// minutes. Lower = more frequent backups.
  final int rpoMinutes;

  /// Recovery Time Objective — max acceptable downtime in
  /// minutes from declaration of incident to fully restored.
  final int rtoMinutes;

  /// True when the sink encrypts at rest. We require this for
  /// every PHI-bearing target; non-PHI targets may relax.
  final bool encryptionAtRest;

  /// Citations the backup target is grounded in.
  final List<String> regulatoryRefs;
}

class BackupCatalog {
  const BackupCatalog._();

  /// Pinned catalog. Append-only; deprecated targets stay so
  /// historic DR drill logs still resolve.
  static const List<BackupTarget> entries = [
    BackupTarget(
      id: 'firestore_default_daily',
      name: 'Firestore default — daily',
      dataClass: BackupDataClass.clinicalRecords,
      source: 'firestore://default',
      sink: 'gs://psyclinicai-backups-eu/firestore-daily/',
      scheduleHours: 24,
      retentionDays: 90,
      rpoMinutes: 1440,
      rtoMinutes: 240,
      encryptionAtRest: true,
      regulatoryRefs: [
        'HIPAA §164.308(a)(7) Contingency Plan',
        'SOC 2 CC9.1',
        'GDPR Art. 32(1)(c) availability',
      ],
    ),
    BackupTarget(
      id: 'clinic_audit_logs_weekly_cold',
      name: 'Clinic audit chain — weekly cold storage',
      dataClass: BackupDataClass.auditChain,
      source: 'firestore://clinic_audit_logs',
      sink: 'gs://psyclinicai-audit-cold-eu/clinic-audit-weekly/',
      scheduleHours: 168,
      retentionDays: 2555,
      rpoMinutes: 10080,
      rtoMinutes: 480,
      encryptionAtRest: true,
      regulatoryRefs: [
        'HIPAA §164.316(b)(2)(i) 6-year audit retention',
        'KVKK md. 12 veri güvenliği yükümlülüğü',
        'ISO 27001 A.12.3 backups',
      ],
    ),
    BackupTarget(
      id: 'consent_records_daily',
      name: 'Consent records — daily',
      dataClass: BackupDataClass.consentRecords,
      source: 'firestore://consent_records,consent_entries',
      sink: 'gs://psyclinicai-backups-eu/consent-daily/',
      scheduleHours: 24,
      retentionDays: 2555,
      rpoMinutes: 1440,
      rtoMinutes: 120,
      encryptionAtRest: true,
      regulatoryRefs: [
        'GDPR Art. 30 records of processing',
        'KVKK md. 7 silme talebi izlenebilirliği',
      ],
    ),
    BackupTarget(
      id: 'app_secrets_kms_snapshot',
      name: 'App secrets — KMS snapshot',
      dataClass: BackupDataClass.appSecrets,
      source: 'kms://psyclinicai-secrets',
      sink: 'gs://psyclinicai-kms-snapshots-eu/',
      scheduleHours: 168,
      retentionDays: 365,
      rpoMinutes: 10080,
      rtoMinutes: 60,
      encryptionAtRest: true,
      regulatoryRefs: [
        'SOC 2 CC6.1 logical access',
        'ISO 27001 A.10 cryptography',
      ],
    ),
    BackupTarget(
      id: 'business_ops_daily',
      name: 'Stripe + landing waitlist — daily',
      dataClass: BackupDataClass.businessOps,
      source: 'firestore://landing_waitlist,beta_signups,dsar_requests',
      sink: 'gs://psyclinicai-backups-eu/business-ops-daily/',
      scheduleHours: 24,
      retentionDays: 365,
      rpoMinutes: 1440,
      rtoMinutes: 480,
      encryptionAtRest: true,
      regulatoryRefs: ['PCI DSS v4.0 §9.4'],
    ),
  ];

  static BackupTarget? byId(String id) {
    for (final t in entries) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Generic recovery step — the runbook a DR drill or a real
/// incident follows. Re-uses the shape of `OpsRunbookStep` /
/// `CssrsRunbookStep` so the dashboard renders them identically.
class RecoveryStep {
  const RecoveryStep({
    required this.label,
    required this.ownerRole,
    required this.targetMinutes,
    required this.action,
  });

  final String label;
  final String ownerRole;
  final int targetMinutes;
  final String action;
}

/// Standard restore protocol for a backup target. All targets
/// share the same skeleton (declare → locate → restore → verify
/// → flip → close), but the *restore + verify + flip* minutes
/// scale with the data class: a sealed KMS secret unwrap is
/// minutes, a full Firestore replay is hours.
///
/// The scaling table is the contract `projectedRestoreMinutes`
/// is held against by tests — any new data class MUST add a
/// branch here AND verify the sum stays under the target's RTO.
List<RecoveryStep> recoveryStepsFor(BackupTarget target) {
  // (restoreMinutes, verifyMinutes, flipMinutes) per class.
  final (int restore, int verify, int flip) = switch (target.dataClass) {
    // Large PHI corpus — restore + per-clinic reconciliation
    // dominates.
    BackupDataClass.clinicalRecords => (60, 30, 30),
    // Forensic chain — verify is the long pole (auditChainVerify
    // walks every entry).
    BackupDataClass.auditChain => (60, 90, 30),
    // Small slice; per-clinic count cheap.
    BackupDataClass.consentRecords => (20, 15, 20),
    // Sealed envelope; unwrap + rotate; no traffic flip.
    BackupDataClass.appSecrets => (10, 10, 10),
    // Business data — modest size, full smoke.
    BackupDataClass.businessOps => (60, 30, 30),
  };

  return [
    const RecoveryStep(
      label: 'Declare DR + open war-room',
      ownerRole: 'cto',
      targetMinutes: 5,
      action:
          'CTO declares DR. Open the incident channel + invite '
          'on-call + DPO + infra + legal. Stamp the start time.',
    ),
    RecoveryStep(
      label: 'Locate latest snapshot',
      ownerRole: 'infra',
      targetMinutes: 15,
      action:
          'List objects in ${target.sink}; identify the latest '
          'snapshot within the SLA window (RPO ${target.rpoMinutes} '
          'min). If none, declare data loss + brief DPO.',
    ),
    RecoveryStep(
      label: 'Restore to staging',
      ownerRole: 'infra',
      targetMinutes: restore,
      action:
          'Restore the snapshot to staging-${target.id}. Verify '
          'row count + smoke-test against the well-known fixture.',
    ),
    RecoveryStep(
      label: 'Verify integrity',
      ownerRole: 'infra',
      targetMinutes: verify,
      action: target.dataClass == BackupDataClass.auditChain
          ? 'Run auditChainVerify (J2) over the restored '
                'clinic_audit_logs slice. Chain MUST verify '
                'before proceeding — any break means a forensic '
                'incident.'
          : 'Smoke-test a representative read path. For '
                'PHI-bearing targets, run a per-clinic count '
                'reconciliation against the last-known good.',
    ),
    RecoveryStep(
      label: 'Flip traffic + close DR',
      ownerRole: 'cto',
      targetMinutes: flip,
      action:
          'Cut customer traffic to the restored source. Confirm '
          'green status from the on-call + the SLO dashboard. '
          'Close DR; schedule the post-incident review (CAPA).',
    ),
  ];
}

/// Sum of recovery step target minutes — the projected restore
/// time. MUST be ≤ the target's RTO; tests pin this invariant.
int projectedRestoreMinutes(BackupTarget target) {
  return recoveryStepsFor(
    target,
  ).fold<int>(0, (acc, s) => acc + s.targetMinutes);
}
