/// SOC 2 — Trust Services Criteria evidence registry (Sprint 14).
///
/// Maps each AICPA TSC criterion we plan to be audited against to the
/// artefact that proves we implement it. The Trust Center reads this
/// list to render a "controls matrix" for prospective customers and
/// to answer auditor questionnaires deterministically.
///
/// Status is conservative — "implemented" requires the linked
/// artefact to exist AND be reviewed within the past 12 months.
library;

enum Soc2Status {
  implemented,
  partial,
  planned,
}

class Soc2Control {
  const Soc2Control({
    required this.criterion,
    required this.category,
    required this.title,
    required this.status,
    required this.evidence,
    required this.lastReviewed,
  });

  /// AICPA TSC reference (e.g. "CC6.1", "A1.2").
  final String criterion;

  /// Trust Services Category — Security / Availability / Processing
  /// Integrity / Confidentiality / Privacy.
  final String category;

  final String title;
  final Soc2Status status;

  /// File path or runbook URL that backs the control.
  final String evidence;

  /// YYYY-MM stamp; controls older than 12 months downgrade to
  /// `partial` until re-reviewed.
  final String lastReviewed;
}

class Soc2EvidenceRegistry {
  const Soc2EvidenceRegistry._();

  static const String lastReviewed = '2026-06';

  /// Observation window opens after this date — recorded so the
  /// Trust Center can show "X days remaining" before the Type I
  /// report can be issued.
  static const String observationOpensAt = '2026-09-01';

  static const List<Soc2Control> controls = [
    Soc2Control(
      criterion: 'CC6.1',
      category: 'Security',
      title: 'Logical access — authentication',
      status: Soc2Status.implemented,
      evidence: 'lib/screens/auth/mfa_setup_screen.dart + Firebase MFA',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'CC6.6',
      category: 'Security',
      title: 'Boundary protection — encrypted transit',
      status: Soc2Status.implemented,
      evidence: 'TLS 1.3 enforced by Firebase Hosting; Anthropic relay TLS',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'CC7.2',
      category: 'Security',
      title: 'System monitoring — security events',
      status: Soc2Status.partial,
      evidence: 'audit_logs collection + retention cron (Sprint 9)',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'CC7.4',
      category: 'Security',
      title: 'Incident response',
      status: Soc2Status.implemented,
      evidence: 'lib/screens/trust/incident_response_screen.dart',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'CC8.1',
      category: 'Security',
      title: 'Change management',
      status: Soc2Status.partial,
      evidence: 'docs/RUNBOOK_CLOUD_FUNCTIONS_IAM.md + git history',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'A1.2',
      category: 'Availability',
      title: 'Backup + recovery',
      status: Soc2Status.partial,
      evidence: 'Firestore daily exports (planned Sprint 15)',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'C1.1',
      category: 'Confidentiality',
      title: 'Data classification + handling',
      status: Soc2Status.implemented,
      evidence: 'lib/utils/pii_redaction.dart + ConsentGuard fail-closed',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'P3.1',
      category: 'Privacy',
      title: 'Notice + choice — consent capture',
      status: Soc2Status.implemented,
      evidence: 'lib/models/consent_record.dart',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'P5.1',
      category: 'Privacy',
      title: 'Access to personal data',
      status: Soc2Status.implemented,
      evidence: 'lib/utils/dsar_export_zip.dart + DPIA reference',
      lastReviewed: '2026-06',
    ),
    Soc2Control(
      criterion: 'P6.1',
      category: 'Privacy',
      title: 'Disposal of personal data',
      status: Soc2Status.implemented,
      evidence: 'functions/src/account_deletion_purge.ts (Sprint 9)',
      lastReviewed: '2026-06',
    ),
  ];

  /// Subset rendered as "audit-ready" on the trust center.
  static List<Soc2Control> get implementedControls => controls
      .where((c) => c.status == Soc2Status.implemented)
      .toList(growable: false);

  /// Controls that still need work before observation opens.
  static List<Soc2Control> get gaps => controls
      .where((c) => c.status != Soc2Status.implemented)
      .toList(growable: false);

  static Soc2Control? byCriterion(String criterion) {
    for (final c in controls) {
      if (c.criterion == criterion) return c;
    }
    return null;
  }
}
