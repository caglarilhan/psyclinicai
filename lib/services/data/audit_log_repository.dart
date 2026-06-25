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
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/audit_log_entry.dart';
import 'audit_log_mirror.dart';
import 'telemetry_service.dart';

class AuditLogRepository {
  AuditLogRepository({
    String? storageBucket,
    AuditLogMirror? mirror,
    String? Function()? clinicIdReader,
  }) : _bucket = storageBucket ?? _storageId,
       _mirror = mirror ?? const NoopAuditLogMirror(),
       _clinicIdReader = clinicIdReader ?? _noClinic;

  static String? _noClinic() => null;

  /// Process-wide singleton — used by surfaces that fire an audit
  /// event without owning the repo's lifecycle (KVKK consent grant
  /// / revoke from a modal, etc.). Tests can swap it via
  /// [setInstanceForTest] to point at a fresh, isolated repo.
  static AuditLogRepository get instance => _instance ??= AuditLogRepository();
  static AuditLogRepository? _instance;

  /// @visibleForTesting — replaces the singleton. Pass `null` to
  /// drop the cached instance so the next read rebuilds the default.
  static void setInstanceForTest(AuditLogRepository? value) {
    _instance = value;
  }

  /// Production bootstrap — installs a singleton wired with the
  /// supplied [mirror] and [clinicIdReader]. Call once at app
  /// startup AFTER Firebase + auth are bootstrapped so the next
  /// `AuditLogRepository.instance` read returns the production-
  /// configured ledger. Re-calling rebuilds the singleton; the
  /// device chain itself is reloaded lazily via [initialize].
  static void bootstrap({
    required AuditLogMirror mirror,
    required String? Function() clinicIdReader,
  }) {
    _instance = AuditLogRepository(
      mirror: mirror,
      clinicIdReader: clinicIdReader,
    );
  }

  /// SharedPreferences bucket id for this repo — not a credential.
  static const _storageId = 'audit_log_v1';
  final String _bucket;

  /// Forensic mirror sink. Default is a no-op so the device chain
  /// works in demo / offline modes without Firebase. Production
  /// bootstrap wires a [FirestoreAuditLogMirror].
  final AuditLogMirror _mirror;

  /// Closure returning the active clinicId — defers reading
  /// `FirebaseAuthService.profile?.clinicId` to call time so a
  /// sign-in / sign-out after construction is reflected on the next
  /// append. The mirror is skipped when this returns null.
  final String? Function() _clinicIdReader;

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
    // Best-effort forensic mirror — failure here MUST NOT break the
    // device append. The Noop default for legacy callers makes this
    // a no-op until production wires a real Firestore mirror.
    unawaited(_mirrorBestEffort(sealed, previousHash));
    return sealed;
  }

  Future<void> _mirrorBestEffort(
    AuditLogEntry sealed,
    String previousHash,
  ) async {
    final clinicId = _clinicIdSafe();
    if (clinicId == null) {
      unawaited(
        TelemetryService.instance.capture(
          'audit_log.mirror_skipped',
          properties: {'reason': 'no_clinic_context'},
        ),
      );
      return;
    }
    try {
      final result = await _mirror.write(
        clinicId: clinicId,
        entry: sealed,
        prevHash: previousHash,
      );
      unawaited(
        TelemetryService.instance.capture(
          'audit_log.mirror_${result.outcome.name}',
          properties: {
            'kind': sealed.kind,
            // Result message may carry an upstream error; PhiRedactor
            // inside captureError scrubs PHI, but here this is a
            // breadcrumb-only path so we drop the free-form text
            // entirely. Outcome enum + kind is enough for SIEM.
          },
        ),
      );
    } catch (e, st) {
      // Defense in depth — the contract says mirrors don't throw, but
      // a buggy adapter could still bubble. Caught + reported.
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'audit_log.mirror_threw',
        ),
      );
    }
  }

  String? _clinicIdSafe() {
    try {
      return _clinicIdReader();
    } catch (_) {
      return null;
    }
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
