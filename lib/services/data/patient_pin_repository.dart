/// Per-device pinned patient ids. Clinicians who see a stable 5-10
/// patients each week pin them so the roster reads in the order
/// that matches the calendar, not alphabetical.
///
/// Storage is intentionally per-device + non-PHI: just an opaque
/// id-set. No names, no demographics — the resolver lives in the
/// patient list / detail screens which already hold the
/// authenticated tenant scope.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telemetry_service.dart';

class PatientPinRepository {
  PatientPinRepository({String? storageKey}) : _key = storageKey ?? _storageId;

  /// SharedPreferences key id for this repo — not a credential.
  static const _storageId = 'patient_pins_v1';
  final String _key;

  final ValueNotifier<Set<String>> _pins = ValueNotifier<Set<String>>(
    <String>{},
  );
  bool _loaded = false;

  ValueListenable<Set<String>> get listenable => _pins;

  Set<String> get current => Set<String>.unmodifiable(_pins.value);

  bool isPinned(String patientId) => _pins.value.contains(patientId);

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_key);
      if (raw == null || raw.isEmpty) {
        _pins.value = <String>{};
      } else {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _pins.value = decoded.cast<String>().toSet();
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'patient_pin_init'),
      );
      _pins.value = <String>{};
    }
    _loaded = true;
  }

  Future<void> toggle(String patientId) async {
    final next = Set<String>.of(_pins.value);
    final added = next.add(patientId);
    if (!added) next.remove(patientId);
    _pins.value = next;
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'patient_pin.toggled',
        properties: {'pinned': added, 'count': next.length},
      ),
    );
  }

  Future<void> pin(String patientId) async {
    if (_pins.value.contains(patientId)) return;
    final next = Set<String>.of(_pins.value)..add(patientId);
    _pins.value = next;
    await _save();
  }

  Future<void> unpin(String patientId) async {
    if (!_pins.value.contains(patientId)) return;
    final next = Set<String>.of(_pins.value)..remove(patientId);
    _pins.value = next;
    await _save();
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_key, jsonEncode(_pins.value.toList()));
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'patient_pin_save'),
      );
    }
  }

  @visibleForTesting
  Future<void> debugReset() async {
    _pins.value = <String>{};
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (_) {}
  }
}
