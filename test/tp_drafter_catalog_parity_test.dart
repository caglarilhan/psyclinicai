/// TPD1 parity test.
///
/// Source of truth = `lib/services/treatment_plan_drafter/tp_drafter_catalog.dart`.
/// Server mirror     = `functions/src/lib/tp_drafter_catalog.ts`.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/treatment_plan_drafter/tp_drafter_catalog.dart';

void main() {
  group('TPD1 parity — Dart catalog ↔ TS tp_drafter_catalog', () {
    final tsFile = File('functions/src/lib/tp_drafter_catalog.ts');

    test('TS mirror exists', () {
      expect(tsFile.existsSync(), isTrue);
    });

    test('every disorder enum name appears verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in TpDrafterCatalog.protocols) {
        expect(ts.contains('"${p.disorder.name}"'), isTrue,
            reason: '${p.disorder.name}: missing in TS');
      }
    });

    test('every modality enum name appears verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in TpDrafterCatalog.protocols) {
        expect(ts.contains('"${p.modality.name}"'), isTrue,
            reason: '${p.modality.name}: missing in TS');
      }
    });

    test('every label byte-equivalent in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in TpDrafterCatalog.protocols) {
        expect(ts.contains(p.label), isTrue,
            reason: '${p.label}: drift');
      }
    });

    test('recommendedSessions byte-equivalent in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in TpDrafterCatalog.protocols) {
        expect(
          ts.contains('recommendedSessions: ${p.recommendedSessions}'),
          isTrue,
          reason: '${p.label}: recommendedSessions drift',
        );
      }
    });

    test('every guideline anchor present in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in TpDrafterCatalog.protocols) {
        for (final a in p.guidelineAnchors) {
          expect(ts.contains(a), isTrue,
              reason: '${p.label}: anchor "$a" missing in TS');
        }
      }
    });

    test('requiresSupervisorCoSign byte-equivalent in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in TpDrafterCatalog.protocols) {
        expect(
          ts.contains(
              'requiresSupervisorCoSign: ${p.requiresSupervisorCoSign}'),
          isTrue,
          reason: '${p.label}: co-sign flag drift',
        );
      }
    });

    test('schemaVersion + lastReviewed pinned in TS', () {
      final ts = tsFile.readAsStringSync();
      expect(
        ts.contains(
            'TPD_SCHEMA_VERSION = ${TpDrafterCatalog.schemaVersion}'),
        isTrue,
      );
      expect(
        ts.contains(
            'TPD_LAST_REVIEWED = "${TpDrafterCatalog.lastReviewed}"'),
        isTrue,
      );
    });

    test('smartGoalFields + outputSections verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final f in TpDrafterCatalog.smartGoalFields) {
        expect(ts.contains('"$f"'), isTrue,
            reason: 'smart goal field "$f" missing in TS');
      }
      for (final s in TpDrafterCatalog.outputSections) {
        expect(ts.contains('"$s"'), isTrue,
            reason: 'output section "$s" missing in TS');
      }
    });
  });
}
