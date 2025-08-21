import 'package:json_annotation/json_annotation.dart';

part 'supervision_education_models.g.dart';

// ===== SÜPERVİZYON & EĞİTİM MODELLERİ =====

@JsonSerializable()
class SupervisionEducationProfile {
  final String id;
  final String clinicianId;
  final String supervisorId;
  final DateTime startDate;
  final DateTime lastUpdated;
  final SupervisionStatus status;
  final List<SupervisionSession> sessions;
  final List<PeerReview> peerReviews;
  final List<CMECredit> cmeCredits;
  final List<CaseStudy> caseStudies;
  final SupervisedAIMode supervisedAIMode;
  final Map<String, dynamic>? metadata;

  SupervisionEducationProfile({
    required this.id,
    required this.clinicianId,
    required this.supervisorId,
    required this.startDate,
    required this.lastUpdated,
    required this.status,
    required this.sessions,
    required this.peerReviews,
    required this.cmeCredits,
    required this.caseStudies,
    required this.supervisedAIMode,
    this.metadata,
  });

  factory SupervisionEducationProfile.fromJson(Map<String, dynamic> json) =>
      _$SupervisionEducationProfileFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionEducationProfileToJson(this);
}

enum SupervisionStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('escalated')
  escalated,
  @JsonValue('terminated')
  terminated,
}

// ===== PEER-REVIEW PANEL =====

@JsonSerializable()
class PeerReview {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final String revieweeName;
  final DateTime reviewDate;
  final ReviewType type;
  final String caseId;
  final String caseSummary;
  final List<ReviewCriteria> criteria;
  final double overallScore;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> recommendations;
  final ReviewStatus status;
  final String? supervisorNotes;
  final DateTime? supervisorReviewDate;

  PeerReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.revieweeName,
    required this.reviewDate,
    required this.type,
    required this.caseId,
    required this.caseSummary,
    required this.criteria,
    required this.overallScore,
    required this.strengths,
    required this.areasForImprovement,
    required this.recommendations,
    required this.status,
    this.supervisorNotes,
    this.supervisorReviewDate,
  });

  factory PeerReview.fromJson(Map<String, dynamic> json) =>
      _$PeerReviewFromJson(json);

  Map<String, dynamic> toJson() => _$PeerReviewToJson(this);
}

enum ReviewType {
  @JsonValue('case_review')
  caseReview,
  @JsonValue('session_review')
  sessionReview,
  @JsonValue('diagnosis_review')
  diagnosisReview,
  @JsonValue('treatment_review')
  treatmentReview,
  @JsonValue('documentation_review')
  documentationReview,
}

enum ReviewStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('escalated')
  escalated,
  @JsonValue('disputed')
  disputed,
}

@JsonSerializable()
class ReviewCriteria {
  final String id;
  final String name;
  final String description;
  final double weight;
  final double score;
  final String? comments;

  ReviewCriteria({
    required this.id,
    required this.name,
    required this.description,
    required this.weight,
    required this.score,
    this.comments,
  });

  factory ReviewCriteria.fromJson(Map<String, dynamic> json) =>
      _$ReviewCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewCriteriaToJson(this);
}

// ===== CME/CPD OTOMASYONU =====

@JsonSerializable()
class CMECredit {
  final String id;
  final String clinicianId;
  final String activityType;
  final String activityName;
  final DateTime activityDate;
  final Duration duration;
  final double credits;
  final String category;
  final String? description;
  final List<String> learningObjectives;
  final List<String> competencies;
  final CMEStatus status;
  final String? certificateUrl;
  final DateTime? completionDate;

  CMECredit({
    required this.id,
    required this.clinicianId,
    required this.activityType,
    required this.activityName,
    required this.activityDate,
    required this.duration,
    required this.credits,
    required this.category,
    this.description,
    required this.learningObjectives,
    required this.competencies,
    required this.status,
    this.certificateUrl,
    this.completionDate,
  });

  factory CMECredit.fromJson(Map<String, dynamic> json) =>
      _$CMECreditFromJson(json);

  Map<String, dynamic> toJson() => _$CMECreditToJson(this);
}

enum CMEStatus {
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('verified')
  verified,
  @JsonValue('expired')
  expired,
}

@JsonSerializable()
class CMETracking {
  final String id;
  final String clinicianId;
  final String reportingPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCredits;
  final double requiredCredits;
  final Map<String, double> categoryCredits;
  final List<CMECredit> activities;
  final bool isCompliant;
  final List<String> requirements;

  CMETracking({
    required this.id,
    required this.clinicianId,
    required this.reportingPeriod,
    required this.startDate,
    required this.endDate,
    required this.totalCredits,
    required this.requiredCredits,
    required this.categoryCredits,
    required this.activities,
    required this.isCompliant,
    required this.requirements,
  });

  factory CMETracking.fromJson(Map<String, dynamic> json) =>
      _$CMETrackingFromJson(json);

