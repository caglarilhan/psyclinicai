// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_language_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Language _$LanguageFromJson(Map<String, dynamic> json) => Language(
  code: json['code'] as String,
  name: json['name'] as String,
  nativeName: json['nativeName'] as String,
  direction: $enumDecode(_$LanguageDirectionEnumMap, json['direction']),
  flag: json['flag'] as String,
  isSupported: json['isSupported'] as bool,
  isRTL: json['isRTL'] as bool,
  regions: (json['regions'] as List<dynamic>).map((e) => e as String).toList(),
  translations: Map<String, String>.from(json['translations'] as Map),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  completionPercentage: (json['completionPercentage'] as num).toDouble(),
);

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'nativeName': instance.nativeName,
  'direction': _$LanguageDirectionEnumMap[instance.direction]!,
  'flag': instance.flag,
  'isSupported': instance.isSupported,
  'isRTL': instance.isRTL,
  'regions': instance.regions,
  'translations': instance.translations,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'completionPercentage': instance.completionPercentage,
};

const _$LanguageDirectionEnumMap = {
  LanguageDirection.ltr: 'ltr',
  LanguageDirection.rtl: 'rtl',
};

LocalizationConfig _$LocalizationConfigFromJson(Map<String, dynamic> json) =>
    LocalizationConfig(
      defaultLanguage: json['defaultLanguage'] as String,
      supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      languageSettings: (json['languageSettings'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, LanguageSettings.fromJson(e as Map<String, dynamic>)),
      ),
      autoDetectLanguage: json['autoDetectLanguage'] as bool,
      fallbackToDefault: json['fallbackToDefault'] as bool,
      regionLanguageMapping: Map<String, String>.from(
        json['regionLanguageMapping'] as Map,
      ),
    );

Map<String, dynamic> _$LocalizationConfigToJson(LocalizationConfig instance) =>
    <String, dynamic>{
      'defaultLanguage': instance.defaultLanguage,
      'supportedLanguages': instance.supportedLanguages,
      'languageSettings': instance.languageSettings,
      'autoDetectLanguage': instance.autoDetectLanguage,
      'fallbackToDefault': instance.fallbackToDefault,
      'regionLanguageMapping': instance.regionLanguageMapping,
    };

