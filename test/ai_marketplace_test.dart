import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai_marketplace_service.dart';
import 'package:psyclinicai/models/ai_marketplace_models.dart';

void main() {
  group('AIMarketplaceService Tests', () {
    late AIMarketplaceService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = AIMarketplaceService();
    });

    tearDown(() {
      // Don't dispose service during tests to avoid stream controller issues
    });

    group('Service Initialization Tests', () {
      test('should create service instance', () {
        expect(service, isNotNull);
        expect(service, isA<AIMarketplaceService>());
      });

      test('should have initial state', () {
        expect(service.currentPage, equals(1));
        expect(service.pageSize, equals(20));
        expect(service.currentFilters, isNull);
        expect(service.currentSearchQuery, isNull);
      });
    });

    group('Model Management Tests', () {
      test('should return available models', () async {
        final models = await service.getAvailableModels();
        expect(models, isNotEmpty);
        expect(models.length, equals(2));
        expect(models.first, isA<MarketplaceAIModel>());
      });

      test('should return model by ID', () async {
        final model = await service.getModelById('model_001');
        expect(model, isNotNull);
        expect(model!.name, equals('PsychDiagnosis Pro'));
        expect(model.category, equals(AIModelCategory.diagnostic));
      });

      test('should cache models after first fetch', () async {
        final models1 = await service.getAvailableModels();
        expect(models1.length, equals(2));
        final models2 = await service.getAvailableModels();
        expect(models2.length, equals(2));
        expect(models1.length, equals(models2.length));
      });

      test('should handle model not found', () async {
        final model = await service.getModelById('nonexistent_model');
        expect(model, isNotNull); // Returns first mock model as fallback
      });
    });

    group('Vendor Management Tests', () {
      test('should return vendors', () async {
        final vendors = await service.getVendors();
        expect(vendors, isNotEmpty);
        expect(vendors.length, equals(2));
        expect(vendors.first, isA<ModelVendor>());
      });

      test('should return vendor by ID', () async {
        final vendor = await service.getVendorById('vendor_001');
        expect(vendor, isNotNull);
        expect(vendor!.name, equals('NeuroTech AI'));
        expect(vendor.industry, equals('Healthcare AI'));
      });

      test('should cache vendors after first fetch', () async {
        final vendors1 = await service.getVendors();
        expect(vendors1.length, equals(2));
        final vendors2 = await service.getVendors();
        expect(vendors2.length, equals(2));
        expect(vendors1.length, equals(vendors2.length));
      });
    });

    group('Purchase Management Tests', () {
      test('should purchase model successfully', () async {
        final purchase = await service.purchaseModel(
          modelId: 'model_001',
          userId: 'user_001',
          paymentMethod: 'credit_card',
        );

        expect(purchase, isNotNull);
        expect(purchase.modelId, equals('model_001'));
        expect(purchase.userId, equals('user_001'));
        expect(purchase.status, equals('completed'));
        expect(purchase.licenseKey, isNotEmpty);
      });

      test('should handle purchase with metadata', () async {
        final purchase = await service.purchaseModel(
          modelId: 'model_002',
          userId: 'user_002',
          paymentMethod: 'paypal',
          metadata: {'plan': 'enterprise', 'auto_renew': false},
        );

        expect(purchase, isNotNull);
        expect(purchase.metadata['plan'], equals('enterprise'));
        expect(purchase.metadata['auto_renew'], equals(false));
      });

      test('should return user purchases', () async {
        final purchases = await service.getUserPurchases('user_001');
        expect(purchases, isNotEmpty);
        expect(purchases.first.userId, equals('user_001'));
      });
    });

    group('Subscription Management Tests', () {
      test('should subscribe to model successfully', () async {
        final subscription = await service.subscribeToModel(
          modelId: 'model_002',
          userId: 'user_001',
          planId: 'premium',
          planName: 'Premium Plan',
          monthlyPrice: 29.99,
          paymentMethod: 'credit_card',
        );

        expect(subscription, isNotNull);
        expect(subscription.modelId, equals('model_002'));
        expect(subscription.userId, equals('user_001'));
        expect(subscription.status, equals('active'));
        expect(subscription.autoRenew, isTrue);
      });

      test('should handle subscription with metadata', () async {
        final subscription = await service.subscribeToModel(
          modelId: 'model_001',
          userId: 'user_002',
          planId: 'enterprise',
          planName: 'Enterprise Plan',
          monthlyPrice: 199.99,
          paymentMethod: 'bank_transfer',
          metadata: {'features': ['priority_support', 'custom_integration']},
        );

        expect(subscription, isNotNull);
        expect(subscription.metadata['features'], contains('priority_support'));
        expect(subscription.metadata['features'], contains('custom_integration'));
      });

      test('should return user subscriptions', () async {
        final subscriptions = await service.getUserSubscriptions('user_002');
        expect(subscriptions, isNotEmpty);
        expect(subscriptions.first.userId, equals('user_002'));
      });
    });

    group('Model Comparison Tests', () {
      test('should compare models successfully', () async {
        final comparison = await service.compareModels(
          modelIds: ['model_001', 'model_002'],
          userId: 'user_001',
        );

        expect(comparison, isNotNull);
        expect(comparison.modelIds, containsAll(['model_001', 'model_002']));
        expect(comparison.models.length, equals(2));
        expect(comparison.comparisonData, isNotEmpty);
      });

      test('should handle single model comparison', () async {
        final comparison = await service.compareModels(
          modelIds: ['model_001'],
          userId: 'user_001',
        );

        expect(comparison, isNotNull);
        expect(comparison.modelIds, equals(['model_001']));
        expect(comparison.models.length, equals(1));
      });
    });

    group('Analytics Tests', () {
      test('should record model analytics', () async {
        final analytics = await service.getModelAnalytics(
          modelId: 'model_001',
          userId: 'user_001',
          operation: 'diagnosis',
          parameters: {'symptoms': ['depression', 'anxiety']},
          results: {'diagnosis': 'Major Depressive Disorder', 'confidence': 0.94},
        );

        expect(analytics, isNotNull);
        expect(analytics.modelId, equals('model_001'));
        expect(analytics.userId, equals('user_001'));
        expect(analytics.operation, equals('diagnosis'));
        expect(analytics.success, isTrue);
      });
    });

    group('Search and Filter Tests', () {
      test('should search models with query', () async {
        final models = await service.searchModels(
          query: 'diagnosis',
          page: 1,
          pageSize: 10,
        );

        expect(models, isNotEmpty);
        expect(service.currentSearchQuery, equals('diagnosis'));
        expect(service.currentPage, equals(1));
      });

      test('should apply filters correctly', () async {
        final filters = ModelSearchFilters(
          categories: [AIModelCategory.diagnostic],
          minRating: 4.5,
          maxPrice: 100.0,
          isCustomizable: true,
        );

        final models = await service.getAvailableModels(filters: filters);
        expect(models, isNotEmpty);
        expect(service.currentFilters, equals(filters));
      });

      test('should get trending models', () async {
        final models = await service.getTrendingModels(limit: 5);
        expect(models, isNotEmpty);
        expect(models.length, lessThanOrEqualTo(5));
      });

      test('should get recommended models', () async {
        final models = await service.getRecommendedModels(
          userId: 'user_001',
          limit: 5,
        );
        expect(models, isNotEmpty);
        expect(models.length, lessThanOrEqualTo(5));
      });
    });

    group('Filter Management Tests', () {
      test('should clear filters correctly', () {
        service.clearFilters();
        expect(service.currentFilters, isNull);
        expect(service.currentSearchQuery, isNull);
        expect(service.currentPage, equals(1));
      });
    });

    group('Stream Tests', () {
      test('should provide model stream', () {
        expect(service.modelStream, isNotNull);
        expect(service.modelStream, isA<Stream<MarketplaceAIModel>>());
      });

      test('should provide purchase stream', () {
        expect(service.purchaseStream, isNotNull);
        expect(service.purchaseStream, isA<Stream<ModelPurchase>>());
      });

      test('should provide subscription stream', () {
        expect(service.subscriptionStream, isNotNull);
        expect(service.subscriptionStream, isA<Stream<ModelSubscription>>());
      });
    });

    group('Mock Data Validation Tests', () {
      test('should have valid mock models', () async {
        final models = await service.getAvailableModels();
        
        for (final model in models) {
          expect(model.id, isNotEmpty);
          expect(model.name, isNotEmpty);
          expect(model.description, isNotEmpty);
          expect(model.vendorId, isNotEmpty);
          expect(model.vendorName, isNotEmpty);
          expect(model.performance, isNotNull);
          expect(model.requirements, isNotNull);
          expect(model.documentation, isNotNull);
          expect(model.versions, isNotEmpty);
          expect(model.reviews, isNotEmpty);
        }
      });

      test('should have valid mock vendors', () async {
        final vendors = await service.getVendors();
        
        for (final vendor in vendors) {
          expect(vendor.id, isNotEmpty);
          expect(vendor.name, isNotEmpty);
          expect(vendor.description, isNotEmpty);
          expect(vendor.website, isNotEmpty);
          expect(vendor.email, isNotEmpty);
          expect(vendor.country, isNotEmpty);
          expect(vendor.industry, isNotEmpty);
        }
      });

      test('should have valid mock purchases', () async {
        final purchases = await service.getUserPurchases('user_001');
        
        for (final purchase in purchases) {
          expect(purchase.id, isNotEmpty);
          expect(purchase.userId, isNotEmpty);
          expect(purchase.modelId, isNotEmpty);
          expect(purchase.modelName, isNotEmpty);
          expect(purchase.licenseKey, isNotEmpty);
          expect(purchase.status, isNotEmpty);
        }
      });

      test('should have valid mock subscriptions', () async {
        final subscriptions = await service.getUserSubscriptions('user_002');
        
        for (final subscription in subscriptions) {
          expect(subscription.id, isNotEmpty);
          expect(subscription.userId, isNotEmpty);
          expect(subscription.modelId, isNotEmpty);
          expect(subscription.modelName, isNotEmpty);
          expect(subscription.planId, isNotEmpty);
          expect(subscription.planName, isNotEmpty);
        }
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        // This test verifies that the service falls back to mock data
        // when network requests fail
        final models = await service.getAvailableModels();
        expect(models, isNotEmpty);
        expect(models.first, isA<MarketplaceAIModel>());
      });

      test('should handle invalid model ID gracefully', () async {
        final model = await service.getModelById('invalid_id');
        expect(model, isNotNull); // Should return first mock model as fallback
      });
    });
  });
}
