// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internationalization_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalizationConfig _$LocalizationConfigFromJson(Map<String, dynamic> json) =>
    LocalizationConfig(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      primaryLanguage: json['primaryLanguage'] as String,
      supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      defaultCurrency: json['defaultCurrency'] as String,
      defaultTimezone: json['defaultTimezone'] as String,
      dateFormat: json['dateFormat'] as String,
      timeFormat: json['timeFormat'] as String,
      numberFormat: json['numberFormat'] as String,
      translations: json['translations'] as Map<String, dynamic>,
      localizedContent: (json['localizedContent'] as List<dynamic>)
          .map((e) => LocalizedContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      culturalPreferences: CulturalPreferences.fromJson(
        json['culturalPreferences'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$LocalizationConfigToJson(LocalizationConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'primaryLanguage': instance.primaryLanguage,
      'supportedLanguages': instance.supportedLanguages,
      'defaultCurrency': instance.defaultCurrency,
      'defaultTimezone': instance.defaultTimezone,
      'dateFormat': instance.dateFormat,
      'timeFormat': instance.timeFormat,
      'numberFormat': instance.numberFormat,
      'translations': instance.translations,
      'localizedContent': instance.localizedContent,
      'culturalPreferences': instance.culturalPreferences,
    };

LocalizedContent _$LocalizedContentFromJson(Map<String, dynamic> json) =>
    LocalizedContent(
      id: json['id'] as String,
      contentType: json['contentType'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      status: $enumDecode(_$ContentStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      authorId: json['authorId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LocalizedContentToJson(LocalizedContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentType': instance.contentType,
      'language': instance.language,
      'title': instance.title,
      'content': instance.content,
      'description': instance.description,
      'tags': instance.tags,
      'status': _$ContentStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'authorId': instance.authorId,
      'metadata': instance.metadata,
    };

const _$ContentStatusEnumMap = {
  ContentStatus.draft: 'draft',
  ContentStatus.published: 'published',
  ContentStatus.archived: 'archived',
  ContentStatus.pending: 'pending',
  ContentStatus.review: 'review',
};

CulturalPreferences _$CulturalPreferencesFromJson(Map<String, dynamic> json) =>
    CulturalPreferences(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      country: json['country'] as String,
      region: json['region'] as String,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      primaryLanguage: json['primaryLanguage'] as String,
      currency: json['currency'] as String,
      timezone: json['timezone'] as String,
      dateFormat: json['dateFormat'] as String,
      timeFormat: json['timeFormat'] as String,
      numberFormat: json['numberFormat'] as String,
      holidays: (json['holidays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      culturalEvents: (json['culturalEvents'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      customs: json['customs'] as Map<String, dynamic>,
      religiousObservances: (json['religiousObservances'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      greetings: Map<String, String>.from(json['greetings'] as Map),
      farewells: Map<String, String>.from(json['farewells'] as Map),
    );

Map<String, dynamic> _$CulturalPreferencesToJson(
  CulturalPreferences instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'country': instance.country,
  'region': instance.region,
  'languages': instance.languages,
  'primaryLanguage': instance.primaryLanguage,
  'currency': instance.currency,
  'timezone': instance.timezone,
  'dateFormat': instance.dateFormat,
  'timeFormat': instance.timeFormat,
  'numberFormat': instance.numberFormat,
  'holidays': instance.holidays,
  'culturalEvents': instance.culturalEvents,
  'customs': instance.customs,
  'religiousObservances': instance.religiousObservances,
  'greetings': instance.greetings,
  'farewells': instance.farewells,
};

MedicalTerminology _$MedicalTerminologyFromJson(Map<String, dynamic> json) =>
    MedicalTerminology(
      id: json['id'] as String,
      language: json['language'] as String,
      country: json['country'] as String,
      terms: Map<String, String>.from(json['terms'] as Map),
      abbreviations: Map<String, String>.from(json['abbreviations'] as Map),
      synonyms: Map<String, String>.from(json['synonyms'] as Map),
      antonyms: Map<String, String>.from(json['antonyms'] as Map),
      icdCodes: (json['icdCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medicationNames: (json['medicationNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      procedureNames: (json['procedureNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      units: Map<String, String>.from(json['units'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$MedicalTerminologyToJson(MedicalTerminology instance) =>
    <String, dynamic>{
      'id': instance.id,
      'language': instance.language,
      'country': instance.country,
      'terms': instance.terms,
      'abbreviations': instance.abbreviations,
      'synonyms': instance.synonyms,
      'antonyms': instance.antonyms,
      'icdCodes': instance.icdCodes,
      'medicationNames': instance.medicationNames,
      'procedureNames': instance.procedureNames,
      'units': instance.units,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

RegionalCompliance _$RegionalComplianceFromJson(Map<String, dynamic> json) =>
    RegionalCompliance(
      id: json['id'] as String,
      country: json['country'] as String,
      region: json['region'] as String,
      applicableLaws: (json['applicableLaws'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      requiredCertifications: (json['requiredCertifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mandatoryReports: (json['mandatoryReports'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dataRetentionRequirements:
          (json['dataRetentionRequirements'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      privacyLaws: (json['privacyLaws'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      securityStandards: (json['securityStandards'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      auditRequirements: (json['auditRequirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      complianceChecklist: json['complianceChecklist'] as Map<String, dynamic>,
      lastReviewDate: DateTime.parse(json['lastReviewDate'] as String),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
    );

Map<String, dynamic> _$RegionalComplianceToJson(RegionalCompliance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'country': instance.country,
      'region': instance.region,
      'applicableLaws': instance.applicableLaws,
      'requiredCertifications': instance.requiredCertifications,
      'mandatoryReports': instance.mandatoryReports,
      'dataRetentionRequirements': instance.dataRetentionRequirements,
      'privacyLaws': instance.privacyLaws,
      'securityStandards': instance.securityStandards,
      'auditRequirements': instance.auditRequirements,
      'complianceChecklist': instance.complianceChecklist,
      'lastReviewDate': instance.lastReviewDate.toIso8601String(),
      'nextReviewDate': instance.nextReviewDate.toIso8601String(),
    };

LanguageSupport _$LanguageSupportFromJson(Map<String, dynamic> json) =>
    LanguageSupport(
      id: json['id'] as String,
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      nativeName: json['nativeName'] as String,
      country: json['country'] as String,
      isRTL: json['isRTL'] as bool,
      isSupported: json['isSupported'] as bool,
      translationCompleteness: (json['translationCompleteness'] as num)
          .toDouble(),
      supportedFeatures: (json['supportedFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      unsupportedFeatures: (json['unsupportedFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      translatorNotes: json['translatorNotes'] as String?,
    );

Map<String, dynamic> _$LanguageSupportToJson(LanguageSupport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'languageCode': instance.languageCode,
      'languageName': instance.languageName,
      'nativeName': instance.nativeName,
      'country': instance.country,
      'isRTL': instance.isRTL,
      'isSupported': instance.isSupported,
      'translationCompleteness': instance.translationCompleteness,
      'supportedFeatures': instance.supportedFeatures,
      'unsupportedFeatures': instance.unsupportedFeatures,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'translatorNotes': instance.translatorNotes,
    };

RegionalPricing _$RegionalPricingFromJson(Map<String, dynamic> json) =>
    RegionalPricing(
      id: json['id'] as String,
      country: json['country'] as String,
      region: json['region'] as String,
      currency: json['currency'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      pricingPlans: (json['pricingPlans'] as List<dynamic>)
          .map((e) => LocalizedPricing.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentMethods: (json['paymentMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      taxRates: (json['taxRates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      discounts: (json['discounts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      regionalFeatures: json['regionalFeatures'] as Map<String, dynamic>,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$RegionalPricingToJson(RegionalPricing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'country': instance.country,
      'region': instance.region,
      'currency': instance.currency,
      'exchangeRate': instance.exchangeRate,
      'pricingPlans': instance.pricingPlans,
      'paymentMethods': instance.paymentMethods,
      'taxRates': instance.taxRates,
      'discounts': instance.discounts,
      'regionalFeatures': instance.regionalFeatures,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

LocalizedPricing _$LocalizedPricingFromJson(Map<String, dynamic> json) =>
    LocalizedPricing(
      id: json['id'] as String,
      planName: json['planName'] as String,
      language: json['language'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      yearlyPrice: (json['yearlyPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      limitations: (json['limitations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LocalizedPricingToJson(LocalizedPricing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planName': instance.planName,
      'language': instance.language,
      'description': instance.description,
      'monthlyPrice': instance.monthlyPrice,
      'yearlyPrice': instance.yearlyPrice,
      'currency': instance.currency,
      'features': instance.features,
      'limitations': instance.limitations,
      'metadata': instance.metadata,
    };
