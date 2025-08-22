import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SmartNotificationsService {
  static const String _notificationsKey = 'smart_notifications';
  final StreamController<SmartNotification> _notificationStreamController = 
      StreamController<SmartNotification>.broadcast();
  
  // Singleton pattern
  static final SmartNotificationsService _instance = SmartNotificationsService._internal();
  factory SmartNotificationsService() => _instance;
  SmartNotificationsService._internal();

  // Get notification stream
  Stream<SmartNotification> get notificationStream => _notificationStreamController.stream;

  // Send smart notification
  Future<void> sendSmartNotification(SmartNotification notification) async {
    // Add to stream
    _notificationStreamController.add(notification);
    
    // Save to local storage
    await _saveNotification(notification);
    
    // In real implementation, this would send push notification
    print('Smart notification sent: ${notification.title}');
  }

  // Generate smart notification based on context
  Future<SmartNotification> generateSmartNotification({
    required String patientId,
    required String clinicianId,
    required NotificationContext context,
    required Map<String, dynamic> data,
  }) async {
    final notification = await _analyzeContextAndGenerate(
      patientId: patientId,
      clinicianId: clinicianId,
      context: context,
      data: data,
    );
    
    return notification;
  }

  // Analyze context and generate appropriate notification
  Future<SmartNotification> _analyzeContextAndGenerate({
    required String patientId,
    required String clinicianId,
    required NotificationContext context,
    required Map<String, dynamic> data,
  }) async {
    final random = Random();
    final timestamp = DateTime.now();
    
    switch (context) {
      case NotificationContext.crisis:
        return _generateCrisisNotification(patientId, clinicianId, data, timestamp);
      
      case NotificationContext.medication:
        return _generateMedicationNotification(patientId, clinicianId, data, timestamp);
      
      case NotificationContext.appointment:
        return _generateAppointmentNotification(patientId, clinicianId, data, timestamp);
      
      case NotificationContext.progress:
        return _generateProgressNotification(patientId, clinicianId, data, timestamp);
      
      case NotificationContext.compliance:
        return _generateComplianceNotification(patientId, clinicianId, data, timestamp);
      
      case NotificationContext.aiInsight:
        return _generateAIInsightNotification(patientId, clinicianId, data, timestamp);
      
      default:
        return _generateGeneralNotification(patientId, clinicianId, data, timestamp);
    }
  }

  // Generate crisis notification
  SmartNotification _generateCrisisNotification(
    String patientId,
    String clinicianId,
    Map<String, dynamic> data,
    DateTime timestamp,
  ) {
    final crisisLevel = data['crisis_level'] ?? 'high';
    final crisisType = data['crisis_type'] ?? 'general';
    
    String title, message, priority;
    
    switch (crisisLevel) {
      case 'critical':
        title = '🚨 CRISIS ALERT: Immediate Action Required';
        message = 'Patient ${data['patient_name'] ?? 'Unknown'} requires immediate attention. '
                 'Crisis type: $crisisType. Please respond immediately.';
        priority = 'critical';
        break;
      case 'high':
        title = '⚠️ High Risk Alert';
        message = 'Patient ${data['patient_name'] ?? 'Unknown'} shows high risk indicators. '
                 'Please review and respond promptly.';
        priority = 'high';
        break;
      default:
        title = '⚠️ Risk Alert';
        message = 'Patient ${data['patient_name'] ?? 'Unknown'} requires attention. '
                 'Please review at your earliest convenience.';
        priority = 'medium';
    }
    
    return SmartNotification(
      id: 'crisis_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      title: title,
      message: message,
      context: NotificationContext.crisis,
      priority: priority,
      timestamp: timestamp,
      data: data,
      requiresAction: true,
      actionRequired: 'Immediate response required',
    );
  }

  // Generate medication notification
  SmartNotification _generateMedicationNotification(
    String patientId,
    String clinicianId,
    Map<String, dynamic> data,
    DateTime timestamp,
  ) {
    final medicationName = data['medication_name'] ?? 'Unknown medication';
    final action = data['action'] ?? 'review';
    
    String title, message;
    
    switch (action) {
      case 'refill':
        title = '💊 Medication Refill Required';
        message = 'Patient ${data['patient_name'] ?? 'Unknown'} needs refill for $medicationName. '
                 'Please review and authorize refill.';
        break;
      case 'review':
        title = '💊 Medication Review Required';
        message = 'Patient ${data['patient_name'] ?? 'Unknown'} medication $medicationName '
                 'requires review. Please assess effectiveness and side effects.';
        break;
      case 'interaction':
        title = '⚠️ Drug Interaction Alert';
        message = 'Potential drug interaction detected for patient ${data['patient_name'] ?? 'Unknown'}. '
                 'Please review medication combination.';
        break;
      default:
        title = '💊 Medication Update';
        message = 'Medication update for patient ${data['patient_name'] ?? 'Unknown'}. '
                 'Please review changes.';
    }
    
    return SmartNotification(
      id: 'med_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      title: title,
      message: message,
      context: NotificationContext.medication,
      priority: 'medium',
      timestamp: timestamp,
      data: data,
      requiresAction: true,
      actionRequired: 'Review and respond',
    );
  }

  // Generate appointment notification
  SmartNotification _generateAppointmentNotification(
    String patientId,
    String clinicianId,
    Map<String, dynamic> data,
    DateTime timestamp,
  ) {
    final appointmentTime = data['appointment_time'];
    final appointmentType = data['appointment_type'] ?? 'session';
    
    String title, message;
    
    if (appointmentTime != null) {
      final timeUntil = appointmentTime.difference(DateTime.now());
      if (timeUntil.inHours < 1) {
        title = '⏰ Upcoming Appointment';
        message = 'Appointment with ${data['patient_name'] ?? 'patient'} in ${timeUntil.inMinutes} minutes. '
                 'Type: $appointmentType. Please prepare.';
      } else if (timeUntil.inHours < 24) {
        title = '📅 Tomorrow\'s Appointment';
        message = 'Appointment with ${data['patient_name'] ?? 'patient'} tomorrow at ${appointmentTime.hour}:${appointmentTime.minute}. '
                 'Type: $appointmentType.';
      } else {
        title = '📅 Upcoming Appointment';
        message = 'Appointment with ${data['patient_name'] ?? 'patient'} on ${appointmentTime.day}/${appointmentTime.month}. '
                 'Type: $appointmentType.';
      }
    } else {
      title = '📅 Appointment Update';
      message = 'Appointment update for ${data['patient_name'] ?? 'patient'}. '
               'Type: $appointmentType. Please review details.';
    }
    
    return SmartNotification(
      id: 'apt_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      title: title,
      message: message,
      context: NotificationContext.appointment,
      priority: 'low',
      timestamp: timestamp,
      data: data,
      requiresAction: false,
    );
  }

  // Generate progress notification
  SmartNotification _generateProgressNotification(
    String patientId,
    String clinicianId,
    Map<String, dynamic> data,
    DateTime timestamp,
  ) {
    final progressType = data['progress_type'] ?? 'general';
    final progressValue = data['progress_value'] ?? 0.0;
    
    String title, message;
    
    switch (progressType) {
      case 'improvement':
        title = '📈 Patient Progress Update';
        message = 'Great news! Patient ${data['patient_name'] ?? 'Unknown'} shows '
                 '${(progressValue * 100).round()}% improvement. Keep up the excellent work!';
        break;
      case 'milestone':
        title = '🎯 Milestone Achieved';
        message = 'Patient ${data['patient_name'] ?? 'Unknown'} has reached an important milestone. '
                 'Please review and celebrate progress.';
        break;
      case 'concern':
        title = '⚠️ Progress Concern';
        message = 'Patient ${data['patient_name'] ?? 'Unknown'} progress has slowed. '
                 'Please review treatment plan and consider adjustments.';
        break;
      default:
        title = '📊 Progress Update';
        message = 'Progress update for patient ${data['patient_name'] ?? 'Unknown'}. '
                 'Please review latest assessment results.';
    }
    
    return SmartNotification(
      id: 'prog_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      title: title,
      message: message,
      context: NotificationContext.progress,
      priority: 'medium',
      timestamp: timestamp,
      data: data,
      requiresAction: progressType == 'concern',
      actionRequired: progressType == 'concern' ? 'Review and adjust treatment' : null,
    );
  }

  // Generate compliance notification
  SmartNotification _generateComplianceNotification(
    String patientId,
    String clinicianId,
    Map<String, dynamic> data,
    DateTime timestamp,
  ) {
    final complianceType = data['compliance_type'] ?? 'general';
    final complianceLevel = data['compliance_level'] ?? 0.0;
    
    String title, message;
    
    if (complianceLevel < 0.5) {
      title = '⚠️ Low Compliance Alert';
      message = 'Patient ${data['patient_name'] ?? 'Unknown'} shows low compliance '
               '(${(complianceLevel * 100).round()}%). Please address barriers to treatment.';
    } else if (complianceLevel < 0.8) {
      title = '📋 Compliance Update';
      message = 'Patient ${data['patient_name'] ?? 'Unknown'} compliance is moderate '
               '(${(complianceLevel * 100).round()}%). Consider support strategies.';
    } else {
      title = '✅ Excellent Compliance';
      message = 'Patient ${data['patient_name'] ?? 'Unknown'} shows excellent compliance '
               '(${(complianceLevel * 100).round()}%). Great work!';
    }
    
    return SmartNotification(
      id: 'comp_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      title: title,
      message: message,
      context: NotificationContext.compliance,
      priority: complianceLevel < 0.5 ? 'high' : 'medium',
      timestamp: timestamp,
      data: data,
      requiresAction: complianceLevel < 0.5,
      actionRequired: complianceLevel < 0.5 ? 'Address compliance barriers' : null,
    );
  }

  // Generate AI insight notification
  SmartNotification _generateAIInsightNotification(
    String patientId,
    String clinicianId,
    Map<String, dynamic> data,
    DateTime timestamp,
  ) {
    final insightType = data['insight_type'] ?? 'general';
    final confidence = data['confidence'] ?? 0.0;
    
    String title, message;
    
    switch (insightType) {
      case 'crisis_prediction':
        title = '🤖 AI Crisis Prediction';
        message = 'AI analysis predicts potential crisis for patient ${data['patient_name'] ?? 'Unknown'} '
                 'with ${(confidence * 100).round()}% confidence. Please review risk factors.';
        break;
      case 'treatment_optimization':
        title = '🤖 AI Treatment Suggestion';
        message = 'AI suggests treatment optimization for patient ${data['patient_name'] ?? 'Unknown'} '
                 'with ${(confidence * 100).round()}% confidence. Please review recommendations.';
        break;
      case 'progress_prediction':
        title = '🤖 AI Progress Forecast';
        message = 'AI predicts patient ${data['patient_name'] ?? 'Unknown'} progress trajectory '
                 'with ${(confidence * 100).round()}% confidence. Please review insights.';
        break;
      default:
        title = '🤖 AI Insight Available';
        message = 'New AI insight available for patient ${data['patient_name'] ?? 'Unknown'}. '
                 'Please review analysis results.';
    }
    
    return SmartNotification(
      id: 'ai_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      title: title,
      message: message,
      context: NotificationContext.aiInsight,
      priority: insightType == 'crisis_prediction' ? 'high' : 'medium',
      timestamp: timestamp,
      data: data,
      requiresAction: true,
      actionRequired: 'Review AI insights',
    );
  }

  // Generate general notification
  SmartNotification _generateGeneralNotification(
    String patientId,
    String clinicianId,
    Map<String, dynamic> data,
    DateTime timestamp,
  ) {
    return SmartNotification(
      id: 'gen_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      title: '📋 General Update',
      message: 'Update for patient ${data['patient_name'] ?? 'Unknown'}. '
               'Please review latest information.',
      context: NotificationContext.general,
      priority: 'low',
      timestamp: timestamp,
      data: data,
      requiresAction: false,
    );
  }

  // Get notifications for a clinician
  Future<List<SmartNotification>> getNotificationsForClinician(String clinicianId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = '${_notificationsKey}_$clinicianId';
      
      final notificationsJson = prefs.getString(notificationsKey);
      if (notificationsJson == null) return [];
      
      final notifications = List<Map<String, dynamic>>.from(json.decode(notificationsJson));
      return notifications.map((json) => SmartNotification.fromJson(json)).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId, String clinicianId) async {
    try {
      final notifications = await getNotificationsForClinician(clinicianId);
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }
        return notification;
      }).toList();
      
      await _saveNotifications(updatedNotifications, clinicianId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Acknowledge notification
  Future<void> acknowledgeNotification(String notificationId, String clinicianId) async {
    try {
      final notifications = await getNotificationsForClinician(clinicianId);
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(
            isAcknowledged: true,
            acknowledgedAt: DateTime.now(),
          );
        }
        return notification;
      }).toList();
      
      await _saveNotifications(updatedNotifications, clinicianId);
    } catch (e) {
      print('Error acknowledging notification: $e');
    }
  }

  // Save notification
  Future<void> _saveNotification(SmartNotification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = '${_notificationsKey}_${notification.clinicianId}';
      
      final existingNotificationsJson = prefs.getString(notificationsKey);
      List<Map<String, dynamic>> notifications = [];
      
      if (existingNotificationsJson != null) {
        notifications = List<Map<String, dynamic>>.from(json.decode(existingNotificationsJson));
      }
      
      notifications.add(notification.toJson());
      
      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications = notifications.sublist(notifications.length - 100);
      }
      
      await prefs.setString(notificationsKey, json.encode(notifications));
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  // Save notifications list
  Future<void> _saveNotifications(List<SmartNotification> notifications, String clinicianId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = '${_notificationsKey}_$clinicianId';
      
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(notificationsKey, json.encode(notificationsJson));
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount(String clinicianId) async {
    try {
      final notifications = await getNotificationsForClinician(clinicianId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Get high priority notifications
  Future<List<SmartNotification>> getHighPriorityNotifications(String clinicianId) async {
    try {
      final notifications = await getNotificationsForClinician(clinicianId);
      return notifications.where((n) => 
        n.priority == 'high' || n.priority == 'critical'
      ).toList();
    } catch (e) {
      print('Error getting high priority notifications: $e');
      return [];
    }
  }

  // Clear old notifications
  Future<void> clearOldNotifications(String clinicianId, {int daysOld = 30}) async {
    try {
      final notifications = await getNotificationsForClinician(clinicianId);
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      final recentNotifications = notifications.where((n) => 
        n.timestamp.isAfter(cutoffDate)
      ).toList();
      
      await _saveNotifications(recentNotifications, clinicianId);
    } catch (e) {
      print('Error clearing old notifications: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}

// Data classes for smart notifications
class SmartNotification {
  final String id;
  final String patientId;
  final String clinicianId;
  final String title;
  final String message;
  final NotificationContext context;
  final String priority;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool requiresAction;
  final String? actionRequired;
  final bool isRead;
  final DateTime? readAt;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;

  const SmartNotification({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.title,
    required this.message,
    required this.context,
    required this.priority,
    required this.timestamp,
    required this.data,
    this.requiresAction = false,
    this.actionRequired,
    this.isRead = false,
    this.readAt,
    this.isAcknowledged = false,
    this.acknowledgedAt,
  });

  SmartNotification copyWith({
    String? id,
    String? patientId,
    String? clinicianId,
    String? title,
    String? message,
    NotificationContext? context,
    String? priority,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? requiresAction,
    String? actionRequired,
    bool? isRead,
    DateTime? readAt,
    bool? isAcknowledged,
    DateTime? acknowledgedAt,
  }) {
    return SmartNotification(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      clinicianId: clinicianId ?? this.clinicianId,
      title: title ?? this.title,
      message: message ?? this.message,
      context: context ?? this.context,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      requiresAction: requiresAction ?? this.requiresAction,
      actionRequired: actionRequired ?? this.actionRequired,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'clinicianId': clinicianId,
      'title': title,
      'message': message,
      'context': context.name,
      'priority': priority,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'requiresAction': requiresAction,
      'actionRequired': actionRequired,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'isAcknowledged': isAcknowledged,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
    };
  }

  factory SmartNotification.fromJson(Map<String, dynamic> json) {
    return SmartNotification(
      id: json['id'],
      patientId: json['patientId'],
      clinicianId: json['clinicianId'],
      title: json['title'],
      message: json['message'],
      context: NotificationContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => NotificationContext.general,
      ),
      priority: json['priority'],
      timestamp: DateTime.parse(json['timestamp']),
      data: Map<String, dynamic>.from(json['data']),
      requiresAction: json['requiresAction'] ?? false,
      actionRequired: json['actionRequired'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      isAcknowledged: json['isAcknowledged'] ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null ? DateTime.parse(json['acknowledgedAt']) : null,
    );
  }
}

enum NotificationContext {
  crisis,
  medication,
  appointment,
  progress,
  compliance,
  aiInsight,
  general,
}
