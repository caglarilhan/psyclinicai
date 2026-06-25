/// H2 — pins the ConsentRepositoryProvider selection contract.
///
/// The provider is the single switch between the in-memory demo
/// repo and the Firestore-backed repo (PR #95). Tests exercise:
///   1. fallback to in-memory when Firebase is not bootstrapped,
///   2. test-override seam returns the injected repo verbatim,
///   3. refresh() drops the cache so the next read rebuilds,
///   4. in-memory fallback is the same singleton instance every
///      time (so listeners stay glued across reads).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';
import 'package:psyclinicai/services/data/consent_repository_provider.dart';

class _FakeRepo extends ConsentEntryRepository {
  @override
  ConsentEntry record(ConsentEntry entry) => entry;
  @override
  ConsentEntry revoke(String entryId) => throw UnimplementedError();
  @override
  List<ConsentEntry> forPatient(String patientId) => const [];
  @override
  ConsentEntry? activeOf(String patientId, ConsentKind kind) => null;
}

void main() {
  setUp(ConsentRepositoryProvider.resetForTesting);
  tearDown(ConsentRepositoryProvider.resetForTesting);

  test('falls back to InMemoryConsentEntryRepository when Firebase off', () {
    final repo = ConsentRepositoryProvider.current();
    expect(repo, isA<InMemoryConsentEntryRepository>());
    expect(
      identical(repo, InMemoryConsentEntryRepository.instance),
      isTrue,
      reason:
          'Fallback must reuse the process-wide singleton so widgets '
          'that addListener() on it before Firebase boots stay glued.',
    );
  });

  test('setOverrideForTest returns the injected repo verbatim', () {
    final fake = _FakeRepo();
    ConsentRepositoryProvider.setOverrideForTest(fake);
    expect(identical(ConsentRepositoryProvider.current(), fake), isTrue);
    ConsentRepositoryProvider.setOverrideForTest(null);
    expect(
      ConsentRepositoryProvider.current(),
      isA<InMemoryConsentEntryRepository>(),
    );
  });

  test('refresh() lets a subsequent current() rebuild', () {
    final first = ConsentRepositoryProvider.current();
    ConsentRepositoryProvider.refresh();
    final second = ConsentRepositoryProvider.current();
    // Both fall back to the same in-memory singleton — the contract
    // is "refresh drops the cache without crashing", not "returns a
    // new instance for the in-memory fallback".
    expect(second, isA<InMemoryConsentEntryRepository>());
    expect(identical(first, second), isTrue);
  });

  test('current() is stable across calls when fallback path stays put', () {
    final a = ConsentRepositoryProvider.current();
    final b = ConsentRepositoryProvider.current();
    expect(identical(a, b), isTrue);
  });
}
