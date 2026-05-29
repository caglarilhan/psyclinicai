import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/billing/subscription_service.dart';

void main() {
  group('SubscriptionTier', () {
    test('seats per tier', () {
      expect(SubscriptionTier.free.seats, 1);
      expect(SubscriptionTier.solo.seats, 1);
      expect(SubscriptionTier.practice.seats, 5);
      expect(SubscriptionTier.group.seats, greaterThan(5));
    });

    test('isPaid', () {
      expect(SubscriptionTier.free.isPaid, isFalse);
      expect(SubscriptionTier.solo.isPaid, isTrue);
    });
  });

  group('SubscriptionService', () {
    test('isActive only when a paid tier is active', () {
      final s = SubscriptionService();
      expect(s.isActive, isFalse);

      s.applyStatus(tier: SubscriptionTier.free, active: true);
      expect(s.isActive, isFalse); // free is never "active"

      s.applyStatus(tier: SubscriptionTier.solo, active: true);
      expect(s.isActive, isTrue);

      s.applyStatus(tier: SubscriptionTier.solo, active: false);
      expect(s.isActive, isFalse);
    });

    test('applyStatus notifies only on change', () {
      final s = SubscriptionService();
      var n = 0;
      s.addListener(() => n++);
      s.applyStatus(tier: SubscriptionTier.solo, active: true);
      s.applyStatus(tier: SubscriptionTier.solo, active: true); // no change
      expect(n, 1);
    });

    test('allowsSeats respects tier', () {
      final s = SubscriptionService()
        ..applyStatus(tier: SubscriptionTier.practice, active: true);
      expect(s.allowsSeats(5), isTrue);
      expect(s.allowsSeats(6), isFalse);
    });

    test('reset returns to free/inactive', () {
      final s = SubscriptionService()
        ..applyStatus(tier: SubscriptionTier.group, active: true)
        ..reset();
      expect(s.tier, SubscriptionTier.free);
      expect(s.isActive, isFalse);
    });

    test('tierFromPriceId maps known prices, defaults to free', () {
      const map = {
        'price_solo': SubscriptionTier.solo,
        'price_group': SubscriptionTier.group,
      };
      expect(
          SubscriptionService.tierFromPriceId('price_solo', priceMap: map),
          SubscriptionTier.solo);
      expect(
          SubscriptionService.tierFromPriceId('price_unknown', priceMap: map),
          SubscriptionTier.free);
    });

    test('isActiveStatus maps Stripe statuses', () {
      expect(SubscriptionService.isActiveStatus('active'), isTrue);
      expect(SubscriptionService.isActiveStatus('trialing'), isTrue);
      expect(SubscriptionService.isActiveStatus('past_due'), isFalse);
      expect(SubscriptionService.isActiveStatus('canceled'), isFalse);
    });

    test('demo mode keeps paid features unlocked', () {
      // Default test build has IS_DEMO=true (no --dart-define), so pilots/local
      // use is never gated.
      expect(SubscriptionService().canUsePaidFeatures, isTrue);
    });
  });
}
