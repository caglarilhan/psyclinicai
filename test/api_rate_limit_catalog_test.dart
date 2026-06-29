import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/api_rate_limit_catalog.dart';

void main() {
  group('ApiRateLimitCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(ApiRateLimitCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = ApiRateLimitCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in ApiRateLimitCatalog.records) {
        expect(ApiRateLimitCatalog.byId(r.id), same(r));
      }
      expect(ApiRateLimitCatalog.byId('does-not-exist'), isNull);
    });

    test('every ApiEndpointClass has exactly one pinned record', () {
      for (final c in ApiEndpointClass.values) {
        final matches = ApiRateLimitCatalog.records
            .where((r) => r.endpointClass == c)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${c.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors + positive rate', () {
      for (final r in ApiRateLimitCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.perTenantRequestsPerMinute, greaterThan(0), reason: r.id);
        expect(r.burstAllowance, greaterThanOrEqualTo(0), reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'auth-login MUST be brute-force-sensitive + tightest cap (per-minute <= 10) + zero burst',
      () {
        final r = ApiRateLimitCatalog.byEndpointClass(
          ApiEndpointClass.authLogin,
        )!;
        expect(
          r.bruteForceSensitive,
          isTrue,
          reason: 'auth-login is the canonical brute-force surface',
        );
        expect(
          r.perTenantRequestsPerMinute,
          lessThanOrEqualTo(10),
          reason:
              'NIST SP 800-63B + PCI DSS §6.5.10 require tight rate-limit on authenticators',
        );
        expect(
          r.burstAllowance,
          0,
          reason:
              'auth-login burst > 0 lets credential stuffing slip through the throttle',
        );
      },
    );

    test(
      'non-auth endpoint classes MUST NOT be brute-force-sensitive (catalog scope keeps lockout policy narrow)',
      () {
        for (final c in ApiEndpointClass.values) {
          if (c == ApiEndpointClass.authLogin) continue;
          final r = ApiRateLimitCatalog.byEndpointClass(c)!;
          expect(
            r.bruteForceSensitive,
            isFalse,
            reason:
                '${c.name}: lockout-after-N policy is reserved for credential surfaces; broadening it triggers spurious DoS on legitimate batches',
          );
        }
      },
    );

    test(
      'ai-copilot-inference MUST have per-minute <= 30 (LLM cost containment alongside L10 token budget)',
      () {
        final r = ApiRateLimitCatalog.byEndpointClass(
          ApiEndpointClass.aiCopilotInference,
        )!;
        expect(
          r.perTenantRequestsPerMinute,
          lessThanOrEqualTo(30),
          reason:
              'AI copilot at > 30 req/min lets a runaway loop burn L10 monthly token budget in minutes',
        );
      },
    );

    test(
      'portal-dsar MUST have per-minute <= 20 (enumeration scraping defense)',
      () {
        final r = ApiRateLimitCatalog.byEndpointClass(
          ApiEndpointClass.portalDsar,
        )!;
        expect(
          r.perTenantRequestsPerMinute,
          lessThanOrEqualTo(20),
          reason:
              'DSAR portal at > 20 req/min lets an attacker enumerate request ids; K17 deadline policy handles legit queue',
        );
      },
    );

    test('rate-limit ladder monotonic across sensitivity tiers', () {
      final auth = ApiRateLimitCatalog.byEndpointClass(
        ApiEndpointClass.authLogin,
      )!.perTenantRequestsPerMinute;
      final dsar = ApiRateLimitCatalog.byEndpointClass(
        ApiEndpointClass.portalDsar,
      )!.perTenantRequestsPerMinute;
      final ai = ApiRateLimitCatalog.byEndpointClass(
        ApiEndpointClass.aiCopilotInference,
      )!.perTenantRequestsPerMinute;
      final pub = ApiRateLimitCatalog.byEndpointClass(
        ApiEndpointClass.publicUnauthenticated,
      )!.perTenantRequestsPerMinute;
      final admin = ApiRateLimitCatalog.byEndpointClass(
        ApiEndpointClass.internalAdmin,
      )!.perTenantRequestsPerMinute;
      final dash = ApiRateLimitCatalog.byEndpointClass(
        ApiEndpointClass.clinicianDashboardRead,
      )!.perTenantRequestsPerMinute;
      final wh = ApiRateLimitCatalog.byEndpointClass(
        ApiEndpointClass.webhookIngestion,
      )!.perTenantRequestsPerMinute;
      expect(auth, lessThan(dsar));
      expect(dsar, lessThanOrEqualTo(ai));
      expect(ai, lessThan(pub));
      expect(pub, lessThanOrEqualTo(admin));
      expect(admin, lessThan(dash));
      expect(dash, lessThanOrEqualTo(wh));
    });

    test(
      'every record MUST cite OWASP API Top-10 API4 (universal rate-limit anchor)',
      () {
        for (final r in ApiRateLimitCatalog.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('OWASP API Top-10 API4'),
            isTrue,
            reason: '${r.id}: needs OWASP API Top-10 API4:2023 anchor',
          );
        }
      },
    );

    test(
      'auth-login MUST cite OWASP API2 broken auth + PCI DSS §6.5.10 + NIST SP 800-63B',
      () {
        final r = ApiRateLimitCatalog.byEndpointClass(
          ApiEndpointClass.authLogin,
        )!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(blob.contains('OWASP API Top-10 API2:2023'), isTrue);
        expect(blob.contains('PCI DSS v4.0 §6.5.10'), isTrue);
        expect(blob.contains('NIST SP 800-63B'), isTrue);
      },
    );

    test(
      'burst allowance MUST be <= per-minute ceiling (token bucket invariant)',
      () {
        for (final r in ApiRateLimitCatalog.records) {
          expect(
            r.burstAllowance,
            lessThanOrEqualTo(r.perTenantRequestsPerMinute),
            reason:
                '${r.id}: burst allowance > steady-state cap would let a single burst exceed the monthly aggregate envelope',
          );
        }
      },
    );
  });

  group('requiresBruteForceLockout helper', () {
    test('true ONLY for auth-login', () {
      for (final c in ApiEndpointClass.values) {
        expect(
          requiresBruteForceLockout(c),
          c == ApiEndpointClass.authLogin,
          reason: c.name,
        );
      }
    });
  });
}
