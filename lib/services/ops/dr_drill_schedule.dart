/// N11 — Disaster recovery drill schedule (pinned helper).
///
/// **Why this exists**: N4 (`backup_recovery_plan.dart`) defines
/// recovery steps per backup target, but a runbook nobody rehearses
/// rots. HIPAA §164.308(a)(7)(ii)(D) requires "testing and revision
/// procedures" for the contingency plan; SOC 2 CC9.2 expects
/// documented drill evidence. This catalog pins which target gets
/// rehearsed at what cadence, who signs off, and how the result
/// lands in the evidence ledger.
///
/// **Distinct from N7 access review schedule**: that catalog rehearses
/// *who has access*; this one rehearses *can we get the data back*.
///
/// **Out of scope** (separate PRs):
///   * Scheduler Cloud Function that fires the drill window.
///   * Drill-result log writer + trust-center widget.
///   * Wire backup_recovery_plan to surface "last drilled" per target.
library;

/// Cadence at which the drill MUST be rehearsed.
enum DrillCadence {
  /// Every quarter (calendar quarters: Jan / Apr / Jul / Oct).
  quarterly,

  /// Twice a year (Jan + Jul).
  semiAnnual,

  /// Once a year (Jan).
  annual,
}

/// What kind of rehearsal — drives the scope + duration.
enum DrillScope {
  /// Restore a small slice + smoke test in staging.
  partialRestoreSmoke,

  /// Full restore + per-clinic count reconciliation in staging.
  fullRestoreReconciliation,

  /// Live failover to the standby region.
  liveFailover,
}

/// One pinned drill record.
class DrDrillRecord {
  const DrDrillRecord({
    required this.id,
    required this.backupTargetId,
    required this.cadence,
    required this.scope,
    required this.signOffOwner,
    required this.signOffSlaDays,
    required this.evidencePathTemplate,
    required this.regulatoryRefs,
  });

  /// Stable id used by the scheduler + the evidence ledger.
  final String id;

  /// MUST match an id in `BackupCatalog.entries`; parity pinned.
  final String backupTargetId;

  final DrillCadence cadence;
  final DrillScope scope;

  /// Single accountable role who signs the drill report.
  final String signOffOwner;

  /// Days from the drill start to the signed result hitting the
  /// evidence ledger. Defaults to 7 for quarterly, 14 for slower.
  final int signOffSlaDays;

  /// Where the signed result lives. `<YYYYqN>` or `<YYYY-mm>` is
  /// substituted by the scheduler.
  final String evidencePathTemplate;

  final List<String> regulatoryRefs;
}

class DrDrillSchedule {
  const DrDrillSchedule._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned drill catalog. Append-only.
  static const List<DrDrillRecord> drills = [
    DrDrillRecord(
      id: 'drill-firestore-default-quarterly',
      backupTargetId: 'firestore_default_daily',
      cadence: DrillCadence.quarterly,
      scope: DrillScope.fullRestoreReconciliation,
      signOffOwner: 'cto',
      signOffSlaDays: 7,
      evidencePathTemplate:
          'docs/security/evidence/<YYYYqN>/dr-firestore-default.MANUAL.md',
      regulatoryRefs: [
        'HIPAA §164.308(a)(7)(ii)(D) testing + revision',
        'SOC 2 CC9.2 vendor + business continuity',
        'ISO 27001 A.17.1.3 verify continuity',
      ],
    ),
    DrDrillRecord(
      id: 'drill-clinic-audit-chain-semi-annual',
      backupTargetId: 'clinic_audit_logs_weekly_cold',
      cadence: DrillCadence.semiAnnual,
      scope: DrillScope.fullRestoreReconciliation,
      signOffOwner: 'ciso',
      signOffSlaDays: 14,
      evidencePathTemplate:
          'docs/security/evidence/<YYYY-mm>/dr-audit-chain.MANUAL.md',
      regulatoryRefs: [
        'HIPAA §164.316(b)(2)(i) 6-year retention',
        'SOC 2 CC7.2 system monitoring',
        'ISO 27001 A.12.3 backups',
      ],
    ),
    DrDrillRecord(
      id: 'drill-consent-records-quarterly',
      backupTargetId: 'consent_records_daily',
      cadence: DrillCadence.quarterly,
      scope: DrillScope.partialRestoreSmoke,
      signOffOwner: 'compliance_officer',
      signOffSlaDays: 7,
      evidencePathTemplate:
          'docs/security/evidence/<YYYYqN>/dr-consent-records.MANUAL.md',
      regulatoryRefs: [
        'GDPR Art. 7(1) burden of proof',
        'KVKK md. 7 silme talebi izlenebilirliği',
      ],
    ),
    DrDrillRecord(
      id: 'drill-app-secrets-annual',
      backupTargetId: 'app_secrets_kms_snapshot',
      cadence: DrillCadence.annual,
      scope: DrillScope.partialRestoreSmoke,
      signOffOwner: 'ciso',
      signOffSlaDays: 14,
      evidencePathTemplate:
          'docs/security/evidence/<YYYY>/dr-app-secrets.MANUAL.md',
      regulatoryRefs: ['SOC 2 CC6.1', 'NIST SP 800-57 §5.3.6'],
    ),
    DrDrillRecord(
      id: 'drill-business-ops-annual',
      backupTargetId: 'business_ops_daily',
      cadence: DrillCadence.annual,
      scope: DrillScope.partialRestoreSmoke,
      signOffOwner: 'cfo',
      signOffSlaDays: 14,
      evidencePathTemplate:
          'docs/security/evidence/<YYYY>/dr-business-ops.MANUAL.md',
      regulatoryRefs: ['PCI DSS v4.0 §12.10.5'],
    ),
  ];

  static DrDrillRecord? byId(String id) {
    for (final d in drills) {
      if (d.id == id) return d;
    }
    return null;
  }

  static List<DrDrillRecord> drillsForTarget(String backupTargetId) {
    return drills.where((d) => d.backupTargetId == backupTargetId).toList();
  }
}

/// Cron expression each cadence renders to. Drills run on the 1st
/// of the cadence month at 02:00 UTC to avoid clinical traffic.
String cronForDrillCadence(DrillCadence cadence) {
  switch (cadence) {
    case DrillCadence.quarterly:
      return '0 2 1 1,4,7,10 *';
    case DrillCadence.semiAnnual:
      return '0 2 1 1,7 *';
    case DrillCadence.annual:
      return '0 2 1 1 *';
  }
}
