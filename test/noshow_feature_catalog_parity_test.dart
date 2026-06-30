/// NS1 parity test.
///
/// Source of truth = `lib/services/noshow/noshow_feature_catalog.dart`.
/// Server mirror     = `functions/src/lib/noshow_feature_catalog.ts`.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/noshow/noshow_feature_catalog.dart';

void main() {
  group('NS1 parity — Dart catalog ↔ TS noshow_feature_catalog', () {
    final tsFile = File('functions/src/lib/noshow_feature_catalog.ts');

    test('TS mirror exists', () {
      expect(tsFile.existsSync(), isTrue);
    });

    test('every feature key appears verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final f in NoShowFeatureCatalog.features) {
        expect(
          ts.contains('key: "${f.key}"'),
          isTrue,
          reason: '${f.key}: missing in TS mirror',
        );
      }
    });

    test('schemaVersion + lastReviewed pinned in TS', () {
      final ts = tsFile.readAsStringSync();
      expect(
        ts.contains(
          'NOSHOW_SCHEMA_VERSION = ${NoShowFeatureCatalog.schemaVersion}',
        ),
        isTrue,
      );
      expect(
        ts.contains(
          'NOSHOW_LAST_REVIEWED = "${NoShowFeatureCatalog.lastReviewed}"',
        ),
        isTrue,
      );
    });

    test('every playbook tier + depositRequired byte-equivalent in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in NoShowFeatureCatalog.playbooks) {
        expect(
          ts.contains('tier: "${p.tier.name}"'),
          isTrue,
          reason: '${p.tier}: missing tier literal in TS',
        );
        expect(
          ts.contains('depositRequired: ${p.depositRequired}'),
          isTrue,
          reason: '${p.tier}: depositRequired drift',
        );
      }
    });

    test('estUsdSavedPerSlot byte-equivalent in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final p in NoShowFeatureCatalog.playbooks) {
        expect(
          ts.contains('estUsdSavedPerSlot: ${p.estUsdSavedPerSlot}'),
          isTrue,
          reason: '${p.tier}: estUsdSavedPerSlot drift',
        );
      }
    });
  });
}
