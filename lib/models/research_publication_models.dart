import 'package:json_annotation/json_annotation.dart';

part 'research_publication_models.g.dart';

// ===== ARAŞTIRMA & BİLİMSEL YAYIN MODELLERİ =====

@JsonSerializable()
class ResearchProfile {
  final String id;
  final String clinicianId;
  final String institution;
  final List<String> researchInterests;
  final List<ResearchProject> projects;
  final List<Publication> publications;
  final List<ClinicalTrial> trials;
  final ResearchMetrics metrics;
  final List<String> collaborations;
  final Map<String, dynamic>? metadata;

  ResearchProfile({
    required this.id,
    required this.clinicianId,
    required this.institution,
    required this.researchInterests,
    required this.projects,
    required this.publications,
    required this.trials,
    required this.metrics,
    required this.collaborations,
    this.metadata,
  });

  factory ResearchProfile.fromJson(Map<String, dynamic> json) =>
      _$ResearchProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ResearchProfileToJson(this);
}

// ===== ANONİMİZE COHORT BUILDER =====

@JsonSerializable()
class CohortBuilder {
  final String id;
  final String name;
  final String description;
  final String researcherId;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final CohortStatus status;
  final List<CohortCriteria> criteria;
  final List<String> inclusionCriteria;
  final List<String> exclusionCriteria;
  final int targetSize;
  final int currentSize;
  final List<String> dataFields;
  final List<String> exportFormats;
  final CohortPrivacy privacySettings;
  final Map<String, dynamic>? metadata;

  CohortBuilder({
    required this.id,
    required this.name,
    required this.description,
    required this.researcherId,
    required this.createdDate,
    required this.lastUpdated,
    required this.status,
    required this.criteria,
    required this.inclusionCriteria,
    required this.exclusionCriteria,
    required this.targetSize,
    required this.currentSize,
    required this.dataFields,
    required this.exportFormats,
    required this.privacySettings,
    this.metadata,
  });

  factory CohortBuilder.fromJson(Map<String, dynamic> json) =>
      _$CohortBuilderFromJson(json);

  Map<String, dynamic> toJson() => _$CohortBuilderToJson(this);
}

enum CohortStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('archived')
  archived,
}

@JsonSerializable()
class CohortCriteria {
  final String id;
  final String field;
  final String operator;
  final dynamic value;
  final String? unit;
  final bool isRequired;

  CohortCriteria({
    required this.id,
    required this.field,
    required this.operator,
    required this.value,
    this.unit,
    required this.isRequired,
  });

  factory CohortCriteria.fromJson(Map<String, dynamic> json) =>
      _$CohortCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$CohortCriteriaToJson(this);
}

@JsonSerializable()
class CohortPrivacy {
  final bool anonymizeData;
  final bool aggregateResults;
  final List<String> restrictedFields;
  final String dataRetention;
  final List<String> accessControls;
  final String? irbApproval;

  CohortPrivacy({
    required this.anonymizeData,
    required this.aggregateResults,
    required this.restrictedFields,
    required this.dataRetention,
    required this.accessControls,
    this.irbApproval,
  });

  factory CohortPrivacy.fromJson(Map<String, dynamic> json) =>
      _$CohortPrivacyFromJson(json);

  Map<String, dynamic> toJson() => _$CohortPrivacyToJson(this);
}

@JsonSerializable()
class CohortExport {
  final String id;
  final String cohortId;
  final String researcherId;
  final DateTime exportDate;
  final String format;
  final String status;
  final String? downloadUrl;
  final int recordCount;
  final List<String> fields;
  final String? notes;

  CohortExport({
    required this.id,
    required this.cohortId,
    required this.researcherId,
    required this.exportDate,
    required this.format,
    required this.status,
    this.downloadUrl,
    required this.recordCount,
    required this.fields,
    this.notes,
  });

  factory CohortExport.fromJson(Map<String, dynamic> json) =>
      _$CohortExportFromJson(json);

  Map<String, dynamic> toJson() => _$CohortExportToJson(this);
}

// ===== OUTCOME META-ANALYTICS =====

@JsonSerializable()
class OutcomeMetaAnalytics {
  final String id;
  final String name;
  final String description;
  final String researcherId;
  final DateTime analysisDate;
  final List<String> outcomeMeasures;
  final List<String> treatmentModalities;
  final List<String> patientPopulations;
  final MetaAnalysisMethod method;
  final List<Study> studies;
  final MetaAnalysisResult result;
  final List<String> conclusions;
  final List<String> recommendations;
  final double confidence;

