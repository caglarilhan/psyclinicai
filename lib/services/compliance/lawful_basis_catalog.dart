/// K16 — GDPR lawful basis catalog (pinned helper).
///
/// **Why this exists**: GDPR Art. 6(1) lists 6 lawful bases (a-f)
/// for personal-data processing; Art. 9(2) lists 10 conditions
/// (a-j) for special-category data including health data. The
/// chosen basis dictates EVERYTHING downstream — withdrawal rights
/// (Art. 7(3) consent-only), data-subject rights triage, retention
/// floor, supervisory authority defensibility. Auditors will ask
/// "what's your lawful basis for X?" and a `RopaRegistry` row that
/// silently picks `consent` for an activity that should be Art.
/// 6(1)(b) contract necessity is a fast track to an Art. 83 fine.
///
/// This catalog pins per processing activity:
///   1. Activity id + plain-English description.
///   2. Art. 6(1) lawful basis (consent / contract / legalObligation
///      / vitalInterest / publicTask / legitInterest).
///   3. Art. 9(2) special-category condition when health data is
///      processed (null when the activity does not touch Art. 9).
///   4. Whether the activity is withdrawable (true only when basis
///      is consent — Art. 7(3)).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `RopaRegistry` (Art. 30 RoPA) — names processing activities
///     + purposes; K16 pins WHICH lawful basis each activity uses.
///   * `DpiaTriggerCatalog` (K14) — when a DPIA is required; K16 is
///     orthogonal — every activity needs a basis whether or not it
///     triggers DPIA.
///   * `ConsentGuard` — runtime gate that checks consent state per
///     request; K16 documents which activities EVEN NEED consent
///     in the first place.
///
/// **Out of scope** (separate PRs):
///   * Per-tenant lawful-basis override (rare; supervised by DPO).
///   * Lawful-basis change-log audit emitter.
///   * Subject Access Request lawful-basis disclosure renderer.
library;

/// Processing activities the platform performs. Each must have
/// exactly one pinned lawful basis row.
enum ProcessingActivity {
  /// Storing + reading patient clinical records (chart, SOAP,
  /// assessment results).
  clinicalRecordStorage,

  /// AI clinician copilot inference (LLM-backed SOAP draft,
  /// treatment plan suggestion).
  aiCopilotInference,

  /// Sending appointment reminder SMS / email.
  appointmentReminder,

  /// Billing + invoice issuance to the clinician's organisation.
  billing,

  /// Marketing email to logged-in clinicians (newsletters, product
  /// updates).
  marketingEmail,

  /// Crash + error telemetry from web / mobile app.
  errorTelemetry,

  /// Vital-emergency disclosure of patient location to an emergency
  /// responder when imminent risk to life is documented (e.g. CSSRS
  /// item 6+ + suicide-pact disclosure).
  vitalEmergencyDisclosure,
}

/// GDPR Art. 6(1) lawful bases (one MUST be cited per activity).
enum LawfulBasisArticle6 {
  /// (a) consent of the data subject.
  consent,

  /// (b) necessary for performance of a contract with the data
  /// subject.
  contract,

  /// (c) compliance with a legal obligation.
  legalObligation,

  /// (d) necessary to protect vital interests of the data subject
  /// or another natural person.
  vitalInterest,

  /// (e) performance of a task in the public interest or exercise
  /// of official authority.
  publicTask,

  /// (f) legitimate interests of the controller.
  legitimateInterest,
}

/// GDPR Art. 9(2) special-category conditions (one MUST be cited
/// when the activity processes health data).
enum SpecialCategoryArt9 {
  /// (a) explicit consent.
  explicitConsent,

  /// (h) preventive or occupational medicine, medical diagnosis,
  /// provision of health care or treatment.
  healthcareProvision,

  /// (c) protect vital interests where the data subject is
  /// incapable of consent.
  vitalIncapacity,

  /// (i) public interest in the area of public health.
  publicHealthInterest,
}

class LawfulBasisRecord {
  const LawfulBasisRecord({
    required this.id,
    required this.activity,
    required this.description,
    required this.article6Basis,
    required this.article9Condition,
    required this.withdrawable,
    required this.regulatoryRefs,
  });

  final String id;
  final ProcessingActivity activity;
  final String description;

  final LawfulBasisArticle6 article6Basis;

  /// Null when the activity does not touch Art. 9 special category.
  final SpecialCategoryArt9? article9Condition;

  /// True only when the chosen basis is consent (Art. 7(3) — every
  /// consent must be as easy to withdraw as to give).
  final bool withdrawable;

  final List<String> regulatoryRefs;
}