  Map<String, dynamic> toJson() => _$CMETrackingToJson(this);
}

// ===== CASE-BASED LEARNING HUB =====

@JsonSerializable()
class CaseStudy {
  final String id;
  final String title;
  final String description;
  final String diagnosis;
  final List<String> symptoms;
  final List<String> comorbidities;
  final List<String> medications;
  final List<String> treatments;
  final String outcome;
  final List<String> learningPoints;
  final List<String> competencies;
  final CaseDifficulty difficulty;
  final List<String> tags;
  final String authorId;
  final String authorName;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final bool isPublic;
  final List<String> reviews;
  final double averageRating;

  CaseStudy({
    required this.id,
    required this.title,
    required this.description,
    required this.diagnosis,
    required this.symptoms,
    required this.comorbidities,
    required this.medications,
    required this.treatments,
    required this.outcome,
    required this.learningPoints,
    required this.competencies,
    required this.difficulty,
    required this.tags,
    required this.authorId,
    required this.authorName,
    required this.createdDate,
    required this.lastUpdated,
    required this.isPublic,
    required this.reviews,
    required this.averageRating,
  });

  factory CaseStudy.fromJson(Map<String, dynamic> json) =>
      _$CaseStudyFromJson(json);

  Map<String, dynamic> toJson() => _$CaseStudyToJson(this);
}

enum CaseDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('expert')
  expert,
}

@JsonSerializable()
class CaseSimulation {
  final String id;
  final String caseStudyId;
  final String clinicianId;
  final DateTime simulationDate;
  final SimulationStatus status;
  final List<SimulationStep> steps;
  final List<String> decisions;
  final List<String> outcomes;
  final double score;
  final List<String> feedback;
  final Duration duration;

  CaseSimulation({
    required this.id,
    required this.caseStudyId,
    required this.clinicianId,
    required this.simulationDate,
    required this.status,
    required this.steps,
    required this.decisions,
    required this.outcomes,
    required this.score,
    required this.feedback,
    required this.duration,
  });

  factory CaseSimulation.fromJson(Map<String, dynamic> json) =>
      _$CaseSimulationFromJson(json);

  Map<String, dynamic> toJson() => _$CaseSimulationToJson(this);
}

enum SimulationStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('paused')
  paused,
}

@JsonSerializable()
class SimulationStep {
  final String id;
  final int stepNumber;
  final String description;
  final List<String> options;
  final String? selectedOption;
  final bool isCorrect;
  final String? explanation;
  final List<String> consequences;

  SimulationStep({
    required this.id,
    required this.stepNumber,
    required this.description,
    required this.options,
    this.selectedOption,
    required this.isCorrect,
    this.explanation,
    required this.consequences,
  });

  factory SimulationStep.fromJson(Map<String, dynamic> json) =>
      _$SimulationStepFromJson(json);

  Map<String, dynamic> toJson() => _$SimulationStepToJson(this);
}

// ===== SÜPERVİZE EDİLEN AI MODU =====

@JsonSerializable()
class SupervisedAIMode {
  final String id;
  final String clinicianId;
  final String supervisorId;
  final DateTime startDate;
  final DateTime lastUpdated;
  final AIModeStatus status;
  final List<AIRecommendation> recommendations;
  final List<AIError> errors;
  final List<AIFeedback> feedback;
  final double accuracy;
  final List<String> learningAreas;
  final Map<String, dynamic>? metadata;

  SupervisedAIMode({
    required this.id,
    required this.clinicianId,
    required this.supervisorId,
    required this.startDate,
    required this.lastUpdated,
    required this.status,
    required this.recommendations,
    required this.errors,
    required this.feedback,
    required this.accuracy,
    required this.learningAreas,
    this.metadata,
  });

  factory SupervisedAIMode.fromJson(Map<String, dynamic> json) =>
      _$SupervisedAIModeFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisedAIModeToJson(this);
}

enum AIModeStatus {
  @JsonValue('active')
  active,
  @JsonValue('monitoring')
  monitoring,
  @JsonValue('restricted')
  restricted,
  @JsonValue('disabled')
  disabled,
}

@JsonSerializable()
class AIRecommendation {
  final String id;
  final String caseId;
  final String recommendation;
  final double confidence;
  final List<String> reasoning;
  final List<String> alternatives;
  final bool wasFollowed;
  final String? clinicianNotes;
  final String? supervisorNotes;
  final DateTime timestamp;

