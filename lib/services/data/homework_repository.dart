import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/homework_item.dart';
import 'secure_prefs.dart';
import 'telemetry_service.dart';

/// Encrypted homework store. Keyed list of [HomeworkItem]; filter by
/// patient in the UI.
///
/// PHI uplift (SecurePrefs ship): homework prompts can quote
/// clinician-authored coping skills, exposure ladders and other
/// session-context fragments, so the on-disk blob now lives in
/// [SecurePrefs] (Android KeyStore / iOS Keychain) instead of
/// plaintext SharedPreferences. `initialize()` carries forward any
/// pre-upgrade SP list under the same key in a one-shot migration so
/// previously-saved homework isn't orphaned.
class HomeworkRepository {
  HomeworkRepository({SecurePrefs? prefs, String? storageKey})
    : _prefs = prefs ?? SecurePrefs.instance,
      _key = storageKey ?? _storageId;

  /// Storage key for this repo — kept stable so the one-shot SP
  /// migration on init can locate any pre-existing list.
  static const _storageId = 'homework_items';
  final String _key;
  final SecurePrefs _prefs;

  final List<HomeworkItem> _items = [];
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
        TelemetryService.instance.captureError(e, st, hint: 'homework_init'),
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
          HomeworkItem.fromJson(jsonDecode(s) as Map<String, dynamic>),
        );
      } catch (err, st) {
        unawaited(
          TelemetryService.instance.captureError(
            err,
            st,
            hint: 'homework_migrate_record',
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
        'homework.migrated_to_secure_prefs',
        properties: {'count': _items.length},
      ),
    );
  }

  void _decodeBlob(String raw) {
    var dropped = 0;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final entry in list) {
        try {
          _items.add(HomeworkItem.fromJson(entry as Map<String, dynamic>));
        } catch (err, st) {
          dropped++;
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'homework_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'homework_decode_blob',
        ),
      );
    }
    if (dropped > 0) {
      unawaited(
        TelemetryService.instance.captureError(
          StateError('Dropped $dropped corrupt homework record(s) on load'),
          StackTrace.current,
          hint: 'homework_init',
        ),
      );
    }
  }

  Future<void> _save() => _persist();

  Future<void> _persist() async {
    try {
      final raw = jsonEncode(
        _items.map((i) => i.toJson()).toList(growable: false),
      );
      await _prefs.setString(_key, raw);
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'homework_save'),
      );
    }
  }

  /// All items across patients (read-only) — for caseload aggregation.
  List<HomeworkItem> get all => List.unmodifiable(_items);

  List<HomeworkItem> forPatient(String patientId) {
    final list = _items.where((i) => i.patientId == patientId).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  Future<void> add(HomeworkItem item) async {
    _items.add(item);
    await _save();
  }

  Future<void> toggleDone(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(done: !_items[i].done);
    await _save();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _save();
  }
}
