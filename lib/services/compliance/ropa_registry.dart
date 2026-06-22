/// GDPR Art. 30 — Record of Processing Activities (RoPA).
///
/// Art. 30 is the underrated half of GDPR: every controller must keep a
/// living register of every distinct processing activity. The auditor
/// walks down this register and pattern-matches it against:
///   • Art. 6 / 9 lawful basis,
///   • Art. 28 sub-processor contracts,
///   • Art. 32 security measures,
///   • Art. 5(1)(e) storage limitation,
///   • Art. 44+ third-country transfer mechanism.
///
/// Rows here are concise — long-form is in the DPA and the
/// sub-processor registry. The Trust Center reads this list to render a
/// human-readable table for prospective customers.
///
/// Status is conservative; a row that is missing one cell stays out of
/// the registry until the cell is filled.
library;

/// One end-to-end processing activity.
class RopaActivity {
  const RopaActivity({
    required this.id,
    required this.purpose,
    required this.dataCategories,
    required this.dataSubjects,
    required this.lawfulBasis,
    required this.retention,
    required this.recipients,
    required this.transferMechanism,
    required this.securityMeasures,
    this.dpiaReference,
    this.crossBorderRecipients = const [],
  });

  /// Slug used for cross-linking from the DPA and sub-processor registry.
  final String id;

  /// Why we process the data, in one sentence.
  final String purpose;

  /// Categories per Art. 4(1) — plus Art. 9 markers when special category.
  final List<String> dataCategories;

  /// Whose data — patients, clinicians, prospects, billing contacts, …
  final String dataSubjects;

  /// Article + plain-English basis ("Art. 9(2)(h) — health care").
  final String lawfulBasis;

  /// Storage limitation — short, audit-friendly ("6 years post-discharge").
  final String retention;

  /// Internal teams / external sub-processors that touch the row.
  final List<String> recipients;

  /// Empty when the data never leaves the EEA. Otherwise the lawful
  /// transfer mechanism — SCC + TIA, UK IDTA, adequacy decision.
  final String transferMechanism;

  /// Short list of the Art. 32 measures that materially protect this
  /// activity (encryption, access control, pseudonymisation, …).
  final List<String> securityMeasures;

  /// Path to the DPIA document when Art. 35 triggers (high risk +
  /// special category + cross-border, mainly). Null when the activity
  /// did not require one.
  final String? dpiaReference;

  /// Structured cross-border recipients. Use when [transferMechanism]
  /// is non-empty so the trust center can render a recipient table.
  final List<RopaCrossBorderRecipient> crossBorderRecipients;
}

/// A single cross-border recipient with the lawful transfer
/// instrument that backs it. Designed for the trust center table —
/// every row is auditable on its own.
class RopaCrossBorderRecipient {
  const RopaCrossBorderRecipient({
    required this.name,
    required this.country,
    required this.instrument,
    required this.tiaReference,
  });

  /// Sub-processor name (matches the sub-processor registry).
  final String name;

  /// ISO-3166-1 alpha-2 country code (US, GB, …) or "EEA" when stays
  /// inside the European Economic Area.
  final String country;

  /// SCC clause set, UK IDTA, adequacy decision text, …
  final String instrument;

  /// Path or URL to the Transfer Impact Assessment artefact.
  final String tiaReference;
}

class RopaRegistry {
  const RopaRegistry._();

  /// YYYY-MM-DD stamp surfaced on the trust center.
  static const String lastReviewed = '2026-06-02';

  /// Owning team / role accountable for keeping the register current.
  static const String controller =
      'PsyClinicAI B.V. — Data Protection Officer (DPO)';

  /// Inbox for Art. 38(4) data-subject and supervisory-authority
  /// correspondence. Surfaced verbatim on the trust center and in
  /// every DSAR / breach response template.
  static const String dpoContact = 'dpo@psyclinicai.com';

