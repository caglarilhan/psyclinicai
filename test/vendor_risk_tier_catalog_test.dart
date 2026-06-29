import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/vendor_risk_tier_catalog.dart';

void main() {
  group('VendorRiskTierCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(VendorRiskTierCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = VendorRiskTierCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in VendorRiskTierCatalog.records) {
        expect(VendorRiskTierCatalog.byId(r.id), same(r));
      }
      expect(VendorRiskTierCatalog.byId('does-not-exist'), isNull);
    });

    test('every VendorRiskTier has exactly one pinned record', () {
      for (final t in VendorRiskTier.values) {
        final matches = VendorRiskTierCatalog.records
            .where((r) => r.tier == t)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${t.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in VendorRiskTierCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.mandatoryArtifacts, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.reviewCadenceMonths, greaterThan(0), reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test('critical tier MUST include BAA + DPA + pen test + SOC 2', () {
      final r = VendorRiskTierCatalog.byTier(VendorRiskTier.critical)!;
      expect(
        r.mandatoryArtifacts,
        contains(VendorDiligenceArtifact.baa),
        reason: 'plain-text PHI requires HIPAA BAA',
      );
      expect(
        r.mandatoryArtifacts,
        contains(VendorDiligenceArtifact.dpa),
        reason: 'EU data export requires GDPR Art. 28 DPA',
      );
      expect(
        r.mandatoryArtifacts,
        contains(VendorDiligenceArtifact.penTestReport),
        reason: 'critical access requires independent pen test',
      );
      expect(
        r.mandatoryArtifacts,
        contains(VendorDiligenceArtifact.soc2TypeII),
        reason: 'critical access requires SOC 2 Type II',
      );
    });

    test('critical tier MUST require continuous monitoring', () {
      final r = VendorRiskTierCatalog.byTier(VendorRiskTier.critical)!;
      expect(r.continuousMonitoringRequired, isTrue);
    });

    test('non-critical tiers MUST NOT require continuous monitoring', () {
      for (final t in VendorRiskTier.values) {
        if (t == VendorRiskTier.critical) continue;
        final r = VendorRiskTierCatalog.byTier(t)!;
        expect(
          r.continuousMonitoringRequired,
          isFalse,
          reason:
              '${t.name}: only critical-tier vendors warrant the cost of continuous monitoring',
        );
      }
    });

    test('only critical tier requires BAA', () {
      for (final t in VendorRiskTier.values) {
        final r = VendorRiskTierCatalog.byTier(t)!;
        final hasBaa = r.mandatoryArtifacts.contains(
          VendorDiligenceArtifact.baa,
        );
        if (t == VendorRiskTier.critical) {
          expect(hasBaa, isTrue);
        } else {
          expect(
            hasBaa,
            isFalse,
            reason:
                '${t.name}: BAA is HIPAA business associate gate — only PHI-handling vendors',
          );
        }
      }
    });

    test(
      'review cadence ladder: critical < elevated <= standard < minimal',
      () {
        final critical = VendorRiskTierCatalog.byTier(VendorRiskTier.critical)!;
        final elevated = VendorRiskTierCatalog.byTier(VendorRiskTier.elevated)!;
        final standard = VendorRiskTierCatalog.byTier(VendorRiskTier.standard)!;
        final minimal = VendorRiskTierCatalog.byTier(VendorRiskTier.minimal)!;
        expect(
          critical.reviewCadenceMonths,
          lessThan(elevated.reviewCadenceMonths),
          reason: 'critical reviewed more often than elevated',
        );
        expect(
          elevated.reviewCadenceMonths,
          lessThanOrEqualTo(standard.reviewCadenceMonths),
          reason: 'elevated reviewed at least as often as standard',
        );
        expect(
          standard.reviewCadenceMonths,
          lessThan(minimal.reviewCadenceMonths),
          reason: 'standard reviewed more often than minimal',
        );
      },
    );

    test('every record MUST cite SOC 2 CC9.2 (vendor risk anchor)', () {
      for (final r in VendorRiskTierCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('SOC 2 CC9.2'),
          isTrue,
          reason: '${r.id}: SOC 2 CC9.2 is the universal vendor-risk control',
        );
      }
    });

    test('critical + elevated tiers MUST cite GDPR Art. 28 (processor)', () {
      for (final t in [VendorRiskTier.critical, VendorRiskTier.elevated]) {
        final r = VendorRiskTierCatalog.byTier(t)!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('GDPR Art. 28'),
          isTrue,
          reason: '${t.name}: PHI-touching vendors are GDPR processors',
        );
      }
    });

    test('critical tier MUST cite HIPAA business associate requirements', () {
      final r = VendorRiskTierCatalog.byTier(VendorRiskTier.critical)!;
      final blob = r.regulatoryRefs.join(' | ');
      expect(
        blob.contains('HIPAA §164.308(b)') || blob.contains('HIPAA §164.314'),
        isTrue,
        reason: 'plain-text PHI vendor is a HIPAA business associate',
      );
    });

    test(
      'mandatory artifact monotonicity: higher tier ⊇ lower tier on PHI gates',
      () {
        final tiers = [
          VendorRiskTier.minimal,
          VendorRiskTier.standard,
          VendorRiskTier.elevated,
          VendorRiskTier.critical,
        ];
        for (var i = 0; i < tiers.length - 1; i++) {
          final lower = VendorRiskTierCatalog.byTier(tiers[i])!;
          final higher = VendorRiskTierCatalog.byTier(tiers[i + 1])!;
          for (final artifact in [
            VendorDiligenceArtifact.dpa,
            VendorDiligenceArtifact.soc2TypeII,
          ]) {
            if (lower.mandatoryArtifacts.contains(artifact)) {
              expect(
                higher.mandatoryArtifacts,
                contains(artifact),
                reason:
                    '${higher.tier.name} MUST include $artifact since ${lower.tier.name} requires it',
              );
            }
          }
        }
      },
    );
  });

  group('requiresBaa / requiresDpa helpers', () {
    test('requiresBaa true ONLY for critical', () {
      for (final t in VendorRiskTier.values) {
        expect(requiresBaa(t), t == VendorRiskTier.critical, reason: t.name);
      }
    });

    test(
      'requiresDpa true for critical + elevated + standard, false for minimal',
      () {
        expect(requiresDpa(VendorRiskTier.critical), isTrue);
        expect(requiresDpa(VendorRiskTier.elevated), isTrue);
        expect(requiresDpa(VendorRiskTier.standard), isTrue);
        expect(
          requiresDpa(VendorRiskTier.minimal),
          isFalse,
          reason:
              'minimal vendors hold no business confidential data — DPA not warranted',
        );
      },
    );
  });
}