  AIRecommendation({
    required this.id,
    required this.caseId,
    required this.recommendation,
    required this.confidence,
    required this.reasoning,
    required this.alternatives,
    required this.wasFollowed,
    this.clinicianNotes,
    this.supervisorNotes,
    required this.timestamp,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AIRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$AIRecommendationToJson(this);
}

@JsonSerializable()
class AIError {
  final String id;
  final String caseId;
  final String errorType;
  final String description;
  final double severity;
  final List<String> contributingFactors;
  final List<String> preventionStrategies;
  final bool wasCorrected;
  final String? correctionNotes;
  final DateTime timestamp;

  AIError({
    required this.id,
    required this.caseId,
    required this.errorType,
    required this.description,
    required this.severity,
    required this.contributingFactors,
    required this.preventionStrategies,
    required this.wasCorrected,
    this.correctionNotes,
    required this.timestamp,
  });

  factory AIError.fromJson(Map<String, dynamic> json) =>
      _$AIErrorFromJson(json);

  Map<String, dynamic> toJson() => _$AIErrorToJson(this);
}

@JsonSerializable()
class AIFeedback {
  final String id;
  final String clinicianId;
  final String supervisorId;
  final DateTime feedbackDate;
  final String feedbackType;
  final String description;
  final List<String> suggestions;
  final double priority;
  final bool isAcknowledged;
  final DateTime? acknowledgedDate;
  final String? response;

  AIFeedback({
    required this.id,
    required this.clinicianId,
    required this.supervisorId,
    required this.feedbackDate,
    required this.feedbackType,
    required this.description,
    required this.suggestions,
    required this.priority,
    required this.isAcknowledged,
    this.acknowledgedDate,
    this.response,
  });

  factory AIFeedback.fromJson(Map<String, dynamic> json) =>
      _$AIFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$AIFeedbackToJson(this);
}

// ===== SÜPERVİZYON SEANSLARI =====

@JsonSerializable()
class SupervisionSession {
  final String id;
  final String clinicianId;
  final String supervisorId;
  final DateTime sessionDate;
  final Duration duration;
  final SessionType type;
  final String agenda;
  final List<String> topics;
  final List<String> actionItems;
  final List<String> recommendations;
  final SessionStatus status;
  final String? notes;
  final String? followUpNotes;

  SupervisionSession({
    required this.id,
    required this.clinicianId,
    required this.supervisorId,
    required this.sessionDate,
    required this.duration,
    required this.type,
    required this.agenda,
    required this.topics,
    required this.actionItems,
    required this.recommendations,
    required this.status,
    this.notes,
    this.followUpNotes,
  });

  factory SupervisionSession.fromJson(Map<String, dynamic> json) =>
      _$SupervisionSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionSessionToJson(this);
}

enum SessionType {
  @JsonValue('individual')
  individual,
  @JsonValue('group')
  group,
  @JsonValue('case_review')
  caseReview,
  @JsonValue('emergency')
  emergency,
  @JsonValue('assessment')
  assessment,
}

enum SessionStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('rescheduled')
  rescheduled,
}

// ===== EĞİTİM MATERYALLERİ =====

@JsonSerializable()
class EducationalMaterial {
  final String id;
  final String title;
  final String description;
  final MaterialType type;
  final String category;
  final List<String> tags;
  final String content;
  final String? url;
  final List<String> learningObjectives;
  final List<String> competencies;
  final Duration estimatedDuration;
  final String authorId;
  final String authorName;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final bool isActive;
  final List<String> reviews;
  final double averageRating;

  EducationalMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.tags,
    required this.content,
    this.url,
    required this.learningObjectives,
    required this.competencies,
    required this.estimatedDuration,
    required this.authorId,
    required this.authorName,
    required this.createdDate,
    required this.lastUpdated,
    required this.isActive,
    required this.reviews,
    required this.averageRating,
  });

  factory EducationalMaterial.fromJson(Map<String, dynamic> json) =>
      _$EducationalMaterialFromJson(json);

  Map<String, dynamic> toJson() => _$EducationalMaterialToJson(this);
}

enum MaterialType {
  @JsonValue('article')
  article,
  @JsonValue('video')
  video,
  @JsonValue('presentation')
  presentation,
  @JsonValue('workshop')
  workshop,
  @JsonValue('webinar')
  webinar,
  @JsonValue('case_study')
  caseStudy,
  @JsonValue('assessment')
  assessment,
}

// ===== SÜPERVİZYON & EĞİTİM ÖZETİ =====

@JsonSerializable()
class SupervisionEducationSummary {
  final String id;
  final String clinicianId;
  final DateTime summaryDate;
  final SupervisionStatus supervisionStatus;
  final double totalCMECredits;
  final double requiredCMECredits;
  final bool cmeCompliant;
  final List<PeerReview> recentPeerReviews;
  final List<CaseStudy> completedCaseStudies;
  final SupervisedAIMode supervisedAIMode;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  SupervisionEducationSummary({
    required this.id,
    required this.clinicianId,
    required this.summaryDate,
    required this.supervisionStatus,
    required this.totalCMECredits,
    required this.requiredCMECredits,
    required this.cmeCompliant,
    required this.recentPeerReviews,
    required this.completedCaseStudies,
    required this.supervisedAIMode,
    required this.recommendations,
    this.metadata,
  });

  factory SupervisionEducationSummary.fromJson(Map<String, dynamic> json) =>
      _$SupervisionEducationSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionEducationSummaryToJson(this);
}
