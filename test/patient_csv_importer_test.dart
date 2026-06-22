import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/patient_csv_importer.dart';

void main() {
  group('PatientCsvImporter', () {
    final imp = PatientCsvImporter();

    test('parses headers + rows; lowercases headers', () {
      final r = imp.parse('Name,DOB,Insurer\nJohn Demo,1989-05-14,BCBS\n');
      expect(r.headers, ['name', 'dob', 'insurer']);
      expect(r.rows.length, 1);
      expect(r.rows.first.values['name'], 'John Demo');
      expect(r.rows.first.isValid, isTrue);
    });

    test('accepts CRLF + tolerates trailing newline', () {
      final r = imp.parse(
        'name,dob\r\nJane Sample,1990-01-02\r\nSven P.,1985-11-11\r\n',
      );
      expect(r.rows.length, 2);
    });

    test('flags missing required column', () {
      final r = imp.parse('name,dob\nNo DOB,\n');
      expect(r.errorRowCount, 1);
      expect(r.rows.first.errors.first, contains('dob'));
    });

    test('flags malformed DOB', () {
      final r = imp.parse('name,dob\nMr Bad,5/14/1989\n');
      expect(r.errorRowCount, 1);
      expect(r.rows.first.errors.first, contains('YYYY-MM-DD'));
    });

    test('accepts DD.MM.YYYY DOB (EU)', () {
      final r = imp.parse('name,dob\nFrau Demo,14.05.1989\n');
      expect(r.errorRowCount, 0);
    });

    test('handles quoted values with commas', () {
      final r = imp.parse(
        'name,dob,notes\n"Smith, Jr.",1980-01-01,"Notes, more"\n',
      );
      expect(r.rows.first.values['name'], 'Smith, Jr.');
      expect(r.rows.first.values['notes'], 'Notes, more');
    });

    test('handles doubled-quote escape', () {
      final r = imp.parse('name,dob\n"O""Brien",1990-01-01\n');
      expect(r.rows.first.values['name'], 'O"Brien');
    });

    test('isClean true when zero errors + non-empty', () {
      final r = imp.parse('name,dob\nA,1980-01-01\n');
      expect(r.isClean, isTrue);
    });

    test('respects maxRows cap', () {
      final small = PatientCsvImporter(maxRows: 2);
      final body = List.generate(5, (i) => 'P$i,1980-01-01').join('\n');
      final r = small.parse('name,dob\n$body\n');
      expect(r.rows.length, 2);
    });
  });
}
