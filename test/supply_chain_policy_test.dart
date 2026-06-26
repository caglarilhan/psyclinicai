import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/supply_chain_policy.dart';

void main() {
  group('SupplyChainPolicy — license catalog parity', () {
    test('every LicenseCategory has exactly one pinned record', () {
      final pinned = SupplyChainPolicy.licenses.map((p) => p.category).toSet();
      expect(pinned, equals(LicenseCategory.values.toSet()));
      expect(SupplyChainPolicy.licenses.length, LicenseCategory.values.length);
    });

    test('forLicenseCategory resolves every enum value', () {
      for (final c in LicenseCategory.values) {
        expect(SupplyChainPolicy.forLicenseCategory(c).category, c);
      }
    });

    test('every license row has at least one example SPDX id', () {
      for (final p in SupplyChainPolicy.licenses) {
        expect(p.exampleLicenses, isNotEmpty, reason: p.category.name);
      }
    });

    test('permissive licenses are prod-allowed and need no legal review', () {
      final p = SupplyChainPolicy.forLicenseCategory(
        LicenseCategory.permissive,
      );
      expect(p.allowedInProdBundle, isTrue);
      expect(p.requiresLegalReview, isFalse);
    });

    test('strong copyleft is forbidden in prod (AGPL-incompat with SaaS)', () {
      final p = SupplyChainPolicy.forLicenseCategory(
        LicenseCategory.strongCopyleft,
      );
      expect(p.allowedInProdBundle, isFalse);
      expect(p.allowedInTestOnly, isFalse);
      expect(p.requiresLegalReview, isTrue);
    });

    test('weak copyleft + proprietary require legal review', () {
      for (final cat in [
        LicenseCategory.weakCopyleft,
        LicenseCategory.proprietary,
      ]) {
        final p = SupplyChainPolicy.forLicenseCategory(cat);
        expect(
          p.requiresLegalReview,
          isTrue,
          reason: '${cat.name} requires counsel sign-off per add',
        );
      }
    });

    test('GPL family is in the strong-copyleft examples', () {
      final p = SupplyChainPolicy.forLicenseCategory(
        LicenseCategory.strongCopyleft,
      );
      expect(p.exampleLicenses, contains('GPL-3.0'));
      expect(p.exampleLicenses, contains('AGPL-3.0'));
    });
  });

  group('SupplyChainPolicy — CVE response parity', () {
    test('every CveSeverity has exactly one pinned response', () {
      final pinned = SupplyChainPolicy.cveResponses
          .map((p) => p.severity)
          .toSet();
      expect(pinned, equals(CveSeverity.values.toSet()));
    });

    test('forCveSeverity resolves every enum value', () {
      for (final s in CveSeverity.values) {
        expect(SupplyChainPolicy.forCveSeverity(s).severity, s);
      }
    });

    test('critical < high < medium < low for ack speed', () {
      final c = SupplyChainPolicy.forCveSeverity(CveSeverity.critical);
      final h = SupplyChainPolicy.forCveSeverity(CveSeverity.high);
      final m = SupplyChainPolicy.forCveSeverity(CveSeverity.medium);
      final l = SupplyChainPolicy.forCveSeverity(CveSeverity.low);
      expect(c.acknowledgeWithinHours, lessThan(h.acknowledgeWithinHours));
      expect(h.acknowledgeWithinHours, lessThan(m.acknowledgeWithinHours));
      expect(m.acknowledgeWithinHours, lessThan(l.acknowledgeWithinHours));
    });

    test('critical < high < medium < low for remediation target', () {
      final c = SupplyChainPolicy.forCveSeverity(CveSeverity.critical);
      final h = SupplyChainPolicy.forCveSeverity(CveSeverity.high);
      final m = SupplyChainPolicy.forCveSeverity(CveSeverity.medium);
      final l = SupplyChainPolicy.forCveSeverity(CveSeverity.low);
      expect(c.remediationTargetDays, lessThan(h.remediationTargetDays));
      expect(h.remediationTargetDays, lessThan(m.remediationTargetDays));
      expect(m.remediationTargetDays, lessThan(l.remediationTargetDays));
    });

    test('critical CVE acknowledged within 4 hours', () {
      final c = SupplyChainPolicy.forCveSeverity(CveSeverity.critical);
      expect(c.acknowledgeWithinHours, lessThanOrEqualTo(4));
    });

    test('critical CVE escalates to CISO (not the generic on-call)', () {
      final c = SupplyChainPolicy.forCveSeverity(CveSeverity.critical);
      expect(c.escalationOwner, 'ciso');
    });
  });

  group('SupplyChainPolicy — SBOM', () {
    test('SBOM format is CycloneDX 1.5 (industry default)', () {
      expect(SupplyChainPolicy.sbomFormat, 'CycloneDX 1.5');
    });

    test('SBOM regeneration cadence is weekly (≤ 7 days)', () {
      expect(SupplyChainPolicy.sbomRegenerationDays, lessThanOrEqualTo(7));
    });

    test('SBOM storage path uses canonical date + file conventions', () {
      expect(
        SupplyChainPolicy.sbomStoragePathTemplate,
        startsWith('docs/security/sbom/'),
      );
      expect(
        SupplyChainPolicy.sbomStoragePathTemplate,
        contains('<YYYY-mm-dd>'),
      );
      expect(
        SupplyChainPolicy.sbomStoragePathTemplate,
        endsWith('.cyclonedx.json'),
      );
    });

    test('policy cites SOC 2 + NIST + EU CRA anchors', () {
      final blob = SupplyChainPolicy.regulatoryRefs.join(' | ');
      expect(blob, contains('SOC 2'));
      expect(blob, contains('NIST'));
      expect(blob, contains('EU CRA'));
    });
  });

  group('isLicenseAllowedInProd', () {
    test('MIT + Apache-2.0 are allowed', () {
      expect(isLicenseAllowedInProd('MIT'), isTrue);
      expect(isLicenseAllowedInProd('Apache-2.0'), isTrue);
    });

    test('GPL-3.0 + AGPL-3.0 are NOT allowed in prod', () {
      expect(isLicenseAllowedInProd('GPL-3.0'), isFalse);
      expect(isLicenseAllowedInProd('AGPL-3.0'), isFalse);
    });

    test('case-insensitive match', () {
      expect(isLicenseAllowedInProd('mit'), isTrue);
      expect(isLicenseAllowedInProd('apache-2.0'), isTrue);
    });

    test('unknown licenses are NOT auto-allowed', () {
      expect(isLicenseAllowedInProd('WTFPL'), isFalse);
    });
  });

  group('isLicenseDeniedInProd', () {
    test('GPL-3.0 is on the deny-list', () {
      expect(isLicenseDeniedInProd('GPL-3.0'), isTrue);
    });

    test('MIT is NOT on the deny-list', () {
      expect(isLicenseDeniedInProd('MIT'), isFalse);
    });

    test('unknown licenses are NOT auto-denied (legal triage needed)', () {
      expect(isLicenseDeniedInProd('WTFPL'), isFalse);
    });
  });
}
