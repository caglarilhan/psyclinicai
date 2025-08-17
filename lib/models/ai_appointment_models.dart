import 'package:json_annotation/json_annotation.dart';
import '../services/ai_appointment_service.dart';

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
    required this.createdAt,
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

// ===== NO-SHOW TAHMİNİ =====

@JsonSerializable()
class NoShowPrediction {
  final String id;
  final String appointmentId;
  final String clientName;
  final DateTime appointmentTime;
  final bool predictedNoShow;
  final bool actualNoShow;
  final double confidence;
  final DateTime predictionDate;
  final Map<String, dynamic> features;

  const NoShowPrediction({
    required this.id,
    required this.appointmentId,
    required this.clientName,
    required this.appointmentTime,
    required this.predictedNoShow,
    required this.actualNoShow,
    required this.confidence,
    required this.predictionDate,
    required this.features,
  });

  factory NoShowPrediction.fromJson(Map<String, dynamic> json) => _$NoShowPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$NoShowPredictionToJson(this);
}

// ===== RANDEVU OPTİMİZASYONU =====

@JsonSerializable()
class AppointmentOptimization {
  final String id;
  final String title;
  final OptimizationType type;
  final double estimatedBenefit;
  final ImplementationDifficulty implementationDifficulty;
  final double aiConfidence;
  final String description;
  final List<String> steps;
  final DateTime createdAt;

  const AppointmentOptimization({
    required this.id,
    required this.title,
    required this.type,
    required this.estimatedBenefit,
    required this.implementationDifficulty,
    required this.aiConfidence,
    required this.description,
    required this.steps,
    required this.createdAt,
  });

  factory AppointmentOptimization.fromJson(Map<String, dynamic> json) => _$AppointmentOptimizationFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentOptimizationToJson(this);
}

enum OptimizationType {
  timeSlot,
  duration,
  therapist,
  location
}

enum ImplementationDifficulty {
  easy,
  medium,
  hard
}

// ===== DANIŞAN TERCİHLERİ =====

@JsonSerializable()
class ClientPreference {
  final String id;
  final String clientId;
  final String clientName;
  final String preferredTime;
  final String preferredTherapist;
  final double preferenceStrength;
  final List<String> preferredDays;
  final String preferredLocation;
  final DateTime lastUpdated;

  const ClientPreference({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.preferredTime,
    required this.preferredTherapist,
    required this.preferenceStrength,
    required this.preferredDays,
    required this.preferredLocation,
    required this.lastUpdated,
  });

  factory ClientPreference.fromJson(Map<String, dynamic> json) => _$ClientPreferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ClientPreferenceToJson(this);
}

// ===== AI SERVİS METODLARI =====

