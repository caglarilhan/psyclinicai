import 'package:json_annotation/json_annotation.dart';

part 'ai_appointment_models.g.dart';

// ===== AI RANDEVU TAHMİNLERİ =====

@JsonSerializable()
class AIAppointmentPrediction {
  final String id;
  final String appointmentId;
  final String clientId;
  final String therapistId;
  final AppointmentPredictionType type;
  final double confidence;
  final String prediction;
  final Map<String, dynamic> factors;
  final DateTime createdAt;
  final bool isActive;
  final String? notes;

  const AIAppointmentPrediction({
    required this.id,
    required this.appointmentId,
    required this.clientId,
    required this.therapistId,
    required this.type,
    required this.confidence,
    required this.prediction,
    required this.factors,
    required this.createdAt,
    required this.isActive,
    this.notes,
  });

  factory AIAppointmentPrediction.fromJson(Map<String, dynamic> json) => _$AIAppointmentPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$AIAppointmentPredictionToJson(this);
}

enum AppointmentPredictionType {
  noShow,
  lateArrival,
  earlyArrival,
  cancellation,
  reschedule,
  emergency,
  followUp,
  newClient,
  regularClient
}

// ===== AI HATIRLATICILAR =====

@JsonSerializable()
class AIAppointmentReminder {
  final String id;
  final String appointmentId;
  final String clientId;
  final String therapistId;
  final ReminderType type;
  final ReminderChannel channel;
  final DateTime scheduledTime;
  final DateTime? sentTime;
  final ReminderStatus status;
  final String message;
  final Map<String, dynamic>? metadata;
  final bool isAIOptimized;

  const AIAppointmentReminder({
    required this.id,
    required this.appointmentId,
    required this.clientId,
    required this.therapistId,
    required this.type,
    required this.channel,
    required this.scheduledTime,
    this.sentTime,
    required this.status,
    required this.message,
    this.metadata,
    required this.isAIOptimized,
  });

  factory AIAppointmentReminder.fromJson(Map<String, dynamic> json) => _$AIAppointmentReminderFromJson(json);
  Map<String, dynamic> toJson() => _$AIAppointmentReminderToJson(this);
}

enum ReminderType {
  appointmentConfirmation,
  appointmentReminder,
  preparationInstructions,
  followUpReminder,
  cancellationNotice,
  rescheduleRequest,
  emergencyAlert
}

enum ReminderChannel {
  sms,
  email,
  pushNotification,
  inApp,
  phoneCall,
  whatsapp
}

enum ReminderStatus {
  scheduled,
  sent,
  delivered,
  read,
  failed,
  cancelled
}

// ===== AKILLI RANDEVU ÖNERİLERİ =====

@JsonSerializable()
class SmartAppointmentSuggestion {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime suggestedTime;
  final List<DateTime> alternativeTimes;
  final double priority;
  final SuggestionReason reason;
  final Map<String, dynamic> factors;
  final DateTime createdAt;
  final bool isAccepted;
  final DateTime? acceptedAt;

  const SmartAppointmentSuggestion({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.suggestedTime,
    required this.alternativeTimes,
    required this.priority,
    required this.reason,
    required this.factors,
    required this.createdAt,
    required this.isAccepted,
    this.acceptedAt,
  });

  factory SmartAppointmentSuggestion.fromJson(Map<String, dynamic> json) => _$SmartAppointmentSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$SmartAppointmentSuggestionToJson(this);
}

enum SuggestionReason {
  clientPreference,
  therapistAvailability,
  optimalTiming,
  followUpSchedule,
  emergencySlot,
  maintenanceWindow,
  seasonalPattern
}

// ===== RANDEVU ANALİTİĞİ =====

@JsonSerializable()
class AppointmentAnalytics {
  final String id;
  final String therapistId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int noShowAppointments;
  final double completionRate;
  final double cancellationRate;
  final double noShowRate;
  final Map<String, double> hourlyDistribution;
  final Map<String, double> dailyDistribution;
  final Map<String, double> monthlyTrends;
  final List<AppointmentPattern> patterns;
  final List<AppointmentInsight> insights;

  const AppointmentAnalytics({
    required this.id,
    required this.therapistId,
    required this.startDate,
    required this.endDate,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.noShowAppointments,
    required this.completionRate,
    required this.cancellationRate,
    required this.noShowRate,
    required this.hourlyDistribution,
    required this.dailyDistribution,
    required this.monthlyTrends,
    required this.patterns,
    required this.insights,
  });

  factory AppointmentAnalytics.fromJson(Map<String, dynamic> json) => _$AppointmentAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentAnalyticsToJson(this);
}

@JsonSerializable()
class AppointmentPattern {
  final String id;
  final PatternType type;
  final String description;
  final double frequency;
  final Map<String, dynamic> data;
  final DateTime firstObserved;
  final DateTime lastObserved;

  const AppointmentPattern({
    required this.id,
    required this.type,
    required this.description,
    required this.frequency,
    required this.data,
    required this.firstObserved,
    required this.lastObserved,
  });

  factory AppointmentPattern.fromJson(Map<String, dynamic> json) => _$AppointmentPatternFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentPatternToJson(this);
}

enum PatternType {
  timePreference,
  cancellationPattern,
  reschedulePattern,
  noShowPattern,
  seasonalVariation,
  clientBehavior,
  therapistAvailability
}

