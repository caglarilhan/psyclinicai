import 'package:flutter/foundation.dart';

import '../../models/consent_entry.dart';

/// Per-category consent store. Sprint 15 ships the in-memory adapter
/// so the Consent Center UI is testable end-to-end; a Firestore
/// adapter joins it once the `consent_entries` collection has its
/// own immutable rule set.
abstract class ConsentEntryRepository extends ChangeNotifier {
  List<ConsentEntry> forPatient(String patientId);
  ConsentEntry? activeOf(String patientId, ConsentKind kind);
  ConsentEntry record(ConsentEntry entry);
  ConsentEntry revoke(String entryId);
}

class InMemoryConsentEntryRepository extends ConsentEntryRepository {
  InMemoryConsentEntryRepository._();
  static final InMemoryConsentEntryRepository instance =
      InMemoryConsentEntryRepository._();

  final Map<String, ConsentEntry> _byId = {};

  @override
  List<ConsentEntry> forPatient(String patientId) => _byId.values
      .where((e) => e.patientId == patientId)
      .toList(growable: false);

  @override
  ConsentEntry? activeOf(String patientId, ConsentKind kind) {
    for (final e in _byId.values) {
      if (e.patientId == patientId && e.kind == kind && e.isActive) {
        return e;
      }
    }
    return null;
  }

  @override
  ConsentEntry record(ConsentEntry entry) {
    // A new active row of the same kind supersedes (revokes) the
    // previous one. Old row stays on disk for the audit trail.
    final existing = activeOf(entry.patientId, entry.kind);
    if (existing != null) {
      _byId[existing.id] = existing.revoke();
    }
    _byId[entry.id] = entry;
    notifyListeners();
    return entry;
  }

  @override
  ConsentEntry revoke(String entryId) {
    final cur = _byId[entryId];
    if (cur == null) {
      throw StateError('ConsentEntry $entryId not found');
    }
    final updated = cur.revoke();
    _byId[entryId] = updated;
    notifyListeners();
    return updated;
  }

  /// Visible-for-test only — wipes the in-memory state.
  void clearForTesting() {
    _byId.clear();
    notifyListeners();
  }
}
