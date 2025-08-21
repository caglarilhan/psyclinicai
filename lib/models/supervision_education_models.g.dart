// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supervision_education_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupervisionEducationProfile _$SupervisionEducationProfileFromJson(
  Map<String, dynamic> json,
) => SupervisionEducationProfile(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  supervisorId: json['supervisorId'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: $enumDecode(_$SupervisionStatusEnumMap, json['status']),
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => SupervisionSession.fromJson(e as Map<String, dynamic>))
      .toList(),
  peerReviews: (json['peerReviews'] as List<dynamic>)
      .map((e) => PeerReview.fromJson(e as Map<String, dynamic>))
      .toList(),
  cmeCredits: (json['cmeCredits'] as List<dynamic>)
      .map((e) => CMECredit.fromJson(e as Map<String, dynamic>))
      .toList(),
  caseStudies: (json['caseStudies'] as List<dynamic>)
      .map((e) => CaseStudy.fromJson(e as Map<String, dynamic>))
      .toList(),
  supervisedAIMode: SupervisedAIMode.fromJson(
    json['supervisedAIMode'] as Map<String, dynamic>,
  ),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SupervisionEducationProfileToJson(
  SupervisionEducationProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'clinicianId': instance.clinicianId,
  'supervisorId': instance.supervisorId,
  'startDate': instance.startDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': _$SupervisionStatusEnumMap[instance.status]!,
  'sessions': instance.sessions,
  'peerReviews': instance.peerReviews,
  'cmeCredits': instance.cmeCredits,
  'caseStudies': instance.caseStudies,
  'supervisedAIMode': instance.supervisedAIMode,
  'metadata': instance.metadata,
};

const _$SupervisionStatusEnumMap = {
  SupervisionStatus.active: 'active',
  SupervisionStatus.paused: 'paused',
  SupervisionStatus.completed: 'completed',
  SupervisionStatus.escalated: 'escalated',
  SupervisionStatus.terminated: 'terminated',
};

PeerReview _$PeerReviewFromJson(Map<String, dynamic> json) => PeerReview(
  id: json['id'] as String,
  reviewerId: json['reviewerId'] as String,
  reviewerName: json['reviewerName'] as String,
  revieweeId: json['revieweeId'] as String,
  revieweeName: json['revieweeName'] as String,
  reviewDate: DateTime.parse(json['reviewDate'] as String),
  type: $enumDecode(_$ReviewTypeEnumMap, json['type']),
  caseId: json['caseId'] as String,
  caseSummary: json['caseSummary'] as String,
  criteria: (json['criteria'] as List<dynamic>)
      .map((e) => ReviewCriteria.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallScore: (json['overallScore'] as num).toDouble(),
  strengths: (json['strengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$ReviewStatusEnumMap, json['status']),
  supervisorNotes: json['supervisorNotes'] as String?,
  supervisorReviewDate: json['supervisorReviewDate'] == null
      ? null
      : DateTime.parse(json['supervisorReviewDate'] as String),
);

Map<String, dynamic> _$PeerReviewToJson(PeerReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'revieweeId': instance.revieweeId,
      'revieweeName': instance.revieweeName,
      'reviewDate': instance.reviewDate.toIso8601String(),
      'type': _$ReviewTypeEnumMap[instance.type]!,
      'caseId': instance.caseId,
      'caseSummary': instance.caseSummary,
      'criteria': instance.criteria,
      'overallScore': instance.overallScore,
      'strengths': instance.strengths,
      'areasForImprovement': instance.areasForImprovement,
      'recommendations': instance.recommendations,
      'status': _$ReviewStatusEnumMap[instance.status]!,
      'supervisorNotes': instance.supervisorNotes,
      'supervisorReviewDate': instance.supervisorReviewDate?.toIso8601String(),
    };

const _$ReviewTypeEnumMap = {
  ReviewType.caseReview: 'case_review',
  ReviewType.sessionReview: 'session_review',
  ReviewType.diagnosisReview: 'diagnosis_review',
  ReviewType.treatmentReview: 'treatment_review',
  ReviewType.documentationReview: 'documentation_review',
};

const _$ReviewStatusEnumMap = {
  ReviewStatus.pending: 'pending',
  ReviewStatus.inProgress: 'in_progress',
  ReviewStatus.completed: 'completed',
  ReviewStatus.escalated: 'escalated',
  ReviewStatus.disputed: 'disputed',
};

ReviewCriteria _$ReviewCriteriaFromJson(Map<String, dynamic> json) =>
    ReviewCriteria(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      weight: (json['weight'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      comments: json['comments'] as String?,
    );

Map<String, dynamic> _$ReviewCriteriaToJson(ReviewCriteria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'weight': instance.weight,
      'score': instance.score,
      'comments': instance.comments,
    };

CMECredit _$CMECreditFromJson(Map<String, dynamic> json) => CMECredit(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  activityType: json['activityType'] as String,
  activityName: json['activityName'] as String,
  activityDate: DateTime.parse(json['activityDate'] as String),
  duration: Duration(microseconds: (json['duration'] as num).toInt()),
  credits: (json['credits'] as num).toDouble(),
  category: json['category'] as String,
  description: json['description'] as String?,
  learningObjectives: (json['learningObjectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  competencies: (json['competencies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$CMEStatusEnumMap, json['status']),
  certificateUrl: json['certificateUrl'] as String?,
  completionDate: json['completionDate'] == null
      ? null
      : DateTime.parse(json['completionDate'] as String),
);

Map<String, dynamic> _$CMECreditToJson(CMECredit instance) => <String, dynamic>{
  'id': instance.id,
  'clinicianId': instance.clinicianId,
  'activityType': instance.activityType,
  'activityName': instance.activityName,
  'activityDate': instance.activityDate.toIso8601String(),
  'duration': instance.duration.inMicroseconds,
  'credits': instance.credits,
  'category': instance.category,
  'description': instance.description,
  'learningObjectives': instance.learningObjectives,
  'competencies': instance.competencies,
  'status': _$CMEStatusEnumMap[instance.status]!,
  'certificateUrl': instance.certificateUrl,
  'completionDate': instance.completionDate?.toIso8601String(),
};

const _$CMEStatusEnumMap = {
  CMEStatus.inProgress: 'in_progress',
  CMEStatus.completed: 'completed',
  CMEStatus.verified: 'verified',
  CMEStatus.expired: 'expired',
};

CMETracking _$CMETrackingFromJson(Map<String, dynamic> json) => CMETracking(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  reportingPeriod: json['reportingPeriod'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  totalCredits: (json['totalCredits'] as num).toDouble(),
  requiredCredits: (json['requiredCredits'] as num).toDouble(),
  categoryCredits: (json['categoryCredits'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  activities: (json['activities'] as List<dynamic>)
      .map((e) => CMECredit.fromJson(e as Map<String, dynamic>))
      .toList(),
  isCompliant: json['isCompliant'] as bool,
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CMETrackingToJson(CMETracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'reportingPeriod': instance.reportingPeriod,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalCredits': instance.totalCredits,
      'requiredCredits': instance.requiredCredits,
      'categoryCredits': instance.categoryCredits,
      'activities': instance.activities,
      'isCompliant': instance.isCompliant,
      'requirements': instance.requirements,
    };

CaseStudy _$CaseStudyFromJson(Map<String, dynamic> json) => CaseStudy(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  diagnosis: json['diagnosis'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  comorbidities: (json['comorbidities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  treatments: (json['treatments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  outcome: json['outcome'] as String,
  learningPoints: (json['learningPoints'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  competencies: (json['competencies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  difficulty: $enumDecode(_$CaseDifficultyEnumMap, json['difficulty']),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  createdDate: DateTime.parse(json['createdDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  isPublic: json['isPublic'] as bool,
  reviews: (json['reviews'] as List<dynamic>).map((e) => e as String).toList(),
  averageRating: (json['averageRating'] as num).toDouble(),
);

Map<String, dynamic> _$CaseStudyToJson(CaseStudy instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'diagnosis': instance.diagnosis,
  'symptoms': instance.symptoms,
  'comorbidities': instance.comorbidities,
  'medications': instance.medications,
  'treatments': instance.treatments,
  'outcome': instance.outcome,
  'learningPoints': instance.learningPoints,
  'competencies': instance.competencies,
  'difficulty': _$CaseDifficultyEnumMap[instance.difficulty]!,
  'tags': instance.tags,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'createdDate': instance.createdDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'isPublic': instance.isPublic,
  'reviews': instance.reviews,
  'averageRating': instance.averageRating,
};

const _$CaseDifficultyEnumMap = {
  CaseDifficulty.beginner: 'beginner',
  CaseDifficulty.intermediate: 'intermediate',
  CaseDifficulty.advanced: 'advanced',
  CaseDifficulty.expert: 'expert',
};

CaseSimulation _$CaseSimulationFromJson(Map<String, dynamic> json) =>
    CaseSimulation(
      id: json['id'] as String,
      caseStudyId: json['caseStudyId'] as String,
      clinicianId: json['clinicianId'] as String,
      simulationDate: DateTime.parse(json['simulationDate'] as String),
      status: $enumDecode(_$SimulationStatusEnumMap, json['status']),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => SimulationStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      decisions: (json['decisions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      outcomes: (json['outcomes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      score: (json['score'] as num).toDouble(),
      feedback: (json['feedback'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$CaseSimulationToJson(CaseSimulation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseStudyId': instance.caseStudyId,
      'clinicianId': instance.clinicianId,
      'simulationDate': instance.simulationDate.toIso8601String(),
      'status': _$SimulationStatusEnumMap[instance.status]!,
      'steps': instance.steps,
      'decisions': instance.decisions,
      'outcomes': instance.outcomes,
      'score': instance.score,
      'feedback': instance.feedback,
      'duration': instance.duration.inMicroseconds,
    };

const _$SimulationStatusEnumMap = {
  SimulationStatus.notStarted: 'not_started',
  SimulationStatus.inProgress: 'in_progress',
  SimulationStatus.completed: 'completed',
  SimulationStatus.paused: 'paused',
};

SimulationStep _$SimulationStepFromJson(Map<String, dynamic> json) =>
    SimulationStep(
      id: json['id'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      description: json['description'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      selectedOption: json['selectedOption'] as String?,
      isCorrect: json['isCorrect'] as bool,
      explanation: json['explanation'] as String?,
      consequences: (json['consequences'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SimulationStepToJson(SimulationStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepNumber': instance.stepNumber,
      'description': instance.description,
      'options': instance.options,
      'selectedOption': instance.selectedOption,
      'isCorrect': instance.isCorrect,
      'explanation': instance.explanation,
      'consequences': instance.consequences,
    };

SupervisedAIMode _$SupervisedAIModeFromJson(Map<String, dynamic> json) =>
    SupervisedAIMode(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      supervisorId: json['supervisorId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      status: $enumDecode(_$AIModeStatusEnumMap, json['status']),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => AIRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => AIError.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedback: (json['feedback'] as List<dynamic>)
          .map((e) => AIFeedback.fromJson(e as Map<String, dynamic>))
          .toList(),
      accuracy: (json['accuracy'] as num).toDouble(),
      learningAreas: (json['learningAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SupervisedAIModeToJson(SupervisedAIMode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'supervisorId': instance.supervisorId,
      'startDate': instance.startDate.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'status': _$AIModeStatusEnumMap[instance.status]!,
      'recommendations': instance.recommendations,
      'errors': instance.errors,
      'feedback': instance.feedback,
      'accuracy': instance.accuracy,
      'learningAreas': instance.learningAreas,
      'metadata': instance.metadata,
    };

const _$AIModeStatusEnumMap = {
  AIModeStatus.active: 'active',
  AIModeStatus.monitoring: 'monitoring',
  AIModeStatus.restricted: 'restricted',
  AIModeStatus.disabled: 'disabled',
};

AIRecommendation _$AIRecommendationFromJson(Map<String, dynamic> json) =>
    AIRecommendation(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      recommendation: json['recommendation'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: (json['reasoning'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      wasFollowed: json['wasFollowed'] as bool,
      clinicianNotes: json['clinicianNotes'] as String?,
      supervisorNotes: json['supervisorNotes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$AIRecommendationToJson(AIRecommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'recommendation': instance.recommendation,
      'confidence': instance.confidence,
      'reasoning': instance.reasoning,
      'alternatives': instance.alternatives,
      'wasFollowed': instance.wasFollowed,
      'clinicianNotes': instance.clinicianNotes,
      'supervisorNotes': instance.supervisorNotes,
      'timestamp': instance.timestamp.toIso8601String(),
    };

AIError _$AIErrorFromJson(Map<String, dynamic> json) => AIError(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  errorType: json['errorType'] as String,
  description: json['description'] as String,
  severity: (json['severity'] as num).toDouble(),
  contributingFactors: (json['contributingFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  preventionStrategies: (json['preventionStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  wasCorrected: json['wasCorrected'] as bool,
  correctionNotes: json['correctionNotes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$AIErrorToJson(AIError instance) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'errorType': instance.errorType,
  'description': instance.description,
  'severity': instance.severity,
  'contributingFactors': instance.contributingFactors,
  'preventionStrategies': instance.preventionStrategies,
  'wasCorrected': instance.wasCorrected,
  'correctionNotes': instance.correctionNotes,
  'timestamp': instance.timestamp.toIso8601String(),
};

AIFeedback _$AIFeedbackFromJson(Map<String, dynamic> json) => AIFeedback(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  supervisorId: json['supervisorId'] as String,
  feedbackDate: DateTime.parse(json['feedbackDate'] as String),
  feedbackType: json['feedbackType'] as String,
  description: json['description'] as String,
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  priority: (json['priority'] as num).toDouble(),
  isAcknowledged: json['isAcknowledged'] as bool,
  acknowledgedDate: json['acknowledgedDate'] == null
      ? null
      : DateTime.parse(json['acknowledgedDate'] as String),
  response: json['response'] as String?,
);

Map<String, dynamic> _$AIFeedbackToJson(AIFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'supervisorId': instance.supervisorId,
      'feedbackDate': instance.feedbackDate.toIso8601String(),
      'feedbackType': instance.feedbackType,
      'description': instance.description,
      'suggestions': instance.suggestions,
      'priority': instance.priority,
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedDate': instance.acknowledgedDate?.toIso8601String(),
      'response': instance.response,
    };

SupervisionSession _$SupervisionSessionFromJson(Map<String, dynamic> json) =>
    SupervisionSession(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      supervisorId: json['supervisorId'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      type: $enumDecode(_$SessionTypeEnumMap, json['type']),
      agenda: json['agenda'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actionItems: (json['actionItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      followUpNotes: json['followUpNotes'] as String?,
    );

Map<String, dynamic> _$SupervisionSessionToJson(SupervisionSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'supervisorId': instance.supervisorId,
      'sessionDate': instance.sessionDate.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'type': _$SessionTypeEnumMap[instance.type]!,
      'agenda': instance.agenda,
      'topics': instance.topics,
      'actionItems': instance.actionItems,
      'recommendations': instance.recommendations,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'followUpNotes': instance.followUpNotes,
    };

const _$SessionTypeEnumMap = {
  SessionType.individual: 'individual',
  SessionType.group: 'group',
  SessionType.caseReview: 'case_review',
  SessionType.emergency: 'emergency',
  SessionType.assessment: 'assessment',
};

const _$SessionStatusEnumMap = {
  SessionStatus.scheduled: 'scheduled',
  SessionStatus.inProgress: 'in_progress',
  SessionStatus.completed: 'completed',
  SessionStatus.cancelled: 'cancelled',
  SessionStatus.rescheduled: 'rescheduled',
};

EducationalMaterial _$EducationalMaterialFromJson(Map<String, dynamic> json) =>
    EducationalMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$MaterialTypeEnumMap, json['type']),
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      content: json['content'] as String,
      url: json['url'] as String?,
      learningObjectives: (json['learningObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      competencies: (json['competencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estimatedDuration: Duration(
        microseconds: (json['estimatedDuration'] as num).toInt(),
      ),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isActive: json['isActive'] as bool,
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      averageRating: (json['averageRating'] as num).toDouble(),
    );

Map<String, dynamic> _$EducationalMaterialToJson(
  EducationalMaterial instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$MaterialTypeEnumMap[instance.type]!,
  'category': instance.category,
  'tags': instance.tags,
  'content': instance.content,
  'url': instance.url,
  'learningObjectives': instance.learningObjectives,
  'competencies': instance.competencies,
  'estimatedDuration': instance.estimatedDuration.inMicroseconds,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'createdDate': instance.createdDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'isActive': instance.isActive,
  'reviews': instance.reviews,
  'averageRating': instance.averageRating,
};

const _$MaterialTypeEnumMap = {
  MaterialType.article: 'article',
  MaterialType.video: 'video',
  MaterialType.presentation: 'presentation',
  MaterialType.workshop: 'workshop',
  MaterialType.webinar: 'webinar',
  MaterialType.caseStudy: 'case_study',
  MaterialType.assessment: 'assessment',
};

SupervisionEducationSummary _$SupervisionEducationSummaryFromJson(
  Map<String, dynamic> json,
) => SupervisionEducationSummary(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  summaryDate: DateTime.parse(json['summaryDate'] as String),
  supervisionStatus: $enumDecode(
    _$SupervisionStatusEnumMap,
    json['supervisionStatus'],
  ),
  totalCMECredits: (json['totalCMECredits'] as num).toDouble(),
  requiredCMECredits: (json['requiredCMECredits'] as num).toDouble(),
  cmeCompliant: json['cmeCompliant'] as bool,
  recentPeerReviews: (json['recentPeerReviews'] as List<dynamic>)
      .map((e) => PeerReview.fromJson(e as Map<String, dynamic>))
      .toList(),
  completedCaseStudies: (json['completedCaseStudies'] as List<dynamic>)
      .map((e) => CaseStudy.fromJson(e as Map<String, dynamic>))
      .toList(),
  supervisedAIMode: SupervisedAIMode.fromJson(
    json['supervisedAIMode'] as Map<String, dynamic>,
  ),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SupervisionEducationSummaryToJson(
  SupervisionEducationSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'clinicianId': instance.clinicianId,
  'summaryDate': instance.summaryDate.toIso8601String(),
  'supervisionStatus': _$SupervisionStatusEnumMap[instance.supervisionStatus]!,
  'totalCMECredits': instance.totalCMECredits,
  'requiredCMECredits': instance.requiredCMECredits,
  'cmeCompliant': instance.cmeCompliant,
  'recentPeerReviews': instance.recentPeerReviews,
  'completedCaseStudies': instance.completedCaseStudies,
  'supervisedAIMode': instance.supervisedAIMode,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
