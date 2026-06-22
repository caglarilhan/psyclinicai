import 'package:flutter/foundation.dart';

import '../../models/insurance_preauth.dart';

/// In-memory pre-authorisation store. Sprint 7 keeps the screen
/// testable; Sprint 8 lands a Firestore-backed implementation with
/// payer webhooks updating the status.
class PreAuthRepository extends ChangeNotifier {
  PreAuthRepository._();
  static final PreAuthRepository instance = PreAuthRepository._();

  final List<InsurancePreAuth> _entries = [];

  /// Read-only view of every record. Caller may sort.
  List<InsurancePreAuth> get all => List.unmodifiable(_entries);

  /// All requests for the given patient, newest-first.
  List<InsurancePreAuth> forPatient(String patientId) {
    final filtered = _entries
        .where((e) => e.patientId == patientId)
        .toList(growable: false);
    final sorted = [...filtered];
    sorted.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return sorted;
  }

  /// Currently-approved request for the patient, if any (the one a
  /// superbill should reference). Returns null when no usable approval
  /// exists at [now].
  InsurancePreAuth? activeAuthFor(String patientId, {DateTime? now}) {
    final stamp = now ?? DateTime.now();
    for (final e in forPatient(patientId)) {
      if (e.isUsableAt(stamp)) return e;
    }
    return null;
  }

  void add(InsurancePreAuth entry) {
    _entries.add(entry);
    notifyListeners();
  }

  /// Replace the row with the same id; useful for the payer webhook
  /// path once Sprint 8 wires it.
  void upsert(InsurancePreAuth entry) {
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i >= 0) {
      _entries[i] = entry;
    } else {
      _entries.add(entry);
    }
    notifyListeners();
  }

  void clearForTesting() {
    _entries.clear();
    notifyListeners();
  }
}
