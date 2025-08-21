// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_publication_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResearchProfile _$ResearchProfileFromJson(Map<String, dynamic> json) =>
    ResearchProfile(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      institution: json['institution'] as String,
      researchInterests: (json['researchInterests'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      projects: (json['projects'] as List<dynamic>)
          .map((e) => ResearchProject.fromJson(e as Map<String, dynamic>))
          .toList(),
      publications: (json['publications'] as List<dynamic>)
          .map((e) => Publication.fromJson(e as Map<String, dynamic>))
          .toList(),
      trials: (json['trials'] as List<dynamic>)
          .map((e) => ClinicalTrial.fromJson(e as Map<String, dynamic>))
          .toList(),
      metrics: ResearchMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>,
      ),
      collaborations: (json['collaborations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResearchProfileToJson(ResearchProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'institution': instance.institution,
      'researchInterests': instance.researchInterests,
      'projects': instance.projects,
      'publications': instance.publications,
      'trials': instance.trials,
      'metrics': instance.metrics,
      'collaborations': instance.collaborations,
      'metadata': instance.metadata,
    };

CohortBuilder _$CohortBuilderFromJson(Map<String, dynamic> json) =>
    CohortBuilder(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      researcherId: json['researcherId'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      status: $enumDecode(_$CohortStatusEnumMap, json['status']),
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => CohortCriteria.fromJson(e as Map<String, dynamic>))
          .toList(),
      inclusionCriteria: (json['inclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exclusionCriteria: (json['exclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      targetSize: (json['targetSize'] as num).toInt(),
      currentSize: (json['currentSize'] as num).toInt(),
      dataFields: (json['dataFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exportFormats: (json['exportFormats'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      privacySettings: CohortPrivacy.fromJson(
        json['privacySettings'] as Map<String, dynamic>,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CohortBuilderToJson(CohortBuilder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'researcherId': instance.researcherId,
      'createdDate': instance.createdDate.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'status': _$CohortStatusEnumMap[instance.status]!,
      'criteria': instance.criteria,
      'inclusionCriteria': instance.inclusionCriteria,
      'exclusionCriteria': instance.exclusionCriteria,
      'targetSize': instance.targetSize,
      'currentSize': instance.currentSize,
      'dataFields': instance.dataFields,
      'exportFormats': instance.exportFormats,
      'privacySettings': instance.privacySettings,
      'metadata': instance.metadata,
    };

const _$CohortStatusEnumMap = {
  CohortStatus.draft: 'draft',
  CohortStatus.active: 'active',
  CohortStatus.completed: 'completed',
  CohortStatus.archived: 'archived',
};

CohortCriteria _$CohortCriteriaFromJson(Map<String, dynamic> json) =>
    CohortCriteria(
      id: json['id'] as String,
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
      unit: json['unit'] as String?,
      isRequired: json['isRequired'] as bool,
    );

Map<String, dynamic> _$CohortCriteriaToJson(CohortCriteria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'field': instance.field,
      'operator': instance.operator,
      'value': instance.value,
      'unit': instance.unit,
      'isRequired': instance.isRequired,
    };

CohortPrivacy _$CohortPrivacyFromJson(Map<String, dynamic> json) =>
    CohortPrivacy(
      anonymizeData: json['anonymizeData'] as bool,
      aggregateResults: json['aggregateResults'] as bool,
      restrictedFields: (json['restrictedFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dataRetention: json['dataRetention'] as String,
      accessControls: (json['accessControls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      irbApproval: json['irbApproval'] as String?,
    );

Map<String, dynamic> _$CohortPrivacyToJson(CohortPrivacy instance) =>
    <String, dynamic>{
      'anonymizeData': instance.anonymizeData,
      'aggregateResults': instance.aggregateResults,
      'restrictedFields': instance.restrictedFields,
      'dataRetention': instance.dataRetention,
      'accessControls': instance.accessControls,
      'irbApproval': instance.irbApproval,
    };

CohortExport _$CohortExportFromJson(Map<String, dynamic> json) => CohortExport(
  id: json['id'] as String,
  cohortId: json['cohortId'] as String,
  researcherId: json['researcherId'] as String,
  exportDate: DateTime.parse(json['exportDate'] as String),
  format: json['format'] as String,
  status: json['status'] as String,
  downloadUrl: json['downloadUrl'] as String?,
  recordCount: (json['recordCount'] as num).toInt(),
  fields: (json['fields'] as List<dynamic>).map((e) => e as String).toList(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CohortExportToJson(CohortExport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cohortId': instance.cohortId,
      'researcherId': instance.researcherId,
      'exportDate': instance.exportDate.toIso8601String(),
      'format': instance.format,
      'status': instance.status,
      'downloadUrl': instance.downloadUrl,
      'recordCount': instance.recordCount,
      'fields': instance.fields,
      'notes': instance.notes,
    };

OutcomeMetaAnalytics _$OutcomeMetaAnalyticsFromJson(
  Map<String, dynamic> json,
) => OutcomeMetaAnalytics(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  researcherId: json['researcherId'] as String,
  analysisDate: DateTime.parse(json['analysisDate'] as String),
  outcomeMeasures: (json['outcomeMeasures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  treatmentModalities: (json['treatmentModalities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  patientPopulations: (json['patientPopulations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  method: $enumDecode(_$MetaAnalysisMethodEnumMap, json['method']),
  studies: (json['studies'] as List<dynamic>)
      .map((e) => Study.fromJson(e as Map<String, dynamic>))
      .toList(),
  result: MetaAnalysisResult.fromJson(json['result'] as Map<String, dynamic>),
  conclusions: (json['conclusions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$OutcomeMetaAnalyticsToJson(
  OutcomeMetaAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'researcherId': instance.researcherId,
  'analysisDate': instance.analysisDate.toIso8601String(),
  'outcomeMeasures': instance.outcomeMeasures,
  'treatmentModalities': instance.treatmentModalities,
  'patientPopulations': instance.patientPopulations,
  'method': _$MetaAnalysisMethodEnumMap[instance.method]!,
  'studies': instance.studies,
  'result': instance.result,
  'conclusions': instance.conclusions,
  'recommendations': instance.recommendations,
  'confidence': instance.confidence,
};

const _$MetaAnalysisMethodEnumMap = {
  MetaAnalysisMethod.fixedEffects: 'fixed_effects',
  MetaAnalysisMethod.randomEffects: 'random_effects',
  MetaAnalysisMethod.bayesian: 'bayesian',
  MetaAnalysisMethod.network: 'network',
};

Study _$StudyFromJson(Map<String, dynamic> json) => Study(
  id: json['id'] as String,
  title: json['title'] as String,
  authors: json['authors'] as String,
  year: (json['year'] as num).toInt(),
  journal: json['journal'] as String,
  sampleSize: (json['sampleSize'] as num).toInt(),
  design: json['design'] as String,
  quality: (json['quality'] as num).toDouble(),
  outcomes: (json['outcomes'] as List<dynamic>)
      .map((e) => Outcome.fromJson(e as Map<String, dynamic>))
      .toList(),
  limitations: (json['limitations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$StudyToJson(Study instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'authors': instance.authors,
  'year': instance.year,
  'journal': instance.journal,
  'sampleSize': instance.sampleSize,
  'design': instance.design,
  'quality': instance.quality,
  'outcomes': instance.outcomes,
  'limitations': instance.limitations,
};

Outcome _$OutcomeFromJson(Map<String, dynamic> json) => Outcome(
  id: json['id'] as String,
  measure: json['measure'] as String,
  treatment: json['treatment'] as String,
  effectSize: (json['effectSize'] as num).toDouble(),
  standardError: (json['standardError'] as num).toDouble(),
  pValue: (json['pValue'] as num).toDouble(),
  confidenceIntervalLower: (json['confidenceIntervalLower'] as num).toDouble(),
  confidenceIntervalUpper: (json['confidenceIntervalUpper'] as num).toDouble(),
);

Map<String, dynamic> _$OutcomeToJson(Outcome instance) => <String, dynamic>{
  'id': instance.id,
  'measure': instance.measure,
  'treatment': instance.treatment,
  'effectSize': instance.effectSize,
  'standardError': instance.standardError,
  'pValue': instance.pValue,
  'confidenceIntervalLower': instance.confidenceIntervalLower,
  'confidenceIntervalUpper': instance.confidenceIntervalUpper,
};

MetaAnalysisResult _$MetaAnalysisResultFromJson(
  Map<String, dynamic> json,
) => MetaAnalysisResult(
  id: json['id'] as String,
  overallEffectSize: (json['overallEffectSize'] as num).toDouble(),
  standardError: (json['standardError'] as num).toDouble(),
  pValue: (json['pValue'] as num).toDouble(),
  confidenceIntervalLower: (json['confidenceIntervalLower'] as num).toDouble(),
  confidenceIntervalUpper: (json['confidenceIntervalUpper'] as num).toDouble(),
  heterogeneity: (json['heterogeneity'] as num).toDouble(),
  iSquared: (json['iSquared'] as num).toDouble(),
  subgroupAnalyses: (json['subgroupAnalyses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sensitivityAnalyses: (json['sensitivityAnalyses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MetaAnalysisResultToJson(MetaAnalysisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'overallEffectSize': instance.overallEffectSize,
      'standardError': instance.standardError,
      'pValue': instance.pValue,
      'confidenceIntervalLower': instance.confidenceIntervalLower,
      'confidenceIntervalUpper': instance.confidenceIntervalUpper,
      'heterogeneity': instance.heterogeneity,
      'iSquared': instance.iSquared,
      'subgroupAnalyses': instance.subgroupAnalyses,
      'sensitivityAnalyses': instance.sensitivityAnalyses,
    };

PublicationAssistant _$PublicationAssistantFromJson(
  Map<String, dynamic> json,
) => PublicationAssistant(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  title: json['title'] as String,
  abstract: json['abstract'] as String,
  type: $enumDecode(_$PublicationTypeEnumMap, json['type']),
  keywords: (json['keywords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  authors: (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
  journal: json['journal'] as String,
  status: $enumDecode(_$PublicationStatusEnumMap, json['status']),
  sections: (json['sections'] as List<dynamic>)
      .map((e) => PublicationSection.fromJson(e as Map<String, dynamic>))
      .toList(),
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  figures: (json['figures'] as List<dynamic>).map((e) => e as String).toList(),
  tables: (json['tables'] as List<dynamic>).map((e) => e as String).toList(),
  doi: json['doi'] as String?,
  publicationDate: json['publicationDate'] == null
      ? null
      : DateTime.parse(json['publicationDate'] as String),
);

Map<String, dynamic> _$PublicationAssistantToJson(
  PublicationAssistant instance,
) => <String, dynamic>{
  'id': instance.id,
  'clinicianId': instance.clinicianId,
  'title': instance.title,
  'abstract': instance.abstract,
  'type': _$PublicationTypeEnumMap[instance.type]!,
  'keywords': instance.keywords,
  'authors': instance.authors,
  'journal': instance.journal,
  'status': _$PublicationStatusEnumMap[instance.status]!,
  'sections': instance.sections,
  'references': instance.references,
  'figures': instance.figures,
  'tables': instance.tables,
  'doi': instance.doi,
  'publicationDate': instance.publicationDate?.toIso8601String(),
};

const _$PublicationTypeEnumMap = {
  PublicationType.researchArticle: 'research_article',
  PublicationType.caseReport: 'case_report',
  PublicationType.reviewArticle: 'review_article',
  PublicationType.letterToEditor: 'letter_to_editor',
  PublicationType.commentary: 'commentary',
};

const _$PublicationStatusEnumMap = {
  PublicationStatus.draft: 'draft',
  PublicationStatus.submitted: 'submitted',
  PublicationStatus.underReview: 'under_review',
  PublicationStatus.revisionRequested: 'revision_requested',
  PublicationStatus.accepted: 'accepted',
  PublicationStatus.published: 'published',
  PublicationStatus.rejected: 'rejected',
};

PublicationSection _$PublicationSectionFromJson(Map<String, dynamic> json) =>
    PublicationSection(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      order: (json['order'] as num).toInt(),
      subsections: (json['subsections'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PublicationSectionToJson(PublicationSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'order': instance.order,
      'subsections': instance.subsections,
      'notes': instance.notes,
    };

PublicationTemplate _$PublicationTemplateFromJson(Map<String, dynamic> json) =>
    PublicationTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$PublicationTypeEnumMap, json['type']),
      journal: json['journal'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => PublicationSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredFields: (json['requiredFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      guidelines: Map<String, String>.from(json['guidelines'] as Map),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$PublicationTemplateToJson(
  PublicationTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$PublicationTypeEnumMap[instance.type]!,
  'journal': instance.journal,
  'sections': instance.sections,
  'requiredFields': instance.requiredFields,
  'guidelines': instance.guidelines,
  'isActive': instance.isActive,
};

ClinicalTrial _$ClinicalTrialFromJson(Map<String, dynamic> json) =>
    ClinicalTrial(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      sponsor: json['sponsor'] as String,
      principalInvestigator: json['principalInvestigator'] as String,
      investigators: (json['investigators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      condition: json['condition'] as String,
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      phase: $enumDecode(_$TrialPhaseEnumMap, json['phase']),
      status: $enumDecode(_$TrialStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['startDate'] as String),
      completionDate: json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String),
      enrollmentTarget: (json['enrollmentTarget'] as num).toInt(),
      currentEnrollment: (json['currentEnrollment'] as num).toInt(),
      eligibilityCriteria: (json['eligibilityCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exclusionCriteria: (json['exclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      locations: (json['locations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contactInfo: json['contactInfo'] as String?,
      website: json['website'] as String?,
      nctId: json['nctId'] as String?,
    );

Map<String, dynamic> _$ClinicalTrialToJson(ClinicalTrial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'sponsor': instance.sponsor,
      'principalInvestigator': instance.principalInvestigator,
      'investigators': instance.investigators,
      'condition': instance.condition,
      'interventions': instance.interventions,
      'phase': _$TrialPhaseEnumMap[instance.phase]!,
      'status': _$TrialStatusEnumMap[instance.status]!,
      'startDate': instance.startDate.toIso8601String(),
      'completionDate': instance.completionDate?.toIso8601String(),
      'enrollmentTarget': instance.enrollmentTarget,
      'currentEnrollment': instance.currentEnrollment,
      'eligibilityCriteria': instance.eligibilityCriteria,
      'exclusionCriteria': instance.exclusionCriteria,
      'locations': instance.locations,
      'contactInfo': instance.contactInfo,
      'website': instance.website,
      'nctId': instance.nctId,
    };

const _$TrialPhaseEnumMap = {
  TrialPhase.phase1: 'phase_1',
  TrialPhase.phase2: 'phase_2',
  TrialPhase.phase3: 'phase_3',
  TrialPhase.phase4: 'phase_4',
  TrialPhase.pilot: 'pilot',
  TrialPhase.feasibility: 'feasibility',
};

const _$TrialStatusEnumMap = {
  TrialStatus.recruiting: 'recruiting',
  TrialStatus.notYetRecruiting: 'not_yet_recruiting',
  TrialStatus.activeNotRecruiting: 'active_not_recruiting',
  TrialStatus.enrollingByInvitation: 'enrolling_by_invitation',
  TrialStatus.suspended: 'suspended',
  TrialStatus.terminated: 'terminated',
  TrialStatus.completed: 'completed',
  TrialStatus.withdrawn: 'withdrawn',
};

TrialMatchmaking _$TrialMatchmakingFromJson(Map<String, dynamic> json) =>
    TrialMatchmaking(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      matchDate: DateTime.parse(json['matchDate'] as String),
      matches: (json['matches'] as List<dynamic>)
          .map((e) => TrialMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      matchScore: (json['matchScore'] as num).toDouble(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isInterested: json['isInterested'] as bool,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TrialMatchmakingToJson(TrialMatchmaking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'matchDate': instance.matchDate.toIso8601String(),
      'matches': instance.matches,
      'criteria': instance.criteria,
      'matchScore': instance.matchScore,
      'recommendations': instance.recommendations,
      'isInterested': instance.isInterested,
      'notes': instance.notes,
    };

TrialMatch _$TrialMatchFromJson(Map<String, dynamic> json) => TrialMatch(
  id: json['id'] as String,
  trialId: json['trialId'] as String,
  trialTitle: json['trialTitle'] as String,
  matchScore: (json['matchScore'] as num).toDouble(),
  matchingCriteria: (json['matchingCriteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  nonMatchingCriteria: (json['nonMatchingCriteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  distance: (json['distance'] as num).toDouble(),
  location: json['location'] as String,
  contactInfo: json['contactInfo'] as String,
  nextSteps: (json['nextSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TrialMatchToJson(TrialMatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trialId': instance.trialId,
      'trialTitle': instance.trialTitle,
      'matchScore': instance.matchScore,
      'matchingCriteria': instance.matchingCriteria,
      'nonMatchingCriteria': instance.nonMatchingCriteria,
      'distance': instance.distance,
      'location': instance.location,
      'contactInfo': instance.contactInfo,
      'nextSteps': instance.nextSteps,
    };

Publication _$PublicationFromJson(Map<String, dynamic> json) => Publication(
  id: json['id'] as String,
  title: json['title'] as String,
  abstract: json['abstract'] as String,
  type: $enumDecode(_$PublicationTypeEnumMap, json['type']),
  authors: (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
  journal: json['journal'] as String,
  year: (json['year'] as num).toInt(),
  doi: json['doi'] as String?,
  url: json['url'] as String?,
  keywords: (json['keywords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  citations: (json['citations'] as num).toInt(),
  status: $enumDecode(_$PublicationStatusEnumMap, json['status']),
  publicationDate: json['publicationDate'] == null
      ? null
      : DateTime.parse(json['publicationDate'] as String),
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  figures: (json['figures'] as List<dynamic>).map((e) => e as String).toList(),
  tables: (json['tables'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$PublicationToJson(Publication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'abstract': instance.abstract,
      'type': _$PublicationTypeEnumMap[instance.type]!,
      'authors': instance.authors,
      'journal': instance.journal,
      'year': instance.year,
      'doi': instance.doi,
      'url': instance.url,
      'keywords': instance.keywords,
      'citations': instance.citations,
      'status': _$PublicationStatusEnumMap[instance.status]!,
      'publicationDate': instance.publicationDate?.toIso8601String(),
      'references': instance.references,
      'figures': instance.figures,
      'tables': instance.tables,
    };

ResearchProject _$ResearchProjectFromJson(Map<String, dynamic> json) =>
    ResearchProject(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      principalInvestigator: json['principalInvestigator'] as String,
      coInvestigators: (json['coInvestigators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      collaborators: (json['collaborators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      funding: json['funding'] as String,
      budget: (json['budget'] as num).toDouble(),
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deliverables: (json['deliverables'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      publications: (json['publications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResearchProjectToJson(ResearchProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'principalInvestigator': instance.principalInvestigator,
      'coInvestigators': instance.coInvestigators,
      'collaborators': instance.collaborators,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'funding': instance.funding,
      'budget': instance.budget,
      'objectives': instance.objectives,
      'deliverables': instance.deliverables,
      'publications': instance.publications,
      'metadata': instance.metadata,
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.proposed: 'proposed',
  ProjectStatus.approved: 'approved',
  ProjectStatus.active: 'active',
  ProjectStatus.completed: 'completed',
  ProjectStatus.onHold: 'on_hold',
  ProjectStatus.cancelled: 'cancelled',
};

ResearchMetrics _$ResearchMetricsFromJson(Map<String, dynamic> json) =>
    ResearchMetrics(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      totalPublications: (json['totalPublications'] as num).toInt(),
      totalCitations: (json['totalCitations'] as num).toInt(),
      hIndex: (json['hIndex'] as num).toDouble(),
      i10Index: (json['i10Index'] as num).toDouble(),
      topPublications: (json['topPublications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      researchAreas: (json['researchAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      publicationByYear: Map<String, int>.from(
        json['publicationByYear'] as Map,
      ),
      citationByYear: Map<String, int>.from(json['citationByYear'] as Map),
      collaborations: (json['collaborations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      impactFactor: (json['impactFactor'] as num).toDouble(),
    );

Map<String, dynamic> _$ResearchMetricsToJson(ResearchMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'totalPublications': instance.totalPublications,
      'totalCitations': instance.totalCitations,
      'hIndex': instance.hIndex,
      'i10Index': instance.i10Index,
      'topPublications': instance.topPublications,
      'researchAreas': instance.researchAreas,
      'publicationByYear': instance.publicationByYear,
      'citationByYear': instance.citationByYear,
      'collaborations': instance.collaborations,
      'impactFactor': instance.impactFactor,
    };

ResearchPublicationSummary _$ResearchPublicationSummaryFromJson(
  Map<String, dynamic> json,
) => ResearchPublicationSummary(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  summaryDate: DateTime.parse(json['summaryDate'] as String),
  activeProjects: (json['activeProjects'] as num).toInt(),
  totalPublications: (json['totalPublications'] as num).toInt(),
  totalCitations: (json['totalCitations'] as num).toInt(),
  hIndex: (json['hIndex'] as num).toDouble(),
  activeCohorts: (json['activeCohorts'] as List<dynamic>)
      .map((e) => CohortBuilder.fromJson(e as Map<String, dynamic>))
      .toList(),
  recentAnalytics: (json['recentAnalytics'] as List<dynamic>)
      .map((e) => OutcomeMetaAnalytics.fromJson(e as Map<String, dynamic>))
      .toList(),
  draftPublications: (json['draftPublications'] as List<dynamic>)
      .map((e) => PublicationAssistant.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendedTrials: (json['recommendedTrials'] as List<dynamic>)
      .map((e) => ClinicalTrial.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ResearchPublicationSummaryToJson(
  ResearchPublicationSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'clinicianId': instance.clinicianId,
  'summaryDate': instance.summaryDate.toIso8601String(),
  'activeProjects': instance.activeProjects,
  'totalPublications': instance.totalPublications,
  'totalCitations': instance.totalCitations,
  'hIndex': instance.hIndex,
  'activeCohorts': instance.activeCohorts,
  'recentAnalytics': instance.recentAnalytics,
  'draftPublications': instance.draftPublications,
  'recommendedTrials': instance.recommendedTrials,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
