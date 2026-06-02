import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';

ConsentEntry _entry({
  String id = 'ce-1',
  String patientId = 'p-1',
  ConsentKind kind = ConsentKind.aiProcessing,
}) =>
    ConsentEntry(
      id: id,
      patientId: patientId,
      kind: kind,
      policyVersion: '2026-06',
      signature: 'typed:John Demo',
    );

void main() {
  group('ConsentEntry', () {
    test('rejects empty policyVersion / signature at construction', () {
      expect(
        () => ConsentEntry(
          id: 'e',
          patientId: 'p',
          kind: ConsentKind.aiProcessing,
          policyVersion: '',
          signature: 'sig',
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => ConsentEntry(
          id: 'e',
          patientId: 'p',
          kind: ConsentKind.aiProcessing,
          policyVersion: '2026',
          signature: '  ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('isActive flips to false on revoke', () {
      final e = _entry();
      expect(e.isActive, isTrue);
      final r = e.revoke();
      expect(r.isActive, isFalse);
      expect(r.revokedAt, isNotNull);
    });

    test('double revoke throws StateError', () {
      final revoked = _entry().revoke();
      expect(() => revoked.revoke(), throwsA(isA<StateError>()));
    });

    test('JSON round-trip preserves revoke trail', () {
      final entry = _entry().revoke(at: DateTime.utc(2026, 6, 10));
      final round = ConsentEntry.fromJson(entry.toJson());
      expect(round.kind, ConsentKind.aiProcessing);
      expect(round.policyVersion, '2026-06');
      expect(round.revokedAt, DateTime.utc(2026, 6, 10));
    });

    test('ConsentKind.fromId falls back to gdprProcessing', () {
      expect(ConsentKind.fromId(null), ConsentKind.gdprProcessing);
      expect(ConsentKind.fromId('garbage'), ConsentKind.gdprProcessing);
      expect(ConsentKind.fromId('ai_processing'), ConsentKind.aiProcessing);
    });

    test('revokeEffect surfaces the downstream consequence', () {
      expect(ConsentKind.aiProcessing.revokeEffect, contains('AI'));
      expect(ConsentKind.audioRecording.revokeEffect, contains('record'));
      expect(ConsentKind.telehealth.revokeEffect, contains('telehealth'));
      expect(ConsentKind.hipaaNopp.revokeEffect, contains('DPO'));
    });
  });

  group('InMemoryConsentEntryRepository', () {
    setUp(() {
      InMemoryConsentEntryRepository.instance.clearForTesting();
    });

    test('record + activeOf return the same row', () {
      final repo = InMemoryConsentEntryRepository.instance;
      final e = repo.record(_entry());
      expect(repo.activeOf('p-1', ConsentKind.aiProcessing)?.id, e.id);
    });

    test('a new active row of the same kind revokes the previous', () {
      final repo = InMemoryConsentEntryRepository.instance;
      final first = repo.record(_entry(id: 'ce-1'));
      final second = repo.record(_entry(id: 'ce-2'));
      expect(repo.activeOf('p-1', ConsentKind.aiProcessing)?.id,
          second.id);
      final firstRows = repo
          .forPatient('p-1')
          .where((e) => e.id == first.id)
          .toList();
      expect(firstRows.single.isActive, isFalse);
    });

    test('revoke flips an existing entry to inactive', () {
      final repo = InMemoryConsentEntryRepository.instance;
      final e = repo.record(_entry());
      repo.revoke(e.id);
      expect(
        repo.activeOf('p-1', ConsentKind.aiProcessing),
        isNull,
      );
    });

    test('revoke unknown id throws StateError', () {
      expect(
        () => InMemoryConsentEntryRepository.instance.revoke('nope'),
        throwsA(isA<StateError>()),
      );
    });

    test('forPatient scopes correctly across patients', () {
      final repo = InMemoryConsentEntryRepository.instance;
      repo.record(_entry(id: 'a', patientId: 'p-1'));
      repo.record(_entry(id: 'b', patientId: 'p-2'));
      expect(repo.forPatient('p-1'), hasLength(1));
      expect(repo.forPatient('p-2'), hasLength(1));
      expect(repo.forPatient('p-3'), isEmpty);
    });
  });
}
