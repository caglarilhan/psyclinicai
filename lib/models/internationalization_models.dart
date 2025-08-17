import 'package:json_annotation/json_annotation.dart';

part 'internationalization_models.g.dart';

@JsonSerializable()
class LocalizationConfig {
  final String id;
  final String organizationId;
  final String primaryLanguage;
  final List<String> supportedLanguages;
  final String defaultCurrency;
  final String defaultTimezone;
  final String dateFormat;
  final String timeFormat;
  final String numberFormat;
  final Map<String, dynamic> translations;
  final List<LocalizedContent> localizedContent;
  final CulturalPreferences culturalPreferences;

  const LocalizationConfig({
    required this.id,
    required this.organizationId,
    required this.primaryLanguage,
    required this.supportedLanguages,
    required this.defaultCurrency,
    required this.defaultTimezone,
    required this.dateFormat,
    required this.timeFormat,
    required this.numberFormat,
    required this.translations,
    required this.localizedContent,
    required this.culturalPreferences,
  });

  factory LocalizationConfig.fromJson(Map<String, dynamic> json) =>
      _$LocalizationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizationConfigToJson(this);
}

@JsonSerializable()
class LocalizedContent {
  final String id;
  final String contentType;
  final String language;
  final String title;
  final String content;
  final String? description;
  final List<String> tags;
  final ContentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? authorId;
  final Map<String, dynamic> metadata;

  const LocalizedContent({
    required this.id,
    required this.contentType,
    required this.language,
    required this.title,
    required this.content,
    this.description,
    required this.tags,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.authorId,
    required this.metadata,
  });

  factory LocalizedContent.fromJson(Map<String, dynamic> json) =>
      _$LocalizedContentFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizedContentToJson(this);
}

@JsonSerializable()
class CulturalPreferences {
  final String id;
  final String organizationId;
  final String country;
  final String region;
  final List<String> languages;
  final String primaryLanguage;
  final String currency;
  final String timezone;
  final String dateFormat;
  final String timeFormat;
  final String numberFormat;
  final List<String> holidays;
  final List<String> culturalEvents;
  final Map<String, dynamic> customs;
  final List<String> religiousObservances;
  final Map<String, String> greetings;
  final Map<String, String> farewells;

  const CulturalPreferences({
    required this.id,
    required this.organizationId,
    required this.country,
    required this.region,
    required this.languages,
    required this.primaryLanguage,
    required this.currency,
    required this.timezone,
    required this.dateFormat,
    required this.timeFormat,
    required this.numberFormat,
    required this.holidays,
    required this.culturalEvents,
    required this.customs,
    required this.religiousObservances,
    required this.greetings,
    required this.farewells,
  });

  factory CulturalPreferences.fromJson(Map<String, dynamic> json) =>
      _$CulturalPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalPreferencesToJson(this);
}

@JsonSerializable()
class MedicalTerminology {
  final String id;
  final String language;
  final String country;
  final Map<String, String> terms;
  final Map<String, String> abbreviations;
  final Map<String, String> synonyms;
  final Map<String, String> antonyms;
  final List<String> icdCodes;
  final List<String> medicationNames;
  final List<String> procedureNames;
  final Map<String, String> units;
  final DateTime lastUpdated;

  const MedicalTerminology({
    required this.id,
    required this.language,
    required this.country,
    required this.terms,
    required this.abbreviations,
    required this.synonyms,
    required this.antonyms,
    required this.icdCodes,
    required this.medicationNames,
    required this.procedureNames,
    required this.units,
    required this.lastUpdated,
  });

  factory MedicalTerminology.fromJson(Map<String, dynamic> json) =>
      _$MedicalTerminologyFromJson(json);

  Map<String, dynamic> toJson() => _$MedicalTerminologyToJson(this);
}

@JsonSerializable()
class RegionalCompliance {
  final String id;
  final String country;
  final String region;
  final List<String> applicableLaws;
  final List<String> requiredCertifications;
  final List<String> mandatoryReports;
  final List<String> dataRetentionRequirements;
  final List<String> privacyLaws;
  final List<String> securityStandards;
  final List<String> auditRequirements;
  final Map<String, dynamic> complianceChecklist;
  final DateTime lastReviewDate;
  final DateTime nextReviewDate;

  const RegionalCompliance({
    required this.id,
    required this.country,
    required this.region,
    required this.applicableLaws,
    required this.requiredCertifications,
    required this.mandatoryReports,
    required this.dataRetentionRequirements,
    required this.privacyLaws,
    required this.securityStandards,
    required this.auditRequirements,
    required this.complianceChecklist,
    required this.lastReviewDate,
    required this.nextReviewDate,
  });

  factory RegionalCompliance.fromJson(Map<String, dynamic> json) =>
      _$RegionalComplianceFromJson(json);

  Map<String, dynamic> toJson() => _$RegionalComplianceToJson(this);
}

@JsonSerializable()
class LanguageSupport {
  final String id;
  final String languageCode;
  final String languageName;
  final String nativeName;
  final String country;
  final bool isRTL;
  final bool isSupported;
  final double translationCompleteness;
  final List<String> supportedFeatures;
  final List<String> unsupportedFeatures;
  final DateTime lastUpdated;
  final String? translatorNotes;

  const LanguageSupport({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.country,
    required this.isRTL,
    required this.isSupported,
    required this.translationCompleteness,
    required this.supportedFeatures,
    required this.unsupportedFeatures,
    required this.lastUpdated,
    this.translatorNotes,
  });

  factory LanguageSupport.fromJson(Map<String, dynamic> json) =>
      _$LanguageSupportFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageSupportToJson(this);

  bool get isFullySupported => translationCompleteness >= 0.95;
  bool get needsTranslation => translationCompleteness < 0.8;
}

@JsonSerializable()
class RegionalPricing {
  final String id;
  final String country;
  final String region;
  final String currency;
  final double exchangeRate;
  final List<LocalizedPricing> pricingPlans;
  final List<String> paymentMethods;
  final List<String> taxRates;
  final List<String> discounts;
  final Map<String, dynamic> regionalFeatures;
  final DateTime lastUpdated;

  const RegionalPricing({
    required this.id,
    required this.country,
    required this.region,
    required this.currency,
    required this.exchangeRate,
    required this.pricingPlans,
    required this.paymentMethods,
    required this.taxRates,
    required this.discounts,
    required this.regionalFeatures,
    required this.lastUpdated,
  });

  factory RegionalPricing.fromJson(Map<String, dynamic> json) =>
      _$RegionalPricingFromJson(json);

  Map<String, dynamic> toJson() => _$RegionalPricingToJson(this);
}

@JsonSerializable()
class LocalizedPricing {
  final String id;
  final String planName;
  final String language;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final List<String> features;
  final List<String> limitations;
  final Map<String, dynamic> metadata;

  const LocalizedPricing({
    required this.id,
    required this.planName,
    required this.language,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.features,
    required this.limitations,
    required this.metadata,
  });

  factory LocalizedPricing.fromJson(Map<String, dynamic> json) =>
      _$LocalizedPricingFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizedPricingToJson(this);
}

enum ContentStatus {
  draft,
  published,
  archived,
  pending,
  review,
}

enum ContentType {
  diagnosis,
  medication,
  procedure,
  education,
  policy,
  form,
  notification,
  help,
  other,
}
