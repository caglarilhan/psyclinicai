/// AI Model Marketplace Models for PsyClinicAI
/// This file contains all the data models needed for AI model marketplace functionality

import 'package:json_annotation/json_annotation.dart';

part 'ai_marketplace_models.g.dart';

/// Model category enumeration
enum ModelCategory {
  @JsonValue('diagnosis')
  diagnosis,
  @JsonValue('treatment')
  treatment,
  @JsonValue('riskAssessment')
  riskAssessment,
  @JsonValue('prognosis')
  prognosis,
  @JsonValue('screening')
  screening,
  @JsonValue('monitoring')
  monitoring,
}

/// Model install status enumeration
enum ModelInstallStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('updating')
  updating,
  @JsonValue('error')
  error,
}

/// Marketplace model
@JsonSerializable()
class MarketplaceModel {
  final String id;
  final String name;
  final String description;
  final String provider;
  final String version;
  final ModelCategory category;
  final double price;
  final String priceUnit; // per_month, per_year, one_time
  final double rating;
  final int reviewCount;
  final List<String> specialties;
  final List<String> features;
  final ModelPerformance performance;
  final String documentation;
  final List<String> requirements;
  final Map<String, dynamic> metadata;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final int downloadCount;
  final bool isVerified;
  final List<String> tags;
  final String? demoUrl;
  final String? paperUrl;
  final String? repositoryUrl;

  const MarketplaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.provider,
    required this.version,
    required this.category,
    required this.price,
    required this.priceUnit,
    required this.rating,
    required this.reviewCount,
    required this.specialties,
    required this.features,
    required this.performance,
    required this.documentation,
    required this.requirements,
    required this.metadata,
    required this.publishedAt,
    required this.updatedAt,
    required this.downloadCount,
    required this.isVerified,
    required this.tags,
    this.demoUrl,
    this.paperUrl,
    this.repositoryUrl,
  });

  factory MarketplaceModel.fromJson(Map<String, dynamic> json) => _$MarketplaceModelFromJson(json);
  Map<String, dynamic> toJson() => _$MarketplaceModelToJson(this);

  /// Create a copy with updated values
  MarketplaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? provider,
    String? version,
    ModelCategory? category,
    double? price,
    String? priceUnit,
    double? rating,
    int? reviewCount,
    List<String>? specialties,
    List<String>? features,
    ModelPerformance? performance,
    String? documentation,
    List<String>? requirements,
    Map<String, dynamic>? metadata,
    DateTime? publishedAt,
    DateTime? updatedAt,
    int? downloadCount,
    bool? isVerified,
    List<String>? tags,
    String? demoUrl,
    String? paperUrl,
    String? repositoryUrl,
  }) {
    return MarketplaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      provider: provider ?? this.provider,
      version: version ?? this.version,
      category: category ?? this.category,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      specialties: specialties ?? this.specialties,
      features: features ?? this.features,
      performance: performance ?? this.performance,
      documentation: documentation ?? this.documentation,
      requirements: requirements ?? this.requirements,
      metadata: metadata ?? this.metadata,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadCount: downloadCount ?? this.downloadCount,
      isVerified: isVerified ?? this.isVerified,
      tags: tags ?? this.tags,
      demoUrl: demoUrl ?? this.demoUrl,
      paperUrl: paperUrl ?? this.paperUrl,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
    );
  }

  /// Check if model is free
  bool get isFree => price == 0.0;
  
  /// Check if model is premium
  bool get isPremium => price > 50.0;
  
  /// Get formatted price
  String get formattedPrice {
    if (isFree) return 'Free';
    return '\$${price.toStringAsFixed(2)}/$priceUnit';
  }
  
  /// Get formatted rating
  String get formattedRating => '${rating.toStringAsFixed(1)}/5.0';
  
  /// Check if model is recently published
  bool get isRecent => DateTime.now().difference(publishedAt).inDays < 30;
  
  /// Check if model is popular
  bool get isPopular => downloadCount > 1000 || rating > 4.5;
}

/// Model performance metrics
@JsonSerializable()
class ModelPerformance {
  final double accuracy;
  final double latency; // in seconds
  final int throughput; // requests per minute
  final double memoryUsage; // in MB
  final double cpuUsage; // percentage
  final Map<String, double> customMetrics;

  const ModelPerformance({
    required this.accuracy,
    required this.latency,
    required this.throughput,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.customMetrics,
  });

  factory ModelPerformance.fromJson(Map<String, dynamic> json) => _$ModelPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$ModelPerformanceToJson(this);

