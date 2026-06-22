import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/supervision_review.dart';
import 'package:psyclinicai/services/supervision_review_repository.dart';

void main() {
  group('SupervisionReview model', () {
    test('JSON round-trip preserves all fields', () {
      final r = SupervisionReview(
        id: 'rev-1',
        clinicId: 'c1',
        traineeId: 't1',
        supervisorId: 'sup1',
        sessionNoteId: 'note-1',
        status: SupervisionReviewStatus.changesRequested,
        supervisorComment: 'Tighten the SOAP plan section',
        requestedAt: DateTime.utc(2026, 6, 1, 9),
        decidedAt: DateTime.utc(2026, 6, 1, 10),
      );
      final round = SupervisionReview.fromJson(r.toJson());
      expect(round.id, r.id);
      expect(round.status, SupervisionReviewStatus.changesRequested);
      expect(round.supervisorComment, 'Tighten the SOAP plan section');
      expect(round.decidedAt, isNotNull);
    });

    test('transitionBlockedReason allows pending → any decision', () {
      final r = SupervisionReview(
        id: 'r',
        clinicId: 'c',
        traineeId: 't',
        supervisorId: 's',
        sessionNoteId: 'n',
      );
      expect(
        r.transitionBlockedReason(SupervisionReviewStatus.approved),
        isNull,
      );
      expect(
        r.transitionBlockedReason(SupervisionReviewStatus.coSigned),
        isNull,
      );
      expect(
        r.transitionBlockedReason(SupervisionReviewStatus.changesRequested),
        isNull,
      );
    });

    test('finalised reviews are frozen', () {
      final r = SupervisionReview(
        id: 'r',
        clinicId: 'c',
        traineeId: 't',
        supervisorId: 's',
        sessionNoteId: 'n',
        status: SupervisionReviewStatus.coSigned,
      );
      expect(
        r.transitionBlockedReason(SupervisionReviewStatus.pending),
        contains('immutable'),
      );
    });

    test('changesRequested only walks back to pending', () {
      final r = SupervisionReview(
        id: 'r',
        clinicId: 'c',
        traineeId: 't',
        supervisorId: 's',
        sessionNoteId: 'n',
        status: SupervisionReviewStatus.changesRequested,
      );
      expect(
        r.transitionBlockedReason(SupervisionReviewStatus.pending),
        isNull,
      );
      expect(
        r.transitionBlockedReason(SupervisionReviewStatus.approved),
        isNotNull,
      );
    });
  });

  group('InMemorySupervisionReviewRepository', () {
    setUp(InMemorySupervisionReviewRepository.instance.clearForTesting);

    test('submit creates a pending review in the supervisor queue', () {
      final repo = InMemorySupervisionReviewRepository.instance;
      final row = repo.submit(
        clinicId: 'c1',
        traineeId: 't1',
        supervisorId: 'sup1',
        sessionNoteId: 'note-1',
      );
      expect(row.status, SupervisionReviewStatus.pending);
      expect(repo.openQueueFor('sup1'), hasLength(1));
      expect(repo.openQueueFor('other-sup'), isEmpty);
    });

    test('decide rejects invalid transitions', () {
      final repo = InMemorySupervisionReviewRepository.instance;
      final row = repo.submit(
        clinicId: 'c1',
        traineeId: 't1',
        supervisorId: 'sup1',
        sessionNoteId: 'note-1',
      );
      repo.decide(
        id: row.id,
        next: SupervisionReviewStatus.coSigned,
        comment: 'Signed off',
      );
      expect(
        () => repo.decide(id: row.id, next: SupervisionReviewStatus.pending),
        throwsA(isA<StateError>()),
      );
    });

    test('changes_requested → pending via resubmit', () {
      final repo = InMemorySupervisionReviewRepository.instance;
      final row = repo.submit(
        clinicId: 'c1',
        traineeId: 't1',
        supervisorId: 'sup1',
        sessionNoteId: 'note-1',
      );
      repo.decide(
        id: row.id,
        next: SupervisionReviewStatus.changesRequested,
        comment: 'Add risk assessment',
      );
      final back = repo.resubmit(row.id);
      expect(back.status, SupervisionReviewStatus.pending);
      expect(back.supervisorComment, 'Add risk assessment');
    });

    test('resubmit refuses to act on a final review', () {
      final repo = InMemorySupervisionReviewRepository.instance;
      final row = repo.submit(
        clinicId: 'c1',
        traineeId: 't1',
        supervisorId: 'sup1',
        sessionNoteId: 'note-1',
      );
      repo.decide(id: row.id, next: SupervisionReviewStatus.approved);
      expect(() => repo.resubmit(row.id), throwsA(isA<StateError>()));
    });
  });
}