  OutcomeMetaAnalytics({
    required this.id,
    required this.name,
    required this.description,
    required this.researcherId,
    required this.analysisDate,
    required this.outcomeMeasures,
    required this.treatmentModalities,
    required this.patientPopulations,
    required this.method,
    required this.studies,
    required this.result,
    required this.conclusions,
    required this.recommendations,
    required this.confidence,
  });

  factory OutcomeMetaAnalytics.fromJson(Map<String, dynamic> json) =>
      _$OutcomeMetaAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$OutcomeMetaAnalyticsToJson(this);
}

enum MetaAnalysisMethod {
  @JsonValue('fixed_effects')
  fixedEffects,
  @JsonValue('random_effects')
  randomEffects,
  @JsonValue('bayesian')
  bayesian,
  @JsonValue('network')
  network,
}

@JsonSerializable()
class Study {
  final String id;
  final String title;
  final String authors;
  final int year;
  final String journal;
  final int sampleSize;
  final String design;
  final double quality;
  final List<Outcome> outcomes;
  final List<String> limitations;

  Study({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.journal,
    required this.sampleSize,
    required this.design,
    required this.quality,
    required this.outcomes,
    required this.limitations,
  });

  factory Study.fromJson(Map<String, dynamic> json) =>
      _$StudyFromJson(json);

  Map<String, dynamic> toJson() => _$StudyToJson(this);
}

@JsonSerializable()
class Outcome {
  final String id;
  final String measure;
  final String treatment;
  final double effectSize;
  final double standardError;
  final double pValue;
  final double confidenceIntervalLower;
  final double confidenceIntervalUpper;

  Outcome({
    required this.id,
    required this.measure,
    required this.treatment,
    required this.effectSize,
    required this.standardError,
    required this.pValue,
    required this.confidenceIntervalLower,
    required this.confidenceIntervalUpper,
  });

  factory Outcome.fromJson(Map<String, dynamic> json) =>
      _$OutcomeFromJson(json);

  Map<String, dynamic> toJson() => _$OutcomeToJson(this);
}

@JsonSerializable()
class MetaAnalysisResult {
  final String id;
  final double overallEffectSize;
  final double standardError;
  final double pValue;
  final double confidenceIntervalLower;
  final double confidenceIntervalUpper;
  final double heterogeneity;
  final double iSquared;
  final List<String> subgroupAnalyses;
  final List<String> sensitivityAnalyses;

  MetaAnalysisResult({
    required this.id,
    required this.overallEffectSize,
    required this.standardError,
    required this.pValue,
    required this.confidenceIntervalLower,
    required this.confidenceIntervalUpper,
    required this.heterogeneity,
    required this.iSquared,
    required this.subgroupAnalyses,
    required this.sensitivityAnalyses,
  });

  factory MetaAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$MetaAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$MetaAnalysisResultToJson(this);
}

// ===== PUBLICATION ASSISTANT =====

@JsonSerializable()
class PublicationAssistant {
  final String id;
  final String clinicianId;
  final String title;
  final String abstract;
  final PublicationType type;
  final List<String> keywords;
  final List<String> authors;
  final String journal;
  final PublicationStatus status;
  final List<PublicationSection> sections;
  final List<String> references;
  final List<String> figures;
  final List<String> tables;
  final String? doi;
  final DateTime? publicationDate;

  PublicationAssistant({
    required this.id,
    required this.clinicianId,
    required this.title,
    required this.abstract,
    required this.type,
    required this.keywords,
    required this.authors,
    required this.journal,
    required this.status,
    required this.sections,
    required this.references,
    required this.figures,
    required this.tables,
    this.doi,
    this.publicationDate,
  });

  factory PublicationAssistant.fromJson(Map<String, dynamic> json) =>
      _$PublicationAssistantFromJson(json);

  Map<String, dynamic> toJson() => _$PublicationAssistantToJson(this);
}

enum PublicationType {
  @JsonValue('research_article')
  researchArticle,
  @JsonValue('case_report')
  caseReport,
  @JsonValue('review_article')
  reviewArticle,
  @JsonValue('letter_to_editor')
  letterToEditor,
  @JsonValue('commentary')
  commentary,
}

