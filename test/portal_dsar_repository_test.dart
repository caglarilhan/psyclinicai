import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/portal_dsar_request.dart';
import 'package:psyclinicai/services/portal/portal_dsar_repository.dart';

void main() {
  setUp(() {
    InMemoryPortalDsarRepository.instance.clearForTesting();
  });

  group('InMemoryPortalDsarRepository', () {
    test('submit lands a request in submitted state for the user', () {
      final repo = InMemoryPortalDsarRepository.instance;
      final r = repo.submit(
        userId: 'u-1',
        patientId: 'p-1',
        kind: PortalDsarKind.access,
        notes: 'Please send my full chart',
      );
      expect(r.state, PortalDsarState.submitted);
      expect(repo.forUser('u-1'), hasLength(1));
      expect(repo.forUser('other'), isEmpty);
    });

    test('advance rejects an illegal transition', () {
      final repo = InMemoryPortalDsarRepository.instance;
      final r = repo.submit(
        userId: 'u-1',
        patientId: 'p-1',
        kind: PortalDsarKind.access,
      );
      expect(
        () => repo.advance(id: r.id, next: PortalDsarState.fulfilled),
        throwsA(isA<StateError>()),
      );
    });

    test('fulfilled stamps fulfilledAt', () {
      final repo = InMemoryPortalDsarRepository.instance;
      final r = repo.submit(
        userId: 'u-1',
        patientId: 'p-1',
        kind: PortalDsarKind.access,
      );
      repo.advance(id: r.id, next: PortalDsarState.underReview);
      final done = repo.advance(
        id: r.id,
        next: PortalDsarState.fulfilled,
        notes: 'Sent the archive',
      );
      expect(done.state, PortalDsarState.fulfilled);
      expect(done.fulfilledAt, isNotNull);
      expect(done.notes, 'Sent the archive');
    });

    test('rejected is a final state — cannot revert', () {
      final repo = InMemoryPortalDsarRepository.instance;
      final r = repo.submit(
        userId: 'u-1',
        patientId: 'p-1',
        kind: PortalDsarKind.access,
      );
      repo.advance(id: r.id, next: PortalDsarState.rejected);
      expect(
        () => repo.advance(id: r.id, next: PortalDsarState.underReview),
        throwsA(isA<StateError>()),
      );
    });
  });
}
