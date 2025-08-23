import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:psyclinicai/models/ai_marketplace_models.dart';

/// AI Model Marketplace Service for PsyClinicAI
/// Handles browsing, installing, and managing third-party AI models
class AIModelMarketplaceService {
  static final AIModelMarketplaceService _instance = AIModelMarketplaceService._internal();
  factory AIModelMarketplaceService() => _instance;
  AIModelMarketplaceService._internal();

  // Mock data storage
  final List<MarketplaceModel> _availableModels = [];
  final List<InstalledModel> _installedModels = [];
  final List<ModelProvider> _providers = [];
  final List<ModelReview> _reviews = [];
  
  // Stream controllers for real-time updates
  final StreamController<MarketplaceModel> _modelController = StreamController<MarketplaceModel>.broadcast();
  final StreamController<InstalledModel> _installedModelController = StreamController<InstalledModel>.broadcast();
  final StreamController<String> _marketplaceLogController = StreamController<String>.broadcast();
  
  // Streams
  Stream<MarketplaceModel> get modelStream => _modelController.stream;
  Stream<InstalledModel> get installedModelStream => _installedModelController.stream;
  Stream<String> get marketplaceLogStream => _marketplaceLogController.stream;

  /// Initialize the marketplace service
  Future<void> initialize() async {
    print('🏪 Initializing AI Model Marketplace Service...');
    
    // Initialize mock data
    _initializeMockData();
    
    print('✅ AI Model Marketplace Service initialized successfully');
  }

