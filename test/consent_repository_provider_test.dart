/// I1 — pins the [ConsentRepositoryRouter] contract.
///
/// The router replaces the previous static-factory pattern that
/// suffered an orphaned-listener bug: consumers that took a final
/// reference to the cached repo + `addListener` on it kept that
/// reference after an auth-driven `refresh()` disposed the
/// underlying instance. The router exposes a stable identity and
/// re-broadcasts the inner repo's notifications, so the orphan is
/// architecturally impossible.
///
/// Tests cover:
///   * Fallback to in-memory when Firebase off / no clinicId.
///   * Inner-repo notify relays through router to external listener.
///   * Auth-driven swap (in-memory → Firestore-like) does NOT
///     detach external listeners from the router (B2 regression).
///   * dispose() detaches the auth listener + (for Firestore inner)
///     disposes the inner repo without throwing.
///   * Disposed router refuses writes with a StateError.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';
import 'package:psyclinicai/services/data/consent_repository_provider.dart';

class _FakeAuth extends ChangeNotifier {
  void fire() => notifyListeners();
}

ConsentRepositoryRouter _build({
  required _FakeAuth auth,
  required String? Function() clinicId,
  required bool Function() firebaseReady,
}) {
  return ConsentRepositoryRouter.test(
    authListenable: auth,
    clinicIdReader: clinicId,
    firebaseReady: firebaseReady,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(InMemoryConsentEntryRepository.instance.clearForTesting);

  test('falls back to in-memory singleton when Firebase off', () {
    final router = _build(
      auth: _FakeAuth(),
      clinicId: () => null,
      firebaseReady: () => false,
    );
    expect(router.active, isA<InMemoryConsentEntryRepository>());
    expect(
      identical(router.active, InMemoryConsentEntryRepository.instance),
      isTrue,
      reason: 'Fallback must reuse the process-wide singleton.',
    );
    expect(router.isFirestoreActive, isFalse);
    router.dispose();
  });

  test('inner repo notifyListeners reaches a router-attached listener', () {
    final router = _build(
      auth: _FakeAuth(),
      clinicId: () => null,
      firebaseReady: () => false,
    );
    var routerNotifications = 0;
    router.addListener(() => routerNotifications++);

    InMemoryConsentEntryRepository.instance.record(
      ConsentEntry(
        id: 'ce-1',
        patientId: 'p1',
        kind: ConsentKind.marketing,
        policyVersion: 'v1',
        signature: 'demo',
      ),
    );

    expect(
      routerNotifications,
      greaterThan(0),
      reason:
          'Router must relay inner repo notifications so screens that '
          'addListener on the router rebuild when a record() happens.',
    );
    router.dispose();
  });

  test('auth swap keeps external router listener attached — B2 regression', () {
    // This is the critical regression: the old static factory would
    // dispose the cached Firestore repo + leave the screen's listener
    // bound to the orphaned instance. The router pattern moves the
    // swap inside the router; external listeners stay on the router
    // identity through any number of swaps.
    final auth = _FakeAuth();
    String? clinicId;
    var ready = false;

    final router = _build(
      auth: auth,
      clinicId: () => clinicId,
      firebaseReady: () => ready,
    );

    var routerNotifications = 0;
    router.addListener(() => routerNotifications++);

    // Initial: fallback in-memory.
    expect(router.isFirestoreActive, isFalse);

    // Simulate sign-in: clinicId resolves, Firebase ready.
    clinicId = 'clinic-a';
    ready = true;
    auth.fire();

    expect(
      router.isFirestoreActive,
      isTrue,
      reason: 'After auth signals ready + clinicId, swap to Firestore.',
    );
    expect(
      routerNotifications,
      greaterThanOrEqualTo(1),
      reason: 'Swap must fire a router notification.',
    );

    // Simulate sign-out: back to in-memory; listener still alive.
    final swapNotificationsSoFar = routerNotifications;
    clinicId = null;
    ready = false;
    auth.fire();

    expect(router.isFirestoreActive, isFalse);
    expect(
      routerNotifications,
      greaterThan(swapNotificationsSoFar),
      reason:
          'Listener attached to the router must survive the second swap '
          '— this is the bug the router exists to prevent.',
    );
    router.dispose();
  });

  test(
    'dispose() removes the auth listener and disposes inner Firestore repo',
    () {
      final auth = _FakeAuth();
      final router = _build(
        auth: auth,
        clinicId: () => 'clinic-x',
        firebaseReady: () => true,
      );
      expect(router.isFirestoreActive, isTrue);

      router.dispose();
      expect(router.isDisposed, isTrue);

      // After dispose, a further auth.fire() must NOT crash. The router
      // unhooked itself, so this is a no-op.
      auth.fire();
      // No assertion needed beyond "did not throw".
    },
  );

  test('disposed router rejects writes with StateError', () {
    final router = _build(
      auth: _FakeAuth(),
      clinicId: () => null,
      firebaseReady: () => false,
    );
    router.dispose();

    expect(
      () => router.record(
        ConsentEntry(
          id: 'ce-x',
          patientId: 'p',
          kind: ConsentKind.marketing,
          policyVersion: 'v',
          signature: 's',
        ),
      ),
      throwsA(isA<StateError>()),
    );
    expect(() => router.revoke('ce-x'), throwsA(isA<StateError>()));
  });

  test('same clinicId across auth fires does not churn the inner repo', () {
    final auth = _FakeAuth();
    final router = _build(
      auth: auth,
      clinicId: () => 'clinic-stable',
      firebaseReady: () => true,
    );

    final first = router.active;
    expect(first, isA<ConsentEntryRepository>());

    auth.fire();
    expect(
      identical(router.active, first),
      isTrue,
      reason: 'No clinicId change → no inner swap.',
    );

    router.dispose();
  });
}
