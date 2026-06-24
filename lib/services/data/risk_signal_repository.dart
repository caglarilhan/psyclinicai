/// Persistent ledger for [RiskSignal]s surfaced during sessions —
/// the foundation for the upcoming "risk coverage" leadership
/// panel ("are signals being acknowledged?") and the audit log
/// review.
///
/// Today the LiveAiPanel only holds signals in-memory and drops
/// them when the panel disposes. This repo gives them a per-tenant
/// lifetime + an `acknowledged` flag so we can answer:
///   - which sessions surfaced signals
///   - which signals were acknowledged (and by whom / when)
///   - per-category aggregate (suicidal ideation, self-harm, etc.)
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../copilot/risk_signal_service.dart';
import 'secure_prefs.dart';
import 'telemetry_service.dart';

class PersistedRiskSignal {
  PersistedRiskSignal({
    required this.id,
    required this.sessionId,
    required this.category,
    required this.severity,
    required this.matchedText,
    required this.snippet,
    required this.source,
    required this.at,
    this.patientId,
    this.acknowledged = false,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  factory PersistedRiskSignal.fromJson(Map<String, dynamic> json) {
    return PersistedRiskSignal(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      patientId: json['patient_id'] as String?,
      category: RiskCategory.values.byName(json['category'] as String),
      severity: RiskSeverity.values.byName(json['severity'] as String),
      matchedText: json['matched_text'] as String,
      snippet: json['snippet'] as String,
      source: RiskSource.values.byName(json['source'] as String),
      at: DateTime.parse(json['at'] as String),
      acknowledged: json['acknowledged'] as bool? ?? false,
      acknowledgedAt: json['acknowledged_at'] == null
          ? null
          : DateTime.parse(json['acknowledged_at'] as String),
      acknowledgedBy: json['acknowledged_by'] as String?,
    );
  }

  final String id;
  final String sessionId;
  final String? patientId;
  final RiskCategory category;
  final RiskSeverity severity;
  final String matchedText;
  final String snippet;
  final RiskSource source;
  final DateTime at;
  final bool acknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'session_id': sessionId,
    if (patientId != null) 'patient_id': patientId,
    'category': category.name,
    'severity': severity.name,
    'matched_text': matchedText,
    'snippet': snippet,
    'source': source.name,
    'at': at.toUtc().toIso8601String(),
    'acknowledged': acknowledged,
    if (acknowledgedAt != null)
      'acknowledged_at': acknowledgedAt!.toUtc().toIso8601String(),
    if (acknowledgedBy != null) 'acknowledged_by': acknowledgedBy,
  };

  PersistedRiskSignal copyWith({
    bool? acknowledged,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
  }) => PersistedRiskSignal(
    id: id,
    sessionId: sessionId,
    patientId: patientId,
    category: category,
    severity: severity,
    matchedText: matchedText,
    snippet: snippet,
    source: source,
    at: at,
    acknowledged: acknowledged ?? this.acknowledged,
    acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
  );
}

class RiskSignalRepository {
  RiskSignalRepository({String? storageBucket, SecurePrefs? prefs})
    : _bucket = storageBucket ?? _storageId,
      _prefs = prefs ?? SecurePrefs.instance;

  /// Storage key id for this repo — not a credential. Kept stable so
  /// the one-shot SP→SecurePrefs migration on init can locate any
  /// existing data under the same name.
  static const _storageId = 'risk_signals_v1';
  final String _bucket;
  final SecurePrefs _prefs;

