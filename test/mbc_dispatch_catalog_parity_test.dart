/// MBC1 parity test.
///
/// Source of truth = `lib/services/mbc/mbc_dispatch_catalog.dart`.
/// Server mirror     = `functions/src/lib/mbc_dispatch_catalog.ts`.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/mbc/mbc_dispatch_catalog.dart';

void main() {
  group('MBC1 parity — Dart catalog ↔ TS mbc_dispatch_catalog', () {
    final tsFile = File('functions/src/lib/mbc_dispatch_catalog.ts');

    test('TS mirror exists', () {
      expect(tsFile.existsSync(), isTrue);
    });

    test('every scaleId appears verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final r in MbcDispatchCatalog.rules) {
        expect(
          ts.contains('scaleId: "${r.scaleId}"'),
          isTrue,
          reason: '${r.scaleId}: missing in TS mirror — drift',
        );
      }
    });

    test('every intervalDays matches between Dart + TS', () {
      final ts = tsFile.readAsStringSync();
      for (final r in MbcDispatchCatalog.rules) {
        expect(
          ts.contains('intervalDays: ${r.intervalDays}'),
          isTrue,
          reason: '${r.scaleId}: intervalDays drift',
        );
      }
    });

    test('linkLifetimeHours + reminderAtHours present verbatim', () {
      final ts = tsFile.readAsStringSync();
      for (final r in MbcDispatchCatalog.rules) {
        expect(
          ts.contains('linkLifetimeHours: ${r.linkLifetimeHours}'),
          isTrue,
          reason: '${r.scaleId}: linkLifetimeHours drift',
        );
        expect(
          ts.contains('reminderAtHours: ${r.reminderAtHours}'),
          isTrue,
          reason: '${r.scaleId}: reminderAtHours drift',
        );
      }
    });

    test('payerCadenceLabel + maxItemsPerSession verbatim', () {
      final ts = tsFile.readAsStringSync();
      for (final r in MbcDispatchCatalog.rules) {
        expect(
          ts.contains('payerCadenceLabel: "${r.payerCadenceLabel}"'),
          isTrue,
          reason: '${r.scaleId}: payerCadenceLabel drift',
        );
        expect(
          ts.contains('maxItemsPerSession: ${r.maxItemsPerSession}'),
          isTrue,
          reason: '${r.scaleId}: maxItemsPerSession drift',
        );
      }
    });

    test('regulatory anchors are byte-equivalent', () {
      final ts = tsFile.readAsStringSync();
      for (final r in MbcDispatchCatalog.rules) {
        for (final ref in r.regulatoryRefs) {
          expect(
            ts.contains(ref),
            isTrue,
            reason: '${r.scaleId}: anchor "$ref" missing in TS — drift',
          );
        }
      }
    });

    test('schemaVersion + lastReviewed pinned in TS', () {
      final ts = tsFile.readAsStringSync();
      expect(
        ts.contains('MBC_SCHEMA_VERSION = ${MbcDispatchCatalog.schemaVersion}'),
        isTrue,
      );
      expect(
        ts.contains('MBC_LAST_REVIEWED = "${MbcDispatchCatalog.lastReviewed}"'),
        isTrue,
      );
    });
  });
}
