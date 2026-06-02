import 'package:flutter/foundation.dart';

import '../../models/portal_dsar_request.dart';

/// Patient-side DSAR queue. RAM-only in Sprint 13; a Firestore adapter
/// lands in Sprint 14 once the `portal_dsar_requests` collection has
/// security rules + an admin handoff cron.
abstract class PortalDsarRepository extends ChangeNotifier {
  List<PortalDsarRequest> forUser(String userId);
  PortalDsarRequest? byId(String id);

  /// Patient files a new request. Always lands in `submitted`.
  PortalDsarRequest submit({
    required String userId,
    required String patientId,
    required PortalDsarKind kind,
    String notes,
  });

  /// Admin moves the request forward. Throws [StateError] when the
  /// transition is disallowed.
  PortalDsarRequest advance({
    required String id,
    required PortalDsarState next,
    String? notes,
  });
}

class InMemoryPortalDsarRepository extends PortalDsarRepository {
  InMemoryPortalDsarRepository._();
  static final InMemoryPortalDsarRepository instance =
      InMemoryPortalDsarRepository._();

  final Map<String, PortalDsarRequest> _byId = {};

  @override
  List<PortalDsarRequest> forUser(String userId) => _byId.values
      .where((r) => r.userId == userId)
      .toList(growable: false);

  @override
  PortalDsarRequest? byId(String id) => _byId[id];

  @override
  PortalDsarRequest submit({
    required String userId,
    required String patientId,
    required PortalDsarKind kind,
    String notes = '',
  }) {
    final id = 'dsar-${DateTime.now().microsecondsSinceEpoch}';
    final row = PortalDsarRequest(
      id: id,
      userId: userId,
      patientId: patientId,
      kind: kind,
      notes: notes,
    );
    _byId[id] = row;
    notifyListeners();
    return row;
  }

  @override
  PortalDsarRequest advance({
    required String id,
    required PortalDsarState next,
    String? notes,
  }) {
    final cur = _byId[id];
    if (cur == null) throw StateError('DSAR request $id not found');
    final blocked = cur.transitionBlockedReason(next);
    if (blocked != null) throw StateError(blocked);
    final fulfilledAt = next == PortalDsarState.fulfilled
        ? DateTime.now().toUtc()
        : cur.fulfilledAt;
    final updated = cur.copyWith(
      state: next,
      notes: notes ?? cur.notes,
      fulfilledAt: fulfilledAt,
    );
    _byId[id] = updated;
    notifyListeners();
    return updated;
  }

  /// Visible-for-test only.
  void clearForTesting() {
    _byId.clear();
    notifyListeners();
  }
}