  /// Calculate performance score
  double get performanceScore {
    final accuracyScore = accuracy * 0.4;
    final latencyScore = (1.0 - (latency / 5.0)).clamp(0.0, 1.0) * 0.3;
    final throughputScore = (throughput / 1000.0).clamp(0.0, 1.0) * 0.3;
    
    return accuracyScore + latencyScore + throughputScore;
  }
  
  /// Check if performance meets minimum thresholds
  bool get meetsThresholds {
    return accuracy >= 0.8 && latency <= 2.0 && throughput >= 100;
  }
  
  /// Get performance summary
  Map<String, dynamic> get summary {
    return {
      'accuracy': '${(accuracy * 100).toStringAsFixed(1)}%',
      'latency': '${latency.toStringAsFixed(2)}s',
      'throughput': '$throughput/min',
      'memory': '${memoryUsage.toStringAsFixed(1)}MB',
      'cpu': '${cpuUsage.toStringAsFixed(1)}%',
      'score': performanceScore.toStringAsFixed(2),
    };
  }
}

/// Installed model
@JsonSerializable()
class InstalledModel {
  final String id;
  final String name;
  final String version;
  final String provider;
  final ModelInstallStatus status;
  final DateTime installedAt;
  final DateTime lastUpdated;
  final double size; // in MB
  final Map<String, dynamic> configuration;
  final List<String> dependencies;
  final String? errorMessage;
  final Map<String, dynamic>? usageStats;

  const InstalledModel({
    required this.id,
    required this.name,
    required this.version,
    required this.provider,
    required this.status,
    required this.installedAt,
    required this.lastUpdated,
    required this.size,
    required this.configuration,
    required this.dependencies,
    this.errorMessage,
    this.usageStats,
  });

  factory InstalledModel.fromJson(Map<String, dynamic> json) => _$InstalledModelFromJson(json);
  Map<String, dynamic> toJson() => _$InstalledModelToJson(this);

  /// Create a copy with updated values
  InstalledModel copyWith({
    String? id,
    String? name,
    String? version,
    String? provider,
    ModelInstallStatus? status,
    DateTime? installedAt,
    DateTime? lastUpdated,
    double? size,
    Map<String, dynamic>? configuration,
    List<String>? dependencies,
    String? errorMessage,
    Map<String, dynamic>? usageStats,
  }) {
    return InstalledModel(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      installedAt: installedAt ?? this.installedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      size: size ?? this.size,
      configuration: configuration ?? this.configuration,
      dependencies: dependencies ?? this.dependencies,
      errorMessage: errorMessage ?? this.errorMessage,
      usageStats: usageStats ?? this.usageStats,
    );
  }

  /// Check if model is working properly
  bool get isWorking => status == ModelInstallStatus.active;
  
  /// Check if model needs update
  bool get needsUpdate => DateTime.now().difference(lastUpdated).inDays > 30;
  
  /// Get formatted size
  String get formattedSize {
    if (size < 1.0) {
      return '${(size * 1024).toStringAsFixed(0)} KB';
    }
    return '${size.toStringAsFixed(1)} MB';
  }
  
  /// Get installation age
  String get installationAge {
    final days = DateTime.now().difference(installedAt).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).round()} weeks ago';
    return '${(days / 30).round()} months ago';
  }
}

/// Model provider
@JsonSerializable()
class ModelProvider {
  final String id;
  final String name;
  final String description;
  final String website;
  final double rating;
  final int reviewCount;
  final int modelsCount;
  final List<String> specialties;
  final bool verified;
  final String? logoUrl;
  final String? contactEmail;
  final String? supportUrl;
  final Map<String, dynamic>? metadata;
  final DateTime joinedAt;
  final DateTime lastActive;

