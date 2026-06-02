import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/ropa_registry.dart';

void main() {
  group('RopaRegistry invariants', () {
    test('every activity has the cells Art. 30 requires', () {
      for (final a in RopaRegistry.activities) {
        expect(a.id, isNotEmpty, reason: '${a.id} missing id');
        expect(a.purpose, isNotEmpty,
            reason: '${a.id} missing purpose');
        expect(a.dataCategories, isNotEmpty,
            reason: '${a.id} missing data categories');
        expect(a.dataSubjects, isNotEmpty,
            reason: '${a.id} missing data subjects');
        expect(a.lawfulBasis, isNotEmpty,
            reason: '${a.id} missing lawful basis');
        expect(a.retention, isNotEmpty,
            reason: '${a.id} missing retention');
        expect(a.recipients, isNotEmpty,
            reason: '${a.id} missing recipients');
        expect(a.securityMeasures, isNotEmpty,
            reason: '${a.id} missing security measures');
      }
    });

    test('ids are unique', () {
      final ids = RopaRegistry.activities.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('crossBorder surfaces only activities with a transfer mechanism',
        () {
      for (final a in RopaRegistry.crossBorder) {
        expect(a.transferMechanism, isNotEmpty);
      }
      final ids = RopaRegistry.crossBorder.map((a) => a.id);
      expect(ids, contains('ai-assistance'));
    });

    test('specialCategory matches Art. 9 references', () {
      final ids =
          RopaRegistry.specialCategory.map((a) => a.id).toSet();
      expect(ids, contains('clinical-record-keeping'));
      expect(ids, contains('ai-assistance'));
    });

    test('byId returns the matching row, null otherwise', () {
      expect(RopaRegistry.byId('audit-logging'), isNotNull);
      expect(RopaRegistry.byId('nope'), isNull);
    });

    test('lastReviewed parses as an ISO date', () {
      expect(
        DateTime.tryParse(RopaRegistry.lastReviewed),
        isNotNull,
      );
    });

    test('dpoContact is a deliverable email address', () {
      expect(RopaRegistry.dpoContact, contains('@'));
    });

    test('cross-border activities carry structured recipient rows', () {
      for (final a in RopaRegistry.crossBorder) {
        expect(a.crossBorderRecipients, isNotEmpty,
            reason:
                '${a.id} declares a transferMechanism but has no '
                'structured cross-border recipient — auditor cannot '
                'verify the destination country / instrument.');
        for (final r in a.crossBorderRecipients) {
          expect(r.country, isNotEmpty);
          expect(r.instrument, isNotEmpty);
          expect(r.tiaReference, isNotEmpty,
              reason: '${a.id}: ${r.name} missing TIA reference');
        }
      }
    });

    test('AI assistance has a DPIA reference (Art. 35)', () {
      final ai = RopaRegistry.byId('ai-assistance');
      expect(ai, isNotNull);
      expect(ai!.dpiaReference, isNotNull);
      expect(ai.dpiaReference, isNotEmpty);
    });
  });
}
