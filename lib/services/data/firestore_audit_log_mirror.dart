/// Concrete [AuditLogMirror] writing to
/// `clinic_audit_logs/{clinicId}/entries/{rowId}`.
///
/// **Idempotency** — the doc id is the entry's [AuditLogEntry.id].
/// Calling `write` with the same entry twice writes the same doc
/// twice with `set(merge: false)`; the chained hash is identical
/// so the chain stays consistent. This is on purpose: the device
/// chain owns ordering, the mirror is a replicated tape.
///
/// **Best-effort** — every Firestore call is wrapped in try/catch
/// and surfaces failure via [MirrorWriteResult.failed]. The
/// contract `AuditLogMirror.write` MUST NOT throw is preserved.
///
/// **Field schema** — flattens [AuditLogEntry] to a snake_case map
/// matching the schema enforced in `firestore.rules`:
///   * `clinic_id` (string, must equal `request.auth.uid`)
///   * `id`, `kind`, `action`, `actor`, `entity`, `result`
///   * `timestamp_utc` (ISO 8601 string, NOT Firestore Timestamp —
///     the chain-verify Cloud Function recomputes hashes from
///     the exact bytes the device used to seal the row)
///   * `hash` (64-char SHA-256 hex)
///   * `prev_hash` (string, may be empty for the chain head)
///   * `device_id` / `user_id` / `ip` — optional, omitted if null
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/audit_log_entry.dart';
import 'audit_log_mirror.dart';

class FirestoreAuditLogMirror implements AuditLogMirror {
  FirestoreAuditLogMirror({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Top-level collection name — kept as a constant so the rules
  /// path and the client path drift together.
  static const String collectionId = 'clinic_audit_logs';

  /// Subcollection name under each clinic doc.
  static const String entriesSubcollection = 'entries';

  CollectionReference<Map<String, dynamic>> _entriesRef(String clinicId) => _db
      .collection(collectionId)
      .doc(clinicId)
      .collection(entriesSubcollection);

  @override
  Future<MirrorWriteResult> write({
    required String clinicId,
    required AuditLogEntry entry,
    String prevHash = '',
  }) async {
    if (clinicId.isEmpty) {
      return const MirrorWriteResult.skipped('empty_clinic_id');
    }
    final hash = entry.hash;
    if (hash == null || hash.isEmpty) {
      return const MirrorWriteResult.skipped('unsealed_entry');
    }
    try {
      final payload = _toPayload(entry, clinicId: clinicId, prevHash: prevHash);
      await _entriesRef(clinicId).doc(entry.id).set(payload);
      return const MirrorWriteResult.success();
    } on FirebaseException catch (e) {
      // Network blip, permission denied, rate-limit → retryable.
      return MirrorWriteResult.failed('firebase:${e.code}:${e.message ?? ''}');
    } catch (e) {
      // Defense in depth — any other throw also turns into `failed`
      // so the contract "mirror MUST NOT throw" is preserved.
      return MirrorWriteResult.failed(e.toString());
    }
  }

  /// Builds the snake_case map exactly matching the schema enforced
  /// in `firestore.rules`. Optional fields are omitted (not nulled)
  /// to keep the doc compact and the rule predicates simple.
  Map<String, dynamic> _toPayload(
    AuditLogEntry entry, {
    required String clinicId,
    required String prevHash,
  }) {
    final map = <String, dynamic>{
      'clinic_id': clinicId,
      'id': entry.id,
      'kind': entry.kind,
      'action': entry.action,
      'actor': entry.actor,
      'entity': entry.entity,
      'timestamp_utc': entry.timestampUtc.toUtc().toIso8601String(),
      'result': entry.result.name,
      'hash': entry.hash,
      'prev_hash': prevHash,
    };
    if (entry.userId != null) map['user_id'] = entry.userId;
    if (entry.ip != null) map['ip'] = entry.ip;
    if (entry.device != null) map['device_id'] = entry.device;
    return map;
  }
}