  const ModelProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.website,
    required this.rating,
    required this.reviewCount,
    required this.modelsCount,
    required this.specialties,
    required this.verified,
    this.logoUrl,
    this.contactEmail,
    this.supportUrl,
    this.metadata,
    required this.joinedAt,
    required this.lastActive,
  });

  factory ModelProvider.fromJson(Map<String, dynamic> json) => _$ModelProviderFromJson(json);
  Map<String, dynamic> toJson() => _$ModelProviderToJson(this);

  /// Create a copy with updated values
  ModelProvider copyWith({
    String? id,
    String? name,
    String? description,
    String? website,
    double? rating,
    int? reviewCount,
    int? modelsCount,
    List<String>? specialties,
    bool? verified,
    String? logoUrl,
    String? contactEmail,
    String? supportUrl,
    Map<String, dynamic>? metadata,
    DateTime? joinedAt,
    DateTime? lastActive,
  }) {
    return ModelProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      modelsCount: modelsCount ?? this.modelsCount,
      specialties: specialties ?? this.specialties,
      verified: verified ?? this.verified,
      logoUrl: logoUrl ?? this.logoUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      supportUrl: supportUrl ?? this.supportUrl,
      metadata: metadata ?? this.metadata,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// Check if provider is active
  bool get isActive => DateTime.now().difference(lastActive).inDays < 7;
  
  /// Check if provider is established
  bool get isEstablished => DateTime.now().difference(joinedAt).inDays > 365;
  
  /// Get formatted rating
  String get formattedRating => '${rating.toStringAsFixed(1)}/5.0';
  
  /// Get provider tier
  String get tier {
    if (rating >= 4.5 && modelsCount >= 20) return 'Premium';
    if (rating >= 4.0 && modelsCount >= 10) return 'Gold';
    if (rating >= 3.5 && modelsCount >= 5) return 'Silver';
    return 'Bronze';
  }
  
  /// Get join date
  String get joinDate {
    final months = DateTime.now().difference(joinedAt).inDays ~/ 30;
    if (months < 1) return 'New';
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    return '$years years';
  }
}

/// Model review
@JsonSerializable()
class ModelReview {
  final String id;
  final String modelId;
  final String userId;
  final String userName;
  final double rating;
  final String title;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final bool verified;
  final int helpfulCount;
  final List<String> images;
  final Map<String, dynamic>? metadata;

  const ModelReview({
    required this.id,
    required this.modelId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    required this.tags,
    required this.verified,
    required this.helpfulCount,
    required this.images,
    this.metadata,
  });

  factory ModelReview.fromJson(Map<String, dynamic> json) => _$ModelReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ModelReviewToJson(this);

  /// Create a copy with updated values
  ModelReview copyWith({
    String? id,
    String? modelId,
    String? userId,
    String? userName,
    double? rating,
    String? title,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? verified,
    int? helpfulCount,
    List<String>? images,
    Map<String, dynamic>? metadata,
  }) {
    return ModelReview(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      verified: verified ?? this.verified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      images: images ?? this.images,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if review is recent
  bool get isRecent => DateTime.now().difference(createdAt).inDays < 7;
  
  /// Check if review is helpful
  bool get isHelpful => helpfulCount >= 5;
  
  /// Get formatted rating
  String get formattedRating => '${rating.toStringAsFixed(1)}/5.0';
  
  /// Get review age
  String get age {
    final days = DateTime.now().difference(createdAt).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).round()} weeks ago';
    return '${(days / 30).round()} months ago';
  }
  
  /// Check if review was edited
  bool get wasEdited => updatedAt != null && updatedAt != createdAt;
}

/// Model comparison
@JsonSerializable()
class ModelComparison {
  final String id;
  final List<String> modelIds;
  final DateTime comparedAt;
  final Map<String, ModelComparisonMetrics> metrics;
  final String winner;
  final List<String> insights;
  final Map<String, dynamic>? metadata;

  const ModelComparison({
    required this.id,
    required this.modelIds,
    required this.comparedAt,
    required this.metrics,
    required this.winner,
    required this.insights,
    this.metadata,
  });

  factory ModelComparison.fromJson(Map<String, dynamic> json) => _$ModelComparisonFromJson(json);
  Map<String, dynamic> toJson() => _$ModelComparisonToJson(this);

  /// Get comparison summary
  Map<String, dynamic> get summary {
    return {
      'id': id,
      'modelCount': modelIds.length,
      'comparedAt': comparedAt.toIso8601String(),
      'winner': winner,
      'insightCount': insights.length,
    };
  }
  
  /// Check if comparison is recent
  bool get isRecent => DateTime.now().difference(comparedAt).inDays < 1;
}

/// Model comparison metrics
@JsonSerializable()
class ModelComparisonMetrics {
  final String modelId;
  final String modelName;
  final double accuracy;
  final double latency;
  final int throughput;
  final double price;
  final double rating;
  final int downloadCount;
  final Map<String, double> customMetrics;

  const ModelComparisonMetrics({
    required this.modelId,
    required this.modelName,
    required this.accuracy,
    required this.latency,
    required this.throughput,
    required this.price,
    required this.rating,
    required this.downloadCount,
    required this.customMetrics,
  });

  factory ModelComparisonMetrics.fromJson(Map<String, dynamic> json) => _$ModelComparisonMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$ModelComparisonMetricsToJson(this);

