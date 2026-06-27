import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/subresource_integrity_catalog.dart';

void main() {
  group('SubresourceIntegrityCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(SubresourceIntegrityCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = SubresourceIntegrityCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in SubresourceIntegrityCatalog.records) {
        expect(SubresourceIntegrityCatalog.byId(r.id), same(r));
      }
      expect(SubresourceIntegrityCatalog.byId('does-not-exist'), isNull);
    });

    test('every record has populated fields + anchors', () {
      for (final r in SubresourceIntegrityCatalog.records) {
        expect(r.url, isNotEmpty, reason: r.id);
        expect(r.integrityHash, isNotEmpty, reason: r.id);
        expect(r.crossorigin, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test('every URL MUST be absolute HTTPS', () {
      for (final r in SubresourceIntegrityCatalog.records) {
        expect(
          r.url.startsWith('https://'),
          isTrue,
          reason:
              '${r.id}: SRI on HTTP defeats the integrity guarantee (MITM strips hash)',
        );
      }
    });

    test('every URL MUST be version-pinned (no "latest", "edge", "main")', () {
      const forbidden = ['latest', '/edge/', '/main/', '/master/'];
      for (final r in SubresourceIntegrityCatalog.records) {
        for (final term in forbidden) {
          expect(
            r.url.toLowerCase().contains(term),
            isFalse,
            reason:
                '${r.id}: floating-tag "$term" defeats SRI (hash will mismatch after publisher updates)',
          );
        }
      }
    });

    test(
      'every integrity hash MUST start with "sha384-" (W3C SRI required format)',
      () {
        for (final r in SubresourceIntegrityCatalog.records) {
          expect(
            r.integrityHash.startsWith('sha384-'),
            isTrue,
            reason:
                '${r.id}: SRI hash format MUST be "sha384-BASE64" per W3C SRI; deviating breaks browser verification',
          );
        }
      },
    );

    test('every crossorigin MUST be "anonymous" or "use-credentials"', () {
      const acceptable = {'anonymous', 'use-credentials'};
      for (final r in SubresourceIntegrityCatalog.records) {
        expect(
          acceptable.contains(r.crossorigin),
          isTrue,
          reason:
              '${r.id}: crossorigin "${r.crossorigin}" is not in the accepted set; browser will ignore SRI',
        );
      }
    });

    test(
      'every record MUST cite OWASP ASVS V14.4.4 (universal SRI anchor)',
      () {
        for (final r in SubresourceIntegrityCatalog.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('OWASP ASVS V14.4.4'),
            isTrue,
            reason: '${r.id}: needs OWASP ASVS V14.4.4 anchor',
          );
        }
      },
    );

    test(
      'script-class records MUST cite W3C SRI Recommendation OR HIPAA §164.312',
      () {
        for (final r in SubresourceIntegrityCatalog.byKind(
          SriAssetKind.script,
        )) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('W3C Subresource Integrity') ||
                blob.contains('HIPAA §164.312'),
            isTrue,
            reason:
                '${r.id}: script-class SRI needs W3C SRI or HIPAA §164.312 anchor (script executes in our origin)',
          );
        }
      },
    );
  });

  group('byKind + isPinnedExternalAsset helpers', () {
    test('byKind slices correctly', () {
      for (final k in SriAssetKind.values) {
        for (final r in SubresourceIntegrityCatalog.byKind(k)) {
          expect(r.kind, k);
        }
      }
    });

    test('isPinnedExternalAsset true for every catalog URL', () {
      for (final r in SubresourceIntegrityCatalog.records) {
        expect(isPinnedExternalAsset(r.url), isTrue, reason: r.id);
      }
    });

    test('isPinnedExternalAsset false for unknown URL', () {
      expect(isPinnedExternalAsset('https://evil.example.com/x.js'), isFalse);
    });
  });
}
