/// L4 — pins the AI-decision audit ledger contract.
///
/// The downstream consumers of these rows are:
///   * the Cloud Function chain verifier (J2) — must recompute
///     hashes byte-for-byte,
///   * the QMS auditor portal (future) — must filter by `kind:
///     ai_decision`,
///   * the FDA Clinical Decision Support evidence pack — must
///     prove every AI run was logged.
///
/// Renaming any of: `kind`, `action` prefix, `entity` segment
/// order, or swapping SHA-256 for a faster hash would break one
/// of those consumers. Pin them all.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/services/ai/ai_decision_logger.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPatient = 'pat-1';
const _kInput = 'Patient context: 32 y/o female, GAD-7 = 14';
const _kOutput = 'Suggested goals: 1) Reduce avoidance ...';

String _sha(String s) => sha256.convert(utf8.encode(s)).toString();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AuditLogRepository.setInstanceForTest(null);
  });

  tearDown(() {
    AuditLogRepository.setInstanceForTest(null);
  });

  group('buildAiDecisionAuditEntryForTesting', () {
    test('kind is the pinned ai_decision string', () {
      final e = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
      );
      expect(e.kind, aiDecisionAuditKind);
      expect(e.kind, 'ai_decision');
    });

    test('action is ai.decision.<service> — service id rides along', () {
      final e = buildAiDecisionAuditEntryForTesting(
        service: 'treatment_plan_goals',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
      );
      expect(e.action, 'ai.decision.treatment_plan_goals');
    });

    test('entity carries service/model/sha/blocked/hits/override in order', () {
      final ts = DateTime.utc(2026, 6, 26, 10);
      final e = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
        nowUtc: ts,
      );
      final expectedInputSha = _sha(_kInput);
      final expectedOutputSha = _sha(_kOutput);
      expect(
        e.entity,
        'service:safety_plan '
        'model:claude-haiku-4-5 '
        'input_sha:$expectedInputSha '
        'output_sha:$expectedOutputSha '
        'blocked:false '
        'hits:- '
        'override:-',
      );
    });

    test('blocked: true flips result to failure', () {
      final e = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: '',
        blocked: true,
      );
      expect(e.result, AuditResult.failure);
      expect(e.entity, contains('blocked:true'));
    });

    test('hits render as comma-separated set of category names', () {
      final e = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: '',
        blocked: true,
        hitCategoryNames: const ['suicideMethods', 'drugOverdose'],
      );
      expect(e.entity, contains('hits:suicideMethods,drugOverdose'));
    });

    test('overrideByClinician toggles override segment', () {
      final accepted = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
        overrideByClinician: false,
      );
      expect(accepted.entity, contains('override:false'));

      final overridden = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
        overrideByClinician: true,
      );
      expect(overridden.entity, contains('override:true'));

      final unknown = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
      );
      expect(unknown.entity, contains('override:-'));
    });

    test('raw input / output text never appears in the entity', () {
      final e = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
      );
      // PHI containment — only hashes leave the helper.
      expect(e.entity, isNot(contains('GAD-7')));
      expect(e.entity, isNot(contains('Reduce avoidance')));
    });

    test('SHA-256 is deterministic across calls', () {
      final a = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
      );
      final b = buildAiDecisionAuditEntryForTesting(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
        nowUtc: DateTime.utc(2030, 1, 1),
      );
      // Different ids (timestamp drives id), same entity hashes.
      final aSha = a.entity.split('input_sha:').last.split(' ').first;
      final bSha = b.entity.split('input_sha:').last.split(' ').first;
      expect(aSha, bSha);
      expect(aSha.length, 64);
    });
  });

  group('recordAiDecision — round-trip', () {
    test('appends a sealed entry to the singleton + returns hashes', () async {
      final bucket = 'ai_decision_${DateTime.now().microsecondsSinceEpoch}';
      AuditLogRepository.setInstanceForTest(
        AuditLogRepository(storageBucket: bucket),
      );

      final result = await recordAiDecision(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
      );

      expect(result.inputSha256, _sha(_kInput));
      expect(result.outputSha256, _sha(_kOutput));
      expect(result.entryId, startsWith('audit-ai-safety_plan-'));

      final repo = AuditLogRepository.instance;
      final rows = repo.all.where((e) => e.kind == 'ai_decision').toList();
      expect(rows, hasLength(1));
      expect(rows.first.id, result.entryId);
      expect(rows.first.actor, _kPatient);
      expect(rows.first.hash, isNotNull);
    });

    test('an unreachable repo does NOT throw — fail-soft contract', () async {
      final repo = _AlwaysThrowingRepo();
      final result = await recordAiDecision(
        service: 'safety_plan',
        modelId: 'claude-haiku-4-5',
        patientId: _kPatient,
        inputText: _kInput,
        outputText: _kOutput,
        blocked: false,
        repository: repo,
      );
      // Hashes still come back so telemetry can correlate.
      expect(result.inputSha256, _sha(_kInput));
      expect(result.outputSha256, _sha(_kOutput));
    });
  });
}

class _AlwaysThrowingRepo extends AuditLogRepository {
  _AlwaysThrowingRepo()
    : super(
        storageBucket: 'always_throw_${DateTime.now().microsecondsSinceEpoch}',
      );

  @override
  Future<AuditLogEntry> append(AuditLogEntry entry) async {
    throw StateError('forced audit failure for contract test');
  }
}
