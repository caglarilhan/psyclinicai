/// L11 — AI hallucination warning sign catalog (pinned helper).
///
/// **Why this exists**: LLM hallucinations in a clinical surface
/// can be patient-harm grade — a fabricated drug name in a SOAP
/// note draft, a made-up DSM-5 code, a citation to a paper that
/// does not exist. L1 AI output guard blocks the obvious (PHI
/// leak, jailbreak), but hallucinations slip through the guard
/// because the output is well-formed. The clinician is the last
/// line of defense.
///
/// This catalog pins per hallucination class:
///   1. Plain-English description of the failure mode.
///   2. Recognition pattern engineers + the model card can grep
///      against (regex / signal hint).
///   3. Severity (patientHarm / clinicalMisinformation / cosmetic).
///   4. Clinician action — block / verify / accept with caveat.
///
/// **Distinct from**:
///   * L1 ai_output_guard: blocks WHAT to never emit; L11 catalogs
///     WHAT SLIPS THROUGH for clinician review.
///   * L6 jailbreak_patterns: detects ATTACKER intent; L11 detects
///     model FABRICATION.
///   * L9 phi_scrub: redacts PHI before relay; L11 catches false
///     content after.
///
/// **Out of scope** (separate PRs):
///   * Clinician training module wiring (N2 module 6).
///   * Per-output-class red-team eval set.
///   * AI output review UI badge.
library;

/// What kind of hallucination the pattern flags.
enum HallucinationClass {
  /// Fabricated drug name or dosage (highest harm).
  fabricatedMedication,

  /// Fabricated diagnostic code (DSM-5 / ICD-11) that does not
  /// exist or is wrong for the symptom set.
  fabricatedDiagnosisCode,

  /// Citation to a paper / guideline / textbook that does not
  /// exist or whose claim is misattributed.
  fabricatedCitation,

  /// Demographic confusion — e.g. patient pronouns flipped, age
  /// stated wrong, history attributed to another patient.
  demographicConfusion,

  /// Internal contradiction — same SOAP draft says BOTH "denies
  /// suicidal ideation" AND "endorses plan".
  internalContradiction,

  /// Made-up appointment time / referral that does not exist in
  /// the schedule.
  fabricatedSchedulingItem,
}

/// Required clinician action when the warning fires.
enum ClinicianAction {
  /// Block: never publish; force regenerate.
  block,

  /// Verify: clinician MUST cross-reference an external source
  /// before publishing.
  verify,

  /// Accept with caveat: publishable + audit-log entry that
  /// flagged content was reviewed.
  acceptWithCaveat,
}

/// One pinned warning sign.
class HallucinationWarningRecord {
  const HallucinationWarningRecord({
    required this.id,
    required this.warningClass,
    required this.description,
    required this.recognitionHints,
    required this.severity,
    required this.clinicianAction,
    required this.regulatoryRefs,
  });

  /// Stable id used by the model-card review + audit log.
  final String id;

  final HallucinationClass warningClass;

  /// Plain-English description shown to the clinician.
  final String description;

  /// Recognition signals — substrings, regex hints, or rules
  /// engineers can grep. Free-form text per signal.
  final List<String> recognitionHints;

  /// Coarse severity: patientHarm > clinicalMisinformation >
  /// cosmetic. Tests pin the ladder.
  final String severity;

  final ClinicianAction clinicianAction;

  final List<String> regulatoryRefs;
}

