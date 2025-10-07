import 'package:url_launcher/url_launcher.dart';
import '../../models/billing_models.dart';

class MockPaymentProvider {
  Future<Uri> createCheckoutUrl(PaymentIntent intent) async {
    final uri = Uri.parse('https://payments.psyclinic.ai/checkout?intent=${intent.id}&amount=${intent.amount.toStringAsFixed(2)}&currency=${intent.currency}');
    return uri;
  }

  Future<void> openCheckout(PaymentIntent intent) async {
    final url = await createCheckoutUrl(intent);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}


