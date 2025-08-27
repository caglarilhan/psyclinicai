// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supervisor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TherapistPerformance _$TherapistPerformanceFromJson(
  Map<String, dynamic> json,
) => TherapistPerformance(
  id: json['id'] as String,
  therapistId: json['therapistId'] as String,
  therapistName: json['therapistName'] as String,
  evaluationPeriod: DateTime.parse(json['evaluationPeriod'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  overallLevel: $enumDecode(_$PerformanceLevelEnumMap, json['overallLevel']),
  overallScore: (json['overallScore'] as num).toDouble(),
  categoryScores: (json['categoryScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  metrics: json['metrics'] as Map<String, dynamic>,
  strengths: (json['strengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  supervisorNotes: json['supervisorNotes'] as String?,
  therapistNotes: json['therapistNotes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$TherapistPerformanceToJson(
  TherapistPerformance instance,
) => <String, dynamic>{
  'id': instance.id,
  'therapistId': instance.therapistId,
  'therapistName': instance.therapistName,
  'evaluationPeriod': instance.evaluationPeriod.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'overallLevel': _$PerformanceLevelEnumMap[instance.overallLevel]!,
  'overallScore': instance.overallScore,
  'categoryScores': instance.categoryScores,
  'metrics': instance.metrics,
  'strengths': instance.strengths,
  'areasForImprovement': instance.areasForImprovement,
  'recommendations': instance.recommendations,
  'supervisorNotes': instance.supervisorNotes,
  'therapistNotes': instance.therapistNotes,
  'metadata': instance.metadata,
};

const _$PerformanceLevelEnumMap = {
  PerformanceLevel.excellent: 'excellent',
  PerformanceLevel.good: 'good',
  PerformanceLevel.average: 'average',
  PerformanceLevel.belowAverage: 'below_average',
  PerformanceLevel.poor: 'poor',
};

SessionEvaluation _$SessionEvaluationFromJson(Map<String, dynamic> json) =>
    SessionEvaluation(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      therapistId: json['therapistId'] as String,
      therapistName: json['therapistName'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      evaluatorId: json['evaluatorId'] as String,
      evaluatorName: json['evaluatorName'] as String?,
      quality: $enumDecode(_$SessionQualityEnumMap, json['quality']),
      qualityScore: (json['qualityScore'] as num).toDouble(),
      sessionDuration: (json['sessionDuration'] as num).toInt(),
      plannedDuration: (json['plannedDuration'] as num).toInt(),
      isOnTime: json['isOnTime'] as bool,
      isComplete: json['isComplete'] as bool,
      skillScores: (json['skillScores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      evaluatorNotes: json['evaluatorNotes'] as String?,
      therapistNotes: json['therapistNotes'] as String?,
      status: $enumDecode(_$EvaluationStatusEnumMap, json['status']),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionEvaluationToJson(SessionEvaluation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'therapistId': instance.therapistId,
      'therapistName': instance.therapistName,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'sessionDate': instance.sessionDate.toIso8601String(),
      'evaluationDate': instance.evaluationDate.toIso8601String(),
      'evaluatorId': instance.evaluatorId,
      'evaluatorName': instance.evaluatorName,
      'quality': _$SessionQualityEnumMap[instance.quality]!,
      'qualityScore': instance.qualityScore,
      'sessionDuration': instance.sessionDuration,
      'plannedDuration': instance.plannedDuration,
      'isOnTime': instance.isOnTime,
      'isComplete': instance.isComplete,
      'skillScores': instance.skillScores,
      'strengths': instance.strengths,
      'areasForImprovement': instance.areasForImprovement,
      'recommendations': instance.recommendations,
      'evaluatorNotes': instance.evaluatorNotes,
      'therapistNotes': instance.therapistNotes,
      'status': _$EvaluationStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
    };

const _$SessionQualityEnumMap = {
  SessionQuality.excellent: 'excellent',
  SessionQuality.good: 'good',
  SessionQuality.adequate: 'adequate',
  SessionQuality.needsImprovement: 'needs_improvement',
  SessionQuality.poor: 'poor',
};

const _$EvaluationStatusEnumMap = {
  EvaluationStatus.pending: 'pending',
  EvaluationStatus.inProgress: 'in_progress',
  EvaluationStatus.completed: 'completed',
  EvaluationStatus.reviewed: 'reviewed',
  EvaluationStatus.approved: 'approved',
};

AIEvaluation _$AIEvaluationFromJson(Map<String, dynamic> json) => AIEvaluation(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  therapistId: json['therapistId'] as String,
  evaluationDate: DateTime.parse(json['evaluationDate'] as String),
  aiModel: json['aiModel'] as String,
  aiVersion: json['aiVersion'] as String,
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  skillAssessments: (json['skillAssessments'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  techniqueEvaluations: (json['techniqueEvaluations'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  interventionScores: (json['interventionScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  detectedStrengths: (json['detectedStrengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  detectedAreasForImprovement:
      (json['detectedAreasForImprovement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  aiRecommendations: (json['aiRecommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  aiAnalysis: json['aiAnalysis'] as String,
  rawAnalysis: json['rawAnalysis'] as Map<String, dynamic>,
  isReviewed: json['isReviewed'] as bool,
  reviewedBy: json['reviewedBy'] as String?,
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  reviewNotes: json['reviewNotes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AIEvaluationToJson(AIEvaluation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'therapistId': instance.therapistId,
      'evaluationDate': instance.evaluationDate.toIso8601String(),
      'aiModel': instance.aiModel,
      'aiVersion': instance.aiVersion,
      'confidenceScore': instance.confidenceScore,
      'skillAssessments': instance.skillAssessments,
      'techniqueEvaluations': instance.techniqueEvaluations,
      'interventionScores': instance.interventionScores,
      'detectedStrengths': instance.detectedStrengths,
      'detectedAreasForImprovement': instance.detectedAreasForImprovement,
      'aiRecommendations': instance.aiRecommendations,
      'aiAnalysis': instance.aiAnalysis,
      'rawAnalysis': instance.rawAnalysis,
      'isReviewed': instance.isReviewed,
      'reviewedBy': instance.reviewedBy,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewNotes': instance.reviewNotes,
      'metadata': instance.metadata,
    };

SupervisionSession _$SupervisionSessionFromJson(Map<String, dynamic> json) =>
    SupervisionSession(
      id: json['id'] as String,
      supervisorId: json['supervisorId'] as String,
      supervisorName: json['supervisorName'] as String,
      therapistIds: (json['therapistIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapistNames: (json['therapistNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: $enumDecode(_$SupervisionTypeEnumMap, json['type']),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      actualDate: json['actualDate'] == null
          ? null
          : DateTime.parse(json['actualDate'] as String),
      plannedDuration: (json['plannedDuration'] as num).toInt(),
      actualDuration: (json['actualDuration'] as num).toInt(),
      location: json['location'] as String?,
      agenda: json['agenda'] as String?,
      discussionTopics: (json['discussionTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actionItems: (json['actionItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supervisorNotes: json['supervisorNotes'] as String?,
      therapistNotes: (json['therapistNotes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$EvaluationStatusEnumMap, json['status']),
      metadata: json['metadata'] as Map<String, dynamic>,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SupervisionSessionToJson(SupervisionSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supervisorId': instance.supervisorId,
      'supervisorName': instance.supervisorName,
      'therapistIds': instance.therapistIds,
      'therapistNames': instance.therapistNames,
      'type': _$SupervisionTypeEnumMap[instance.type]!,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'actualDate': instance.actualDate?.toIso8601String(),
      'plannedDuration': instance.plannedDuration,
      'actualDuration': instance.actualDuration,
      'location': instance.location,
      'agenda': instance.agenda,
      'discussionTopics': instance.discussionTopics,
      'actionItems': instance.actionItems,
      'supervisorNotes': instance.supervisorNotes,
      'therapistNotes': instance.therapistNotes,
      'status': _$EvaluationStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'attachments': instance.attachments,
    };

const _$SupervisionTypeEnumMap = {
  SupervisionType.individual: 'individual',
  SupervisionType.group: 'group',
  SupervisionType.peer: 'peer',
  SupervisionType.caseReview: 'case_review',
  SupervisionType.liveSupervision: 'live_supervision',
};

PerformanceMetrics _$PerformanceMetricsFromJson(
  Map<String, dynamic> json,
) => PerformanceMetrics(
  id: json['id'] as String,
  therapistId: json['therapistId'] as String,
  calculationDate: DateTime.parse(json['calculationDate'] as String),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  totalSessions: (json['totalSessions'] as num).toInt(),
  completedSessions: (json['completedSessions'] as num).toInt(),
  cancelledSessions: (json['cancelledSessions'] as num).toInt(),
  noShowSessions: (json['noShowSessions'] as num).toInt(),
  averageSessionDuration: (json['averageSessionDuration'] as num).toDouble(),
  onTimeRate: (json['onTimeRate'] as num).toDouble(),
  completionRate: (json['completionRate'] as num).toDouble(),
  averageQualityScore: (json['averageQualityScore'] as num).toDouble(),
  skillAverages: (json['skillAverages'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  techniqueUsage: Map<String, int>.from(json['techniqueUsage'] as Map),
  interventionEffectiveness:
      (json['interventionEffectiveness'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  totalClients: (json['totalClients'] as num).toInt(),
  activeClients: (json['activeClients'] as num).toInt(),
  dischargedClients: (json['dischargedClients'] as num).toInt(),
  clientSatisfactionScore: (json['clientSatisfactionScore'] as num).toDouble(),
  detailedMetrics: json['detailedMetrics'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PerformanceMetricsToJson(PerformanceMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'therapistId': instance.therapistId,
      'calculationDate': instance.calculationDate.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'totalSessions': instance.totalSessions,
      'completedSessions': instance.completedSessions,
      'cancelledSessions': instance.cancelledSessions,
      'noShowSessions': instance.noShowSessions,
      'averageSessionDuration': instance.averageSessionDuration,
      'onTimeRate': instance.onTimeRate,
      'completionRate': instance.completionRate,
      'averageQualityScore': instance.averageQualityScore,
      'skillAverages': instance.skillAverages,
      'techniqueUsage': instance.techniqueUsage,
      'interventionEffectiveness': instance.interventionEffectiveness,
      'totalClients': instance.totalClients,
      'activeClients': instance.activeClients,
      'dischargedClients': instance.dischargedClients,
      'clientSatisfactionScore': instance.clientSatisfactionScore,
      'detailedMetrics': instance.detailedMetrics,
      'metadata': instance.metadata,
    };

DevelopmentPlan _$DevelopmentPlanFromJson(Map<String, dynamic> json) =>
    DevelopmentPlan(
      id: json['id'] as String,
      therapistId: json['therapistId'] as String,
      therapistName: json['therapistName'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String),
      supervisorId: json['supervisorId'] as String,
      supervisorName: json['supervisorName'] as String?,
      goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
      actionSteps: (json['actionSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      resources: (json['resources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      milestoneDates: (json['milestoneDates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, DateTime.parse(e as String)),
      ),
      completedActions: (json['completedActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      completedMilestones: (json['completedMilestones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      supervisorNotes: json['supervisorNotes'] as String?,
      therapistNotes: json['therapistNotes'] as String?,
      status: $enumDecode(_$EvaluationStatusEnumMap, json['status']),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DevelopmentPlanToJson(DevelopmentPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'therapistId': instance.therapistId,
      'therapistName': instance.therapistName,
      'createdDate': instance.createdDate.toIso8601String(),
      'targetDate': instance.targetDate?.toIso8601String(),
      'supervisorId': instance.supervisorId,
      'supervisorName': instance.supervisorName,
      'goals': instance.goals,
      'actionSteps': instance.actionSteps,
      'resources': instance.resources,
      'milestones': instance.milestones,
      'milestoneDates': instance.milestoneDates.map(
        (k, e) => MapEntry(k, e.toIso8601String()),
      ),
      'completedActions': instance.completedActions,
      'completedMilestones': instance.completedMilestones,
      'progressPercentage': instance.progressPercentage,
      'supervisorNotes': instance.supervisorNotes,
      'therapistNotes': instance.therapistNotes,
      'status': _$EvaluationStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
    };

PerformanceReport _$PerformanceReportFromJson(Map<String, dynamic> json) =>
    PerformanceReport(
      id: json['id'] as String,
      therapistId: json['therapistId'] as String,
      therapistName: json['therapistName'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      generatedBy: json['generatedBy'] as String,
      overallLevel: $enumDecode(
        _$PerformanceLevelEnumMap,
        json['overallLevel'],
      ),
      overallScore: (json['overallScore'] as num).toDouble(),
      categoryBreakdown: (json['categoryBreakdown'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      keyAchievements: (json['keyAchievements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      statistics: json['statistics'] as Map<String, dynamic>,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      summary: json['summary'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PerformanceReportToJson(PerformanceReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'therapistId': instance.therapistId,
      'therapistName': instance.therapistName,
      'reportDate': instance.reportDate.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'generatedBy': instance.generatedBy,
      'overallLevel': _$PerformanceLevelEnumMap[instance.overallLevel]!,
      'overallScore': instance.overallScore,
      'categoryBreakdown': instance.categoryBreakdown,
      'keyAchievements': instance.keyAchievements,
      'areasForImprovement': instance.areasForImprovement,
      'recommendations': instance.recommendations,
      'statistics': instance.statistics,
      'strengths': instance.strengths,
      'challenges': instance.challenges,
      'summary': instance.summary,
      'metadata': instance.metadata,
      'attachments': instance.attachments,
    };

TeamPerformance _$TeamPerformanceFromJson(Map<String, dynamic> json) =>
    TeamPerformance(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      therapistIds: (json['therapistIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapistNames: (json['therapistNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      teamAverageScore: (json['teamAverageScore'] as num).toDouble(),
      teamLevel: $enumDecode(_$PerformanceLevelEnumMap, json['teamLevel']),
      categoryAverages: (json['categoryAverages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      teamStrengths: (json['teamStrengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      teamChallenges: (json['teamChallenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      teamRecommendations: (json['teamRecommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      individualScores: json['individualScores'] as Map<String, dynamic>,
      comparativeMetrics: json['comparativeMetrics'] as Map<String, dynamic>,
      supervisorNotes: json['supervisorNotes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TeamPerformanceToJson(TeamPerformance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'evaluationDate': instance.evaluationDate.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'therapistIds': instance.therapistIds,
      'therapistNames': instance.therapistNames,
      'teamAverageScore': instance.teamAverageScore,
      'teamLevel': _$PerformanceLevelEnumMap[instance.teamLevel]!,
      'categoryAverages': instance.categoryAverages,
      'teamStrengths': instance.teamStrengths,
      'teamChallenges': instance.teamChallenges,
      'teamRecommendations': instance.teamRecommendations,
      'individualScores': instance.individualScores,
      'comparativeMetrics': instance.comparativeMetrics,
      'supervisorNotes': instance.supervisorNotes,
      'metadata': instance.metadata,
    };
