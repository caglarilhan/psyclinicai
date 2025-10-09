import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  bool _initialized = false;

  Future<void> initialize({required String publishableKey, String? merchantId}) async {
    if (_initialized) return;
    Stripe.publishableKey = publishableKey;
    if (merchantId != null) {
      Stripe.merchantIdentifier = merchantId;
    }
    _initialized = true;
  }

  Future<void> presentPaymentSheet({required String paymentIntentClientSecret}) async {
    // Not: Gerçek kullanımdaki intent ve ephemeral key üretimi backend tarafından yapılmalıdır.
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        merchantDisplayName: 'PsyClinicAI',
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }
}


