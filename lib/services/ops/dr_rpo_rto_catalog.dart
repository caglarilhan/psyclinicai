/// N22 — Disaster recovery RPO/RTO catalog (pinned helper).
///
/// **Why this exists**: HIPAA §164.308(a)(7) contingency plan, ISO
/// 27001 A.17.1 (information security continuity), and SOC 2 A1.2
/// (environmental + technical recovery) all require documented
/// Recovery Point Objective (RPO — max acceptable data loss) +
/// Recovery Time Objective (RTO — max acceptable downtime) per
/// service tier. Without a per-service number, every DR drill
/// scores "did we recover fast enough?" against a moving target
/// and the auditor walks away unsatisfied. This catalog pins those
/// numbers + the drill cadence that verifies them.
///
/// This catalog pins per service tier:
///   1. Tier id + service class (patientCare / clinicianAdmin /
///      tenantOnboarding / observability / publicMarketing).
///   2. RPO in minutes (max acceptable data loss).
///   3. RTO in minutes (max acceptable downtime).
///   4. Whether nightly backups must be tested by drill.
///   5. Drill cadence in days.
///   6. Regulatory anchor.
///
/// **Distinct from**:
///   * `EncryptionKeyRotationSchedule` (N20) — key lifecycle; N22
///     governs service-recovery posture.
///   * `DataRetentionClassCatalog` (K15) — retention floor + end-
///     of-life disposition; N22 governs RECOVERY targets.
///   * `StatusPageAudienceTierCatalog` (M6) — incident-time
///     notification matrix; N22 is the underlying RPO/RTO that
///     drives whether the incident is even declared.
///
/// **Out of scope** (separate PRs):
///   * DR drill runner (N11).
///   * Per-tenant RPO/RTO override (enterprise SKU).
///   * Cross-region failover automation.
library;

/// Service tier classes.
enum DrServiceTier {
  /// Patient-facing care surface (sessions, intake, telehealth).
  /// Tightest RPO/RTO — direct clinical-safety impact.
  patientCare,

  /// Clinician admin (schedule, chart access, copilot drafts).
  /// Tight RPO/RTO — disrupts the working day.
  clinicianAdmin,

  /// Tenant onboarding + billing.
  /// Loose RPO/RTO — can defer hours without patient impact.
  tenantOnboarding,

  /// Internal observability (Sentry, Grafana, audit log read
  /// replicas).
  /// Loosest — degraded telemetry does not hurt patients.
  observability,

  /// Public marketing site + status page.
  /// Loose RPO; tight RTO because outage hurts brand trust.
  publicMarketing,
}

class DrTierRecord {
  const DrTierRecord({
    required this.id,
    required this.tier,
    required this.description,
    required this.rpoMinutes,
    required this.rtoMinutes,
    required this.requiresBackupDrill,
    required this.drillCadenceDays,
    required this.regulatoryRefs,
  });

  final String id;
  final DrServiceTier tier;
  final String description;

  /// Max acceptable data loss in minutes. Tests pin monotonic
  /// ladder (patientCare tightest).
  final int rpoMinutes;

  /// Max acceptable downtime in minutes. Tests pin monotonic
  /// ladder.
  final int rtoMinutes;

  /// True when nightly backups must be exercised by a DR drill
  /// (the only proof that backups actually restore).
  final bool requiresBackupDrill;

  /// Days between scheduled DR drills. Higher-risk tiers drill
  /// more often.
  final int drillCadenceDays;

  final List<String> regulatoryRefs;
}

class DrRpoRtoCatalog {
  const DrRpoRtoCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned RPO/RTO table. Append-only.
  static const List<DrTierRecord> records = [
    DrTierRecord(
      id: 'patient-care',
      tier: DrServiceTier.patientCare,
      description:
          'Patient-facing care surface — telehealth session, intake form, clinician live chat. Outage here = patient-safety risk.',
      rpoMinutes: 5,
      rtoMinutes: 30,
      requiresBackupDrill: true,
      drillCadenceDays: 90,
      regulatoryRefs: [
        'HIPAA §164.308(a)(7) contingency plan',
        'HIPAA §164.308(a)(7)(ii)(B) disaster recovery plan',
        'ISO 27001 A.17.1.1 planning continuity',
        'ISO 27001 A.17.1.2 implementing continuity',
        'ISO 27001 A.17.1.3 verify, review and evaluate continuity',
        'SOC 2 A1.2 environmental + technical recovery',
        'Joint Commission NPSG 15.01.01 (suicide risk reduction)',
      ],
    ),
    DrTierRecord(
      id: 'clinician-admin',
      tier: DrServiceTier.clinicianAdmin,
      description:
          'Clinician admin surface — schedule, chart browse, copilot draft. Outage disrupts the working day but no immediate clinical-safety risk.',
      rpoMinutes: 15,
      rtoMinutes: 120,
      requiresBackupDrill: true,
      drillCadenceDays: 180,
      regulatoryRefs: [
        'HIPAA §164.308(a)(7) contingency plan',
        'ISO 27001 A.17.1.1',
        'ISO 27001 A.17.1.3',
        'SOC 2 A1.2',
      ],
    ),
    DrTierRecord(
      id: 'tenant-onboarding',
      tier: DrServiceTier.tenantOnboarding,
      description:
          'Tenant onboarding + billing surface. Outage delays new-clinic activation; can wait hours without patient impact.',
      rpoMinutes: 60,
      rtoMinutes: 480,
      requiresBackupDrill: false,
      drillCadenceDays: 365,
      regulatoryRefs: [
        'SOC 2 A1.2 environmental + technical recovery',
        'ISO 27001 A.17.1.1',
        'PCI DSS v4.0 §12.10 incident response plan',
      ],
    ),
    DrTierRecord(
      id: 'observability',
      tier: DrServiceTier.observability,
      description:
          'Sentry, Grafana, audit log read replicas. Degraded telemetry does not hurt patients but slows incident response.',
      rpoMinutes: 240,
      rtoMinutes: 720,
      requiresBackupDrill: false,
      drillCadenceDays: 365,
      regulatoryRefs: [
        'SOC 2 CC7.2 system monitoring',
        'ISO 27001 A.12.4.1 event logging',
      ],
    ),
    DrTierRecord(
      id: 'public-marketing',
      tier: DrServiceTier.publicMarketing,
      description:
          'Public marketing site + status page. Loose RPO (static content); tight-ish RTO because outage damages brand trust.',
      rpoMinutes: 1440,
      rtoMinutes: 60,
      requiresBackupDrill: false,
      drillCadenceDays: 365,
      regulatoryRefs: [
        'SOC 2 CC2.3 communication of objectives',
        'ISO 27001 A.17.1.1',
      ],
    ),
  ];

  static DrTierRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static DrTierRecord? byTier(DrServiceTier t) {
    for (final r in records) {
      if (r.tier == t) return r;
    }
    return null;
  }
}

/// True when the service tier requires a nightly-backup DR drill
/// (the only proof that backups actually restore). Drives the
/// drill scheduler.
bool requiresBackupDrill(DrServiceTier t) {
  final r = DrRpoRtoCatalog.byTier(t);
  return r?.requiresBackupDrill ?? false;
}
