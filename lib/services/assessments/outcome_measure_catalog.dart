/// O3 — Outcome measure catalog (pinned helper).
///
/// **Why this exists**: `lib/services/assessments/clinical_scales.dart`
/// already pins the items + per-item scoring for each instrument
/// (PHQ-9, GAD-7, WHO-5, AUDIT, PCL-5, etc.). What is NOT pinned
/// today is the *decision-support* layer on top: severity bands,
/// re-administration cadence, alarm threshold that triggers a
/// clinician review, and the published-guideline citation each
/// threshold is grounded in.
///
/// Pinning that here:
///   1. The clinical-scale screen shows a deterministic severity
///      badge keyed on the score (not a free-text interpretation).
///   2. A re-admin reminder cron fires at the published cadence
///      per scale (PHQ-9 every 2 weeks, WHO-5 every 4 weeks, etc.).
///   3. Audit log records the alarm threshold + the runbook
///      pointer when a score crosses it — required by Joint
///      Commission NPSG 15.01.01 (suicide-risk reduction).
///
/// **Out of scope** (separate PRs):
///   * Patch clinical_scale_screen.dart to read severity badges
///     from this catalog.
///   * Re-admin reminder Cloud Function.
///   * Adolescent / child variants (PHQ-A, GAD-7-A) — landed as a
///     separate PR with their own published thresholds.
library;

/// Severity band the score falls into.
enum OutcomeSeverity { none, minimal, mild, moderate, moderatelySevere, severe }

/// One severity band for a scale.
class SeverityBand {
  const SeverityBand({
    required this.severity,
    required this.minScore,
    required this.maxScore,
    required this.clinicianAction,
  });

  final OutcomeSeverity severity;
  final int minScore;
  final int maxScore;

  /// Plain-language action the clinician dashboard surfaces when
  /// the score lands in this band. Never the diagnosis itself.
  final String clinicianAction;
}

/// One pinned outcome measure record.
class OutcomeMeasureRecord {
  const OutcomeMeasureRecord({
    required this.scaleId,
    required this.fullName,
    required this.maxScore,
    required this.bands,
    required this.alarmThreshold,
    required this.runbookId,
    required this.readminInterval,
    required this.validatedPopulation,
    required this.regulatoryRefs,
  });

  /// MUST match an id in `ClinicalScales` (e.g. `phq9`, `gad7`,
  /// `audit`, `who5`, `pcl5`). Tests pin parity against the
  /// known-good set.
  final String scaleId;

  final String fullName;

  /// Maximum possible score for the instrument.
  final int maxScore;

  /// Severity bands. Must cover [0, maxScore] contiguously with no
  /// gaps or overlaps — tests enforce this.
  final List<SeverityBand> bands;

  /// Score at or above this triggers the clinician-review alarm.
  /// Lower bound of the action-required band (typically moderate
  /// onwards).
  final int alarmThreshold;

  /// Stable id of the escalation runbook (matches `risk_escalation_
  /// chain` for suicidality-bearing measures, or the generic
  /// clinical-review runbook for severity-only).
  final String runbookId;

  /// Recommended days between administrations per published
  /// guideline. Drives the reminder cron.
  final int readminInterval;

  /// Population the published thresholds were validated against
  /// (`adult`, `geriatric`, `perinatal`, etc.). Tests pin we ship
  /// at least one adult-validated row.
  final String validatedPopulation;

  final List<String> regulatoryRefs;
}

