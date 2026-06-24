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
  RiskSignalRepository({String? storageBucket})
    : _bucket = storageBucket ?? _storageId;

  /// SharedPreferences bucket id for this repo — not a credential.
  static const _storageId = 'risk_signals_v1';
  final String _bucket;

  final List<PersistedRiskSignal> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getStringList(_bucket) ?? [];
      for (final s in raw) {
        try {
          _items.add(
            PersistedRiskSignal.fromJson(jsonDecode(s) as Map<String, dynamic>),
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
        TelemetryService.instance.captureError(e, st, hint: 'risk_signal_init'),
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

  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_bucket);
    } catch (_) {}
  }
}
