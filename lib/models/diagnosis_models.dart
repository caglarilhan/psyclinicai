import 'package:json_annotation/json_annotation.dart';

part 'diagnosis_models.g.dart';

// ICD-11 Ana Kategori
@JsonSerializable()
class ICD11Category {
  final String code;
  final String title;
  final String description;
  final List<String> languages;
  final Map<String, String> translations;
  final List<ICD11Subcategory> subcategories;
  final List<String> keywords;
  final List<String> synonyms;
  final String parentCode;
  final int level;
  final bool isActive;
  final DateTime lastUpdated;

  ICD11Category({
    required this.code,
    required this.title,
    required this.description,
    required this.languages,
    required this.translations,
    required this.subcategories,
    required this.keywords,
    required this.synonyms,
    required this.parentCode,
    required this.level,
    required this.isActive,
    required this.lastUpdated,
  });

  factory ICD11Category.fromJson(Map<String, dynamic> json) =>
      _$ICD11CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ICD11CategoryToJson(this);
}

// ICD-11 Alt Kategori
@JsonSerializable()
class ICD11Subcategory {
  final String code;
  final String title;
  final String description;
  final Map<String, String> translations;
  final List<String> keywords;
  final List<String> synonyms;
  final List<String> inclusionCriteria;
  final List<String> exclusionCriteria;
  final List<String> relatedConditions;
  final String parentCode;
  final int level;
  final bool isActive;
  final DateTime lastUpdated;

  ICD11Subcategory({
    required this.code,
    required this.title,
    required this.description,
    required this.translations,
    required this.keywords,
    required this.synonyms,
    required this.inclusionCriteria,
    required this.exclusionCriteria,
    required this.relatedConditions,
    required this.parentCode,
    required this.level,
    required this.isActive,
    required this.lastUpdated,
  });

  factory ICD11Subcategory.fromJson(Map<String, dynamic> json) =>
      _$ICD11SubcategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ICD11SubcategoryToJson(this);
}

// ICD-11 Tanı Kodu
@JsonSerializable()
class ICD11Diagnosis {
  final String code;
  final String title;
  final String description;
  final Map<String, String> translations;
  final List<String> keywords;
  final List<String> synonyms;
  final List<String> inclusionCriteria;
  final List<String> exclusionCriteria;
  final List<String> relatedConditions;
  final List<String> symptoms;
  final List<String> riskFactors;
  final List<String> complications;
  final String severity;
  final String chronicity;
  final String category;
  final String subcategory;
  final List<String> treatmentOptions;
  final List<String> medications;
  final List<String> therapies;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime lastUpdated;

  ICD11Diagnosis({
    required this.code,
    required this.title,
    required this.description,
    required this.translations,
    required this.keywords,
    required this.synonyms,
    required this.inclusionCriteria,
    required this.exclusionCriteria,
    required this.relatedConditions,
    required this.symptoms,
    required this.riskFactors,
    required this.complications,
    required this.severity,
    required this.chronicity,
    required this.category,
    required this.subcategory,
    required this.treatmentOptions,
    required this.medications,
    required this.therapies,
    required this.metadata,
    required this.isActive,
    required this.lastUpdated,
  });

  factory ICD11Diagnosis.fromJson(Map<String, dynamic> json) =>
      _$ICD11DiagnosisFromJson(json);

  Map<String, dynamic> toJson() => _$ICD11DiagnosisToJson(this);
}

// DSM-5-TR Tanı Kriterleri
@JsonSerializable()
class DSM5Diagnosis {
  final String code;
  final String title;
  final String description;
  final Map<String, String> translations;
  final List<DSM5Criterion> criteria;
  final List<String> symptoms;
  final List<String> riskFactors;
  final List<String> complications;
  final String severity;
  final String chronicity;
  final List<String> differentialDiagnosis;
  final List<String> comorbidities;
  final List<String> treatmentOptions;
  final List<String> medications;
  final List<String> therapies;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime lastUpdated;

  DSM5Diagnosis({
    required this.code,
    required this.title,
    required this.description,
    required this.translations,
    required this.criteria,
    required this.symptoms,
    required this.riskFactors,
    required this.complications,
    required this.severity,
    required this.chronicity,
    required this.differentialDiagnosis,
    required this.comorbidities,
    required this.treatmentOptions,
    required this.medications,
    required this.therapies,
    required this.metadata,
    required this.isActive,
    required this.lastUpdated,
  });