class OutcomeMeasureCatalog {
  const OutcomeMeasureCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned records. Append-only.
  static const List<OutcomeMeasureRecord> measures = [
    OutcomeMeasureRecord(
      scaleId: 'phq9',
      fullName: 'Patient Health Questionnaire-9 (PHQ-9)',
      maxScore: 27,
      bands: [
        SeverityBand(
          severity: OutcomeSeverity.minimal,
          minScore: 0,
          maxScore: 4,
          clinicianAction: 'No action required; re-screen at next visit.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.mild,
          minScore: 5,
          maxScore: 9,
          clinicianAction: 'Watchful waiting; repeat in 2-4 weeks.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.moderate,
          minScore: 10,
          maxScore: 14,
          clinicianAction:
              'Treatment plan; counselling / pharmacotherapy decision.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.moderatelySevere,
          minScore: 15,
          maxScore: 19,
          clinicianAction: 'Active treatment; pharmacotherapy + therapy.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.severe,
          minScore: 20,
          maxScore: 27,
          clinicianAction:
              'Immediate treatment; expedited referral if symptoms acute.',
        ),
      ],
      alarmThreshold: 10,
      runbookId: 'cssrs-or-phq9-item9',
      readminInterval: 14,
      validatedPopulation: 'adult',
      regulatoryRefs: [
        'Kroenke, Spitzer, Williams (2001) PHQ-9 validation',
        'NICE CG90 depression in adults',
        'Joint Commission NPSG 15.01.01 (item 9 suicidality)',
      ],
    ),
    OutcomeMeasureRecord(
      scaleId: 'gad7',
      fullName: 'Generalised Anxiety Disorder-7 (GAD-7)',
      maxScore: 21,
      bands: [
        SeverityBand(
          severity: OutcomeSeverity.minimal,
          minScore: 0,
          maxScore: 4,
          clinicianAction: 'No action required; re-screen at next visit.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.mild,
          minScore: 5,
          maxScore: 9,
          clinicianAction: 'Watchful waiting; repeat in 2-4 weeks.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.moderate,
          minScore: 10,
          maxScore: 14,
          clinicianAction: 'Active treatment decision; counselling first-line.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.severe,
          minScore: 15,
          maxScore: 21,
          clinicianAction:
              'Active treatment; consider pharmacotherapy alongside therapy.',
        ),
      ],
      alarmThreshold: 10,
      runbookId: 'generic-clinical-review',
      readminInterval: 14,
      validatedPopulation: 'adult',
      regulatoryRefs: [
        'Spitzer, Kroenke, Williams, Löwe (2006) GAD-7 validation',
        'NICE CG113 generalised anxiety disorder',
      ],
    ),
    OutcomeMeasureRecord(
      scaleId: 'who5',
      fullName: 'WHO-5 Wellbeing Index',
      maxScore: 25,
      bands: [
        SeverityBand(
          severity: OutcomeSeverity.severe,
          minScore: 0,
          maxScore: 12,
          clinicianAction:
              'Likely depression; administer PHQ-9 + clinical review.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.moderate,
          minScore: 13,
          maxScore: 17,
          clinicianAction: 'Reduced wellbeing; explore + re-screen in 2 weeks.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.none,
          minScore: 18,
          maxScore: 25,
          clinicianAction: 'Good wellbeing; no further action.',
        ),
      ],
      alarmThreshold: 13,
      runbookId: 'generic-clinical-review',
      readminInterval: 28,
      validatedPopulation: 'adult',
      regulatoryRefs: [
        'WHO-5 (1998) Hellenic translation + validation',
        'Topp et al. (2015) WHO-5 systematic review',
      ],
    ),
    OutcomeMeasureRecord(
      scaleId: 'audit',
      fullName: 'AUDIT — Alcohol Use Disorders Identification Test',
      maxScore: 40,
      bands: [
        SeverityBand(
          severity: OutcomeSeverity.minimal,
          minScore: 0,
          maxScore: 7,
          clinicianAction: 'No action; education leaflet at discharge.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.mild,
          minScore: 8,
          maxScore: 15,
          clinicianAction: 'Brief intervention; re-screen in 12 weeks.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.moderate,
          minScore: 16,
          maxScore: 19,
          clinicianAction:
              'Counselling + monitoring; consider specialist referral.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.severe,
          minScore: 20,
          maxScore: 40,
          clinicianAction: 'Specialist referral for alcohol-use treatment.',
        ),
      ],
      alarmThreshold: 16,
      runbookId: 'generic-clinical-review',
      readminInterval: 84,
      validatedPopulation: 'adult',
      regulatoryRefs: [
        'WHO AUDIT (Saunders et al., 1993)',
        'NICE CG115 alcohol-use disorders',
      ],
    ),
    OutcomeMeasureRecord(
      scaleId: 'pcl5',
      fullName: 'PCL-5 — PTSD Checklist for DSM-5',
      maxScore: 80,
      bands: [
        SeverityBand(
          severity: OutcomeSeverity.minimal,
          minScore: 0,
          maxScore: 32,
          clinicianAction: 'No PTSD diagnosis indicated; re-screen as needed.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.moderate,
          minScore: 33,
          maxScore: 50,
          clinicianAction:
              'Probable PTSD; administer structured clinical interview.',
        ),
        SeverityBand(
          severity: OutcomeSeverity.severe,
          minScore: 51,
          maxScore: 80,
          clinicianAction:
              'High symptom burden; expedited PTSD-specialist consult.',
        ),
      ],
      alarmThreshold: 33,
      runbookId: 'generic-clinical-review',
      readminInterval: 28,
      validatedPopulation: 'adult',
      regulatoryRefs: [
        'Weathers et al. (2013) PCL-5 development',
        'NICE NG116 post-traumatic stress disorder',
      ],
    ),
  ];

  static OutcomeMeasureRecord? byScaleId(String id) {
    for (final m in measures) {
      if (m.scaleId == id) return m;
    }
    return null;
  }
}

/// Resolves the severity band a [score] falls into for [record].
/// Returns null when the score is out of range.
SeverityBand? bandForScore(OutcomeMeasureRecord record, int score) {
  for (final b in record.bands) {
    if (score >= b.minScore && score <= b.maxScore) return b;
  }
  return null;
}

/// True when [score] meets or exceeds the alarm threshold + needs
/// clinician review.
bool requiresClinicianAlarm(OutcomeMeasureRecord record, int score) =>
    score >= record.alarmThreshold;
