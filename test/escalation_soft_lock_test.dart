import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/escalation_soft_lock.dart';

void main() {
  setUp(() {
    EscalationSoftLock.instance.clearForTesting();
  });

  EscalationSoftLockEntry entry({
    String patientId = 'p1',
    String tier = 'imminent',
    String severity = 'critical',
    String reason = 'family_present',
    DateTime? dismissedAt,
  }) => EscalationSoftLockEntry(
    patientId: patientId,
    patientName: 'Test Patient',
    severity: severity,
    tier: tier,
    reason: reason,
    dismissedAt: dismissedAt ?? DateTime.utc(2026, 6, 1, 12),
  );

  group('EscalationSoftLockEntry.isActiveAt', () {
    test('true within the 24-hour follow-up window', () {
      final e = entry(dismissedAt: DateTime.utc(2026, 6, 1, 12));
      expect(e.isActiveAt(DateTime.utc(2026, 6, 1, 18)), isTrue);
    });

    test('false the moment the 24-hour window closes', () {
      final e = entry(dismissedAt: DateTime.utc(2026, 6, 1, 12));
      expect(e.isActiveAt(DateTime.utc(2026, 6, 2, 12)), isFalse);
    });

    test('false long after the window closes', () {
      final e = entry(dismissedAt: DateTime.utc(2026, 6, 1, 12));
      expect(e.isActiveAt(DateTime.utc(2026, 6, 10)), isFalse);
    });
  });

  group('EscalationSoftLock.record + isLocked', () {
    test('starts empty', () {
      expect(EscalationSoftLock.instance.entries, isEmpty);
      expect(EscalationSoftLock.instance.isLocked('p1'), isFalse);
    });

    test('record adds the entry and notifies', () {
      var notified = 0;
      void listener() => notified++;
      EscalationSoftLock.instance.addListener(listener);
      addTearDown(() => EscalationSoftLock.instance.removeListener(listener));

      EscalationSoftLock.instance.record(entry());
      expect(EscalationSoftLock.instance.entries, hasLength(1));
      expect(notified, 1);
    });

    test('isLocked is true within the 24-hour window', () {
      final now = DateTime.utc(2026, 6, 1, 12);
      EscalationSoftLock.instance.record(entry(dismissedAt: now));
      expect(
        EscalationSoftLock.instance.isLocked(
          'p1',
          now: now.add(const Duration(hours: 6)),
        ),
        isTrue,
      );
    });

    test('isLocked is false after the window closes', () {
      final now = DateTime.utc(2026, 6, 1, 12);
      EscalationSoftLock.instance.record(entry(dismissedAt: now));
      expect(
        EscalationSoftLock.instance.isLocked(
          'p1',
          now: now.add(const Duration(hours: 25)),
        ),
        isFalse,
      );
    });

    test('isLocked scopes to the right patient', () {
      EscalationSoftLock.instance.record(entry(patientId: 'p1'));
      expect(EscalationSoftLock.instance.isLocked('p2'), isFalse);
    });

    test('activeAt only returns rows still inside the window', () {
      final now = DateTime.utc(2026, 6, 1, 12);
      EscalationSoftLock.instance.record(
        entry(
          patientId: 'recent',
          dismissedAt: now.subtract(const Duration(hours: 4)),
        ),
      );
      EscalationSoftLock.instance.record(
        entry(
          patientId: 'stale',
          dismissedAt: now.subtract(const Duration(days: 2)),
        ),
      );
      final active = EscalationSoftLock.instance.activeAt(now);
      expect(active, hasLength(1));
      expect(active.single.patientId, 'recent');
    });

    test('clearForTesting wipes every entry', () {
      EscalationSoftLock.instance.record(entry());
      EscalationSoftLock.instance.clearForTesting();
      expect(EscalationSoftLock.instance.entries, isEmpty);
    });
  });
}
