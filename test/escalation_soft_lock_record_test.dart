import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/escalation_soft_lock_record.dart';

EscalationSoftLockRecord _row({
  DateTime? dismissedAt,
  DateTime? followUpDueAt,
  bool stale = false,
  String? supervisorHandoffId,
}) {
  final d = dismissedAt ?? DateTime.utc(2026, 6, 2, 12);
  return EscalationSoftLockRecord(
    id: 'lock-1',
    clinicId: 'c1',
    patientId: 'p1',
    dismissingClinicianId: 'doc-1',
    severity: 'severe',
    tier: 'imminent',
    dismissReasonCode: 'dismissReasonSupervisorHandoff',
    dismissedAt: d,
    followUpDueAt:
        followUpDueAt ?? EscalationSoftLockRecord.dueAtFromDismissal(d),
    supervisorHandoffId: supervisorHandoffId,
    stale: stale,
  );
}

void main() {
  group('EscalationSoftLockRecord', () {
    test('dueAtFromDismissal adds the 24h follow-up window in UTC', () {
      final dismissed = DateTime.utc(2026, 6, 2, 10);
      final due = EscalationSoftLockRecord.dueAtFromDismissal(dismissed);
      expect(
        due.difference(dismissed),
        EscalationSoftLockRecord.followUpWindow,
      );
      expect(due.isUtc, isTrue);
    });

    test('isActiveAt is true inside the 24h window', () {
      final r = _row(dismissedAt: DateTime.utc(2026, 6, 2, 12));
      expect(r.isActiveAt(DateTime.utc(2026, 6, 2, 18)), isTrue);
    });

    test('isActiveAt flips to false after the window closes', () {
      final r = _row(dismissedAt: DateTime.utc(2026, 6, 1));
      expect(r.isActiveAt(DateTime.utc(2026, 6, 3)), isFalse);
    });

    test('a stale row is never active', () {
      final r = _row(stale: true);
      expect(r.isActiveAt(DateTime.utc(2026, 6, 2, 13)), isFalse);
    });

    test('JSON round-trip preserves every field, including stale', () {
      final r = _row(stale: true, supervisorHandoffId: 'rev-42');
      final round = EscalationSoftLockRecord.fromJson(r.toJson());
      expect(round.id, r.id);
      expect(round.clinicId, r.clinicId);
      expect(round.patientId, r.patientId);
      expect(round.dismissingClinicianId, r.dismissingClinicianId);
      expect(round.severity, r.severity);
      expect(round.tier, r.tier);
      expect(round.dismissReasonCode, r.dismissReasonCode);
      expect(round.dismissedAt, r.dismissedAt);
      expect(round.followUpDueAt, r.followUpDueAt);
      expect(round.supervisorHandoffId, 'rev-42');
      expect(round.stale, isTrue);
    });

    test('copyWith only mutates the supplied fields', () {
      final r = _row();
      final h = r.copyWith(supervisorHandoffId: 'rev-7');
      expect(h.supervisorHandoffId, 'rev-7');
      expect(h.patientId, r.patientId);
      expect(h.dismissedAt, r.dismissedAt);
      expect(h.stale, isFalse);
    });
  });
}