extension AIAppointmentServiceExtension on AIAppointmentService {
  Future<List<NoShowPrediction>> getNoShowPredictions() async {
    // Simüle edilmiş no-show tahminleri
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      NoShowPrediction(
        id: '1',
        appointmentId: 'apt_001',
        clientName: 'Ahmet Yılmaz',
        appointmentTime: DateTime.now().add(const Duration(days: 1)),
        predictedNoShow: true,
        actualNoShow: true,
        confidence: 0.89,
        predictionDate: DateTime.now().subtract(const Duration(hours: 2)),
        features: {
          'previousNoShows': 2,
          'lastMinuteCancellations': 1,
          'clientEngagement': 0.3,
        },
      ),
      NoShowPrediction(
        id: '2',
        appointmentId: 'apt_002',
        clientName: 'Ayşe Demir',
        appointmentTime: DateTime.now().add(const Duration(days: 2)),
        predictedNoShow: false,
        actualNoShow: false,
        confidence: 0.92,
        predictionDate: DateTime.now().subtract(const Duration(hours: 4)),
        features: {
          'previousNoShows': 0,
          'lastMinuteCancellations': 0,
          'clientEngagement': 0.9,
        },
      ),
      NoShowPrediction(
        id: '3',
        appointmentId: 'apt_003',
        clientName: 'Mehmet Kaya',
        appointmentTime: DateTime.now().add(const Duration(days: 1)),
        predictedNoShow: true,
        actualNoShow: false,
        confidence: 0.76,
        predictionDate: DateTime.now().subtract(const Duration(hours: 3)),
        features: {
          'previousNoShows': 1,
          'lastMinuteCancellations': 0,
          'clientEngagement': 0.6,
        },
      ),
      NoShowPrediction(
        id: '4',
        appointmentId: 'apt_004',
        clientName: 'Fatma Özkan',
        appointmentTime: DateTime.now().add(const Duration(days: 3)),
        predictedNoShow: false,
        actualNoShow: false,
        confidence: 0.94,
        predictionDate: DateTime.now().subtract(const Duration(hours: 5)),
        features: {
          'previousNoShows': 0,
          'lastMinuteCancellations': 0,
          'clientEngagement': 0.95,
        },
      ),
      NoShowPrediction(
        id: '5',
        appointmentId: 'apt_005',
        clientName: 'Ali Veli',
        appointmentTime: DateTime.now().add(const Duration(days: 1)),
        predictedNoShow: false,
        actualNoShow: true,
        confidence: 0.68,
        predictionDate: DateTime.now().subtract(const Duration(hours: 1)),
        features: {
          'previousNoShows': 0,
          'lastMinuteCancellations': 1,
          'clientEngagement': 0.7,
        },
      ),
    ];
  }

  Future<List<AppointmentOptimization>> getAppointmentOptimizations() async {
    // Simüle edilmiş optimizasyon önerileri
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      AppointmentOptimization(
        id: '1',
        title: 'Sabah Randevularını Artır',
        type: OptimizationType.timeSlot,
        estimatedBenefit: 0.25,
        implementationDifficulty: ImplementationDifficulty.easy,
        aiConfidence: 0.87,
        description: 'Sabah saatlerinde no-show oranı %15 daha düşük',
        steps: [
          'Sabah 9-11 arası boş slotları tespit et',
          'Yüksek no-show riskli danışanları sabah saatlerine yönlendir',
          'Sabah randevuları için %10 indirim uygula',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppointmentOptimization(
        id: '2',
        title: 'Randevu Sürelerini Optimize Et',
        type: OptimizationType.duration,
        estimatedBenefit: 0.18,
        implementationDifficulty: ImplementationDifficulty.medium,
        aiConfidence: 0.79,
        description: 'Danışan ihtiyaçlarına göre esnek süreler',
        steps: [
          'Danışan geçmişini analiz et',
          'Optimal randevu süresini hesapla',
          'Terapist onayı al ve uygula',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      AppointmentOptimization(
        id: '3',
        title: 'Terapist Eşleştirmesini İyileştir',
        type: OptimizationType.therapist,
        estimatedBenefit: 0.32,
        implementationDifficulty: ImplementationDifficulty.hard,
        aiConfidence: 0.91,
        description: 'Danışan-terapist uyumunu maksimize et',
        steps: [
          'Danışan tercihlerini analiz et',
          'Terapist uzmanlık alanlarını değerlendir',
          'Uyum skorunu hesapla ve eşleştir',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppointmentOptimization(
        id: '4',
        title: 'Lokasyon Bazlı Optimizasyon',
        type: OptimizationType.location,
        estimatedBenefit: 0.12,
        implementationDifficulty: ImplementationDifficulty.easy,
        aiConfidence: 0.73,
        description: 'Danışan konumuna göre en yakın merkezi öner',
        steps: [
          'Danışan konumunu tespit et',
          'En yakın merkezleri listele',
          'Ulaşım kolaylığını değerlendir',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  Future<List<ClientPreference>> getClientPreferences() async {
    // Simüle edilmiş danışan tercihleri
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ClientPreference(
        id: '1',
        clientId: 'client_001',
        clientName: 'Ahmet Yılmaz',
        preferredTime: '14:00',
        preferredTherapist: 'Dr. Ayşe Demir',
        preferenceStrength: 0.85,
        preferredDays: ['Pazartesi', 'Çarşamba', 'Cuma'],
        preferredLocation: 'Merkez Şube',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ClientPreference(
        id: '2',
        clientId: 'client_002',
        clientName: 'Ayşe Demir',
        preferredTime: '10:00',
        preferredTherapist: 'Dr. Mehmet Kaya',
        preferenceStrength: 0.92,
        preferredDays: ['Salı', 'Perşembe'],
        preferredLocation: 'Kadıköy Şube',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ClientPreference(
        id: '3',
        clientId: 'client_003',
        clientName: 'Mehmet Kaya',
        preferredTime: '16:00',
        preferredTherapist: 'Dr. Fatma Özkan',
        preferenceStrength: 0.78,
        preferredDays: ['Pazartesi', 'Cuma'],
        preferredLocation: 'Beşiktaş Şube',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ClientPreference(
        id: '4',
        clientId: 'client_004',
        clientName: 'Fatma Özkan',
        preferredTime: '11:00',
        preferredTherapist: 'Dr. Ali Veli',
        preferenceStrength: 0.65,
        preferredDays: ['Çarşamba', 'Cumartesi'],
        preferredLocation: 'Merkez Şube',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  Future<List<AppointmentOptimization>> autoOptimizeAppointments() async {
    // Otomatik optimizasyon simülasyonu
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final optimizations = await getAppointmentOptimizations();
    
    // AI algoritması ile optimizasyonları güncelle
    for (var optimization in optimizations) {
      // Tahmini faydayı artır
      optimization = AppointmentOptimization(
        id: optimization.id,
        title: optimization.title,
        type: optimization.type,
        estimatedBenefit: optimization.estimatedBenefit * 1.1, // %10 artış
        implementationDifficulty: optimization.implementationDifficulty,
        aiConfidence: optimization.aiConfidence,
        description: optimization.description,
        steps: optimization.steps,
        createdAt: DateTime.now(),
      );
    }
    
    return optimizations;
  }
}
