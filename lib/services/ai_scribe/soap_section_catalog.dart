/// AS1 — SOAP section catalog (pinned helper).
///
/// **Why this exists**: PILAR 1 (Ambient Clinical Scribe) generates a
/// SOAP note draft from a session transcript. Both the Cloud Function
/// prompt builder and the Flutter review screen need an identical,
/// versioned definition of what a SOAP note IS — which sections, what
/// each section must contain, what evidence the LLM must cite, and
/// what the clinician edits before signing.
///
/// Pinning that here:
///   1. Cloud Function `aiScribeDraftSoap` reads this catalog to build
///      the system prompt + JSON schema the LLM must conform to.
///   2. Flutter `AiScribeReviewScreen` reads this catalog to render
///      the edit form (one tab per section, required fields marked).
///   3. Drift test (`soap_section_parity_test.dart`) confirms the TS
///      mirror (`functions/src/lib/soap_section_catalog.ts`) is
///      byte-equivalent — change one, the other is forced to follow.
///
/// **Regulatory framing**:
///   * SOAP structure: AAFP / NIH PubMed Bookshelf Standard (NBK482263)
///   * Citation requirement: HIPAA §164.526 (accuracy of PHI),
///     21 CFR §11 (electronic records integrity).
///   * Clinician-in-the-loop edit + sign: FDA Clinical Decision
///     Support (CDS) non-device criterion §520(o)(1)(E).
///   * DSM-5-TR alignment for Assessment section.
///
/// **Out of scope** (separate PRs):
///   * Modality-specific templates (CBT/DBT/EMDR/ACT) — AS2 catalog.
///   * Audio capture pipeline — AS3.
///   * Insurance prior-auth letter generator — separate pilar.
library;

/// One SOAP section.
enum SoapSection { subjective, objective, assessment, plan }

/// Field kind for the editor UI.
enum SoapFieldKind {
  longText,
  bulletList,
  structuredList,
  codedTerm,
}

/// One field within a SOAP section.
class SoapFieldSpec {
  const SoapFieldSpec({
    required this.key,
    required this.label,
    required this.kind,
    required this.required,
    required this.placeholder,
    required this.citationRequired,
  });

  /// Stable JSON key the LLM emits + the Flutter form binds to.
  final String key;

  /// Human label shown to the clinician.
  final String label;

  final SoapFieldKind kind;

  /// If true the LLM MUST emit this field (empty string allowed when
  /// the transcript has no signal, but the key cannot be omitted).
  final bool required;

  final String placeholder;

  /// If true the LLM must attach `transcript_spans` (start/end ms in
  /// the audio) for every claim in this field. Drives the review UI's
  /// "tap to hear" affordance + the audit trail.
  final bool citationRequired;
}

/// One pinned SOAP section spec.
class SoapSectionSpec {
  const SoapSectionSpec({
    required this.section,
    required this.title,
    required this.purpose,
    required this.fields,
    required this.maxOutputTokens,
    required this.regulatoryRefs,
  });

  final SoapSection section;
  final String title;
  final String purpose;
  final List<SoapFieldSpec> fields;

  /// Cap the LLM's per-section output. Stops runaway generations
  /// from blowing the token budget + keeps the review screen
  /// scannable.
  final int maxOutputTokens;

  final List<String> regulatoryRefs;
}

class SoapSectionCatalog {
  const SoapSectionCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Schema version the LLM emits as `schema_version`. Bump when a
  /// new section / required field lands so old drafts can be
  /// re-rendered safely.
  static const int schemaVersion = 1;

  /// Per-section LLM temperature. Lower = more faithful to the
  /// transcript, higher = more synthesis. Pinned conservatively.
  static const Map<SoapSection, double> sectionTemperature = {
    SoapSection.subjective: 0.2,
    SoapSection.objective: 0.1,
    SoapSection.assessment: 0.3,
    SoapSection.plan: 0.2,
  };

