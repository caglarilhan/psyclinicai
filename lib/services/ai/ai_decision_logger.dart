/// L4 — Per-AI-call audit ledger row.
///
/// **Why this exists**: ISO 13485 §7.5.6 + FDA Clinical Decision
/// Support Guidance (Sep 2022) both demand that a Software-as-
/// Medical-Device sponsor can answer, for any AI-touched clinical
/// artifact: "what input was given, what came back, which model
/// version produced it, did the clinician override the AI's
/// suggestion?" Today our `AuditLogRepository` carries consent +
/// auth + PHI-read rows but **no AI-call ledger**. This helper
/// closes that gap with a single function call per AI completion.
///
/// **PHI containment**: the helper hashes the input + output
/// strings with SHA-256 before they leave the call. The audit
/// row never carries the raw prompt or the raw response — only
/// the opaque 64-char digests + scalars (model id, service id,
/// blocked flag, hit categories, optional override flag). An
/// auditor who walks the chain can prove the AI ran for this
/// patient at this time WITHOUT being able to reconstruct the
/// clinical content.
///
/// **Replay strategy**: the device-side `AuditLogRepository`
/// chains every row; the J1 Firestore mirror replicates the
/// chain. When a regulator wants to audit a specific decision,
/// the on-call retrieves the in-clinic prompt + response cache
/// (separate, encrypted, 6-year retention) and recomputes the
/// hashes — match → row is the original AI call; mismatch → the
/// cache was tampered with OR the audit row was forged.
///
/// **Roadmap** (separate PRs):
///   * L4.x — SafetyPlanAi + TreatmentPlanAi wires call
///     [recordAiDecision] right after the safety gate (L1.x).
///   * L4.y — clinician "override" UI that records the decision
///     was edited / discarded post-AI surfacing.
///   * L4.z — chain-verify Cloud Function (J2) extended to
///     verify per-AI rows.
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../models/audit_log_entry.dart';
import '../data/audit_log_repository.dart';

/// The audit `kind` every AI-decision row carries. Pinned so the
/// SIEM correlation rule + a future filter on the audit viewer
/// don't drift from the writer.
const String aiDecisionAuditKind = 'ai_decision';

/// Pinned `action` prefix — service id appended (e.g.
/// `ai.decision.safety_plan`, `ai.decision.treatment_plan_goals`).
const String aiDecisionActionPrefix = 'ai.decision';

/// Pure result returned by [recordAiDecision] so the caller can
/// telemetry-correlate the audit row without re-hashing.
@immutable
class AiDecisionAuditResult {
  const AiDecisionAuditResult({
    required this.entryId,
    required this.inputSha256,
    required this.outputSha256,
  });

  /// `id` field of the appended [AuditLogEntry] — surfaces in
  /// the chain hash so the Cloud Function verifier can pin it.
  final String entryId;

  /// Hex SHA-256 of the input bytes the AI saw.
  final String inputSha256;

  /// Hex SHA-256 of the model's response bytes (`outputText`
  /// passed in — empty when the gate blocked before parse).
  final String outputSha256;
}

/// Single entry-point an AI service calls. Returns the sealed
/// row's id + hashes so the caller can correlate telemetry. Never
/// throws on audit-write failure — the AI call already succeeded
/// from the clinician's view, the audit gap surfaces via
/// `TelemetryService.captureError(hint: 'audit_log_save')` inside
/// [AuditLogRepository].
Future<AiDecisionAuditResult> recordAiDecision({
  required String service,
  required String modelId,
  required String patientId,
  required String inputText,
  required String outputText,
  required bool blocked,
  Iterable<String> hitCategoryNames = const [],
  bool? overrideByClinician,
  AuditLogRepository? repository,
  DateTime? nowUtc,
}) async {
  final repo = repository ?? AuditLogRepository.instance;
  final ts = (nowUtc ?? DateTime.now()).toUtc();
  final inputSha = _sha256Hex(inputText);
  final outputSha = _sha256Hex(outputText);
  final entry = _buildEntry(
    service: service,
    modelId: modelId,
    patientId: patientId,
    inputSha: inputSha,
    outputSha: outputSha,
    blocked: blocked,
    hitCategoryNames: hitCategoryNames,
    overrideByClinician: overrideByClinician,
    ts: ts,
  );
  try {
    await repo.initialize();
    await repo.append(entry);
  } catch (_) {
    // Audit-append already routes failures through TelemetryService
    // inside the repository; we deliberately do not double-report
    // here, but we also never let the AI surface crash on a
    // bookkeeping miss.
  }
  return AiDecisionAuditResult(
    entryId: entry.id,
    inputSha256: inputSha,
    outputSha256: outputSha,
  );
}

/// Builds the audit entry without writing — exposed for tests
/// that want to assert the entity string verbatim without booting
/// SharedPreferences.
@visibleForTesting
AuditLogEntry buildAiDecisionAuditEntryForTesting({
  required String service,
  required String modelId,
  required String patientId,
  required String inputText,
  required String outputText,
  required bool blocked,
  Iterable<String> hitCategoryNames = const [],
  bool? overrideByClinician,
  DateTime? nowUtc,
}) {
  return _buildEntry(
    service: service,
    modelId: modelId,
    patientId: patientId,
    inputSha: _sha256Hex(inputText),
    outputSha: _sha256Hex(outputText),
    blocked: blocked,
    hitCategoryNames: hitCategoryNames,
    overrideByClinician: overrideByClinician,
    ts: (nowUtc ?? DateTime.now()).toUtc(),
  );
}

String _sha256Hex(String text) => sha256.convert(utf8.encode(text)).toString();

AuditLogEntry _buildEntry({
  required String service,
  required String modelId,
  required String patientId,
  required String inputSha,
  required String outputSha,
  required bool blocked,
  required Iterable<String> hitCategoryNames,
  required bool? overrideByClinician,
  required DateTime ts,
}) {
  final hitNames = hitCategoryNames.toSet();
  final hitCsv = hitNames.isEmpty ? '-' : hitNames.join(',');
  final overrideStr = overrideByClinician == null
      ? '-'
      : (overrideByClinician ? 'true' : 'false');
  return AuditLogEntry(
    id: 'audit-ai-$service-${ts.microsecondsSinceEpoch}',
    kind: aiDecisionAuditKind,
    action: '$aiDecisionActionPrefix.$service',
    actor: patientId,
    entity:
        'service:$service '
        'model:$modelId '
        'input_sha:$inputSha '
        'output_sha:$outputSha '
        'blocked:$blocked '
        'hits:$hitCsv '
        'override:$overrideStr',
    timestampUtc: ts,
    result: blocked ? AuditResult.failure : AuditResult.success,
  );
}
