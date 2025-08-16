import 'package:json_annotation/json_annotation.dart';

part 'global_medical_standards.g.dart';

// Global Tıbbi Standartlar
@JsonSerializable()
class GlobalMedicalStandards {
  final String id;
  final String name;
  final String organization;
  final String version;
  final DateTime publishedDate;
  final DateTime lastUpdated;
  final String status; // active, deprecated, draft
  final List<String> applicableRegions;
  final List<String> applicableSpecialties;
  final Map<String, dynamic> standards;
  final List<String> references;
  final Map<String, dynamic> metadata;

  GlobalMedicalStandards({
    required this.id,
    required this.name,
    required this.organization,
    required this.version,
    required this.publishedDate,
    required this.lastUpdated,
    required this.status,
    required this.applicableRegions,
    required this.applicableSpecialties,
    required this.standards,
    required this.references,
    required this.metadata,
  });

  factory GlobalMedicalStandards.fromJson(Map<String, dynamic> json) =>
      _$GlobalMedicalStandardsFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalMedicalStandardsToJson(this);
}

// WHO Guidelines
@JsonSerializable()
class WHOGuidelines {
  final String id;
  final String title;
  final String category;
  final String version;
  final DateTime publishedDate;
  final List<String> targetAudience;
  final List<String> keyRecommendations;
  final List<String> evidenceLevels;
  final Map<String, dynamic> implementationGuidance;
  final List<String> references;
  final Map<String, dynamic> metadata;

  WHOGuidelines({
    required this.id,
    required this.title,
    required this.category,
    required this.version,
    required this.publishedDate,
    required this.targetAudience,
    required this.keyRecommendations,
    required this.evidenceLevels,
    required this.implementationGuidance,
    required this.references,
    required this.metadata,
  });

  factory WHOGuidelines.fromJson(Map<String, dynamic> json) =>
      _$WHOGuidelinesFromJson(json);

  Map<String, dynamic> toJson() => _$WHOGuidelinesToJson(this);
}

// DSM-5-TR Standards
@JsonSerializable()
class DSM5TRStandards {
  final String id;
  final String disorderName;
  final String code;
  final String category;
  final String description;
  final List<String> diagnosticCriteria;
  final List<String> symptoms;
  final List<String> associatedFeatures;
  final List<String> differentialDiagnosis;
  final Map<String, dynamic> treatmentGuidelines;
  final List<String> references;
  final Map<String, dynamic> metadata;

  DSM5TRStandards({
    required this.id,
    required this.disorderName,
    required this.code,
    required this.category,
    required this.description,
    required this.diagnosticCriteria,
    required this.symptoms,
    required this.associatedFeatures,
    required this.differentialDiagnosis,
    required this.treatmentGuidelines,
    required this.references,
    required this.metadata,
  });

  factory DSM5TRStandards.fromJson(Map<String, dynamic> json) =>
      _$DSM5TRStandardsFromJson(json);

  Map<String, dynamic> toJson() => _$DSM5TRStandardsToJson(this);
}

// ICD-11 Standards
@JsonSerializable()
class ICD11Standards {
  final String id;
  final String code;
  final String title;
  final String category;
  final String description;
  final List<String> inclusionTerms;
  final List<String> exclusionTerms;
  final List<String> symptoms;
  final List<String> diagnosticCriteria;
  final Map<String, dynamic> treatmentGuidelines;
  final List<String> references;
  final Map<String, dynamic> metadata;

  ICD11Standards({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.description,
    required this.inclusionTerms,
    required this.exclusionTerms,
    required this.symptoms,
    required this.diagnosticCriteria,
    required this.treatmentGuidelines,
    required this.references,
    required this.metadata,
  });

  factory ICD11Standards.fromJson(Map<String, dynamic> json) =>
      _$ICD11StandardsFromJson(json);

  Map<String, dynamic> toJson() => _$ICD11StandardsToJson(this);
}

// ICD-10-CM Standards (US)
@JsonSerializable()
class ICD10CMStandards {
  final String id;
  final String code;
  final String title;
  final String category;
  final String description;
  final List<String> inclusionTerms;
  final List<String> exclusionTerms;
  final List<String> symptoms;
  final List<String> diagnosticCriteria;
  final Map<String, dynamic> treatmentGuidelines;
  final List<String> references;
  final Map<String, dynamic> metadata;

