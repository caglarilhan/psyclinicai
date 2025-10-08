import 'package:flutter/material.dart';

/// Diagnosis System - Tanı sistemi
enum DiagnosisSystem { dsm_5_tr, icd_11, icd_10 }

/// Diagnosis Severity - Tanı şiddeti
enum DiagnosisSeverity {
  mild,
  moderate,
  severe,
  critical,
}

/// Diagnosis Entry - Tanı girişi
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

  factory DiagnosisEntry.fromJson(Map<String, dynamic> json) {
    return DiagnosisEntry(
      id: json['id'] as String,
      system: DiagnosisSystem.values.firstWhere(
        (e) => e.name == (json['system'] as String? ?? 'dsm_5_tr'),
        orElse: () => DiagnosisSystem.dsm_5_tr,
      ),
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      synonyms: List<String>.from(json['synonyms'] ?? const <String>[]),
      specifiers: List<String>.from(json['specifiers'] ?? const <String>[]),
      comorbidities: List<String>.from(json['comorbidities'] ?? const <String>[]),
      typicalSeverity: DiagnosisSeverity.values.firstWhere(
        (e) => e.name == (json['typicalSeverity'] as String? ?? 'mild'),
        orElse: () => DiagnosisSeverity.mild,
      ),
      commonTreatments: List<String>.from(json['commonTreatments'] ?? const <String>[]),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? const <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'system': system.name,
      'code': code,
      'title': title,
      'description': description,
      'synonyms': synonyms,
      'specifiers': specifiers,
      'comorbidities': comorbidities,
      'typicalSeverity': typicalSeverity.name,
      'commonTreatments': commonTreatments,
      'metadata': metadata,
    };
  }
}

/// Diagnosis Search Filters - Tanı arama filtreleri
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

  factory DiagnosisSearchFilters.fromJson(Map<String, dynamic> json) {
    return DiagnosisSearchFilters(
      system: DiagnosisSystem.values.firstWhere(
        (e) => e.name == (json['system'] as String? ?? 'dsm_5_tr'),
        orElse: () => DiagnosisSystem.dsm_5_tr,
      ),
      query: json['query'] as String?,
      minSeverity: (json['minSeverity'] as String?) != null
          ? DiagnosisSeverity.values.firstWhere(
              (e) => e.name == json['minSeverity'],
              orElse: () => DiagnosisSeverity.mild,
            )
          : null,
      includeSynonyms: json['includeSynonyms'] as bool? ?? true,
      limit: json['limit'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system': system.name,
      'query': query,
      'minSeverity': minSeverity?.name,
      'includeSynonyms': includeSynonyms,
      'limit': limit,
    };
  }
}

/// Diagnosis Suggestion - Tanı önerisi
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

  factory DiagnosisSuggestion.fromJson(Map<String, dynamic> json) {
    return DiagnosisSuggestion(
      id: json['id'] as String,
      diagnosis: json['diagnosis'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      evidence: List<String>.from(json['evidence'] ?? const <String>[]),
      differentialDiagnoses: List<String>.from(json['differentialDiagnoses'] ?? const <String>[]),
      icd10Code: json['icd10Code'] as String,
      severity: DiagnosisSeverity.values.firstWhere(
        (e) => e.name == (json['severity'] as String? ?? 'mild'),
        orElse: () => DiagnosisSeverity.mild,
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosis': diagnosis,
      'confidence': confidence,
      'evidence': evidence,
      'differentialDiagnoses': differentialDiagnoses,
      'icd10Code': icd10Code,
      'severity': severity.name,
      'notes': notes,
    };
  }
}

/// Regional Diagnosis Config - Bölgesel tanı konfigürasyonu
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

  factory RegionalDiagnosisConfig.fromJson(Map<String, dynamic> json) {
    return RegionalDiagnosisConfig(
      region: json['region'] as String,
      defaultSystem: DiagnosisSystem.values.firstWhere(
        (e) => e.name == (json['defaultSystem'] as String? ?? 'dsm_5_tr'),
        orElse: () => DiagnosisSystem.dsm_5_tr,
      ),
      language: json['language'] as String,
      codeMappings: Map<String, String>.from(json['codeMappings'] ?? const <String, String>{}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? const <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'defaultSystem': defaultSystem.name,
      'language': language,
      'codeMappings': codeMappings,
      'metadata': metadata,
    };
  }
}

/// Diagnosis Category - Tanı kategorisi
class DiagnosisCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int diagnosisCount;
  final List<DiagnosisSubCategory> subCategories;

  const DiagnosisCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.diagnosisCount = 0,
    this.subCategories = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'diagnosisCount': diagnosisCount,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }

  factory DiagnosisCategory.fromJson(Map<String, dynamic> json) {
    return DiagnosisCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      diagnosisCount: json['diagnosisCount'] as int? ?? 0,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => DiagnosisSubCategory.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class DiagnosisSubCategory {
  final String id;
  final String name;
  final String description;
  final int diagnosisCount;

  const DiagnosisSubCategory({
    required this.id,
    required this.name,
    required this.description,
    this.diagnosisCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'diagnosisCount': diagnosisCount,
    };
  }

  factory DiagnosisSubCategory.fromJson(Map<String, dynamic> json) {
    return DiagnosisSubCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      diagnosisCount: json['diagnosisCount'] as int? ?? 0,
    );
  }
}

class Diagnosis {
  final String id;
  final String code;
  final String name;
  final String description;
  final String criteria;
  final DiagnosisCategory category;
  final DiagnosisSeverity severity;
  final List<String> symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final double? confidence;
  final List<String>? differentialDiagnoses;
  final Map<String, dynamic>? metadata;

