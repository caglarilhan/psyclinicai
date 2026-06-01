/// Pure conflict-detection helpers for [Appointment]. Kept out of the
/// service so they can be unit-tested without bootstrapping
/// [SharedPreferences] or [NotificationService].
///
/// "Overlap" follows the standard half-open interval rule: `[start, end)`.
/// An appointment that ends exactly when another starts does NOT conflict
/// — that's a back-to-back booking, which clinicians want.
library;

import '../models/appointment_model.dart';

/// True when two `[start, end)` intervals overlap by any amount.
///
/// Returns `false` for back-to-back appointments where one ends at the
/// moment the next begins.
bool intervalsOverlap(
    DateTime startA, DateTime endA, DateTime startB, DateTime endB) {
  return startA.isBefore(endB) && endA.isAfter(startB);
}

/// Returns the first appointment in [existing] that overlaps with
/// [candidate], or `null` if there is no conflict.
///
/// Pass [excludeId] when editing an existing appointment so the check
/// does not flag the appointment against its own previous slot.
Appointment? findConflictingAppointment(
  Appointment candidate,
  Iterable<Appointment> existing, {
  String? excludeId,
}) {
  for (final a in existing) {
    if (excludeId != null && a.id == excludeId) continue;
    if (intervalsOverlap(
        candidate.startTime, candidate.endTime, a.startTime, a.endTime)) {
      return a;
    }
  }
  return null;
}

/// Convenience wrapper that returns just a boolean.
bool hasAppointmentConflict(
  Appointment candidate,
  Iterable<Appointment> existing, {
  String? excludeId,
}) =>
    findConflictingAppointment(candidate, existing, excludeId: excludeId) !=
    null;
