import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/billing/pricing_tier_catalog.dart';

void main() {
  group('PricingTierCatalog — pinned invariants', () {
    test('every PricingTier has exactly one pinned record', () {
      final pinned = PricingTierCatalog.tiers.map((r) => r.tier).toSet();
      expect(pinned, equals(PricingTier.values.toSet()));
      expect(PricingTierCatalog.tiers.length, PricingTier.values.length);
    });

    test('forTier resolves every enum value', () {
      for (final t in PricingTier.values) {
        expect(PricingTierCatalog.forTier(t).tier, t);
      }
    });

    test('byStripePriceIdKey resolves every entry', () {
      for (final r in PricingTierCatalog.tiers) {
        expect(
          PricingTierCatalog.byStripePriceIdKey(r.stripePriceIdKey),
          same(r),
        );
      }
      expect(PricingTierCatalog.byStripePriceIdKey('does-not-exist'), isNull);
    });

    test('every record has populated fields', () {
      for (final r in PricingTierCatalog.tiers) {
        expect(r.publicName, isNotEmpty, reason: r.tier.name);
        expect(r.priceEurMonth, greaterThanOrEqualTo(0), reason: r.tier.name);
        expect(r.includedSeats, greaterThan(0), reason: r.tier.name);
        expect(r.maxSeats, greaterThanOrEqualTo(0), reason: r.tier.name);
        expect(r.trialDays, greaterThanOrEqualTo(0), reason: r.tier.name);
        expect(r.includedFeatures, isNotEmpty, reason: r.tier.name);
        expect(r.stripePriceIdKey, isNotEmpty, reason: r.tier.name);
      }
    });

    test('every Stripe price-id key is unique', () {
      final keys = PricingTierCatalog.tiers
          .map((r) => r.stripePriceIdKey)
          .toList();
      expect(keys.toSet().length, keys.length, reason: 'duplicate Stripe keys');
    });

    test('includedSeats ≤ maxSeats when maxSeats > 0', () {
      for (final r in PricingTierCatalog.tiers) {
        if (r.maxSeats == 0) continue;
        expect(
          r.includedSeats,
          lessThanOrEqualTo(r.maxSeats),
          reason: '${r.tier.name}: includedSeats > maxSeats is contradictory',
        );
      }
    });

    test('every excludedFeatures entry is NOT also in includedFeatures', () {
      for (final r in PricingTierCatalog.tiers) {
        for (final f in r.excludedFeatures) {
          expect(
            r.includedFeatures,
            isNot(contains(f)),
            reason:
                '${r.tier.name}: feature `$f` is in BOTH lists — exclusion '
                'must override inclusion in pinned data, not at runtime',
          );
        }
      }
    });

    test('free tier has 1 seat + no trial + Stripe key = "free"', () {
      final f = PricingTierCatalog.forTier(PricingTier.free);
      expect(f.includedSeats, 1);
      expect(f.maxSeats, 1);
      expect(f.trialDays, 0);
      expect(f.priceEurMonth, 0);
      expect(f.stripePriceIdKey, 'free');
    });

    test('pilot tier has positive monthly price + 14-day trial', () {
      final p = PricingTierCatalog.forTier(PricingTier.pilot);
      expect(p.priceEurMonth, greaterThan(0));
      expect(p.trialDays, 14);
      expect(p.billingCycle, BillingCycle.perMonth);
    });

    test(
      'enterprise tier is contract-only (priceEurMonth==0) + unlimited seats',
      () {
        final e = PricingTierCatalog.forTier(PricingTier.enterprise);
        expect(
          e.priceEurMonth,
          0,
          reason: 'enterprise renders "Contact us" — no headline price',
        );
        expect(e.maxSeats, 0, reason: 'enterprise = unlimited seats');
        expect(e.billingCycle, BillingCycle.perYear);
      },
    );

    test('only enterprise includes baa_signed + sso_saml + dedicated_csm', () {
      const enterpriseOnly = ['baa_signed', 'sso_saml', 'dedicated_csm'];
      for (final r in PricingTierCatalog.tiers) {
        for (final feature in enterpriseOnly) {
          if (r.tier == PricingTier.enterprise) {
            expect(
              r.includedFeatures,
              contains(feature),
              reason: 'enterprise must include $feature',
            );
          } else {
            expect(
              r.includedFeatures,
              isNot(contains(feature)),
              reason:
                  '${r.tier.name} must NOT include enterprise-only $feature',
            );
          }
        }
      }
    });

    test('AI SOAP draft + telehealth start at the pilot tier', () {
      for (final feature in ['ai_soap_draft', 'telehealth_video']) {
        expect(
          PricingTierCatalog.forTier(PricingTier.free).includedFeatures,
          isNot(contains(feature)),
          reason: 'free MUST NOT include paid feature $feature',
        );
        expect(
          PricingTierCatalog.forTier(PricingTier.pilot).includedFeatures,
          contains(feature),
          reason: 'pilot MUST include $feature',
        );
        expect(
          PricingTierCatalog.forTier(PricingTier.enterprise).includedFeatures,
          contains(feature),
          reason: 'enterprise MUST include $feature',
        );
      }
    });

    test('PricingTier ↔ SupportTier parity (M3 catalog)', () {
      // PricingTier names align with M3 support_escalation_matrix
      // SupportTier values: free / pilot / enterprise. Once M3
      // (PR #129) merges, follow-up wires the test to import the
      // enum directly.
      const supportTierNames = {'free', 'pilot', 'enterprise'};
      final pricingTierNames = PricingTier.values.map((t) => t.name).toSet();
      expect(
        pricingTierNames,
        equals(supportTierNames),
        reason:
            'PricingTier names must match SupportTier names in M3 so the '
            'support escalation matrix joins correctly',
      );
    });
  });

  group('isFeatureIncluded', () {
    test('free → ai_soap_draft is false', () {
      expect(isFeatureIncluded(PricingTier.free, 'ai_soap_draft'), isFalse);
    });

    test('pilot → ai_soap_draft is true', () {
      expect(isFeatureIncluded(PricingTier.pilot, 'ai_soap_draft'), isTrue);
    });

    test('enterprise → baa_signed is true', () {
      expect(isFeatureIncluded(PricingTier.enterprise, 'baa_signed'), isTrue);
    });

    test('unknown feature returns false (strict)', () {
      expect(isFeatureIncluded(PricingTier.pilot, 'flying_pony'), isFalse);
    });

    test('explicit exclusion overrides everything', () {
      expect(isFeatureIncluded(PricingTier.free, 'priority_support'), isFalse);
    });
  });

  group('isWithinSeatCap', () {
    test('free: 1 seat OK, 2 seats not', () {
      expect(isWithinSeatCap(PricingTier.free, 1), isTrue);
      expect(isWithinSeatCap(PricingTier.free, 2), isFalse);
    });

    test('pilot: 10 seats OK, 11 not', () {
      expect(isWithinSeatCap(PricingTier.pilot, 10), isTrue);
      expect(isWithinSeatCap(PricingTier.pilot, 11), isFalse);
    });

    test('enterprise: unlimited (always true)', () {
      expect(isWithinSeatCap(PricingTier.enterprise, 1000), isTrue);
      expect(isWithinSeatCap(PricingTier.enterprise, 100000), isTrue);
    });
  });
}
