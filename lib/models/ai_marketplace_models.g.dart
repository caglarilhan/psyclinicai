// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_marketplace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceModel _$MarketplaceModelFromJson(Map<String, dynamic> json) =>
    MarketplaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      provider: json['provider'] as String,
      version: json['version'] as String,
      category: $enumDecode(_$ModelCategoryEnumMap, json['category']),
      price: (json['price'] as num).toDouble(),
      priceUnit: json['priceUnit'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      specialties: (json['specialties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performance: ModelPerformance.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
      documentation: json['documentation'] as String,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      downloadCount: (json['downloadCount'] as num).toInt(),
      isVerified: json['isVerified'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      demoUrl: json['demoUrl'] as String?,
      paperUrl: json['paperUrl'] as String?,
      repositoryUrl: json['repositoryUrl'] as String?,
    );

Map<String, dynamic> _$MarketplaceModelToJson(MarketplaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'provider': instance.provider,
      'version': instance.version,
      'category': _$ModelCategoryEnumMap[instance.category]!,
      'price': instance.price,
      'priceUnit': instance.priceUnit,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'specialties': instance.specialties,
      'features': instance.features,
      'performance': instance.performance,
      'documentation': instance.documentation,
      'requirements': instance.requirements,
      'metadata': instance.metadata,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'downloadCount': instance.downloadCount,
      'isVerified': instance.isVerified,
      'tags': instance.tags,
      'demoUrl': instance.demoUrl,
      'paperUrl': instance.paperUrl,
      'repositoryUrl': instance.repositoryUrl,
    };

const _$ModelCategoryEnumMap = {
  ModelCategory.diagnosis: 'diagnosis',
  ModelCategory.treatment: 'treatment',
  ModelCategory.riskAssessment: 'riskAssessment',
  ModelCategory.prognosis: 'prognosis',
  ModelCategory.screening: 'screening',
  ModelCategory.monitoring: 'monitoring',
};

ModelPerformance _$ModelPerformanceFromJson(Map<String, dynamic> json) =>
    ModelPerformance(
      accuracy: (json['accuracy'] as num).toDouble(),
      latency: (json['latency'] as num).toDouble(),
      throughput: (json['throughput'] as num).toInt(),
      memoryUsage: (json['memoryUsage'] as num).toDouble(),
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      customMetrics: (json['customMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$ModelPerformanceToJson(ModelPerformance instance) =>
    <String, dynamic>{
      'accuracy': instance.accuracy,
      'latency': instance.latency,
      'throughput': instance.throughput,
      'memoryUsage': instance.memoryUsage,
      'cpuUsage': instance.cpuUsage,
      'customMetrics': instance.customMetrics,
    };

InstalledModel _$InstalledModelFromJson(Map<String, dynamic> json) =>
    InstalledModel(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      provider: json['provider'] as String,
      status: $enumDecode(_$ModelInstallStatusEnumMap, json['status']),
      installedAt: DateTime.parse(json['installedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      size: (json['size'] as num).toDouble(),
      configuration: json['configuration'] as Map<String, dynamic>,
      dependencies: (json['dependencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      errorMessage: json['errorMessage'] as String?,
      usageStats: json['usageStats'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$InstalledModelToJson(InstalledModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'provider': instance.provider,
      'status': _$ModelInstallStatusEnumMap[instance.status]!,
      'installedAt': instance.installedAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'size': instance.size,
      'configuration': instance.configuration,
      'dependencies': instance.dependencies,
      'errorMessage': instance.errorMessage,
      'usageStats': instance.usageStats,
    };

const _$ModelInstallStatusEnumMap = {
  ModelInstallStatus.active: 'active',
  ModelInstallStatus.inactive: 'inactive',
  ModelInstallStatus.updating: 'updating',
  ModelInstallStatus.error: 'error',
};

ModelProvider _$ModelProviderFromJson(Map<String, dynamic> json) =>
    ModelProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      website: json['website'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      modelsCount: (json['modelsCount'] as num).toInt(),
      specialties: (json['specialties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      verified: json['verified'] as bool,
      logoUrl: json['logoUrl'] as String?,
      contactEmail: json['contactEmail'] as String?,
      supportUrl: json['supportUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
    );

Map<String, dynamic> _$ModelProviderToJson(ModelProvider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'website': instance.website,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'modelsCount': instance.modelsCount,
      'specialties': instance.specialties,
      'verified': instance.verified,
      'logoUrl': instance.logoUrl,
      'contactEmail': instance.contactEmail,
      'supportUrl': instance.supportUrl,
      'metadata': instance.metadata,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'lastActive': instance.lastActive.toIso8601String(),
    };

ModelReview _$ModelReviewFromJson(Map<String, dynamic> json) => ModelReview(
  id: json['id'] as String,
  modelId: json['modelId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  rating: (json['rating'] as num).toDouble(),
  title: json['title'] as String,
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  verified: json['verified'] as bool,
  helpfulCount: (json['helpfulCount'] as num).toInt(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ModelReviewToJson(ModelReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'userId': instance.userId,
      'userName': instance.userName,
      'rating': instance.rating,
      'title': instance.title,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'tags': instance.tags,
      'verified': instance.verified,
      'helpfulCount': instance.helpfulCount,
      'images': instance.images,
      'metadata': instance.metadata,
    };

ModelComparison _$ModelComparisonFromJson(Map<String, dynamic> json) =>
    ModelComparison(
      id: json['id'] as String,
      modelIds: (json['modelIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comparedAt: DateTime.parse(json['comparedAt'] as String),
      metrics: (json['metrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          ModelComparisonMetrics.fromJson(e as Map<String, dynamic>),
        ),
      ),
      winner: json['winner'] as String,
      insights: (json['insights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModelComparisonToJson(ModelComparison instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelIds': instance.modelIds,
      'comparedAt': instance.comparedAt.toIso8601String(),
      'metrics': instance.metrics,
      'winner': instance.winner,
      'insights': instance.insights,
      'metadata': instance.metadata,
    };

ModelComparisonMetrics _$ModelComparisonMetricsFromJson(
  Map<String, dynamic> json,
) => ModelComparisonMetrics(
  modelId: json['modelId'] as String,
  modelName: json['modelName'] as String,
  accuracy: (json['accuracy'] as num).toDouble(),
  latency: (json['latency'] as num).toDouble(),
  throughput: (json['throughput'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  rating: (json['rating'] as num).toDouble(),
  downloadCount: (json['downloadCount'] as num).toInt(),
  customMetrics: (json['customMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$ModelComparisonMetricsToJson(
  ModelComparisonMetrics instance,
) => <String, dynamic>{
  'modelId': instance.modelId,
  'modelName': instance.modelName,
  'accuracy': instance.accuracy,
  'latency': instance.latency,
  'throughput': instance.throughput,
  'price': instance.price,
  'rating': instance.rating,
  'downloadCount': instance.downloadCount,
  'customMetrics': instance.customMetrics,
};

ModelPerformanceComparison _$ModelPerformanceComparisonFromJson(
  Map<String, dynamic> json,
) => ModelPerformanceComparison(
  winner: json['winner'] as String,
  insights: (json['insights'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  scores: (json['scores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  detailedMetrics: (json['detailedMetrics'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, ModelComparisonMetrics.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$ModelPerformanceComparisonToJson(
  ModelPerformanceComparison instance,
) => <String, dynamic>{
  'winner': instance.winner,
  'insights': instance.insights,
  'scores': instance.scores,
  'detailedMetrics': instance.detailedMetrics,
};

ModelInstallRequest _$ModelInstallRequestFromJson(Map<String, dynamic> json) =>
    ModelInstallRequest(
      modelId: json['modelId'] as String,
      userId: json['userId'] as String,
      licenseKey: json['licenseKey'] as String?,
      configuration: json['configuration'] as Map<String, dynamic>?,
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      customPath: json['customPath'] as String?,
    );

Map<String, dynamic> _$ModelInstallRequestToJson(
  ModelInstallRequest instance,
) => <String, dynamic>{
  'modelId': instance.modelId,
  'userId': instance.userId,
  'licenseKey': instance.licenseKey,
  'configuration': instance.configuration,
  'autoUpdate': instance.autoUpdate,
  'customPath': instance.customPath,
};

ModelInstallResponse _$ModelInstallResponseFromJson(
  Map<String, dynamic> json,
) => ModelInstallResponse(
  success: json['success'] as bool,
  installationId: json['installationId'] as String?,
  message: json['message'] as String?,
  data: json['data'] as Map<String, dynamic>?,
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$ModelInstallResponseToJson(
  ModelInstallResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'installationId': instance.installationId,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
  'timestamp': instance.timestamp.toIso8601String(),
};

ModelTestRequest _$ModelTestRequestFromJson(Map<String, dynamic> json) =>
    ModelTestRequest(
      modelId: json['modelId'] as String,
      testType: json['testType'] as String,
      testData: json['testData'] as Map<String, dynamic>,
      parameters: json['parameters'] as Map<String, dynamic>?,
      iterations: (json['iterations'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ModelTestRequestToJson(ModelTestRequest instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'testType': instance.testType,
      'testData': instance.testData,
      'parameters': instance.parameters,
      'iterations': instance.iterations,
    };

ModelTestResult _$ModelTestResultFromJson(Map<String, dynamic> json) =>
    ModelTestResult(
      testId: json['testId'] as String,
      modelId: json['modelId'] as String,
      success: json['success'] as bool,
      results: json['results'] as Map<String, dynamic>,
      executionTime: (json['executionTime'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModelTestResultToJson(ModelTestResult instance) =>
    <String, dynamic>{
      'testId': instance.testId,
      'modelId': instance.modelId,
      'success': instance.success,
      'results': instance.results,
      'executionTime': instance.executionTime,
      'completedAt': instance.completedAt.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

ModelSearchFilters _$ModelSearchFiltersFromJson(Map<String, dynamic> json) =>
    ModelSearchFilters(
      query: json['query'] as String?,
      category: $enumDecodeNullable(_$ModelCategoryEnumMap, json['category']),
      provider: json['provider'] as String?,
      specialty: json['specialty'] as String?,
      minRating: (json['minRating'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      isFree: json['isFree'] as bool?,
      isVerified: json['isVerified'] as bool?,
      isRecent: json['isRecent'] as bool?,
      isPopular: json['isPopular'] as bool?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      customFilters: json['customFilters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModelSearchFiltersToJson(ModelSearchFilters instance) =>
    <String, dynamic>{
      'query': instance.query,
      'category': _$ModelCategoryEnumMap[instance.category],
      'provider': instance.provider,
      'specialty': instance.specialty,
      'minRating': instance.minRating,
      'maxPrice': instance.maxPrice,
      'isFree': instance.isFree,
      'isVerified': instance.isVerified,
      'isRecent': instance.isRecent,
      'isPopular': instance.isPopular,
      'tags': instance.tags,
      'customFilters': instance.customFilters,
    };

ModelSearchResult _$ModelSearchResultFromJson(Map<String, dynamic> json) =>
    ModelSearchResult(
      models: (json['models'] as List<dynamic>)
          .map((e) => MarketplaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      appliedFilters: ModelSearchFilters.fromJson(
        json['appliedFilters'] as Map<String, dynamic>,
      ),
      facets: json['facets'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModelSearchResultToJson(ModelSearchResult instance) =>
    <String, dynamic>{
      'models': instance.models,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'appliedFilters': instance.appliedFilters,
      'facets': instance.facets,
      'metadata': instance.metadata,
    };
