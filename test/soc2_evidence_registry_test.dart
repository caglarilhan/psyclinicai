import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/soc2_evidence_registry.dart';

void main() {
  group('Soc2EvidenceRegistry invariants', () {
    test('every control has the cells the auditor expects', () {
      for (final c in Soc2EvidenceRegistry.controls) {
        expect(c.criterion, isNotEmpty,
            reason: '${c.title}: missing criterion');
        expect(c.category, isNotEmpty);
        expect(c.title, isNotEmpty);
        expect(c.evidence, isNotEmpty,
            reason: '${c.criterion}: missing evidence link');
        expect(c.lastReviewed, matches(RegExp(r'^\d{4}-\d{2}$')),
            reason: '${c.criterion}: lastReviewed must be YYYY-MM');
      }
    });

    test('criteria are unique', () {
      final ids = Soc2EvidenceRegistry.controls
          .map((c) => c.criterion)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('implementedControls excludes partial / planned rows', () {
      for (final c in Soc2EvidenceRegistry.implementedControls) {
        expect(c.status, Soc2Status.implemented);
      }
    });

    test('gaps surfaces every non-implemented row', () {
      for (final c in Soc2EvidenceRegistry.gaps) {
        expect(c.status, isNot(Soc2Status.implemented));
      }
    });

    test('byCriterion returns the matching control or null', () {
      expect(Soc2EvidenceRegistry.byCriterion('CC6.1'), isNotNull);
      expect(Soc2EvidenceRegistry.byCriterion('nope'), isNull);
    });

    test('observationOpensAt parses as a date', () {
      expect(
        DateTime.tryParse(Soc2EvidenceRegistry.observationOpensAt),
        isNotNull,
      );
    });
  });
}
