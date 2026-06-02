import 'package:flutter/foundation.dart';

import '../../models/account_deletion_request.dart';

/// Contract for the account-deletion store.
///
/// Sprint 8 ships the in-memory implementation so the UI is testable
/// end-to-end. Sprint 9 lands a Firestore-backed adapter that survives
/// app restarts and lets a back-end purge job pick the row up after
/// the 30-day grace window closes.
abstract class AccountDeletionRepository extends ChangeNotifier {
  AccountDeletionRequest? current(String userId);
  void request({required String userId, String? reasonCode});
  void cancel(String userId);
  void complete(String userId);
}

/// In-memory implementation. Single instance per process.
class InMemoryAccountDeletionRepository extends AccountDeletionRepository {
  InMemoryAccountDeletionRepository._();
  static final InMemoryAccountDeletionRepository instance =
      InMemoryAccountDeletionRepository._();

  final Map<String, AccountDeletionRequest> _byUser = {};

  @override
  AccountDeletionRequest? current(String userId) => _byUser[userId];

  @override
  void request({required String userId, String? reasonCode}) {
    _byUser[userId] = AccountDeletionRequest(
      userId: userId,
      requestedAt: DateTime.now().toUtc(),
      reasonCode: reasonCode,
    );
    notifyListeners();
  }

  @override
  void cancel(String userId) {
    final cur = _byUser[userId];
    if (cur == null) return;
    _byUser[userId] = cur.copyWith(cancelledAt: DateTime.now().toUtc());
    notifyListeners();
  }

  @override
  void complete(String userId) {
    final cur = _byUser[userId];
    if (cur == null) return;
    _byUser[userId] = cur.copyWith(completedAt: DateTime.now().toUtc());
    notifyListeners();
  }

  /// Visible-for-test only — wipes every entry without going through
  /// the cancel/complete lifecycle.
  void clearForTesting() {
    _byUser.clear();
    notifyListeners();
  }
}
