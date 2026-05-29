import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../config/build_config.dart';
import 'subscription_service.dart';

/// Starts a Stripe Checkout flow for a [SubscriptionTier].
///
/// Stripe Checkout sessions MUST be created server-side (the secret key never
/// touches the client), so this calls our backend (`BACKEND_URL` →
/// `/createCheckoutSession`) and redirects the browser to the returned URL.
/// When the backend/Stripe isn't configured yet, it fails with a clear,
/// non-configured error instead of a broken redirect.
class CheckoutService {
  CheckoutService({http.Client? client, Future<bool> Function(Uri)? launcher})
      : _client = client ?? http.Client(),
        _launch = launcher ?? _defaultLaunch;

  final http.Client _client;
  final Future<bool> Function(Uri) _launch;

  static Future<bool> _defaultLaunch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.platformDefault);

  /// Creates a checkout session for [tier] and redirects to Stripe.
  /// Throws [CheckoutException] (notConfigured set) when billing isn't wired.
  Future<void> startCheckout(
    SubscriptionTier tier, {
    String? customerEmail,
  }) async {
    if (!tier.isPaid) {
      throw const CheckoutException('Select a paid plan to continue.');
    }
    if (!BuildConfig.billingConfigured) {
      throw const CheckoutException(
        'Billing is not configured yet. Please contact us to start a plan.',
        notConfigured: true,
      );
    }

    final url = await _createSession(tier, customerEmail);
    final ok = await _launch(Uri.parse(url));
    if (!ok) {
      throw const CheckoutException('Could not open the checkout page.');
    }
  }

  Future<String> _createSession(
      SubscriptionTier tier, String? customerEmail) async {
    try {
      final resp = await _client
          .post(
            Uri.parse('${BuildConfig.backendUrl}/createCheckoutSession'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'tier': tier.name,
              if (customerEmail != null) 'email': customerEmail,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        throw CheckoutException('Checkout failed (${resp.statusCode}).');
      }
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final url = decoded['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const CheckoutException('Checkout session had no URL.');
      }
      return url;
    } on CheckoutException {
      rethrow;
    } catch (e) {
      throw CheckoutException('Could not reach the billing service. $e');
    }
  }

  void dispose() => _client.close();
}

class CheckoutException implements Exception {
  const CheckoutException(this.message, {this.notConfigured = false});
  final String message;
  final bool notConfigured;

  @override
  String toString() => 'CheckoutException: $message';
}