  /// Initialize mock data
  void _initializeMockData() {
    // Mock providers
    _providers.addAll([
      ModelProvider(
        id: 'provider_001',
        name: 'MindTech AI',
        description: 'Leading provider of mental health AI models with focus on diagnosis and screening',
        website: 'https://mindtech.ai',
        rating: 4.8,
        reviewCount: 156,
        modelsCount: 25,
        specialties: ['depression', 'anxiety', 'diagnosis', 'screening'],
        verified: true,
        contactEmail: 'contact@mindtech.ai',
        supportUrl: 'https://mindtech.ai/support',
        joinedAt: DateTime.now().subtract(const Duration(days: 365)),
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ModelProvider(
        id: 'provider_002',
        name: 'NeuroLogic Systems',
        description: 'Specialized in neurological and cognitive assessment AI models',
        website: 'https://neurologic.ai',
        rating: 4.6,
        reviewCount: 89,
        modelsCount: 18,
        specialties: ['neurology', 'cognitive_assessment', 'monitoring', 'prognosis'],
        verified: true,
        contactEmail: 'info@neurologic.ai',
        supportUrl: 'https://neurologic.ai/support',
        joinedAt: DateTime.now().subtract(const Duration(days: 180)),
        lastActive: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      ModelProvider(
        id: 'provider_003',
        name: 'CrisisGuard AI',
        description: 'Advanced crisis detection and risk assessment AI models',
        website: 'https://crisisguard.ai',
        rating: 4.9,
        reviewCount: 234,
        modelsCount: 12,
        specialties: ['crisis_detection', 'risk_assessment', 'suicide_prevention', 'emergency'],
        verified: true,
        contactEmail: 'support@crisisguard.ai',
        supportUrl: 'https://crisisguard.ai/support',
        joinedAt: DateTime.now().subtract(const Duration(days: 90)),
        lastActive: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ModelProvider(
        id: 'provider_004',
        name: 'TherapyBot Labs',
        description: 'Innovative therapy and treatment recommendation AI models',
        website: 'https://therapybot.ai',
        rating: 4.4,
        reviewCount: 67,
        modelsCount: 15,
        specialties: ['therapy', 'treatment', 'recommendations', 'wellness'],
        verified: false,
        contactEmail: 'hello@therapybot.ai',
        supportUrl: 'https://therapybot.ai/support',
        joinedAt: DateTime.now().subtract(const Duration(days: 45)),
        lastActive: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    // Mock marketplace models
    _availableModels.addAll([
      MarketplaceModel(
        id: 'model_001',
        name: 'DepressionScreen Pro',
        description: 'Advanced depression screening model with 95% accuracy using patient responses and behavioral patterns',
        provider: 'MindTech AI',
        version: '2.1.0',
        category: ModelCategory.screening,
        price: 29.99,
        priceUnit: 'per_month',
        rating: 4.8,
        reviewCount: 89,
        specialties: ['depression', 'screening', 'mental_health'],
        features: [
          'Multi-modal input support',
          'Real-time analysis',
          'Customizable thresholds',
          'Detailed reporting',
          'API integration',
        ],
        performance: ModelPerformance(
          accuracy: 0.95,
          latency: 0.8,
          throughput: 500,
          memoryUsage: 256.0,
          cpuUsage: 15.0,
          customMetrics: {'sensitivity': 0.94, 'specificity': 0.96},
        ),
        documentation: 'Comprehensive documentation with examples and best practices',
        requirements: ['Python 3.8+', 'TensorFlow 2.4+', '8GB RAM'],
        metadata: {'framework': 'TensorFlow', 'architecture': 'Transformer'},
        publishedAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        downloadCount: 1250,
        isVerified: true,
        tags: ['depression', 'screening', 'high_accuracy', 'verified'],
        demoUrl: 'https://demo.mindtech.ai/depression-screen',
        paperUrl: 'https://arxiv.org/abs/2023.12345',
        repositoryUrl: 'https://github.com/mindtech/depression-screen',
      ),
      MarketplaceModel(
        id: 'model_002',
        name: 'AnxietyClassifier Elite',
        description: 'State-of-the-art anxiety disorder classification with support for multiple anxiety types',
        provider: 'MindTech AI',
        version: '1.8.0',
        category: ModelCategory.diagnosis,
        price: 39.99,
        priceUnit: 'per_month',
        rating: 4.7,
        reviewCount: 67,
        specialties: ['anxiety', 'classification', 'diagnosis'],
        features: [
          'Multi-class classification',
          'Severity assessment',
          'Treatment recommendations',
          'Progress tracking',
          'Clinical validation',
        ],
        performance: ModelPerformance(
          accuracy: 0.92,
          latency: 1.2,
          throughput: 400,
          memoryUsage: 320.0,
          cpuUsage: 20.0,
          customMetrics: {'precision': 0.91, 'recall': 0.93},
        ),
        documentation: 'Detailed API documentation with integration examples',
        requirements: ['Python 3.9+', 'PyTorch 1.12+', '16GB RAM'],
        metadata: {'framework': 'PyTorch', 'architecture': 'BERT'},
        publishedAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        downloadCount: 890,
        isVerified: true,
        tags: ['anxiety', 'classification', 'diagnosis', 'verified'],
        demoUrl: 'https://demo.mindtech.ai/anxiety-classifier',
        paperUrl: 'https://arxiv.org/abs/2023.23456',
        repositoryUrl: 'https://github.com/mindtech/anxiety-classifier',
      ),
      MarketplaceModel(
        id: 'model_003',
        name: 'CrisisDetect Ultra',
        description: 'Real-time crisis detection model for suicide prevention and emergency intervention',
        provider: 'CrisisGuard AI',
        version: '3.0.0',
        category: ModelCategory.riskAssessment,
        price: 99.99,
        priceUnit: 'per_month',
        rating: 4.9,
        reviewCount: 156,
        specialties: ['crisis_detection', 'suicide_prevention', 'emergency'],
        features: [
          'Real-time monitoring',
          'Multi-channel input',
          'Risk scoring',
          'Emergency alerts',
          '24/7 support',
        ],
        performance: ModelPerformance(
          accuracy: 0.98,
          latency: 0.3,
          throughput: 1000,
          memoryUsage: 512.0,
          cpuUsage: 25.0,
          customMetrics: {'false_positive_rate': 0.01, 'response_time': 0.2},
        ),
        documentation: 'Emergency response documentation with integration guidelines',
        requirements: ['Python 3.10+', 'ONNX Runtime', '32GB RAM'],
        metadata: {'framework': 'ONNX', 'architecture': 'EfficientNet'},
        publishedAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        downloadCount: 567,
        isVerified: true,
        tags: ['crisis', 'emergency', 'high_accuracy', 'verified'],
        demoUrl: 'https://demo.crisisguard.ai/crisis-detect',
        paperUrl: 'https://arxiv.org/abs/2023.34567',
        repositoryUrl: 'https://github.com/crisisguard/crisis-detect',
      ),
      MarketplaceModel(
        id: 'model_004',
        name: 'TherapyRecommend Pro',
        description: 'AI-powered therapy recommendation system based on patient history and preferences',
        provider: 'TherapyBot Labs',
        version: '1.5.0',
        category: ModelCategory.treatment,
        price: 19.99,
        priceUnit: 'per_month',
        rating: 4.3,
        reviewCount: 34,
        specialties: ['therapy', 'treatment', 'recommendations'],
        features: [
          'Personalized recommendations',
          'Evidence-based approaches',
          'Progress tracking',
          'Outcome prediction',
          'Integration ready',
        ],
        performance: ModelPerformance(
          accuracy: 0.87,
          latency: 1.5,
          throughput: 300,
          memoryUsage: 128.0,
          cpuUsage: 12.0,
          customMetrics: {'recommendation_accuracy': 0.89, 'user_satisfaction': 0.85},
        ),
        documentation: 'User guide with integration examples and best practices',
        requirements: ['Python 3.8+', 'Scikit-learn 1.0+', '4GB RAM'],
        metadata: {'framework': 'Scikit-learn', 'architecture': 'Random Forest'},
        publishedAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
        downloadCount: 234,
        isVerified: false,
        tags: ['therapy', 'recommendations', 'personalized'],
        demoUrl: 'https://demo.therapybot.ai/therapy-recommend',
        paperUrl: 'https://arxiv.org/abs/2023.45678',
        repositoryUrl: 'https://github.com/therapybot/therapy-recommend',
      ),
      MarketplaceModel(
        id: 'model_005',
        name: 'NeuroMonitor Plus',
        description: 'Advanced neurological monitoring and cognitive assessment AI model',
        provider: 'NeuroLogic Systems',
        version: '2.2.0',
        category: ModelCategory.monitoring,
        price: 49.99,
        priceUnit: 'per_month',
        rating: 4.6,
        reviewCount: 78,
        specialties: ['neurology', 'cognitive_assessment', 'monitoring'],
        features: [
          'Cognitive assessment',
          'Memory testing',
          'Attention monitoring',
          'Progress tracking',
          'Clinical reports',
        ],
        performance: ModelPerformance(
          accuracy: 0.91,
          latency: 1.8,
          throughput: 250,
          memoryUsage: 256.0,
          cpuUsage: 18.0,
          customMetrics: {'cognitive_accuracy': 0.93, 'memory_precision': 0.89},
        ),
        documentation: 'Clinical documentation with assessment protocols',
        requirements: ['Python 3.9+', 'TensorFlow 2.6+', '16GB RAM'],
        metadata: {'framework': 'TensorFlow', 'architecture': 'LSTM'},
        publishedAt: DateTime.now().subtract(const Duration(days: 75)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        downloadCount: 456,
        isVerified: true,
        tags: ['neurology', 'cognitive', 'monitoring', 'verified'],
        demoUrl: 'https://demo.neurologic.ai/neuro-monitor',
        paperUrl: 'https://arxiv.org/abs/2023.56789',
        repositoryUrl: 'https://github.com/neurologic/neuro-monitor',
      ),
    ]);

    // Mock installed models
    _installedModels.addAll([
      InstalledModel(
        id: 'installed_001',
        name: 'DepressionScreen Pro',
        version: '2.1.0',
        provider: 'MindTech AI',
        status: ModelInstallStatus.active,
        installedAt: DateTime.now().subtract(const Duration(days: 10)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        size: 256.0,
        configuration: {'auto_update': true, 'log_level': 'info'},
        dependencies: ['tensorflow', 'numpy', 'pandas'],
        usageStats: {'total_requests': 1250, 'success_rate': 0.98},
      ),
      InstalledModel(
        id: 'installed_002',
        name: 'CrisisDetect Ultra',
        version: '3.0.0',
        provider: 'CrisisGuard AI',
        status: ModelInstallStatus.active,
        installedAt: DateTime.now().subtract(const Duration(days: 5)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        size: 512.0,
        configuration: {'emergency_mode': true, 'alert_threshold': 0.8},
        dependencies: ['onnxruntime', 'numpy', 'scipy'],
        usageStats: {'total_requests': 890, 'success_rate': 0.99},
      ),
    ]);

    // Mock reviews
    _reviews.addAll([
      ModelReview(
        id: 'review_001',
        modelId: 'model_001',
        userId: 'user_001',
        userName: 'Dr. Sarah Johnson',
        rating: 5.0,
        title: 'Excellent depression screening tool',
        comment: 'This model has significantly improved our screening accuracy. Easy to integrate and very reliable.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        tags: ['accurate', 'easy_to_use', 'reliable'],
        verified: true,
        helpfulCount: 12,
        images: [],
      ),
      ModelReview(
        id: 'review_002',
        modelId: 'model_001',
        userId: 'user_002',
        userName: 'Dr. Michael Chen',
        rating: 4.5,
        title: 'Great tool with room for improvement',
        comment: 'Very accurate predictions, but the API could be more flexible. Overall highly recommended.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        tags: ['accurate', 'needs_improvement', 'recommended'],
        verified: true,
        helpfulCount: 8,
        images: [],
      ),
    ]);
  }

  /// Get all available models
  List<MarketplaceModel> getAvailableModels() {
    return List.unmodifiable(_availableModels);
  }

  /// Get model by ID
  MarketplaceModel? getModel(String modelId) {
    try {
      return _availableModels.firstWhere((model) => model.id == modelId);
    } catch (e) {
      return null;
    }
  }

  /// Get all installed models
  List<InstalledModel> getInstalledModels() {
    return List.unmodifiable(_installedModels);
  }

  /// Get installed model by ID
  InstalledModel? getInstalledModel(String modelId) {
    try {
      return _installedModels.firstWhere((model) => model.id == modelId);
    } catch (e) {
      return null;
    }
  }

  /// Get all providers
  List<ModelProvider> getProviders() {
    return List.unmodifiable(_providers);
  }

  /// Get provider by ID
  ModelProvider? getProvider(String providerId) {
    try {
      return _providers.firstWhere((provider) => provider.id == providerId);
    } catch (e) {
      return null;
    }
  }

  /// Get all reviews
  List<ModelReview> getReviews() {
    return List.unmodifiable(_reviews);
  }

  /// Get reviews for a specific model
  List<ModelReview> getModelReviews(String modelId) {
    return _reviews.where((review) => review.modelId == modelId).toList();
  }

  /// Search models with filters
  List<MarketplaceModel> searchModels({
    String? query,
    ModelCategory? category,
    String? specialty,
    String? provider,
    double? minRating,
    double? maxPrice,
  }) {
    return _availableModels.where((model) {
      // Query filter
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        if (!model.name.toLowerCase().contains(queryLower) &&
            !model.description.toLowerCase().contains(queryLower) &&
            !model.provider.toLowerCase().contains(queryLower)) {
          return false;
        }
      }
      
      // Category filter
      if (category != null && model.category != category) {
        return false;
      }
      
      // Specialty filter
      if (specialty != null && !model.specialties.contains(specialty)) {
        return false;
      }
      
      // Provider filter
      if (provider != null && model.provider != provider) {
        return false;
      }
      
      // Rating filter
      if (minRating != null && model.rating < minRating) {
        return false;
      }
      
      // Price filter
      if (maxPrice != null && model.price > maxPrice) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Install a model
  Future<void> installModel(String modelId) async {
    print('📥 Installing model: $modelId');
    
    final model = getModel(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    // Check if already installed
    final existingInstallation = _installedModels.any((installed) => 
        installed.name == model.name && installed.provider == model.provider);
    
    if (existingInstallation) {
      throw Exception('Model already installed');
    }
    
    // Simulate installation process
    await Future.delayed(Duration(seconds: 3));
    
    // Create installed model
    final installedModel = InstalledModel(
      id: 'installed_${DateTime.now().millisecondsSinceEpoch}',
      name: model.name,
      version: model.version,
      provider: model.provider,
      status: ModelInstallStatus.active,
      installedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      size: model.performance.memoryUsage,
      configuration: {
        'auto_update': true,
        'log_level': 'info',
        'performance_mode': 'balanced',
      },
      dependencies: model.requirements,
      usageStats: {'total_requests': 0, 'success_rate': 1.0},
    );
    
    // Add to installed models
    _installedModels.add(installedModel);
    
    // Update download count
    final modelIndex = _availableModels.indexWhere((m) => m.id == modelId);
    if (modelIndex != -1) {
      final updatedModel = model.copyWith(
        downloadCount: model.downloadCount + 1,
      );
      _availableModels[modelIndex] = updatedModel;
      _modelController.add(updatedModel);
    }
    
    // Notify listeners
    _installedModelController.add(installedModel);
    _marketplaceLogController.add('Model ${model.name} installed successfully');
    
    print('✅ Model installed successfully: $modelId');
  }

  /// Uninstall a model
  Future<void> uninstallModel(String modelId) async {
    print('🗑️ Uninstalling model: $modelId');
    
    final installedModel = getInstalledModel(modelId);
    if (installedModel == null) {
      throw Exception('Installed model not found: $modelId');
    }
    
    // Simulate uninstallation process
    await Future.delayed(Duration(seconds: 2));
    
    // Remove from installed models
    _installedModels.removeWhere((model) => model.id == modelId);
    
    // Notify listeners
    _marketplaceLogController.add('Model ${installedModel.name} uninstalled successfully');
    
    print('✅ Model uninstalled successfully: $modelId');
  }

  /// Update a model
  Future<void> updateModel(String modelId) async {
    print('🔄 Updating model: $modelId');
    
    final installedModel = getInstalledModel(modelId);
    if (installedModel == null) {
      throw Exception('Installed model not found: $modelId');
    }
    
    // Find corresponding marketplace model
    final marketplaceModel = _availableModels.firstWhere(
      (model) => model.name == installedModel.name && model.provider == installedModel.provider,
      orElse: () => throw Exception('Marketplace model not found'),
    );
    
    // Check if update is available
    if (marketplaceModel.version == installedModel.version) {
      throw Exception('Model is already up to date');
    }
    
    // Simulate update process
    await Future.delayed(Duration(seconds: 5));
    
    // Update installed model
    final updatedModel = installedModel.copyWith(
      version: marketplaceModel.version,
      lastUpdated: DateTime.now(),
      status: ModelInstallStatus.active,
      size: marketplaceModel.performance.memoryUsage,
      configuration: {
        ...installedModel.configuration,
        'last_update': DateTime.now().toIso8601String(),
      },
    );
    
    // Update in list
    final index = _installedModels.indexWhere((model) => model.id == modelId);
    if (index != -1) {
      _installedModels[index] = updatedModel;
      _installedModelController.add(updatedModel);
    }
    
    // Notify listeners
    _marketplaceLogController.add('Model ${installedModel.name} updated to version ${marketplaceModel.version}');
    
    print('✅ Model updated successfully: $modelId');
  }

  /// Test a model
  Future<Map<String, dynamic>> testModel(String modelId, Map<String, dynamic> testData) async {
    print('🧪 Testing model: $modelId');
    
    final model = getModel(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    // Simulate testing process
    await Future.delayed(Duration(seconds: 2));
    
    // Generate mock test results
    final results = {
      'model_id': modelId,
      'test_timestamp': DateTime.now().toIso8601String(),
      'execution_time': Random().nextDouble() * 2.0 + 0.5,
      'accuracy': model.performance.accuracy + Random().nextDouble() * 0.1 - 0.05,
      'latency': model.performance.latency + Random().nextDouble() * 0.5 - 0.25,
      'throughput': model.performance.throughput + Random().nextInt(100) - 50,
      'test_data_size': testData.length,
      'success': true,
    };
    
    print('✅ Model test completed: $modelId');
    return results;
  }

  /// Compare models
  Future<ModelPerformanceComparison> compareModels(List<String> modelIds) async {
    print('🔍 Comparing models: ${modelIds.join(', ')}');
    
    if (modelIds.length < 2) {
      throw Exception('At least 2 models required for comparison');
    }
    
    if (modelIds.length > 5) {
      throw Exception('Maximum 5 models allowed for comparison');
    }
    
    // Get models
    final models = modelIds.map((id) => getModel(id)).whereType<MarketplaceModel>().toList();
    if (models.length != modelIds.length) {
      throw Exception('Some models not found');
    }
    
    // Simulate comparison process
    await Future.delayed(Duration(seconds: 3));
    
    // Calculate scores for each model
    final scores = <String, double>{};
    final detailedMetrics = <String, ModelComparisonMetrics>{};
    
    for (final model in models) {
      final score = model.performance.performanceScore;
      scores[model.id] = score;
      
      detailedMetrics[model.id] = ModelComparisonMetrics(
        modelId: model.id,
        modelName: model.name,
        accuracy: model.performance.accuracy,
        latency: model.performance.latency,
        throughput: model.performance.throughput,
        price: model.price,
        rating: model.rating,
        downloadCount: model.downloadCount,
        customMetrics: model.performance.customMetrics,
      );
    }
    
    // Find winner
    final winner = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    // Generate insights
    final insights = _generateComparisonInsights(models, scores);
    
    final comparison = ModelPerformanceComparison(
      winner: winner,
      insights: insights,
      scores: scores,
      detailedMetrics: detailedMetrics,
    );
    
    print('✅ Model comparison completed');
    return comparison;
  }

  /// Generate comparison insights
  List<String> _generateComparisonInsights(List<MarketplaceModel> models, Map<String, double> scores) {
    final insights = <String>[];
    
    // Performance insights
    final sortedScores = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topModel = models.firstWhere((m) => m.id == sortedScores.first.key);
    final bottomModel = models.firstWhere((m) => m.id == sortedScores.last.key);
    
    insights.add('${topModel.name} shows the best overall performance with a score of ${sortedScores.first.value.toStringAsFixed(2)}');
    
    if (sortedScores.first.value - sortedScores.last.value > 0.3) {
      insights.add('There is a significant performance gap between the top and bottom performers');
    }
    
    // Price insights
    final priceRange = models.map((m) => m.price).reduce((a, b) => a > b ? a : b) - 
                       models.map((m) => m.price).reduce((a, b) => a < b ? a : b);
    if (priceRange > 50) {
      insights.add('Price varies significantly across models, consider cost-performance ratio');
    }
    
    // Accuracy insights
    final accuracyRange = models.map((m) => m.performance.accuracy).reduce((a, b) => a > b ? a : b) - 
                          models.map((m) => m.performance.accuracy).reduce((a, b) => a < b ? a : b);
    if (accuracyRange > 0.1) {
      insights.add('Accuracy varies considerably - ${topModel.name} leads with ${(topModel.performance.accuracy * 100).toStringAsFixed(1)}%');
    }
    
    // Latency insights
    final fastestModel = models.reduce((a, b) => a.performance.latency < b.performance.latency ? a : b);
    if (fastestModel.performance.latency < 1.0) {
      insights.add('${fastestModel.name} offers the fastest response time at ${fastestModel.performance.latency.toStringAsFixed(2)}s');
    }
    
    // Specialized insights
    if (models.any((m) => m.isVerified) && models.any((m) => !m.isVerified)) {
      insights.add('Consider verified models for production use cases');
    }
    
    if (models.any((m) => m.isFree) && models.any((m) => !m.isFree)) {
      insights.add('Free models available for testing before purchasing premium options');
    }
    
    return insights;
  }

  /// Get marketplace statistics
  Map<String, dynamic> getMarketplaceStatistics() {
    final totalModels = _availableModels.length;
    final freeModels = _availableModels.where((m) => m.isFree).length;
    final premiumModels = _availableModels.where((m) => m.isPremium).length;
    final verifiedModels = _availableModels.where((m) => m.isVerified).length;
    
    final totalProviders = _providers.length;
    final verifiedProviders = _providers.where((p) => p.verified).length;
    
    final totalDownloads = _availableModels.map((m) => m.downloadCount).reduce((a, b) => a + b);
    final averageRating = _availableModels.map((m) => m.rating).reduce((a, b) => a + b) / totalModels;
    
    final totalInstalled = _installedModels.length;
    final activeInstalled = _installedModels.where((m) => m.status == ModelInstallStatus.active).length;
    
    return {
      'total_models': totalModels,
      'free_models': freeModels,
      'premium_models': premiumModels,
      'verified_models': verifiedModels,
      'total_providers': totalProviders,
      'verified_providers': verifiedProviders,
      'total_downloads': totalDownloads,
      'average_rating': averageRating.toStringAsFixed(2),
      'total_installed': totalInstalled,
      'active_installed': activeInstalled,
      'marketplace_health': 'excellent',
    };
  }

  /// Get trending models
  List<MarketplaceModel> getTrendingModels({int limit = 5}) {
    final sortedModels = List<MarketplaceModel>.from(_availableModels);
    
    // Sort by popularity score (downloads + rating + recency)
    sortedModels.sort((a, b) {
      final aScore = a.downloadCount + (a.rating * 100) + (a.isRecent ? 50 : 0);
      final bScore = b.downloadCount + (b.rating * 100) + (b.isRecent ? 50 : 0);
      return bScore.compareTo(aScore);
    });
    
    return sortedModels.take(limit).toList();
  }

  /// Get recommended models
  List<MarketplaceModel> getRecommendedModels({int limit = 5}) {
    final sortedModels = List<MarketplaceModel>.from(_availableModels);
    
    // Sort by quality score (accuracy + rating + verification)
    sortedModels.sort((a, b) {
      final aScore = a.performance.accuracy + (a.rating / 5.0) + (a.isVerified ? 0.2 : 0.0);
      final bScore = b.performance.accuracy + (b.rating / 5.0) + (b.isVerified ? 0.2 : 0.0);
      return bScore.compareTo(aScore);
    });
    
    return sortedModels.take(limit).toList();
  }

  /// Add model review
  Future<void> addReview(ModelReview review) async {
    print('📝 Adding review for model: ${review.modelId}');
    
    // Validate review
    if (review.rating < 1.0 || review.rating > 5.0) {
      throw Exception('Rating must be between 1.0 and 5.0');
    }
    
    if (review.title.isEmpty || review.comment.isEmpty) {
      throw Exception('Title and comment are required');
    }
    
    // Add review
    _reviews.add(review);
    
    // Update model rating
    final modelIndex = _availableModels.indexWhere((m) => m.id == review.modelId);
    if (modelIndex != -1) {
      final model = _availableModels[modelIndex];
      final newRating = (_reviews
          .where((r) => r.modelId == review.modelId)
          .map((r) => r.rating)
          .reduce((a, b) => a + b)) / _reviews.where((r) => r.modelId == review.modelId).length;
      
      final updatedModel = model.copyWith(
        rating: newRating,
        reviewCount: model.reviewCount + 1,
      );
      
      _availableModels[modelIndex] = updatedModel;
      _modelController.add(updatedModel);
    }
    
    print('✅ Review added successfully');
  }

  /// Get model analytics
  Map<String, dynamic> getModelAnalytics(String modelId) {
    final model = getModel(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    final modelReviews = getModelReviews(modelId);
    final averageRating = modelReviews.isNotEmpty 
        ? modelReviews.map((r) => r.rating).reduce((a, b) => a + b) / modelReviews.length
        : 0.0;
    
    final ratingDistribution = <String, int>{
      '5_star': modelReviews.where((r) => r.rating == 5.0).length,
      '4_star': modelReviews.where((r) => r.rating >= 4.0 && r.rating < 5.0).length,
      '3_star': modelReviews.where((r) => r.rating >= 3.0 && r.rating < 4.0).length,
      '2_star': modelReviews.where((r) => r.rating >= 2.0 && r.rating < 3.0).length,
      '1_star': modelReviews.where((r) => r.rating >= 1.0 && r.rating < 2.0).length,
    };
    
    final recentReviews = modelReviews
        .where((r) => r.isRecent)
        .take(5)
        .map((r) => r.summary)
        .toList();
    
    return {
      'model_id': modelId,
      'model_name': model.name,
      'total_reviews': modelReviews.length,
      'average_rating': averageRating.toStringAsFixed(2),
      'rating_distribution': ratingDistribution,
      'recent_reviews': recentReviews,
      'download_trend': 'increasing',
      'performance_metrics': model.performance.summary,
      'market_position': _getMarketPosition(model),
    };
  }

  /// Get market position
  String _getMarketPosition(MarketplaceModel model) {
    final similarModels = _availableModels
        .where((m) => m.category == model.category)
        .toList();
    
    if (similarModels.isEmpty) return 'unique';
    
    final sortedModels = List<MarketplaceModel>.from(similarModels)
      ..sort((a, b) => b.performance.performanceScore.compareTo(a.performance.performanceScore));
    
    final position = sortedModels.indexWhere((m) => m.id == model.id) + 1;
    final total = sortedModels.length;
    
    if (position <= total * 0.2) return 'leader';
    if (position <= total * 0.4) return 'strong';
    if (position <= total * 0.6) return 'average';
    if (position <= total * 0.8) return 'below_average';
    return 'needs_improvement';
  }

  /// Clean up resources
  void dispose() {
    _modelController.close();
    _installedModelController.close();
    _marketplaceLogController.close();
  }
}