enum PublicationStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('submitted')
  submitted,
  @JsonValue('under_review')
  underReview,
  @JsonValue('revision_requested')
  revisionRequested,
  @JsonValue('accepted')
  accepted,
  @JsonValue('published')
  published,
  @JsonValue('rejected')
  rejected,
}

@JsonSerializable()
class PublicationSection {
  final String id;
  final String title;
  final String content;
  final int order;
  final List<String> subsections;
  final String? notes;

  PublicationSection({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    required this.subsections,
    this.notes,
  });

  factory PublicationSection.fromJson(Map<String, dynamic> json) =>
      _$PublicationSectionFromJson(json);

  Map<String, dynamic> toJson() => _$PublicationSectionToJson(this);
}

@JsonSerializable()
class PublicationTemplate {
  final String id;
  final String name;
  final PublicationType type;
  final String journal;
  final List<PublicationSection> sections;
  final List<String> requiredFields;
  final Map<String, String> guidelines;
  final bool isActive;

  PublicationTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.journal,
    required this.sections,
    required this.requiredFields,
    required this.guidelines,
    required this.isActive,
  });

  factory PublicationTemplate.fromJson(Map<String, dynamic> json) =>
      _$PublicationTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$PublicationTemplateToJson(this);
}

// ===== CLINICAL TRIAL MATCHMAKING =====

@JsonSerializable()
class ClinicalTrial {
  final String id;
  final String title;
  final String description;
  final String sponsor;
  final String principalInvestigator;
  final List<String> investigators;
  final String condition;
  final List<String> interventions;
  final TrialPhase phase;
  final TrialStatus status;
  final DateTime startDate;
  final DateTime? completionDate;
  final int enrollmentTarget;
  final int currentEnrollment;
  final List<String> eligibilityCriteria;
  final List<String> exclusionCriteria;
  final List<String> locations;
  final String? contactInfo;
  final String? website;
  final String? nctId;

  ClinicalTrial({
    required this.id,
    required this.title,
    required this.description,
    required this.sponsor,
    required this.principalInvestigator,
    required this.investigators,
    required this.condition,
    required this.interventions,
    required this.phase,
    required this.status,
    required this.startDate,
    this.completionDate,
    required this.enrollmentTarget,
    required this.currentEnrollment,
    required this.eligibilityCriteria,
    required this.exclusionCriteria,
    required this.locations,
    this.contactInfo,
    this.website,
    this.nctId,
  });

  factory ClinicalTrial.fromJson(Map<String, dynamic> json) =>
      _$ClinicalTrialFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicalTrialToJson(this);
}

enum TrialPhase {
  @JsonValue('phase_1')
  phase1,
  @JsonValue('phase_2')
  phase2,
  @JsonValue('phase_3')
  phase3,
  @JsonValue('phase_4')
  phase4,
  @JsonValue('pilot')
  pilot,
  @JsonValue('feasibility')
  feasibility,
}

enum TrialStatus {
  @JsonValue('recruiting')
  recruiting,
  @JsonValue('not_yet_recruiting')
  notYetRecruiting,
  @JsonValue('active_not_recruiting')
  activeNotRecruiting,
  @JsonValue('enrolling_by_invitation')
  enrollingByInvitation,
  @JsonValue('suspended')
  suspended,
  @JsonValue('terminated')
  terminated,
  @JsonValue('completed')
  completed,
  @JsonValue('withdrawn')
  withdrawn,
}

@JsonSerializable()
class TrialMatchmaking {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime matchDate;
  final List<TrialMatch> matches;
  final List<String> criteria;
  final double matchScore;
  final List<String> recommendations;
  final bool isInterested;
  final String? notes;

  TrialMatchmaking({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.matchDate,
    required this.matches,
    required this.criteria,
    required this.matchScore,
    required this.recommendations,
    required this.isInterested,
    this.notes,
  });

  factory TrialMatchmaking.fromJson(Map<String, dynamic> json) =>
      _$TrialMatchmakingFromJson(json);

  Map<String, dynamic> toJson() => _$TrialMatchmakingToJson(this);
}

@JsonSerializable()
class TrialMatch {
  final String id;
  final String trialId;
  final String trialTitle;
  final double matchScore;
  final List<String> matchingCriteria;
  final List<String> nonMatchingCriteria;
  final double distance;
  final String location;
  final String contactInfo;
  final List<String> nextSteps;

