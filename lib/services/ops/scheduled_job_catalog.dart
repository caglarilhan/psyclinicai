/// O10 — Scheduled job catalog (pinned helper).
///
/// **Why this exists**: SOC 2 CC7.1 (detection + monitoring), SOC 2
/// A1.2 (recovery), and ISO 27001 A.12.1.3 (capacity management)
/// all rely on the platform's scheduled jobs running on time and
/// failing loudly. A silently-failed nightly backup is the worst
/// possible discovery during a DR drill. A silently-skipped key
/// rotation is the worst possible discovery during an audit. This
/// catalog pins every scheduled job with its cadence, owner,
/// alert threshold (max consecutive failures before P1), and
/// whether idempotent re-runs are safe.
///
/// This catalog pins per scheduled job:
///   1. Stable job id + plain-English description.
///   2. Cron-style cadence label (e.g. "nightly-0200-utc",
///      "weekly-sunday", "every-15-min").
///   3. Owner role (sre / data-engineer / clinician-ops).
///   4. Max consecutive failures before P1 incident raise.
///   5. Whether job is safe to re-run (idempotent).
///   6. Regulatory anchor.
///
/// **Distinct from**:
///   * `DrRpoRtoCatalog` (N22) — service-recovery TARGETS; O10 pins
///     the SCHEDULED JOBS that satisfy those targets.
///   * `EncryptionKeyRotationSchedule` (N20) — key-rotation policy;
///     O10 includes the rotation JOB that executes that policy.
///   * `DataRetentionClassCatalog` (K15) — retention POLICY; O10
///     includes the purge job that executes the retention.
///
/// **Out of scope** (separate PRs):
///   * Scheduled-job runner implementation.
///   * PagerDuty integration for alerts.
///   * Per-tenant job-execution audit log.
library;

/// Owning role for each scheduled job.
enum JobOwner {
  /// Site Reliability Engineering team.
  sre,

  /// Data Engineering team.
  dataEngineering,

  /// Clinician operations / nursing escalation team.
  clinicianOps,

  /// Compliance / DPO team.
  compliance,
}

class ScheduledJobRecord {
  const ScheduledJobRecord({
    required this.id,
    required this.description,
    required this.cadenceLabel,
    required this.owner,
    required this.maxConsecutiveFailuresBeforeP1,
    required this.idempotent,
    required this.regulatoryRefs,
  });

  /// Stable job id (kebab-case).
  final String id;
  final String description;

  /// Cadence label — human-readable, drives the dashboard tooltip
  /// + the cron expression generator (out of scope).
  final String cadenceLabel;

  final JobOwner owner;

  /// Max consecutive failures before the runner raises a P1
  /// incident. Tests pin: PHI-critical jobs <= 2, lower-risk
  /// jobs <= 5.
  final int maxConsecutiveFailuresBeforeP1;

  /// True when the job is safe to re-run on the same input
  /// without side effects. Required for jobs the runner may
  /// retry automatically.
  final bool idempotent;

  final List<String> regulatoryRefs;
}

class ScheduledJobCatalog {
  const ScheduledJobCatalog._();

