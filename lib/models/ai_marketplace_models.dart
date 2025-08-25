import 'package:json_annotation/json_annotation.dart';

part 'ai_marketplace_models.g.dart';

/// AI Model Marketplace Status
enum MarketplaceStatus {
  @JsonValue('active') active,
  @JsonValue('inactive') inactive,
  @JsonValue('maintenance') maintenance,
  @JsonValue('beta') beta,
}

/// AI Model Category
enum AIModelCategory {
  @JsonValue('nlp') nlp,
  @JsonValue('computer_vision') computerVision,
  @JsonValue('audio') audio,
  @JsonValue('multimodal') multimodal,
  @JsonValue('predictive') predictive,
  @JsonValue('diagnostic') diagnostic,
  @JsonValue('therapeutic') therapeutic,
  @JsonValue('research') research,
}

/// AI Model License Type
enum ModelLicenseType {
  @JsonValue('commercial') commercial,
  @JsonValue('academic') academic,
  @JsonValue('open_source') openSource,
  @JsonValue('proprietary') proprietary,
  @JsonValue('freemium') freemium,
}

/// AI Model Pricing Model
enum PricingModel {
  @JsonValue('one_time') oneTime,
  @JsonValue('subscription') subscription,
  @JsonValue('usage_based') usageBased,
  @JsonValue('tiered') tiered,
  @JsonValue('free') free,
}

/// AI Model Performance Metrics
@JsonSerializable()
class ModelPerformanceMetrics {
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double auc;
  final double latency;
  final double throughput;
  final Map<String, double> customMetrics;
  final DateTime lastUpdated;
  final String evaluationDataset;

  const ModelPerformanceMetrics({
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.auc,
    required this.latency,
    required this.throughput,
    required this.customMetrics,
    required this.lastUpdated,
    required this.evaluationDataset,
  });

  factory ModelPerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$ModelPerformanceMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ModelPerformanceMetricsToJson(this);
}

/// AI Model Requirements
@JsonSerializable()
class ModelRequirements {
  final String minimumRam;
  final String minimumStorage;
  final String minimumCpu;
  final String recommendedGpu;
  final List<String> supportedPlatforms;
  final List<String> dependencies;
  final String pythonVersion;
  final Map<String, String> frameworkVersions;

  const ModelRequirements({
    required this.minimumRam,
    required this.minimumStorage,
    required this.minimumCpu,
    required this.recommendedGpu,
    required this.supportedPlatforms,
    required this.dependencies,
    required this.pythonVersion,
    required this.frameworkVersions,
  });

  factory ModelRequirements.fromJson(Map<String, dynamic> json) =>
      _$ModelRequirementsFromJson(json);

  Map<String, dynamic> toJson() => _$ModelRequirementsToJson(this);
}

/// AI Model Documentation
@JsonSerializable()
class ModelDocumentation {
  final String overview;
  final String installation;
  final String usage;
  final String api;
  final String examples;
  final String troubleshooting;
  final String changelog;
  final String license;
  final List<String> tutorials;
  final String support;

  const ModelDocumentation({
    required this.overview,
    required this.installation,
    required this.usage,
    required this.api,
    required this.examples,
    required this.troubleshooting,
    required this.changelog,
    required this.license,
    required this.tutorials,
    required this.support,
  });

  factory ModelDocumentation.fromJson(Map<String, dynamic> json) =>
      _$ModelDocumentationFromJson(json);

  Map<String, dynamic> toJson() => _$ModelDocumentationToJson(this);
}

/// AI Model Review
@JsonSerializable()
class ModelReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> pros;
  final List<String> cons;
  final DateTime createdAt;
  final bool verified;
  final int helpfulVotes;

  const ModelReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.pros,
    required this.cons,
    required this.createdAt,
    required this.verified,
    required this.helpfulVotes,
  });

  factory ModelReview.fromJson(Map<String, dynamic> json) =>
      _$ModelReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ModelReviewToJson(this);
}

/// AI Model Version
@JsonSerializable()
class ModelVersion {
  final String version;
  final String description;
  final DateTime releaseDate;
  final List<String> features;
  final List<String> bugFixes;
  final List<String> breakingChanges;
  final String downloadUrl;
  final String checksum;
  final bool isLatest;
  final bool isStable;

  const ModelVersion({
    required this.version,
    required this.description,
    required this.releaseDate,
    required this.features,
    required this.bugFixes,
    required this.breakingChanges,
    required this.downloadUrl,
    required this.checksum,
    required this.isLatest,
    required this.isStable,
  });

  factory ModelVersion.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ModelVersionToJson(this);
}

/// AI Model in Marketplace
@JsonSerializable()
class MarketplaceAIModel {
  final String id;
  final String name;
  final String description;
  final String vendorId;
  final String vendorName;
  final AIModelCategory category;
  final List<String> tags;
  final ModelLicenseType licenseType;
  final PricingModel pricingModel;
  final double price;
  final String currency;
  final Map<String, double> pricingTiers;
  final ModelPerformanceMetrics performance;
  final ModelRequirements requirements;
  final ModelDocumentation documentation;
  final List<ModelVersion> versions;
  final List<ModelReview> reviews;
  final double averageRating;
  final int totalReviews;
  final int downloads;
  final MarketplaceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> useCases;
  final List<String> industries;
  final String modelSize;
  final String trainingData;
  final String lastTrained;
  final bool isCustomizable;
  final List<String> supportedLanguages;
  final Map<String, dynamic> metadata;

