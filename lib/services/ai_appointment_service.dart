import '../models/ai_appointment_models.dart';
import '../utils/ai_logger.dart';

class AIAppointmentService {
  static final AIAppointmentService _instance = AIAppointmentService._internal();
  factory AIAppointmentService() => _instance;
  AIAppointmentService._internal();

  final AILogger _logger = AILogger();
  
  List<AIAppointmentPrediction> _predictions = [];
  List<AIAppointmentReminder> _reminders = [];
  List<SmartAppointmentSuggestion> _suggestions = [];
  List<AppointmentAnalytics> _analytics = [];
  List<InstitutionalMessage> _messages = [];
  List<AIMeetingSummary> _meetingSummaries = [];

  Future<void> initialize() async {
    _logger.info('AIAppointmentService initializing...', context: 'AIAppointmentService');
    await _loadMockData();
    _logger.info('AIAppointmentService initialized successfully', context: 'AIAppointmentService');
  }

  // ===== AI RANDEVU TAHMİNLERİ =====
  
  Future<AIAppointmentPrediction> predictAppointmentOutcome({
    required String appointmentId,
    required String clientId,
    required String therapistId,
    required Map<String, dynamic> clientHistory,
    required Map<String, dynamic> appointmentData,
  }) async {
    _logger.info('Predicting appointment outcome for: $appointmentId', context: 'AIAppointmentService');
    
    // AI tahmin algoritması (şimdilik mock)
    final prediction = _generatePrediction(clientHistory, appointmentData);
    
    final aiPrediction = AIAppointmentPrediction(
      id: _generateId(),
      appointmentId: appointmentId,
      clientId: clientId,
      therapistId: therapistId,
      type: prediction['type'],
      confidence: prediction['confidence'],
      prediction: prediction['prediction'],
      factors: prediction['factors'],
      createdAt: DateTime.now(),
      isActive: true,
      notes: prediction['notes'],
    );
    
    _predictions.add(aiPrediction);
    _logger.info('Prediction generated: ${aiPrediction.type}', context: 'AIAppointmentService');
    
    return aiPrediction;
  }

  Map<String, dynamic> _generatePrediction(
    Map<String, dynamic> clientHistory,
    Map<String, dynamic> appointmentData,
  ) {
    // Mock AI tahmin algoritması
    final noShowRate = clientHistory['noShowRate'] ?? 0.1;
    final cancellationRate = clientHistory['cancellationRate'] ?? 0.05;
    final lateArrivalRate = clientHistory['lateArrivalRate'] ?? 0.15;
    
    if (noShowRate > 0.3) {
      return {
        'type': AppointmentPredictionType.noShow,
        'confidence': 0.85,
        'prediction': 'Yüksek no-show riski',
        'factors': {
          'noShowRate': noShowRate,
          'previousNoShows': clientHistory['previousNoShows'] ?? 0,
          'lastMinuteCancellations': clientHistory['lastMinuteCancellations'] ?? 0,
        },
        'notes': 'Bu danışan için özel hatırlatıcılar gerekli',
      };
    } else if (cancellationRate > 0.2) {
      return {
        'type': AppointmentPredictionType.cancellation,
        'confidence': 0.75,
        'prediction': 'İptal riski mevcut',
        'factors': {
          'cancellationRate': cancellationRate,
          'rescheduleFrequency': clientHistory['rescheduleFrequency'] ?? 0,
        },
        'notes': 'Esnek randevu seçenekleri önerilebilir',
      };
    } else if (lateArrivalRate > 0.25) {
      return {
        'type': AppointmentPredictionType.lateArrival,
        'confidence': 0.70,
        'prediction': 'Geç gelme olasılığı',
        'factors': {
          'lateArrivalRate': lateArrivalRate,
          'averageDelay': clientHistory['averageDelay'] ?? 0,
        },
        'notes': 'Randevu saatinden 15 dakika önce hatırlatma',
      };
    } else {
      return {
        'type': AppointmentPredictionType.regularClient,
        'confidence': 0.90,
        'prediction': 'Normal seyir bekleniyor',
        'factors': {
          'reliabilityScore': 0.95,
          'attendanceRate': 0.98,
        },
        'notes': 'Standart hatırlatma yeterli',
      };
    }
  }

