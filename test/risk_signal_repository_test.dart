/// Coverage for RiskSignalRepository — JSON round-trip, save +
/// reload, filter by session / patient, acknowledge flow, and the
/// corrupt-record drop on initialize.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/risk_signal_service.dart';
import 'package:psyclinicai/services/data/risk_signal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

  test('initialize drops corrupt records', () async {
    const goodJson =
        '{"id":"good","session_id":"s1","category":"suicidalIdeation",'
        '"severity":"high","matched_text":"x","snippet":"y",'
        '"source":"lexicon","at":"2026-06-24T14:00:00.000Z",'
        '"acknowledged":false}';
    SharedPreferences.setMockInitialValues({
      'rs_test_corrupt': <String>[goodJson, 'not json at all'],
    });
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
