import 'package:flutter/foundation.dart';

import '../models/supervision_review.dart';

/// Contract for the trainee → supervisor co-sign queue.
///
/// Sprint 9 ships the in-memory implementation so the UI is testable
/// end-to-end. A Firestore-backed adapter lands once the
/// `supervision_reviews` collection has its own security rules + audit
/// hook (Sprint 10 backlog).
abstract class SupervisionReviewRepository extends ChangeNotifier {
  List<SupervisionReview> openQueueFor(String supervisorId);
  List<SupervisionReview> allFor(String supervisorId);
  SupervisionReview? byId(String id);

  /// Trainee submits — creates a [SupervisionReviewStatus.pending] row.
  SupervisionReview submit({
    required String clinicId,
    required String traineeId,
    required String supervisorId,
    required String sessionNoteId,
  });

  /// Supervisor decides. Throws [StateError] when the transition is not
  /// allowed by [SupervisionReview.transitionBlockedReason].
  SupervisionReview decide({
    required String id,
    required SupervisionReviewStatus next,
    String comment = '',
  });

  /// Trainee resubmits after `changes_requested`. Throws [StateError]
  /// if the review is not currently in `changes_requested`.
  SupervisionReview resubmit(String id);
}

/// In-memory implementation. Singleton — process-scoped state.
class InMemorySupervisionReviewRepository extends SupervisionReviewRepository {
  InMemorySupervisionReviewRepository._();
  static final InMemorySupervisionReviewRepository instance =
      InMemorySupervisionReviewRepository._();

  final Map<String, SupervisionReview> _byId = {};

  @override
  List<SupervisionReview> openQueueFor(String supervisorId) => _byId.values
      .where((r) => r.supervisorId == supervisorId && r.isOpen)
      .toList(growable: false);

  @override
  List<SupervisionReview> allFor(String supervisorId) => _byId.values
      .where((r) => r.supervisorId == supervisorId)
      .toList(growable: false);

  @override
  SupervisionReview? byId(String id) => _byId[id];

  @override
  SupervisionReview submit({
    required String clinicId,
    required String traineeId,
    required String supervisorId,
    required String sessionNoteId,
  }) {
    final id = 'rev-${DateTime.now().microsecondsSinceEpoch}';
    final row = SupervisionReview(
      id: id,
      clinicId: clinicId,
      traineeId: traineeId,
      supervisorId: supervisorId,
      sessionNoteId: sessionNoteId,
    );
    _byId[id] = row;
    notifyListeners();
    return row;
  }

  @override
  SupervisionReview decide({
    required String id,
    required SupervisionReviewStatus next,
    String comment = '',
  }) {
    final cur = _byId[id];
    if (cur == null) {
      throw StateError('Review $id not found');
    }
    final blocked = cur.transitionBlockedReason(next);
    if (blocked != null) {
      throw StateError(blocked);
    }
    final updated = cur.copyWith(
      status: next,
      supervisorComment: comment.isNotEmpty ? comment : cur.supervisorComment,
      decidedAt: DateTime.now().toUtc(),
    );
    _byId[id] = updated;
    notifyListeners();
    return updated;
  }

  @override
  SupervisionReview resubmit(String id) {
    final cur = _byId[id];
    if (cur == null) {
      throw StateError('Review $id not found');
    }
    if (cur.status != SupervisionReviewStatus.changesRequested) {
      throw StateError('Only reviews in changes_requested can be resubmitted');
    }
    final updated = cur.copyWith(status: SupervisionReviewStatus.pending);
    _byId[id] = updated;
    notifyListeners();
    return updated;
  }

  /// Visible-for-test only — wipes every entry.
  void clearForTesting() {
    _byId.clear();
    notifyListeners();
  }
}
