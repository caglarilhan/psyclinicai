/// G1 — coverage for FirestoreConsentEntryRepository:
///   * snapshot listener hydrates the read cache,
///   * record() optimistically updates the cache + persists,
///   * record() of the same kind supersedes the prior active row
///     (sets revokedAt) without exposing two active rows,
///   * revoke() flips the persisted row,
///   * tenancy scope: rows under another clinic_id never appear in
///     the read cache.
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/services/data/firestore_consent_entry_repository.dart';

ConsentEntry _entry({
  String id = 'ce-1',
  String patientId = 'pat-1',
  ConsentKind kind = ConsentKind.kvkkSpecialCategoryHealth,
  String policyVersion = 'kvkk-aydinlatma-v2026.06',
  String signature = 'typed:Demo',
}) => ConsentEntry(
  id: id,
  patientId: patientId,
  kind: kind,
  policyVersion: policyVersion,
  signature: signature,
);

Future<FirestoreConsentEntryRepository> _repo({
  required FakeFirebaseFirestore db,
  String clinicId = 'clinic-A',
}) async {
  final repo = FirestoreConsentEntryRepository(
    clinicId: clinicId,
    collection: db.collection('consent_entries'),
  );
  // Let the initial snapshot land.
  await Future<void>.delayed(const Duration(milliseconds: 30));
  addTearDown(repo.dispose);
  return repo;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('forPatient + activeOf hydrate from existing Firestore docs', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('consent_entries').doc('ce-pre').set({
      ..._entry(id: 'ce-pre', patientId: 'pat-pre').toJson(),
      'clinic_id': 'clinic-A',
    });
    final repo = await _repo(db: db);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(repo.forPatient('pat-pre'), hasLength(1));
    expect(
      repo.activeOf('pat-pre', ConsentKind.kvkkSpecialCategoryHealth)?.id,
      'ce-pre',
    );
  });

  test('record persists + optimistically updates the read cache', () async {
    final db = FakeFirebaseFirestore();
    final repo = await _repo(db: db);

    repo.record(_entry());
    // Optimistic cache update — visible synchronously.
    expect(
      repo.activeOf('pat-1', ConsentKind.kvkkSpecialCategoryHealth)?.id,
      'ce-1',
    );

    // Firestore write completes shortly after; the snapshot echoes it.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final doc = await db.collection('consent_entries').doc('ce-1').get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['clinic_id'], 'clinic-A');
    expect(doc.data()!['kind'], 'kvkk_md6_health');
  });

  test('record supersedes prior active row (sets revokedAt)', () async {
    final db = FakeFirebaseFirestore();
    final repo = await _repo(db: db);

    repo.record(_entry(id: 'old'));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    repo.record(_entry(id: 'new'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final active = repo.activeOf(
      'pat-1',
      ConsentKind.kvkkSpecialCategoryHealth,
    );
    expect(active?.id, 'new');

    final oldDoc = await db.collection('consent_entries').doc('old').get();
    expect(oldDoc.data()!['revokedAt'], isNotNull);
  });

  test('revoke flips the persisted row', () async {
    final db = FakeFirebaseFirestore();
    final repo = await _repo(db: db);

    repo.record(_entry(id: 'rev-target'));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    repo.revoke('rev-target');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      repo.activeOf('pat-1', ConsentKind.kvkkSpecialCategoryHealth),
      isNull,
    );
    final doc = await db.collection('consent_entries').doc('rev-target').get();
    expect(doc.data()!['revokedAt'], isNotNull);
  });

  test('tenancy scope: rows under another clinic_id are invisible', () async {
    final db = FakeFirebaseFirestore();
    // Pre-seed rows for two clinics.
    await db.collection('consent_entries').doc('mine').set({
      ..._entry(id: 'mine').toJson(),
      'clinic_id': 'clinic-A',
    });
    await db.collection('consent_entries').doc('theirs').set({
      ..._entry(id: 'theirs', patientId: 'pat-2').toJson(),
      'clinic_id': 'clinic-B',
    });

    final repo = await _repo(db: db, clinicId: 'clinic-A');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(repo.forPatient('pat-1').map((e) => e.id), ['mine']);
    expect(repo.forPatient('pat-2'), isEmpty);
  });
}
