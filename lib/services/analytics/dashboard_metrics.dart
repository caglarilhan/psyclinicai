/// Active-dashboard 4-metric roll-up (plan §B).
///
/// `dashboard_screen.dart` currently shows an empty hero. The plan
/// calls for four cards the clinician can act on first thing in the
/// morning: Today's sessions, Pending notes (>24h unsigned), At-risk
/// patients (last 7d C-SSRS/PHQ-9 trigger), Outstanding superbills.
///
/// This service computes the numbers from in-memory inputs so the
/// Sprint 16 UI can render them off a single `DashboardMetrics`
/// object without re-running queries on every rebuild. Pure
/// functions only.
library;

class DashboardInputs {
  const DashboardInputs({
    required this.now,
    required this.appointmentsToday,
    required this.sessions,
    required this.atRiskPatientIds,
    required this.superbills,
  });

  final DateTime now;
  final List<DashboardAppointment> appointmentsToday;
  final List<DashboardSession> sessions;

  /// IDs of patients that triggered a risk event (C-SSRS positive or
  /// PHQ-9 q9 ≥ 1) in the last 7 days. Already de-duplicated.
  final List<String> atRiskPatientIds;

  final List<DashboardSuperbill> superbills;
}

class DashboardAppointment {
  const DashboardAppointment({
    required this.id,
    required this.patientName,
    required this.startsAt,
    required this.kind,
    this.cancelled = false,
  });

  final String id;
  final String patientName;
  final DateTime startsAt;
  final String kind;
  final bool cancelled;
}

class DashboardSession {
  const DashboardSession({
    required this.id,
    required this.endedAt,
    this.signedAt,
  });

  final String id;
  final DateTime endedAt;
  final DateTime? signedAt;

  bool unsignedAfter(Duration window, DateTime now) =>
      signedAt == null && now.difference(endedAt) > window;
}

class DashboardSuperbill {
  const DashboardSuperbill({
    required this.id,
    required this.amountCents,
    required this.status,
    required this.issuedAt,
  });

  final String id;
  final int amountCents;

  /// One of `paid` / `unpaid` / `partial` / `void`.
  final String status;
  final DateTime issuedAt;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.todaysSessionCount,
    required this.nextAppointment,
    required this.pendingNotesCount,
    required this.atRiskCount,
    required this.outstandingTotalCents,
    required this.oldestOutstandingAgeDays,
  });

  final int todaysSessionCount;
  final DashboardAppointment? nextAppointment;
  final int pendingNotesCount;
  final int atRiskCount;
  final int outstandingTotalCents;
  final int oldestOutstandingAgeDays;

  bool get hasAnythingToShow =>
      todaysSessionCount > 0 ||
      pendingNotesCount > 0 ||
      atRiskCount > 0 ||
      outstandingTotalCents > 0;
}

class DashboardMetricsBuilder {
  const DashboardMetricsBuilder({
    this.unsignedWindow = const Duration(hours: 24),
  });

  /// How long after `endedAt` an unsigned session counts as "pending".
  final Duration unsignedWindow;

  DashboardMetrics build(DashboardInputs input) {
    final today = DateTime(input.now.year, input.now.month, input.now.day);
    final liveAppointments = input.appointmentsToday
        .where((a) => !a.cancelled)
        .where(
          (a) => DateTime(
            a.startsAt.year,
            a.startsAt.month,
            a.startsAt.day,
          ).isAtSameMomentAs(today),
        )
        .toList(growable: false);
    liveAppointments.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    final next = liveAppointments
        .where((a) => a.startsAt.isAfter(input.now))
        .toList(growable: false);

    final pending = input.sessions
        .where((s) => s.unsignedAfter(unsignedWindow, input.now))
        .length;

    final unpaid = input.superbills
        .where((s) => s.status == 'unpaid' || s.status == 'partial')
        .toList(growable: false);
    final outstandingTotalCents = unpaid.fold<int>(
      0,
      (sum, s) => sum + s.amountCents,
    );
    final oldestAge = unpaid.isEmpty
        ? 0
        : unpaid
              .map((s) => input.now.difference(s.issuedAt).inDays)
              .reduce((a, b) => a > b ? a : b);

    return DashboardMetrics(
      todaysSessionCount: liveAppointments.length,
      nextAppointment: next.isEmpty ? null : next.first,
      pendingNotesCount: pending,
      atRiskCount: input.atRiskPatientIds.toSet().length,
      outstandingTotalCents: outstandingTotalCents,
      oldestOutstandingAgeDays: oldestAge,
    );
  }
}
