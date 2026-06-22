import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/phi_redaction.dart';

void main() {
  group('PhiRedactor', () {
    test('emails are masked + counted', () {
      final r = PhiRedactor().scrub(
        'Contact patient at jane.doe@example.com or admin+x@clinic.de.',
      );
      expect(r.cleanText, contains('[EMAIL]'));
      expect(r.cleanText, isNot(contains('jane.doe@example.com')));
      expect(r.removed['email'], 2);
    });

    test('phone numbers (E.164 + US) are masked', () {
      final r = PhiRedactor().scrub(
        'Call +905551112233 or 415-555-0142 or (415) 555 0142',
      );
      expect(r.cleanText, contains('[PHONE]'));
      expect(r.removed['phone_e164'], 1);
      expect(r.removed['phone_us'], greaterThanOrEqualTo(2));
    });

    test('ISO + US + DE dates are masked', () {
      final r = PhiRedactor().scrub(
        'DOB 1989-05-14, last seen 05/14/2024 and 14.05.2024',
      );
      expect(r.cleanText, contains('[DATE]'));
      expect(r.removed['date_iso'], 1);
      expect(r.removed['date_us'], 1);
      expect(r.removed['date_de'], 1);
    });

    test('MRN + SSN + KVNR identifiers are masked', () {
      final r = PhiRedactor().scrub(
        'Patient #PSY-123, MRN: BCBS-99, SSN 123-45-6789, KVNR A123456789',
      );
      expect(r.cleanText, contains('[MRN]'));
      expect(r.cleanText, contains('[SSN]'));
      expect(r.cleanText, contains('[KVNR]'));
    });

    test('patient name list redacts case-insensitively', () {
      final r = PhiRedactor(
        patientNames: ['John Demo', 'Jane Sample'],
      ).scrub('John Demo arrived 5 min late. jane sample sent the form.');
      expect(r.cleanText, contains('[NAME]'));
      expect(r.cleanText, isNot(contains('John Demo')));
      expect(r.cleanText, isNot(contains('jane sample')));
      expect(r.removed['name'], 2);
    });

    test('clean text returns zero counts', () {
      final r = PhiRedactor().scrub('No identifiers here.');
      expect(r.cleanText, 'No identifiers here.');
      expect(r.totalRemoved, 0);
    });

    // M-9 fix coverage — Luhn-validated NPI detection.
    group('NPI Luhn validation (M-9)', () {
      test('valid NPI is masked', () {
        // 1234567893 is a documented NPPES sample (passes Luhn with
        // the 80840 prefix). Counter records the hit.
        final r = PhiRedactor().scrub('Provider NPI 1234567893 signed.');
        expect(r.cleanText, contains('[NPI]'));
        expect(r.removed['npi'], 1);
      });

      test('random 10-digit numbers are NOT masked', () {
        // Plain study/member id 1111111111 fails Luhn → text stays.
        final r = PhiRedactor().scrub('Study code 1111111111 noted.');
        expect(r.cleanText, contains('1111111111'));
        expect(r.removed['npi'], isNull);
      });
    });

    // M-6 fix coverage — date shifting for limited-dataset compliance.
    group('Date handling (M-6)', () {
      test('default redactor still tokenises dates to [DATE]', () {
        final r = PhiRedactor().scrub('Last visit 2026-06-21.');
        expect(r.cleanText, contains('[DATE]'));
        expect(r.cleanText, isNot(contains('2026-06-21')));
      });

      test('dateShift preserves relative offsets between ISO dates', () {
        final r = PhiRedactor(
          dateShift: const Duration(days: 30),
        ).scrub('Symptom onset 2026-06-01, follow-up 2026-06-15.');
        // Both dates shift by exactly +30d so the gap stays 14 days.
        expect(r.cleanText, contains('2026-07-01'));
        expect(r.cleanText, contains('2026-07-15'));
        expect(r.cleanText, isNot(contains('[DATE]')));
      });

      test('US date format round-trips through the shifter', () {
        final r = PhiRedactor(
          dateShift: const Duration(days: 7),
        ).scrub('Booked 05/14/2024 for review.');
        expect(r.cleanText, contains('5/21/2024'));
      });

      test('DE date format round-trips through the shifter', () {
        final r = PhiRedactor(
          dateShift: const Duration(days: -3),
        ).scrub('Termin am 14.05.2024.');
        expect(r.cleanText, contains('11.5.2024'));
      });

      test('counter still records every shifted date for telemetry', () {
        final r = PhiRedactor(
          dateShift: const Duration(days: 1),
        ).scrub('2026-06-01 and 2026-06-15 and 05/14/2024');
        expect(r.removed['date_iso'], 2);
        expect(r.removed['date_us'], 1);
      });
    });
  });
}
