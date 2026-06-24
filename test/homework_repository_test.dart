import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/homework_item.dart';
import 'package:psyclinicai/services/data/homework_repository.dart';
import 'package:psyclinicai/services/data/secure_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fssChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

const _validHomeworkJson =
    '{"id":"ok","patientId":"p1","title":"keep me",'
    '"dueDate":"2026-06-01T00:00:00.000","done":false}';
const _homeworkSeed = <String>['{not valid json', _validHomeworkJson];

/// Repository logic: patient filtering, due-date ordering, in-place
/// toggle isolation, per-record resilience, and the SP→SecurePrefs
/// one-shot migration on init.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late Map<String, String> secureBacking;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secureBacking = <String, String>{};
    messenger.setMockMethodCallHandler(_fssChannel, (call) async {
      switch (call.method) {
        case 'read':
          return secureBacking[(call.arguments as Map)['key'] as String];
        case 'write':
          final a = call.arguments as Map;
          secureBacking[a['key'] as String] = a['value'] as String;
          return null;
        case 'delete':
          secureBacking.remove((call.arguments as Map)['key'] as String);
          return null;
        case 'containsKey':
          return secureBacking.containsKey(
            (call.arguments as Map)['key'] as String,
          );
        case 'deleteAll':
          secureBacking.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(secureBacking);
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(_fssChannel, null);
    SecurePrefs.setInstanceForTest(null);
  });

  HomeworkItem item(String id, String pid, String due) => HomeworkItem(
    id: id,
    patientId: pid,
    title: 'task $id',
    dueDate: DateTime.parse(due),
  );

  test(
    'forPatient filters by patient and sorts by dueDate ascending',
    () async {
      final repo = HomeworkRepository();
      await repo.initialize();
      await repo.add(item('a', 'p1', '2026-06-10T00:00:00.000'));
      await repo.add(item('b', 'p1', '2026-06-01T00:00:00.000'));
      await repo.add(item('c', 'p2', '2026-06-05T00:00:00.000'));

      final p1 = repo.forPatient('p1');
      expect(p1.map((i) => i.id), ['b', 'a']);
      expect(repo.forPatient('p2').map((i) => i.id), ['c']);
    },
  );

  test('toggleDone flips the target only', () async {
    final repo = HomeworkRepository();
    await repo.initialize();
    await repo.add(item('a', 'p1', '2026-06-10T00:00:00.000'));
    await repo.add(item('b', 'p1', '2026-06-11T00:00:00.000'));

    await repo.toggleDone('a');
    final byId = {for (final i in repo.forPatient('p1')) i.id: i.done};
    expect(byId['a'], isTrue);
    expect(byId['b'], isFalse);
  });

  test(
    'initialize migrates legacy SP list into SecurePrefs (one-shot)',
    () async {
      SharedPreferences.setMockInitialValues({'homework_items': _homeworkSeed});
      final repo = HomeworkRepository();
      await repo.initialize();
      final p1 = repo.forPatient('p1');
      expect(p1, hasLength(1));
      expect(p1.single.id, 'ok');

      // SP entry must be wiped; SecurePrefs must hold the data.
      expect(secureBacking.keys, contains('homework_items'));
      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('homework_items'), isNull);
    },
  );

  test('decoded blob drops corrupt records (per-record resilience)', () async {
    secureBacking['homework_items'] = '[$_validHomeworkJson, "not a map"]';
    final repo = HomeworkRepository();
    await repo.initialize();
    final p1 = repo.forPatient('p1');
    expect(p1, hasLength(1));
    expect(p1.single.id, 'ok');
  });
}
