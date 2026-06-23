/// SharedPreferences-backed log of medication doses (MAR — the
/// "Medication Administration Record" in psychiatry parlance).
///
/// One row per scheduled dose; updates flip the status as the
/// patient takes / skips / misses it. Per-record resilience on
/// load (a single corrupt entry never wipes the list).
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/medication_dose_log.dart';
import 'telemetry_service.dart';

class MedicationDoseRepository {
  MedicationDoseRepository({String? storageKey})
    : _key = storageKey ?? _defaultKey;

  static const _defaultKey = 'medication_dose_log_v1';
  final String _key;

  final List<MedicationDoseLog> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      for (final s in raw) {
        try {
          _items.add(
            MedicationDoseLog.fromJson(jsonDecode(s) as Map<String, dynamic>),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'medication_dose_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'medication_dose_init',
        ),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(
        _key,
        _items.map((d) => jsonEncode(d.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'medication_dose_save',
        ),
      );
    }
  }

  List<MedicationDoseLog> get all => List.unmodifiable(_items);

  /// All doses scheduled for a patient on a calendar day (UTC).
  /// Sorted by `scheduledAt`.
  List<MedicationDoseLog> forPatientOnDate(String patientId, DateTime day) {
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    final nextUtc = dayUtc.add(const Duration(days: 1));
    return _items
        .where(
          (d) =>
              d.patientId == patientId &&
              !d.scheduledAt.isBefore(dayUtc) &&
              d.scheduledAt.isBefore(nextUtc),
        )
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// All doses across a span. Newest-first.
  List<MedicationDoseLog> forPatientInRange(
    String patientId,
    DateTime start,
    DateTime end,
  ) {
    final from = start.toUtc();
    final to = end.toUtc();
    return _items
        .where(
          (d) =>
              d.patientId == patientId &&
              !d.scheduledAt.isBefore(from) &&
              !d.scheduledAt.isAfter(to),
        )
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  /// Upsert by id (replace or append). Used when the patient
  /// marks a dose taken/missed/skipped or attaches a side-effect.
  Future<MedicationDoseLog> upsert(MedicationDoseLog dose) async {
    final i = _items.indexWhere((d) => d.id == dose.id);
    if (i < 0) {
      _items.add(dose);
    } else {
      _items[i] = dose;
    }
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'medication_dose.upsert',
        properties: {
          'status': dose.status.id,
          'side_effects': dose.sideEffects.length,
        },
      ),
    );
    return dose;
  }

  /// Bulk seed — used by the clinician when first writing a
  /// regimen ("3 doses a day for 90 days" expands into 270 logs).
  /// Not destructive: existing logs with matching ids are
  /// preserved.
  Future<int> seed(List<MedicationDoseLog> doses) async {
    final knownIds = _items.map((d) => d.id).toSet();
    var added = 0;
    for (final d in doses) {
      if (knownIds.contains(d.id)) continue;
      _items.add(d);
      added++;
    }
    if (added > 0) await _save();
    return added;
  }

  Future<void> remove(String id) async {
    _items.removeWhere((d) => d.id == id);
    await _save();
  }

  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (_) {}
  }
}