  factory DSM5Diagnosis.fromJson(Map<String, dynamic> json) =>
      _$DSM5DiagnosisFromJson(json);

  Map<String, dynamic> toJson() => _$DSM5DiagnosisToJson(this);
}

// DSM-5 Kriter
@JsonSerializable()
class DSM5Criterion {
  final String code;
  final String description;
  final Map<String, String> translations;
  final List<String> examples;
  final String type; // required, optional, exclusion
  final int minRequired;
  final int maxAllowed;
  final List<String> subCriteria;
  final Map<String, dynamic> metadata;

  DSM5Criterion({
    required this.code,
    required this.description,
    required this.translations,
    required this.examples,
    required this.type,
    required this.minRequired,
    required this.maxAllowed,
    required this.subCriteria,
    required this.metadata,
  });

  factory DSM5Criterion.fromJson(Map<String, dynamic> json) =>
      _$DSM5CriterionFromJson(json);

  Map<String, dynamic> toJson() => _$DSM5CriterionToJson(this);
}

// AI Destekli Tanı Önerisi
@JsonSerializable()
class AIDiagnosisSuggestion {
  final String suggestedDiagnosis;
  final String diagnosisCode;
  final String classificationSystem; // ICD-11, DSM-5, etc.
  final double confidence;
  final List<String> supportingSymptoms;
  final List<String> supportingCriteria;
  final List<String> conflictingSymptoms;
  final List<String> conflictingCriteria;
  final List<String> differentialDiagnoses;
  final List<String> recommendedAssessments;
  final List<String> recommendedTests;
  final String reasoning;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;

  AIDiagnosisSuggestion({
    required this.suggestedDiagnosis,
    required this.diagnosisCode,
    required this.classificationSystem,
    required this.confidence,
    required this.supportingSymptoms,
    required this.supportingCriteria,
    required this.conflictingSymptoms,
    required this.conflictingCriteria,
    required this.differentialDiagnoses,
    required this.recommendedAssessments,
    required this.recommendedTests,
    required this.reasoning,
    required this.metadata,
    required this.generatedAt,
  });

  factory AIDiagnosisSuggestion.fromJson(Map<String, dynamic> json) =>
      _$AIDiagnosisSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$AIDiagnosisSuggestionToJson(this);
}

// Tanı Arama Sonucu
@JsonSerializable()
class DiagnosisSearchResult {
  final List<ICD11Diagnosis> icd11Results;
  final List<DSM5Diagnosis> dsm5Results;
  final List<AIDiagnosisSuggestion> aiSuggestions;
  final int totalResults;
  final String searchQuery;
  final List<String> filters;
  final Map<String, dynamic> metadata;
  final DateTime searchedAt;

  DiagnosisSearchResult({
    required this.icd11Results,
    required this.dsm5Results,
    required this.aiSuggestions,
    required this.totalResults,
    required this.searchQuery,
    required this.filters,
    required this.metadata,
    required this.searchedAt,
  });

  factory DiagnosisSearchResult.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisSearchResultToJson(this);
}

// Tanı Geçmişi
@JsonSerializable()
class DiagnosisHistory {
  final String patientId;
  final String diagnosisCode;
  final String diagnosisTitle;
  final String classificationSystem;
  final String severity;
  final String status; // active, resolved, chronic
  final DateTime diagnosedAt;
  final DateTime? resolvedAt;
  final String diagnosedBy;
  final String notes;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> medications;
  final double confidence;
  final String source; // manual, ai_suggested, ai_confirmed
  final Map<String, dynamic> metadata;

  DiagnosisHistory({
    required this.patientId,
    required this.diagnosisCode,
    required this.diagnosisTitle,
    required this.classificationSystem,
    required this.severity,
    required this.status,
    required this.diagnosedAt,
    this.resolvedAt,
    required this.diagnosedBy,
    required this.notes,
    required this.symptoms,
    required this.treatments,
    required this.medications,
    required this.confidence,
    required this.source,
    required this.metadata,
  });