  const MarketplaceAIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.vendorId,
    required this.vendorName,
    required this.category,
    required this.tags,
    required this.licenseType,
    required this.pricingModel,
    required this.price,
    required this.currency,
    required this.pricingTiers,
    required this.performance,
    required this.requirements,
    required this.documentation,
    required this.versions,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.downloads,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.useCases,
    required this.industries,
    required this.modelSize,
    required this.trainingData,
    required this.lastTrained,
    required this.isCustomizable,
    required this.supportedLanguages,
    required this.metadata,
  });

  factory MarketplaceAIModel.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceAIModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketplaceAIModelToJson(this);
}

/// AI Model Purchase
@JsonSerializable()
class ModelPurchase {
  final String id;
  final String userId;
  final String modelId;
  final String modelName;
  final double price;
  final String currency;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final String licenseKey;
  final String status;
  final String paymentMethod;
  final String transactionId;
  final String invoiceUrl;
  final Map<String, dynamic> metadata;

  const ModelPurchase({
    required this.id,
    required this.userId,
    required this.modelId,
    required this.modelName,
    required this.price,
    required this.currency,
    required this.purchaseDate,
    required this.expiryDate,
    required this.licenseKey,
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    required this.invoiceUrl,
    required this.metadata,
  });

  factory ModelPurchase.fromJson(Map<String, dynamic> json) =>
      _$ModelPurchaseFromJson(json);

  Map<String, dynamic> toJson() => _$ModelPurchaseToJson(this);
}

/// AI Model Subscription
@JsonSerializable()
class ModelSubscription {
  final String id;
  final String userId;
  final String modelId;
  final String modelName;
  final String planId;
  final String planName;
  final double monthlyPrice;
  final String currency;
  final DateTime startDate;
  final DateTime nextBillingDate;
  final DateTime? endDate;
  final String status;
  final bool autoRenew;
  final int usageLimit;
  final int currentUsage;
  final String paymentMethod;
  final Map<String, dynamic> metadata;

  const ModelSubscription({
    required this.id,
    required this.userId,
    required this.modelId,
    required this.modelName,
    required this.planId,
    required this.planName,
    required this.monthlyPrice,
    required this.currency,
    required this.startDate,
    required this.nextBillingDate,
    this.endDate,
    required this.status,
    required this.autoRenew,
    required this.usageLimit,
    required this.currentUsage,
    required this.paymentMethod,
    required this.metadata,
  });

  factory ModelSubscription.fromJson(Map<String, dynamic> json) =>
      _$ModelSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$ModelSubscriptionToJson(this);
}

/// AI Model Vendor
@JsonSerializable()
class ModelVendor {
  final String id;
  final String name;
  final String description;
  final String website;
  final String email;
  final String phone;
  final String address;
  final String country;
  final String industry;
  final int foundedYear;
  final int employeeCount;
  final double rating;
  final int totalModels;
  final List<String> specializations;
  final String verificationStatus;
  final DateTime verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const ModelVendor({
    required this.id,
    required this.name,
    required this.description,
    required this.website,
    required this.email,
    required this.phone,
    required this.address,
    required this.country,
    required this.industry,
    required this.foundedYear,
    required this.employeeCount,
    required this.rating,
    required this.totalModels,
    required this.specializations,
    required this.verificationStatus,
    required this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory ModelVendor.fromJson(Map<String, dynamic> json) =>
      _$ModelVendorFromJson(json);

  Map<String, dynamic> toJson() => _$ModelVendorToJson(this);
}

/// AI Model Usage Analytics
@JsonSerializable()
class ModelUsageAnalytics {
  final String id;
  final String modelId;
  final String userId;
  final DateTime timestamp;
  final String operation;
  final int inputSize;
  final int outputSize;
  final double processingTime;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> results;

  const ModelUsageAnalytics({
    required this.id,
    required this.modelId,
    required this.userId,
    required this.timestamp,
    required this.operation,
    required this.inputSize,
    required this.outputSize,
    required this.processingTime,
    required this.success,
    this.errorMessage,
    required this.parameters,
    required this.results,
  });

  factory ModelUsageAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ModelUsageAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$ModelUsageAnalyticsToJson(this);
}

/// AI Model Search Filters
@JsonSerializable()
class ModelSearchFilters {
  final List<AIModelCategory>? categories;
  final List<ModelLicenseType>? licenseTypes;
  final List<PricingModel>? pricingModels;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<String>? tags;
  final List<String>? vendors;
  final List<String>? useCases;
  final List<String>? industries;
  final bool? isCustomizable;
  final String? searchQuery;

  const ModelSearchFilters({
    this.categories,
    this.licenseTypes,
    this.pricingModels,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.tags,
    this.vendors,
    this.useCases,
    this.industries,
    this.isCustomizable,
    this.searchQuery,
  });

  factory ModelSearchFilters.fromJson(Map<String, dynamic> json) =>
      _$ModelSearchFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$ModelSearchFiltersToJson(this);
}

/// AI Model Comparison
@JsonSerializable()
class ModelComparison {
  final String id;
  final List<String> modelIds;
  final List<MarketplaceAIModel> models;
  final Map<String, Map<String, dynamic>> comparisonData;
  final DateTime createdAt;
  final String createdBy;

  const ModelComparison({
    required this.id,
    required this.modelIds,
    required this.models,
    required this.comparisonData,
    required this.createdAt,
    required this.createdBy,
  });

  factory ModelComparison.fromJson(Map<String, dynamic> json) =>
      _$ModelComparisonFromJson(json);

  Map<String, dynamic> toJson() => _$ModelComparisonToJson(this);
}