  Future<List<AIAppointmentPrediction>> getPredictions({
    String? therapistId,
    String? clientId,
    AppointmentPredictionType? type,
  }) async {
    List<AIAppointmentPrediction> filtered = _predictions;
    
    if (therapistId != null) {
      filtered = filtered.where((p) => p.therapistId == therapistId).toList();
    }
    
    if (clientId != null) {
      filtered = filtered.where((p) => p.clientId == clientId).toList();
    }
    
    if (type != null) {
      filtered = filtered.where((p) => p.type == type).toList();
    }
    
    return filtered;
  }

  // ===== AI HATIRLATICILAR =====
  
  Future<AIAppointmentReminder> createAIOptimizedReminder({
    required String appointmentId,
    required String clientId,
    required String therapistId,
    required ReminderType type,
    required DateTime appointmentTime,
    required Map<String, dynamic> clientPreferences,
  }) async {
    _logger.info('Creating AI-optimized reminder for: $appointmentId', context: 'AIAppointmentService');
    
    // AI ile optimal hatırlatma zamanı ve kanalı belirleme
    final optimalTime = _calculateOptimalReminderTime(appointmentTime, clientPreferences);
    final optimalChannel = _determineOptimalChannel(clientPreferences);
    final message = _generatePersonalizedMessage(type, clientPreferences);
    
    final reminder = AIAppointmentReminder(
      id: _generateId(),
      appointmentId: appointmentId,
      clientId: clientId,
      therapistId: therapistId,
      type: type,
      channel: optimalChannel,
      scheduledTime: optimalTime,
      status: ReminderStatus.scheduled,
      message: message,
      isAIOptimized: true,
    );
    
    _reminders.add(reminder);
    _logger.info('AI reminder created: ${reminder.type}', context: 'AIAppointmentService');
    
    return reminder;
  }

  DateTime _calculateOptimalReminderTime(
    DateTime appointmentTime,
    Map<String, dynamic> clientPreferences,
  ) {
    final preferredAdvanceNotice = clientPreferences['preferredAdvanceNotice'] ?? 24; // saat
    final timezone = clientPreferences['timezone'] ?? 'Europe/Istanbul';
    final workingHours = clientPreferences['workingHours'] ?? {'start': 9, 'end': 18};
    
    // Randevudan önceki optimal zaman
    final reminderTime = appointmentTime.subtract(Duration(hours: preferredAdvanceNotice));
    
    // Çalışma saatleri içinde olup olmadığını kontrol et
    final hour = reminderTime.hour;
    if (hour < workingHours['start'] || hour > workingHours['end']) {
      // Çalışma saatleri dışındaysa, bir sonraki çalışma saatine ayarla
      return DateTime(
        reminderTime.year,
        reminderTime.month,
        reminderTime.day,
        workingHours['start'],
        0,
        0,
      );
    }
    
    return reminderTime;
  }

  ReminderChannel _determineOptimalChannel(Map<String, dynamic> clientPreferences) {
    final preferredChannels = clientPreferences['preferredChannels'] ?? ['email'];
    final responseRates = clientPreferences['responseRates'] ?? {};
    
    // En yüksek yanıt oranına sahip kanalı seç
    ReminderChannel bestChannel = ReminderChannel.email;
    double bestRate = 0.0;
    
    for (final channel in preferredChannels) {
      final rate = responseRates[channel] ?? 0.0;
      if (rate > bestRate) {
        bestRate = rate;
        bestChannel = _stringToReminderChannel(channel);
      }
    }
    
    return bestChannel;
  }

  ReminderChannel _stringToReminderChannel(String channel) {
    switch (channel.toLowerCase()) {
      case 'sms':
        return ReminderChannel.sms;
      case 'email':
        return ReminderChannel.email;
      case 'push':
        return ReminderChannel.pushNotification;
      case 'whatsapp':
        return ReminderChannel.whatsapp;
      case 'call':
        return ReminderChannel.phoneCall;
      default:
        return ReminderChannel.email;
    }
  }

