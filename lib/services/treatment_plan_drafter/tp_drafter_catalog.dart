/// TPD1 — Evidence-Based Treatment Plan Drafter catalog
/// (pinned helper, PILAR 4 / PR-1).
///
/// **Why this exists**: PILAR 4 ships an AI drafter that produces a
/// SMART-goal treatment plan citing the published clinical guideline
/// for the (disorder, modality) pair. This is *separate* from
/// `lib/services/treatment_plan_templates.dart`, which holds static
/// seed templates the clinician can copy. The drafter catalog pins:
///   1. The (disorder, modality) tuples the drafter is allowed to
///      generate plans for — so the LLM cannot quietly invent a
///      protocol for a disorder we have no guideline citation for.
///   2. The guideline anchors per tuple — so the cited spans the LLM
///      attaches resolve to a real document the clinician can audit.
///   3. The output JSON schema sections + SMART-goal field set the
///      LLM must conform to.
///   4. Whether the tuple requires supervisor co-sign before
///      persistence — mandatory for trauma + personality +
///      substance-use protocols.
///
/// **Regulatory framing**:
///   * FDA CDS non-device — §520(o)(1)(E): drafter never auto-files;
///     clinician edits + signs every plan before persistence.
///   * EU AI Act high-risk disclosure: signed plan footer carries
///     "AI-assisted draft, clinician-reviewed".
///   * HIPAA §164.526 — accuracy of PHI: every goal cites a guideline.
///   * Joint Commission care-planning standards: SMART goals +
///     measurable outcome instrument + reassessment cadence.
library;

enum TpDisorderId {
  majorDepressiveDisorder,
  generalisedAnxietyDisorder,
  panicDisorder,
  socialAnxietyDisorder,
  ptsd,
  ocd,
  borderlinePersonalityDisorder,
  bingEatingDisorder,
  alcoholUseDisorder,
  insomniaDisorder,
}

enum TpModality { cbt, dbt, emdr, act, ipt, mi, cbti }

class TpProtocolSpec {
  const TpProtocolSpec({
    required this.disorder,
    required this.modality,
    required this.label,
    required this.recommendedSessions,
    required this.outcomeInstrument,
    required this.guidelineAnchors,
    required this.requiresSupervisorCoSign,
  });

  final TpDisorderId disorder;
  final TpModality modality;

  /// Plain-language label rendered in the picker, e.g.
  /// "CBT for Major Depressive Disorder".
  final String label;

  /// Recommended session count per the cited guideline. Drives the
  /// session-by-session skeleton the LLM populates.
  final int recommendedSessions;

  /// Outcome instrument the plan re-administers to measure progress.
  /// Must match an id in `outcome_measure_catalog.dart` so the
  /// dispatcher cron (PILAR 2) can carry the cadence.
  final String outcomeInstrument;

  /// Published clinical-guideline anchors. The LLM must cite at least
  /// one of these in every SMART goal it emits.
  final List<String> guidelineAnchors;

  /// True when the practice MUST route the draft to a supervisor for
  /// co-sign before persistence.
  final bool requiresSupervisorCoSign;
}

class TpDrafterCatalog {
  const TpDrafterCatalog._();

  static const String lastReviewed = '2026-06';
  static const int schemaVersion = 1;

