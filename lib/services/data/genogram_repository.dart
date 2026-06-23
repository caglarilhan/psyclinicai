/// SharedPreferences-backed store for genograms — one per
/// patient. The visual canvas (separate sprint) reads from this
/// repo; today the repo + model are the data backbone for
/// capturing the structure.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/genogram.dart';
import 'telemetry_service.dart';

class GenogramRepository {
  GenogramRepository({String? storageKey}) : _key = storageKey ?? _defaultKey;

  static const _defaultKey = 'genograms_v1';
  final String _key;

  final Map<String, Genogram> _byPatient = {};
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _byPatient.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      for (final s in raw) {
        try {
          final g = Genogram.fromJson(jsonDecode(s) as Map<String, dynamic>);
          _byPatient[g.patientId] = g;
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'genogram_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'genogram_init'),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(
        _key,
        _byPatient.values.map((g) => jsonEncode(g.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'genogram_save'),
      );
    }
  }

  Genogram? forPatient(String patientId) => _byPatient[patientId];

  Future<Genogram> upsert(Genogram g) async {
    final next = g.copyWith(updatedAt: DateTime.now().toUtc());
    _byPatient[g.patientId] = next;
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'genogram.upsert',
        properties: {
          'people': next.people.length,
          'relationships': next.relationships.length,
        },
      ),
    );
    return next;
  }

  Future<void> remove(String patientId) async {
    _byPatient.remove(patientId);
    await _save();
  }

  Future<void> debugReset() async {
    _byPatient.clear();
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (_) {}
  }
}
