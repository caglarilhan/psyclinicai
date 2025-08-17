// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_medical_standards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalMedicalStandards _$GlobalMedicalStandardsFromJson(
  Map<String, dynamic> json,
) => GlobalMedicalStandards(
  id: json['id'] as String,
  name: json['name'] as String,
  organization: json['organization'] as String,
  version: json['version'] as String,
  publishedDate: DateTime.parse(json['publishedDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  applicableRegions: (json['applicableRegions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  applicableSpecialties: (json['applicableSpecialties'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  standards: json['standards'] as Map<String, dynamic>,
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$GlobalMedicalStandardsToJson(
  GlobalMedicalStandards instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'organization': instance.organization,
  'version': instance.version,
  'publishedDate': instance.publishedDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'applicableRegions': instance.applicableRegions,
  'applicableSpecialties': instance.applicableSpecialties,
  'standards': instance.standards,
  'references': instance.references,
  'metadata': instance.metadata,
};

WHOGuidelines _$WHOGuidelinesFromJson(Map<String, dynamic> json) =>
    WHOGuidelines(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      version: json['version'] as String,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      targetAudience: (json['targetAudience'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keyRecommendations: (json['keyRecommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      evidenceLevels: (json['evidenceLevels'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      implementationGuidance:
          json['implementationGuidance'] as Map<String, dynamic>,
      references: (json['references'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$WHOGuidelinesToJson(WHOGuidelines instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'version': instance.version,
      'publishedDate': instance.publishedDate.toIso8601String(),
      'targetAudience': instance.targetAudience,
      'keyRecommendations': instance.keyRecommendations,
      'evidenceLevels': instance.evidenceLevels,
      'implementationGuidance': instance.implementationGuidance,
      'references': instance.references,
      'metadata': instance.metadata,
    };

DSM5TRStandards _$DSM5TRStandardsFromJson(Map<String, dynamic> json) =>
    DSM5TRStandards(
      id: json['id'] as String,
      disorderName: json['disorderName'] as String,
      code: json['code'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      diagnosticCriteria: (json['diagnosticCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      associatedFeatures: (json['associatedFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      differentialDiagnosis: (json['differentialDiagnosis'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatmentGuidelines: json['treatmentGuidelines'] as Map<String, dynamic>,
      references: (json['references'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DSM5TRStandardsToJson(DSM5TRStandards instance) =>
    <String, dynamic>{
      'id': instance.id,
      'disorderName': instance.disorderName,
      'code': instance.code,
      'category': instance.category,
      'description': instance.description,
      'diagnosticCriteria': instance.diagnosticCriteria,
      'symptoms': instance.symptoms,
      'associatedFeatures': instance.associatedFeatures,
      'differentialDiagnosis': instance.differentialDiagnosis,
      'treatmentGuidelines': instance.treatmentGuidelines,
      'references': instance.references,
      'metadata': instance.metadata,
    };

ICD11Standards _$ICD11StandardsFromJson(Map<String, dynamic> json) =>
    ICD11Standards(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      inclusionTerms: (json['inclusionTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exclusionTerms: (json['exclusionTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      diagnosticCriteria: (json['diagnosticCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatmentGuidelines: json['treatmentGuidelines'] as Map<String, dynamic>,
      references: (json['references'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ICD11StandardsToJson(ICD11Standards instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'inclusionTerms': instance.inclusionTerms,
      'exclusionTerms': instance.exclusionTerms,
      'symptoms': instance.symptoms,
      'diagnosticCriteria': instance.diagnosticCriteria,
      'treatmentGuidelines': instance.treatmentGuidelines,
      'references': instance.references,
      'metadata': instance.metadata,
    };

ICD10CMStandards _$ICD10CMStandardsFromJson(Map<String, dynamic> json) =>
    ICD10CMStandards(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      inclusionTerms: (json['inclusionTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exclusionTerms: (json['exclusionTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      diagnosticCriteria: (json['diagnosticCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatmentGuidelines: json['treatmentGuidelines'] as Map<String, dynamic>,
      references: (json['references'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ICD10CMStandardsToJson(ICD10CMStandards instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'inclusionTerms': instance.inclusionTerms,
      'exclusionTerms': instance.exclusionTerms,
      'symptoms': instance.symptoms,
      'diagnosticCriteria': instance.diagnosticCriteria,
      'treatmentGuidelines': instance.treatmentGuidelines,
      'references': instance.references,
      'metadata': instance.metadata,
    };

ICD10TRStandards _$ICD10TRStandardsFromJson(Map<String, dynamic> json) =>
    ICD10TRStandards(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      inclusionTerms: (json['inclusionTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exclusionTerms: (json['exclusionTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      diagnosticCriteria: (json['diagnosticCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatmentGuidelines: json['treatmentGuidelines'] as Map<String, dynamic>,
      references: (json['references'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ICD10TRStandardsToJson(ICD10TRStandards instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'inclusionTerms': instance.inclusionTerms,
      'exclusionTerms': instance.exclusionTerms,
      'symptoms': instance.symptoms,
      'diagnosticCriteria': instance.diagnosticCriteria,
      'treatmentGuidelines': instance.treatmentGuidelines,
      'references': instance.references,
      'metadata': instance.metadata,
    };

EvidenceBasedMedicineGuidelines _$EvidenceBasedMedicineGuidelinesFromJson(
  Map<String, dynamic> json,
) => EvidenceBasedMedicineGuidelines(
  id: json['id'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  version: json['version'] as String,
  publishedDate: DateTime.parse(json['publishedDate'] as String),
  evidenceLevel: json['evidenceLevel'] as String,
  recommendationStrength: json['recommendationStrength'] as String,
  keyRecommendations: (json['keyRecommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  supportingEvidence: (json['supportingEvidence'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  limitations: (json['limitations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  implementationGuidance:
      json['implementationGuidance'] as Map<String, dynamic>,
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$EvidenceBasedMedicineGuidelinesToJson(
  EvidenceBasedMedicineGuidelines instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'version': instance.version,
  'publishedDate': instance.publishedDate.toIso8601String(),
  'evidenceLevel': instance.evidenceLevel,
  'recommendationStrength': instance.recommendationStrength,
  'keyRecommendations': instance.keyRecommendations,
  'supportingEvidence': instance.supportingEvidence,
  'limitations': instance.limitations,
  'implementationGuidance': instance.implementationGuidance,
  'references': instance.references,
  'metadata': instance.metadata,
};

ClinicalPracticeGuidelines _$ClinicalPracticeGuidelinesFromJson(
  Map<String, dynamic> json,
) => ClinicalPracticeGuidelines(
  id: json['id'] as String,
  title: json['title'] as String,
  organization: json['organization'] as String,
  specialty: json['specialty'] as String,
  version: json['version'] as String,
  publishedDate: DateTime.parse(json['publishedDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  targetAudience: (json['targetAudience'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  keyRecommendations: (json['keyRecommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  implementationSteps: json['implementationSteps'] as Map<String, dynamic>,
  qualityIndicators: (json['qualityIndicators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ClinicalPracticeGuidelinesToJson(
  ClinicalPracticeGuidelines instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'organization': instance.organization,
  'specialty': instance.specialty,
  'version': instance.version,
  'publishedDate': instance.publishedDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'targetAudience': instance.targetAudience,
  'keyRecommendations': instance.keyRecommendations,
  'implementationSteps': instance.implementationSteps,
  'qualityIndicators': instance.qualityIndicators,
  'references': instance.references,
  'metadata': instance.metadata,
};

CountrySpecificProtocols _$CountrySpecificProtocolsFromJson(
  Map<String, dynamic> json,
) => CountrySpecificProtocols(
  id: json['id'] as String,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  protocolName: json['protocolName'] as String,
  category: json['category'] as String,
  version: json['version'] as String,
  publishedDate: DateTime.parse(json['publishedDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  applicableRegions: (json['applicableRegions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protocolDetails: json['protocolDetails'] as Map<String, dynamic>,
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CountrySpecificProtocolsToJson(
  CountrySpecificProtocols instance,
) => <String, dynamic>{
  'id': instance.id,
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'protocolName': instance.protocolName,
  'category': instance.category,
  'version': instance.version,
  'publishedDate': instance.publishedDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'applicableRegions': instance.applicableRegions,
  'protocolDetails': instance.protocolDetails,
  'requirements': instance.requirements,
  'references': instance.references,
  'metadata': instance.metadata,
};

StandardComplianceTracking _$StandardComplianceTrackingFromJson(
  Map<String, dynamic> json,
) => StandardComplianceTracking(
  id: json['id'] as String,
  standardId: json['standardId'] as String,
  standardName: json['standardName'] as String,
  organizationId: json['organizationId'] as String,
  organizationName: json['organizationName'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  complianceStatus: json['complianceStatus'] as String,
  complianceScore: (json['complianceScore'] as num).toDouble(),
  compliantAreas: (json['compliantAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  nonCompliantAreas: (json['nonCompliantAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  nextAssessmentDate: DateTime.parse(json['nextAssessmentDate'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$StandardComplianceTrackingToJson(
  StandardComplianceTracking instance,
) => <String, dynamic>{
  'id': instance.id,
  'standardId': instance.standardId,
  'standardName': instance.standardName,
  'organizationId': instance.organizationId,
  'organizationName': instance.organizationName,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'complianceStatus': instance.complianceStatus,
  'complianceScore': instance.complianceScore,
  'compliantAreas': instance.compliantAreas,
  'nonCompliantAreas': instance.nonCompliantAreas,
  'recommendations': instance.recommendations,
  'nextAssessmentDate': instance.nextAssessmentDate.toIso8601String(),
  'metadata': instance.metadata,
};

StandardVersionControl _$StandardVersionControlFromJson(
  Map<String, dynamic> json,
) => StandardVersionControl(
  id: json['id'] as String,
  standardId: json['standardId'] as String,
  standardName: json['standardName'] as String,
  version: json['version'] as String,
  releaseDate: DateTime.parse(json['releaseDate'] as String),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  deprecationDate: DateTime.parse(json['deprecationDate'] as String),
  status: json['status'] as String,
  changes: (json['changes'] as List<dynamic>).map((e) => e as String).toList(),
  breakingChanges: (json['breakingChanges'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  migrationGuidance: (json['migrationGuidance'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$StandardVersionControlToJson(
  StandardVersionControl instance,
) => <String, dynamic>{
  'id': instance.id,
  'standardId': instance.standardId,
  'standardName': instance.standardName,
  'version': instance.version,
  'releaseDate': instance.releaseDate.toIso8601String(),
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'deprecationDate': instance.deprecationDate.toIso8601String(),
  'status': instance.status,
  'changes': instance.changes,
  'breakingChanges': instance.breakingChanges,
  'migrationGuidance': instance.migrationGuidance,
  'metadata': instance.metadata,
};

StandardMapping _$StandardMappingFromJson(Map<String, dynamic> json) =>
    StandardMapping(
      id: json['id'] as String,
      sourceStandardId: json['sourceStandardId'] as String,
      sourceStandardName: json['sourceStandardName'] as String,
      targetStandardId: json['targetStandardId'] as String,
      targetStandardName: json['targetStandardName'] as String,
      mappingType: json['mappingType'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      codeMappings: Map<String, String>.from(json['codeMappings'] as Map),
      notes: (json['notes'] as List<dynamic>).map((e) => e as String).toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$StandardMappingToJson(StandardMapping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceStandardId': instance.sourceStandardId,
      'sourceStandardName': instance.sourceStandardName,
      'targetStandardId': instance.targetStandardId,
      'targetStandardName': instance.targetStandardName,
      'mappingType': instance.mappingType,
      'confidenceScore': instance.confidenceScore,
      'codeMappings': instance.codeMappings,
      'notes': instance.notes,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'metadata': instance.metadata,
    };

StandardQualityMetrics _$StandardQualityMetricsFromJson(
  Map<String, dynamic> json,
) => StandardQualityMetrics(
  id: json['id'] as String,
  standardId: json['standardId'] as String,
  standardName: json['standardName'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  completenessScore: (json['completenessScore'] as num).toDouble(),
  accuracyScore: (json['accuracyScore'] as num).toDouble(),
  consistencyScore: (json['consistencyScore'] as num).toDouble(),
  timelinessScore: (json['timelinessScore'] as num).toDouble(),
  overallScore: (json['overallScore'] as num).toDouble(),
  strengths: (json['strengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  weaknesses: (json['weaknesses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  improvementAreas: (json['improvementAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$StandardQualityMetricsToJson(
  StandardQualityMetrics instance,
) => <String, dynamic>{
  'id': instance.id,
  'standardId': instance.standardId,
  'standardName': instance.standardName,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'completenessScore': instance.completenessScore,
  'accuracyScore': instance.accuracyScore,
  'consistencyScore': instance.consistencyScore,
  'timelinessScore': instance.timelinessScore,
  'overallScore': instance.overallScore,
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
  'improvementAreas': instance.improvementAreas,
  'metadata': instance.metadata,
};
