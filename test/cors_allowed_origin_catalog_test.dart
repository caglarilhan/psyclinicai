import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/cors_allowed_origin_catalog.dart';

void main() {
  group('CorsAllowedOriginCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(CorsAllowedOriginCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = CorsAllowedOriginCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every record origin is unique', () {
      final origins = CorsAllowedOriginCatalog.records
          .map((r) => r.origin)
          .toList();
      expect(origins.toSet().length, origins.length);
    });

    test('byId resolves every record', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        expect(CorsAllowedOriginCatalog.byId(r.id), same(r));
      }
      expect(CorsAllowedOriginCatalog.byId('does-not-exist'), isNull);
    });

    test('every record has populated fields + anchors', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        expect(r.origin, isNotEmpty, reason: r.id);
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.allowedSlots, isNotEmpty, reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'no record is a wildcard ("*") — Access-Control-Allow-Origin: * defeats same-origin policy',
      () {
        for (final r in CorsAllowedOriginCatalog.records) {
          expect(
            r.origin == '*',
            isFalse,
            reason:
                '${r.id}: wildcard origin defeats CORS purpose; OWASP API8:2023',
          );
        }
      },
    );

    test('every production-slot origin MUST be HTTPS', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        if (!r.allowedSlots.contains(CorsDeploymentSlot.production)) continue;
        expect(
          r.origin.startsWith('https://'),
          isTrue,
          reason:
              '${r.id}: production CORS origin MUST be HTTPS; HTTP origin in prod = downgrade attack surface',
        );
      }
    });

    test(
      'every origin MUST have no path component (canonical scheme+host+port only)',
      () {
        for (final r in CorsAllowedOriginCatalog.records) {
          final m = RegExp(r'^https?://[^/]+(/.*)?$').firstMatch(r.origin);
          expect(
            m,
            isNotNull,
            reason:
                '${r.id}: origin "${r.origin}" not a valid scheme://host[:port]',
          );
          final tail = m!.group(1);
          expect(
            tail == null || tail.isEmpty,
            isTrue,
            reason:
                '${r.id}: origin must be scheme+host+port ONLY (no path "$tail"); CORS spec rejects paths',
          );
        }
      },
    );

    test('every origin MUST NOT end with a trailing slash', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        expect(
          r.origin.endsWith('/'),
          isFalse,
          reason:
              '${r.id}: trailing slash makes "${r.origin}" not a valid Origin header value',
        );
      }
    });

    test('local-dev slot MUST have at least one origin', () {
      final local = CorsAllowedOriginCatalog.records
          .where((r) => r.allowedSlots.contains(CorsDeploymentSlot.local))
          .toList();
      expect(
        local,
        isNotEmpty,
        reason: 'local-dev slot needs at least one origin for emulator/test',
      );
    });

    test('preview + staging + production origins MUST NOT be localhost', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        final nonLocalSlots = r.allowedSlots
            .where((s) => s != CorsDeploymentSlot.local)
            .toList();
        if (nonLocalSlots.isEmpty) continue;
        expect(
          r.origin.contains('localhost') || r.origin.contains('127.0.0.1'),
          isFalse,
          reason:
              '${r.id}: localhost origin in ${nonLocalSlots.map((s) => s.name).join(",")} slot is a typo or test artifact',
        );
      }
    });

    test('production-marketing MUST NOT allow credentials (no auth surface)', () {
      final r = CorsAllowedOriginCatalog.byId('production-marketing')!;
      expect(
        r.allowCredentials,
        isFalse,
        reason:
            'marketing site has no auth surface; allowing credentials widens cookie leakage attack window for no benefit',
      );
    });

    test('production-app MUST allow credentials (auth surface)', () {
      final r = CorsAllowedOriginCatalog.byId('production-app')!;
      expect(
        r.allowCredentials,
        isTrue,
        reason:
            'production-app needs Cookie / Authorization for clinician + patient session',
      );
    });

    test('every record MUST cite OWASP or W3C anchor', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('OWASP') || blob.contains('W3C'),
          isTrue,
          reason: '${r.id}: needs OWASP API/ASVS or W3C Fetch CORS anchor',
        );
      }
    });

    test('production records MUST cite HIPAA, GDPR, or SOC 2 anchor', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        if (!r.allowedSlots.contains(CorsDeploymentSlot.production)) continue;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('HIPAA') ||
              blob.contains('GDPR') ||
              blob.contains('SOC 2'),
          isTrue,
          reason: '${r.id}: production origin needs a compliance anchor',
        );
      }
    });
  });

  group('forSlot + isOriginAllowed helpers', () {
    test('forSlot slices correctly', () {
      for (final s in CorsDeploymentSlot.values) {
        for (final r in CorsAllowedOriginCatalog.forSlot(s)) {
          expect(r.allowedSlots.contains(s), isTrue);
        }
      }
    });

    test('isOriginAllowed true for every known (origin, slot) pair', () {
      for (final r in CorsAllowedOriginCatalog.records) {
        for (final s in r.allowedSlots) {
          expect(
            isOriginAllowed(r.origin, s),
            isTrue,
            reason: '${r.id} @ ${s.name}',
          );
        }
      }
    });

    test(
      'isOriginAllowed false for production-app in local slot (slot scoping enforced)',
      () {
        expect(
          isOriginAllowed(
            'https://app.psyclinicai.com',
            CorsDeploymentSlot.local,
          ),
          isFalse,
        );
      },
    );

    test('isOriginAllowed false for unknown origin', () {
      expect(
        isOriginAllowed(
          'https://evil.example.com',
          CorsDeploymentSlot.production,
        ),
        isFalse,
      );
    });
  });
}
