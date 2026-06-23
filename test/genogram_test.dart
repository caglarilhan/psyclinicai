/// Coverage for the genogram model + repository. JSON round-trip
/// across people / relationships, attribute frequency, per-patient
/// lookup, corrupt-record drop.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/genogram.dart';
import 'package:psyclinicai/services/data/genogram_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Genogram model', () {
    test('round-trips people + relationships through JSON', () {
      final g = Genogram(
        id: 'g1',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23, 10),
        people: const [
          GenogramPerson(
            id: 'self',
            label: 'Ali',
            sex: GenogramSex.male,
            birthYear: 1990,
            isIndexPatient: true,
            attributes: [GenogramAttribute.anxiety],
          ),
          GenogramPerson(
            id: 'father',
            label: 'Father',
            sex: GenogramSex.male,
            birthYear: 1962,
            deathYear: 2019,
            attributes: [
              GenogramAttribute.depression,
              GenogramAttribute.alcoholMisuse,
            ],
          ),
          GenogramPerson(
            id: 'mother',
            label: 'Mother',
            sex: GenogramSex.female,
            birthYear: 1964,
            attributes: [GenogramAttribute.anxiety],
          ),
        ],
        relationships: const [
          GenogramRelationship(
            fromPersonId: 'father',
            toPersonId: 'mother',
            kind: GenogramRelationshipKind.marriage,
          ),
          GenogramRelationship(
            fromPersonId: 'father',
            toPersonId: 'self',
            kind: GenogramRelationshipKind.parentChild,
          ),
          GenogramRelationship(
            fromPersonId: 'mother',
            toPersonId: 'self',
            kind: GenogramRelationshipKind.parentChild,
          ),
        ],
        clinicianNotes: 'Two generations of anxiety, alcohol on paternal side.',
      );
      final back = Genogram.fromJson(g.toJson());
      expect(back.people, hasLength(3));
      expect(back.indexPatient?.label, 'Ali');
      expect(back.relationships, hasLength(3));
      // Deceased on the father node should survive round-trip.
      final father = back.people.firstWhere((p) => p.id == 'father');
      expect(father.isDeceased, isTrue);
      expect(father.deathYear, 2019);
      expect(
        father.attributes,
        containsAll([
          GenogramAttribute.depression,
          GenogramAttribute.alcoholMisuse,
        ]),
      );
    });

    test('attributeFrequency counts members with the flag', () {
      final g = Genogram(
        id: 'g2',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23),
        people: const [
          GenogramPerson(
            id: 'a',
            label: 'A',
            attributes: [GenogramAttribute.anxiety],
          ),
          GenogramPerson(
            id: 'b',
            label: 'B',
            attributes: [
              GenogramAttribute.anxiety,
              GenogramAttribute.depression,
            ],
          ),
          GenogramPerson(id: 'c', label: 'C'),
        ],
      );
      expect(g.attributeFrequency(GenogramAttribute.anxiety), 2);
      expect(g.attributeFrequency(GenogramAttribute.depression), 1);
      expect(g.attributeFrequency(GenogramAttribute.bipolar), 0);
    });

    test('relationshipsFor returns both inbound + outbound edges', () {
      final g = Genogram(
        id: 'g3',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23),
        relationships: const [
          GenogramRelationship(
            fromPersonId: 'self',
            toPersonId: 'father',
            kind: GenogramRelationshipKind.parentChild,
          ),
          GenogramRelationship(
            fromPersonId: 'mother',
            toPersonId: 'self',
            kind: GenogramRelationshipKind.parentChild,
          ),
          GenogramRelationship(
            fromPersonId: 'father',
            toPersonId: 'mother',
            kind: GenogramRelationshipKind.marriage,
          ),
        ],
      );
      expect(g.relationshipsFor('self'), hasLength(2));
      expect(g.relationshipsFor('father'), hasLength(2));
    });

    test('indexPatient returns null when no member is flagged', () {
      final g = Genogram(
        id: 'g4',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23),
        people: const [GenogramPerson(id: 'a', label: 'A')],
      );
      expect(g.indexPatient, isNull);
    });

    test('GenogramAttribute enum has 15 stable items', () {
      // Locking the contract so dashboards can chart by frequency.
      expect(GenogramAttribute.values, hasLength(15));
      expect(
        GenogramAttribute.fromId('substance_misuse'),
        GenogramAttribute.substanceMisuse,
      );
      expect(GenogramAttribute.fromId('bogus'), isNull);
    });
  });

  group('GenogramRepository', () {
    test('upsert + forPatient round-trip', () async {
      final repo = GenogramRepository(storageKey: 'geno_rt');
      await repo.initialize();
      final g = Genogram(
        id: 'g1',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23),
        people: const [
          GenogramPerson(id: 'self', label: 'Ali', isIndexPatient: true),
        ],
      );
      final saved = await repo.upsert(g);
      expect(saved.updatedAt, isNotNull);
      final fresh = GenogramRepository(storageKey: 'geno_rt');
      await fresh.initialize();
      final back = fresh.forPatient('p1');
      expect(back, isNotNull);
      expect(back!.indexPatient?.label, 'Ali');
    });

    test('upsert replaces the patient row (one row per patient)', () async {
      final repo = GenogramRepository(storageKey: 'geno_idem');
      await repo.initialize();
      await repo.upsert(
        Genogram(
          id: 'g1',
          patientId: 'p1',
          clinicianId: 'c1',
          createdAt: DateTime.utc(2026, 6, 20),
          people: const [GenogramPerson(id: 'a', label: 'A')],
        ),
      );
      await repo.upsert(
        Genogram(
          id: 'g1',
          patientId: 'p1',
          clinicianId: 'c1',
          createdAt: DateTime.utc(2026, 6, 20),
          people: const [
            GenogramPerson(id: 'a', label: 'A'),
            GenogramPerson(id: 'b', label: 'B'),
          ],
        ),
      );
      final back = repo.forPatient('p1')!;
      expect(back.people, hasLength(2));
    });

    test('initialize drops a corrupt record but loads the valid one', () async {
      SharedPreferences.setMockInitialValues({
        'geno_corrupt': <String>[
          '{"id":"good","patientId":"good","clinicianId":"c","createdAt":"2026-06-23T10:00:00Z","people":[],"relationships":[]}',
          'not valid json',
        ],
      });
      final repo = GenogramRepository(storageKey: 'geno_corrupt');
      await repo.initialize();
      expect(repo.forPatient('good'), isNotNull);
    });
  });
}