  /// Calculate overall score
  double get overallScore {
    final accuracyScore = accuracy * 0.3;
    final latencyScore = (1.0 - (latency / 5.0)).clamp(0.0, 1.0) * 0.2;
    final throughputScore = (throughput / 1000.0).clamp(0.0, 1.0) * 0.2;
    final priceScore = (1.0 - (price / 100.0)).clamp(0.0, 1.0) * 0.15;
    final ratingScore = (rating / 5.0) * 0.15;
    
    return accuracyScore + latencyScore + throughputScore + priceScore + ratingScore;
  }
  
  /// Get metrics summary
  Map<String, dynamic> get summary {
    return {
      'modelId': modelId,
      'modelName': modelName,
      'accuracy': '${(accuracy * 100).toStringAsFixed(1)}%',
      'latency': '${latency.toStringAsFixed(2)}s',
      'throughput': '$throughput/min',
      'price': '\$${price.toStringAsFixed(2)}',
      'rating': '${rating.toStringAsFixed(1)}/5.0',
      'downloads': downloadCount,
      'score': overallScore.toStringAsFixed(2),
    };
  }
}

/// Model performance comparison
@JsonSerializable()
class ModelPerformanceComparison {
  final String winner;
  final List<String> insights;
  final Map<String, double> scores;
  final Map<String, ModelComparisonMetrics> detailedMetrics;

  const ModelPerformanceComparison({
    required this.winner,
    required this.insights,
    required this.scores,
    required this.detailedMetrics,
  });

  factory ModelPerformanceComparison.fromJson(Map<String, dynamic> json) => _$ModelPerformanceComparisonFromJson(json);
  Map<String, dynamic> toJson() => _$ModelPerformanceComparisonToJson(this);

  /// Get comparison summary
  Map<String, dynamic> get summary {
    return {
      'winner': winner,
      'insightCount': insights.length,
      'modelCount': scores.length,
      'averageScore': scores.values.reduce((a, b) => a + b) / scores.length,
    };
  }
  
  /// Get top performers
  List<String> get topPerformers {
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }
  
  /// Get performance gap
  double get performanceGap {
    if (scores.isEmpty) return 0.0;
    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    final minScore = scores.values.reduce((a, b) => a < b ? a : b);
    return maxScore - minScore;
  }
}

/// Model installation request
@JsonSerializable()
class ModelInstallRequest {
  final String modelId;
  final String userId;
  final String? licenseKey;
  final Map<String, dynamic>? configuration;
  final bool autoUpdate;
  final String? customPath;

  const ModelInstallRequest({
    required this.modelId,
    required this.userId,
    this.licenseKey,
    this.configuration,
    this.autoUpdate = true,
    this.customPath,
  });

  factory ModelInstallRequest.fromJson(Map<String, dynamic> json) => _$ModelInstallRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ModelInstallRequestToJson(this);

  /// Validate request
  bool get isValid {
    return modelId.isNotEmpty && userId.isNotEmpty;
  }
  
  /// Get request summary
  Map<String, dynamic> get summary {
    return {
      'modelId': modelId,
      'userId': userId,
      'autoUpdate': autoUpdate,
      'hasLicense': licenseKey != null,
      'hasCustomConfig': configuration != null,
      'customPath': customPath,
    };
  }
}

/// Model installation response
@JsonSerializable()
class ModelInstallResponse {
  final bool success;
  final String? installationId;
  final String? message;
  final Map<String, dynamic>? data;
  final List<String>? errors;
  final DateTime timestamp;

  const ModelInstallResponse({
    required this.success,
    this.installationId,
    this.message,
    this.data,
    this.errors,
    required this.timestamp,
  });

  factory ModelInstallResponse.fromJson(Map<String, dynamic> json) => _$ModelInstallResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ModelInstallResponseToJson(this);

  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  /// Get first error message
  String? get firstError => hasErrors ? errors!.first : null;
  
