import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ai_marketplace_models.dart';

/// AI Model Marketplace Service for comprehensive model marketplace management
class AIMarketplaceService {
  static const String _baseUrl = 'https://api.ai-marketplace.com/v1';
  static const String _apiKey = 'demo_key_12345';

  // Cache for marketplace data
  final Map<String, MarketplaceAIModel> _modelsCache = {};
  final Map<String, ModelVendor> _vendorsCache = {};
  final Map<String, ModelPurchase> _purchasesCache = {};
  final Map<String, ModelSubscription> _subscriptionsCache = {};

  // Stream controllers for real-time updates
  final StreamController<MarketplaceAIModel> _modelController =
      StreamController<MarketplaceAIModel>.broadcast();
  final StreamController<ModelPurchase> _purchaseController =
      StreamController<ModelPurchase>.broadcast();
  final StreamController<ModelSubscription> _subscriptionController =
      StreamController<ModelSubscription>.broadcast();

  // Search and filter state
  ModelSearchFilters? _currentFilters;
  String? _currentSearchQuery;
  int _currentPage = 1;
  int _pageSize = 20;

  /// Get stream for model updates
  Stream<MarketplaceAIModel> get modelStream => _modelController.stream;

  /// Get stream for purchase updates
  Stream<ModelPurchase> get purchaseStream => _purchaseController.stream;

  /// Get stream for subscription updates
  Stream<ModelSubscription> get subscriptionStream => _subscriptionController.stream;

  /// Get current search filters
  ModelSearchFilters? get currentFilters => _currentFilters;

  /// Get current search query
  String? get currentSearchQuery => _currentSearchQuery;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get page size
  int get pageSize => _pageSize;

