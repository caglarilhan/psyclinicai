/// K14 — DPIA trigger catalog (pinned helper).
///
/// **Why this exists**: GDPR Art. 35(1) requires a Data Protection
/// Impact Assessment when processing is "likely to result in a high
/// risk to the rights and freedoms of natural persons." Art. 35(3)
/// + EDPB Guidelines on DPIA (WP248 rev.01, adopted 4 Oct 2017) +
/// the national DPA's published lists spell out specific triggers.
/// Failing to do a DPIA when one is required is an Art. 83(4)(a)
/// fine — up to €10M or 2% global turnover. This catalog pins our
/// in-product trigger set so the feature-onboarding workflow can
/// gate launch on DPIA completion.
///
/// This catalog pins per trigger:
///   1. Trigger id + GDPR Art. 35 sub-condition + EDPB criterion.
///   2. Whether it is mandatory (one of the 9 EDPB criteria) or
///      strongly-recommended (national DPA list).
///   3. Required review owner role (DPO, CISO, clinical lead).
///   4. Maximum review turnaround in business days.
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `RopaRegistry` — describes EXISTING processing activities
///     under Art. 30; K14 pins WHEN a NEW activity must trigger a
///     DPIA before launch.
///   * `IdentityVerificationPolicy` (K13) — gates data-subject
///     request fulfillment; K14 gates the platform's ability to
///     start the processing in the first place.
///   * `CrossBorderTransferRegister` (K12) — Schrems II measures
///     for transfers; K14 is upstream — if the processing fails
///     the DPIA, the transfer never happens.
///
/// **Out of scope** (separate PRs):
///   * DPIA report template generator.
///   * Feature-launch gate workflow UI.
///   * Stakeholder review queue ingest.
library;

/// Which clinical/product change scenarios force a DPIA.
enum DpiaTrigger {
  /// Systematic + extensive evaluation of natural persons including
  /// profiling, with legal/significant effects (Art. 35(3)(a)).
  systematicAutomatedProfiling,

  /// Large-scale processing of special-category data (Art. 9) —
  /// health data is special category by default. (Art. 35(3)(b)).
  largeScaleHealthData,

  /// Systematic monitoring of publicly accessible area on a large
  /// scale (Art. 35(3)(c)). Telehealth waiting room recording etc.
  systematicPublicMonitoring,

  /// Combining / cross-referencing datasets from different sources
  /// in a way the data subject would not reasonably expect (EDPB
  /// WP248 criterion 5).
  datasetCombination,

  /// Processing of data on vulnerable subjects — children, patients
  /// in care (EDPB WP248 criterion 6).
  vulnerableSubjects,

  /// Innovative use of new technology — AI for clinical decision
  /// support is the textbook example (EDPB WP248 criterion 7).
  innovativeTechnology,

  /// Processing that may itself prevent the data subject from
  /// exercising a right or using a service (EDPB WP248 criterion 9).
  preventsRightExercise,
}

/// Who reviews and signs off the DPIA when the trigger fires.
enum DpiaReviewerRole {
  /// Data Protection Officer (Art. 37 designate). Mandatory on
  /// every DPIA per Art. 35(2).
  dpo,

  /// Chief Information Security Officer — required when the trigger
  /// hits a security-of-processing axis (Art. 32).
  ciso,

  /// Clinical lead — required when the trigger involves clinical
  /// decision support or patient-safety surface.
  clinicalLead,
}

class DpiaTriggerRecord {
  const DpiaTriggerRecord({
    required this.id,
    required this.trigger,
    required this.description,
    required this.mandatory,
    required this.requiredReviewers,
    required this.reviewTurnaroundDays,
    required this.regulatoryRefs,
  });

  final String id;
  final DpiaTrigger trigger;
  final String description;

  /// True when the trigger is one of GDPR Art. 35(3) explicit
  /// scenarios OR one of the EDPB WP248 9 criteria. False when
  /// only on a national DPA's optional list.
  final bool mandatory;

  final List<DpiaReviewerRole> requiredReviewers;

  /// Maximum business days from trigger detection to DPIA sign-off.
  final int reviewTurnaroundDays;

  final List<String> regulatoryRefs;
}

