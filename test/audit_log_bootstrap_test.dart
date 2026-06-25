/// J3 — pins the AuditLogRepository.bootstrap contract.
///
/// Production wires the singleton with FirestoreAuditLogMirror +
/// clinic-id reader; this test verifies that bootstrap actually
/// REPLACES the singleton and that subsequent reads return the
/// production-configured instance (not the default Noop).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/services/data/audit_log_mirror.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingMirror implements AuditLogMirror {
  final List<({String clinicId, AuditLogEntry entry, String prevHash})> writes =
      [];

  @override
  Future<MirrorWriteResult> write({
    required String clinicId,
    required AuditLogEntry entry,
    String prevHash = '',
  }) async {
    writes.add((clinicId: clinicId, entry: entry, prevHash: prevHash));
    return const MirrorWriteResult.success();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AuditLogRepository.setInstanceForTest(null);
  });

  tearDown(() {
    AuditLogRepository.setInstanceForTest(null);
  });

  test('bootstrap installs a production-wired singleton', () async {
    final mirror = _RecordingMirror();
    AuditLogRepository.bootstrap(
      mirror: mirror,
      clinicIdReader: () => 'clinic-prod',
    );

    final repo = AuditLogRepository.instance;
    await repo.initialize();
    await repo.append(
      AuditLogEntry(
        id: 'audit-boot-1',
        kind: 'consent',
        action: 'kvkk.consent_granted',
        actor: 'pat-1',
        entity: 'patient:pat-1 entry:ce-1 policy:2026-06',
        timestampUtc: DateTime.utc(2026, 6, 25, 12),
        result: AuditResult.success,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      mirror.writes,
      hasLength(1),
      reason: 'bootstrap singleton must route appends through the wired mirror',
    );
    expect(mirror.writes.single.clinicId, 'clinic-prod');
  });

  test('re-bootstrap replaces the singleton', () async {
    final mirrorA = _RecordingMirror();
    AuditLogRepository.bootstrap(
      mirror: mirrorA,
      clinicIdReader: () => 'clinic-a',
    );
    final firstInstance = AuditLogRepository.instance;

    final mirrorB = _RecordingMirror();
    AuditLogRepository.bootstrap(
      mirror: mirrorB,
      clinicIdReader: () => 'clinic-b',
    );
    final secondInstance = AuditLogRepository.instance;

    expect(
      identical(firstInstance, secondInstance),
      isFalse,
      reason: 're-bootstrap must rebuild the singleton',
    );
  });

  test('clinicIdReader is read at each append, not at bootstrap', () async {
    final mirror = _RecordingMirror();
    String? currentClinic = 'clinic-initial';
    AuditLogRepository.bootstrap(
      mirror: mirror,
      clinicIdReader: () => currentClinic,
    );

    final repo = AuditLogRepository.instance;
    await repo.initialize();

    await repo.append(
      AuditLogEntry(
        id: 'audit-c1',
        kind: 'consent',
        action: 'kvkk.consent_granted',
        actor: 'pat-1',
        entity: 'patient:pat-1 entry:ce-1 policy:2026-06',
        timestampUtc: DateTime.utc(2026, 6, 25, 12),
        result: AuditResult.success,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    currentClinic = 'clinic-after-switch';
    await repo.append(
      AuditLogEntry(
        id: 'audit-c2',
        kind: 'consent',
        action: 'kvkk.consent_granted',
        actor: 'pat-1',
        entity: 'patient:pat-1 entry:ce-2 policy:2026-06',
        timestampUtc: DateTime.utc(2026, 6, 25, 12, 0, 1),
        result: AuditResult.success,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(mirror.writes, hasLength(2));
    expect(mirror.writes[0].clinicId, 'clinic-initial');
    expect(
      mirror.writes[1].clinicId,
      'clinic-after-switch',
      reason: 'A sign-in switch mid-session must surface on the next append',
    );
  });
}
