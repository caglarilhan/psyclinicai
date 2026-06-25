/// Forensic audit-chain mirror sink — write-side abstraction.
///
/// **Why a mirror exists** (I4 / B4): the on-device
/// [AuditLogRepository] persists to SharedPreferences only. That
/// satisfies HIPAA §164.312(b) "implement hardware, software, and
/// procedural mechanisms that record and examine activity" on a
/// single device, but it cannot satisfy §164.316(b)(2)(i)'s 6-year
/// retention requirement once you account for app uninstall,
/// device wipe, OS-user switch, or a clinician handing over a new
/// device. The fix is a Firestore mirror per [clinicId] —
/// append-only, server-rules enforced.
///
/// The mirror is a **separate concern** from the device chain:
///   * the device chain remains the source of truth for the
///     clinician's online + offline experience,
///   * mirror writes are best-effort (network may be down) — a
///     failure here MUST NOT block the device append,
///   * each entry carries the same `hash` and `prev_hash` so the
///     server can replay the chain and an out-of-order arrival
///     still verifies cleanly.
///
/// Cloud Function `auditChainVerify` (separate PR) walks the
/// Firestore chain nightly and pages the on-call if any segment
/// fails to recompute. That gives us the "tamper-evident across
/// the fleet" guarantee KVK Kurumu / OCR auditors expect.
library;

import 'package:flutter/foundation.dart';

import '../../models/audit_log_entry.dart';

/// Minimum surface a mirror sink needs to satisfy. Implementations
/// MUST be idempotent (the same `(clinicId, entry.id)` may be
/// written more than once on retry) and MUST NOT throw — failures
/// are surfaced via the [MirrorWriteResult] union so callers can
/// queue replays without exception-handling boilerplate.
abstract class AuditLogMirror {
  /// Submit a sealed [entry] (i.e., the row returned by
  /// `AuditLogRepository.append`, with its [AuditLogEntry.hash] set)
  /// to the upstream mirror under `clinicId`.
  ///
  /// Returns a [MirrorWriteResult] describing whether the write
  /// landed. Implementations MUST swallow their own exceptions and
  /// surface them as [MirrorWriteOutcome.failed] so a network blip
  /// can't break the device append.
  Future<MirrorWriteResult> write({
    required String clinicId,
    required AuditLogEntry entry,
    String prevHash = '',
  });
}

/// Three outcomes the device chain cares about.
enum MirrorWriteOutcome {
  /// Successfully replicated upstream.
  success,

  /// The mirror is intentionally turned off — Firebase not
  /// bootstrapped, no clinic context yet, etc. Not a failure; the
  /// device chain stays the source of truth.
  skipped,

  /// Transient failure (network, permission denied, rate limit).
  /// Caller may queue a replay.
  failed,
}

/// Compact result tuple — outcome + optional error message used
/// for telemetry breadcrumbs. Never carries PHI; the error message
/// is scrubbed by the caller before forwarding to Sentry.
@immutable
class MirrorWriteResult {
  const MirrorWriteResult._(this.outcome, [this.message]);

  /// Successfully landed upstream.
  const MirrorWriteResult.success() : this._(MirrorWriteOutcome.success);

  /// Intentionally skipped — explain *why* via [reason] so telemetry
  /// can distinguish "Firebase off" from "no clinic profile".
  const MirrorWriteResult.skipped(String reason)
    : this._(MirrorWriteOutcome.skipped, reason);

  /// Transient failure — [error] is the upstream exception message
  /// (scrub before sending to Sentry).
  const MirrorWriteResult.failed(String error)
    : this._(MirrorWriteOutcome.failed, error);

  final MirrorWriteOutcome outcome;

  /// Free-form context — present on `skipped` (reason) and `failed`
  /// (error). `null` on `success`.
  final String? message;

  bool get isSuccess => outcome == MirrorWriteOutcome.success;
  bool get isSkipped => outcome == MirrorWriteOutcome.skipped;
  bool get isFailed => outcome == MirrorWriteOutcome.failed;
}

/// Null implementation — what the device chain falls back to when
/// no real mirror has been wired. Useful as a default so call
/// sites don't have to null-check the field.
class NoopAuditLogMirror implements AuditLogMirror {
  const NoopAuditLogMirror();

  @override
  Future<MirrorWriteResult> write({
    required String clinicId,
    required AuditLogEntry entry,
    String prevHash = '',
  }) async => const MirrorWriteResult.skipped('mirror_not_configured');
}
