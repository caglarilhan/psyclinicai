/// J5 — Crisis trigger threshold catalog (pinned helper).
///
/// **Why this exists**: `ClinicalScales` (PHQ-9, GAD-7, CSSRS,
/// AUDIT, PCL-5, WHO-5) measures the score. `AssessmentSeverityEngine`
/// translates raw scores into severity bands. But the question "at
/// which score does the system escalate to a clinician?" is policy,
/// not measurement. A wrong threshold either floods the clinician
/// queue (false-positive fatigue) or misses an active suicide risk
/// (the L11 patientHarm equivalent in assessment-land). Joint
/// Commission NPSG 15.01.01 + FDA CDS Guidance Sep 2022 require a
/// documented escalation rule per validated instrument. This
/// catalog pins those numbers + the action tier each threshold
/// fires.
///
/// This catalog pins per scale × threshold:
///   1. Scale id (phq9 / gad7 / cssrs / audit / pcl5 / who5).
///   2. Pinned cutoff score.
///   3. Whether score >= cutoff (standard) or score <= cutoff
///      (inverted scales like WHO-5).
///   4. Escalation action tier (none / clinicianReview /
///      sameDayClinicianContact / immediateCrisis).
///   5. Why this score → this tier (clinical literature).
///   6. Regulatory anchor.
///
/// **Distinct from**:
///   * `ClinicalScales` — instrument + scoring formula; J5 pins
///     when the score forces an action.
///   * `AssessmentSeverityEngine` — translates score → severity
///     band label; J5 pins the action that band triggers.
///   * `risk_escalation_chain.dart` — runtime escalation pipeline;
///     J5 is the policy table the pipeline reads.
///   * L11 hallucination warning — AI output safety; J5 is
///     human-completed assessment safety.
///
/// **Out of scope** (separate PRs):
///   * Escalation pipeline implementation (already wired in
///     risk_escalation_chain).
///   * Per-tenant threshold override (rare; clinical lead approval).
///   * Time-window detection (multiple positives in 7 days).
library;

/// Validated clinical instrument.
enum ClinicalInstrument {
  /// PHQ-9 — Patient Health Questionnaire for depression
  /// (Kroenke 2001).
  phq9,

  /// GAD-7 — Generalised Anxiety Disorder 7-item scale
  /// (Spitzer 2006).
  gad7,

  /// C-SSRS — Columbia Suicide Severity Rating Scale
  /// (Posner 2011).
  cssrs,

  /// AUDIT — Alcohol Use Disorders Identification Test
  /// (Saunders 1993).
  audit,

  /// PCL-5 — PTSD Checklist for DSM-5 (Weathers 2013).
  pcl5,

  /// WHO-5 — WHO Wellbeing Index (Topp 2015) (inverted —
  /// LOWER score = worse).
  who5,
}

/// Escalation action tier. Ordinal: none < clinicianReview <
/// sameDayClinicianContact < immediateCrisis.
enum EscalationAction {
  /// No clinician action required.
  none,

  /// Add to clinician's standard review queue (next session).
  clinicianReview,

  /// Clinician MUST contact patient same day (phone / message).
  sameDayClinicianContact,

  /// Immediate crisis protocol — within minutes; may include
  /// emergency-services contact per K16 vital-emergency.
  immediateCrisis,
}

class CrisisTriggerRecord {
  const CrisisTriggerRecord({
    required this.id,
    required this.instrument,
    required this.cutoff,
    required this.lowerBoundInclusive,
    required this.action,
    required this.appliesToTotalScore,
    required this.description,
    required this.regulatoryRefs,
  });

  /// Stable id (e.g. 'phq9-moderately-severe').
  final String id;

  final ClinicalInstrument instrument;

  /// Cutoff score that fires the threshold.
  final int cutoff;

  /// True when threshold is score >= cutoff (standard); false when
  /// inverse (e.g. WHO-5 LOWER = worse → score <= cutoff).
  final bool lowerBoundInclusive;

  final EscalationAction action;

  /// True when the cutoff applies to the instrument's TOTAL score
  /// (the common case). False when it applies to a SUB-ITEM (e.g.
  /// PHQ-9 item 9 suicidal-ideation flag), in which case
  /// `escalationForScore(totalScore)` will skip it — caller must
  /// use the dedicated sub-item helper.
  final bool appliesToTotalScore;

  final String description;

  final List<String> regulatoryRefs;
}

class CrisisTriggerThresholdCatalog {
  const CrisisTriggerThresholdCatalog._();

