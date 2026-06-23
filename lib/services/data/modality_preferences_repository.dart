/// Per-clinician modality preferences (enabled set + tier) —
/// SharedPreferences-backed. One record per clinician keyed by
/// `clinicianId`; one device usually holds one clinician so the
/// happy path is "one JSON blob, one read on init".
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/modality_preferences.dart';
import 'telemetry_service.dart';

class ModalityPreferencesRepository {
  ModalityPreferencesRepository({String? storageKey})
    : _key = storageKey ?? _defaultKey;

  static const _defaultKey = 'modality_preferences_v1';
  final String _key;

  final Map<String, ModalityPreferences> _byClinician = {};
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _byClinician.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      for (final s in raw) {
        try {
          final json = jsonDecode(s) as Map<String, dynamic>;
          final p = ModalityPreferences.fromJson(json);
          _byClinician[p.clinicianId] = p;
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'modality_preferences_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'modality_preferences_init',
        ),
      );
    }
    _loaded = true;
  }

  ModalityPreferences forClinician(String clinicianId) =>
      _byClinician[clinicianId] ?? ModalityPreferences.defaults(clinicianId);

  Future<void> save(ModalityPreferences prefs) async {
    _byClinician[prefs.clinicianId] = prefs;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(
        _key,
        _byClinician.values.map((p) => jsonEncode(p.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'modality_preferences_save',
        ),
      );
    }
    unawaited(
      TelemetryService.instance.capture(
        'modality_preferences.saved',
        properties: {
          'enabled_count': prefs.enabled.length,
          'tier': prefs.tier.id,
        },
      ),
    );
  }

  Future<void> debugReset() async {
    _byClinician.clear();
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (_) {}
  }
}