  final List<PersistedRiskSignal> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final raw = await _prefs.getString(_bucket);
      if (raw != null && raw.isNotEmpty) {
        _decodeInto(raw);
      } else {
        await _migrateFromSharedPreferences();
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'risk_signal_init'),
      );
    }
    _loaded = true;
  }

  /// PHI uplift (PR after SecurePrefs ship): risk signals used to sit
  /// in plain SharedPreferences as a `getStringList`. On the first
  /// launch with this code, copy any pre-existing list into
  /// SecurePrefs and clear the SP entry so the data never gets left
  /// in plaintext on disk.
  Future<void> _migrateFromSharedPreferences() async {
    SharedPreferences sp;
    try {
      sp = await SharedPreferences.getInstance();
    } catch (_) {
      // No SharedPreferences available (web cold start, certain test
      // contexts) — nothing to migrate.
      return;
    }
    final legacy = sp.getStringList(_bucket);
    if (legacy == null || legacy.isEmpty) return;
    for (final s in legacy) {
      try {
        _items.add(
          PersistedRiskSignal.fromJson(jsonDecode(s) as Map<String, dynamic>),
        );
      } catch (err, st) {
        unawaited(
          TelemetryService.instance.captureError(
            err,
            st,
            hint: 'risk_signal_migrate_record',
          ),
        );
      }
    }
    if (_items.isNotEmpty) {
      await _persist();
    }
    try {
      await sp.remove(_bucket);
    } catch (_) {}
    unawaited(
      TelemetryService.instance.capture(
        'risk_signal.migrated_to_secure_prefs',
        properties: {'count': _items.length},
      ),
    );
  }

  void _decodeInto(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final entry in list) {
        try {
          _items.add(
            PersistedRiskSignal.fromJson(entry as Map<String, dynamic>),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'risk_signal_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'risk_signal_decode_blob',
        ),
      );
    }
  }

  Future<void> _save() => _persist();

  Future<void> _persist() async {
    try {
      final raw = jsonEncode(
        _items.map((e) => e.toJson()).toList(growable: false),
      );
      await _prefs.setString(_bucket, raw);
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'risk_signal_save'),
      );
    }
  }

  /// Read-only snapshot, newest first.
  List<PersistedRiskSignal> get all {
    final list = [..._items]..sort((a, b) => b.at.compareTo(a.at));
    return List.unmodifiable(list);
  }

  List<PersistedRiskSignal> forSession(String sessionId) =>
      all.where((s) => s.sessionId == sessionId).toList();

  List<PersistedRiskSignal> forPatient(String patientId) =>
      all.where((s) => s.patientId == patientId).toList();

  Future<PersistedRiskSignal> save(PersistedRiskSignal signal) async {
    final existingIdx = _items.indexWhere((e) => e.id == signal.id);
    if (existingIdx >= 0) {
      _items[existingIdx] = signal;
    } else {
      _items.add(signal);
      unawaited(
        TelemetryService.instance.capture(
          'risk_signal.persisted',
          properties: {
            'category': signal.category.name,
            'severity': signal.severity.name,
            'source': signal.source.name,
          },
        ),
      );
    }
    await _save();
    return signal;
  }

  /// Mark a signal acknowledged. The row is replaced in place and
  /// the change is telemetered without any PHI / matched-text
  /// content.
  Future<PersistedRiskSignal?> acknowledge(
    String id, {
    required String actor,
    DateTime? at,
  }) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return null;
    final updated = _items[idx].copyWith(
      acknowledged: true,
      acknowledgedAt: (at ?? DateTime.now()).toUtc(),
      acknowledgedBy: actor,
    );
    _items[idx] = updated;
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'risk_signal.acknowledged',
        properties: {
          'category': updated.category.name,
          'severity': updated.severity.name,
        },
      ),
    );
    return updated;
  }

  /// Acknowledge several rows at once. Unknown ids are skipped
  /// silently (so a stale UI snapshot never throws). Returns the
  /// rows actually mutated, in their post-update form. Writes the
  /// whole snapshot once at the end + fires a single
  /// `risk_signal.acknowledged_bulk` telemetry hint with the count —
  /// no per-row noise, no PHI.
  Future<List<PersistedRiskSignal>> acknowledgeAll(
    Iterable<String> ids, {
    required String actor,
    DateTime? at,
  }) async {
    final stamp = (at ?? DateTime.now()).toUtc();
    final updated = <PersistedRiskSignal>[];
    for (final id in ids) {
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx < 0) continue;
      if (_items[idx].acknowledged) continue;
      final next = _items[idx].copyWith(
        acknowledged: true,
        acknowledgedAt: stamp,
        acknowledgedBy: actor,
      );
      _items[idx] = next;
      updated.add(next);
    }
    if (updated.isEmpty) return updated;
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'risk_signal.acknowledged_bulk',
        properties: {'count': updated.length},
      ),
    );
    return updated;
  }

  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      await _prefs.remove(_bucket);
    } catch (_) {}
    // Clear any leftover SP entry from a pre-migration build.
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_bucket);
    } catch (_) {}
  }
}