  ICD10CMStandards({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.description,
    required this.inclusionTerms,
    required this.exclusionTerms,
    required this.symptoms,
    required this.diagnosticCriteria,
    required this.treatmentGuidelines,
    required this.references,
    required this.metadata,
  });

  factory ICD10CMStandards.fromJson(Map<String, dynamic> json) =>
      _$ICD10CMStandardsFromJson(json);

  Map<String, dynamic> toJson() => _$ICD10CMStandardsToJson(this);
}

// ICD-10-TR Standards (Türkiye)
@JsonSerializable()
class ICD10TRStandards {
  final String id;
  final String code;
  final String title;
  final String category;
  final String description;
  final List<String> inclusionTerms;
  final List<String> exclusionTerms;
  final List<String> symptoms;
  final List<String> diagnosticCriteria;
  final Map<String, dynamic> treatmentGuidelines;
  final List<String> references;
  final Map<String, dynamic> metadata;

  ICD10TRStandards({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.description,
    required this.inclusionTerms,
    required this.exclusionTerms,
    required this.symptoms,
    required this.diagnosticCriteria,
    required this.treatmentGuidelines,
    required this.references,
    required this.metadata,
  });

  factory ICD10TRStandards.fromJson(Map<String, dynamic> json) =>
      _$ICD10TRStandardsFromJson(json);

  Map<String, dynamic> toJson() => _$ICD10TRStandardsToJson(this);
}

// Evidence-Based Medicine Guidelines
@JsonSerializable()
class EvidenceBasedMedicineGuidelines {
  final String id;
  final String title;
  final String category;
  final String version;
  final DateTime publishedDate;
  final String evidenceLevel; // A, B, C, D
  final String recommendationStrength; // strong, moderate, weak
  final List<String> keyRecommendations;
  final List<String> supportingEvidence;
  final List<String> limitations;
  final Map<String, dynamic> implementationGuidance;
  final List<String> references;
  final Map<String, dynamic> metadata;

  EvidenceBasedMedicineGuidelines({
    required this.id,
    required this.title,
    required this.category,
    required this.version,
    required this.publishedDate,
    required this.evidenceLevel,
    required this.recommendationStrength,
    required this.keyRecommendations,
    required this.supportingEvidence,
    required this.limitations,
    required this.implementationGuidance,
    required this.references,
    required this.metadata,
  });

  factory EvidenceBasedMedicineGuidelines.fromJson(Map<String, dynamic> json) =>
      _$EvidenceBasedMedicineGuidelinesFromJson(json);

  Map<String, dynamic> toJson() => _$EvidenceBasedMedicineGuidelinesToJson(this);
}

// Clinical Practice Guidelines
@JsonSerializable()
class ClinicalPracticeGuidelines {
  final String id;
  final String title;
  final String organization;
  final String specialty;
  final String version;
  final DateTime publishedDate;
  final DateTime lastUpdated;
  final String status;
  final List<String> targetAudience;
  final List<String> keyRecommendations;
  final Map<String, dynamic> implementationSteps;
  final List<String> qualityIndicators;
  final List<String> references;
  final Map<String, dynamic> metadata;

  ClinicalPracticeGuidelines({
    required this.id,
    required this.title,
    required this.organization,
    required this.specialty,
    required this.version,
    required this.publishedDate,
    required this.lastUpdated,
    required this.status,
    required this.targetAudience,
    required this.keyRecommendations,
    required this.implementationSteps,
    required this.qualityIndicators,
    required this.references,
    required this.metadata,
  });

  factory ClinicalPracticeGuidelines.fromJson(Map<String, dynamic> json) =>
      _$ClinicalPracticeGuidelinesFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicalPracticeGuidelinesToJson(this);
}

// Country-Specific Protocols
@JsonSerializable()
class CountrySpecificProtocols {
  final String id;
  final String countryCode;
  final String countryName;
  final String protocolName;
  final String category;
  final String version;
  final DateTime publishedDate;
  final DateTime lastUpdated;
  final String status;
  final List<String> applicableRegions;
  final Map<String, dynamic> protocolDetails;
  final List<String> requirements;
  final List<String> references;
  final Map<String, dynamic> metadata;

  CountrySpecificProtocols({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.protocolName,
    required this.category,
    required this.version,
    required this.publishedDate,
    required this.lastUpdated,
    required this.status,
    required this.applicableRegions,
    required this.protocolDetails,
    required this.requirements,
    required this.references,
    required this.metadata,
  });