class HallucinationWarningCatalog {
  const HallucinationWarningCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned warning catalog. Append-only.
  static const List<HallucinationWarningRecord> warnings = [
    HallucinationWarningRecord(
      id: 'fabricated-medication-name',
      warningClass: HallucinationClass.fabricatedMedication,
      description:
          'AI draft includes a medication name not in the patient '
          'chart history or the agency formulary.',
      recognitionHints: [
        'Drug name pattern (e.g. "-mab", "-prazole") not in formulary RxNorm',
        'Dose unit mismatch with the named drug',
        'Brand name with no generic in the chart',
      ],
      severity: 'patientHarm',
      clinicianAction: ClinicianAction.block,
      regulatoryRefs: [
        'FDA CDS Guidance (Sep 2022) — software functions intended to inform clinical management',
        'Joint Commission NPSG 03.06.01 (medication reconciliation)',
      ],
    ),
    HallucinationWarningRecord(
      id: 'fabricated-dsm-code',
      warningClass: HallucinationClass.fabricatedDiagnosisCode,
      description:
          'AI cites a diagnosis code that does not exist in DSM-5-TR '
          'or ICD-11 or is wrong for the documented symptom set.',
      recognitionHints: [
        'DSM-5-TR code regex F\\d{2}\\.\\d{1,2} not present in the DSM lookup',
        'ICD-11 code with no chapter prefix',
        'Code-symptom mismatch flagged by clinical_lens_service',
      ],
      severity: 'clinicalMisinformation',
      clinicianAction: ClinicianAction.verify,
      regulatoryRefs: [
        'APA DSM-5-TR (2022)',
        'WHO ICD-11 (Jan 2022)',
        'EU AI Act Annex III §5(b) clinical decision support',
      ],
    ),
    HallucinationWarningRecord(
      id: 'fabricated-citation',
      warningClass: HallucinationClass.fabricatedCitation,
      description:
          'AI references a paper, NICE guideline, or textbook that '
          'either does not exist or makes a different claim.',
      recognitionHints: [
        'Title not in the pinned guideline corpus (rag-grounded-public-qa)',
        'DOI / PMID format present but does not resolve',
        'Citation precedes the search-results section in the draft',
      ],
      severity: 'clinicalMisinformation',
      clinicianAction: ClinicianAction.verify,
      regulatoryRefs: [
        'EU AI Act Art. 13 transparency',
        'COPE 2019 citation best practice',
      ],
    ),
    HallucinationWarningRecord(
      id: 'demographic-confusion',
      warningClass: HallucinationClass.demographicConfusion,
      description:
          'AI draft uses wrong pronouns / age / cultural context '
          'for the chart in scope (often patient-id mix-up).',
      recognitionHints: [
        'Pronoun shift mid-paragraph',
        'Age stated > chart age + 1',
        'Cultural reference inconsistent with documented background',
      ],
      severity: 'patientHarm',
      clinicianAction: ClinicianAction.block,
      regulatoryRefs: [
        'Joint Commission NPSG 01.01.01 (patient identification)',
        'EU AI Act Art. 14 human oversight',
      ],
    ),
    HallucinationWarningRecord(
      id: 'internal-contradiction',
      warningClass: HallucinationClass.internalContradiction,
      description:
          'Same draft holds two mutually exclusive claims '
          '(e.g. denies SI + endorses plan).',
      recognitionHints: [
        '"denies" + "endorses" of the same construct in same note',
        'CSSRS item 1 + item 5 both flagged contradictorily',
        'Negation + assertion of the same finding',
      ],
      severity: 'patientHarm',
      clinicianAction: ClinicianAction.block,
      regulatoryRefs: [
        'Joint Commission NPSG 15.01.01 (suicide risk reduction)',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    HallucinationWarningRecord(
      id: 'fabricated-scheduling-item',
      warningClass: HallucinationClass.fabricatedSchedulingItem,
      description:
          'AI suggests an appointment time or referral that does '
          'not exist in the appointment service or referral list.',
      recognitionHints: [
        'Date/time mentioned but not in appointment_service',
        'Referral target not in clinic network registry',
      ],
      severity: 'cosmetic',
      clinicianAction: ClinicianAction.acceptWithCaveat,
      regulatoryRefs: ['SOC 2 CC7.2 system monitoring'],
    ),
  ];

  static HallucinationWarningRecord? byId(String id) {
    for (final w in warnings) {
      if (w.id == id) return w;
    }
    return null;
  }

  static List<HallucinationWarningRecord> byClass(HallucinationClass c) {
    return warnings.where((w) => w.warningClass == c).toList();
  }
}

/// Severity ladder: `patientHarm` > `clinicalMisinformation` >
/// `cosmetic`. Higher index = higher severity.
const _severityOrder = ['cosmetic', 'clinicalMisinformation', 'patientHarm'];

/// True when [a] is at least as severe as [b]. Drives the
/// "block-overrides-verify-overrides-accept" routing in the AI
/// review UI.
bool severityAtLeast(String a, String b) {
  final ai = _severityOrder.indexOf(a);
  final bi = _severityOrder.indexOf(b);
  return ai >= bi;
}

/// True when the warning forces a hard block.
bool isBlocking(HallucinationWarningRecord w) =>
    w.clinicianAction == ClinicianAction.block;
