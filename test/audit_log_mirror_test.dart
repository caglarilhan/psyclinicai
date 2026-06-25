/// I4 — pins the AuditLogRepository ↔ AuditLogMirror contract.
///
/// The mirror replicates the device hash chain to a per-clinic
/// Firestore collection so HIPAA §164.316(b)(2)(i)'s 6-year
/// retention survives device wipes / app uninstalls / clinician
/// handovers. The contract these tests pin:
///
///   * `append()` always succeeds locally — a mirror failure
///     MUST NOT break the device chain.
///   * Mirror gets the sealed entry (hash field populated by the
///     repo, NOT the caller).
///   * When no clinicId is configured, mirror is skipped — the
///     device chain is the only writer in demo / pre-auth mode.
///   * The Noop default mirror reports `skipped` so callers can
///     branch on outcome telemetry without null checks.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/services/data/audit_log_mirror.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CaptureMirror implements AuditLogMirror {
  final List<({String clinicId, AuditLogEntry entry, String prevHash})> writes =
      [];
  MirrorWriteResult Function()? respond;

  @override
  Future<MirrorWriteResult> write({
    required String clinicId,
    required AuditLogEntry entry,
    String prevHash = '',
  }) async {
    writes.add((clinicId: clinicId, entry: entry, prevHash: prevHash));
    return respond?.call() ?? const MirrorWriteResult.success();
  }
}

class _ThrowingMirror implements AuditLogMirror {
  @override
  Future<MirrorWriteResult> write({
    required String clinicId,
    required AuditLogEntry entry,
    String prevHash = '',
  }) async => throw StateError('mirror should not propagate');
}

var _entrySeq = 0;
AuditLogEntry _entry(String id) {
  // Monotonic timestamps so `all` (newest-first sort) is deterministic
  // across multi-append tests.
  _entrySeq += 1;
  return AuditLogEntry(
    id: id,
    kind: 'consent',
    action: 'kvkk.consent_granted',
    actor: 'pat-1',
    entity: 'patient:pat-1 entry:ce-$id policy:2026-06',
    timestampUtc: DateTime.utc(
      2026,
      6,
      25,
      12,
    ).add(Duration(seconds: _entrySeq)),
    result: AuditResult.success,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'mirror is invoked with clinicId + sealed entry containing hash',
    () async {
      final mirror = _CaptureMirror();
      final repo = AuditLogRepository(
        storageBucket: 'audit_mirror_${DateTime.now().microsecondsSinceEpoch}',
        mirror: mirror,
        clinicIdReader: () => 'clinic-x',
      );
      await repo.initialize();

      final sealed = await repo.append(_entry('e1'));
      await Future<void>.delayed(Duration.zero);

      expect(mirror.writes, hasLength(1));
      expect(mirror.writes.single.clinicId, 'clinic-x');
      expect(mirror.writes.single.entry.id, 'e1');
      expect(
        mirror.writes.single.entry.hash,
        isNotNull,
        reason:
            'Mirror must receive the SEALED entry — chained hash '
            'already computed by the repo.',
      );
      expect(mirror.writes.single.entry.hash, sealed.hash);
    },
  );

  test('null clinicId → mirror is skipped (demo / pre-auth path)', () async {
    final mirror = _CaptureMirror();
    final repo = AuditLogRepository(
      storageBucket:
          'audit_mirror_skip_${DateTime.now().microsecondsSinceEpoch}',
      mirror: mirror,
      clinicIdReader: () => null,
    );
    await repo.initialize();

    await repo.append(_entry('e1'));
    await Future<void>.delayed(Duration.zero);

    expect(
      mirror.writes,
      isEmpty,
      reason:
          'No clinic context = no mirror call. The device chain is '
          'the sole writer in demo mode.',
    );
  });

  test(
    'mirror failure does NOT break the device append (best-effort)',
    () async {
      final mirror = _CaptureMirror()
        ..respond = (() => const MirrorWriteResult.failed('network_down'));
      final repo = AuditLogRepository(
        storageBucket:
            'audit_mirror_fail_${DateTime.now().microsecondsSinceEpoch}',
        mirror: mirror,
        clinicIdReader: () => 'clinic-x',
      );
      await repo.initialize();

      final sealed = await repo.append(_entry('e1'));
      await Future<void>.delayed(Duration.zero);

      expect(repo.all, hasLength(1));
      expect(repo.all.single.id, 'e1');
      expect(sealed.hash, isNotNull);
      expect(repo.verifyChain(), isNull);
      expect(mirror.writes, hasLength(1));
    },
  );

  test('a throwing mirror is caught — device chain stays intact', () async {
    final repo = AuditLogRepository(
      storageBucket:
          'audit_mirror_throw_${DateTime.now().microsecondsSinceEpoch}',
      mirror: _ThrowingMirror(),
      clinicIdReader: () => 'clinic-x',
    );
    await repo.initialize();

    final sealed = await repo.append(_entry('e1'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repo.all, hasLength(1));
    expect(sealed.hash, isNotNull);
    expect(
      repo.verifyChain(),
      isNull,
      reason: 'Mirror exception must not corrupt the device chain.',
    );
  });

  test(
    'NoopAuditLogMirror reports skipped — telemetry can distinguish',
    () async {
      const mirror = NoopAuditLogMirror();
      final result = await mirror.write(
        clinicId: 'clinic-x',
        entry: _entry('e1'),
      );
      expect(result.outcome, MirrorWriteOutcome.skipped);
      expect(result.message, 'mirror_not_configured');
      expect(result.isSkipped, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isFailed, isFalse);
    },
  );

  test(
    'multiple appends keep the chain intact even with mirror responses',
    () async {
      final mirror = _CaptureMirror();
      final repo = AuditLogRepository(
        storageBucket:
            'audit_mirror_chain_${DateTime.now().microsecondsSinceEpoch}',
        mirror: mirror,
        clinicIdReader: () => 'clinic-x',
      );
      await repo.initialize();

      await repo.append(_entry('e1'));
      await repo.append(_entry('e2'));
      await repo.append(_entry('e3'));
      await Future<void>.delayed(Duration.zero);

      expect(repo.verifyChain(), isNull);
      expect(mirror.writes.map((w) => w.entry.id), ['e1', 'e2', 'e3']);
      // Each upstream hash must match what the repo sealed (chain
      // entries are oldest→newest in `_items`; `all` reverses to
      // newest-first).
      final newestFirst = repo.all.toList();
      final oldestFirst = newestFirst.reversed.toList();
      for (var i = 0; i < mirror.writes.length; i++) {
        expect(mirror.writes[i].entry.hash, oldestFirst[i].hash);
      }
    },
  );
}
