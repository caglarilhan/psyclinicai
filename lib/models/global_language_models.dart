import 'package:json_annotation/json_annotation.dart';

part 'global_language_models.g.dart';

/// Global Language Models for PsyClinicAI
/// Provides comprehensive multi-language support for global expansion

@JsonSerializable()
class Language {
  final String code;
  final String name;
  final String nativeName;
  final LanguageDirection direction;
  final String flag;
  final bool isSupported;
  final bool isRTL;
  final List<String> regions;
  final Map<String, String> translations;
  final DateTime lastUpdated;
  final double completionPercentage;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.direction,
    required this.flag,
    required this.isSupported,
    required this.isRTL,
    required this.regions,
    required this.translations,
    required this.lastUpdated,
    required this.completionPercentage,
  });

  factory Language.fromJson(Map<String, dynamic> json) => _$LanguageFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageToJson(this);

  bool get isComplete => completionPercentage >= 95.0;
  bool get needsUpdate => DateTime.now().difference(lastUpdated).inDays > 30;
}

enum LanguageDirection { ltr, rtl }

@JsonSerializable()
class LocalizationConfig {
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final Map<String, LanguageSettings> languageSettings;
  final bool autoDetectLanguage;
  final bool fallbackToDefault;
  final Map<String, String> regionLanguageMapping;

  const LocalizationConfig({
    required this.defaultLanguage,
    required this.supportedLanguages,
    required this.languageSettings,
    required this.autoDetectLanguage,
    required this.fallbackToDefault,
    required this.regionLanguageMapping,
  });

  factory LocalizationConfig.fromJson(Map<String, dynamic> json) => _$LocalizationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizationConfigToJson(this);
}

@JsonSerializable()
class LanguageSettings {
  final String languageCode;
  final bool enabled;
  final DateTime enabledAt;
  final String enabledBy;
  final Map<String, bool> features;
  final Map<String, String> customTranslations;
  final List<String> regionalVariants;

  const LanguageSettings({
    required this.languageCode,
    required this.enabled,
    required this.enabledAt,
    required this.enabledBy,
    required this.features,
    required this.customTranslations,
    required this.regionalVariants,
  });

  factory LanguageSettings.fromJson(Map<String, dynamic> json) => _$LanguageSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageSettingsToJson(this);
}

@JsonSerializable()
class TranslationKey {
  final String key;
  final String category;
  final String description;
  final Map<String, String> translations;
  final TranslationStatus status;
  final DateTime lastUpdated;
  final String updatedBy;
  final List<String> tags;
  final bool isContextual;

  const TranslationKey({
    required this.key,
    required this.category,
    required this.description,
    required this.translations,
    required this.status,
    required this.lastUpdated,
    required this.updatedBy,
    required this.tags,
    required this.isContextual,
  });

  factory TranslationKey.fromJson(Map<String, dynamic> json) => _$TranslationKeyFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationKeyToJson(this);

  bool get isComplete => translations.length >= 10; // Minimum 10 language support
  bool get needsReview => status == TranslationStatus.needsReview;
}

enum TranslationStatus { draft, inProgress, needsReview, approved, deprecated }

@JsonSerializable()
class RegionalConfig {
  final String regionCode;
  final String regionName;
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final String currency;
  final String timezone;
  final String dateFormat;
  final String numberFormat;
  final Map<String, dynamic> culturalSettings;
  final List<String> complianceFrameworks;
  final Map<String, String> legalRequirements;

  const RegionalConfig({
    required this.regionCode,
    required this.regionName,
    required this.defaultLanguage,
    required this.supportedLanguages,
    required this.currency,
    required this.timezone,
    required this.dateFormat,
    required this.numberFormat,
    required this.culturalSettings,
    required this.complianceFrameworks,
    required this.legalRequirements,
  });

  factory RegionalConfig.fromJson(Map<String, dynamic> json) => _$RegionalConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RegionalConfigToJson(this);
}

@JsonSerializable()
class CulturalAdaptation {
  final String regionCode;
  final String languageCode;
  final Map<String, String> culturalPreferences;
  final Map<String, List<String>> sensitiveTopics;
  final Map<String, String> colorMeanings;
  final Map<String, String> symbolMeanings;
  final List<String> culturalTaboos;
  final Map<String, String> greetingStyles;
  final Map<String, String> communicationStyles;

  const CulturalAdaptation({
    required this.regionCode,
    required this.languageCode,
    required this.culturalPreferences,
    required this.sensitiveTopics,
    required this.colorMeanings,
    required this.symbolMeanings,
    required this.culturalTaboos,
    required this.greetingStyles,
    required this.communicationStyles,
  });

  factory CulturalAdaptation.fromJson(Map<String, dynamic> json) => _$CulturalAdaptationFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalAdaptationToJson(this);
}

