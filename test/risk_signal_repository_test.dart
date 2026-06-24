/// Coverage for RiskSignalRepository — JSON round-trip, save +
/// reload, filter by session / patient, acknowledge flow, and the
/// corrupt-record drop on initialize.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/risk_signal_service.dart';
import 'package:psyclinicai/services/data/risk_signal_repository.dart';
import 'package:psyclinicai/services/data/secure_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fssChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

PersistedRiskSignal _row({
  String id = 'sig-1',
  String sessionId = 'sess-1',
  String? patientId,
  RiskCategory category = RiskCategory.suicidalIdeation,
  RiskSeverity severity = RiskSeverity.elevated,
  RiskSource source = RiskSource.lexicon,
  String matched = 'not worth living',
  DateTime? at,
  bool acknowledged = false,
}) => PersistedRiskSignal(
  id: id,
  sessionId: sessionId,
  patientId: patientId,
  category: category,
  severity: severity,
  matchedText: matched,
  snippet: 'context for $matched',
  source: source,
  at: at ?? DateTime.utc(2026, 6, 24, 14),
  acknowledged: acknowledged,
);

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

  test('initialize on a fresh bucket yields an empty snapshot', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_fresh');
    await repo.initialize();
    expect(repo.all, isEmpty);
  });

  test('save + reload survives across repo instances', () async {
    final first = RiskSignalRepository(storageBucket: 'rs_test_persist');
    await first.initialize();
    await first.save(_row(id: 'a'));
    await first.save(_row(id: 'b'));

    final fresh = RiskSignalRepository(storageBucket: 'rs_test_persist');
    await fresh.initialize();
    expect(fresh.all, hasLength(2));
    expect(fresh.all.map((s) => s.id).toSet(), {'a', 'b'});
  });

  test('forSession + forPatient filter the snapshot', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_filter');
    await repo.initialize();
    await repo.save(_row(id: 'a', sessionId: 's1', patientId: 'p1'));
    await repo.save(_row(id: 'b', sessionId: 's2', patientId: 'p1'));
    await repo.save(_row(id: 'c', sessionId: 's2', patientId: 'p2'));

    expect(repo.forSession('s2').map((s) => s.id).toSet(), {'b', 'c'});
    expect(repo.forPatient('p1').map((s) => s.id).toSet(), {'a', 'b'});
  });

  test('acknowledge flips the flag + stamps actor / time', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_ack');
    await repo.initialize();
    await repo.save(_row(id: 'a'));
    final at = DateTime.utc(2026, 6, 24, 15);
    final acked = await repo.acknowledge(
      'a',
      actor: 'dr.lee@psyclinicai.com',
      at: at,
    );
    expect(acked, isNotNull);
    expect(acked!.acknowledged, isTrue);
    expect(acked.acknowledgedBy, 'dr.lee@psyclinicai.com');
    expect(acked.acknowledgedAt, at);
  });

  test('acknowledge returns null for unknown id', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_ack_missing');
    await repo.initialize();
    expect(await repo.acknowledge('missing', actor: 'x'), isNull);
  });

  test('acknowledgeAll flips every matching row + stamps actor', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_ack_all');
    await repo.initialize();
    await repo.save(_row(id: 'a'));
    await repo.save(_row(id: 'b'));
    await repo.save(_row(id: 'c'));
    final updated = await repo.acknowledgeAll([
      'a',
      'b',
    ], actor: 'dr.lee@psyclinicai.com');
    expect(updated, hasLength(2));
    final byId = {for (final s in repo.all) s.id: s};
    expect(byId['a']!.acknowledged, isTrue);
    expect(byId['a']!.acknowledgedBy, 'dr.lee@psyclinicai.com');
    expect(byId['b']!.acknowledged, isTrue);
    expect(byId['c']!.acknowledged, isFalse);
  });

  test('acknowledgeAll skips unknown ids without throwing', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_ack_all_skip');
    await repo.initialize();
    await repo.save(_row(id: 'a'));
    final updated = await repo.acknowledgeAll([
      'a',
      'never-existed',
    ], actor: 'x');
    expect(updated, hasLength(1));
    expect(updated.first.id, 'a');
  });

  test('acknowledgeAll skips already-acknowledged rows', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_ack_all_idem');
    await repo.initialize();
    await repo.save(_row(id: 'a'));
    await repo.acknowledge('a', actor: 'first');
    final updated = await repo.acknowledgeAll(['a'], actor: 'second');
    expect(updated, isEmpty);
    expect(repo.all.firstWhere((s) => s.id == 'a').acknowledgedBy, 'first');
  });

  test('saving with the same id replaces the row (no duplicates)', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_dedup');
    await repo.initialize();
    await repo.save(_row(id: 'a'));
    await repo.save(_row(id: 'a', acknowledged: true));
    expect(repo.all, hasLength(1));
    expect(repo.all.first.acknowledged, isTrue);
  });

  test('all is sorted newest-first', () async {
    final repo = RiskSignalRepository(storageBucket: 'rs_test_sort');
    await repo.initialize();
    await repo.save(_row(id: 'old', at: DateTime.utc(2026, 6, 2)));
    await repo.save(_row(id: 'new', at: DateTime.utc(2026, 6, 23)));
    await repo.save(_row(id: 'mid', at: DateTime.utc(2026, 6, 12)));
    expect(repo.all.map((s) => s.id).toList(), ['new', 'mid', 'old']);
  });

  test(
    'initialize migrates legacy SP list into SecurePrefs (one-shot)',
    () async {
      const goodJson =
          '{"id":"good","session_id":"s1","category":"suicidalIdeation",'
          '"severity":"high","matched_text":"x","snippet":"y",'
          '"source":"lexicon","at":"2026-06-24T14:00:00.000Z",'
          '"acknowledged":false}';
      SharedPreferences.setMockInitialValues({
        'rs_test_migrate': <String>[goodJson, 'not json at all'],
      });

      final repo = RiskSignalRepository(storageBucket: 'rs_test_migrate');
      await repo.initialize();
      expect(repo.all, hasLength(1));
      expect(repo.all.first.id, 'good');

      // Migration must have promoted the data into the SecurePrefs backing
      // and cleared the SP entry so PHI never lingers in plaintext.
      expect(secureBacking.keys, contains('rs_test_migrate'));
      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('rs_test_migrate'), isNull);
    },
  );

  test('decoded blob drops corrupt records (per-record resilience)', () async {
    secureBacking['rs_test_corrupt'] =
        '[{"id":"good","session_id":"s1","category":"suicidalIdeation",'
        '"severity":"high","matched_text":"x","snippet":"y",'
        '"source":"lexicon","at":"2026-06-24T14:00:00.000Z",'
        '"acknowledged":false},'
        '"not a map at all"]';
    final repo = RiskSignalRepository(storageBucket: 'rs_test_corrupt');
    await repo.initialize();
    expect(repo.all, hasLength(1));
    expect(repo.all.first.id, 'good');
  });

  test('JSON round-trip preserves every field', () {
    final row =
        _row(
          id: 'x',
          sessionId: 's',
          patientId: 'pat-1',
          category: RiskCategory.harmToOthers,
          severity: RiskSeverity.high,
          source: RiskSource.ai,
          matched: 'phrase',
          at: DateTime.utc(2026, 6, 24, 9, 5),
          acknowledged: true,
        ).copyWith(
          acknowledgedAt: DateTime.utc(2026, 6, 24, 10),
          acknowledgedBy: 'dr.lee@psyclinicai.com',
        );
    final encoded = row.toJson();
    final decoded = PersistedRiskSignal.fromJson(encoded);
    expect(decoded.id, 'x');
    expect(decoded.patientId, 'pat-1');
    expect(decoded.category, RiskCategory.harmToOthers);
    expect(decoded.severity, RiskSeverity.high);
    expect(decoded.source, RiskSource.ai);
    expect(decoded.acknowledged, isTrue);
    expect(decoded.acknowledgedBy, 'dr.lee@psyclinicai.com');
  });
}
