// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supervision_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupervisionSession _$SupervisionSessionFromJson(Map<String, dynamic> json) =>
    SupervisionSession(
      id: json['id'] as String,
      title: json['title'] as String,
      supervisorId: json['supervisorId'] as String,
      therapistId: json['therapistId'] as String,
      therapistName: json['therapistName'] as String,
      clientId: json['clientId'] as String?,
      type: $enumDecode(_$SupervisionTypeEnumMap, json['type']),
      status: $enumDecode(_$SupervisionStatusEnumMap, json['status']),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      actualDate: json['actualDate'] == null
          ? null
          : DateTime.parse(json['actualDate'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      notes: json['notes'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actionItems: (json['actionItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      aiSummary: json['aiSummary'] as Map<String, dynamic>,
      performanceRating: $enumDecodeNullable(
        _$PerformanceRatingEnumMap,
        json['performanceRating'],
      ),
      feedback: json['feedback'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SupervisionSessionToJson(
  SupervisionSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'supervisorId': instance.supervisorId,
  'therapistId': instance.therapistId,
  'therapistName': instance.therapistName,
  'clientId': instance.clientId,
  'type': _$SupervisionTypeEnumMap[instance.type]!,
  'status': _$SupervisionStatusEnumMap[instance.status]!,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'actualDate': instance.actualDate?.toIso8601String(),
  'duration': instance.duration.inMicroseconds,
  'notes': instance.notes,
  'topics': instance.topics,
  'actionItems': instance.actionItems,
  'aiSummary': instance.aiSummary,
  'performanceRating': _$PerformanceRatingEnumMap[instance.performanceRating],
  'feedback': instance.feedback,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$SupervisionTypeEnumMap = {
  SupervisionType.individual: 'individual',
  SupervisionType.group: 'group',
  SupervisionType.caseReview: 'caseReview',
  SupervisionType.skillAssessment: 'skillAssessment',
  SupervisionType.supervision: 'supervision',
  SupervisionType.crisisManagement: 'crisisManagement',
  SupervisionType.documentationReview: 'documentationReview',
};

const _$SupervisionStatusEnumMap = {
  SupervisionStatus.pending: 'pending',
  SupervisionStatus.scheduled: 'scheduled',
  SupervisionStatus.inProgress: 'inProgress',
  SupervisionStatus.completed: 'completed',
  SupervisionStatus.cancelled: 'cancelled',
  SupervisionStatus.requiresFollowUp: 'requiresFollowUp',
};

const _$PerformanceRatingEnumMap = {
  PerformanceRating.poor: 'poor',
  PerformanceRating.fair: 'fair',
  PerformanceRating.good: 'good',
  PerformanceRating.veryGood: 'veryGood',
  PerformanceRating.excellent: 'excellent',
};

TherapistPerformance _$TherapistPerformanceFromJson(
  Map<String, dynamic> json,
) => TherapistPerformance(
  id: json['id'] as String,
  therapistId: json['therapistId'] as String,
  therapistName: json['therapistName'] as String,
  specialization: json['specialization'] as String,
  successRate: (json['successRate'] as num).toDouble(),
  caseCount: (json['caseCount'] as num).toInt(),
  averageRating: (json['averageRating'] as num).toDouble(),
  improvementRate: (json['improvementRate'] as num).toDouble(),
  notes: json['notes'] as String?,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$TherapistPerformanceToJson(
  TherapistPerformance instance,
) => <String, dynamic>{
  'id': instance.id,
  'therapistId': instance.therapistId,
  'therapistName': instance.therapistName,
  'specialization': instance.specialization,
  'successRate': instance.successRate,
  'caseCount': instance.caseCount,
  'averageRating': instance.averageRating,
  'improvementRate': instance.improvementRate,
  'notes': instance.notes,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

QualityMetric _$QualityMetricFromJson(Map<String, dynamic> json) =>
    QualityMetric(
      id: json['id'] as String,
      metricName: json['metricName'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      score: (json['score'] as num).toDouble(),
      trend: json['trend'] as String,
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$QualityMetricToJson(QualityMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metricName': instance.metricName,
      'description': instance.description,
      'category': instance.category,
      'score': instance.score,
      'trend': instance.trend,
      'targetValue': instance.targetValue,
      'weight': instance.weight,
      'notes': instance.notes,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

SupervisionReport _$SupervisionReportFromJson(Map<String, dynamic> json) =>
    SupervisionReport(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      supervisorId: json['supervisorId'] as String,
      therapistId: json['therapistId'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      summary: json['summary'] as String,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      overallRating: $enumDecode(
        _$PerformanceRatingEnumMap,
        json['overallRating'],
      ),
      additionalNotes: json['additionalNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SupervisionReportToJson(SupervisionReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'supervisorId': instance.supervisorId,
      'therapistId': instance.therapistId,
      'reportDate': instance.reportDate.toIso8601String(),
      'summary': instance.summary,
      'strengths': instance.strengths,
      'areasForImprovement': instance.areasForImprovement,
      'recommendations': instance.recommendations,
      'overallRating': _$PerformanceRatingEnumMap[instance.overallRating]!,
      'additionalNotes': instance.additionalNotes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

SupervisionTemplate _$SupervisionTemplateFromJson(Map<String, dynamic> json) =>
    SupervisionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$SupervisionTypeEnumMap, json['type']),
      defaultDuration: Duration(
        microseconds: (json['defaultDuration'] as num).toInt(),
      ),
      standardTopics: (json['standardTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      standardActionItems: (json['standardActionItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      aiPromptTemplate: json['aiPromptTemplate'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SupervisionTemplateToJson(
  SupervisionTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$SupervisionTypeEnumMap[instance.type]!,
  'defaultDuration': instance.defaultDuration.inMicroseconds,
  'standardTopics': instance.standardTopics,
  'standardActionItems': instance.standardActionItems,
  'aiPromptTemplate': instance.aiPromptTemplate,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

SupervisionSchedule _$SupervisionScheduleFromJson(Map<String, dynamic> json) =>
    SupervisionSchedule(
      id: json['id'] as String,
      supervisorId: json['supervisorId'] as String,
      therapistId: json['therapistId'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      type: $enumDecode(_$SupervisionTypeEnumMap, json['type']),
      notes: json['notes'] as String?,
      isRecurring: json['isRecurring'] as bool,
      recurrencePattern: json['recurrencePattern'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SupervisionScheduleToJson(
  SupervisionSchedule instance,
) => <String, dynamic>{
  'id': instance.id,
  'supervisorId': instance.supervisorId,
  'therapistId': instance.therapistId,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'duration': instance.duration.inMicroseconds,
  'type': _$SupervisionTypeEnumMap[instance.type]!,
  'notes': instance.notes,
  'isRecurring': instance.isRecurring,
  'recurrencePattern': instance.recurrencePattern,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

SupervisionFeedback _$SupervisionFeedbackFromJson(Map<String, dynamic> json) =>
    SupervisionFeedback(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      fromId: json['fromId'] as String,
      toId: json['toId'] as String,
      feedbackType: json['feedbackType'] as String,
      content: json['content'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isAnonymous: json['isAnonymous'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SupervisionFeedbackToJson(
  SupervisionFeedback instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'fromId': instance.fromId,
  'toId': instance.toId,
  'feedbackType': instance.feedbackType,
  'content': instance.content,
  'rating': instance.rating,
  'tags': instance.tags,
  'isAnonymous': instance.isAnonymous,
  'createdAt': instance.createdAt.toIso8601String(),
};

SupervisionAnalytics _$SupervisionAnalyticsFromJson(
  Map<String, dynamic> json,
) => SupervisionAnalytics(
  id: json['id'] as String,
  supervisorId: json['supervisorId'] as String,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  totalSessions: (json['totalSessions'] as num).toInt(),
  completedSessions: (json['completedSessions'] as num).toInt(),
  cancelledSessions: (json['cancelledSessions'] as num).toInt(),
  averageSessionDuration: (json['averageSessionDuration'] as num).toDouble(),
  sessionsByType: Map<String, int>.from(json['sessionsByType'] as Map),
  performanceByTherapist:
      (json['performanceByTherapist'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  topTopics: (json['topTopics'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  commonActionItems: (json['commonActionItems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$SupervisionAnalyticsToJson(
  SupervisionAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'supervisorId': instance.supervisorId,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'totalSessions': instance.totalSessions,
  'completedSessions': instance.completedSessions,
  'cancelledSessions': instance.cancelledSessions,
  'averageSessionDuration': instance.averageSessionDuration,
  'sessionsByType': instance.sessionsByType,
  'performanceByTherapist': instance.performanceByTherapist,
  'topTopics': instance.topTopics,
  'commonActionItems': instance.commonActionItems,
  'generatedAt': instance.generatedAt.toIso8601String(),
};

SupervisionGoal _$SupervisionGoalFromJson(Map<String, dynamic> json) =>
    SupervisionGoal(
      id: json['id'] as String,
      therapistId: json['therapistId'] as String,
      supervisorId: json['supervisorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      status: json['status'] as String,
      progress: (json['progress'] as num).toDouble(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SupervisionGoalToJson(SupervisionGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'therapistId': instance.therapistId,
      'supervisorId': instance.supervisorId,
      'title': instance.title,
      'description': instance.description,
      'targetDate': instance.targetDate.toIso8601String(),
      'status': instance.status,
      'progress': instance.progress,
      'milestones': instance.milestones,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SupervisionResource _$SupervisionResourceFromJson(Map<String, dynamic> json) =>
    SupervisionResource(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      filePath: json['filePath'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      isPublic: json['isPublic'] as bool,
      downloadCount: (json['downloadCount'] as num).toInt(),
    );

Map<String, dynamic> _$SupervisionResourceToJson(
  SupervisionResource instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': instance.type,
  'url': instance.url,
  'filePath': instance.filePath,
  'tags': instance.tags,
  'uploadedBy': instance.uploadedBy,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
  'isPublic': instance.isPublic,
  'downloadCount': instance.downloadCount,
};
