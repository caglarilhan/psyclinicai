import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/security_headers_catalog.dart';

void main() {
  group('SecurityHeadersCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(SecurityHeadersCatalog.records, isNotEmpty);
    });

    test('every record name is unique (case-insensitive)', () {
      final names = SecurityHeadersCatalog.records
          .map((r) => r.name.toLowerCase())
          .toList();
      expect(names.toSet().length, names.length);
    });

    test('byName resolves every record (case-insensitive)', () {
      for (final r in SecurityHeadersCatalog.records) {
        expect(SecurityHeadersCatalog.byName(r.name), same(r));
        expect(SecurityHeadersCatalog.byName(r.name.toLowerCase()), same(r));
      }
      expect(SecurityHeadersCatalog.byName('X-No-Such-Header'), isNull);
    });

    test('every record has populated fields + anchors', () {
      for (final r in SecurityHeadersCatalog.records) {
        expect(r.requiredValue, isNotEmpty, reason: r.name);
        expect(r.description, isNotEmpty, reason: r.name);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.name);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'HSTS header MUST be set + max-age >= 1 year + includeSubDomains + preload',
      () {
        final r = SecurityHeadersCatalog.byName('Strict-Transport-Security')!;
        expect(r.requiredOnEveryResponse, isTrue);
        expect(r.requiredValue.contains('max-age='), isTrue);
        expect(
          r.requiredValue.contains('includeSubDomains'),
          isTrue,
          reason:
              'HSTS without includeSubDomains leaves subdomain downgrade open',
        );
        expect(
          r.requiredValue.contains('preload'),
          isTrue,
          reason: 'HSTS preload opt-in defeats first-request TOFU window',
        );
        final match = RegExp(r'max-age=(\d+)').firstMatch(r.requiredValue);
        expect(match, isNotNull);
        final maxAge = int.parse(match!.group(1)!);
        expect(
          maxAge,
          greaterThanOrEqualTo(31536000),
          reason:
              'HSTS max-age must be >= 1 year per browser preload requirements',
        );
      },
    );

    test('CSP MUST forbid inline + plugins + framing + base-uri override', () {
      final r = SecurityHeadersCatalog.byName('Content-Security-Policy')!;
      expect(r.requiredOnEveryResponse, isTrue);
      expect(
        r.requiredValue.contains("object-src 'none'"),
        isTrue,
        reason: 'CSP must forbid plugins (Flash, applets) — XSS amplifier',
      );
      expect(
        r.requiredValue.contains("base-uri 'none'"),
        isTrue,
        reason: 'CSP must forbid <base> override — script-src bypass vector',
      );
      expect(
        r.requiredValue.contains("frame-ancestors 'none'"),
        isTrue,
        reason:
            'CSP frame-ancestors none blocks clickjacking (modern replacement for X-Frame-Options)',
      );
      expect(
        r.requiredValue.contains('upgrade-insecure-requests'),
        isTrue,
        reason:
            'CSP upgrade-insecure-requests auto-redirects HTTP subresources to HTTPS',
      );
    });

    test('X-Content-Type-Options MUST be exactly nosniff', () {
      final r = SecurityHeadersCatalog.byName('X-Content-Type-Options')!;
      expect(
        r.requiredValue,
        'nosniff',
        reason: 'X-Content-Type-Options only accepts nosniff per WHATWG Fetch',
      );
      expect(r.requiredOnEveryResponse, isTrue);
    });

    test(
      'X-Frame-Options MUST be DENY (defense-in-depth with CSP frame-ancestors)',
      () {
        final r = SecurityHeadersCatalog.byName('X-Frame-Options')!;
        expect(
          r.requiredValue,
          'DENY',
          reason:
              'X-Frame-Options DENY is the strictest setting + parity with CSP frame-ancestors none',
        );
        expect(r.requiredOnEveryResponse, isTrue);
      },
    );

    test(
      'Referrer-Policy MUST NOT leak full URL cross-origin (strict-origin-when-cross-origin minimum)',
      () {
        final r = SecurityHeadersCatalog.byName('Referrer-Policy')!;
        const acceptable = {
          'strict-origin-when-cross-origin',
          'strict-origin',
          'no-referrer',
          'same-origin',
        };
        expect(
          acceptable.contains(r.requiredValue),
          isTrue,
          reason:
              'Referrer-Policy "${r.requiredValue}" leaks too much; only strict-origin/no-referrer/same-origin keep PHI URLs out of cross-origin Referer header',
        );
      },
    );

    test(
      'Permissions-Policy MUST disable camera + geolocation + payment + usb (privacy-by-default)',
      () {
        final r = SecurityHeadersCatalog.byName('Permissions-Policy')!;
        for (final feature in [
          'camera=()',
          'geolocation=()',
          'payment=()',
          'usb=()',
        ]) {
          expect(
            r.requiredValue.contains(feature),
            isTrue,
            reason:
                'Permissions-Policy must disable $feature by default (GDPR Art. 25 privacy by default)',
          );
        }
      },
    );

    test('COOP + COEP MUST be set for cross-origin isolation', () {
      final coop = SecurityHeadersCatalog.byName('Cross-Origin-Opener-Policy')!;
      final coep = SecurityHeadersCatalog.byName(
        'Cross-Origin-Embedder-Policy',
      )!;
      expect(coop.requiredValue, 'same-origin');
      expect(coep.requiredValue, 'require-corp');
      expect(coop.requiredOnEveryResponse, isTrue);
      expect(coep.requiredOnEveryResponse, isTrue);
    });

    test('every record MUST cite OWASP ASVS V14.4 OR an RFC/W3C spec', () {
      for (final r in SecurityHeadersCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('OWASP ASVS V14.4') ||
              blob.contains('RFC ') ||
              blob.contains('W3C') ||
              blob.contains('WHATWG') ||
              blob.contains('HTML Living Standard'),
          isTrue,
          reason:
              '${r.name}: needs OWASP ASVS V14.4 OR RFC/W3C/WHATWG spec anchor',
        );
      }
    });

    test(
      'Referrer-Policy MUST cite HIPAA §164.502(b) (minimum-necessary anchor)',
      () {
        final r = SecurityHeadersCatalog.byName('Referrer-Policy')!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('HIPAA §164.502(b)'),
          isTrue,
          reason:
              'Referrer leakage of PHI URLs is a minimum-necessary violation; anchor mandatory',
        );
      },
    );

    test(
      'every record MUST require on every response (catalog scope = hardening headers only)',
      () {
        for (final r in SecurityHeadersCatalog.records) {
          expect(
            r.requiredOnEveryResponse,
            isTrue,
            reason:
                '${r.name}: catalog scope is universally-required hardening headers; situational headers (CORS, Cache-Control) live elsewhere',
          );
        }
      },
    );
  });

  group('isRequiredOnEveryResponse helper', () {
    test('true for every known header', () {
      for (final r in SecurityHeadersCatalog.records) {
        expect(isRequiredOnEveryResponse(r.name), isTrue, reason: r.name);
      }
    });

    test('false for unknown header', () {
      expect(isRequiredOnEveryResponse('X-Made-Up-Header'), isFalse);
    });

    test('case-insensitive lookup', () {
      expect(isRequiredOnEveryResponse('strict-transport-security'), isTrue);
      expect(isRequiredOnEveryResponse('STRICT-TRANSPORT-SECURITY'), isTrue);
    });
  });
}
