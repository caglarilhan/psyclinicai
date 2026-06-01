import 'package:flutter/foundation.dart';

/// One row of the soft-lock list — a patient who left an imminent /
/// immediate C-SSRS escalation without an explicit safety-plan
/// completion. Banner stays up for 24 hours so the next clinician
/// touch (dashboard load, chart open) cannot miss it.
class EscalationSoftLockEntry {
  const EscalationSoftLockEntry({
    required this.patientId,
    required this.patientName,
    required this.severity,
    required this.tier,
    required this.reason,
    required this.dismissedAt,
  });

  final String patientId;
  final String patientName;

  /// Canonical severity from the C-SSRS scorer (`severe` / `critical`).
  final String severity;

  /// Tier the modal was at when dismissed (`immediate` / `imminent`).
  final String tier;

  /// Clinician-supplied reason code from the dismissal picker.
  final String reason;

  final DateTime dismissedAt;

  /// True while the dismissal is still inside the 24-hour follow-up
  /// window. Time-bounded so a stale entry does not linger on the
  /// dashboard forever.
  bool isActiveAt(DateTime now) {
    return now.toUtc().difference(dismissedAt.toUtc()) <
        const Duration(hours: 24);
  }
}

/// In-memory soft-lock registry. Sprint 6 keeps it RAM-only so the
/// dashboard banner works today; Sprint 7 lands a Firestore mirror so
/// the lock survives a refresh and another clinician on the same
/// caseload can see it too.
class EscalationSoftLock extends ChangeNotifier {
  EscalationSoftLock._();
  static final EscalationSoftLock instance = EscalationSoftLock._();

  final List<EscalationSoftLockEntry> _entries = [];

  /// All entries (chronological).
  List<EscalationSoftLockEntry> get entries =>
      List.unmodifiable(_entries);

  /// Entries whose 24-hour follow-up window is still open.
  List<EscalationSoftLockEntry> activeAt(DateTime now) =>
      _entries.where((e) => e.isActiveAt(now)).toList(growable: false);

  /// True when the patient has at least one active soft-lock entry.
  bool isLocked(String patientId, {DateTime? now}) {
    final stamp = now ?? DateTime.now();
    return _entries.any((e) =>
        e.patientId == patientId && e.isActiveAt(stamp));
  }

  void record(EscalationSoftLockEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  /// Drops every entry; useful from tests and from a future "supervisor
  /// reviewed" workflow.
  void clearForTesting() {
    _entries.clear();
    notifyListeners();
  }
}
