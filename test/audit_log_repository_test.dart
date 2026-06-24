/// Coverage for AuditLogRepository — append-only contract, hash
/// chain integrity, query filters (actor/kind/range), tamper
/// detection, update/delete refusal, corrupt-record drop.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuditLogEntry _row({
  String id = 'r1',
  String kind = 'signin',
  String action = 'Signed in',
  String actor = 'demo@psyclinicai.com',
  String entity = 'session',
  AuditResult result = AuditResult.success,
  DateTime? at,
}) => AuditLogEntry(
  id: id,
  kind: kind,
  action: action,
  actor: actor,
  entity: entity,
  timestampUtc: at ?? DateTime.utc(2026, 6, 24, 10),
  result: result,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('append + chain', () {
    test('append seals each row with a non-empty SHA-256 hash', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_seal');
      await repo.initialize();
      final r = await repo.append(_row());
      expect(r.hash, isNotNull);
      expect(r.hash, isNotEmpty);
      expect(r.hash!.length, 64);
    });

    test('subsequent appends produce different hashes', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_chain');
      await repo.initialize();
      final a = await repo.append(_row(id: 'a'));
      final b = await repo.append(_row(id: 'b'));
      expect(a.hash, isNot(equals(b.hash)));
    });

    test('verifyChain returns null on intact chain', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_verify');
      await repo.initialize();
      await repo.append(_row(id: 'a'));
      await repo.append(_row(id: 'b'));
      await repo.append(_row(id: 'c'));
      expect(repo.verifyChain(), isNull);
    });

    test(
      'verifyChain catches a tampered row after manual corruption',
      () async {
        const tampered =
            '{"id":"a","kind":"signin","action":"Signed in",'
            '"actor":"demo@psyclinicai.com","entity":"session",'
            '"timestamp_utc":"2026-06-24T10:00:00.000Z",'
            '"result":"success","hash":"bogus"}';
        SharedPreferences.setMockInitialValues({
          'al_test_tamper': <String>[tampered],
        });
        final repo = AuditLogRepository(storageBucket: 'al_test_tamper');
        await repo.initialize();
        expect(repo.verifyChain(), 0);
      },
    );

    test("appended row's hash field is overwritten by the repo", () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_override');
      await repo.initialize();
      final supplied = _row().copyWith(hash: 'caller-supplied-bogus');
      final sealed = await repo.append(supplied);
      expect(sealed.hash, isNot('caller-supplied-bogus'));
    });
  });

  group('query filters', () {
    test('forActor filters by actor email', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_actor');
      await repo.initialize();
      await repo.append(_row(id: 'a', actor: 'alice@x.com'));
      await repo.append(_row(id: 'b', actor: 'bob@x.com'));
      await repo.append(_row(id: 'c', actor: 'alice@x.com'));
      final alice = repo.forActor('alice@x.com').map((r) => r.id).toSet();
      expect(alice, {'a', 'c'});
    });

    test('byKind filters by event kind', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_kind');
      await repo.initialize();
      await repo.append(_row(id: 'a'));
      await repo.append(_row(id: 'b', kind: 'phi_read'));
      await repo.append(_row(id: 'c', kind: 'phi_read'));
      expect(repo.byKind('phi_read').map((r) => r.id), {'b', 'c'});
    });

    test('inRange filters inclusive UTC bounds', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_range');
      await repo.initialize();
      await repo.append(_row(id: 'a', at: DateTime.utc(2026, 6, 2, 9)));
      await repo.append(_row(id: 'b', at: DateTime.utc(2026, 6, 22, 9)));
      await repo.append(_row(id: 'c', at: DateTime.utc(2026, 7, 2, 9)));
      final june = repo
          .inRange(DateTime.utc(2026, 6, 2), DateTime.utc(2026, 6, 30))
          .map((r) => r.id)
          .toSet();
      expect(june, {'a', 'b'});
    });

    test('all is sorted newest-first', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_sort');
      await repo.initialize();
      await repo.append(_row(id: 'oldest', at: DateTime.utc(2026, 6, 2)));
      await repo.append(_row(id: 'newest', at: DateTime.utc(2026, 6, 23)));
      await repo.append(_row(id: 'middle', at: DateTime.utc(2026, 6, 12)));
      expect(repo.all.map((r) => r.id).toList(), [
        'newest',
        'middle',
        'oldest',
      ]);
    });
  });

  group('append-only contract', () {
    test('update throws UnsupportedError', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_no_update');
      await repo.initialize();
      expect(() => repo.update(_row()), throwsUnsupportedError);
    });

    test('delete throws UnsupportedError', () async {
      final repo = AuditLogRepository(storageBucket: 'al_test_no_delete');
      await repo.initialize();
      expect(() => repo.delete('any-id'), throwsUnsupportedError);
    });
  });

  group('persistence', () {
    test('rows survive repo reload', () async {
      final first = AuditLogRepository(storageBucket: 'al_test_persist');
      await first.initialize();
      await first.append(_row(id: 'a'));
      await first.append(_row(id: 'b'));

      final fresh = AuditLogRepository(storageBucket: 'al_test_persist');
      await fresh.initialize();
      expect(fresh.all, hasLength(2));
      expect(fresh.verifyChain(), isNull);
    });

    test('initialize drops corrupt records', () async {
      SharedPreferences.setMockInitialValues({
        'al_test_corrupt': <String>[
          '{"id":"good","kind":"signin","action":"X","actor":"a","entity":"e","timestamp_utc":"2026-06-24T10:00:00.000Z","result":"success"}',
          'not valid json',
        ],
      });
      final repo = AuditLogRepository(storageBucket: 'al_test_corrupt');
      await repo.initialize();
      expect(repo.all, hasLength(1));
      expect(repo.all.first.id, 'good');
    });
  });
}

extension on AuditLogEntry {
  AuditLogEntry copyWith({String? hash}) => AuditLogEntry(
    id: id,
    kind: kind,
    action: action,
    actor: actor,
    entity: entity,
    timestampUtc: timestampUtc,
    result: result,
    userId: userId,
    ip: ip,
    device: device,
    hash: hash,
  );
}