class LawfulBasisCatalog {
  const LawfulBasisCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned table. Append-only.
  static const List<LawfulBasisRecord> records = [
    LawfulBasisRecord(
      id: 'clinical-record-storage',
      activity: ProcessingActivity.clinicalRecordStorage,
      description:
          'Store + read patient clinical records (chart, SOAP, assessment results) so the licensed clinician can provide care.',
      article6Basis: LawfulBasisArticle6.contract,
      article9Condition: SpecialCategoryArt9.healthcareProvision,
      withdrawable: false,
      regulatoryRefs: [
        'GDPR Art. 6(1)(b) contract necessity',
        'GDPR Art. 9(2)(h) healthcare provision',
        'HIPAA §164.502(a)(1)(ii) treatment use',
      ],
    ),
    LawfulBasisRecord(
      id: 'ai-copilot-inference',
      activity: ProcessingActivity.aiCopilotInference,
      description:
          'Generate clinician-facing draft notes / treatment-plan suggestions via LLM. Output is decision support; clinician retains final authority (L12 override audit).',
      article6Basis: LawfulBasisArticle6.contract,
      article9Condition: SpecialCategoryArt9.healthcareProvision,
      withdrawable: false,
      regulatoryRefs: [
        'GDPR Art. 6(1)(b) contract necessity',
        'GDPR Art. 9(2)(h) healthcare provision',
        'EU AI Act Art. 14 human oversight',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    LawfulBasisRecord(
      id: 'appointment-reminder',
      activity: ProcessingActivity.appointmentReminder,
      description:
          'Send appointment-reminder SMS / email to the patient. Treatment-adjacent service the patient signs up for.',
      article6Basis: LawfulBasisArticle6.contract,
      article9Condition: null,
      withdrawable: false,
      regulatoryRefs: [
        'GDPR Art. 6(1)(b) contract necessity',
        'ePrivacy Directive Art. 13(2) prior-relationship soft opt-in',
      ],
    ),
    LawfulBasisRecord(
      id: 'billing',
      activity: ProcessingActivity.billing,
      description:
          'Issue invoices to the clinician organisation + retain accounting records under EU/US tax law.',
      article6Basis: LawfulBasisArticle6.legalObligation,
      article9Condition: null,
      withdrawable: false,
      regulatoryRefs: [
        'GDPR Art. 6(1)(c) legal obligation (tax law)',
        'DE HGB §257 books + records 10-year retention',
        'US IRS guidance 7-year',
      ],
    ),
    LawfulBasisRecord(
      id: 'marketing-email',
      activity: ProcessingActivity.marketingEmail,
      description:
          'Send product-update + newsletter email to logged-in clinicians who opt in. Pure consent — silent unsubscribe at any time.',
      article6Basis: LawfulBasisArticle6.consent,
      article9Condition: null,
      withdrawable: true,
      regulatoryRefs: [
        'GDPR Art. 6(1)(a) consent',
        'GDPR Art. 7(3) withdrawal as easy as giving',
        'ePrivacy Directive Art. 13(1) opt-in for marketing comms',
      ],
    ),
    LawfulBasisRecord(
      id: 'error-telemetry',
      activity: ProcessingActivity.errorTelemetry,
      description:
          'Crash + error reports from web / mobile clients to triage bugs. PHI scrub (L9) runs before send; pseudonymised user id only.',
      article6Basis: LawfulBasisArticle6.legitimateInterest,
      article9Condition: null,
      withdrawable: false,
      regulatoryRefs: [
        'GDPR Art. 6(1)(f) legitimate interest (service reliability)',
        'GDPR Recital 49 network + information security',
      ],
    ),
    LawfulBasisRecord(
      id: 'vital-emergency-disclosure',
      activity: ProcessingActivity.vitalEmergencyDisclosure,
      description:
          'Disclose patient location to an emergency responder when imminent risk to life is documented (e.g. CSSRS item 6+ + suicide plan). Exceptional, narrowly scoped; clinical lead approval required.',
      article6Basis: LawfulBasisArticle6.vitalInterest,
      article9Condition: SpecialCategoryArt9.vitalIncapacity,
      withdrawable: false,
      regulatoryRefs: [
        'GDPR Art. 6(1)(d) vital interest',
        'GDPR Art. 9(2)(c) vital interest where data subject incapable of consent',
        'HIPAA §164.512(j) avert serious + imminent threat',
        'Joint Commission NPSG 15.01.01 (suicide risk reduction)',
      ],
    ),
  ];

  static LawfulBasisRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static LawfulBasisRecord? byActivity(ProcessingActivity a) {
    for (final r in records) {
      if (r.activity == a) return r;
    }
    return null;
  }
}

/// True when the data subject may withdraw the basis at any time
/// (only when the chosen basis is consent — Art. 7(3)).
bool isWithdrawable(ProcessingActivity a) {
  final r = LawfulBasisCatalog.byActivity(a);
  return r?.withdrawable ?? false;
}