  TrialMatch({
    required this.id,
    required this.trialId,
    required this.trialTitle,
    required this.matchScore,
    required this.matchingCriteria,
    required this.nonMatchingCriteria,
    required this.distance,
    required this.location,
    required this.contactInfo,
    required this.nextSteps,
  });

  factory TrialMatch.fromJson(Map<String, dynamic> json) =>
      _$TrialMatchFromJson(json);

  Map<String, dynamic> toJson() => _$TrialMatchToJson(this);
}

// ===== PUBLICATION =====

@JsonSerializable()
class Publication {
  final String id;
  final String title;
  final String abstract;
  final PublicationType type;
  final List<String> authors;
  final String journal;
  final int year;
  final String? doi;
  final String? url;
  final List<String> keywords;
  final int citations;
  final PublicationStatus status;
  final DateTime? publicationDate;
  final List<String> references;
  final List<String> figures;
  final List<String> tables;

  Publication({
    required this.id,
    required this.title,
    required this.abstract,
    required this.type,
    required this.authors,
    required this.journal,
    required this.year,
    this.doi,
    this.url,
    required this.keywords,
    required this.citations,
    required this.status,
    this.publicationDate,
    required this.references,
    required this.figures,
    required this.tables,
  });

  factory Publication.fromJson(Map<String, dynamic> json) =>
      _$PublicationFromJson(json);

  Map<String, dynamic> toJson() => _$PublicationToJson(this);
}

// ===== RESEARCH PROJECT =====

@JsonSerializable()
class ResearchProject {
  final String id;
  final String title;
  final String description;
  final String principalInvestigator;
  final List<String> coInvestigators;
  final List<String> collaborators;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String funding;
  final double budget;
  final List<String> objectives;
  final List<String> deliverables;
  final List<String> publications;
  final Map<String, dynamic>? metadata;

  ResearchProject({
    required this.id,
    required this.title,
    required this.description,
    required this.principalInvestigator,
    required this.coInvestigators,
    required this.collaborators,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.funding,
    required this.budget,
    required this.objectives,
    required this.deliverables,
    required this.publications,
    this.metadata,
  });

  factory ResearchProject.fromJson(Map<String, dynamic> json) =>
      _$ResearchProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ResearchProjectToJson(this);
}

enum ProjectStatus {
  @JsonValue('proposed')
  proposed,
  @JsonValue('approved')
  approved,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('on_hold')
  onHold,
  @JsonValue('cancelled')
  cancelled,
}

// ===== RESEARCH METRICS =====

@JsonSerializable()
class ResearchMetrics {
  final String id;
  final String clinicianId;
  final int totalPublications;
  final int totalCitations;
  final double hIndex;
  final double i10Index;
  final List<String> topPublications;
  final List<String> researchAreas;
  final Map<String, int> publicationByYear;
  final Map<String, int> citationByYear;
  final List<String> collaborations;
  final double impactFactor;

  ResearchMetrics({
    required this.id,
    required this.clinicianId,
    required this.totalPublications,
    required this.totalCitations,
    required this.hIndex,
    required this.i10Index,
    required this.topPublications,
    required this.researchAreas,
    required this.publicationByYear,
    required this.citationByYear,
    required this.collaborations,
    required this.impactFactor,
  });

  factory ResearchMetrics.fromJson(Map<String, dynamic> json) =>
      _$ResearchMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ResearchMetricsToJson(this);
}

// ===== RESEARCH & PUBLICATION ÖZETİ =====

@JsonSerializable()
class ResearchPublicationSummary {
  final String id;
  final String clinicianId;
  final DateTime summaryDate;
  final int activeProjects;
  final int totalPublications;
  final int totalCitations;
  final double hIndex;
  final List<CohortBuilder> activeCohorts;
  final List<OutcomeMetaAnalytics> recentAnalytics;
  final List<PublicationAssistant> draftPublications;
  final List<ClinicalTrial> recommendedTrials;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  ResearchPublicationSummary({
    required this.id,
    required this.clinicianId,
    required this.summaryDate,
    required this.activeProjects,
    required this.totalPublications,
    required this.totalCitations,
    required this.hIndex,
    required this.activeCohorts,
    required this.recentAnalytics,
    required this.draftPublications,
    required this.recommendedTrials,
    required this.recommendations,
    this.metadata,
  });

  factory ResearchPublicationSummary.fromJson(Map<String, dynamic> json) =>
      _$ResearchPublicationSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ResearchPublicationSummaryToJson(this);
}