  const Diagnosis({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.criteria,
    required this.category,
    required this.severity,
    required this.symptoms,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.confidence,
    this.differentialDiagnoses,
    this.metadata,
  });

  Diagnosis copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? criteria,
    DiagnosisCategory? category,
    DiagnosisSeverity? severity,
    List<String>? symptoms,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    double? confidence,
    List<String>? differentialDiagnoses,
    Map<String, dynamic>? metadata,
  }) {
    return Diagnosis(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      criteria: criteria ?? this.criteria,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      confidence: confidence ?? this.confidence,
      differentialDiagnoses: differentialDiagnoses ?? this.differentialDiagnoses,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'criteria': criteria,
      'category': category.toJson(),
      'severity': severity.name,
      'symptoms': symptoms,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'confidence': confidence,
      'differentialDiagnoses': differentialDiagnoses,
      'metadata': metadata,
    };
  }

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      criteria: json['criteria'] as String,
      category: DiagnosisCategory.fromJson(json['category'] as Map<String, dynamic>),
      severity: DiagnosisSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => DiagnosisSeverity.mild,
      ),
      symptoms: List<String>.from(json['symptoms'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      confidence: json['confidence'] as double?,
      differentialDiagnoses: json['differentialDiagnoses'] != null
          ? List<String>.from(json['differentialDiagnoses'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Diagnosis && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Diagnosis(id: $id, code: $code, name: $name, severity: $severity)';
  }
}

class AIDiagnosisSuggestion {
  final String id;
  final Diagnosis diagnosis;
  final double confidence;
  final String reasoning;
  final List<String> supportingSymptoms;
  final List<String> conflictingSymptoms;
  final List<String> recommendations;
  final DateTime generatedAt;

  const AIDiagnosisSuggestion({
    required this.id,
    required this.diagnosis,
    required this.confidence,
    required this.reasoning,
    required this.supportingSymptoms,
    required this.conflictingSymptoms,
    required this.recommendations,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosis': diagnosis.toJson(),
      'confidence': confidence,
      'reasoning': reasoning,
      'supportingSymptoms': supportingSymptoms,
      'conflictingSymptoms': conflictingSymptoms,
      'recommendations': recommendations,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory AIDiagnosisSuggestion.fromJson(Map<String, dynamic> json) {
    return AIDiagnosisSuggestion(
      id: json['id'] as String,
      diagnosis: Diagnosis.fromJson(json['diagnosis'] as Map<String, dynamic>),
      confidence: json['confidence'] as double,
      reasoning: json['reasoning'] as String,
      supportingSymptoms: List<String>.from(json['supportingSymptoms'] as List),
      conflictingSymptoms: List<String>.from(json['conflictingSymptoms'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}

class DiagnosisSearchResult {
  final List<Diagnosis> diagnoses;
  final int totalCount;
  final String searchQuery;
  final List<String> suggestions;
  final Duration searchTime;

  const DiagnosisSearchResult({
    required this.diagnoses,
    required this.totalCount,
    required this.searchQuery,
    this.suggestions = const [],
    required this.searchTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'diagnoses': diagnoses.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'searchQuery': searchQuery,
      'suggestions': suggestions,
      'searchTime': searchTime.inMilliseconds,
    };
  }

  factory DiagnosisSearchResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisSearchResult(
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      searchQuery: json['searchQuery'] as String,
      suggestions: List<String>.from(json['suggestions'] as List),
      searchTime: Duration(milliseconds: json['searchTime'] as int),
    );
  }
}

class DiagnosisStatistics {
  final int totalDiagnoses;
  final Map<DiagnosisCategory, int> diagnosesByCategory;
  final Map<DiagnosisSeverity, int> diagnosesBySeverity;
  final Map<String, int> diagnosesByMonth;
  final double averageConfidence;
  final List<Diagnosis> mostCommonDiagnoses;
  final List<Diagnosis> recentDiagnoses;

  const DiagnosisStatistics({
    required this.totalDiagnoses,
    required this.diagnosesByCategory,
    required this.diagnosesBySeverity,
    required this.diagnosesByMonth,
    required this.averageConfidence,
    required this.mostCommonDiagnoses,
    required this.recentDiagnoses,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalDiagnoses': totalDiagnoses,
      'diagnosesByCategory': diagnosesByCategory.map(
        (key, value) => MapEntry(key.id, value),
      ),
      'diagnosesBySeverity': diagnosesBySeverity.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'diagnosesByMonth': diagnosesByMonth,
      'averageConfidence': averageConfidence,
      'mostCommonDiagnoses': mostCommonDiagnoses.map((e) => e.toJson()).toList(),
      'recentDiagnoses': recentDiagnoses.map((e) => e.toJson()).toList(),
    };
  }

  factory DiagnosisStatistics.fromJson(Map<String, dynamic> json) {
    return DiagnosisStatistics(
      totalDiagnoses: json['totalDiagnoses'] as int,
      diagnosesByCategory: (json['diagnosesByCategory'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          DiagnosisCategory.fromJson({'id': key, 'name': '', 'description': '', 'icon': 0, 'color': 0}),
          value as int,
        ),
      ),
      diagnosesBySeverity: (json['diagnosesBySeverity'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          DiagnosisSeverity.values.firstWhere((e) => e.name == key),
          value as int,
        ),
      ),
      diagnosesByMonth: Map<String, int>.from(json['diagnosesByMonth'] as Map),
      averageConfidence: json['averageConfidence'] as double,
      mostCommonDiagnoses: (json['mostCommonDiagnoses'] as List<dynamic>)
          .map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentDiagnoses: (json['recentDiagnoses'] as List<dynamic>)
          .map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
