/// Coverage for SystemStatusService — singleton snapshot defaults,
/// overall severity ranking, nonOperational filter, and listenable
/// fan-out to consumers.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/system_status_service.dart';

void main() {
  setUp(SystemStatusService.instance.debugReset);

  test('default snapshot ships every subsystem as operational', () {
    final s = SystemStatusService.instance;
    expect(s.current, hasLength(SystemId.values.length));
    expect(
      s.current.every((x) => x.severity == StatusSeverity.operational),
      isTrue,
    );
    expect(s.overallSeverity, StatusSeverity.operational);
    expect(s.nonOperational, isEmpty);
  });

  test('flipping one subsystem to degraded surfaces it as nonOperational', () {
    final s = SystemStatusService.instance;
    s.setSeverity(
      SystemId.anthropic,
      StatusSeverity.degraded,
      message: 'Latency spike',
    );
    expect(s.nonOperational, hasLength(1));
    expect(s.nonOperational.first.system, SystemId.anthropic);
    expect(s.nonOperational.first.message, 'Latency spike');
    expect(s.overallSeverity, StatusSeverity.degraded);
  });

  test('overallSeverity takes the worst across subsystems', () {
    final s = SystemStatusService.instance;
    s.setSeverity(SystemId.anthropic, StatusSeverity.degraded);
    s.setSeverity(SystemId.stripe, StatusSeverity.down);
    expect(s.overallSeverity, StatusSeverity.down);
  });

  test('debugReset returns to all-operational', () {
    final s = SystemStatusService.instance
      ..setSeverity(SystemId.firestoreEU, StatusSeverity.down);
    s.debugReset();
    expect(s.overallSeverity, StatusSeverity.operational);
    expect(s.nonOperational, isEmpty);
  });

  test('listenable fires when a subsystem changes severity', () {
    final s = SystemStatusService.instance;
    var notifications = 0;
    void listener() => notifications++;
    s.statusListenable.addListener(listener);
    addTearDown(() => s.statusListenable.removeListener(listener));

    s.setSeverity(SystemId.email, StatusSeverity.degraded);
    expect(notifications, greaterThan(0));
  });

  group('severity ranking', () {
    test('down > degraded > operational', () {
      expect(
        StatusSeverity.down.rank,
        greaterThan(StatusSeverity.degraded.rank),
      );
      expect(
        StatusSeverity.degraded.rank,
        greaterThan(StatusSeverity.operational.rank),
      );
    });
  });
}
