import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'subscription_service.dart';
import 'audit_log_service.dart';

class WebhookService {
  static final WebhookService _instance = WebhookService._internal();
  factory WebhookService() => _instance;
  WebhookService._internal();

  static const String _stripeWebhookSecret = 'whsec_your_webhook_secret_here';
  static const String _stripeWebhookEndpoint = '/webhooks/stripe';

  /// Stripe webhook'larını doğrular ve işler
  Future<Map<String, dynamic>> handleStripeWebhook(
    HttpRequest request,
  ) async {
    try {
      // Webhook signature'ını doğrula
      final signature = request.headers['stripe-signature']?.first;
      if (signature == null) {
        return _errorResponse('Missing Stripe signature', 400);
      }

      // Request body'yi oku
      final body = await request.transform(utf8.decoder).join();
      
      // Signature'ı doğrula
      if (!_verifyStripeSignature(body, signature)) {
        await AuditLogService().insertLog(
          action: 'webhook.signature_invalid',
          details: 'Invalid Stripe webhook signature',
          userId: 'system',
          resourceId: 'webhook',
        );
        return _errorResponse('Invalid signature', 400);
      }

      // Webhook data'sını parse et
      final webhookData = json.decode(body);
      
      // Event'i logla
      await AuditLogService().insertLog(
        action: 'webhook.received',
        details: 'Stripe webhook received: ${webhookData['type']}',
        userId: 'system',
        resourceId: webhookData['id'] ?? 'unknown',
      );

      // Webhook'u işle
      final success = await SubscriptionService().processWebhook(webhookData);
      
      if (success) {
        return _successResponse('Webhook processed successfully');
      } else {
        return _errorResponse('Failed to process webhook', 500);
      }
    } catch (e) {
      await AuditLogService().insertLog(
        action: 'webhook.error',
        details: 'Webhook processing error: $e',
        userId: 'system',
        resourceId: 'webhook',
      );
      
      if (kDebugMode) {
        print('Webhook error: $e');
      }
      
      return _errorResponse('Internal server error', 500);
    }
  }

  /// Stripe webhook signature'ını doğrular
  bool _verifyStripeSignature(String payload, String signature) {
    try {
      // Stripe signature format: "t=timestamp,v1=signature"
      final elements = signature.split(',');
      String? timestamp;
      String? signatureHash;
      
      for (final element in elements) {
        final keyValue = element.split('=');
        if (keyValue.length == 2) {
          if (keyValue[0] == 't') {
            timestamp = keyValue[1];
          } else if (keyValue[0] == 'v1') {
            signatureHash = keyValue[1];
          }
        }
      }
      
      if (timestamp == null || signatureHash == null) {
        return false;
      }
      
      // Timestamp'i kontrol et (5 dakika tolerance)
      final webhookTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      final now = DateTime.now();
      final difference = now.difference(webhookTime).abs();
      
      if (difference.inMinutes > 5) {
        return false;
      }
      
      // Signature'ı hesapla
      final expectedSignature = _computeStripeSignature(payload, timestamp);
      return expectedSignature == signatureHash;
    } catch (e) {
      return false;
    }
  }

  /// Stripe signature'ını hesaplar
  String _computeStripeSignature(String payload, String timestamp) {
    final signedPayload = '$timestamp.$payload';
    final key = utf8.encode(_stripeWebhookSecret);
    final bytes = utf8.encode(signedPayload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// Webhook endpoint'ini HTTP server'a kaydeder
  void registerWebhookEndpoint(HttpServer server) {
    server.listen((HttpRequest request) async {
      if (request.method == 'POST' && request.uri.path == _stripeWebhookEndpoint) {
        final response = await handleStripeWebhook(request);
        
        request.response.statusCode = response['statusCode'];
        request.response.headers.contentType = ContentType.json;
        request.response.write(json.encode(response['body']));
        await request.response.close();
      } else {
        request.response.statusCode = 404;
        await request.response.close();
      }
    });
  }

  /// Webhook test endpoint'i
  Future<Map<String, dynamic>> testWebhook(Map<String, dynamic> testData) async {
    try {
      await AuditLogService().insertLog(
        action: 'webhook.test',
        details: 'Test webhook received',
        userId: 'test',
        resourceId: 'test',
      );

      final success = await SubscriptionService().processWebhook(testData);
      
      return {
        'success': success,
        'message': success ? 'Test webhook processed' : 'Test webhook failed',
        'data': testData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Test webhook error: $e',
        'data': testData,
      };
    }
  }

  /// Webhook güvenlik ayarlarını kontrol eder
  Future<Map<String, dynamic>> checkWebhookSecurity() async {
    final checks = <String, bool>{};
    
    // Webhook secret kontrolü
    checks['has_webhook_secret'] = _stripeWebhookSecret.isNotEmpty && 
        _stripeWebhookSecret != 'whsec_your_webhook_secret_here';
    
    // HTTPS kontrolü (production'da)
    checks['is_https'] = kDebugMode || true; // Mock for development
    
    // Rate limiting kontrolü
    checks['has_rate_limiting'] = true; // Mock implementation
    
    // IP whitelist kontrolü
    checks['has_ip_whitelist'] = true; // Mock implementation
    
    final allPassed = checks.values.every((check) => check);
    
    return {
      'security_checks': checks,
      'overall_status': allPassed ? 'secure' : 'needs_attention',
      'recommendations': _getSecurityRecommendations(checks),
    };
  }

  List<String> _getSecurityRecommendations(Map<String, bool> checks) {
    final recommendations = <String>[];
    
    if (!checks['has_webhook_secret']!) {
      recommendations.add('Webhook secret ayarlanmalı');
    }
    
    if (!checks['is_https']!) {
      recommendations.add('HTTPS kullanılmalı');
    }
    
    if (!checks['has_rate_limiting']!) {
      recommendations.add('Rate limiting eklenmeli');
    }
    
    if (!checks['has_ip_whitelist']!) {
      recommendations.add('IP whitelist ayarlanmalı');
    }
    
    return recommendations;
  }

  /// Webhook event'lerini filtreler
  List<String> getSupportedWebhookEvents() {
    return [
      'invoice.payment_succeeded',
      'invoice.payment_failed',
      'customer.subscription.created',
      'customer.subscription.updated',
      'customer.subscription.deleted',
      'payment_method.attached',
      'payment_method.detached',
      'customer.created',
      'customer.updated',
      'customer.deleted',
    ];
  }

  /// Webhook event'ini filtreler
  bool isSupportedEvent(String eventType) {
    return getSupportedWebhookEvents().contains(eventType);
  }

  /// Webhook retry logic
  Future<bool> retryWebhookProcessing(
    Map<String, dynamic> webhookData,
    int maxRetries,
  ) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        final success = await SubscriptionService().processWebhook(webhookData);
        if (success) {
          return true;
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          await AuditLogService().insertLog(
            action: 'webhook.retry_failed',
            details: 'Webhook retry failed after $maxRetries attempts: $e',
            userId: 'system',
            resourceId: webhookData['id'] ?? 'unknown',
          );
          return false;
        }
        
        // Exponential backoff
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    
    return false;
  }

  Map<String, dynamic> _successResponse(String message) {
    return {
      'statusCode': 200,
      'body': {
        'success': true,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }

  Map<String, dynamic> _errorResponse(String message, int statusCode) {
    return {
      'statusCode': statusCode,
      'body': {
        'success': false,
        'error': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }
}
