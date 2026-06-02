import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/account_deletion_request.dart';
import 'package:psyclinicai/services/data/account_deletion_repository.dart';

void main() {
  late InMemoryAccountDeletionRepository repo;

  setUp(() {
    repo = InMemoryAccountDeletionRepository.instance
      ..clearForTesting();
  });

  group('request / current', () {
    test('starts empty', () {
      expect(repo.current('u1'), isNull);
    });

    test('request stores a fresh row and notifies', () {
      var notified = 0;
      void listener() => notified++;
      repo.addListener(listener);
      addTearDown(() => repo.removeListener(listener));

      repo.request(userId: 'u1', reasonCode: 'switching-provider');
      final cur = repo.current('u1');
      expect(cur, isNotNull);
      expect(cur!.userId, 'u1');
      expect(cur.reasonCode, 'switching-provider');
      expect(cur.statusAt(DateTime.now()), DeletionStatus.pendingGrace);
      expect(notified, greaterThanOrEqualTo(1));
    });
  });

  group('cancel', () {
    test('flips the row to cancelled', () {
      repo.request(userId: 'u1');
      repo.cancel('u1');
      final cur = repo.current('u1')!;
      expect(cur.statusAt(DateTime.now()), DeletionStatus.cancelled);
      expect(cur.cancelledAt, isNotNull);
    });

    test('is a no-op when no request exists', () {
      repo.cancel('u-missing');
      expect(repo.current('u-missing'), isNull);
    });
  });

  group('complete', () {
    test('sets completedAt and flips status', () {
      repo.request(userId: 'u1');
      repo.complete('u1');
      final cur = repo.current('u1')!;
      expect(cur.statusAt(DateTime.now()), DeletionStatus.completed);
      expect(cur.completedAt, isNotNull);
    });

    test('is a no-op when no request exists', () {
      repo.complete('u-missing');
      expect(repo.current('u-missing'), isNull);
    });
  });

  group('isolation per user', () {
    test("cancel does not touch another user's row", () {
      repo.request(userId: 'u1');
      repo.request(userId: 'u2');
      repo.cancel('u1');
      expect(repo.current('u1')!.cancelledAt, isNotNull);
      expect(repo.current('u2')!.cancelledAt, isNull);
    });
  });
}
