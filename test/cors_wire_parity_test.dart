/// N27 wire-up parity test.
///
/// Two places hold the same CORS allow-origin policy:
///   1. `lib/services/security/cors_allowed_origin_catalog.dart` —
///      Dart source of truth.
///   2. `functions/src/middleware/cors.ts` — Express middleware
///      mirror that the Cloud Functions chain enforces at runtime.
///
/// If the TS mirror drifts from the Dart catalog, this test fails
/// — that is the whole point. Adding / changing an origin requires
/// the same change on both sides in the same PR.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/cors_allowed_origin_catalog.dart';

void main() {
  group('N27 wire-up parity — catalog ↔ TS middleware', () {
    final tsFile = File('functions/src/middleware/cors.ts');

    test('TS middleware file exists', () {
      expect(
        tsFile.existsSync(),
        isTrue,
        reason:
            'functions/src/middleware/cors.ts MUST exist as the Express middleware mirror of the Dart catalog',
      );
    });

    test('TS middleware contains every catalog origin', () {
      final ts = tsFile.readAsStringSync();
      for (final record in CorsAllowedOriginCatalog.records) {
        expect(
          ts.contains("origin: '${record.origin}'"),
          isTrue,
          reason:
              '${record.id}: missing origin "${record.origin}" in TS middleware — drift',
        );
      }
    });

    test('TS middleware allowCredentials matches catalog for every origin', () {
      final ts = tsFile.readAsStringSync();
      for (final record in CorsAllowedOriginCatalog.records) {
        final originIdx = ts.indexOf("origin: '${record.origin}'");
        expect(
          originIdx,
          greaterThan(-1),
          reason: '${record.id}: origin literal not found',
        );
        final block = ts.substring(
          originIdx,
          (originIdx + 220).clamp(0, ts.length),
        );
        final expected =
            'allowCredentials: ${record.allowCredentials ? "true" : "false"}';
        expect(
          block.contains(expected),
          isTrue,
          reason:
              '${record.id}: expected `$expected` near origin block — drift',
        );
      }
    });

    test('TS middleware slot mapping matches catalog for every origin', () {
      final ts = tsFile.readAsStringSync();
      for (final record in CorsAllowedOriginCatalog.records) {
        final originIdx = ts.indexOf("origin: '${record.origin}'");
        final block = ts.substring(
          originIdx,
          (originIdx + 220).clamp(0, ts.length),
        );
        for (final slot in record.allowedSlots) {
          expect(
            block.contains("'${slot.name}'"),
            isTrue,
            reason:
                '${record.id}: slot "${slot.name}" missing in TS block — drift',
          );
        }
      }
    });

    test('TS middleware does NOT emit a wildcard "*" origin entry', () {
      final ts = tsFile.readAsStringSync();
      expect(
        ts.contains("origin: '*'"),
        isFalse,
        reason:
            'wildcard "*" origin defeats CORS for credentialled requests (OWASP API8:2023)',
      );
    });
  });
}
