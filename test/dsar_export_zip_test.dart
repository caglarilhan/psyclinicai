import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/dsar_export.dart';
import 'package:psyclinicai/utils/dsar_export_zip.dart';

void main() {
  final now = DateTime.utc(2026, 6, 2, 12);

  group('buildPatientExportZip', () {
    test('returns null for an effectively-empty bundle', () {
      // A truly empty Map is below the 30-byte floor.
      expect(
        buildPatientExportZip(
          patientId: 'p',
          bundle: const {},
          generatedAt: now,
        ),
        isNull,
      );
    });

    test('real (small) bundle still produces bytes', () {
      final bundle = buildPatientExport(patientId: 'p1', generatedAt: now);
      final bytes = buildPatientExportZip(
        patientId: 'p1',
        bundle: bundle,
        generatedAt: now,
      );
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(0));
    });

    test('zip contains patient-export.json + README.txt', () {
      final bundle = buildPatientExport(patientId: 'p1', generatedAt: now);
      final bytes = buildPatientExportZip(
        patientId: 'p1',
        bundle: bundle,
        generatedAt: now,
      )!;
      final archive = ZipDecoder().decodeBytes(bytes);
      final names = archive.map((f) => f.name).toSet();
      expect(names, containsAll(['patient-export.json', 'README.txt']));
    });

    test('JSON entry round-trips back to the original bundle', () {
      final bundle = buildPatientExport(patientId: 'p1', generatedAt: now);
      final bytes = buildPatientExportZip(
        patientId: 'p1',
        bundle: bundle,
        generatedAt: now,
      )!;
      final archive = ZipDecoder().decodeBytes(bytes);
      final jsonFile = archive.findFile('patient-export.json')!;
      final decoded =
          jsonDecode(utf8.decode(jsonFile.content as List<int>))
              as Map<String, dynamic>;
      expect(decoded['patient_id'], bundle['patient_id']);
      expect(decoded['schema_version'], bundle['schema_version']);
    });

    test('README names patient id and a UTC timestamp', () {
      final bundle = buildPatientExport(patientId: 'p1', generatedAt: now);
      final bytes = buildPatientExportZip(
        patientId: 'p1',
        bundle: bundle,
        generatedAt: now,
      )!;
      final archive = ZipDecoder().decodeBytes(bytes);
      final readme = utf8.decode(
        archive.findFile('README.txt')!.content as List<int>,
      );
      expect(readme, contains('p1'));
      expect(readme, contains('2026-06-02T12:00:00.000Z'));
      expect(readme, contains('GDPR Articles 15'));
      expect(
        readme,
        contains('NOT password-protected'),
        reason: 'README must surface the encryption scope honestly',
      );
    });
  });

  group('buildExportFileName', () {
    test('uses zero-padded YYYYMMDD', () {
      final n = buildExportFileName('demo-1', DateTime.utc(2026, 1, 9));
      expect(n, 'psyclinicai-export-demo-1-20260109.zip');
    });

    test('embeds the patient id verbatim', () {
      final n = buildExportFileName('p-42', DateTime.utc(2026, 12, 31));
      expect(n, 'psyclinicai-export-p-42-20261231.zip');
    });
  });
}
