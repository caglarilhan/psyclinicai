/// Auth-aware router for the active [ConsentEntryRepository].
///
/// **The orphaned-listener bug we fix**: the previous bootstrap was
/// a static factory (`ConsentRepositoryProvider.current()`) plus an
/// auth listener that called `refresh()` to drop the cache.
/// Consumers captured the result of `current()` in a `final` field
/// and called `addListener(_onChange)` on it. When auth flipped,
/// the cached instance was `dispose()`d but the screen's listener
/// stayed bound to the now-disposed `ChangeNotifier` — debug throws
/// "ChangeNotifier was used after being disposed", release silently
/// shows stale data.
///
/// [ConsentRepositoryRouter] replaces that pattern. It is a stable
/// `ChangeNotifier` that decorates the active inner repository and
/// re-broadcasts its notifications. When auth flips, the router
/// swaps the inner repo + transfers its own listener, but every
/// downstream consumer keeps listening to the same router instance.
/// No orphaned listeners possible.
///
/// **Selection rule** (same as before):
///   * Firebase ready AND profile clinicId resolved →
///     [FirestoreConsentEntryRepository] scoped by clinicId
///   * else → [InMemoryConsentEntryRepository.instance]
///
/// Wired into the widget tree via `ChangeNotifierProvider<
/// ConsentEntryRepository>` in `main.dart`. Consumers read via
/// `context.watch<ConsentEntryRepository>()` (rebuild on change)
/// or `context.read<ConsentEntryRepository>()` (write-only).
library;

import 'package:flutter/foundation.dart';

import '../../models/consent_entry.dart';
import 'auth_service.dart';
import 'consent_entry_repository.dart';
import 'firebase_bootstrap.dart';
import 'firestore_consent_entry_repository.dart';

class ConsentRepositoryRouter extends ConsentEntryRepository {
  /// Production constructor — wires the router to
  /// [FirebaseAuthService.instance] + [PsyFirebase.isReady].
  ConsentRepositoryRouter()
    : _authListenable = FirebaseAuthService.instance,
      _clinicIdReader = (() => FirebaseAuthService.instance.profile?.clinicId),
      _firebaseReadyReader = (() => PsyFirebase.isReady),
      _firestoreFactory = ((id) =>
          FirestoreConsentEntryRepository(clinicId: id)) {
    _attach(_pick());
    _authListenable.addListener(_onAuthChanged);
  }

  /// Test seam — injects an arbitrary [Listenable] as the auth source,
  /// closures that return the current clinicId + Firebase readiness,
  /// and a factory for the "Firestore-like" branch (defaults to a
  /// fresh in-memory repo so tests don't need Firebase init).
  @visibleForTesting
  ConsentRepositoryRouter.test({
    required Listenable authListenable,
    required String? Function() clinicIdReader,
    required bool Function() firebaseReady,
    ConsentEntryRepository Function(String clinicId)? firestoreFactory,
  }) : _authListenable = authListenable,
       _clinicIdReader = clinicIdReader,
       _firebaseReadyReader = firebaseReady,
       _firestoreFactory = firestoreFactory ?? ((_) => _FakeFirestoreRepo()) {
    _attach(_pick());
    _authListenable.addListener(_onAuthChanged);
  }

  final Listenable _authListenable;
  final String? Function() _clinicIdReader;
  final bool Function() _firebaseReadyReader;
  final ConsentEntryRepository Function(String clinicId) _firestoreFactory;

  ConsentEntryRepository _active = InMemoryConsentEntryRepository.instance;
  String? _activeClinicId;
  bool _disposed = false;

  /// The repo the router is currently delegating to. Exposed for
  /// tests that need to assert the underlying type / clinicId.
  @visibleForTesting
  ConsentEntryRepository get active => _active;

  /// `true` when the active repo is NOT the in-memory singleton —
  /// i.e. we routed to a Firestore-like adapter via the factory.
  @visibleForTesting
  bool get isFirestoreActive => _active is! InMemoryConsentEntryRepository;

  /// `true` when the router has been disposed; any further writes
  /// throw [StateError].
  @visibleForTesting
  bool get isDisposed => _disposed;

  void _onAuthChanged() {
    if (_disposed) return;
    final next = _pick();
    if (identical(next, _active)) return;
    _detach(_active);
    _attach(next);
    notifyListeners();
  }

  ConsentEntryRepository _pick() {
    final ready = _firebaseReadySafe();
    final clinicId = _clinicIdSafe();
    if (ready && clinicId != null) {
      if (isFirestoreActive && _activeClinicId == clinicId) return _active;
      return _firestoreFactory(clinicId);
    }
    return InMemoryConsentEntryRepository.instance;
  }

  void _attach(ConsentEntryRepository repo) {
    _active = repo;
    _activeClinicId = repo is FirestoreConsentEntryRepository
        ? repo.clinicId
        : (_clinicIdSafe());
    repo.addListener(_relay);
  }

  void _detach(ConsentEntryRepository repo) {
    repo.removeListener(_relay);
    if (repo is! InMemoryConsentEntryRepository) {
      // The in-memory singleton must NEVER be disposed — other surfaces
      // (tests, demo mode) still hold listeners against it. Any other
      // adapter we routed to is owned by the router and must be torn
      // down on swap / dispose.
      try {
        repo.dispose();
      } catch (e, st) {
        debugPrint('[consent-router] dispose threw: $e\n$st');
      }
    }
  }

  void _relay() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  List<ConsentEntry> forPatient(String patientId) =>
      _active.forPatient(patientId);

  @override
  ConsentEntry? activeOf(String patientId, ConsentKind kind) =>
      _active.activeOf(patientId, kind);

  @override
  ConsentEntry record(ConsentEntry entry) {
    if (_disposed) {
      throw StateError('ConsentRepositoryRouter used after dispose');
    }
    return _active.record(entry);
  }

  @override
  ConsentEntry revoke(String entryId) {
    if (_disposed) {
      throw StateError('ConsentRepositoryRouter used after dispose');
    }
    return _active.revoke(entryId);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _authListenable.removeListener(_onAuthChanged);
    _detach(_active);
    super.dispose();
  }

  bool _firebaseReadySafe() {
    try {
      return _firebaseReadyReader();
    } catch (_) {
      return false;
    }
  }

  String? _clinicIdSafe() {
    try {
      return _clinicIdReader();
    } catch (_) {
      return null;
    }
  }
}

/// Default test stand-in for the "Firestore branch" — a plain
/// in-memory adapter so router tests can exercise the swap path
/// without booting Firebase. Tests that need real Firestore
/// behavior can pass their own `firestoreFactory` to
/// [ConsentRepositoryRouter.test].
class _FakeFirestoreRepo extends ConsentEntryRepository {
  final Map<String, ConsentEntry> _byId = {};

  @override
  List<ConsentEntry> forPatient(String patientId) => _byId.values
      .where((e) => e.patientId == patientId)
      .toList(growable: false);

  @override
  ConsentEntry? activeOf(String patientId, ConsentKind kind) {
    for (final e in _byId.values) {
      if (e.patientId == patientId && e.kind == kind && e.isActive) return e;
    }
    return null;
  }

  @override
  ConsentEntry record(ConsentEntry entry) {
    _byId[entry.id] = entry;
    notifyListeners();
    return entry;
  }

  @override
  ConsentEntry revoke(String entryId) {
    final cur = _byId[entryId];
    if (cur == null) throw StateError('entry $entryId not found');
    final updated = cur.revoke();
    _byId[entryId] = updated;
    notifyListeners();
    return updated;
  }
}