  String _generatePersonalizedMessage(
    ReminderType type,
    Map<String, dynamic> clientPreferences,
  ) {
    final clientName = clientPreferences['name'] ?? 'Değerli Danışan';
    final preferredLanguage = clientPreferences['preferredLanguage'] ?? 'tr';
    
    switch (type) {
      case ReminderType.appointmentConfirmation:
        return '$clientName, randevunuz onaylanmıştır. Detaylar için uygulamayı kontrol edin.';
      case ReminderType.appointmentReminder:
        return '$clientName, yarın saat ${clientPreferences['appointmentTime']} randevunuz var. Hazırlık yapmayı unutmayın.';
      case ReminderType.preparationInstructions:
        return '$clientName, randevunuz için özel hazırlık talimatları: ${clientPreferences['instructions'] ?? 'Rahat kıyafetler giyin.'}';
      case ReminderType.followUpReminder:
        return '$clientName, takip randevunuz yaklaşıyor. Güncel durumunuzu değerlendirmek için hazır olun.';
      default:
        return '$clientName, randevunuzla ilgili önemli bilgi. Lütfen uygulamayı kontrol edin.';
    }
  }

  Future<List<AIAppointmentReminder>> getReminders({
    String? therapistId,
    String? clientId,
    ReminderStatus? status,
  }) async {
    List<AIAppointmentReminder> filtered = _reminders;
    
    if (therapistId != null) {
      filtered = filtered.where((r) => r.therapistId == therapistId).toList();
    }
    
    if (clientId != null) {
      filtered = filtered.where((r) => r.clientId == clientId).toList();
    }
    
    if (status != null) {
      filtered = filtered.where((r) => r.status == status).toList();
    }
    
    return filtered;
  }

  // ===== AKILLI RANDEVU ÖNERİLERİ =====
  
  Future<SmartAppointmentSuggestion> generateSmartSuggestion({
    required String clientId,
    required String therapistId,
    required Map<String, dynamic> clientPreferences,
    required Map<String, dynamic> therapistAvailability,
    required Map<String, dynamic> constraints,
  }) async {
    _logger.info('Generating smart appointment suggestion for: $clientId', context: 'AIAppointmentService');
    
    // AI ile optimal randevu zamanı hesaplama
    final optimalTime = _calculateOptimalAppointmentTime(
      clientPreferences,
      therapistAvailability,
      constraints,
    );
    
    final alternativeTimes = _generateAlternativeTimes(optimalTime, therapistAvailability);
    final priority = _calculateSuggestionPriority(clientPreferences, constraints);
    final reason = _determineSuggestionReason(clientPreferences, constraints);
    
    final suggestion = SmartAppointmentSuggestion(
      id: _generateId(),
      clientId: clientId,
      therapistId: therapistId,
      suggestedTime: optimalTime,
      alternativeTimes: alternativeTimes,
      priority: priority,
      reason: reason,
      factors: {
        'clientPreferences': clientPreferences,
        'therapistAvailability': therapistAvailability,
        'constraints': constraints,
      },
      createdAt: DateTime.now(),
      isAccepted: false,
    );
    
    _suggestions.add(suggestion);
    _logger.info('Smart suggestion generated: ${suggestion.reason}', context: 'AIAppointmentService');
    
    return suggestion;
  }

  DateTime _calculateOptimalAppointmentTime(
    Map<String, dynamic> clientPreferences,
    Map<String, dynamic> therapistAvailability,
    Map<String, dynamic> constraints,
  ) {
    final preferredTime = clientPreferences['preferredTime'] ?? '09:00';
    final preferredDay = clientPreferences['preferredDay'] ?? 'monday';
    final timezone = clientPreferences['timezone'] ?? 'Europe/Istanbul';
    
    // Şu anki tarihten itibaren en yakın uygun zamanı bul
    final now = DateTime.now();
    final daysToAdd = _getDaysToAdd(preferredDay);
    final targetDate = now.add(Duration(days: daysToAdd));
    
    final timeParts = preferredTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
  }

  int _getDaysToAdd(String preferredDay) {
    final days = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };
    
    final currentDay = DateTime.now().weekday;
    final targetDay = days[preferredDay.toLowerCase()] ?? 1;
    