@JsonSerializable()
class AppointmentInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final InsightSeverity severity;
  final Map<String, dynamic> data;
  final List<String> recommendations;
  final DateTime createdAt;
  final bool isActioned;

  const AppointmentInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.data,
    required this.recommendations,
    required this.isActioned,
  });

  factory AppointmentInsight.fromJson(Map<String, dynamic> json) => _$AppointmentInsightFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentInsightToJson(this);
}

enum InsightType {
  performance,
  efficiency,
  clientSatisfaction,
  revenue,
  scheduling,
  resourceUtilization,
  risk
}

enum InsightSeverity {
  low,
  medium,
  high,
  critical
}

// ===== KURUM MESAJLAŞMA MODELLERİ =====

@JsonSerializable()
class InstitutionalMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final List<String> recipientIds;
  final List<String> recipientNames;
  final MessageType type;
  final String subject;
  final String content;
  final MessagePriority priority;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? readAt;
  final List<MessageAttachment> attachments;
  final List<MessageReaction> reactions;
  final List<MessageReply> replies;
  final Map<String, dynamic>? metadata;
  final bool isAIProcessed;

  const InstitutionalMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.recipientIds,
    required this.recipientNames,
    required this.type,
    required this.subject,
    required this.content,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.readAt,
    required this.attachments,
    required this.reactions,
    required this.replies,
    this.metadata,
    required this.isAIProcessed,
  });

  factory InstitutionalMessage.fromJson(Map<String, dynamic> json) => _$InstitutionalMessageFromJson(json);
  Map<String, dynamic> toJson() => _$InstitutionalMessageToJson(this);
}

enum MessageType {
  general,
  announcement,
  meeting,
  task,
  question,
  feedback,
  emergency,
  reminder,
  report
}

enum MessagePriority {
  low,
  normal,
  high,
  urgent
}

enum MessageStatus {
  draft,
  sent,
  delivered,
  read,
  archived,
  deleted
}

@JsonSerializable()
class MessageAttachment {
  final String id;
  final String name;
  final String type;
  final int size;
  final String url;
  final DateTime uploadedAt;
  final String uploadedBy;

  const MessageAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) => _$MessageAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$MessageAttachmentToJson(this);
}

@JsonSerializable()
class MessageReaction {
  final String id;
  final String userId;
  final String userName;
  final ReactionType type;
  final DateTime createdAt;

  const MessageReaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) => _$MessageReactionFromJson(json);
  Map<String, dynamic> toJson() => _$MessageReactionToJson(this);
}

enum ReactionType {
  like,
  love,
  laugh,
  wow,
  sad,
  angry,
  thumbsUp,
  thumbsDown
}

@JsonSerializable()
class MessageReply {
  final String id;
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final List<MessageReaction> reactions;
  final List<MessageReply> nestedReplies;

  const MessageReply({
    required this.id,
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    required this.reactions,
    required this.nestedReplies,
  });

  factory MessageReply.fromJson(Map<String, dynamic> json) => _$MessageReplyFromJson(json);
  Map<String, dynamic> toJson() => _$MessageReplyToJson(this);
}

// ===== AI TOPLANTI ÖZETLERİ =====

@JsonSerializable()
class AIMeetingSummary {
  final String id;
  final String meetingId;
  final String title;
  final DateTime meetingDate;
  final List<String> participants;
  final String summary;
  final List<String> keyPoints;
  final List<String> actionItems;
  final List<String> decisions;
  final Map<String, dynamic> sentiment;
  final double confidence;
  final DateTime createdAt;
  final String generatedBy;

  const AIMeetingSummary({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.meetingDate,
    required this.participants,
    required this.summary,
    required this.keyPoints,
    required this.actionItems,
    required this.decisions,
    required this.sentiment,
    required this.confidence,
    required this.createdAt,
    required this.generatedBy,
  });

  factory AIMeetingSummary.fromJson(Map<String, dynamic> json) => _$AIMeetingSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$AIMeetingSummaryToJson(this);
}

// ===== RANDEVU OPTİMİZASYONU =====

@JsonSerializable()
class AppointmentOptimization {
  final String id;
  final String therapistId;
  final DateTime date;
  final List<OptimizationSuggestion> suggestions;
  final Map<String, dynamic> constraints;
  final double efficiencyScore;
  final DateTime createdAt;

  const AppointmentOptimization({
    required this.id,
    required this.therapistId,
    required this.date,
    required this.suggestions,
    required this.constraints,
    required this.efficiencyScore,
    required this.createdAt,
  });

  factory AppointmentOptimization.fromJson(Map<String, dynamic> json) => _$AppointmentOptimizationFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentOptimizationToJson(this);
}

@JsonSerializable()
class OptimizationSuggestion {
  final String id;
  final OptimizationType type;
  final String description;
  final double impact;
  final List<String> actions;
  final Map<String, dynamic> data;

  const OptimizationSuggestion({
    required this.id,
    required this.type,
    required this.description,
    required this.impact,
    required this.actions,
    required this.data,
  });

  factory OptimizationSuggestion.fromJson(Map<String, dynamic> json) => _$OptimizationSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$OptimizationSuggestionToJson(this);
}

enum OptimizationType {
  timeSlot,
  duration,
  sequence,
  resource,
  capacity,
  routing
}
