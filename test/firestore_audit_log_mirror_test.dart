/// J1 — pins the FirestoreAuditLogMirror payload schema + idempotency.
///
/// The schema MUST match the predicates in `firestore.rules` for
/// `clinic_audit_logs/{clinicId}/entries/{rowId}`. A drift here
/// silently breaks every mirror write under tenancy enforcement.
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/services/data/firestore_audit_log_mirror.dart';

final _kSampleHash = 'a' * 64; // 64-char SHA-256 hex stand-in.

AuditLogEntry _entry({String id = 'audit-test-1', String? hash}) =>
    AuditLogEntry(
      id: id,
      kind: 'consent',
      action: 'kvkk.consent_granted',
      actor: 'pat-1',
      entity: 'patient:pat-1 entry:ce-1 policy:2026-06',
      timestampUtc: DateTime.utc(2026, 6, 25, 12, 34, 56),
      result: AuditResult.success,
      hash: hash ?? _kSampleHash,
    );

AuditLogEntry _unsealedEntry({String id = 'audit-test-1'}) => AuditLogEntry(
  id: id,
  kind: 'consent',
  action: 'kvkk.consent_granted',
  actor: 'pat-1',
  entity: 'patient:pat-1 entry:ce-1 policy:2026-06',
  timestampUtc: DateTime.utc(2026, 6, 25, 12, 34, 56),
  result: AuditResult.success,
  hash: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore db;
  late FirestoreAuditLogMirror mirror;

  setUp(() {
    db = FakeFirebaseFirestore();
    mirror = FirestoreAuditLogMirror(firestore: db);
  });

  test('writes to clinic_audit_logs/{clinicId}/entries/{entry.id}', () async {
    final result = await mirror.write(
      clinicId: 'clinic-xyz',
      entry: _entry(),
      prevHash: '',
    );
    expect(result.isSuccess, isTrue);

    final snap = await db
        .collection('clinic_audit_logs')
        .doc('clinic-xyz')
        .collection('entries')
        .doc('audit-test-1')
        .get();
    expect(snap.exists, isTrue);
  });

  test('payload schema matches firestore.rules predicates exactly', () async {
    await mirror.write(
      clinicId: 'clinic-xyz',
      entry: _entry(id: 'audit-schema-1'),
      prevHash: 'b' * 64,
    );

    final data =
        (await db
                .collection('clinic_audit_logs')
                .doc('clinic-xyz')
                .collection('entries')
                .doc('audit-schema-1')
                .get())
            .data();
    expect(data, isNotNull);
    expect(data!['clinic_id'], 'clinic-xyz');
    expect(data['id'], 'audit-schema-1');
    expect(data['kind'], 'consent');
    expect(data['action'], 'kvkk.consent_granted');
    expect(data['actor'], 'pat-1');
    expect(data['entity'], 'patient:pat-1 entry:ce-1 policy:2026-06');
    expect(data['result'], 'success');
    expect(data['hash'], _kSampleHash);
    expect(data['prev_hash'], 'b' * 64);
    expect(data['timestamp_utc'], '2026-06-25T12:34:56.000Z');
    // Optional fields omitted when null.
    expect(data.containsKey('user_id'), isFalse);
    expect(data.containsKey('ip'), isFalse);
    expect(data.containsKey('device_id'), isFalse);
  });

  test('empty clinicId returns skipped, no write happens', () async {
    final result = await mirror.write(clinicId: '', entry: _entry());
    expect(result.isSkipped, isTrue);
    expect(result.message, 'empty_clinic_id');
    expect((await db.collection('clinic_audit_logs').get()).docs, isEmpty);
  });

  test('unsealed entry (hash null) returns skipped', () async {
    final result = await mirror.write(
      clinicId: 'clinic-xyz',
      entry: _unsealedEntry(),
    );
    expect(result.isSkipped, isTrue);
    expect(result.message, 'unsealed_entry');
  });

  test(
    'idempotent — same entry id is a no-op overwrite (set, not add)',
    () async {
      final entry = _entry(id: 'audit-idem-1');
      await mirror.write(clinicId: 'clinic-xyz', entry: entry, prevHash: '');
      await mirror.write(clinicId: 'clinic-xyz', entry: entry, prevHash: '');

      final all = await db
          .collection('clinic_audit_logs')
          .doc('clinic-xyz')
          .collection('entries')
          .get();
      expect(
        all.docs,
        hasLength(1),
        reason: 'Idempotency relies on entry.id being the doc id.',
      );
    },
  );

  test('chain head writes with empty prev_hash', () async {
    await mirror.write(
      clinicId: 'clinic-xyz',
      entry: _entry(id: 'audit-head'),
      prevHash: '',
    );
    final data =
        (await db
                .collection('clinic_audit_logs')
                .doc('clinic-xyz')
                .collection('entries')
                .doc('audit-head')
                .get())
            .data();
    expect(data!['prev_hash'], '');
  });

  test('multiple clinicIds land in distinct subcollections', () async {
    await mirror.write(
      clinicId: 'clinic-a',
      entry: _entry(id: 'audit-a'),
      prevHash: '',
    );
    await mirror.write(
      clinicId: 'clinic-b',
      entry: _entry(id: 'audit-b'),
      prevHash: '',
    );

    final aDocs = await db
        .collection('clinic_audit_logs')
        .doc('clinic-a')
        .collection('entries')
        .get();
    final bDocs = await db
        .collection('clinic_audit_logs')
        .doc('clinic-b')
        .collection('entries')
        .get();
    expect(aDocs.docs, hasLength(1));
    expect(bDocs.docs, hasLength(1));
    expect(aDocs.docs.single.id, 'audit-a');
    expect(bDocs.docs.single.id, 'audit-b');
  });
}
