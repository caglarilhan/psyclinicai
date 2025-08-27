import 'package:json_annotation/json_annotation.dart';

part 'diagnosis_models.g.dart';

/// Diagnosis System - Tanı sistemi
enum DiagnosisSystem {
  @JsonValue('dsm_5_tr') dsm_5_tr,
  @JsonValue('icd_11') icd_11,
  @JsonValue('icd_10') icd_10,
}

/// Diagnosis Severity - Tanı şiddeti
enum DiagnosisSeverity {
  @JsonValue('mild') mild,
  @JsonValue('moderate') moderate,
  @JsonValue('severe') severe,
  @JsonValue('very_severe') verySevere,
}

/// Diagnosis Entry - Tanı girişi
@JsonSerializable()
class DiagnosisEntry {
  final String id;
  final DiagnosisSystem system;
  final String code;
  final String title;
  final String description;
  final List<String> synonyms;
  final List<String> specifiers;
  final List<String> comorbidities;
  final DiagnosisSeverity typicalSeverity;
  final List<String> commonTreatments;
  final Map<String, dynamic> metadata;

  const DiagnosisEntry({
    required this.id,
    required this.system,
    required this.code,
    required this.title,
    required this.description,
    required this.synonyms,
    required this.specifiers,
    required this.comorbidities,
    required this.typicalSeverity,
    required this.commonTreatments,
    required this.metadata,
  });

  factory DiagnosisEntry.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisEntryFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisEntryToJson(this);
}

/// Diagnosis Search Filters - Tanı arama filtreleri
@JsonSerializable()
class DiagnosisSearchFilters {
  final DiagnosisSystem system;
  final String? query;
  final DiagnosisSeverity? minSeverity;
  final bool includeSynonyms;
  final int limit;

  const DiagnosisSearchFilters({
    required this.system,
    this.query,
    this.minSeverity,
    this.includeSynonyms = true,
    this.limit = 20,
  });

  factory DiagnosisSearchFilters.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisSearchFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisSearchFiltersToJson(this);
}

/// Diagnosis Suggestion - Tanı önerisi
@JsonSerializable()
class DiagnosisSuggestion {
  final String id;
  final String diagnosis;
  final double confidence;
  final List<String> evidence;
  final List<String> differentialDiagnoses;
  final String icd10Code;
  final DiagnosisSeverity severity;
  final String? notes;

  const DiagnosisSuggestion({
    required this.id,
    required this.diagnosis,
    required this.confidence,
    required this.evidence,
    required this.differentialDiagnoses,
    required this.icd10Code,
    required this.severity,
    this.notes,
  });

  factory DiagnosisSuggestion.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisSuggestionToJson(this);
}

/// Regional Diagnosis Config - Bölgesel tanı konfigürasyonu
@JsonSerializable()
class RegionalDiagnosisConfig {
  final String region;
  final DiagnosisSystem defaultSystem;
  final String language;
  final Map<String, String> codeMappings;
  final Map<String, dynamic> metadata;

  const RegionalDiagnosisConfig({
    required this.region,
    required this.defaultSystem,
    required this.language,
    required this.codeMappings,
    required this.metadata,
  });

  factory RegionalDiagnosisConfig.fromJson(Map<String, dynamic> json) =>
      _$RegionalDiagnosisConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RegionalDiagnosisConfigToJson(this);
}

/// Diagnosis Category - Tanı kategorisi
@JsonSerializable()
class DiagnosisCategory {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<String> parentCategories;
  final List<String> childCategories;
  final List<String> disorderIds;
  final Map<String, dynamic> metadata;

  const DiagnosisCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.parentCategories,
    required this.childCategories,
    required this.disorderIds,
    required this.metadata,
  });

  factory DiagnosisCategory.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisCategoryToJson(this);
}
