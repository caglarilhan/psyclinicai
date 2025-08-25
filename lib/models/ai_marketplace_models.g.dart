// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_marketplace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelPerformanceMetrics _$ModelPerformanceMetricsFromJson(
  Map<String, dynamic> json,
) => ModelPerformanceMetrics(
  accuracy: (json['accuracy'] as num).toDouble(),
  precision: (json['precision'] as num).toDouble(),
  recall: (json['recall'] as num).toDouble(),
  f1Score: (json['f1Score'] as num).toDouble(),
  auc: (json['auc'] as num).toDouble(),
  latency: (json['latency'] as num).toDouble(),
  throughput: (json['throughput'] as num).toDouble(),
  customMetrics: (json['customMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  evaluationDataset: json['evaluationDataset'] as String,
);

Map<String, dynamic> _$ModelPerformanceMetricsToJson(
  ModelPerformanceMetrics instance,
) => <String, dynamic>{
  'accuracy': instance.accuracy,
  'precision': instance.precision,
  'recall': instance.recall,
  'f1Score': instance.f1Score,
  'auc': instance.auc,
  'latency': instance.latency,
  'throughput': instance.throughput,
  'customMetrics': instance.customMetrics,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'evaluationDataset': instance.evaluationDataset,
};

ModelRequirements _$ModelRequirementsFromJson(Map<String, dynamic> json) =>
    ModelRequirements(
      minimumRam: json['minimumRam'] as String,
      minimumStorage: json['minimumStorage'] as String,
      minimumCpu: json['minimumCpu'] as String,
      recommendedGpu: json['recommendedGpu'] as String,
      supportedPlatforms: (json['supportedPlatforms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dependencies: (json['dependencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      pythonVersion: json['pythonVersion'] as String,
      frameworkVersions: Map<String, String>.from(
        json['frameworkVersions'] as Map,
      ),
    );

Map<String, dynamic> _$ModelRequirementsToJson(ModelRequirements instance) =>
    <String, dynamic>{
      'minimumRam': instance.minimumRam,
      'minimumStorage': instance.minimumStorage,
      'minimumCpu': instance.minimumCpu,
      'recommendedGpu': instance.recommendedGpu,
      'supportedPlatforms': instance.supportedPlatforms,
      'dependencies': instance.dependencies,
      'pythonVersion': instance.pythonVersion,
      'frameworkVersions': instance.frameworkVersions,
    };

ModelDocumentation _$ModelDocumentationFromJson(Map<String, dynamic> json) =>
    ModelDocumentation(
      overview: json['overview'] as String,
      installation: json['installation'] as String,
      usage: json['usage'] as String,
      api: json['api'] as String,
      examples: json['examples'] as String,
      troubleshooting: json['troubleshooting'] as String,
      changelog: json['changelog'] as String,
      license: json['license'] as String,
      tutorials: (json['tutorials'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      support: json['support'] as String,
    );

Map<String, dynamic> _$ModelDocumentationToJson(ModelDocumentation instance) =>
    <String, dynamic>{
      'overview': instance.overview,
      'installation': instance.installation,
      'usage': instance.usage,
      'api': instance.api,
      'examples': instance.examples,
      'troubleshooting': instance.troubleshooting,
      'changelog': instance.changelog,
      'license': instance.license,
      'tutorials': instance.tutorials,
      'support': instance.support,
    };

ModelReview _$ModelReviewFromJson(Map<String, dynamic> json) => ModelReview(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  pros: (json['pros'] as List<dynamic>).map((e) => e as String).toList(),
  cons: (json['cons'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  verified: json['verified'] as bool,
  helpfulVotes: (json['helpfulVotes'] as num).toInt(),
);

Map<String, dynamic> _$ModelReviewToJson(ModelReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'rating': instance.rating,
      'comment': instance.comment,
      'pros': instance.pros,
      'cons': instance.cons,
      'createdAt': instance.createdAt.toIso8601String(),
      'verified': instance.verified,
      'helpfulVotes': instance.helpfulVotes,
    };

ModelVersion _$ModelVersionFromJson(Map<String, dynamic> json) => ModelVersion(
  version: json['version'] as String,
  description: json['description'] as String,
  releaseDate: DateTime.parse(json['releaseDate'] as String),
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bugFixes: (json['bugFixes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  breakingChanges: (json['breakingChanges'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  downloadUrl: json['downloadUrl'] as String,
  checksum: json['checksum'] as String,
  isLatest: json['isLatest'] as bool,
  isStable: json['isStable'] as bool,
);

Map<String, dynamic> _$ModelVersionToJson(ModelVersion instance) =>
    <String, dynamic>{
      'version': instance.version,
      'description': instance.description,
      'releaseDate': instance.releaseDate.toIso8601String(),
      'features': instance.features,
      'bugFixes': instance.bugFixes,
      'breakingChanges': instance.breakingChanges,
      'downloadUrl': instance.downloadUrl,
      'checksum': instance.checksum,
      'isLatest': instance.isLatest,
      'isStable': instance.isStable,
    };

MarketplaceAIModel _$MarketplaceAIModelFromJson(Map<String, dynamic> json) =>
    MarketplaceAIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
      category: $enumDecode(_$AIModelCategoryEnumMap, json['category']),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      licenseType: $enumDecode(_$ModelLicenseTypeEnumMap, json['licenseType']),
      pricingModel: $enumDecode(_$PricingModelEnumMap, json['pricingModel']),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      pricingTiers: (json['pricingTiers'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      performance: ModelPerformanceMetrics.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
      requirements: ModelRequirements.fromJson(
        json['requirements'] as Map<String, dynamic>,
      ),
      documentation: ModelDocumentation.fromJson(
        json['documentation'] as Map<String, dynamic>,
      ),
      versions: (json['versions'] as List<dynamic>)
          .map((e) => ModelVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => ModelReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      downloads: (json['downloads'] as num).toInt(),
      status: $enumDecode(_$MarketplaceStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      useCases: (json['useCases'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      industries: (json['industries'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      modelSize: json['modelSize'] as String,
      trainingData: json['trainingData'] as String,
      lastTrained: json['lastTrained'] as String,
      isCustomizable: json['isCustomizable'] as bool,
      supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$MarketplaceAIModelToJson(MarketplaceAIModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'vendorId': instance.vendorId,
      'vendorName': instance.vendorName,
      'category': _$AIModelCategoryEnumMap[instance.category]!,
      'tags': instance.tags,
      'licenseType': _$ModelLicenseTypeEnumMap[instance.licenseType]!,
      'pricingModel': _$PricingModelEnumMap[instance.pricingModel]!,
      'price': instance.price,
      'currency': instance.currency,
      'pricingTiers': instance.pricingTiers,
      'performance': instance.performance,
      'requirements': instance.requirements,
      'documentation': instance.documentation,
      'versions': instance.versions,
      'reviews': instance.reviews,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'downloads': instance.downloads,
      'status': _$MarketplaceStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'useCases': instance.useCases,
      'industries': instance.industries,
      'modelSize': instance.modelSize,
      'trainingData': instance.trainingData,
      'lastTrained': instance.lastTrained,
      'isCustomizable': instance.isCustomizable,
      'supportedLanguages': instance.supportedLanguages,
      'metadata': instance.metadata,
    };

const _$AIModelCategoryEnumMap = {
  AIModelCategory.nlp: 'nlp',
  AIModelCategory.computerVision: 'computer_vision',
  AIModelCategory.audio: 'audio',
  AIModelCategory.multimodal: 'multimodal',
  AIModelCategory.predictive: 'predictive',
  AIModelCategory.diagnostic: 'diagnostic',
  AIModelCategory.therapeutic: 'therapeutic',
  AIModelCategory.research: 'research',
};

const _$ModelLicenseTypeEnumMap = {
  ModelLicenseType.commercial: 'commercial',
  ModelLicenseType.academic: 'academic',
  ModelLicenseType.openSource: 'open_source',
  ModelLicenseType.proprietary: 'proprietary',
  ModelLicenseType.freemium: 'freemium',
};

const _$PricingModelEnumMap = {
  PricingModel.oneTime: 'one_time',
  PricingModel.subscription: 'subscription',
  PricingModel.usageBased: 'usage_based',
  PricingModel.tiered: 'tiered',
  PricingModel.free: 'free',
};

const _$MarketplaceStatusEnumMap = {
  MarketplaceStatus.active: 'active',
  MarketplaceStatus.inactive: 'inactive',
  MarketplaceStatus.maintenance: 'maintenance',
  MarketplaceStatus.beta: 'beta',
};

ModelPurchase _$ModelPurchaseFromJson(Map<String, dynamic> json) =>
    ModelPurchase(
      id: json['id'] as String,
      userId: json['userId'] as String,
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      licenseKey: json['licenseKey'] as String,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String,
      invoiceUrl: json['invoiceUrl'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ModelPurchaseToJson(ModelPurchase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'modelId': instance.modelId,
      'modelName': instance.modelName,
      'price': instance.price,
      'currency': instance.currency,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'licenseKey': instance.licenseKey,
      'status': instance.status,
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'invoiceUrl': instance.invoiceUrl,
      'metadata': instance.metadata,
    };

ModelSubscription _$ModelSubscriptionFromJson(Map<String, dynamic> json) =>
    ModelSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      autoRenew: json['autoRenew'] as bool,
      usageLimit: (json['usageLimit'] as num).toInt(),
      currentUsage: (json['currentUsage'] as num).toInt(),
      paymentMethod: json['paymentMethod'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ModelSubscriptionToJson(ModelSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'modelId': instance.modelId,
      'modelName': instance.modelName,
      'planId': instance.planId,
      'planName': instance.planName,
      'monthlyPrice': instance.monthlyPrice,
      'currency': instance.currency,
      'startDate': instance.startDate.toIso8601String(),
      'nextBillingDate': instance.nextBillingDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'autoRenew': instance.autoRenew,
      'usageLimit': instance.usageLimit,
      'currentUsage': instance.currentUsage,
      'paymentMethod': instance.paymentMethod,
      'metadata': instance.metadata,
    };

ModelVendor _$ModelVendorFromJson(Map<String, dynamic> json) => ModelVendor(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  website: json['website'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  country: json['country'] as String,
  industry: json['industry'] as String,
  foundedYear: (json['foundedYear'] as num).toInt(),
  employeeCount: (json['employeeCount'] as num).toInt(),
  rating: (json['rating'] as num).toDouble(),
  totalModels: (json['totalModels'] as num).toInt(),
  specializations: (json['specializations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  verificationStatus: json['verificationStatus'] as String,
  verifiedAt: DateTime.parse(json['verifiedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ModelVendorToJson(ModelVendor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'website': instance.website,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'country': instance.country,
      'industry': instance.industry,
      'foundedYear': instance.foundedYear,
      'employeeCount': instance.employeeCount,
      'rating': instance.rating,
      'totalModels': instance.totalModels,
      'specializations': instance.specializations,
      'verificationStatus': instance.verificationStatus,
      'verifiedAt': instance.verifiedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

ModelUsageAnalytics _$ModelUsageAnalyticsFromJson(Map<String, dynamic> json) =>
    ModelUsageAnalytics(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      operation: json['operation'] as String,
      inputSize: (json['inputSize'] as num).toInt(),
      outputSize: (json['outputSize'] as num).toInt(),
      processingTime: (json['processingTime'] as num).toDouble(),
      success: json['success'] as bool,
      errorMessage: json['errorMessage'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>,
      results: json['results'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ModelUsageAnalyticsToJson(
  ModelUsageAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'modelId': instance.modelId,
  'userId': instance.userId,
  'timestamp': instance.timestamp.toIso8601String(),
  'operation': instance.operation,
  'inputSize': instance.inputSize,
  'outputSize': instance.outputSize,
  'processingTime': instance.processingTime,
  'success': instance.success,
  'errorMessage': instance.errorMessage,
  'parameters': instance.parameters,
  'results': instance.results,
};

ModelSearchFilters _$ModelSearchFiltersFromJson(Map<String, dynamic> json) =>
    ModelSearchFilters(
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AIModelCategoryEnumMap, e))
          .toList(),
      licenseTypes: (json['licenseTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ModelLicenseTypeEnumMap, e))
          .toList(),
      pricingModels: (json['pricingModels'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PricingModelEnumMap, e))
          .toList(),
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minRating: (json['minRating'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      vendors: (json['vendors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      useCases: (json['useCases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      industries: (json['industries'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isCustomizable: json['isCustomizable'] as bool?,
      searchQuery: json['searchQuery'] as String?,
    );

Map<String, dynamic> _$ModelSearchFiltersToJson(ModelSearchFilters instance) =>
    <String, dynamic>{
      'categories': instance.categories
          ?.map((e) => _$AIModelCategoryEnumMap[e]!)
          .toList(),
      'licenseTypes': instance.licenseTypes
          ?.map((e) => _$ModelLicenseTypeEnumMap[e]!)
          .toList(),
      'pricingModels': instance.pricingModels
          ?.map((e) => _$PricingModelEnumMap[e]!)
          .toList(),
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'minRating': instance.minRating,
      'tags': instance.tags,
      'vendors': instance.vendors,
      'useCases': instance.useCases,
      'industries': instance.industries,
      'isCustomizable': instance.isCustomizable,
      'searchQuery': instance.searchQuery,
    };

ModelComparison _$ModelComparisonFromJson(Map<String, dynamic> json) =>
    ModelComparison(
      id: json['id'] as String,
      modelIds: (json['modelIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      models: (json['models'] as List<dynamic>)
          .map((e) => MarketplaceAIModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      comparisonData: (json['comparisonData'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, e as Map<String, dynamic>),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$ModelComparisonToJson(ModelComparison instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelIds': instance.modelIds,
      'models': instance.models,
      'comparisonData': instance.comparisonData,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };
