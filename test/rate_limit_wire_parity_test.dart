/// N25 wire-up parity test.
///
/// Two places hold the same rate-limit policy:
///   1. `lib/services/security/api_rate_limit_catalog.dart` — Dart
///      source of truth.
///   2. `functions/src/middleware/rate_limit.ts` — Express middleware
///      that enforces the catalog at runtime.
///
/// If the TS mirror drifts from the catalog, this test fails. The
/// drift detector is the whole point — any change to one side MUST
/// land in the same PR as the change to the other.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/api_rate_limit_catalog.dart';

/// Catalog enum → TS literal string mapping. Tests assert both sides
/// stay in step.
const Map<ApiEndpointClass, String> _classToTsLiteral = {
  ApiEndpointClass.authLogin: 'auth-login',
  ApiEndpointClass.publicUnauthenticated: 'public-unauthenticated',
  ApiEndpointClass.clinicianDashboardRead: 'clinician-dashboard-read',
  ApiEndpointClass.aiCopilotInference: 'ai-copilot-inference',
  ApiEndpointClass.portalDsar: 'portal-dsar',
  ApiEndpointClass.internalAdmin: 'internal-admin',
  ApiEndpointClass.webhookIngestion: 'webhook-ingestion',
};

void main() {
  group('N25 wire-up parity — catalog ↔ TS middleware', () {
    final tsFile = File('functions/src/middleware/rate_limit.ts');

    test('TS middleware file exists', () {
      expect(tsFile.existsSync(), isTrue);
    });

    test('every catalog endpoint class has a TS string mapping', () {
      for (final c in ApiEndpointClass.values) {
        expect(
          _classToTsLiteral.containsKey(c),
          isTrue,
          reason:
              '${c.name}: missing TS literal mapping — drift between Dart enum + TS string union',
        );
      }
    });

    test('TS middleware contains every endpoint class literal', () {
      final ts = tsFile.readAsStringSync();
      for (final c in ApiEndpointClass.values) {
        final literal = _classToTsLiteral[c]!;
        expect(
          ts.contains("'$literal':"),
          isTrue,
          reason:
              '${c.name}: missing RATE_LIMITS["$literal"] entry in TS — drift',
        );
      }
    });

    test('TS perMinute + burst + bruteForceSensitive match catalog', () {
      final ts = tsFile.readAsStringSync();
      for (final record in ApiRateLimitCatalog.records) {
        final literal = _classToTsLiteral[record.endpointClass]!;
        final keyIdx = ts.indexOf("'$literal':");
        expect(keyIdx, greaterThan(-1), reason: '$literal: key not found');
        final block = ts.substring(keyIdx, (keyIdx + 260).clamp(0, ts.length));
        expect(
          block.contains('perMinute: ${record.perTenantRequestsPerMinute}'),
          isTrue,
          reason:
              '$literal: perMinute mismatch — catalog=${record.perTenantRequestsPerMinute}',
        );
        expect(
          block.contains('burst: ${record.burstAllowance}'),
          isTrue,
          reason: '$literal: burst mismatch — catalog=${record.burstAllowance}',
        );
        expect(
          block.contains(
            'bruteForceSensitive: ${record.bruteForceSensitive ? "true" : "false"}',
          ),
          isTrue,
          reason: '$literal: bruteForceSensitive mismatch',
        );
      }
    });

    test('auth-login lockout-after-N constant pinned to 5 in TS', () {
      final ts = tsFile.readAsStringSync();
      expect(
        ts.contains('LOCKOUT_FAILURES = 5'),
        isTrue,
        reason:
            'NIST SP 800-63B + PCI DSS §6.5.10 require lockout after a small number of failures; we pin 5',
      );
    });
  });
}
