/// Caseload-level outcome aggregator. Pure — takes in-memory snapshots
/// (PHQ-9 scores, appointment outcomes, goal progress) and emits the
/// metrics surfaced on the Outcomes dashboard.
///
/// Kept dependency-free so the Reports screen, the PDF export pipeline,
/// and a future BI back-end can share one calculation.
library;

/// One PHQ-9 (or other 0–N scale) result captured at a moment in time.
class OutcomeSample {
  const OutcomeSample({required this.score, required this.takenAt});
  final int score;
  final DateTime takenAt;
}

/// What happened to a single appointment (completed vs no-show vs
/// cancelled). String-typed to match [Appointment.status] without
/// pulling that model in.
class AppointmentOutcome {
  const AppointmentOutcome({required this.status, required this.scheduledFor});

  /// Free-text status — interpreted via [isNoShow]/[isCompleted] below
  /// so the registry stays open to future statuses.
  final String status;
  final DateTime scheduledFor;

  bool get isNoShow {
    final s = status.toLowerCase();
    return s.contains('no-show') || s.contains('noshow') || s == 'no_show';
  }

  bool get isCompleted {
    final s = status.toLowerCase();
    return s.contains('complete') || s == 'done' || s == 'attended';
  }

  /// True when the appointment was filled, regardless of outcome
  /// (denominator for the no-show rate).
  bool get isFinalised {
    final s = status.toLowerCase();
    return isCompleted ||
        isNoShow ||
        s.contains('cancel') ||
        s.contains('rescheduled');
  }
}

/// Aggregated metrics for one caseload over an arbitrary window.
class CaseloadOutcomeMetrics {
  const CaseloadOutcomeMetrics({
    required this.totalSamples,
    required this.firstSample,
    required this.latestSample,
    required this.delta,
    required this.totalAppointments,
    required this.finalisedAppointments,
    required this.noShowCount,
    required this.completedGoalsRatio,
  });

  /// Number of outcome samples in the window.
  final int totalSamples;

  /// Earliest sample, or `null` if no samples.
  final OutcomeSample? firstSample;

  /// Most recent sample, or `null` if no samples.
  final OutcomeSample? latestSample;

  /// Latest minus first, signed (negative = improvement on PHQ-9).
  /// `null` when there's nothing to compare.
  final int? delta;

  /// All appointments in the window.
  final int totalAppointments;

  /// Appointments that reached a final state (completed / no-show /
  /// cancelled / rescheduled). Pending future appointments are excluded
  /// because they don't yet count toward the no-show denominator.
  final int finalisedAppointments;

  /// Number of no-shows.
  final int noShowCount;

  /// 0.0 – 1.0 — share of treatment goals that are fully met (progress
  /// == 100).
  final double completedGoalsRatio;

  /// No-show rate over the finalised denominator. Returns 0 when the
  /// denominator is empty so the UI never has to special-case NaN.
  double get noShowRate =>
      finalisedAppointments == 0 ? 0 : noShowCount / finalisedAppointments;

  /// True only when the latest sample is at least 5 points lower than
  /// the first — a heuristic "reliable improvement" guard for the
  /// dashboard chip. Real RCI requires standard-error inputs we don't
  /// store yet.
  bool get hasReliableImprovement {
    final d = delta;
    return d != null && d <= -5;
  }
}

/// Build metrics from the supplied snapshots. All arguments are
/// independently optional so the caller can omit signals they don't
/// have (e.g. when the patient hasn't completed a PHQ-9 yet).
///
/// [goalProgressValues] is a list of 0–100 percentages — one per active
/// treatment goal.
CaseloadOutcomeMetrics buildCaseloadMetrics({
  List<OutcomeSample> samples = const [],
  List<AppointmentOutcome> appointments = const [],
  List<int> goalProgressValues = const [],
}) {
  final sorted = [...samples]..sort((a, b) => a.takenAt.compareTo(b.takenAt));
  final first = sorted.isEmpty ? null : sorted.first;
  final latest = sorted.isEmpty ? null : sorted.last;
  final delta = (first == null || latest == null)
      ? null
      : (sorted.length < 2 ? null : latest.score - first.score);

  final finalised = appointments.where((a) => a.isFinalised).length;
  final noShow = appointments.where((a) => a.isNoShow).length;

  final completedGoals =
      goalProgressValues.where((p) => p >= 100).length;
  final ratio = goalProgressValues.isEmpty
      ? 0.0
      : completedGoals / goalProgressValues.length;

  return CaseloadOutcomeMetrics(
    totalSamples: sorted.length,
    firstSample: first,
    latestSample: latest,
    delta: delta,
    totalAppointments: appointments.length,
    finalisedAppointments: finalised,
    noShowCount: noShow,
    completedGoalsRatio: ratio,
  );
}
