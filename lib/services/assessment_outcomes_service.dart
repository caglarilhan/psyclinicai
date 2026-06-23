/// Pure helpers that turn ASEBA + Vanderbilt records into chart-
/// ready trend series. The outcomes widget consumes these so the
/// dashboard layer stays widget-only; the maths is unit-testable
/// in isolation.
///
/// Series shapes:
///   - `asebaTotalProblemsTrend` — one point per capture, sorted
///     oldest-first, value = composite total-problems T-score.
///     Returns an empty list when the patient has no captures.
///   - `vanderbiltInattentionTrend` /
///     `vanderbiltHyperactivityTrend` — symptom count per capture.
library;

import '../models/aseba_score_record.dart';
import '../models/vanderbilt_assessment.dart';

class AssessmentTrendPoint {
  const AssessmentTrendPoint({
    required this.at,
    required this.value,
    this.label,
  });
  final DateTime at;
  final num value;
  final String? label;
}

class AssessmentOutcomesService {
  /// ASEBA Total Problems composite trend (T-score). One point per
  /// capture, oldest-first. When a record is missing the composite,
  /// the helper skips that record rather than substituting 0 —
  /// charting layer reads the gap as "not entered".
  static List<AssessmentTrendPoint> asebaTotalProblemsTrend(
    Iterable<AsebaScoreRecord> records,
  ) {
    final sorted = records.toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    final out = <AssessmentTrendPoint>[];
    for (final r in sorted) {
      final t = r.compositeT[AsebaCompositeScale.totalProblems];
      if (t == null) continue;
      out.add(
        AssessmentTrendPoint(at: r.capturedAt, value: t, label: r.form.label),
      );
    }
    return out;
  }

  /// ASEBA syndrome-scale clinical-count trend. Counts subscales
  /// scored at T >= 70 per capture.
  static List<AssessmentTrendPoint> asebaSyndromeClinicalTrend(
    Iterable<AsebaScoreRecord> records,
  ) {
    final sorted = records.toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return [
      for (final r in sorted)
        AssessmentTrendPoint(
          at: r.capturedAt,
          value: r.syndromeClinicalCount,
          label: r.form.label,
        ),
    ];
  }

  /// Vanderbilt inattention symptom-count trend. Counts items
  /// scored 2 (Often) or 3 (Very Often) per capture. Sorted
  /// oldest-first.
  static List<AssessmentTrendPoint> vanderbiltInattentionTrend(
    Iterable<VanderbiltAssessment> records,
  ) {
    return _vanderbiltCounts(records, (a) => a.inattentionSymptomCount);
  }

  /// Vanderbilt hyperactivity / impulsivity symptom-count trend.
  static List<AssessmentTrendPoint> vanderbiltHyperactivityTrend(
    Iterable<VanderbiltAssessment> records,
  ) {
    return _vanderbiltCounts(records, (a) => a.hyperactivitySymptomCount);
  }

  static List<AssessmentTrendPoint> _vanderbiltCounts(
    Iterable<VanderbiltAssessment> records,
    int Function(VanderbiltAssessment) count,
  ) {
    final sorted = records.toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return [
      for (final r in sorted)
        AssessmentTrendPoint(
          at: r.capturedAt,
          value: count(r),
          label: r.respondent == VanderbiltRespondent.parent
              ? 'Parent'
              : 'Teacher',
        ),
    ];
  }

  /// Latest subtype call from the most recent record. Returns null
  /// when no Vanderbilt records exist for the patient.
  static VanderbiltSubtype? latestSubtype(
    Iterable<VanderbiltAssessment> records,
  ) {
    if (records.isEmpty) return null;
    final list = records.toList()
      ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return list.first.subtype;
  }
}