LanguageSettings _$LanguageSettingsFromJson(Map<String, dynamic> json) =>
    LanguageSettings(
      languageCode: json['languageCode'] as String,
      enabled: json['enabled'] as bool,
      enabledAt: DateTime.parse(json['enabledAt'] as String),
      enabledBy: json['enabledBy'] as String,
      features: Map<String, bool>.from(json['features'] as Map),
      customTranslations: Map<String, String>.from(
        json['customTranslations'] as Map,
      ),
      regionalVariants: (json['regionalVariants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LanguageSettingsToJson(LanguageSettings instance) =>
    <String, dynamic>{
      'languageCode': instance.languageCode,
      'enabled': instance.enabled,
      'enabledAt': instance.enabledAt.toIso8601String(),
      'enabledBy': instance.enabledBy,
      'features': instance.features,
      'customTranslations': instance.customTranslations,
      'regionalVariants': instance.regionalVariants,
    };

TranslationKey _$TranslationKeyFromJson(Map<String, dynamic> json) =>
    TranslationKey(
      key: json['key'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
      status: $enumDecode(_$TranslationStatusEnumMap, json['status']),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      updatedBy: json['updatedBy'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isContextual: json['isContextual'] as bool,
    );

Map<String, dynamic> _$TranslationKeyToJson(TranslationKey instance) =>
    <String, dynamic>{
      'key': instance.key,
      'category': instance.category,
      'description': instance.description,
      'translations': instance.translations,
      'status': _$TranslationStatusEnumMap[instance.status]!,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'tags': instance.tags,
      'isContextual': instance.isContextual,
    };

const _$TranslationStatusEnumMap = {
  TranslationStatus.draft: 'draft',
  TranslationStatus.inProgress: 'inProgress',
  TranslationStatus.needsReview: 'needsReview',
  TranslationStatus.approved: 'approved',
  TranslationStatus.deprecated: 'deprecated',
};

RegionalConfig _$RegionalConfigFromJson(Map<String, dynamic> json) =>
    RegionalConfig(
      regionCode: json['regionCode'] as String,
      regionName: json['regionName'] as String,
      defaultLanguage: json['defaultLanguage'] as String,
      supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      currency: json['currency'] as String,
      timezone: json['timezone'] as String,
      dateFormat: json['dateFormat'] as String,
      numberFormat: json['numberFormat'] as String,
      culturalSettings: json['culturalSettings'] as Map<String, dynamic>,
      complianceFrameworks: (json['complianceFrameworks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      legalRequirements: Map<String, String>.from(
        json['legalRequirements'] as Map,
      ),
    );

Map<String, dynamic> _$RegionalConfigToJson(RegionalConfig instance) =>
    <String, dynamic>{
      'regionCode': instance.regionCode,
      'regionName': instance.regionName,
      'defaultLanguage': instance.defaultLanguage,
      'supportedLanguages': instance.supportedLanguages,
      'currency': instance.currency,
      'timezone': instance.timezone,
      'dateFormat': instance.dateFormat,
      'numberFormat': instance.numberFormat,
      'culturalSettings': instance.culturalSettings,
      'complianceFrameworks': instance.complianceFrameworks,
      'legalRequirements': instance.legalRequirements,
    };

CulturalAdaptation _$CulturalAdaptationFromJson(Map<String, dynamic> json) =>
    CulturalAdaptation(
      regionCode: json['regionCode'] as String,
      languageCode: json['languageCode'] as String,
      culturalPreferences: Map<String, String>.from(
        json['culturalPreferences'] as Map,
      ),
      sensitiveTopics: (json['sensitiveTopics'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      colorMeanings: Map<String, String>.from(json['colorMeanings'] as Map),
      symbolMeanings: Map<String, String>.from(json['symbolMeanings'] as Map),
      culturalTaboos: (json['culturalTaboos'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      greetingStyles: Map<String, String>.from(json['greetingStyles'] as Map),
      communicationStyles: Map<String, String>.from(
        json['communicationStyles'] as Map,
      ),
    );

Map<String, dynamic> _$CulturalAdaptationToJson(CulturalAdaptation instance) =>
    <String, dynamic>{
      'regionCode': instance.regionCode,
      'languageCode': instance.languageCode,
      'culturalPreferences': instance.culturalPreferences,
      'sensitiveTopics': instance.sensitiveTopics,
      'colorMeanings': instance.colorMeanings,
      'symbolMeanings': instance.symbolMeanings,
      'culturalTaboos': instance.culturalTaboos,
      'greetingStyles': instance.greetingStyles,
      'communicationStyles': instance.communicationStyles,
    };

LanguageMetrics _$LanguageMetricsFromJson(Map<String, dynamic> json) =>
    LanguageMetrics(
      languageCode: json['languageCode'] as String,
      totalKeys: (json['totalKeys'] as num).toInt(),
      translatedKeys: (json['translatedKeys'] as num).toInt(),
      reviewedKeys: (json['reviewedKeys'] as num).toInt(),
      approvedKeys: (json['approvedKeys'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      accuracyRate: (json['accuracyRate'] as num).toDouble(),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      activeContributors: (json['activeContributors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      categoryBreakdown: Map<String, int>.from(
        json['categoryBreakdown'] as Map,
      ),
    );

Map<String, dynamic> _$LanguageMetricsToJson(LanguageMetrics instance) =>
    <String, dynamic>{
      'languageCode': instance.languageCode,
      'totalKeys': instance.totalKeys,
      'translatedKeys': instance.translatedKeys,
      'reviewedKeys': instance.reviewedKeys,
      'approvedKeys': instance.approvedKeys,
      'completionRate': instance.completionRate,
      'accuracyRate': instance.accuracyRate,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'activeContributors': instance.activeContributors,
      'categoryBreakdown': instance.categoryBreakdown,
    };

TranslationProject _$TranslationProjectFromJson(Map<String, dynamic> json) =>
    TranslationProject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      targetLanguages: (json['targetLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sourceLanguage: json['sourceLanguage'] as String,
      status: $enumDecode(_$TranslationProjectStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['startDate'] as String),
      completionDate: json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String),
      progressByLanguage: (json['progressByLanguage'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      assignedTranslators: (json['assignedTranslators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reviews: (json['reviews'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, TranslationReview.fromJson(e as Map<String, dynamic>)),
      ),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TranslationProjectToJson(TranslationProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'targetLanguages': instance.targetLanguages,
      'sourceLanguage': instance.sourceLanguage,
      'status': _$TranslationProjectStatusEnumMap[instance.status]!,
      'startDate': instance.startDate.toIso8601String(),
      'completionDate': instance.completionDate?.toIso8601String(),
      'progressByLanguage': instance.progressByLanguage,
      'assignedTranslators': instance.assignedTranslators,
      'reviews': instance.reviews,
      'metadata': instance.metadata,
    };

const _$TranslationProjectStatusEnumMap = {
  TranslationProjectStatus.planning: 'planning',
  TranslationProjectStatus.inProgress: 'inProgress',
  TranslationProjectStatus.review: 'review',
  TranslationProjectStatus.completed: 'completed',
  TranslationProjectStatus.onHold: 'onHold',
  TranslationProjectStatus.cancelled: 'cancelled',
};

TranslationReview _$TranslationReviewFromJson(Map<String, dynamic> json) =>
    TranslationReview(
      id: json['id'] as String,
      translatorId: json['translatorId'] as String,
      reviewerId: json['reviewerId'] as String,
      status: $enumDecode(_$ReviewStatusEnumMap, json['status']),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => ReviewComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      qualityScore: (json['qualityScore'] as num).toDouble(),
      feedback: json['feedback'] as String,
    );

Map<String, dynamic> _$TranslationReviewToJson(TranslationReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'translatorId': instance.translatorId,
      'reviewerId': instance.reviewerId,
      'status': _$ReviewStatusEnumMap[instance.status]!,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'comments': instance.comments,
      'qualityScore': instance.qualityScore,
      'feedback': instance.feedback,
    };

const _$ReviewStatusEnumMap = {
  ReviewStatus.pending: 'pending',
  ReviewStatus.inProgress: 'inProgress',
  ReviewStatus.approved: 'approved',
  ReviewStatus.needsRevision: 'needsRevision',
  ReviewStatus.rejected: 'rejected',
};

ReviewComment _$ReviewCommentFromJson(Map<String, dynamic> json) =>
    ReviewComment(
      id: json['id'] as String,
      commenterId: json['commenterId'] as String,
      comment: json['comment'] as String,
      type: $enumDecode(_$CommentTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$ReviewCommentToJson(ReviewComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'commenterId': instance.commenterId,
      'comment': instance.comment,
      'type': _$CommentTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'isResolved': instance.isResolved,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

const _$CommentTypeEnumMap = {
  CommentType.suggestion: 'suggestion',
  CommentType.correction: 'correction',
  CommentType.question: 'question',
  CommentType.general: 'general',
};

LanguageDetectionResult _$LanguageDetectionResultFromJson(
  Map<String, dynamic> json,
) => LanguageDetectionResult(
  detectedLanguage: json['detectedLanguage'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => LanguageProbability.fromJson(e as Map<String, dynamic>))
      .toList(),
  isReliable: json['isReliable'] as bool,
  detectionMethod: json['detectionMethod'] as String,
);

Map<String, dynamic> _$LanguageDetectionResultToJson(
  LanguageDetectionResult instance,
) => <String, dynamic>{
  'detectedLanguage': instance.detectedLanguage,
  'confidence': instance.confidence,
  'alternatives': instance.alternatives,
  'isReliable': instance.isReliable,
  'detectionMethod': instance.detectionMethod,
};

LanguageProbability _$LanguageProbabilityFromJson(Map<String, dynamic> json) =>
    LanguageProbability(
      languageCode: json['languageCode'] as String,
      probability: (json['probability'] as num).toDouble(),
    );

Map<String, dynamic> _$LanguageProbabilityToJson(
  LanguageProbability instance,
) => <String, dynamic>{
  'languageCode': instance.languageCode,
  'probability': instance.probability,
};

LocalizationReport _$LocalizationReportFromJson(Map<String, dynamic> json) =>
    LocalizationReport(
      id: json['id'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String,
      languageMetrics: (json['languageMetrics'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, LanguageMetrics.fromJson(e as Map<String, dynamic>)),
      ),
      activeProjects: (json['activeProjects'] as List<dynamic>)
          .map((e) => TranslationProject.fromJson(e as Map<String, dynamic>))
          .toList(),
      languagesNeedingAttention:
          (json['languagesNeedingAttention'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      translationRequests: Map<String, int>.from(
        json['translationRequests'] as Map,
      ),
      userSatisfaction: (json['userSatisfaction'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$LocalizationReportToJson(LocalizationReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'generatedBy': instance.generatedBy,
      'languageMetrics': instance.languageMetrics,
      'activeProjects': instance.activeProjects,
      'languagesNeedingAttention': instance.languagesNeedingAttention,
      'translationRequests': instance.translationRequests,
      'userSatisfaction': instance.userSatisfaction,
    };
