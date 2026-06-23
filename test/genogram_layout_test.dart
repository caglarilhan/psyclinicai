/// Coverage for the genogram layout engine — generation assignment
/// across parent-child edges + same-generation sibling/marriage
/// edges, deterministic ordering within a row, and the bounding-box
/// computation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/genogram.dart';
import 'package:psyclinicai/widgets/genogram/genogram_layout.dart';

Genogram _g({
  List<GenogramPerson> people = const [],
  List<GenogramRelationship> rels = const [],
}) => Genogram(
  id: 'g1',
  patientId: 'p1',
  clinicianId: 'c1',
  createdAt: DateTime.utc(2026, 6, 23),
  people: people,
  relationships: rels,
);

void main() {
  group('GenogramLayoutEngine', () {
    test('empty genogram produces empty layout with zero size', () {
      final layout = GenogramLayoutEngine().compute(_g());
      expect(layout.nodes, isEmpty);
      expect(layout.size.width, 0);
      expect(layout.size.height, 0);
    });

    test('parent-child edge places parent above index patient', () {
      final layout = GenogramLayoutEngine().compute(
        _g(
          people: const [
            GenogramPerson(id: 'self', label: 'Self', isIndexPatient: true),
            GenogramPerson(id: 'mom', label: 'Mom'),
          ],
          rels: const [
            GenogramRelationship(
              fromPersonId: 'mom',
              toPersonId: 'self',
              kind: GenogramRelationshipKind.parentChild,
            ),
          ],
        ),
      );
      final self = layout.nodeFor('self')!;
      final mom = layout.nodeFor('mom')!;
      expect(self.generation, 0);
      expect(mom.generation, -1);
      expect(mom.y, lessThan(self.y));
    });

    test('siblings share the index-patient row', () {
      final layout = GenogramLayoutEngine().compute(
        _g(
          people: const [
            GenogramPerson(id: 'self', label: 'Self', isIndexPatient: true),
            GenogramPerson(id: 'sib', label: 'Sibling'),
          ],
          rels: const [
            GenogramRelationship(
              fromPersonId: 'self',
              toPersonId: 'sib',
              kind: GenogramRelationshipKind.sibling,
            ),
          ],
        ),
      );
      expect(layout.nodeFor('self')!.generation, 0);
      expect(layout.nodeFor('sib')!.generation, 0);
      expect(layout.nodeFor('self')!.y, layout.nodeFor('sib')!.y);
    });

    test('marriage edge keeps both partners on the same row', () {
      final layout = GenogramLayoutEngine().compute(
        _g(
          people: const [
            GenogramPerson(id: 'a', label: 'A', isIndexPatient: true),
            GenogramPerson(id: 'b', label: 'B'),
          ],
          rels: const [
            GenogramRelationship(
              fromPersonId: 'a',
              toPersonId: 'b',
              kind: GenogramRelationshipKind.marriage,
            ),
          ],
        ),
      );
      expect(layout.nodeFor('a')!.y, layout.nodeFor('b')!.y);
    });

    test('row ordering uses birthYear when present', () {
      final layout = GenogramLayoutEngine().compute(
        _g(
          people: const [
            GenogramPerson(
              id: 'younger',
              label: 'Y',
              birthYear: 2010,
              isIndexPatient: true,
            ),
            GenogramPerson(id: 'older', label: 'O', birthYear: 2005),
          ],
          rels: const [
            GenogramRelationship(
              fromPersonId: 'younger',
              toPersonId: 'older',
              kind: GenogramRelationshipKind.sibling,
            ),
          ],
        ),
      );
      expect(
        layout.nodeFor('older')!.x,
        lessThan(layout.nodeFor('younger')!.x),
      );
    });

    test('orphan person without edges lands on the index row by default', () {
      final layout = GenogramLayoutEngine().compute(
        _g(
          people: const [
            GenogramPerson(id: 'self', label: 'Self', isIndexPatient: true),
            GenogramPerson(id: 'orphan', label: 'Orphan'),
          ],
        ),
      );
      expect(layout.nodeFor('orphan')!.generation, 0);
    });

    test('three generations get distinct y coordinates', () {
      final layout = GenogramLayoutEngine().compute(
        _g(
          people: const [
            GenogramPerson(id: 'grand', label: 'Grand'),
            GenogramPerson(id: 'mom', label: 'Mom'),
            GenogramPerson(id: 'self', label: 'Self', isIndexPatient: true),
          ],
          rels: const [
            GenogramRelationship(
              fromPersonId: 'grand',
              toPersonId: 'mom',
              kind: GenogramRelationshipKind.parentChild,
            ),
            GenogramRelationship(
              fromPersonId: 'mom',
              toPersonId: 'self',
              kind: GenogramRelationshipKind.parentChild,
            ),
          ],
        ),
      );
      final grand = layout.nodeFor('grand')!;
      final mom = layout.nodeFor('mom')!;
      final self = layout.nodeFor('self')!;
      expect(grand.generation, -2);
      expect(mom.generation, -1);
      expect(self.generation, 0);
      expect(grand.y, lessThan(mom.y));
      expect(mom.y, lessThan(self.y));
    });
  });
}
