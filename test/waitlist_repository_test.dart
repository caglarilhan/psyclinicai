import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/waitlist_repository.dart';

/// Minimal stub Firestore — captures every `.add()` call without
/// needing the Firebase emulator. We only assert on what the
/// repository writes; rules + indexes are exercised in the rules-test
/// suite.
class _StubFirestore implements FirebaseFirestore {
  _StubFirestore();
  final List<_Write> writes = <_Write>[];

  bool nextThrows = false;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _StubCollection(path, this);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _Write {
  _Write(this.collection, this.data);
  final String collection;
  final Map<String, Object?> data;
}

class _StubCollection implements CollectionReference<Map<String, dynamic>> {
  _StubCollection(this.path, this._owner);
  @override
  final String path;
  final _StubFirestore _owner;

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(
    Map<String, dynamic> data,
  ) async {
    if (_owner.nextThrows) throw StateError('rule denied');
    _owner.writes.add(_Write(path, data));
    return _StubDoc();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _StubDoc implements DocumentReference<Map<String, dynamic>> {
  @override
  String get id => 'stub';
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('WaitlistRepository.recordLanding', () {
    test('saves with normalised email + source + serverTimestamp', () async {
      final stub = _StubFirestore();
      final repo = WaitlistRepository(firestore: stub);
      final r = await repo.recordLanding(
        email: '  Clinician@Example.COM  ',
        source: 'hero',
      );
      expect(r, WaitlistOutcome.saved);
      expect(stub.writes, hasLength(1));
      expect(stub.writes.first.collection, 'landing_waitlist');
      expect(stub.writes.first.data['email'], 'clinician@example.com');
      expect(stub.writes.first.data['source'], 'hero');
      expect(stub.writes.first.data['createdAt'], isA<FieldValue>());
    });

    test('merges extra fields into the payload', () async {
      final stub = _StubFirestore();
      final repo = WaitlistRepository(firestore: stub);
      await repo.recordLanding(
        email: 'a@b.co',
        source: 'pricing',
        extra: {'tier': 'practice'},
      );
      expect(stub.writes.first.data['tier'], 'practice');
    });

    test('returns denied (not throws) when Firestore raises', () async {
      final stub = _StubFirestore()..nextThrows = true;
      final repo = WaitlistRepository(firestore: stub);
      final r = await repo.recordLanding(
        email: 'a@b.co',
        source: 'hero',
      );
      expect(r, WaitlistOutcome.denied);
      // Best-effort capture: NO row was written.
      expect(stub.writes, isEmpty);
    });

    test('returns skipped when no Firestore handle is available', () async {
      // Constructing without a firestore arg + PsyFirebase.isReady
      // is false in the test runner so the resolver returns null →
      // skipped.
      final repo = WaitlistRepository();
      final r = await repo.recordLanding(
        email: 'a@b.co',
        source: 'hero',
      );
      expect(r, WaitlistOutcome.skipped);
    });
  });

  group('WaitlistRepository.recordBetaSignup', () {
    test('writes to the beta_signups collection with extras', () async {
      final stub = _StubFirestore();
      final repo = WaitlistRepository(firestore: stub);
      final r = await repo.recordBetaSignup(
        email: 'beta@example.com',
        extra: {
          'clinic_name': 'Sample Clinic',
          'country': 'DE',
          'region': 'eu',
          'role': 'psychiatrist',
        },
      );
      expect(r, WaitlistOutcome.saved);
      expect(stub.writes.first.collection, 'beta_signups');
      expect(stub.writes.first.data['country'], 'DE');
      expect(stub.writes.first.data['role'], 'psychiatrist');
      expect(stub.writes.first.data['email'], 'beta@example.com');
    });
  });
}
