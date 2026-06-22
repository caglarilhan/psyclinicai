/// GDPR Article 17 "right to erasure" request — captures the moment the
/// user asks for their account to be deleted, plus the 30-day grace
/// window that lets them undo it.
///
/// The request is the source of truth: the actual data purge runs as a
/// scheduled job after [graceEndsAt] passes. Cancelling the request
/// before then nulls out [completedAt] and stops the purge.
library;

/// Lifecycle of a deletion request.
enum DeletionStatus {
  /// User submitted the request; grace window running.
  pendingGrace,

  /// User cancelled before the grace window closed.
  cancelled,

  /// Purge job ran to completion.
  completed;

  static DeletionStatus fromId(String? id) {
    for (final s in DeletionStatus.values) {
      if (s.name == id) return s;
    }
    return DeletionStatus.pendingGrace;
  }
}

/// Default grace window — 30 days, matching the standard EU practice
/// (GDPR does not name a number; we pick a conservative one).
const Duration accountDeletionGrace = Duration(days: 30);

class AccountDeletionRequest {
  AccountDeletionRequest({
    required this.userId,
    required this.requestedAt,
    Duration grace = accountDeletionGrace,
    this.cancelledAt,
    this.completedAt,
    this.reasonCode,
  }) : graceEndsAt = requestedAt.toUtc().add(grace);

  factory AccountDeletionRequest.fromJson(Map<String, dynamic> json) {
    final requested = DateTime.parse(json['requested_at'] as String);
    final graceEnds = DateTime.tryParse(json['grace_ends_at'] as String? ?? '');
    return AccountDeletionRequest(
      userId: json['user_id'] as String,
      requestedAt: requested,
      grace: graceEnds == null
          ? accountDeletionGrace
          : graceEnds.toUtc().difference(requested.toUtc()),
      cancelledAt: DateTime.tryParse(json['cancelled_at'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      reasonCode: json['reason_code'] as String?,
    );
  }

  final String userId;
  final DateTime requestedAt;
  final DateTime graceEndsAt;

  /// Set when the user clicked "Undo deletion" before the grace window
  /// closed.
  final DateTime? cancelledAt;

  /// Set after the purge job completes — captures the moment the user's
  /// data was actually removed.
  final DateTime? completedAt;

  /// Free-text reason chosen by the user (kept short — UI offers a
  /// dropdown). Not required.
  final String? reasonCode;

  /// Computed status snapshot at the current wall-clock.
  DeletionStatus statusAt(DateTime now) {
    if (cancelledAt != null) return DeletionStatus.cancelled;
    if (completedAt != null) return DeletionStatus.completed;
    return DeletionStatus.pendingGrace;
  }

  /// True only while the request is still waiting out the grace window.
  bool isInGraceWindowAt(DateTime now) {
    if (statusAt(now) != DeletionStatus.pendingGrace) return false;
    return now.toUtc().isBefore(graceEndsAt);
  }

  /// True when the grace window has elapsed AND the request was not
  /// cancelled — i.e. the purge job is allowed to run.
  bool isReadyToPurgeAt(DateTime now) {
    if (statusAt(now) != DeletionStatus.pendingGrace) return false;
    return !now.toUtc().isBefore(graceEndsAt);
  }

  AccountDeletionRequest copyWith({
    DateTime? cancelledAt,
    DateTime? completedAt,
    String? reasonCode,
  }) {
    return AccountDeletionRequest(
      userId: userId,
      requestedAt: requestedAt,
      grace: graceEndsAt.difference(requestedAt.toUtc()),
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completedAt: completedAt ?? this.completedAt,
      reasonCode: reasonCode ?? this.reasonCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'requested_at': requestedAt.toUtc().toIso8601String(),
    'grace_ends_at': graceEndsAt.toUtc().toIso8601String(),
    if (cancelledAt != null)
      'cancelled_at': cancelledAt!.toUtc().toIso8601String(),
    if (completedAt != null)
      'completed_at': completedAt!.toUtc().toIso8601String(),
    if (reasonCode != null) 'reason_code': reasonCode,
  };
}