  /// Get response summary
  Map<String, dynamic> get summary {
    return {
      'success': success,
      'installationId': installationId,
      'message': message,
      'errorCount': errors?.length ?? 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Model test request
@JsonSerializable()
class ModelTestRequest {
  final String modelId;
  final String testType; // sample, custom, benchmark
  final Map<String, dynamic> testData;
  final Map<String, dynamic>? parameters;
  final int? iterations;

  const ModelTestRequest({
    required this.modelId,
    required this.testType,
    required this.testData,
    this.parameters,
    this.iterations,
  });

  factory ModelTestRequest.fromJson(Map<String, dynamic> json) => _$ModelTestRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ModelTestRequestToJson(this);

  /// Validate request
  bool get isValid {
    return modelId.isNotEmpty && testType.isNotEmpty && testData.isNotEmpty;
  }
  
  /// Get request summary
  Map<String, dynamic> get summary {
    return {
      'modelId': modelId,
      'testType': testType,
      'dataSize': testData.length,
      'hasParameters': parameters != null,
      'iterations': iterations ?? 1,
    };
  }
}

/// Model test result
@JsonSerializable()
class ModelTestResult {
  final String testId;
  final String modelId;
  final bool success;
  final Map<String, dynamic> results;
  final double executionTime;
  final DateTime completedAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const ModelTestResult({
    required this.testId,
    required this.modelId,
    required this.success,
    required this.results,
    required this.executionTime,
    required this.completedAt,
    this.errorMessage,
    this.metadata,
  });

  factory ModelTestResult.fromJson(Map<String, dynamic> json) => _$ModelTestResultFromJson(json);
  Map<String, dynamic> toJson() => _$ModelTestResultToJson(this);

  /// Check if test passed
  bool get passed => success && errorMessage == null;
  
  /// Get execution time in seconds
  double get executionTimeSeconds => executionTime / 1000.0;
  
  /// Get formatted execution time
  String get formattedExecutionTime {
    if (executionTime < 1000) return '${executionTime.toStringAsFixed(0)}ms';
    return '${executionTimeSeconds.toStringAsFixed(2)}s';
  }
  
  /// Get result summary
  Map<String, dynamic> get summary {
    return {
      'testId': testId,
      'modelId': modelId,
      'success': success,
      'executionTime': formattedExecutionTime,
      'completedAt': completedAt.toIso8601String(),
      'hasErrors': errorMessage != null,
    };
  }
}

/// Model search filters
@JsonSerializable()
class ModelSearchFilters {
  final String? query;
  final ModelCategory? category;
  final String? provider;
  final String? specialty;
  final double? minRating;
  final double? maxPrice;
  final bool? isFree;
  final bool? isVerified;
  final bool? isRecent;
  final bool? isPopular;
  final List<String>? tags;
  final Map<String, dynamic>? customFilters;

  const ModelSearchFilters({
    this.query,
    this.category,
    this.provider,
    this.specialty,
    this.minRating,
    this.maxPrice,
    this.isFree,
    this.isVerified,
    this.isRecent,
    this.isPopular,
    this.tags,
    this.customFilters,
  });

  factory ModelSearchFilters.fromJson(Map<String, dynamic> json) => _$ModelSearchFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$ModelSearchFiltersToJson(this);

  /// Check if filters are empty
  bool get isEmpty {
    return query == null &&
           category == null &&
           provider == null &&
           specialty == null &&
           minRating == null &&
           maxPrice == null &&
           isFree == null &&
           isVerified == null &&
           isRecent == null &&
           isPopular == null &&
           (tags == null || tags!.isEmpty) &&
           (customFilters == null || customFilters!.isEmpty);
  }
  
  /// Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (category != null) count++;
    if (provider != null) count++;
    if (specialty != null) count++;
    if (minRating != null) count++;
    if (maxPrice != null) count++;
    if (isFree != null) count++;
    if (isVerified != null) count++;
    if (isRecent != null) count++;
    if (isPopular != null) count++;
    if (tags != null && tags!.isNotEmpty) count++;
    if (customFilters != null && customFilters!.isNotEmpty) count++;
    return count;
  }
  
  /// Get filters summary
  Map<String, dynamic> get summary {
    return {
      'query': query,
      'category': category?.name,
      'provider': provider,
      'specialty': specialty,
      'minRating': minRating,
      'maxPrice': maxPrice,
      'isFree': isFree,
      'isVerified': isVerified,
      'isRecent': isRecent,
      'isPopular': isPopular,
      'tags': tags,
      'activeFilters': activeFilterCount,
    };
  }
}

/// Model search result
@JsonSerializable()
class ModelSearchResult {
  final List<MarketplaceModel> models;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final ModelSearchFilters appliedFilters;
  final Map<String, dynamic>? facets;
  final Map<String, dynamic>? metadata;

  const ModelSearchResult({
    required this.models,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.appliedFilters,
    this.facets,
    this.metadata,
  });

  factory ModelSearchResult.fromJson(Map<String, dynamic> json) => _$ModelSearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$ModelSearchResultToJson(this);

  /// Check if result is empty
  bool get isEmpty => models.isEmpty;
  
  /// Check if result has multiple pages
  bool get hasMultiplePages => totalPages > 1;
  
  /// Check if current page is first
  bool get isFirstPage => page == 1;
  
  /// Check if current page is last
  bool get isLastPage => page == totalPages;
  
  /// Get result summary
  Map<String, dynamic> get summary {
    return {
      'modelCount': models.length,
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'hasMultiplePages': hasMultiplePages,
      'appliedFilters': appliedFilters.summary,
    };
  }
}
