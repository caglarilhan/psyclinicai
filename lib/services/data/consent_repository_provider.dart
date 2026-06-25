/// Bootstrap-time selector for the active [ConsentEntryRepository].
///
/// **Why a separate factory** — the IntakeFormScreen + ConsentCenter
/// today reach for `InMemoryConsentEntryRepository.instance` directly,
/// which is fine in demo mode but means the Firestore adapter
/// (PR #95) is never used in production. This provider gives the
/// bootstrap one symbol to swap, and the rest of the app reads the
/// active repo by calling [ConsentRepositoryProvider.current].
///
/// **Selection rule**:
///   * if Firebase is ready AND a clinician profile is resolved →
///     [FirestoreConsentEntryRepository] scoped to the profile's
///     `clinicId`,
///   * else → [InMemoryConsentEntryRepository.instance].
///
/// The Firestore instance is cached so multiple consumers share a
/// single snapshot subscription. A new auth event (sign-in /
/// sign-out / clinicId change) calls [refresh] to rebuild it.
library;

import 'auth_service.dart';
import 'consent_entry_repository.dart';
import 'firebase_bootstrap.dart';
import 'firestore_consent_entry_repository.dart';

class ConsentRepositoryProvider {
  ConsentRepositoryProvider._();

  static ConsentEntryRepository? _cached;
  static String? _cachedClinicId;
  static bool _cachedIsFirestore = false;

  static ConsentEntryRepository? _override;

  /// Test seam — injects [repo] as the active value; subsequent
  /// [current] calls return it verbatim. Pass `null` to clear.
  static void setOverrideForTest(ConsentEntryRepository? repo) {
    _override = repo;
  }

  /// Returns the active repo. Picks Firestore when Firebase is
  /// bootstrapped + a clinician profile is signed in; falls back to
  /// the in-memory singleton otherwise (demo mode + widget tests
  /// without a Firebase fixture).
  static ConsentEntryRepository current() {
    if (_override != null) return _override!;

    final firebaseReady = _firebaseReadySafe();
    final clinicId = _clinicIdSafe();

    if (firebaseReady && clinicId != null) {
      if (_cached != null &&
          _cachedIsFirestore &&
          _cachedClinicId == clinicId) {
        return _cached!;
      }
      _disposeCached();
      final repo = FirestoreConsentEntryRepository(clinicId: clinicId);
      _cached = repo;
      _cachedClinicId = clinicId;
      _cachedIsFirestore = true;
      return repo;
    }

    if (!_cachedIsFirestore && _cached != null) return _cached!;
    _disposeCached();
    final repo = InMemoryConsentEntryRepository.instance;
    _cached = repo;
    _cachedClinicId = null;
    _cachedIsFirestore = false;
    return repo;
  }

  /// Drops the cached repo and rebuilds it on the next [current]
  /// call. Bootstrap should call this after a sign-in / sign-out
  /// completes so the next read picks the matching repo.
  static void refresh() {
    _disposeCached();
  }

  /// Test-only — fully drops cached + override state.
  static void resetForTesting() {
    _disposeCached();
    _override = null;
  }

  static void _disposeCached() {
    final cur = _cached;
    if (cur != null && cur is FirestoreConsentEntryRepository) {
      cur.dispose();
    }
    _cached = null;
    _cachedClinicId = null;
    _cachedIsFirestore = false;
  }

  static bool _firebaseReadySafe() {
    try {
      return PsyFirebase.isReady;
    } catch (_) {
      return false;
    }
  }

  static String? _clinicIdSafe() {
    try {
      return FirebaseAuthService.instance.profile?.clinicId;
    } catch (_) {
      return null;
    }
  }
}
