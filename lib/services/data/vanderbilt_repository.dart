/// Encrypted log of NICHQ Vanderbilt ADHD screening assessments.
/// One row per (patient, respondent, capture timestamp). The
/// clinician usually orders both a parent + a teacher form for the
/// same child so both rows live side-by-side.
///
/// PHI uplift (SecurePrefs ship): scores + symptom counts are
/// clinical data, so the on-disk blob now sits in [SecurePrefs]
/// (Android KeyStore / iOS Keychain) instead of plaintext
/// SharedPreferences. `initialize()` carries forward any pre-upgrade
/// SP list under the same key in a one-shot migration so the
/// existing roster isn't lost.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/vanderbilt_assessment.dart';
import 'secure_prefs.dart';
import 'telemetry_service.dart';

class VanderbiltRepository {
  VanderbiltRepository({String? storageKey, SecurePrefs? prefs})
    : _key = storageKey ?? _storageId,
      _prefs = prefs ?? SecurePrefs.instance;

  /// Storage key for this repo — kept stable so the one-shot SP
  /// migration on init can find any pre-existing list.
  static const _storageId = 'nichq_vanderbilt_v1';
  final String _key;
  final SecurePrefs _prefs;

  final List<VanderbiltAssessment> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final raw = await _prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        _decodeBlob(raw);
      } else {
        await _migrateFromSharedPreferences();
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'vanderbilt_init'),
      );
    }
    _loaded = true;
  }

  Future<void> _migrateFromSharedPreferences() async {
    SharedPreferences sp;
    try {
      sp = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }
    final legacy = sp.getStringList(_key);
    if (legacy == null || legacy.isEmpty) return;
    for (final s in legacy) {
      try {
        _items.add(
          VanderbiltAssessment.fromJson(jsonDecode(s) as Map<String, dynamic>),
        );
      } catch (err, st) {
        unawaited(
          TelemetryService.instance.captureError(
            err,
            st,
            hint: 'vanderbilt_migrate_record',
          ),
        );
      }
    }
    if (_items.isNotEmpty) {
      await _persist();
    }
    try {
      await sp.remove(_key);
    } catch (_) {}
    unawaited(
      TelemetryService.instance.capture(
        'vanderbilt.migrated_to_secure_prefs',
        properties: {'count': _items.length},
      ),
    );
  }

  void _decodeBlob(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final entry in list) {
        try {
          _items.add(
            VanderbiltAssessment.fromJson(entry as Map<String, dynamic>),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'vanderbilt_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'vanderbilt_decode_blob',
        ),
      );
    }
  }

  Future<void> _save() => _persist();

  Future<void> _persist() async {
    try {
      final raw = jsonEncode(
        _items.map((a) => a.toJson()).toList(growable: false),
      );
      await _prefs.setString(_key, raw);
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'vanderbilt_save'),
      );
    }
  }

  List<VanderbiltAssessment> get all => List.unmodifiable(_items);

  List<VanderbiltAssessment> forPatient(
    String patientId, {
    VanderbiltRespondent? respondent,
  }) {
    final list =
        _items
            .where((a) => a.patientId == patientId)
            .where((a) => respondent == null || a.respondent == respondent)
            .toList()
          ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return list;
  }

  /// Most recent parent + teacher pair for the child. Returns
  /// null entries when the corresponding form hasn't been
  /// captured yet — the clinician panel uses this to flag
  /// "teacher form pending" alongside the existing parent score.
  ({VanderbiltAssessment? parent, VanderbiltAssessment? teacher}) latestPair(
    String patientId,
  ) {
    final list = forPatient(patientId);
    VanderbiltAssessment? parent;
    VanderbiltAssessment? teacher;
    for (final a in list.reversed) {
      if (parent == null && a.respondent == VanderbiltRespondent.parent) {
        parent = a;
      }
      if (teacher == null && a.respondent == VanderbiltRespondent.teacher) {
        teacher = a;
      }
      if (parent != null && teacher != null) break;
    }
    return (parent: parent, teacher: teacher);
  }

  Future<VanderbiltAssessment> upsert(VanderbiltAssessment a) async {
    final i = _items.indexWhere((x) => x.id == a.id);
    if (i < 0) {
      _items.add(a);
    } else {
      _items[i] = a;
    }
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'vanderbilt.upsert',
        properties: {
          'respondent': a.respondent.id,
          'subtype': a.subtype.id,
          'inattn': a.inattentionSymptomCount,
          'hyper': a.hyperactivitySymptomCount,
          'odd_pos': a.oppositionalPositiveScreen,
          'conduct_pos': a.conductPositiveScreen,
        },
      ),
    );
    return a;
  }

  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      await _prefs.remove(_key);
    } catch (_) {}
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (_) {}
  }
}