  /// Pinned spec. Append-only — never reorder, never delete a field
  /// without bumping schemaVersion.
  static const List<SoapSectionSpec> sections = [
    SoapSectionSpec(
      section: SoapSection.subjective,
      title: 'Subjective',
      purpose:
          'Patient-reported experience, mood, presenting concerns, '
          'symptom timeline, life events since last session.',
      fields: [
        SoapFieldSpec(
          key: 'chief_complaint',
          label: 'Chief complaint',
          kind: SoapFieldKind.longText,
          required: true,
          placeholder: "One sentence summarising the patient's focus today.",
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'history_present_illness',
          label: 'History of present illness',
          kind: SoapFieldKind.longText,
          required: true,
          placeholder:
              'Timeline, frequency, intensity, triggers since last visit.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'patient_reported_symptoms',
          label: 'Patient-reported symptoms',
          kind: SoapFieldKind.bulletList,
          required: true,
          placeholder: "Bullets of symptoms in the patient's own words.",
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'life_events',
          label: 'Recent life events',
          kind: SoapFieldKind.bulletList,
          required: false,
          placeholder: 'Stressors / supports since last session.',
          citationRequired: true,
        ),
      ],
      maxOutputTokens: 600,
      regulatoryRefs: [
        'AAFP SOAP note guidance',
        'NIH NBK482263 SOAP structure',
      ],
    ),
    SoapSectionSpec(
      section: SoapSection.objective,
      title: 'Objective',
      purpose:
          'Clinician-observed mental status exam, affect, behaviour, '
          'observable measurements (outcome scale results, vitals if '
          'collected, attendance / engagement metrics).',
      fields: [
        SoapFieldSpec(
          key: 'mental_status_exam',
          label: 'Mental status exam',
          kind: SoapFieldKind.structuredList,
          required: true,
          placeholder:
              'Appearance, behaviour, speech, mood, affect, thought process, '
              'thought content, perception, cognition, insight, judgement.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'outcome_measure_scores',
          label: 'Outcome measure scores (today)',
          kind: SoapFieldKind.structuredList,
          required: false,
          placeholder:
              'PHQ-9, GAD-7, WHO-5, etc. — only what was administered.',
          citationRequired: false,
        ),
        SoapFieldSpec(
          key: 'observable_behaviour',
          label: 'Observable behaviour notes',
          kind: SoapFieldKind.bulletList,
          required: false,
          placeholder: 'Engagement, eye contact, motor activity, etc.',
          citationRequired: true,
        ),
      ],
      maxOutputTokens: 500,
      regulatoryRefs: [
        'NIH NBK482263 SOAP structure',
        'APA MSE documentation guidance',
      ],
    ),
    SoapSectionSpec(
      section: SoapSection.assessment,
      title: 'Assessment',
      purpose:
          'Clinical formulation. Working diagnoses (DSM-5-TR), '
          'differential, risk assessment, progress vs treatment goals.',
      fields: [
        SoapFieldSpec(
          key: 'working_diagnoses',
          label: 'Working diagnoses (DSM-5-TR)',
          kind: SoapFieldKind.codedTerm,
          required: true,
          placeholder:
              'List with DSM-5-TR code + plain-language label. Mark each '
              'as confirmed / provisional / rule-out.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'differential_diagnoses',
          label: 'Differential diagnoses',
          kind: SoapFieldKind.codedTerm,
          required: false,
          placeholder: 'Conditions actively considered + ruled out.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'risk_assessment',
          label: 'Risk assessment',
          kind: SoapFieldKind.structuredList,
          required: true,
          placeholder:
              'Suicide, self-harm, harm-to-others, neglect, substance — '
              'one row each with risk level + rationale + plan reference.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'progress_vs_goals',
          label: 'Progress vs treatment goals',
          kind: SoapFieldKind.bulletList,
          required: true,
          placeholder: 'Movement on each active treatment-plan goal.',
          citationRequired: true,
        ),
      ],
      maxOutputTokens: 700,
      regulatoryRefs: [
        'DSM-5-TR diagnostic criteria',
        'Joint Commission NPSG 15.01.01 (suicide risk)',
        'FDA CDS non-device criterion §520(o)(1)(E)',
      ],
    ),
    SoapSectionSpec(
      section: SoapSection.plan,
      title: 'Plan',
      purpose:
          'Next steps: interventions delivered, homework assigned, '
          'medication discussion (without prescribing), referrals, '
          'next-session cadence, safety plan if elevated risk.',
      fields: [
        SoapFieldSpec(
          key: 'interventions_delivered',
          label: 'Interventions delivered this session',
          kind: SoapFieldKind.bulletList,
          required: true,
          placeholder:
              'CBT thought record, behavioural activation, exposure plan, '
              'DBT skills coaching, etc. — modality + technique.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'homework_assigned',
          label: 'Homework / between-session work',
          kind: SoapFieldKind.bulletList,
          required: false,
          placeholder:
              'Specific tasks the patient agreed to do before next visit.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'medication_discussion',
          label: 'Medication discussion (non-prescriptive)',
          kind: SoapFieldKind.longText,
          required: false,
          placeholder:
              'Note any conversation about psychotropics. Do not record '
              "prescriptions — that is the prescriber's eRx system.",
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'referrals',
          label: 'Referrals + coordination',
          kind: SoapFieldKind.bulletList,
          required: false,
          placeholder: 'Specialist referrals, ROIs, care-team updates.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'safety_plan_reference',
          label: 'Safety plan reference',
          kind: SoapFieldKind.longText,
          required: false,
          placeholder:
              'If risk is elevated, link / summarise the active safety plan. '
              'Required when assessment.risk_assessment has a non-low row.',
          citationRequired: true,
        ),
        SoapFieldSpec(
          key: 'next_session',
          label: 'Next session cadence',
          kind: SoapFieldKind.longText,
          required: true,
          placeholder: 'When + modality + focus.',
          citationRequired: false,
        ),
      ],
      maxOutputTokens: 700,
      regulatoryRefs: [
        'NIH NBK482263 SOAP structure',
        'SAMHSA TIP 50 safety planning',
        'Stanley-Brown Safety Plan',
      ],
    ),
  ];

  static SoapSectionSpec bySection(SoapSection s) {
    for (final spec in sections) {
      if (spec.section == s) return spec;
    }
    throw StateError('Unknown SOAP section $s — catalog corrupt');
  }
}

/// True when every required field in [spec] has a non-empty entry in
/// [draft]. Used by the review screen to gate the "Sign + finalise"
/// button.
bool isSectionComplete(SoapSectionSpec spec, Map<String, dynamic> draft) {
  for (final f in spec.fields) {
    if (!f.required) continue;
    final v = draft[f.key];
    if (v == null) return false;
    if (v is String && v.trim().isEmpty) return false;
    if (v is List && v.isEmpty) return false;
  }
  return true;
}

/// Stable cache key combining schema version + section + tenant. Used
/// by the service layer to cache draft skeletons.
String soapDraftCacheKey({
  required String tenantId,
  required SoapSection section,
}) =>
    'soap:v${SoapSectionCatalog.schemaVersion}:$tenantId:${section.name}';
