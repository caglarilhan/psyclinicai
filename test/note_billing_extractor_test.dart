import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/billing/note_billing_extractor.dart';

void main() {
  const x = NoteBillingExtractor();
  // Pretend only these codes exist in the lookup.
  bool known(String c) => const {'F41.1', 'F32.1', 'F43.10'}.contains(c);

  group('extractIcd10', () {
    test('keeps documented, known codes in order, de-duplicated', () {
      const note =
          'Assessment: GAD (F41.1) with comorbid MDD, recurrent (F32.1). '
          'Re-confirmed F41.1 in session.';
      expect(x.extractIcd10(note, isKnown: known), ['F41.1', 'F32.1']);
    });

    test('drops codes not in the lookup (no autocoding)', () {
      const note = 'Possible F99.0 and Z99.9 noted but F43.10 confirmed.';
      expect(x.extractIcd10(note, isKnown: known), ['F43.10']);
    });

    test('returns empty when nothing matches', () {
      expect(x.extractIcd10('No codes here.', isKnown: known), isEmpty);
    });
  });

  group('suggestCpt', () {
    test('an explicit CPT in the note wins', () {
      expect(x.suggestCpt('Provided 90837 psychotherapy.'), '90837');
    });

    test('infers from documented session length', () {
      expect(x.suggestCpt('Session lasted 55 minutes.'), '90837');
      expect(x.suggestCpt('45 minute therapy session.'), '90834');
      expect(x.suggestCpt('Brief 20 min check-in.'), '90832');
    });

    test('defaults to 90834 when no length is documented', () {
      expect(x.suggestCpt('Supportive psychotherapy.'), '90834');
    });

    test('psychiatry uses E&M codes', () {
      expect(x.suggestCpt('Med review.', isPsychiatry: true), '99213');
      expect(
        x.suggestCpt('30 minute med management.', isPsychiatry: true),
        '99214',
      );
    });
  });

  test('fromNote assembles a prefill', () {
    const note = 'Dx F41.1. 50 minute individual psychotherapy.';
    final p = x.fromNote(note, isKnownIcd: known, patientName: 'Jane Doe');
    expect(p.patientName, 'Jane Doe');
    expect(p.icd10Codes, ['F41.1']);
    expect(p.cptCode, '90834');
    expect(p.isEmpty, isFalse);
  });
}