    if (targetDay > currentDay) {
      return targetDay - currentDay;
    } else {
      return 7 - currentDay + targetDay;
    }
  }

  List<DateTime> _generateAlternativeTimes(
    DateTime optimalTime,
    Map<String, dynamic> therapistAvailability,
  ) {
    final alternatives = <DateTime>[];
    final slots = therapistAvailability['availableSlots'] ?? [];
    
    for (final slot in slots.take(5)) {
      if (slot != optimalTime) {
        alternatives.add(slot);
      }
    }
    
    return alternatives;
  }

  double _calculateSuggestionPriority(
    Map<String, dynamic> clientPreferences,
    Map<String, dynamic> constraints,
  ) {
    double priority = 0.5;
    
    // Aciliyet faktörü
    if (constraints['urgency'] == 'high') priority += 0.3;
    if (constraints['urgency'] == 'critical') priority += 0.5;
    
    // Danışan önceliği
    if (clientPreferences['priority'] == 'high') priority += 0.2;
    if (clientPreferences['priority'] == 'vip') priority += 0.3;
    
    // Takip randevusu
    if (constraints['isFollowUp'] == true) priority += 0.1;
    
    return priority.clamp(0.0, 1.0);
  }

  SuggestionReason _determineSuggestionReason(
    Map<String, dynamic> clientPreferences,
    Map<String, dynamic> constraints,
  ) {
    if (constraints['isFollowUp'] == true) {
      return SuggestionReason.followUpSchedule;
    } else if (constraints['urgency'] == 'critical') {
      return SuggestionReason.emergencySlot;
    } else if (clientPreferences['hasPreference'] == true) {
      return SuggestionReason.clientPreference;
    } else {
      return SuggestionReason.optimalTiming;
    }
  }

  Future<List<SmartAppointmentSuggestion>> getSuggestions({
    String? therapistId,
    String? clientId,
    bool? accepted,
  }) async {
    List<SmartAppointmentSuggestion> filtered = _suggestions;
    
    if (therapistId != null) {
      filtered = filtered.where((s) => s.therapistId == therapistId).toList();
    }
    
    if (clientId != null) {
      filtered = filtered.where((s) => s.clientId == clientId).toList();
    }
    
    if (accepted != null) {
      filtered = filtered.where((s) => s.isAccepted == accepted).toList();
    }
    
    return filtered;
  }

  // ===== RANDEVU ANALİTİĞİ =====
  
  Future<AppointmentAnalytics> generateAnalytics({
    required String therapistId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _logger.info('Generating appointment analytics for: $therapistId', context: 'AIAppointmentService');
    
    // Mock veri ile analitik oluştur
    final analytics = AppointmentAnalytics(
      id: _generateId(),
      therapistId: therapistId,
      startDate: startDate,
      endDate: endDate,
      totalAppointments: 45,
      completedAppointments: 38,
      cancelledAppointments: 5,
      noShowAppointments: 2,
      completionRate: 84.4,
      cancellationRate: 11.1,
      noShowRate: 4.4,
      hourlyDistribution: {
        '09:00': 15.6,
        '10:00': 22.2,
        '11:00': 17.8,
        '14:00': 20.0,
        '15:00': 15.6,
        '16:00': 8.9,
      },
      dailyDistribution: {
        'monday': 22.2,
        'tuesday': 20.0,
        'wednesday': 17.8,
        'thursday': 20.0,
        'friday': 20.0,
      },
      monthlyTrends: {
        '2024-01': 42,
        '2024-02': 45,
        '2024-03': 48,
      },
      patterns: _generateMockPatterns(),
      insights: _generateMockInsights(),
    );
    
    _analytics.add(analytics);
    _logger.info('Analytics generated successfully', context: 'AIAppointmentService');
    
    return analytics;
  }

  List<AppointmentPattern> _generateMockPatterns() {
    return [
      AppointmentPattern(
        id: '1',
        type: PatternType.timePreference,
        description: 'Danışanlar genellikle sabah 10:00-11:00 arası randevu tercih ediyor',
        frequency: 0.75,
        data: {'peakHour': '10:00', 'preference': 'morning'},
        firstObserved: DateTime.now().subtract(const Duration(days: 30)),
        lastObserved: DateTime.now(),
      ),
      AppointmentPattern(
        id: '2',
        type: PatternType.cancellationPattern,
        description: 'Cuma günleri iptal oranı %20 daha yüksek',
        frequency: 0.60,
        data: {'day': 'friday', 'cancellationRate': 0.20},
        firstObserved: DateTime.now().subtract(const Duration(days: 60)),
        lastObserved: DateTime.now(),
      ),
    ];
  }

  List<AppointmentInsight> _generateMockInsights() {
    return [
      AppointmentInsight(
        id: '1',
        type: InsightType.efficiency,
        title: 'Sabah 9:00-10:00 arası boş slotlar',
        description: 'Bu zaman diliminde randevu alımı düşük, kapasite artırılabilir',
        severity: InsightSeverity.medium,
        data: {'timeSlot': '09:00-10:00', 'utilization': 0.30},
        recommendations: [
          'Sabah erken randevular için indirim uygula',
          'Yeni danışanlar için bu slotları öner',
          'Çalışan saatlerini genişlet',
        ],
        createdAt: DateTime.now(),
        isActioned: false,
      ),
      AppointmentInsight(
        id: '2',
        type: InsightType.performance,
        title: 'No-show oranı %4.4 - Hedef %2',
        description: 'No-show oranı hedeflenen seviyenin üzerinde',
        severity: InsightSeverity.high,
        data: {'currentRate': 0.044, 'targetRate': 0.02},
        recommendations: [
          'AI hatırlatıcıları optimize et',
          'No-show riski yüksek danışanlar için özel protokoller',
          'Randevu onay sürecini güçlendir',
        ],
        createdAt: DateTime.now(),
        isActioned: false,
      ),
    ];
  }

  // ===== KURUM MESAJLAŞMA =====
  
  Future<InstitutionalMessage> sendMessage({
    required String senderId,
    required String senderName,
    required String senderRole,
    required List<String> recipientIds,
    required List<String> recipientNames,
    required MessageType type,
    required String subject,
    required String content,
    required MessagePriority priority,
    List<MessageAttachment>? attachments,
  }) async {
    _logger.info('Sending institutional message: $subject', context: 'AIAppointmentService');
    
    final message = InstitutionalMessage(
      id: _generateId(),
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      recipientIds: recipientIds,
      recipientNames: recipientNames,
      type: type,
      subject: subject,
      content: content,
      priority: priority,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      sentAt: DateTime.now(),
      attachments: attachments ?? [],
      reactions: [],
      replies: [],
      isAIProcessed: true,
    );
    
    _messages.add(message);
    _logger.info('Message sent successfully', context: 'AIAppointmentService');
    
    return message;
  }

  Future<List<InstitutionalMessage>> getMessages({
    String? userId,
    MessageType? type,
    MessageStatus? status,
  }) async {
    List<InstitutionalMessage> filtered = _messages;
    
    if (userId != null) {
      filtered = filtered.where((m) => 
        m.senderId == userId || m.recipientIds.contains(userId)
      ).toList();
    }
    
    if (type != null) {
      filtered = filtered.where((m) => m.type == type).toList();
    }
    
    if (status != null) {
      filtered = filtered.where((m) => m.status == status).toList();
    }
    
    return filtered;
  }

  // ===== AI TOPLANTI ÖZETLERİ =====
  
  Future<AIMeetingSummary> generateMeetingSummary({
    required String meetingId,
    required String title,
    required DateTime meetingDate,
    required List<String> participants,
    required String transcript,
    required Map<String, dynamic> context,
  }) async {
    _logger.info('Generating AI meeting summary for: $title', context: 'AIAppointmentService');
    
    // AI ile toplantı özeti oluştur (şimdilik mock)
    final summary = _generateMockMeetingSummary(transcript, context);
    
    final meetingSummary = AIMeetingSummary(
      id: _generateId(),
      meetingId: meetingId,
      title: title,
      meetingDate: meetingDate,
      participants: participants,
      summary: summary['summary'],
      keyPoints: summary['keyPoints'],
      actionItems: summary['actionItems'],
      decisions: summary['decisions'],
      sentiment: summary['sentiment'],
      confidence: summary['confidence'],
      createdAt: DateTime.now(),
      generatedBy: 'AI Assistant',
    );
    
    _meetingSummaries.add(meetingSummary);
    _logger.info('Meeting summary generated successfully', context: 'AIAppointmentService');
    
    return meetingSummary;
  }

  Map<String, dynamic> _generateMockMeetingSummary(
    String transcript,
    Map<String, dynamic> context,
  ) {
    return {
      'summary': 'Toplantıda randevu sistemi optimizasyonu, AI hatırlatıcılar ve kurum mesajlaşma özellikleri tartışıldı.',
      'keyPoints': [
        'AI destekli randevu tahminleri başarıyla test edildi',
        'Hatırlatıcı sistemi %30 daha etkili hale getirildi',
        'Kurum mesajlaşma özelliği kullanıma hazır',
      ],
      'actionItems': [
        'Randevu analitik dashboard\'ı geliştir',
        'AI model performansını izle',
        'Kullanıcı geri bildirimlerini topla',
      ],
      'decisions': [
        'AI randevu sistemi production\'a alınacak',
        'Haftalık performans raporları hazırlanacak',
      ],
      'sentiment': {
        'overall': 'positive',
        'confidence': 0.85,
        'participants': {
          'positive': 4,
          'neutral': 1,
          'negative': 0,
        },
      },
      'confidence': 0.88,
    };
  }

  Future<List<AIMeetingSummary>> getMeetingSummaries({
    String? meetingId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<AIMeetingSummary> filtered = _meetingSummaries;
    
    if (meetingId != null) {
      filtered = filtered.where((s) => s.meetingId == meetingId).toList();
    }
    
    if (startDate != null) {
      filtered = filtered.where((s) => s.meetingDate.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      filtered = filtered.where((s) => s.meetingDate.isBefore(endDate)).toList();
    }
    
    return filtered;
  }

  // ===== YARDIMCI METODLAR =====
  
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _loadMockData() async {
    // Mock predictions
    _predictions = [
      AIAppointmentPrediction(
        id: '1',
        appointmentId: 'apt1',
        clientId: 'client1',
        therapistId: 'therapist1',
        type: AppointmentPredictionType.noShow,
        confidence: 0.85,
        prediction: 'Yüksek no-show riski',
        factors: {'noShowRate': 0.4, 'previousNoShows': 3},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        notes: 'Özel hatırlatıcı gerekli',
      ),
    ];

    // Mock reminders
    _reminders = [
      AIAppointmentReminder(
        id: '1',
        appointmentId: 'apt1',
        clientId: 'client1',
        therapistId: 'therapist1',
        type: ReminderType.appointmentReminder,
        channel: ReminderChannel.sms,
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        status: ReminderStatus.scheduled,
        message: 'Yarın saat 10:00 randevunuz var',
        isAIOptimized: true,
      ),
    ];

    // Mock suggestions
    _suggestions = [
      SmartAppointmentSuggestion(
        id: '1',
        clientId: 'client1',
        therapistId: 'therapist1',
        suggestedTime: DateTime.now().add(const Duration(days: 1)),
        alternativeTimes: [
          DateTime.now().add(const Duration(days: 2)),
          DateTime.now().add(const Duration(days: 3)),
        ],
        priority: 0.8,
        reason: SuggestionReason.clientPreference,
        factors: {'preferredTime': '10:00', 'urgency': 'medium'},
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isAccepted: false,
      ),
    ];

    // Mock messages
    _messages = [
      InstitutionalMessage(
        id: '1',
        senderId: 'therapist1',
        senderName: 'Dr. Ayşe Demir',
        senderRole: 'therapist',
        recipientIds: ['therapist2', 'therapist3'],
        recipientNames: ['Dr. Mehmet Kaya', 'Dr. Fatma Öz'],
        type: MessageType.announcement,
        subject: 'AI Randevu Sistemi Güncellemesi',
        content: 'Yeni AI özellikleri kullanıma alındı. Test etmek için lütfen uygulamayı güncelleyin.',
        priority: MessagePriority.high,
        status: MessageStatus.sent,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        attachments: [],
        reactions: [],
        replies: [],
        isAIProcessed: true,
      ),
    ];
  }
}
