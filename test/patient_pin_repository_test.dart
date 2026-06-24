/// Coverage for PatientPinRepository — fresh-device empty set,
/// toggle, pin / unpin idempotency, listenable fan-out, JSON
/// round-trip across reload, and the corrupt-record fallback.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/patient_pin_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fresh device yields an empty set', () async {
    final repo = PatientPinRepository(storageKey: 'pp_test_fresh');
    await repo.initialize();
    expect(repo.current, isEmpty);
    expect(repo.isPinned('any-id'), isFalse);
  });

  test('toggle adds a patient and toggling again removes it', () async {
    final repo = PatientPinRepository(storageKey: 'pp_test_toggle');
    await repo.initialize();
    await repo.toggle('pat-1');
    expect(repo.isPinned('pat-1'), isTrue);
    await repo.toggle('pat-1');
    expect(repo.isPinned('pat-1'), isFalse);
  });

  test('pin is idempotent', () async {
    final repo = PatientPinRepository(storageKey: 'pp_test_pin_idem');
    await repo.initialize();
    await repo.pin('pat-1');
    await repo.pin('pat-1');
    expect(repo.current, {'pat-1'});
  });

  test('unpin is idempotent on an unpinned patient', () async {
    final repo = PatientPinRepository(storageKey: 'pp_test_unpin_idem');
    await repo.initialize();
    await repo.unpin('never-pinned');
    expect(repo.current, isEmpty);
  });

  test('multiple pins coexist', () async {
    final repo = PatientPinRepository(storageKey: 'pp_test_multi');
    await repo.initialize();
    await repo.pin('pat-1');
    await repo.pin('pat-2');
    await repo.pin('pat-3');
    expect(repo.current, {'pat-1', 'pat-2', 'pat-3'});
  });

  test('round-trip across repo instances', () async {
    final first = PatientPinRepository(storageKey: 'pp_test_persist');
    await first.initialize();
    await first.pin('pat-1');
    await first.pin('pat-2');

    final fresh = PatientPinRepository(storageKey: 'pp_test_persist');
    await fresh.initialize();
    expect(fresh.current, {'pat-1', 'pat-2'});
  });

  test('listenable fires when the set changes', () async {
    final repo = PatientPinRepository(storageKey: 'pp_test_listenable');
    await repo.initialize();
    var notifications = 0;
    void listener() => notifications++;
    repo.listenable.addListener(listener);
    addTearDown(() => repo.listenable.removeListener(listener));

    await repo.pin('pat-1');
    expect(notifications, greaterThan(0));
  });

  test('corrupt stored value falls back to empty set', () async {
    SharedPreferences.setMockInitialValues({'pp_test_corrupt': 'not json'});
    final repo = PatientPinRepository(storageKey: 'pp_test_corrupt');
    await repo.initialize();
    expect(repo.current, isEmpty);
  });

  test('empty stored value yields empty set without throwing', () async {
    SharedPreferences.setMockInitialValues({'pp_test_empty': ''});
    final repo = PatientPinRepository(storageKey: 'pp_test_empty');
    await repo.initialize();
    expect(repo.current, isEmpty);
  });
}
