import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/homework_item.dart';
import 'package:psyclinicai/services/data/homework_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository logic (shared shape across the offline stores): patient
/// filtering, due-date ordering, in-place toggle isolation, and per-record
/// resilience so one corrupt entry never wipes a patient's list.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  HomeworkItem item(String id, String pid, String due) => HomeworkItem(
    id: id,
    patientId: pid,
    title: 'task $id',
    dueDate: DateTime.parse(due),
  );

  test(
    'forPatient filters by patient and sorts by dueDate ascending',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repo = HomeworkRepository();
      await repo.initialize();
      await repo.add(item('a', 'p1', '2026-06-10T00:00:00.000'));
      await repo.add(item('b', 'p1', '2026-06-01T00:00:00.000'));
      await repo.add(item('c', 'p2', '2026-06-05T00:00:00.000'));

      final p1 = repo.forPatient('p1');
      expect(p1.map((i) => i.id), ['b', 'a']); // earliest due first
      expect(repo.forPatient('p2').map((i) => i.id), ['c']); // isolation
    },
  );

  test('toggleDone flips the target only', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = HomeworkRepository();
    await repo.initialize();
    await repo.add(item('a', 'p1', '2026-06-10T00:00:00.000'));
    await repo.add(item('b', 'p1', '2026-06-11T00:00:00.000'));

    await repo.toggleDone('a');
    final byId = {for (final i in repo.forPatient('p1')) i.id: i.done};
    expect(byId['a'], isTrue);
    expect(byId['b'], isFalse);
  });

  test('a corrupt stored record is skipped, valid ones survive', () async {
    SharedPreferences.setMockInitialValues({
      'homework_items': <String>[
        '{not valid json',
        '{"id":"ok","patientId":"p1","title":"keep me",'
            '"dueDate":"2026-06-01T00:00:00.000","done":false}',
      ],
    });
    final repo = HomeworkRepository();
    await repo.initialize();
    final p1 = repo.forPatient('p1');
    expect(p1, hasLength(1));
    expect(p1.single.id, 'ok');
  });
}