  /// YYYY-MM stamp — drives the ops "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned scheduled job table. Append-only.
  static const List<ScheduledJobRecord> records = [
    ScheduledJobRecord(
      id: 'nightly-backup',
      description:
          'Take encrypted nightly backup of patient DB + KMS handle; ship to offsite cold storage. Drives N20 backup-encryption-key + K15 backup-blob retention.',
      cadenceLabel: 'nightly-0200-utc',
      owner: JobOwner.sre,
      maxConsecutiveFailuresBeforeP1: 1,
      idempotent: true,
      regulatoryRefs: [
        'HIPAA §164.308(a)(7) contingency plan',
        'HIPAA §164.308(a)(7)(ii)(A) data backup plan',
        'ISO 27001 A.12.3.1 information backup',
        'SOC 2 A1.2 environmental + technical recovery',
      ],
    ),
    ScheduledJobRecord(
      id: 'jwt-signing-key-rotation',
      description:
          'Rotate JWT signing key per N20 (90 days). Re-publish JWKS; retain old key for verify-window equal to max JWT TTL.',
      cadenceLabel: 'every-90-days-0300-utc',
      owner: JobOwner.sre,
      maxConsecutiveFailuresBeforeP1: 1,
      idempotent: true,
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 signature key cryptoperiod',
        'HIPAA §164.312(d) person/entity authentication',
        'SOC 2 CC6.1 logical access',
      ],
    ),
    ScheduledJobRecord(
      id: 'audit-log-hmac-rotation',
      description:
          'Rotate audit-log HMAC chain key per N20 (180 days). Old keys retained for verification.',
      cadenceLabel: 'every-180-days-0300-utc',
      owner: JobOwner.sre,
      maxConsecutiveFailuresBeforeP1: 1,
      idempotent: true,
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 MAC key cryptoperiod',
        'HIPAA §164.312(b) audit controls',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
    ScheduledJobRecord(
      id: 'retention-purge-clinical-record',
      description:
          'Purge clinical records past K15 max retention (30y); anonymise + cold-archive copy retained for research value (Recital 26).',
      cadenceLabel: 'monthly-1st-0400-utc',
      owner: JobOwner.compliance,
      maxConsecutiveFailuresBeforeP1: 2,
      idempotent: true,
      regulatoryRefs: [
        'GDPR Art. 5(1)(e) storage limitation',
        'GDPR Art. 17 right to erasure',
        'HIPAA §164.530(j)(2) documentation',
        'ISO 27001 A.18.1.3 protection of records',
      ],
    ),
    ScheduledJobRecord(
      id: 'product-analytics-anonymise',
      description:
          'Anonymise product-analytics events past 2y (K15 product-analytics max retention). Pseudonyms unlinked.',
      cadenceLabel: 'weekly-sunday-0400-utc',
      owner: JobOwner.dataEngineering,
      maxConsecutiveFailuresBeforeP1: 3,
      idempotent: true,
      regulatoryRefs: [
        'GDPR Art. 5(1)(c) data minimisation',
        'GDPR Art. 5(1)(e) storage limitation',
        'GDPR Recital 26 anonymisation',
      ],
    ),
    ScheduledJobRecord(
      id: 'cssrs-positive-followup-sweep',
      description:
          'Sweep for CSSRS-positive patients with no clinician follow-up logged in 24h; raise to clinician-ops for outreach (Joint Commission NPSG 15.01.01).',
      cadenceLabel: 'every-15-min',
      owner: JobOwner.clinicianOps,
      maxConsecutiveFailuresBeforeP1: 2,
      idempotent: true,
      regulatoryRefs: [
        'Joint Commission NPSG 15.01.01 (suicide risk reduction)',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    ScheduledJobRecord(
      id: 'dsar-deadline-sweep',
      description:
          'Sweep open DSAR queue for items approaching their K17 deadline; raise to compliance team for triage.',
      cadenceLabel: 'daily-0900-utc',
      owner: JobOwner.compliance,
      maxConsecutiveFailuresBeforeP1: 3,
      idempotent: true,
      regulatoryRefs: [
        'GDPR Art. 12(3) deadline',
        'GDPR Art. 15 / 16 / 17 / 18 / 20 / 21',
      ],
    ),
    ScheduledJobRecord(
      id: 'auth-event-purge',
      description:
          'Purge auth-event records past K15 max retention (7y). Hard-delete.',
      cadenceLabel: 'monthly-1st-0500-utc',
      owner: JobOwner.sre,
      maxConsecutiveFailuresBeforeP1: 3,
      idempotent: true,
      regulatoryRefs: [
        'GDPR Art. 5(1)(e) storage limitation',
        'HIPAA §164.312(b) audit controls',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
  ];

  static ScheduledJobRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static List<ScheduledJobRecord> byOwner(JobOwner o) {
    return records.where((r) => r.owner == o).toList();
  }
}

/// True when the job runner may safely retry the job after a
/// transient failure (idempotent).
bool isSafeToRetry(String jobId) {
  final r = ScheduledJobCatalog.byId(jobId);
  return r?.idempotent ?? false;
}