  /// Pinned (disorder, modality) tuples. Append-only.
  /// Every entry is grounded in a public, peer-cited guideline.
  static const List<TpProtocolSpec> protocols = [
    TpProtocolSpec(
      disorder: TpDisorderId.majorDepressiveDisorder,
      modality: TpModality.cbt,
      label: 'CBT for Major Depressive Disorder',
      recommendedSessions: 16,
      outcomeInstrument: 'phq9',
      guidelineAnchors: [
        'NICE CG90 depression in adults',
        'APA Clinical Practice Guideline for the Treatment of Depression (2019)',
      ],
      requiresSupervisorCoSign: false,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.majorDepressiveDisorder,
      modality: TpModality.ipt,
      label: 'Interpersonal Therapy for Major Depressive Disorder',
      recommendedSessions: 16,
      outcomeInstrument: 'phq9',
      guidelineAnchors: [
        'NICE CG90 depression in adults',
        'Markowitz & Weissman IPT manual (2012)',
      ],
      requiresSupervisorCoSign: false,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.generalisedAnxietyDisorder,
      modality: TpModality.cbt,
      label: 'CBT for Generalised Anxiety Disorder',
      recommendedSessions: 14,
      outcomeInstrument: 'gad7',
      guidelineAnchors: [
        'NICE CG113 generalised anxiety disorder',
        'APA Clinical Practice Guideline for Anxiety Disorders (2024)',
      ],
      requiresSupervisorCoSign: false,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.panicDisorder,
      modality: TpModality.cbt,
      label: 'CBT for Panic Disorder (interoceptive exposure)',
      recommendedSessions: 12,
      outcomeInstrument: 'gad7',
      guidelineAnchors: [
        'NICE CG113 generalised anxiety + panic',
        'APA Clinical Practice Guideline for Anxiety Disorders (2024)',
      ],
      requiresSupervisorCoSign: false,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.socialAnxietyDisorder,
      modality: TpModality.cbt,
      label: 'CBT for Social Anxiety Disorder',
      recommendedSessions: 14,
      outcomeInstrument: 'gad7',
      guidelineAnchors: ['NICE CG159 social anxiety disorder'],
      requiresSupervisorCoSign: false,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.ptsd,
      modality: TpModality.emdr,
      label: 'EMDR for PTSD',
      recommendedSessions: 12,
      outcomeInstrument: 'pcl5',
      guidelineAnchors: [
        'NICE NG116 post-traumatic stress disorder',
        'WHO mhGAP 2023 PTSD module',
      ],
      requiresSupervisorCoSign: true,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.ptsd,
      modality: TpModality.cbt,
      label: 'Trauma-Focused CBT for PTSD',
      recommendedSessions: 14,
      outcomeInstrument: 'pcl5',
      guidelineAnchors: [
        'NICE NG116 post-traumatic stress disorder',
        'APA Clinical Practice Guideline for PTSD (2017)',
      ],
      requiresSupervisorCoSign: true,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.ocd,
      modality: TpModality.cbt,
      label: 'ERP-based CBT for OCD',
      recommendedSessions: 16,
      outcomeInstrument: 'gad7',
      guidelineAnchors: [
        'NICE CG31 obsessive-compulsive disorder',
        'APA Clinical Practice Guideline for OCD (2013)',
      ],
      requiresSupervisorCoSign: false,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.borderlinePersonalityDisorder,
      modality: TpModality.dbt,
      label: 'DBT for Borderline Personality Disorder',
      recommendedSessions: 48,
      outcomeInstrument: 'phq9',
      guidelineAnchors: [
        'NICE CG78 borderline personality disorder',
        'Linehan DBT Skills Training Manual (2nd ed.)',
      ],
      requiresSupervisorCoSign: true,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.bingEatingDisorder,
      modality: TpModality.cbt,
      label: 'CBT for Binge-Eating Disorder',
      recommendedSessions: 16,
      outcomeInstrument: 'phq9',
      guidelineAnchors: ['NICE NG69 eating disorders'],
      requiresSupervisorCoSign: false,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.alcoholUseDisorder,
      modality: TpModality.mi,
      label: 'Motivational Interviewing for Alcohol Use Disorder',
      recommendedSessions: 8,
      outcomeInstrument: 'audit',
      guidelineAnchors: [
        'NICE CG115 alcohol-use disorders',
        'SAMHSA TIP 35 enhancing motivation',
      ],
      requiresSupervisorCoSign: true,
    ),
    TpProtocolSpec(
      disorder: TpDisorderId.insomniaDisorder,
      modality: TpModality.cbti,
      label: 'CBT-I for Insomnia Disorder',
      recommendedSessions: 6,
      outcomeInstrument: 'phq9',
      guidelineAnchors: ['AASM clinical practice guideline for CBT-I (2021)'],
      requiresSupervisorCoSign: false,
    ),
  ];

  /// Canonical SMART-goal field set every protocol's goals must
  /// conform to. Pinned so the LLM JSON schema is stable.
  static const List<String> smartGoalFields = [
    'goal_text',
    'specific',
    'measurable',
    'achievable',
    'relevant',
    'time_bound',
    'cited_guideline',
  ];

  /// Section keys the LLM emits, in canonical order.
  static const List<String> outputSections = [
    'presenting_problems',
    'smart_goals',
    'session_plan',
    'homework_templates',
    'outcome_reassessment',
    'risk_review_cadence',
  ];

  static TpProtocolSpec byKey({
    required TpDisorderId disorder,
    required TpModality modality,
  }) {
    for (final p in protocols) {
      if (p.disorder == disorder && p.modality == modality) return p;
    }
    throw StateError(
      'No drafter protocol for ${disorder.name} × ${modality.name}',
    );
  }

  /// Modalities the catalog supports for a given disorder.
  static List<TpModality> modalitiesFor(TpDisorderId disorder) {
    final out = <TpModality>[];
    for (final p in protocols) {
      if (p.disorder == disorder) out.add(p.modality);
    }
    return out;
  }
}

/// True when the protocol requires supervisor co-sign before the
/// drafted plan persists to the encounter. Pure for unit tests.
bool requiresCoSign(TpProtocolSpec spec) => spec.requiresSupervisorCoSign;