@JsonSerializable()
class LanguageMetrics {
  final String languageCode;
  final int totalKeys;
  final int translatedKeys;
  final int reviewedKeys;
  final int approvedKeys;
  final double completionRate;
  final double accuracyRate;
  final DateTime lastActivity;
  final List<String> activeContributors;
  final Map<String, int> categoryBreakdown;

  const LanguageMetrics({
    required this.languageCode,
    required this.totalKeys,
    required this.translatedKeys,
    required this.reviewedKeys,
    required this.approvedKeys,
    required this.completionRate,
    required this.accuracyRate,
    required this.lastActivity,
    required this.activeContributors,
    required this.categoryBreakdown,
  });

  factory LanguageMetrics.fromJson(Map<String, dynamic> json) => _$LanguageMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageMetricsToJson(this);

  bool get isFullyTranslated => completionRate >= 100.0;
  bool get isHighQuality => accuracyRate >= 95.0;
}

@JsonSerializable()
class TranslationProject {
  final String id;
  final String name;
  final String description;
  final List<String> targetLanguages;
  final String sourceLanguage;
  final TranslationProjectStatus status;
  final DateTime startDate;
  final DateTime? completionDate;
  final Map<String, double> progressByLanguage;
  final List<String> assignedTranslators;
  final Map<String, TranslationReview> reviews;
  final Map<String, dynamic> metadata;

  const TranslationProject({
    required this.id,
    required this.name,
    required this.description,
    required this.targetLanguages,
    required this.sourceLanguage,
    required this.status,
    required this.startDate,
    this.completionDate,
    required this.progressByLanguage,
    required this.assignedTranslators,
    required this.reviews,
    required this.metadata,
  });

  factory TranslationProject.fromJson(Map<String, dynamic> json) => _$TranslationProjectFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationProjectToJson(this);

  bool get isCompleted => status == TranslationProjectStatus.completed;
  double get overallProgress => progressByLanguage.values.isEmpty 
      ? 0.0 
      : progressByLanguage.values.reduce((a, b) => a + b) / progressByLanguage.length;
}

enum TranslationProjectStatus { planning, inProgress, review, completed, onHold, cancelled }

@JsonSerializable()
class TranslationReview {
  final String id;
  final String translatorId;
  final String reviewerId;
  final ReviewStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final List<ReviewComment> comments;
  final double qualityScore;
  final String feedback;

  const TranslationReview({
    required this.id,
    required this.translatorId,
    required this.reviewerId,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    required this.comments,
    required this.qualityScore,
    required this.feedback,
  });

  factory TranslationReview.fromJson(Map<String, dynamic> json) => _$TranslationReviewFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationReviewToJson(this);
}

enum ReviewStatus { pending, inProgress, approved, needsRevision, rejected }

@JsonSerializable()
class ReviewComment {
  final String id;
  final String commenterId;
  final String comment;
  final CommentType type;
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;

  const ReviewComment({
    required this.id,
    required this.commenterId,
    required this.comment,
    required this.type,
    required this.createdAt,
    required this.isResolved,
    this.resolvedAt,
  });

  factory ReviewComment.fromJson(Map<String, dynamic> json) => _$ReviewCommentFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewCommentToJson(this);
}

enum CommentType { suggestion, correction, question, general }

@JsonSerializable()
class LanguageDetectionResult {
  final String detectedLanguage;
  final double confidence;
  final List<LanguageProbability> alternatives;
  final bool isReliable;
  final String detectionMethod;

  const LanguageDetectionResult({
    required this.detectedLanguage,
    required this.confidence,
    required this.alternatives,
    required this.isReliable,
    required this.detectionMethod,
  });

  factory LanguageDetectionResult.fromJson(Map<String, dynamic> json) => _$LanguageDetectionResultFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageDetectionResultToJson(this);
}

@JsonSerializable()
class LanguageProbability {
  final String languageCode;
  final double probability;

  const LanguageProbability({
    required this.languageCode,
    required this.probability,
  });

  factory LanguageProbability.fromJson(Map<String, dynamic> json) => _$LanguageProbabilityFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageProbabilityToJson(this);
}

@JsonSerializable()
class LocalizationReport {
  final String id;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, LanguageMetrics> languageMetrics;
  final List<TranslationProject> activeProjects;
  final List<String> languagesNeedingAttention;
  final Map<String, int> translationRequests;
  final Map<String, double> userSatisfaction;

  const LocalizationReport({
    required this.id,
    required this.generatedAt,
    required this.generatedBy,
    required this.languageMetrics,
    required this.activeProjects,
    required this.languagesNeedingAttention,
    required this.translationRequests,
    required this.userSatisfaction,
  });

  factory LocalizationReport.fromJson(Map<String, dynamic> json) => _$LocalizationReportFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizationReportToJson(this);
}
