// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_appointment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIAppointmentPrediction _$AIAppointmentPredictionFromJson(
  Map<String, dynamic> json,
) => AIAppointmentPrediction(
  id: json['id'] as String,
  appointmentId: json['appointmentId'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  type: $enumDecode(_$AppointmentPredictionTypeEnumMap, json['type']),
  confidence: (json['confidence'] as num).toDouble(),
  prediction: json['prediction'] as String,
  factors: json['factors'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$AIAppointmentPredictionToJson(
  AIAppointmentPrediction instance,
) => <String, dynamic>{
  'id': instance.id,
  'appointmentId': instance.appointmentId,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'type': _$AppointmentPredictionTypeEnumMap[instance.type]!,
  'confidence': instance.confidence,
  'prediction': instance.prediction,
  'factors': instance.factors,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
  'notes': instance.notes,
};

const _$AppointmentPredictionTypeEnumMap = {
  AppointmentPredictionType.noShow: 'noShow',
  AppointmentPredictionType.lateArrival: 'lateArrival',
  AppointmentPredictionType.earlyArrival: 'earlyArrival',
  AppointmentPredictionType.cancellation: 'cancellation',
  AppointmentPredictionType.reschedule: 'reschedule',
  AppointmentPredictionType.emergency: 'emergency',
  AppointmentPredictionType.followUp: 'followUp',
  AppointmentPredictionType.newClient: 'newClient',
  AppointmentPredictionType.regularClient: 'regularClient',
};

AIAppointmentReminder _$AIAppointmentReminderFromJson(
  Map<String, dynamic> json,
) => AIAppointmentReminder(
  id: json['id'] as String,
  appointmentId: json['appointmentId'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
  channel: $enumDecode(_$ReminderChannelEnumMap, json['channel']),
  scheduledTime: DateTime.parse(json['scheduledTime'] as String),
  sentTime: json['sentTime'] == null
      ? null
      : DateTime.parse(json['sentTime'] as String),
  status: $enumDecode(_$ReminderStatusEnumMap, json['status']),
  message: json['message'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
  isAIOptimized: json['isAIOptimized'] as bool,
);

Map<String, dynamic> _$AIAppointmentReminderToJson(
  AIAppointmentReminder instance,
) => <String, dynamic>{
  'id': instance.id,
  'appointmentId': instance.appointmentId,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'type': _$ReminderTypeEnumMap[instance.type]!,
  'channel': _$ReminderChannelEnumMap[instance.channel]!,
  'scheduledTime': instance.scheduledTime.toIso8601String(),
  'sentTime': instance.sentTime?.toIso8601String(),
  'status': _$ReminderStatusEnumMap[instance.status]!,
  'message': instance.message,
  'metadata': instance.metadata,
  'isAIOptimized': instance.isAIOptimized,
};

const _$ReminderTypeEnumMap = {
  ReminderType.appointmentConfirmation: 'appointmentConfirmation',
  ReminderType.appointmentReminder: 'appointmentReminder',
  ReminderType.preparationInstructions: 'preparationInstructions',
  ReminderType.followUpReminder: 'followUpReminder',
  ReminderType.cancellationNotice: 'cancellationNotice',
  ReminderType.rescheduleRequest: 'rescheduleRequest',
  ReminderType.emergencyAlert: 'emergencyAlert',
};

const _$ReminderChannelEnumMap = {
  ReminderChannel.sms: 'sms',
  ReminderChannel.email: 'email',
  ReminderChannel.pushNotification: 'pushNotification',
  ReminderChannel.inApp: 'inApp',
  ReminderChannel.phoneCall: 'phoneCall',
  ReminderChannel.whatsapp: 'whatsapp',
};

const _$ReminderStatusEnumMap = {
  ReminderStatus.scheduled: 'scheduled',
  ReminderStatus.sent: 'sent',
  ReminderStatus.delivered: 'delivered',
  ReminderStatus.read: 'read',
  ReminderStatus.failed: 'failed',
  ReminderStatus.cancelled: 'cancelled',
};

SmartAppointmentSuggestion _$SmartAppointmentSuggestionFromJson(
  Map<String, dynamic> json,
) => SmartAppointmentSuggestion(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  suggestedTime: DateTime.parse(json['suggestedTime'] as String),
  alternativeTimes: (json['alternativeTimes'] as List<dynamic>)
      .map((e) => DateTime.parse(e as String))
      .toList(),
  priority: (json['priority'] as num).toDouble(),
  reason: $enumDecode(_$SuggestionReasonEnumMap, json['reason']),
  factors: json['factors'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isAccepted: json['isAccepted'] as bool,
  acceptedAt: json['acceptedAt'] == null
      ? null
      : DateTime.parse(json['acceptedAt'] as String),
);

Map<String, dynamic> _$SmartAppointmentSuggestionToJson(
  SmartAppointmentSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'suggestedTime': instance.suggestedTime.toIso8601String(),
  'alternativeTimes': instance.alternativeTimes
      .map((e) => e.toIso8601String())
      .toList(),
  'priority': instance.priority,
  'reason': _$SuggestionReasonEnumMap[instance.reason]!,
  'factors': instance.factors,
  'createdAt': instance.createdAt.toIso8601String(),
  'isAccepted': instance.isAccepted,
  'acceptedAt': instance.acceptedAt?.toIso8601String(),
};

const _$SuggestionReasonEnumMap = {
  SuggestionReason.clientPreference: 'clientPreference',
  SuggestionReason.therapistAvailability: 'therapistAvailability',
  SuggestionReason.optimalTiming: 'optimalTiming',
  SuggestionReason.followUpSchedule: 'followUpSchedule',
  SuggestionReason.emergencySlot: 'emergencySlot',
  SuggestionReason.maintenanceWindow: 'maintenanceWindow',
  SuggestionReason.seasonalPattern: 'seasonalPattern',
};

AppointmentAnalytics _$AppointmentAnalyticsFromJson(
  Map<String, dynamic> json,
) => AppointmentAnalytics(
  id: json['id'] as String,
  therapistId: json['therapistId'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  completedAppointments: (json['completedAppointments'] as num).toInt(),
  cancelledAppointments: (json['cancelledAppointments'] as num).toInt(),
  noShowAppointments: (json['noShowAppointments'] as num).toInt(),
  completionRate: (json['completionRate'] as num).toDouble(),
  cancellationRate: (json['cancellationRate'] as num).toDouble(),
  noShowRate: (json['noShowRate'] as num).toDouble(),
  hourlyDistribution: (json['hourlyDistribution'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  dailyDistribution: (json['dailyDistribution'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  monthlyTrends: (json['monthlyTrends'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  patterns: (json['patterns'] as List<dynamic>)
      .map((e) => AppointmentPattern.fromJson(e as Map<String, dynamic>))
      .toList(),
  insights: (json['insights'] as List<dynamic>)
      .map((e) => AppointmentInsight.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AppointmentAnalyticsToJson(
  AppointmentAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'therapistId': instance.therapistId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'totalAppointments': instance.totalAppointments,
  'completedAppointments': instance.completedAppointments,
  'cancelledAppointments': instance.cancelledAppointments,
  'noShowAppointments': instance.noShowAppointments,
  'completionRate': instance.completionRate,
  'cancellationRate': instance.cancellationRate,
  'noShowRate': instance.noShowRate,
  'hourlyDistribution': instance.hourlyDistribution,
  'dailyDistribution': instance.dailyDistribution,
  'monthlyTrends': instance.monthlyTrends,
  'patterns': instance.patterns,
  'insights': instance.insights,
};

AppointmentPattern _$AppointmentPatternFromJson(Map<String, dynamic> json) =>
    AppointmentPattern(
      id: json['id'] as String,
      type: $enumDecode(_$PatternTypeEnumMap, json['type']),
      description: json['description'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      data: json['data'] as Map<String, dynamic>,
      firstObserved: DateTime.parse(json['firstObserved'] as String),
      lastObserved: DateTime.parse(json['lastObserved'] as String),
    );

Map<String, dynamic> _$AppointmentPatternToJson(AppointmentPattern instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PatternTypeEnumMap[instance.type]!,
      'description': instance.description,
      'frequency': instance.frequency,
      'data': instance.data,
      'firstObserved': instance.firstObserved.toIso8601String(),
      'lastObserved': instance.lastObserved.toIso8601String(),
    };

const _$PatternTypeEnumMap = {
  PatternType.timePreference: 'timePreference',
  PatternType.cancellationPattern: 'cancellationPattern',
  PatternType.reschedulePattern: 'reschedulePattern',
  PatternType.noShowPattern: 'noShowPattern',
  PatternType.seasonalVariation: 'seasonalVariation',
  PatternType.clientBehavior: 'clientBehavior',
  PatternType.therapistAvailability: 'therapistAvailability',
};

AppointmentInsight _$AppointmentInsightFromJson(Map<String, dynamic> json) =>
    AppointmentInsight(
      id: json['id'] as String,
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$InsightSeverityEnumMap, json['severity']),
      data: json['data'] as Map<String, dynamic>,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActioned: json['isActioned'] as bool,
    );

Map<String, dynamic> _$AppointmentInsightToJson(AppointmentInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$InsightTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'severity': _$InsightSeverityEnumMap[instance.severity]!,
      'data': instance.data,
      'recommendations': instance.recommendations,
      'isActioned': instance.isActioned,
    };

const _$InsightTypeEnumMap = {
  InsightType.performance: 'performance',
  InsightType.efficiency: 'efficiency',
  InsightType.clientSatisfaction: 'clientSatisfaction',
  InsightType.revenue: 'revenue',
  InsightType.scheduling: 'scheduling',
  InsightType.resourceUtilization: 'resourceUtilization',
  InsightType.risk: 'risk',
};

const _$InsightSeverityEnumMap = {
  InsightSeverity.low: 'low',
  InsightSeverity.medium: 'medium',
  InsightSeverity.high: 'high',
  InsightSeverity.critical: 'critical',
};

InstitutionalMessage _$InstitutionalMessageFromJson(
  Map<String, dynamic> json,
) => InstitutionalMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  senderRole: json['senderRole'] as String,
  recipientIds: (json['recipientIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recipientNames: (json['recipientNames'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  subject: json['subject'] as String,
  content: json['content'] as String,
  priority: $enumDecode(_$MessagePriorityEnumMap, json['priority']),
  status: $enumDecode(_$MessageStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  sentAt: json['sentAt'] == null
      ? null
      : DateTime.parse(json['sentAt'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
  attachments: (json['attachments'] as List<dynamic>)
      .map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
      .toList(),
  reactions: (json['reactions'] as List<dynamic>)
      .map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
      .toList(),
  replies: (json['replies'] as List<dynamic>)
      .map((e) => MessageReply.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  isAIProcessed: json['isAIProcessed'] as bool,
);

Map<String, dynamic> _$InstitutionalMessageToJson(
  InstitutionalMessage instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'senderRole': instance.senderRole,
  'recipientIds': instance.recipientIds,
  'recipientNames': instance.recipientNames,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'subject': instance.subject,
  'content': instance.content,
  'priority': _$MessagePriorityEnumMap[instance.priority]!,
  'status': _$MessageStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'sentAt': instance.sentAt?.toIso8601String(),
  'readAt': instance.readAt?.toIso8601String(),
  'attachments': instance.attachments,
  'reactions': instance.reactions,
  'replies': instance.replies,
  'metadata': instance.metadata,
  'isAIProcessed': instance.isAIProcessed,
};

const _$MessageTypeEnumMap = {
  MessageType.general: 'general',
  MessageType.announcement: 'announcement',
  MessageType.meeting: 'meeting',
  MessageType.task: 'task',
  MessageType.question: 'question',
  MessageType.feedback: 'feedback',
  MessageType.emergency: 'emergency',
  MessageType.reminder: 'reminder',
  MessageType.report: 'report',
};

const _$MessagePriorityEnumMap = {
  MessagePriority.low: 'low',
  MessagePriority.normal: 'normal',
  MessagePriority.high: 'high',
  MessagePriority.urgent: 'urgent',
};

const _$MessageStatusEnumMap = {
  MessageStatus.draft: 'draft',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.archived: 'archived',
  MessageStatus.deleted: 'deleted',
};

MessageAttachment _$MessageAttachmentFromJson(Map<String, dynamic> json) =>
    MessageAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
      url: json['url'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      uploadedBy: json['uploadedBy'] as String,
    );

Map<String, dynamic> _$MessageAttachmentToJson(MessageAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'url': instance.url,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'uploadedBy': instance.uploadedBy,
    };

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) =>
    MessageReaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      type: $enumDecode(_$ReactionTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageReactionToJson(MessageReaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'type': _$ReactionTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ReactionTypeEnumMap = {
  ReactionType.like: 'like',
  ReactionType.love: 'love',
  ReactionType.laugh: 'laugh',
  ReactionType.wow: 'wow',
  ReactionType.sad: 'sad',
  ReactionType.angry: 'angry',
  ReactionType.thumbsUp: 'thumbsUp',
  ReactionType.thumbsDown: 'thumbsDown',
};

MessageReply _$MessageReplyFromJson(Map<String, dynamic> json) => MessageReply(
  id: json['id'] as String,
  messageId: json['messageId'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  reactions: (json['reactions'] as List<dynamic>)
      .map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
      .toList(),
  nestedReplies: (json['nestedReplies'] as List<dynamic>)
      .map((e) => MessageReply.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MessageReplyToJson(MessageReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'reactions': instance.reactions,
      'nestedReplies': instance.nestedReplies,
    };

AIMeetingSummary _$AIMeetingSummaryFromJson(Map<String, dynamic> json) =>
    AIMeetingSummary(
      id: json['id'] as String,
      meetingId: json['meetingId'] as String,
      title: json['title'] as String,
      meetingDate: DateTime.parse(json['meetingDate'] as String),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      summary: json['summary'] as String,
      keyPoints: (json['keyPoints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actionItems: (json['actionItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      decisions: (json['decisions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sentiment: json['sentiment'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      generatedBy: json['generatedBy'] as String,
    );

Map<String, dynamic> _$AIMeetingSummaryToJson(AIMeetingSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'meetingId': instance.meetingId,
      'title': instance.title,
      'meetingDate': instance.meetingDate.toIso8601String(),
      'participants': instance.participants,
      'summary': instance.summary,
      'keyPoints': instance.keyPoints,
      'actionItems': instance.actionItems,
      'decisions': instance.decisions,
      'sentiment': instance.sentiment,
      'confidence': instance.confidence,
      'createdAt': instance.createdAt.toIso8601String(),
      'generatedBy': instance.generatedBy,
    };

AppointmentOptimization _$AppointmentOptimizationFromJson(
  Map<String, dynamic> json,
) => AppointmentOptimization(
  id: json['id'] as String,
  therapistId: json['therapistId'] as String,
  date: DateTime.parse(json['date'] as String),
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => OptimizationSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
  constraints: json['constraints'] as Map<String, dynamic>,
  efficiencyScore: (json['efficiencyScore'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AppointmentOptimizationToJson(
  AppointmentOptimization instance,
) => <String, dynamic>{
  'id': instance.id,
  'therapistId': instance.therapistId,
  'date': instance.date.toIso8601String(),
  'suggestions': instance.suggestions,
  'constraints': instance.constraints,
  'efficiencyScore': instance.efficiencyScore,
  'createdAt': instance.createdAt.toIso8601String(),
};

OptimizationSuggestion _$OptimizationSuggestionFromJson(
  Map<String, dynamic> json,
) => OptimizationSuggestion(
  id: json['id'] as String,
  type: $enumDecode(_$OptimizationTypeEnumMap, json['type']),
  description: json['description'] as String,
  impact: (json['impact'] as num).toDouble(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  data: json['data'] as Map<String, dynamic>,
);

Map<String, dynamic> _$OptimizationSuggestionToJson(
  OptimizationSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$OptimizationTypeEnumMap[instance.type]!,
  'description': instance.description,
  'impact': instance.impact,
  'actions': instance.actions,
  'data': instance.data,
};

const _$OptimizationTypeEnumMap = {
  OptimizationType.timeSlot: 'timeSlot',
  OptimizationType.duration: 'duration',
  OptimizationType.sequence: 'sequence',
  OptimizationType.resource: 'resource',
  OptimizationType.capacity: 'capacity',
  OptimizationType.routing: 'routing',
};
