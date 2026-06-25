/// Real Firestore-backed adapter for [ConsentEntryRepository].
///
/// Pairs with the `consent_entries` collection rules shipped in
/// PR #94. The class subscribes to a clinic-scoped snapshot
/// listener and exposes the same synchronous read API as
/// [InMemoryConsentEntryRepository] (callers don't switch between
/// sync + async at the UI layer).
///
/// **Write semantics — optimistic**. `record` / `revoke` update the
/// local cache immediately, notify listeners, then fire the Firestore
/// write asynchronously. Failures are reported to [TelemetryService]
/// so a regression is visible in the dashboards; we never silently
/// drop a write. The snapshot listener re-broadcasts whatever
/// Firestore confirms, so a failed optimistic write reverts on the
/// next snapshot tick.
///
/// **Persistence schema** mirrors `lib/models/consent_entry.dart`
/// (id / patientId / kind / policyVersion / signature / signedAt
/// ISO 8601) + adds `clinic_id` for the tenancy guard the rules
/// enforce.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/consent_entry.dart';
import 'consent_entry_repository.dart';
import 'telemetry_service.dart';

class FirestoreConsentEntryRepository extends ConsentEntryRepository {
  FirestoreConsentEntryRepository({
    required this.clinicId,
    CollectionReference<Map<String, dynamic>>? collection,
  }) : _collection =
           collection ??
           FirebaseFirestore.instance.collection(_collectionName) {
    _subscription = _collection
        .where('clinic_id', isEqualTo: clinicId)
        .snapshots()
        .listen(
          _onSnapshot,
          onError: (Object e, StackTrace st) {
            unawaited(
              TelemetryService.instance.captureError(
                e,
                st,
                hint: 'consent_entries.snapshot',
              ),
            );
          },
        );
  }

  static const String _collectionName = 'consent_entries';

  /// Tenant that scopes every read + write. Must match the caller's
  /// Firebase Auth uid (per the firestore.rules guard).
  final String clinicId;

  final CollectionReference<Map<String, dynamic>> _collection;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
  _subscription;

  final Map<String, ConsentEntry> _cache = <String, ConsentEntry>{};

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    _cache.clear();
    for (final doc in snap.docs) {
      try {
        _cache[doc.id] = ConsentEntry.fromJson(doc.data());
      } catch (e, st) {
        unawaited(
          TelemetryService.instance.captureError(
            e,
            st,
            hint: 'consent_entries.decode',
          ),
        );
      }
    }
    notifyListeners();
  }

  @override
  List<ConsentEntry> forPatient(String patientId) => _cache.values
      .where((e) => e.patientId == patientId)
      .toList(growable: false);

  @override
  ConsentEntry? activeOf(String patientId, ConsentKind kind) {
    for (final e in _cache.values) {
      if (e.patientId == patientId && e.kind == kind && e.isActive) {
        return e;
      }
    }
    return null;
  }

  @override
  ConsentEntry record(ConsentEntry entry) {
    // App-level supersede so the UI flips to the new active row
    // before the Firestore listener echo arrives. The wire shape
    // also writes the supersede; see [_writeRecord].
    final existing = activeOf(entry.patientId, entry.kind);
    if (existing != null) {
      _cache[existing.id] = existing.revoke();
    }
    _cache[entry.id] = entry;
    notifyListeners();
    unawaited(_writeRecord(entry, existing));
    return entry;
  }

  Future<void> _writeRecord(ConsentEntry entry, ConsentEntry? existing) async {
    try {
      final payload = <String, Object?>{
        ...entry.toJson(),
        'clinic_id': clinicId,
      };
      await _collection.doc(entry.id).set(payload);
      if (existing != null) {
        await _collection.doc(existing.id).update({
          'revokedAt': DateTime.now().toUtc().toIso8601String(),
        });
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'consent_entries.write',
        ),
      );
    }
  }

  @override
  ConsentEntry revoke(String entryId) {
    final cur = _cache[entryId];
    if (cur == null) {
      throw StateError('ConsentEntry $entryId not found');
    }
    final updated = cur.revoke();
    _cache[entryId] = updated;
    notifyListeners();
    unawaited(_writeRevoke(entryId, updated));
    return updated;
  }

  Future<void> _writeRevoke(String entryId, ConsentEntry updated) async {
    try {
      await _collection.doc(entryId).update({
        'revokedAt': updated.revokedAt?.toIso8601String(),
      });
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'consent_entries.revoke',
        ),
      );
    }
  }

  /// Production teardown — cancels the snapshot listener so a
  /// repository swap mid-session doesn't leak subscriptions.
  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
