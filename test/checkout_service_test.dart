import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/billing/checkout_service.dart';
import 'package:psyclinicai/services/billing/subscription_service.dart';

void main() {
  test('rejects a non-paid tier', () async {
    final svc = CheckoutService(launcher: (_) async => true);
    expect(
      () => svc.startCheckout(SubscriptionTier.free),
      throwsA(isA<CheckoutException>()),
    );
  });

  test('fails clearly (notConfigured) when billing is not wired', () async {
    // Default test build has no BACKEND_URL/STRIPE key → billingConfigured=false.
    final svc = CheckoutService(launcher: (_) async => true);
    try {
      await svc.startCheckout(SubscriptionTier.solo);
      fail('expected CheckoutException');
    } on CheckoutException catch (e) {
      expect(e.notConfigured, isTrue);
      expect(e.message, contains('not configured'));
    }
  });
}