  /// Get available AI models from marketplace
  Future<List<MarketplaceAIModel>> getAvailableModels({
    ModelSearchFilters? filters,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Update current state
      _currentFilters = filters;
      _currentSearchQuery = searchQuery;
      _currentPage = page;
      _pageSize = pageSize;

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      if (filters != null) {
        if (filters.categories != null) {
          queryParams['categories'] = filters.categories!
              .map((c) => c.name)
              .join(',');
        }
        if (filters.licenseTypes != null) {
          queryParams['license_types'] = filters.licenseTypes!
              .map((l) => l.name)
              .join(',');
        }
        if (filters.pricingModels != null) {
          queryParams['pricing_models'] = filters.pricingModels!
              .map((p) => p.name)
              .join(',');
        }
        if (filters.minPrice != null) {
          queryParams['min_price'] = filters.minPrice!.toString();
        }
        if (filters.maxPrice != null) {
          queryParams['max_price'] = filters.maxPrice!.toString();
        }
        if (filters.minRating != null) {
          queryParams['min_rating'] = filters.minRating!.toString();
        }
        if (filters.tags != null && filters.tags!.isNotEmpty) {
          queryParams['tags'] = filters.tags!.join(',');
        }
        if (filters.vendors != null && filters.vendors!.isNotEmpty) {
          queryParams['vendors'] = filters.vendors!.join(',');
        }
        if (filters.useCases != null && filters.useCases!.isNotEmpty) {
          queryParams['use_cases'] = filters.useCases!.join(',');
        }
        if (filters.industries != null && filters.industries!.isNotEmpty) {
          queryParams['industries'] = filters.industries!.join(',');
        }
        if (filters.isCustomizable != null) {
          queryParams['customizable'] = filters.isCustomizable!.toString();
        }
      }

      final uri = Uri.parse('$_baseUrl/models').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = (data['models'] as List)
            .map((json) => MarketplaceAIModel.fromJson(json))
            .toList();

        // Update cache
        for (final model in models) {
          _modelsCache[model.id] = model;
        }

        return models;
      } else {
        throw Exception('Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockModels();
    }
  }

  /// Get AI model by ID
  Future<MarketplaceAIModel?> getModelById(String modelId) async {
    try {
      // Check cache first
      if (_modelsCache.containsKey(modelId)) {
        return _modelsCache[modelId];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/models/$modelId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = MarketplaceAIModel.fromJson(data);
        _modelsCache[modelId] = model;
        return model;
      } else {
        throw Exception('Failed to load model: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockModels().firstWhere(
        (model) => model.id == modelId,
        orElse: () => _getMockModels().first,
      );
    }
  }

  /// Get model vendors
  Future<List<ModelVendor>> getVendors() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/vendors'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vendors = (data['vendors'] as List)
            .map((json) => ModelVendor.fromJson(json))
            .toList();

        // Update cache
        for (final vendor in vendors) {
          _vendorsCache[vendor.id] = vendor;
        }

        return vendors;
      } else {
        throw Exception('Failed to load vendors: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockVendors();
    }
  }

  /// Get vendor by ID
  Future<ModelVendor?> getVendorById(String vendorId) async {
    try {
      // Check cache first
      if (_vendorsCache.containsKey(vendorId)) {
        return _vendorsCache[vendorId];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/vendors/$vendorId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vendor = ModelVendor.fromJson(data);
        _vendorsCache[vendorId] = vendor;
        return vendor;
      } else {
        throw Exception('Failed to load vendor: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockVendors().firstWhere(
        (vendor) => vendor.id == vendorId,
        orElse: () => _getMockVendors().first,
      );
    }
  }

  /// Purchase AI model
  Future<ModelPurchase> purchaseModel({
    required String modelId,
    required String userId,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/purchases'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model_id': modelId,
          'user_id': userId,
          'payment_method': paymentMethod,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final purchase = ModelPurchase.fromJson(data);
        _purchasesCache[purchase.id] = purchase;

        // Notify listeners
        _purchaseController.add(purchase);

        return purchase;
      } else {
        throw Exception('Failed to purchase model: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock purchase for demo purposes
      final model = await getModelById(modelId);
      if (model == null) {
        throw Exception('Model not found');
      }

      final purchase = ModelPurchase(
        id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        modelId: modelId,
        modelName: model.name,
        price: model.price,
        currency: model.currency,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        licenseKey: 'LIC_${DateTime.now().millisecondsSinceEpoch}',
        status: 'completed',
        paymentMethod: paymentMethod,
        transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        invoiceUrl: 'https://invoice.example.com/${DateTime.now().millisecondsSinceEpoch}',
        metadata: metadata ?? {},
      );

      _purchasesCache[purchase.id] = purchase;
      _purchaseController.add(purchase);

      return purchase;
    }
  }

  /// Subscribe to AI model
  Future<ModelSubscription> subscribeToModel({
    required String modelId,
    required String userId,
    required String planId,
    required String planName,
    required double monthlyPrice,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model_id': modelId,
          'user_id': userId,
          'plan_id': planId,
          'plan_name': planName,
          'monthly_price': monthlyPrice,
          'payment_method': paymentMethod,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final subscription = ModelSubscription.fromJson(data);
        _subscriptionsCache[subscription.id] = subscription;

        // Notify listeners
        _subscriptionController.add(subscription);

        return subscription;
      } else {
        throw Exception('Failed to subscribe to model: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock subscription for demo purposes
      final model = await getModelById(modelId);
      if (model == null) {
        throw Exception('Model not found');
      }

      final subscription = ModelSubscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        modelId: modelId,
        modelName: model.name,
        planId: planId,
        planName: planName,
        monthlyPrice: monthlyPrice,
        currency: model.currency,
        startDate: DateTime.now(),
        nextBillingDate: DateTime.now().add(const Duration(days: 30)),
        status: 'active',
        autoRenew: true,
        usageLimit: 1000,
        currentUsage: 0,
        paymentMethod: paymentMethod,
        metadata: metadata ?? {},
      );

      _subscriptionsCache[subscription.id] = subscription;
      _subscriptionController.add(subscription);

      return subscription;
    }
  }

  /// Get user purchases
  Future<List<ModelPurchase>> getUserPurchases(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/purchases'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final purchases = (data['purchases'] as List)
            .map((json) => ModelPurchase.fromJson(json))
            .toList();

        // Update cache
        for (final purchase in purchases) {
          _purchasesCache[purchase.id] = purchase;
        }

        return purchases;
      } else {
        throw Exception('Failed to load purchases: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockPurchases().where((p) => p.userId == userId).toList();
    }
  }

  /// Get user subscriptions
  Future<List<ModelSubscription>> getUserSubscriptions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/subscriptions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final subscriptions = (data['subscriptions'] as List)
            .map((json) => ModelSubscription.fromJson(json))
            .toList();

        // Update cache
        for (final subscription in subscriptions) {
          _subscriptionsCache[subscription.id] = subscription;
        }

        return subscriptions;
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockSubscriptions().where((s) => s.userId == userId).toList();
    }
  }

  /// Compare AI models
  Future<ModelComparison> compareModels({
    required List<String> modelIds,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/compare'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model_ids': modelIds,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ModelComparison.fromJson(data);
      } else {
        throw Exception('Failed to compare models: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock comparison for demo purposes
      final models = <MarketplaceAIModel>[];
      for (final modelId in modelIds) {
        final model = await getModelById(modelId);
        if (model != null) {
          models.add(model);
        }
      }

      final comparisonData = <String, Map<String, dynamic>>{};
      for (final model in models) {
        comparisonData[model.id] = {
          'accuracy': model.performance.accuracy,
          'latency': model.performance.latency,
          'price': model.price,
          'rating': model.averageRating,
          'downloads': model.downloads,
        };
      }

      return ModelComparison(
        id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
        modelIds: modelIds,
        models: models,
        comparisonData: comparisonData,
        createdAt: DateTime.now(),
        createdBy: userId,
      );
    }
  }

  /// Get model analytics
  Future<ModelUsageAnalytics> getModelAnalytics({
    required String modelId,
    required String userId,
    required String operation,
    required Map<String, dynamic> parameters,
    required Map<String, dynamic> results,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/$modelId/analytics'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'operation': operation,
          'parameters': parameters,
          'results': results,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ModelUsageAnalytics.fromJson(data);
      } else {
        throw Exception('Failed to record analytics: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock analytics for demo purposes
      return ModelUsageAnalytics(
        id: 'analytics_${DateTime.now().millisecondsSinceEpoch}',
        modelId: modelId,
        userId: userId,
        timestamp: DateTime.now(),
        operation: operation,
        inputSize: parameters.length,
        outputSize: results.length,
        processingTime: 0.5,
        success: true,
        parameters: parameters,
        results: results,
      );
    }
  }

  /// Search models with advanced filters
  Future<List<MarketplaceAIModel>> searchModels({
    String? query,
    ModelSearchFilters? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    return getAvailableModels(
      filters: filters,
      searchQuery: query,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get trending models
  Future<List<MarketplaceAIModel>> getTrendingModels({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models/trending?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = (data['models'] as List)
            .map((json) => MarketplaceAIModel.fromJson(json))
            .toList();

        return models;
      } else {
        throw Exception('Failed to load trending models: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock trending models for demo purposes
      final allModels = _getMockModels();
      allModels.sort((a, b) => b.downloads.compareTo(a.downloads));
      return allModels.take(limit).toList();
    }
  }

  /// Get recommended models for user
  Future<List<MarketplaceAIModel>> getRecommendedModels({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/recommendations?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = (data['models'] as List)
            .map((json) => MarketplaceAIModel.fromJson(json))
            .toList();

        return models;
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock recommendations for demo purposes
      final allModels = _getMockModels();
      allModels.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      return allModels.take(limit).toList();
    }
  }

  /// Clear search filters
  void clearFilters() {
    _currentFilters = null;
    _currentSearchQuery = null;
    _currentPage = 1;
  }

  /// Dispose resources
  void dispose() {
    if (!_modelController.isClosed) {
      _modelController.close();
    }
    if (!_purchaseController.isClosed) {
      _purchaseController.close();
    }
    if (!_subscriptionController.isClosed) {
      _subscriptionController.close();
    }
  }

  // Mock data methods
  List<MarketplaceAIModel> _getMockModels() {
    return [
      MarketplaceAIModel(
        id: 'model_001',
        name: 'PsychDiagnosis Pro',
        description: 'Advanced AI model for psychiatric diagnosis with high accuracy',
        vendorId: 'vendor_001',
        vendorName: 'NeuroTech AI',
        category: AIModelCategory.diagnostic,
        tags: ['psychiatry', 'diagnosis', 'mental-health', 'clinical'],
        licenseType: ModelLicenseType.commercial,
        pricingModel: PricingModel.subscription,
        price: 99.99,
        currency: 'USD',
        pricingTiers: {
          'basic': 49.99,
          'professional': 99.99,
          'enterprise': 199.99,
        },
        performance: ModelPerformanceMetrics(
          accuracy: 0.94,
          precision: 0.92,
          recall: 0.95,
          f1Score: 0.93,
          auc: 0.96,
          latency: 0.8,
          throughput: 150,
          customMetrics: {'sensitivity': 0.94, 'specificity': 0.93},
          lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
          evaluationDataset: 'DSM-5 Clinical Dataset v2.1',
        ),
        requirements: ModelRequirements(
          minimumRam: '8GB',
          minimumStorage: '2GB',
          minimumCpu: 'Intel i5 or equivalent',
          recommendedGpu: 'NVIDIA GTX 1060 or better',
          supportedPlatforms: ['Windows', 'macOS', 'Linux'],
          dependencies: ['Python 3.8+', 'TensorFlow 2.4+', 'CUDA 11.0+'],
          pythonVersion: '3.8+',
          frameworkVersions: {'tensorflow': '2.4+', 'pytorch': '1.8+'},
        ),
        documentation: ModelDocumentation(
          overview: 'Comprehensive psychiatric diagnosis AI model',
          installation: 'Detailed installation guide with dependencies',
          usage: 'API documentation and usage examples',
          api: 'RESTful API with Python SDK',
          examples: 'Clinical case studies and examples',
          troubleshooting: 'Common issues and solutions',
          changelog: 'Version history and updates',
          license: 'Commercial license terms',
          tutorials: ['Quick Start', 'Advanced Usage', 'Integration Guide'],
          support: '24/7 technical support',
        ),
        versions: [
          ModelVersion(
            version: '2.1.0',
            description: 'Latest stable release with improved accuracy',
            releaseDate: DateTime.now().subtract(const Duration(days: 30)),
            features: ['Enhanced DSM-5 compliance', 'Improved accuracy'],
            bugFixes: ['Fixed memory leak', 'Resolved API timeout issues'],
            breakingChanges: [],
            downloadUrl: 'https://download.example.com/v2.1.0',
            checksum: 'sha256:abc123...',
            isLatest: true,
            isStable: true,
          ),
        ],
        reviews: [
          ModelReview(
            id: 'review_001',
            userId: 'user_001',
            userName: 'Dr. Smith',
            rating: 4.8,
            comment: 'Excellent diagnostic accuracy in clinical practice',
            pros: ['High accuracy', 'Easy integration', 'Good support'],
            cons: ['Price could be lower', 'Some false positives'],
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            verified: true,
            helpfulVotes: 12,
          ),
        ],
        averageRating: 4.8,
        totalReviews: 156,
        downloads: 2347,
        status: MarketplaceStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        useCases: ['Clinical diagnosis', 'Research', 'Training'],
        industries: ['Healthcare', 'Mental Health', 'Research'],
        modelSize: '2.3GB',
        trainingData: 'DSM-5 Clinical Dataset (50,000+ cases)',
        lastTrained: '2024-01-15',
        isCustomizable: true,
        supportedLanguages: ['English', 'Spanish', 'French'],
        metadata: {'certification': 'FDA Class II', 'compliance': 'HIPAA'},
      ),
      MarketplaceAIModel(
        id: 'model_002',
        name: 'TherapyBot Assistant',
        description: 'AI-powered therapy assistant for patient support',
        vendorId: 'vendor_002',
        vendorName: 'Mindful AI',
        category: AIModelCategory.therapeutic,
        tags: ['therapy', 'assistant', 'patient-support', 'counseling'],
        licenseType: ModelLicenseType.freemium,
        pricingModel: PricingModel.tiered,
        price: 0.0,
        currency: 'USD',
        pricingTiers: {
          'free': 0.0,
          'premium': 29.99,
          'professional': 79.99,
        },
        performance: ModelPerformanceMetrics(
          accuracy: 0.87,
          precision: 0.85,
          recall: 0.89,
          f1Score: 0.87,
          auc: 0.88,
          latency: 1.2,
          throughput: 100,
          customMetrics: {'engagement': 0.78, 'satisfaction': 0.82},
          lastUpdated: DateTime.now().subtract(const Duration(days: 14)),
          evaluationDataset: 'Therapy Session Dataset v1.5',
        ),
        requirements: ModelRequirements(
          minimumRam: '4GB',
          minimumStorage: '1GB',
          minimumCpu: 'Intel i3 or equivalent',
          recommendedGpu: 'Integrated graphics sufficient',
          supportedPlatforms: ['Web', 'iOS', 'Android'],
          dependencies: ['Node.js 16+', 'React Native 0.68+'],
          pythonVersion: '3.7+',
          frameworkVersions: {'tensorflow': '2.3+', 'scikit-learn': '1.0+'},
        ),
        documentation: ModelDocumentation(
          overview: 'AI therapy assistant for patient support',
          installation: 'Simple web-based setup',
          usage: 'Intuitive interface with guided setup',
          api: 'REST API with mobile SDKs',
          examples: 'Use case scenarios and demos',
          troubleshooting: 'FAQ and support articles',
          changelog: 'Regular updates and improvements',
          license: 'Freemium with premium features',
          tutorials: ['Getting Started', 'Advanced Features', 'API Integration'],
          support: 'Community forum and email support',
        ),
        versions: [
          ModelVersion(
            version: '1.5.2',
            description: 'Enhanced patient engagement features',
            releaseDate: DateTime.now().subtract(const Duration(days: 14)),
            features: ['Improved conversation flow', 'Better emotion detection'],
            bugFixes: ['Fixed session persistence', 'Resolved notification issues'],
            breakingChanges: [],
            downloadUrl: 'https://download.example.com/v1.5.2',
            checksum: 'sha256:def456...',
            isLatest: true,
            isStable: true,
          ),
        ],
        reviews: [
          ModelReview(
            id: 'review_002',
            userId: 'user_002',
            userName: 'Dr. Johnson',
            rating: 4.2,
            comment: 'Good for basic patient support, needs more advanced features',
            pros: ['Easy to use', 'Good patient engagement', 'Free tier available'],
            cons: ['Limited advanced features', 'Sometimes generic responses'],
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
            verified: true,
            helpfulVotes: 8,
          ),
        ],
        averageRating: 4.2,
        totalReviews: 89,
        downloads: 1543,
        status: MarketplaceStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 14)),
        useCases: ['Patient support', 'Basic counseling', 'Education'],
        industries: ['Healthcare', 'Mental Health', 'Education'],
        modelSize: '850MB',
        trainingData: 'Therapy Session Dataset (25,000+ sessions)',
        lastTrained: '2024-01-20',
        isCustomizable: false,
        supportedLanguages: ['English'],
        metadata: {'accessibility': 'WCAG 2.1 AA', 'privacy': 'GDPR compliant'},
      ),
    ];
  }

  List<ModelVendor> _getMockVendors() {
    return [
      ModelVendor(
        id: 'vendor_001',
        name: 'NeuroTech AI',
        description: 'Leading provider of AI solutions for mental health',
        website: 'https://neurotech-ai.com',
        email: 'contact@neurotech-ai.com',
        phone: '+1-555-0123',
        address: '123 AI Boulevard, Tech City, CA 90210',
        country: 'United States',
        industry: 'Healthcare AI',
        foundedYear: 2020,
        employeeCount: 150,
        rating: 4.8,
        totalModels: 12,
        specializations: ['Psychiatry', 'Neurology', 'Mental Health'],
        verificationStatus: 'verified',
        verifiedAt: DateTime.now().subtract(const Duration(days: 365)),
        createdAt: DateTime.now().subtract(const Duration(days: 1095)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        metadata: {'certifications': ['ISO 27001', 'SOC 2'], 'partners': ['Mayo Clinic', 'Stanford']},
      ),
      ModelVendor(
        id: 'vendor_002',
        name: 'Mindful AI',
        description: 'Innovative AI solutions for mindfulness and therapy',
        website: 'https://mindful-ai.com',
        email: 'hello@mindful-ai.com',
        phone: '+1-555-0456',
        address: '456 Wellness Street, Mind City, NY 10001',
        country: 'United States',
        industry: 'Wellness Technology',
        foundedYear: 2021,
        employeeCount: 75,
        rating: 4.2,
        totalModels: 8,
        specializations: ['Therapy', 'Mindfulness', 'Wellness'],
        verificationStatus: 'verified',
        verifiedAt: DateTime.now().subtract(const Duration(days: 180)),
        createdAt: DateTime.now().subtract(const Duration(days: 730)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        metadata: {'certifications': ['HIPAA'], 'partners': ['Calm', 'Headspace']},
      ),
    ];
  }

  List<ModelPurchase> _getMockPurchases() {
    return [
      ModelPurchase(
        id: 'purchase_001',
        userId: 'user_001',
        modelId: 'model_001',
        modelName: 'PsychDiagnosis Pro',
        price: 99.99,
        currency: 'USD',
        purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 335)),
        licenseKey: 'LIC_001_ABC123',
        status: 'active',
        paymentMethod: 'credit_card',
        transactionId: 'TXN_001_DEF456',
        invoiceUrl: 'https://invoice.example.com/001',
        metadata: {'plan': 'professional', 'auto_renew': true},
      ),
    ];
  }

  List<ModelSubscription> _getMockSubscriptions() {
    return [
      ModelSubscription(
        id: 'sub_001',
        userId: 'user_002',
        modelId: 'model_002',
        modelName: 'TherapyBot Assistant',
        planId: 'premium',
        planName: 'Premium Plan',
        monthlyPrice: 29.99,
        currency: 'USD',
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        nextBillingDate: DateTime.now().add(const Duration(days: 15)),
        status: 'active',
        autoRenew: true,
        usageLimit: 1000,
        currentUsage: 450,
        paymentMethod: 'paypal',
        metadata: {'features': ['advanced_analytics', 'priority_support']},
      ),
    ];
  }
}