  factory DiagnosisHistory.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisHistoryToJson(this);
}

// Tanı Trend Analizi
@JsonSerializable()
class DiagnosisTrend {
  final String diagnosisCode;
  final String diagnosisTitle;
  final String period; // daily, weekly, monthly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final int totalCases;
  final int newCases;
  final int resolvedCases;
  final double prevalence;
  final double incidence;
  final List<Map<String, dynamic>> timeSeriesData;
  final Map<String, dynamic> demographics;
  final Map<String, dynamic> riskFactors;
  final Map<String, dynamic> outcomes;
  final Map<String, dynamic> metadata;

  DiagnosisTrend({
    required this.diagnosisCode,
    required this.diagnosisTitle,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalCases,
    required this.newCases,
    required this.resolvedCases,
    required this.prevalence,
    required this.incidence,
    required this.timeSeriesData,
    required this.demographics,
    required this.riskFactors,
    required this.outcomes,
    required this.metadata,
  });

  factory DiagnosisTrend.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisTrendFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisTrendToJson(this);
}

// Tanı İstatistikleri
@JsonSerializable()
class DiagnosisStatistics {
  final int totalDiagnoses;
  final int activeDiagnoses;
  final int resolvedDiagnoses;
  final int chronicDiagnoses;
  final Map<String, int> diagnosesByCategory;
  final Map<String, int> diagnosesBySeverity;
  final Map<String, int> diagnosesBySystem;
  final List<DiagnosisTrend> topTrendingDiagnoses;
  final Map<String, double> averageResolutionTime;
  final Map<String, double> treatmentSuccessRate;
  final Map<String, dynamic> metadata;
  final DateTime calculatedAt;

  DiagnosisStatistics({
    required this.totalDiagnoses,
    required this.activeDiagnoses,
    required this.resolvedDiagnoses,
    required this.chronicDiagnoses,
    required this.diagnosesByCategory,
    required this.diagnosesBySeverity,
    required this.diagnosesBySystem,
    required this.topTrendingDiagnoses,
    required this.averageResolutionTime,
    required this.treatmentSuccessRate,
    required this.metadata,
    required this.calculatedAt,
  });

  factory DiagnosisStatistics.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisStatisticsToJson(this);
}

// Tanı Arama Filtreleri
@JsonSerializable()
class DiagnosisSearchFilters {
  final List<String> classificationSystems;
  final List<String> categories;
  final List<String> subcategories;
  final List<String> severityLevels;
  final List<String> chronicityTypes;
  final List<String> languages;
  final bool includeInactive;
  final bool includeAI;
  final bool includeSynonyms;
  final bool includeRelated;
  final int maxResults;
  final String sortBy;
  final String sortOrder;
  final Map<String, dynamic> customFilters;

  DiagnosisSearchFilters({
    required this.classificationSystems,
    required this.categories,
    required this.subcategories,
    required this.severityLevels,
    required this.chronicityTypes,
    required this.languages,
    required this.includeInactive,
    required this.includeAI,
    required this.includeSynonyms,
    required this.includeRelated,
    required this.maxResults,
    required this.sortBy,
    required this.sortOrder,
    required this.customFilters,
  });

  factory DiagnosisSearchFilters.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisSearchFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisSearchFiltersToJson(this);
}

// Tanı Öneri Ayarları
@JsonSerializable()
class DiagnosisSuggestionSettings {
  final double minConfidence;
  final int maxSuggestions;
  final List<String> preferredSystems;
  final List<String> excludedCategories;
  final bool includeDifferentialDiagnosis;
  final bool includeTreatmentOptions;
  final bool includeRiskFactors;
  final bool includeComorbidities;
  final String language;
  final Map<String, dynamic> customSettings;

  DiagnosisSuggestionSettings({
    required this.minConfidence,
    required this.maxSuggestions,
    required this.preferredSystems,
    required this.excludedCategories,
    required this.includeDifferentialDiagnosis,
    required this.includeTreatmentOptions,
    required this.includeRiskFactors,
    required this.includeComorbidities,
    required this.language,
    required this.customSettings,
  });

  factory DiagnosisSuggestionSettings.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisSuggestionSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisSuggestionSettingsToJson(this);
}
