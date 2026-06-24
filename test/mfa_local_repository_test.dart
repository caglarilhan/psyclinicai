/// Coverage for MfaLocalRepository — fresh device, round-trip,
/// idempotent clear, listenable fan-out.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/mfa_local_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fresh device reports not acknowledged', () async {
    final repo = MfaLocalRepository(storageKey: 'mfa_test_fresh');
    await repo.initialize();
    expect(repo.isAcknowledged, isFalse);
    expect(repo.acknowledgedAt, isNull);
  });

  test('markAcknowledged stamps a UTC timestamp', () async {
    final repo = MfaLocalRepository(storageKey: 'mfa_test_mark');
    await repo.initialize();
    final at = DateTime.utc(2026, 6, 24, 14, 30);
    await repo.markAcknowledged(at: at);
    expect(repo.isAcknowledged, isTrue);
    expect(repo.acknowledgedAt, at);
  });

  test('round-trip across repo instances', () async {
    final first = MfaLocalRepository(storageKey: 'mfa_test_persist');
    await first.initialize();
    await first.markAcknowledged(at: DateTime.utc(2026, 6, 24, 14));

    final fresh = MfaLocalRepository(storageKey: 'mfa_test_persist');
    await fresh.initialize();
    expect(fresh.isAcknowledged, isTrue);
    expect(fresh.acknowledgedAt, DateTime.utc(2026, 6, 24, 14));
  });

  test('markCleared resets the flag', () async {
    final repo = MfaLocalRepository(storageKey: 'mfa_test_clear');
    await repo.initialize();
    await repo.markAcknowledged();
    expect(repo.isAcknowledged, isTrue);
    await repo.markCleared();
    expect(repo.isAcknowledged, isFalse);
  });

  test('markCleared is idempotent when never acknowledged', () async {
    final repo = MfaLocalRepository(storageKey: 'mfa_test_clear_idem');
    await repo.initialize();
    await repo.markCleared();
    expect(repo.isAcknowledged, isFalse);
  });

  test('listenable fires when state changes', () async {
    final repo = MfaLocalRepository(storageKey: 'mfa_test_listen');
    await repo.initialize();
    var fires = 0;
    void listener() => fires++;
    repo.listenable.addListener(listener);
    addTearDown(() => repo.listenable.removeListener(listener));

    await repo.markAcknowledged();
    expect(fires, greaterThan(0));
  });

  test('initialize tolerates malformed stored value', () async {
    SharedPreferences.setMockInitialValues({'mfa_test_bad': 'not a date'});
    final repo = MfaLocalRepository(storageKey: 'mfa_test_bad');
    await repo.initialize();
    expect(repo.isAcknowledged, isFalse);
  });
}
