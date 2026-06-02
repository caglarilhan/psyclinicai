/// B20 (Sprint 9) — caseload-level outcomes metrics.
///
/// The previous outcomes dashboard computed a single-patient delta
/// inline (`_delta` in `_DeltaSummary`). That made it impossible to:
///   • test the maths in isolation,
///   • surface caseload-wide trends (the actual review request),
///   • reuse the numbers in the AI Diagnosis context.
///
/// This file exposes pure, side-effect-free functions over a series
/// of assessment scores. Anything UI lives in the widget.
library;

/// Time-ordered assessment scores for one patient × one instrument.
///
/// `scores` is ordered earliest → latest. `instrument` matches the
/// repository convention (`phq9`, `gad7`, …).
class PatientOutcomeSeries {
  const PatientOutcomeSeries({
    required this.patientId,
    required this.instrument,
    required this.scores,
  });

  final String patientId;
  final String instrument;
  final List<int> scores;
}

/// Roll-up across a caseload — the 3 numbers the outcomes panel
/// surfaces above the per-patient chart.
class CaseloadOutcomeMetrics {
  const CaseloadOutcomeMetrics({
    required this.patientCount,
    required this.avgFirstScore,
    required this.avgLastScore,
    required this.responseRate,
  });

  /// Distinct patients with ≥2 datapoints for the instrument.
  final int patientCount;

  /// Mean of every patient's first score. Returns 0 when [patientCount]
  /// is 0 — callers should branch on count first when rendering.
  final double avgFirstScore;

  /// Mean of every patient's last score.
  final double avgLastScore;

  /// Fraction (0..1) of patients whose last score is ≥50% lower than
  /// their first. 50% is the conventional "response" cutoff for PHQ-9
  /// and GAD-7. Returns 0 when [patientCount] is 0.
  final double responseRate;

  /// Average movement (positive = worse, negative = improvement).
  double get avgDelta => avgLastScore - avgFirstScore;

  /// True when at least one patient series qualified.
  bool get hasData => patientCount > 0;
}

/// Builds the caseload roll-up for a given instrument from a list of
/// per-patient series. Series with <2 datapoints are skipped — we need
/// both a baseline and a follow-up to compute anything useful.
CaseloadOutcomeMetrics buildCaseloadMetrics({
  required String instrument,
  required List<PatientOutcomeSeries> series,
}) {
  final eligible = series
      .where((s) => s.instrument == instrument && s.scores.length >= 2)
      .toList(growable: false);

  if (eligible.isEmpty) {
    return const CaseloadOutcomeMetrics(
      patientCount: 0,
      avgFirstScore: 0,
      avgLastScore: 0,
      responseRate: 0,
    );
  }

  var firstSum = 0;
  var lastSum = 0;
  var responders = 0;
  for (final s in eligible) {
    final first = s.scores.first;
    final last = s.scores.last;
    firstSum += first;
    lastSum += last;
    // Symptom-scale convention: lower = better. A first score of 0 is
    // a non-symptomatic baseline; "response" is undefined, so we skip
    // it from the numerator (denominator still counts the patient).
    if (first > 0 && last <= first / 2) {
      responders++;
    }
  }

  final n = eligible.length;
  return CaseloadOutcomeMetrics(
    patientCount: n,
    avgFirstScore: firstSum / n,
    avgLastScore: lastSum / n,
    responseRate: responders / n,
  );
}
