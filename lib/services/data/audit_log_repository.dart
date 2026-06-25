/// Append-only, tamper-evident audit log repository.
///
/// HIPAA §164.312(b) requires the covered entity to keep an
/// immutable record of who accessed / modified PHI and when. This
/// repo is the on-device + Firestore-mirrored ledger that backs
/// that requirement.
///
/// Two invariants enforced:
///
/// 1. **Append-only**: there is no `update` or `delete`. `append`
///    is the only mutation entry-point.
/// 2. **Hash chain**: every row's `hash` =
///    `sha256(previous.hash + entry.toJson())`. If anyone edits a
///    past row, the next row's chained hash will fail
///    [verifyChain]. Re-computing the chain after a tamper attempt
///    is impossible without rewriting every subsequent row, which
///    we can detect during nightly audit.
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/audit_log_entry.dart';
import 'telemetry_service.dart';

class AuditLogRepository {
  AuditLogRepository({String? storageBucket})
    : _bucket = storageBucket ?? _storageId;

  /// Process-wide singleton — used by surfaces that fire an audit
  /// event without owning the repo's lifecycle (KVKK consent grant
  /// / revoke from a modal, etc.). Tests can swap it via
  /// [setInstanceForTest] to point at a fresh, isolated repo.
  static AuditLogRepository get instance => _instance ??= AuditLogRepository();
  static AuditLogRepository? _instance;

  /// @visibleForTesting — replaces the singleton. Pass `null` to
  /// drop the cached instance so the next read rebuilds the default.
  ///
  /// **CWE-489 defence**: a malicious code path inside the release
  /// binary could call this to swap the forensic audit ledger for an
  /// attacker-controlled stub, silently swallowing every audit row.
  /// We block the mutation at runtime in release builds so the field
  /// stays a debug / test affordance only.
  @visibleForTesting
  static void setInstanceForTest(AuditLogRepository? value) {
    if (kReleaseMode) {
      throw StateError(
        'AuditLogRepository.setInstanceForTest is disabled in release builds',
      );
    }
    _instance = value;
  }

  /// SharedPreferences bucket id for this repo — not a credential.
  static const _storageId = 'audit_log_v1';
  final String _bucket;

  final List<AuditLogEntry> _items = [];
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
            AuditLogEntry.fromJson(jsonDecode(s) as Map<String, dynamic>),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'audit_log_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'audit_log_init'),
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
        TelemetryService.instance.captureError(e, st, hint: 'audit_log_save'),
      );
    }
  }

  /// Read-only snapshot, newest first.
  List<AuditLogEntry> get all {
    final list = [..._items]
      ..sort((a, b) => b.timestampUtc.compareTo(a.timestampUtc));
    return List.unmodifiable(list);
  }

  /// Filter by acting clinician (actor email/uid). Newest first.
  List<AuditLogEntry> forActor(String actor) =>
      all.where((e) => e.actor == actor).toList();

  /// Filter by kind (signin, phi_read, phi_write, mfa_enrol, etc.).
  List<AuditLogEntry> byKind(String kind) =>
      all.where((e) => e.kind == kind).toList();

  /// Filter by inclusive UTC range, newest first.
  List<AuditLogEntry> inRange(DateTime from, DateTime to) {
    final f = from.toUtc();
    final t = to.toUtc();
    return all.where((e) {
      final ts = e.timestampUtc;
      return !ts.isBefore(f) && !ts.isAfter(t);
    }).toList();
  }

  /// Append a new audit row. The provided entry's `hash` field is
  /// IGNORED — the repo computes the chained hash deterministically
  /// from the previous row + the entry's stable JSON. This
  /// guarantees the chain stays intact even if a caller
  /// accidentally pre-computes a hash.
  Future<AuditLogEntry> append(AuditLogEntry entry) async {
    final previousHash = _items.isEmpty ? '' : (_items.last.hash ?? '');
    final entryWithoutHash = entry.copyWith();
    final chained = previousHash + jsonEncode(entryWithoutHash.toJson());
    final hash = sha256.convert(utf8.encode(chained)).toString();
    final sealed = entry.copyWith(hash: hash);
    _items.add(sealed);
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'audit_log.appended',
        properties: {'kind': sealed.kind, 'result': sealed.result.name},
      ),
    );
    return sealed;
  }

  /// Walk the hash chain and verify every row's `hash` matches the
  /// recomputed value. Returns the first row index that fails, or
  /// `null` when the chain is intact. Used by nightly audit job +
  /// the audit log viewer's "verify integrity" button.
  int? verifyChain() {
    var prevHash = '';
    for (var i = 0; i < _items.length; i++) {
      final row = _items[i];
      final unsealed = row.copyWith();
      final expected = sha256
          .convert(utf8.encode(prevHash + jsonEncode(unsealed.toJson())))
          .toString();
      if (row.hash != expected) return i;
      prevHash = row.hash ?? '';
    }
    return null;
  }

  /// Append-only — explicit failure if someone tries to mutate.
  /// Kept here so a wrong call site fails LOUDLY rather than
  /// silently no-oping.
  Never update(AuditLogEntry _) => throw UnsupportedError(
    'AuditLogRepository is append-only; use append() instead.',
  );

  /// Append-only — see [update].
  Never delete(String _) => throw UnsupportedError(
    'AuditLogRepository is append-only; rows cannot be deleted.',
  );

  /// Used by tests / dev tooling only. Wipes the chain so we start
  /// fresh in a controlled environment.
  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_bucket);
    } catch (_) {}
  }
}

extension _AuditLogEntryCopy on AuditLogEntry {
  AuditLogEntry copyWith({String? hash}) => AuditLogEntry(
    id: id,
    kind: kind,
    action: action,
    actor: actor,
    entity: entity,
    timestampUtc: timestampUtc,
    result: result,
    userId: userId,
    ip: ip,
    device: device,
    hash: hash,
  );
}
