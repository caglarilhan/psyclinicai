/// SharedPreferences-backed log of medication side effect
/// reports. One row per event. The MAR Side-effect button hands
/// the patient a chip rail of common SEs (per drug class) and
/// drops one row here per submission. Resolution is the same row
/// re-saved with `resolvedAt`.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/medication_side_effect.dart';
import 'telemetry_service.dart';

class MedicationSideEffectRepository {
  MedicationSideEffectRepository({String? storageBucket})
    : _bucket = storageBucket ?? _storageId;

  // SharedPreferences bucket id for this repo — not a credential.
  static const _storageId = 'med_se_v1';
  final String _bucket;

  final List<MedicationSideEffect> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_bucket) ?? [];
      for (final s in raw) {
        try {
          _items.add(
            MedicationSideEffect.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'med_se_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'med_se_init'),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(
        _bucket,
        _items.map((e) => jsonEncode(e.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'med_se_save'),
      );
    }
  }

  List<MedicationSideEffect> get all => List.unmodifiable(_items);

  /// All SE events for this patient, newest first.
  List<MedicationSideEffect> forPatient(String patientId) {
    final list = _items.where((e) => e.patientId == patientId).toList()
      ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return list;
  }

  /// All SE events tied to a specific medication on a patient's
  /// regimen — used by the MAR sheet to show "previously reported
  /// for this drug" inline with the new-event form.
  List<MedicationSideEffect> forMedication(
    String patientId,
    String medicationId,
  ) {
    final list =
        _items
            .where(
              (e) => e.patientId == patientId && e.medicationId == medicationId,
            )
            .toList()
          ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return list;
  }

  /// Patient header roll-up — convenient call site for the
  /// outcomes dashboard's tolerability tile.
  SideEffectSummary summaryForPatient(String patientId) =>
      SideEffectSummary.compute(forPatient(patientId));

  Future<MedicationSideEffect> upsert(MedicationSideEffect e) async {
    final i = _items.indexWhere((x) => x.id == e.id);
    if (i < 0) {
      _items.add(e);
    } else {
      _items[i] = e;
    }
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'med_se.upsert',
        properties: {
          'system': e.system.id,
          'severity': e.severity.value,
          'ongoing': e.isOngoing,
          'significant': e.isClinicallySignificant,
          'has_naranjo': e.naranjoScore != null,
        },
      ),
    );
    return e;
  }

  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_bucket);
    } catch (_) {}
  }
}