  factory CountrySpecificProtocols.fromJson(Map<String, dynamic> json) =>
      _$CountrySpecificProtocolsFromJson(json);

  Map<String, dynamic> toJson() => _$CountrySpecificProtocolsFromJson(this);
}

// Standard Compliance Tracking
@JsonSerializable()
class StandardComplianceTracking {
  final String id;
  final String standardId;
  final String standardName;
  final String organizationId;
  final String organizationName;
  final DateTime assessmentDate;
  final String complianceStatus; // compliant, non_compliant, partially_compliant
  final double complianceScore; // 0.0 - 1.0
  final List<String> compliantAreas;
  final List<String> nonCompliantAreas;
  final List<String> recommendations;
  final DateTime nextAssessmentDate;
  final Map<String, dynamic> metadata;

  StandardComplianceTracking({
    required this.id,
    required this.standardId,
    required this.standardName,
    required this.organizationId,
    required this.organizationName,
    required this.assessmentDate,
    required this.complianceStatus,
    required this.complianceScore,
    required this.compliantAreas,
    required this.nonCompliantAreas,
    required this.recommendations,
    required this.nextAssessmentDate,
    required this.metadata,
  });

  factory StandardComplianceTracking.fromJson(Map<String, dynamic> json) =>
      _$StandardComplianceTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$StandardComplianceTrackingToJson(this);
}

// Standard Version Control
@JsonSerializable()
class StandardVersionControl {
  final String id;
  final String standardId;
  final String standardName;
  final String version;
  final DateTime releaseDate;
  final DateTime effectiveDate;
  final DateTime deprecationDate;
  final String status; // active, deprecated, draft
  final List<String> changes;
  final List<String> breakingChanges;
  final List<String> migrationGuidance;
  final Map<String, dynamic> metadata;

  StandardVersionControl({
    required this.id,
    required this.standardId,
    required this.standardName,
    required this.version,
    required this.releaseDate,
    required this.effectiveDate,
    required this.deprecationDate,
    required this.status,
    required this.changes,
    required this.breakingChanges,
    required this.migrationGuidance,
    required this.metadata,
  });

  factory StandardVersionControl.fromJson(Map<String, dynamic> json) =>
      _$StandardVersionControlFromJson(json);

  Map<String, dynamic> toJson() => _$StandardVersionControlToJson(this);
}

// Standard Mapping
@JsonSerializable()
class StandardMapping {
  final String id;
  final String sourceStandardId;
  final String sourceStandardName;
  final String targetStandardId;
  final String targetStandardName;
  final String mappingType; // direct, equivalent, related
  final double confidenceScore; // 0.0 - 1.0
  final Map<String, String> codeMappings;
  final List<String> notes;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  StandardMapping({
    required this.id,
    required this.sourceStandardId,
    required this.sourceStandardName,
    required this.targetStandardId,
    required this.targetStandardName,
    required this.mappingType,
    required this.confidenceScore,
    required this.codeMappings,
    required this.notes,
    required this.lastUpdated,
    required this.metadata,
  });

  factory StandardMapping.fromJson(Map<String, dynamic> json) =>
      _$StandardMappingFromJson(json);

  Map<String, dynamic> toJson() => _$StandardMappingToJson(this);
}

// Standard Quality Metrics
@JsonSerializable()
class StandardQualityMetrics {
  final String id;
  final String standardId;
  final String standardName;
  final DateTime assessmentDate;
  final double completenessScore; // 0.0 - 1.0
  final double accuracyScore; // 0.0 - 1.0
  final double consistencyScore; // 0.0 - 1.0
  final double timelinessScore; // 0.0 - 1.0
  final double overallScore; // 0.0 - 1.0
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> improvementAreas;
  final Map<String, dynamic> metadata;

  StandardQualityMetrics({
    required this.id,
    required this.standardId,
    required this.standardName,
    required this.assessmentDate,
    required this.completenessScore,
    required this.accuracyScore,
    required this.consistencyScore,
    required this.timelinessScore,
    required this.overallScore,
    required this.strengths,
    required this.weaknesses,
    required this.improvementAreas,
    required this.metadata,
  });

  factory StandardQualityMetrics.fromJson(Map<String, dynamic> json) =>
      _$StandardQualityMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$StandardQualityMetricsToJson(this);
}
