/// AS1 parity test.
///
/// Source of truth = `lib/services/ai_scribe/soap_section_catalog.dart`.
/// Server mirror     = `functions/src/lib/soap_section_catalog.ts`.
///
/// Tests assert that every section title, every field key, every
/// field required flag and every regulatory anchor is present
/// verbatim in the TS file. Add/rename on one side, the other side
/// is forced to follow or this test fails.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai_scribe/soap_section_catalog.dart';

void main() {
  group('AS1 parity — Dart SOAP catalog ↔ TS soap_section_catalog', () {
    final tsFile = File('functions/src/lib/soap_section_catalog.ts');

    test('TS mirror file exists', () {
      expect(tsFile.existsSync(), isTrue);
    });

    test('every section title appears verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final spec in SoapSectionCatalog.sections) {
        expect(
          ts.contains('title: "${spec.title}"'),
          isTrue,
          reason: '${spec.title}: missing in TS mirror — drift',
        );
      }
    });

    test('every section name appears as TS section literal', () {
      final ts = tsFile.readAsStringSync();
      for (final spec in SoapSectionCatalog.sections) {
        expect(
          ts.contains('section: "${spec.section.name}"'),
          isTrue,
          reason: '${spec.section.name}: missing section literal in TS',
        );
      }
    });

    test('every field key appears verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final spec in SoapSectionCatalog.sections) {
        for (final f in spec.fields) {
          expect(
            ts.contains('key: "${f.key}"'),
            isTrue,
            reason:
                '${spec.title}.${f.key}: field key missing in TS — drift',
          );
        }
      }
    });

    test('schema version matches between Dart + TS', () {
      final ts = tsFile.readAsStringSync();
      expect(
        ts.contains(
            'SOAP_SCHEMA_VERSION = ${SoapSectionCatalog.schemaVersion}'),
        isTrue,
        reason:
            'schemaVersion drift: Dart=${SoapSectionCatalog.schemaVersion}',
      );
    });

    test('lastReviewed matches between Dart + TS', () {
      final ts = tsFile.readAsStringSync();
      expect(
        ts.contains(
            'SOAP_LAST_REVIEWED = "${SoapSectionCatalog.lastReviewed}"'),
        isTrue,
        reason: 'lastReviewed drift',
      );
    });

    test('every regulatory anchor is present verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final spec in SoapSectionCatalog.sections) {
        for (final ref in spec.regulatoryRefs) {
          expect(
            ts.contains(ref),
            isTrue,
            reason:
                '${spec.title}: regulatory anchor "$ref" missing in TS — drift',
          );
        }
      }
    });
  });
}