class DpiaTriggerCatalog {
  const DpiaTriggerCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned trigger catalog. Append-only.
  static const List<DpiaTriggerRecord> records = [
    DpiaTriggerRecord(
      id: 'systematic-automated-profiling',
      trigger: DpiaTrigger.systematicAutomatedProfiling,
      description:
          'New automated profiling of clinicians or patients with legal or similarly significant effects (e.g. risk scoring that gates clinical pathway routing).',
      mandatory: true,
      requiredReviewers: [DpiaReviewerRole.dpo, DpiaReviewerRole.ciso],
      reviewTurnaroundDays: 20,
      regulatoryRefs: [
        'GDPR Art. 35(3)(a) systematic + extensive evaluation incl. profiling',
        'GDPR Art. 22 automated decision-making',
        'EDPB WP248 rev.01 criterion 1 (evaluation/scoring)',
        'EU AI Act Art. 13 transparency',
      ],
    ),
    DpiaTriggerRecord(
      id: 'large-scale-health-data',
      trigger: DpiaTrigger.largeScaleHealthData,
      description:
          'Onboarding a new clinic or expanding to a new region where the patient population crosses the large-scale processing threshold (EDPB WP248 §III.B).',
      mandatory: true,
      requiredReviewers: [
        DpiaReviewerRole.dpo,
        DpiaReviewerRole.ciso,
        DpiaReviewerRole.clinicalLead,
      ],
      reviewTurnaroundDays: 30,
      regulatoryRefs: [
        'GDPR Art. 35(3)(b) large-scale special category data',
        'GDPR Art. 9 special categories (health data)',
        'EDPB WP248 rev.01 criterion 4 (sensitive data, large scale)',
      ],
    ),
    DpiaTriggerRecord(
      id: 'systematic-public-monitoring',
      trigger: DpiaTrigger.systematicPublicMonitoring,
      description:
          'Adding any feature that systematically captures audio/video from a publicly accessible context (e.g. clinic lobby camera, telehealth waiting room).',
      mandatory: true,
      requiredReviewers: [DpiaReviewerRole.dpo, DpiaReviewerRole.ciso],
      reviewTurnaroundDays: 20,
      regulatoryRefs: [
        'GDPR Art. 35(3)(c) systematic monitoring of publicly accessible area',
        'EDPB WP248 rev.01 criterion 8 (innovative use + monitoring)',
      ],
    ),
    DpiaTriggerRecord(
      id: 'dataset-combination',
      trigger: DpiaTrigger.datasetCombination,
      description:
          'Cross-referencing a clinical dataset with an external dataset (e.g. EHR + insurance claims + wearable telemetry) in a way the patient would not reasonably expect.',
      mandatory: true,
      requiredReviewers: [DpiaReviewerRole.dpo],
      reviewTurnaroundDays: 20,
      regulatoryRefs: [
        'EDPB WP248 rev.01 criterion 5 (matching or combining datasets)',
        'GDPR Art. 5(1)(b) purpose limitation',
      ],
    ),
    DpiaTriggerRecord(
      id: 'vulnerable-subjects',
      trigger: DpiaTrigger.vulnerableSubjects,
      description:
          'New processing affecting children, patients under involuntary care, or other vulnerable groups where consent ability is impaired.',
      mandatory: true,
      requiredReviewers: [DpiaReviewerRole.dpo, DpiaReviewerRole.clinicalLead],
      reviewTurnaroundDays: 25,
      regulatoryRefs: [
        'EDPB WP248 rev.01 criterion 6 (vulnerable data subjects)',
        'GDPR Art. 8 child consent',
        'UN CRPD Art. 12 (involuntary care safeguards)',
      ],
    ),
    DpiaTriggerRecord(
      id: 'innovative-technology',
      trigger: DpiaTrigger.innovativeTechnology,
      description:
          'Introducing an AI/LLM-based clinical decision support feature, on-device biosignal classification, or any other novel processing pattern.',
      mandatory: true,
      requiredReviewers: [
        DpiaReviewerRole.dpo,
        DpiaReviewerRole.ciso,
        DpiaReviewerRole.clinicalLead,
      ],
      reviewTurnaroundDays: 30,
      regulatoryRefs: [
        'EDPB WP248 rev.01 criterion 7 (innovative use of new technology)',
        'EU AI Act Annex III §5(b) clinical decision support',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    DpiaTriggerRecord(
      id: 'prevents-right-exercise',
      trigger: DpiaTrigger.preventsRightExercise,
      description:
          'New automated logic whose decision may itself prevent the data subject from exercising a right or accessing a service (e.g. risk-scored intake triage that gates access to care).',
      mandatory: true,
      requiredReviewers: [DpiaReviewerRole.dpo, DpiaReviewerRole.clinicalLead],
      reviewTurnaroundDays: 25,
      regulatoryRefs: [
        'EDPB WP248 rev.01 criterion 9 (preventing exercise of right or contract)',
        'GDPR Art. 22 automated decision-making',
      ],
    ),
  ];

  static DpiaTriggerRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static DpiaTriggerRecord? byTrigger(DpiaTrigger t) {
    for (final r in records) {
      if (r.trigger == t) return r;
    }
    return null;
  }
}

/// True when the trigger is mandatory under GDPR Art. 35(3) or EDPB
/// WP248. Drives the feature-onboarding form to block launch until
/// the DPIA is signed off.
bool requiresDpia(DpiaTrigger t) {
  final r = DpiaTriggerCatalog.byTrigger(t);
  return r?.mandatory ?? false;
}