  /// YYYY-MM stamp — drives the clinical-policy "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned threshold table. Append-only.
  static const List<CrisisTriggerRecord> records = [
    // ─────── PHQ-9 (depression) ───────
    CrisisTriggerRecord(
      id: 'phq9-moderate',
      instrument: ClinicalInstrument.phq9,
      cutoff: 10,
      lowerBoundInclusive: true,
      action: EscalationAction.clinicianReview,
      appliesToTotalScore: true,
      description:
          'PHQ-9 >= 10 indicates moderate depression (Kroenke 2001 sens/spec ~88%/88%). Add to clinician review queue.',
      regulatoryRefs: [
        'Kroenke et al. 2001 PHQ-9 validation',
        'USPSTF 2023 Recommendation Statement: Screening for Depression',
      ],
    ),
    CrisisTriggerRecord(
      id: 'phq9-moderately-severe',
      instrument: ClinicalInstrument.phq9,
      cutoff: 15,
      lowerBoundInclusive: true,
      action: EscalationAction.sameDayClinicianContact,
      appliesToTotalScore: true,
      description:
          'PHQ-9 >= 15 indicates moderately severe depression — same-day clinician contact (Kroenke 2001).',
      regulatoryRefs: [
        'Kroenke et al. 2001',
        'NICE Guideline NG222 (depression in adults)',
      ],
    ),
    CrisisTriggerRecord(
      id: 'phq9-item9-positive',
      instrument: ClinicalInstrument.phq9,
      cutoff: 1,
      lowerBoundInclusive: true,
      action: EscalationAction.immediateCrisis,
      appliesToTotalScore: false,
      description:
          'PHQ-9 item 9 >= 1 (any positive on suicidal ideation) MUST trigger immediate crisis protocol per Joint Commission NPSG 15.01.01. Confirm with C-SSRS within minutes. NOTE: cutoff applies to ITEM-9 SUB-SCORE, not total — escalationForScore() skips this; use escalationForSubItem(phq9, 9, value).',
      regulatoryRefs: [
        'Joint Commission NPSG 15.01.01 (suicide risk reduction)',
        'PHQ-9 item 9 routing per Kroenke 2001 + Simon et al. 2013',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    // ─────── GAD-7 (anxiety) ───────
    CrisisTriggerRecord(
      id: 'gad7-moderate',
      instrument: ClinicalInstrument.gad7,
      cutoff: 10,
      lowerBoundInclusive: true,
      action: EscalationAction.clinicianReview,
      appliesToTotalScore: true,
      description:
          'GAD-7 >= 10 indicates moderate anxiety (Spitzer 2006). Add to clinician review queue.',
      regulatoryRefs: ['Spitzer et al. 2006 GAD-7 validation'],
    ),
    CrisisTriggerRecord(
      id: 'gad7-severe',
      instrument: ClinicalInstrument.gad7,
      cutoff: 15,
      lowerBoundInclusive: true,
      action: EscalationAction.sameDayClinicianContact,
      appliesToTotalScore: true,
      description:
          'GAD-7 >= 15 indicates severe anxiety — same-day clinician contact (Spitzer 2006).',
      regulatoryRefs: ['Spitzer et al. 2006', 'NICE Guideline CG113 (anxiety)'],
    ),
    // ─────── C-SSRS (suicide severity) ───────
    CrisisTriggerRecord(
      id: 'cssrs-ideation-with-method',
      instrument: ClinicalInstrument.cssrs,
      cutoff: 3,
      lowerBoundInclusive: true,
      action: EscalationAction.sameDayClinicianContact,
      appliesToTotalScore: true,
      description:
          'C-SSRS ideation level >= 3 (active ideation + method) — same-day contact (Posner 2011).',
      regulatoryRefs: [
        'Posner et al. 2011 C-SSRS validation',
        'Joint Commission NPSG 15.01.01',
      ],
    ),
    CrisisTriggerRecord(
      id: 'cssrs-ideation-with-plan-or-intent',
      instrument: ClinicalInstrument.cssrs,
      cutoff: 4,
      lowerBoundInclusive: true,
      action: EscalationAction.immediateCrisis,
      appliesToTotalScore: true,
      description:
          'C-SSRS ideation level >= 4 (active ideation + plan or intent) MUST trigger immediate crisis protocol (Posner 2011 + Joint Commission NPSG 15.01.01).',
      regulatoryRefs: [
        'Posner et al. 2011 C-SSRS validation',
        'Joint Commission NPSG 15.01.01 (suicide risk reduction)',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    // ─────── AUDIT (alcohol use) ───────
    CrisisTriggerRecord(
      id: 'audit-harmful-use',
      instrument: ClinicalInstrument.audit,
      cutoff: 8,
      lowerBoundInclusive: true,
      action: EscalationAction.clinicianReview,
      appliesToTotalScore: true,
      description:
          'AUDIT >= 8 indicates harmful alcohol use (Saunders 1993). Add to clinician review queue.',
      regulatoryRefs: ['Saunders et al. 1993 AUDIT validation (WHO)'],
    ),
    CrisisTriggerRecord(
      id: 'audit-dependence-likely',
      instrument: ClinicalInstrument.audit,
      cutoff: 20,
      lowerBoundInclusive: true,
      action: EscalationAction.sameDayClinicianContact,
      appliesToTotalScore: true,
      description:
          'AUDIT >= 20 suggests alcohol dependence — same-day clinician contact for further assessment (Saunders 1993).',
      regulatoryRefs: ['Saunders et al. 1993', 'NIAAA Treatment Navigator'],
    ),
    // ─────── PCL-5 (PTSD) ───────
    CrisisTriggerRecord(
      id: 'pcl5-probable-ptsd',
      instrument: ClinicalInstrument.pcl5,
      cutoff: 33,
      lowerBoundInclusive: true,
      action: EscalationAction.clinicianReview,
      appliesToTotalScore: true,
      description:
          'PCL-5 >= 33 suggests probable PTSD — add to clinician review queue for structured interview (Weathers 2013).',
      regulatoryRefs: [
        'Weathers et al. 2013 PCL-5 validation',
        'VA/DoD Clinical Practice Guideline for PTSD (2023)',
      ],
    ),
    // ─────── WHO-5 (wellbeing, inverted) ───────
    CrisisTriggerRecord(
      id: 'who5-poor-wellbeing',
      instrument: ClinicalInstrument.who5,
      cutoff: 28,
      lowerBoundInclusive: false,
      action: EscalationAction.clinicianReview,
      appliesToTotalScore: true,
      description:
          'WHO-5 <= 28 (raw, before x4) signals poor wellbeing per Topp 2015. Add to clinician review queue + consider PHQ-9 follow-up.',
      regulatoryRefs: ['Topp et al. 2015 WHO-5 systematic review'],
    ),
  ];

  static CrisisTriggerRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static List<CrisisTriggerRecord> byInstrument(ClinicalInstrument i) {
    return records.where((r) => r.instrument == i).toList();
  }
}

/// Ordinal helper for monotonic action comparisons.
int _actionOrdinal(EscalationAction a) {
  switch (a) {
    case EscalationAction.none:
      return 0;
    case EscalationAction.clinicianReview:
      return 1;
    case EscalationAction.sameDayClinicianContact:
      return 2;
    case EscalationAction.immediateCrisis:
      return 3;
  }
}

/// True when action [a] is at least as severe as [b]. Drives the
/// escalation pipeline routing.
bool actionAtLeast(EscalationAction a, EscalationAction b) {
  return _actionOrdinal(a) >= _actionOrdinal(b);
}

/// Given an instrument + TOTAL score, return the highest matching
/// escalation action across all TOTAL-SCORE thresholds. Returns
/// `EscalationAction.none` if no threshold matches. SUB-ITEM
/// thresholds (e.g. PHQ-9 item 9) are intentionally skipped — use
/// [escalationForSubItem] for those.
EscalationAction escalationForScore(ClinicalInstrument i, int score) {
  EscalationAction worst = EscalationAction.none;
  for (final r in CrisisTriggerThresholdCatalog.byInstrument(i)) {
    if (!r.appliesToTotalScore) continue;
    final matched = r.lowerBoundInclusive
        ? score >= r.cutoff
        : score <= r.cutoff;
    if (matched && actionAtLeast(r.action, worst)) {
      worst = r.action;
    }
  }
  return worst;
}

/// Given an instrument + sub-item id (free-form, e.g. 'item9') +
/// the sub-item value, return the matching escalation action.
/// Caller looks up the matching threshold by [recordId] (because
/// sub-item rules are scale-specific, e.g. only PHQ-9 has item9).
EscalationAction escalationForSubItem(String recordId, int value) {
  final r = CrisisTriggerThresholdCatalog.byId(recordId);
  if (r == null || r.appliesToTotalScore) return EscalationAction.none;
  final matched = r.lowerBoundInclusive ? value >= r.cutoff : value <= r.cutoff;
  return matched ? r.action : EscalationAction.none;
}
