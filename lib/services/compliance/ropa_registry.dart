/// GDPR Art. 30 (Records of Processing Activities) + KVKK md. 16
/// (Veri İşleme Envanteri) consolidated registry.
///
/// Both regulators require a living register of every distinct
/// processing activity. The auditor walks down this register and
/// pattern-matches it against:
///   • Art. 6 / 9 (GDPR) and md. 5 / 6 (KVKK) lawful basis,
///   • Art. 28 sub-processor contracts (DPA / DPAdd),
///   • Art. 32 / md. 12 technical + organizational measures,
///   • Art. 5(1)(e) / md. 4 storage limitation,
///   • Art. 44+ / md. 9 cross-border transfer mechanism.
///
/// Each [RopaActivity] therefore tracks both legal frameworks. The
/// [RopaRegistry.exportJson] dump is the snapshot a regulator (KVK
/// Kurumu or an EU DPA) sees during a vendor questionnaire.
///
/// Rows here are concise — long-form is in the DPA and the
/// sub-processor registry. The Trust Center reads this list to render
/// a human-readable table for prospective customers.
///
/// Status is conservative; a row missing a mandatory cell stays out
/// of the registry until the cell is filled.
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
    this.kvkkBasis = '',
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

  /// KVKK md. 5 / 6 lawful-processing ground, plain Turkish copy
  /// ("md. 6/2 ve md. 6/3 — özel nitelikli sağlık verisi için
  /// açık rıza"). Empty for activities outside Türkiye scope.
  final String kvkkBasis;

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

  /// Audit-export shape. Field names mirror the regulatory glossary
  /// so an auditor can read the JSON without an internal cheat-sheet:
  /// `gdpr_lawful_basis`, `kvkk_basis`, `data_categories`, etc.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'purpose': purpose,
    'data_categories': dataCategories,
    'data_subjects': dataSubjects,
    'gdpr_lawful_basis': lawfulBasis,
    if (kvkkBasis.isNotEmpty) 'kvkk_basis': kvkkBasis,
    'retention': retention,
    'recipients': recipients,
    if (transferMechanism.isNotEmpty) 'transfer_mechanism': transferMechanism,
    'security_measures': securityMeasures,
    if (dpiaReference != null) 'dpia_reference': dpiaReference,
    if (crossBorderRecipients.isNotEmpty)
      'cross_border_recipients': crossBorderRecipients
          .map((c) => c.toJson())
          .toList(growable: false),
  };
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

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'country': country,
    'instrument': instrument,
    'tia_reference': tiaReference,
  };
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
      kvkkBasis:
          'md. 6/2 + md. 6/3 — özel nitelikli sağlık verisi için açık rıza '
          '(intake formundan toplanır); md. 5/2(ç) — yasal yükümlülüklerin '
          'yerine getirilmesi (tıbbi kayıt mevzuatı).',
    ),
    RopaActivity(
      id: 'ai-assistance',
      purpose:
          'Generate decision-support drafts (treatment plan suggestions, '
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
      kvkkBasis:
          'md. 6/2 — özel nitelikli sağlık verisi için açık rıza '
          '(consent_records.ai_assistance_consent altında kayıt altına '
          'alınır); md. 9 kapsamında ABD aktarımı, açık rıza + SCC '
          'Modül 2 + TIA çerçevesinde yapılır.',
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
      kvkkBasis:
          'md. 5/2(c) — sözleşmenin kurulması ve ifası; md. 5/2(ç) — '
          'vergi / muhasebe mevzuatı kapsamındaki yasal yükümlülükler. '
          'md. 9 kapsamında ABD aktarımı, SCC Modül 2 + Stripe DPA '
          'çerçevesinde gerçekleştirilir.',
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
      kvkkBasis:
          'md. 5/2(ç) — KVKK md. 12 + ISMS denetim izi gereği; '
          'md. 5/2(f) — meşru menfaat (güvenlik denetimi).',
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
      kvkkBasis:
          'md. 5/2(ç) — KVKK md. 12/5 ihlal bildirim yükümlülüğü '
          '(KVK Kurulu en geç 72 saat içinde bilgilendirilir); '
          'md. 5/2(f) — meşru menfaat (olay müdahalesi).',
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

  /// Full registry dump suitable for KVK Kurumu envanter audit and
  /// GDPR Art. 30 supervisory-authority requests. Structured fields
  /// (snake_case) so the downstream JSON consumer doesn't need a
  /// custom decoder. Stable shape — auditors pin specific paths.
  static Map<String, Object?> exportJson() => <String, Object?>{
    'version': '1.0',
    'frameworks': const ['gdpr', 'kvkk', 'hipaa'],
    'last_reviewed': lastReviewed,
    'controller': controller,
    'dpo_contact': dpoContact,
    'activities': activities.map((a) => a.toJson()).toList(growable: false),
  };

  /// Activities with a non-empty KVKK basis — surfaced when the
  /// patient/clinician is in scope of the Turkish regulator.
  static List<RopaActivity> get kvkkInScope =>
      activities.where((a) => a.kvkkBasis.isNotEmpty).toList(growable: false);
}
