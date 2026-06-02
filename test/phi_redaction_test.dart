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
      final r = PhiRedactor(patientNames: ['John Demo', 'Jane Sample']).scrub(
        'John Demo arrived 5 min late. jane sample sent the form.',
      );
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
  });
}
