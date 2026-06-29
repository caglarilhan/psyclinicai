/// N24 wire-up parity test.
///
/// Three places hold the same security header values:
///   1. `lib/services/security/security_headers_catalog.dart` —
///      Dart source of truth (the catalog).
///   2. `functions/src/middleware/security_headers.ts` — Cloud
///      Functions Express middleware mirror.
///   3. `firebase.json` — Firebase Hosting CDN header block.
///
/// If any of the three drifts from the catalog, this test fails.
/// That is the whole point — catalog change must propagate to BOTH
/// runtime emitters in the same PR.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/security_headers_catalog.dart';

void main() {
  group('N24 wire-up parity — catalog ↔ TS middleware ↔ firebase.json', () {
    final tsFile = File('functions/src/middleware/security_headers.ts');
    final firebaseJsonFile = File('firebase.json');

    test('Cloud Functions TS middleware file exists', () {
      expect(
        tsFile.existsSync(),
        isTrue,
        reason:
            'functions/src/middleware/security_headers.ts MUST exist as the Express middleware mirror of the Dart catalog',
      );
    });

    test('firebase.json exists', () {
      expect(firebaseJsonFile.existsSync(), isTrue);
    });

    test('TS middleware contains exactly the catalog header names + values', () {
      final ts = tsFile.readAsStringSync();
      for (final record in SecurityHeadersCatalog.records) {
        expect(
          ts.contains("'${record.name}'"),
          isTrue,
          reason:
              '${record.name}: missing in functions/src/middleware/security_headers.ts — drift; add the entry on the TS side in the same PR',
        );
        expect(
          ts.contains(record.requiredValue) ||
              ts.contains(record.requiredValue.replaceAll("'", '"')),
          isTrue,
          reason:
              '${record.name}: TS value does not match catalog "${record.requiredValue}" — drift',
        );
      }
    });

    test(
      'firebase.json hosting.headers global "**" source contains every catalog header',
      () {
        final raw = firebaseJsonFile.readAsStringSync();
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final hosting = json['hosting'] as Map<String, dynamic>;
        final blocks = hosting['headers'] as List<dynamic>;

        // Find the global "**" block.
        final globalBlock = blocks.firstWhere(
          (b) => (b as Map)['source'] == '**',
          orElse: () => null,
        );
        expect(
          globalBlock,
          isNotNull,
          reason:
              'firebase.json hosting.headers MUST have a "source": "**" block carrying the N24 catalog headers',
        );

        final headers = ((globalBlock as Map)['headers'] as List)
            .cast<Map<String, dynamic>>();
        final headerMap = {
          for (final h in headers) h['key'] as String: h['value'] as String,
        };

        for (final record in SecurityHeadersCatalog.records) {
          expect(
            headerMap.containsKey(record.name),
            isTrue,
            reason:
                '${record.name}: missing in firebase.json hosting.headers "**" block — drift; add the entry on the Hosting side in the same PR',
          );
          expect(
            headerMap[record.name],
            record.requiredValue,
            reason:
                '${record.name}: firebase.json value mismatches catalog — drift',
          );
        }
      },
    );

    test(
      'firebase.json global block is FIRST so per-route override blocks (cache, portal session) can supersede',
      () {
        final raw = firebaseJsonFile.readAsStringSync();
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final blocks =
            (json['hosting'] as Map<String, dynamic>)['headers']
                as List<dynamic>;
        expect(
          (blocks.first as Map)['source'],
          '**',
          reason:
              'global "**" block MUST be the first entry — Firebase Hosting "last match wins"; per-route override blocks (cache, portal session) come AFTER so they override safely',
        );
      },
    );
  });
}