  static const List<RopaActivity> activities = [
    RopaActivity(
      id: 'clinical-record-keeping',
      purpose: 'Maintain longitudinal patient clinical records.',
      dataCategories: [
        'Identity (name, DoB)',
        'Contact (email, phone)',
        'Special category — health (Art. 9)',
        'Clinical free-text (session notes, treatment plans)',
      ],
      dataSubjects: 'Patients',
      lawfulBasis:
          'Art. 9(2)(h) — health care; Art. 6(1)(b) — performance of '
          'contract with the clinician.',
      retention:
          '6 years after end of treatment (HIPAA §164.316 alignment); '
          'longer when local clinical retention rules require.',
      recipients: ['Clinician (controller)', 'Firebase (EU)', 'Hetzner (EU)'],
      transferMechanism: '',
      securityMeasures: [
        'Field-level audit logging (HIPAA §164.312(b))',
        'Firestore deny-by-default rules',
        'At-rest encryption (Google EU)',
      ],
    ),
    RopaActivity(
      id: 'ai-assistance',
      purpose:
          "Generate decision-support drafts (treatment plan suggestions, "
          "session note structuring) at the clinician's explicit request.",
      dataCategories: [
        'Clinical free-text segments',
        'Patient pseudo-identifier (no name)',
      ],
      dataSubjects: 'Patients',
      lawfulBasis:
          'Art. 9(2)(a) — explicit consent (recorded in '
          'consent_records.ai_assistance_consent).',
      retention: 'Prompt + response retained 30 days for audit, then purged.',
      recipients: ['Anthropic (US, BYOK relay)'],
      transferMechanism:
          'SCC (2021/914) + Transfer Impact Assessment; clinician-side '
          'BYOK keeps key custody with the EU controller.',
      securityMeasures: [
        'ConsentGuard fail-closed gate',
        'PII redaction before relay (PromptSafety.fence)',
        'Per-prompt audit log entry',
      ],
      // Art. 9 special category + cross-border + large-scale ⇒ Art. 35
      // DPIA mandatory. Path tracked here so the trust center can link
      // directly to the artefact during a vendor questionnaire.
      dpiaReference: 'docs/compliance/DPIA_AI_ASSISTANCE.md',
      crossBorderRecipients: [
        RopaCrossBorderRecipient(
          name: 'Anthropic, PBC',
          country: 'US',
          instrument: 'SCC 2021/914 Module 2 (controller → processor)',
          tiaReference: 'docs/compliance/TIA_ANTHROPIC.md',
        ),
      ],
    ),
    RopaActivity(
      id: 'billing-and-superbill',
      purpose: 'Issue invoices and produce insurance-ready superbills.',
      dataCategories: [
        'Identity',
        'Diagnosis code (ICD-10)',
        'Service code (CPT)',
        'Payment metadata',
      ],
      dataSubjects: 'Patients · billing contacts',
      lawfulBasis: 'Art. 6(1)(b) + Art. 6(1)(c) tax/accounting obligation.',
      retention:
          '7 years (statutory tax retention, EU); supersedes the clinical '
          'rule when longer.',
      recipients: ['Stripe (US, BAA + SCC)', 'Clinician (controller)'],
      transferMechanism: 'SCC (2021/914) + Stripe Data Processing Addendum.',
      securityMeasures: [
        'Server-side Stripe webhook signing',
        'No payment card data persisted in app',
      ],
      crossBorderRecipients: [
        RopaCrossBorderRecipient(
          name: 'Stripe, Inc.',
          country: 'US',
          instrument: 'SCC 2021/914 Module 2 + Stripe DPA',
          tiaReference: 'docs/compliance/TIA_STRIPE.md',
        ),
      ],
    ),
    RopaActivity(
      id: 'audit-logging',
      purpose:
          'Tamper-evident audit trail of every PHI access, change, and '
          'export.',
      dataCategories: [
        'Actor identity (clinician)',
        'Entity reference',
        'IP address (redacted for export)',
      ],
      dataSubjects: 'Clinicians · patients (indirectly)',
      lawfulBasis:
          'Art. 6(1)(c) — legal obligation (HIPAA §164.312(b) audit '
          'controls); Art. 6(1)(f) — legitimate interest in security.',
      retention:
          '6 years (HIPAA §164.316(b)(2)(i)); rows pseudonymised by the '
          'audit_retention_purge Cloud Function thereafter.',
      recipients: ['Firebase (EU)'],
      transferMechanism: '',
      securityMeasures: [
        'Append-only Firestore rule',
        'SHA-256 hash chain',
        'Daily retention cron',
      ],
    ),
    RopaActivity(
      id: 'incident-response',
      purpose: 'Investigate, contain, and notify on security incidents.',
      dataCategories: ['Identity', 'Communication logs', 'Incident artefacts'],
      dataSubjects: 'Affected clinicians and patients',
      lawfulBasis:
          'Art. 6(1)(c) — HIPAA §164.404 breach notification; Art. 33 / 34 '
          'breach notification.',
      retention: '6 years after closure.',
      recipients: [
        'Internal incident commander',
        'Affected data subjects',
        'Regulators (when triggered)',
      ],
      transferMechanism: '',
      securityMeasures: [
        'Severity-aligned playbook',
        'On-call rotation',
        '24-hour internal determination SLA',
      ],
    ),
  ];

  /// Activities that involve a transfer outside the EEA.
  static List<RopaActivity> get crossBorder => activities
      .where((a) => a.transferMechanism.isNotEmpty)
      .toList(growable: false);

  /// Activities that touch Art. 9 special category (health) data.
  static List<RopaActivity> get specialCategory => activities
      .where(
        (a) =>
            a.dataCategories.any((c) => c.toLowerCase().contains('art. 9')) ||
            a.lawfulBasis.contains('Art. 9'),
      )
      .toList(growable: false);

  static RopaActivity? byId(String id) {
    for (final a in activities) {
      if (a.id == id) return a;
    }
    return null;
  }
}
