/// Offline repository for modality-specific session artefacts —
/// CBT thought records, DBT diary cards, EMDR session trackers.
///
/// Storage strategy mirrors [`HomeworkRepository`] /
/// [`AssessmentRepository`]: SharedPreferences-backed string list,
/// per-record resilience (a single corrupt entry never wipes the
/// list), telemetry on load/save errors.
///
/// One repository, three modalities — the envelope tags each record
/// with its `type` so the loader can pick the correct
/// `fromJson` factory. Saved as a single key so the cross-modality
/// caseload view ("everything for this patient") is one read.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/modalities/cbt_thought_record.dart';
import '../../models/modalities/dbt_diary_card.dart';
import '../../models/modalities/emdr_session_tracker.dart';
import '../../models/modalities/family_session_note.dart';
import 'telemetry_service.dart';

enum ModalityKind {
  cbt('cbt'),
  dbt('dbt'),
  emdr('emdr'),
  family('family');

  const ModalityKind(this.id);
  final String id;

  static ModalityKind? fromId(String id) {
    for (final k in values) {
      if (k.id == id) return k;
    }
    return null;
  }
}

/// Tagged envelope for the JSON list. Keeps the modality type out
/// of the inner models so each one can be swapped/extended
/// independently.
class ModalityRecord {
  const ModalityRecord({required this.kind, required this.payload});

  factory ModalityRecord.fromJson(Map<String, dynamic> json) {
    final kind = ModalityKind.fromId(json['type'] as String? ?? '');
    if (kind == null) {
      throw StateError('Unknown modality type: ${json['type']}');
    }
    final raw = json['payload'];
    if (raw is! Map) {
      throw StateError('Modality payload is not a map');
    }
    final payload = Map<String, dynamic>.from(raw);
    final inner = switch (kind) {
      ModalityKind.cbt => CbtThoughtRecord.fromJson(payload),
      ModalityKind.dbt => DbtDiaryCard.fromJson(payload),
      ModalityKind.emdr => EmdrSessionTracker.fromJson(payload),
      ModalityKind.family => FamilySessionNote.fromJson(payload),
    };
    return ModalityRecord(kind: kind, payload: inner);
  }

  final ModalityKind kind;

  /// Strongly-typed inner record — exactly one of
  /// [CbtThoughtRecord] / [DbtDiaryCard] / [EmdrSessionTracker].
  final Object payload;

  String get patientId => switch (payload) {
    final CbtThoughtRecord r => r.patientId,
    final DbtDiaryCard r => r.patientId,
    final EmdrSessionTracker r => r.patientId,
    final FamilySessionNote r => r.patientId,
    _ => '',
  };

  String get id => switch (payload) {
    final CbtThoughtRecord r => r.id,
    final DbtDiaryCard r => r.id,
    final EmdrSessionTracker r => r.id,
    final FamilySessionNote r => r.id,
    _ => '',
  };

  /// Closest sort key — primary date for the record.
  DateTime get sortDate => switch (payload) {
    final CbtThoughtRecord r => r.recordedAt,
    final DbtDiaryCard r => r.weekStart,
    final EmdrSessionTracker r => r.updatedAt ?? r.createdAt,
    final FamilySessionNote r => r.sessionDate,
    _ => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  };

  CbtThoughtRecord? get cbtRecord =>
      payload is CbtThoughtRecord ? payload as CbtThoughtRecord : null;
  DbtDiaryCard? get dbtCard =>
      payload is DbtDiaryCard ? payload as DbtDiaryCard : null;
  EmdrSessionTracker? get emdrSession =>
      payload is EmdrSessionTracker ? payload as EmdrSessionTracker : null;
  FamilySessionNote? get familySessionNote =>
      payload is FamilySessionNote ? payload as FamilySessionNote : null;

  Map<String, dynamic> toJson() => {
    'type': kind.id,
    'payload': switch (payload) {
      final CbtThoughtRecord r => r.toJson(),
      final DbtDiaryCard r => r.toJson(),
      final EmdrSessionTracker r => r.toJson(),
      final FamilySessionNote r => r.toJson(),
      _ => <String, dynamic>{},
    },
  };
}

class ModalitySessionRepository {
  ModalitySessionRepository({String? storageKey})
    : _key = storageKey ?? _defaultKey;

  static const _defaultKey = 'modality_sessions';
  final String _key;

  final List<ModalityRecord> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      var dropped = 0;
      for (final s in raw) {
        try {
          _items.add(
            ModalityRecord.fromJson(jsonDecode(s) as Map<String, dynamic>),
          );
        } catch (err, st) {
          dropped++;
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'modality_session_decode_record',
            ),
          );
        }
      }
      if (dropped > 0) {
        unawaited(
          TelemetryService.instance.captureError(
            StateError(
              'Dropped $dropped corrupt modality session record(s) on load',
            ),
            StackTrace.current,
            hint: 'modality_session_init',
          ),
        );
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'modality_session_init',
        ),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        _items.map((r) => jsonEncode(r.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'modality_session_save',
        ),
      );
    }
  }

  List<ModalityRecord> get all => List.unmodifiable(_items);

  /// All records for a patient, sorted newest-first.
  List<ModalityRecord> forPatient(String patientId) {
    final list = _items.where((r) => r.patientId == patientId).toList()
      ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return list;
  }

  /// All records for a patient of a specific modality, sorted
  /// newest-first.
  List<ModalityRecord> forPatientOfKind(String patientId, ModalityKind kind) =>
      forPatient(patientId).where((r) => r.kind == kind).toList();

  ModalityRecord? byId(String id) {
    for (final r in _items) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Upsert — replaces by id if present, otherwise appends. Returns
  /// the merged record so the caller can rebind state.
  Future<ModalityRecord> upsert(ModalityRecord record) async {
    final i = _items.indexWhere((r) => r.id == record.id);
    if (i < 0) {
      _items.add(record);
    } else {
      _items[i] = record;
    }
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'modality_session.upsert',
        properties: {'kind': record.kind.id},
      ),
    );
    return record;
  }

  Future<void> remove(String id) async {
    _items.removeWhere((r) => r.id == id);
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'modality_session.removed',
        properties: {'id_redacted_hash': id.hashCode},
      ),
    );
  }

  /// Test/debug seam — wipes the in-memory list and the persistent
  /// store. Only used by widget tests so they start clean.
  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {
      // best-effort
    }
  }
}
