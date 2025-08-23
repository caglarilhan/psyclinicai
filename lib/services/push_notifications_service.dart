import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationsService {
  static const String _notificationsKey = 'push_notifications';
  static const String _subscriptionsKey = 'notification_subscriptions';
  static const String _settingsKey = 'notification_settings';
  
  // Singleton pattern
  static final PushNotificationsService _instance = PushNotificationsService._internal();
  factory PushNotificationsService() => _instance;
  PushNotificationsService._internal();

  // Stream controllers for real-time updates
  final StreamController<PushNotification> _notificationStreamController = 
      StreamController<PushNotification>.broadcast();
  
  final StreamController<NotificationDeliveryStatus> _deliveryStreamController = 
      StreamController<NotificationDeliveryStatus>.broadcast();

  // Get streams
  Stream<PushNotification> get notificationStream => _notificationStreamController.stream;
  Stream<NotificationDeliveryStatus> get deliveryStream => _deliveryStreamController.stream;

  // Notification settings
  NotificationSettings _settings = const NotificationSettings(
    enabled: true,
    soundEnabled: true,
    vibrationEnabled: true,
    badgeEnabled: true,
    quietHoursEnabled: false,
    quietHoursStart: '22:00',
    quietHoursEnd: '08:00',
    categories: {
      'clinical': true,
      'administrative': true,
      'reminders': true,
      'alerts': true,
      'updates': true,
    },
  );

  // Active notification subscriptions
  final Map<String, NotificationSubscription> _subscriptions = {};

  // Initialize push notifications service
  Future<void> initialize() async {
    try {
      // Load settings
      await _loadSettings();
      
      // Load subscriptions
      await _loadSubscriptions();
      
      print('✅ Push Notifications service initialized');
    } catch (e) {
      print('Error initializing push notifications service: $e');
    }
  }

  // Get notification settings
  NotificationSettings get settings => _settings;

  // Update notification settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      _settings = newSettings;
      await _saveSettings();
      
      print('✅ Notification settings updated');
    } catch (e) {
      print('Error updating notification settings: $e');
    }
  }

  // Subscribe to notification category
  Future<bool> subscribeToCategory({
    required String userId,
    required String category,
    required String deviceToken,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final subscription = NotificationSubscription(
        id: _generateSecureId(),
        userId: userId,
        category: category,
        deviceToken: deviceToken,
        metadata: metadata ?? {},
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _subscriptions['${userId}_$category'] = subscription;
      await _saveSubscriptions();

      print('✅ Subscribed to category: $category for user: $userId');
      return true;

    } catch (e) {
      print('Error subscribing to category: $e');
      return false;
    }
  }

  // Unsubscribe from notification category
  Future<bool> unsubscribeFromCategory({
    required String userId,
    required String category,
  }) async {
    try {
      final key = '${userId}_$category';
      if (_subscriptions.containsKey(key)) {
        final subscription = _subscriptions[key]!;
        subscription.isActive = false;
        subscription.updatedAt = DateTime.now();
        
        await _saveSubscriptions();
        print('✅ Unsubscribed from category: $category for user: $userId');
        return true;
      }
      return false;

    } catch (e) {
      print('Error unsubscribing from category: $e');
      return false;
    }
  }

  // Send push notification
  Future<String> sendNotification({
    required String title,
    required String body,
    required String category,
    required List<String> targetUserIds,
    String? imageUrl,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
    NotificationType type = NotificationType.alert,
    DateTime? scheduledAt,
  }) async {
    try {
      final notificationId = _generateSecureId();
      
      final notification = PushNotification(
        id: notificationId,
        title: title,
        body: body,
        category: category,
        targetUserIds: targetUserIds,
        imageUrl: imageUrl,
        data: data ?? {},
        priority: priority,
        type: type,
        status: NotificationStatus.pending,
        scheduledAt: scheduledAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Check if notifications are enabled
      if (!_settings.enabled) {
        print('⚠️ Notifications are disabled');
        return notificationId;
      }

      // Check quiet hours
      if (_settings.quietHoursEnabled && _isInQuietHours()) {
        print('⚠️ Notification scheduled during quiet hours');
        notification.status = NotificationStatus.scheduled;
        notification.scheduledAt = _getNextQuietHoursEnd();
      }

      // Check category settings
      if (!_settings.categories[category] ?? true) {
        print('⚠️ Category $category is disabled');
        return notificationId;
      }

      // Save notification
      await _saveNotification(notification);

      // Send to notification stream
      _notificationStreamController.add(notification);

      // Simulate delivery to target users
      for (final userId in targetUserIds) {
        await _deliverNotification(notification, userId);
      }

      print('✅ Push notification sent: $notificationId');
      return notificationId;

    } catch (e) {
      print('Error sending push notification: $e');
      rethrow;
    }
  }

  // Deliver notification to specific user
  Future<void> _deliverNotification(PushNotification notification, String userId) async {
    try {
      // Check if user is subscribed to this category
      final key = '${userId}_${notification.category}';
      final subscription = _subscriptions[key];
      
      if (subscription == null || !subscription.isActive) {
        print('⚠️ User $userId not subscribed to category ${notification.category}');
        return;
      }

      // Simulate delivery delay
      await Future.delayed(Duration(milliseconds: Random().nextInt(1000) + 500));

      // Update notification status
      notification.status = NotificationStatus.delivered;
      notification.updatedAt = DateTime.now();
      await _saveNotification(notification);

      // Send delivery status
      _deliveryStreamController.add(NotificationDeliveryStatus(
        id: _generateSecureId(),
        notificationId: notification.id,
        userId: userId,
        deviceToken: subscription.deviceToken,
        status: DeliveryStatus.delivered,
        timestamp: DateTime.now(),
        metadata: {
          'deliveryTime': DateTime.now().millisecondsSinceEpoch,
          'category': notification.category,
          'priority': notification.priority.name,
        },
      ));

      print('✅ Notification delivered to user: $userId');

    } catch (e) {
      print('Error delivering notification to user $userId: $e');
      
      // Send delivery failure status
      _deliveryStreamController.add(NotificationDeliveryStatus(
        id: _generateSecureId(),
        notificationId: notification.id,
        userId: userId,
        deviceToken: '',
        status: DeliveryStatus.failed,
        timestamp: DateTime.now(),
        metadata: {
          'error': e.toString(),
          'category': notification.category,
        },
      ));
    }
  }

  // Send clinical alert notification
  Future<String> sendClinicalAlert({
    required String patientId,
    required String patientName,
    required String alertType,
    required String message,
    required List<String> clinicianIds,
    NotificationPriority priority = NotificationPriority.high,
    Map<String, dynamic>? clinicalData,
  }) async {
    return await sendNotification(
      title: '🚨 Clinical Alert: $alertType',
      body: 'Patient: $patientName - $message',
      category: 'clinical',
      targetUserIds: clinicianIds,
      priority: priority,
      type: NotificationType.alert,
      data: {
        'patientId': patientId,
        'patientName': patientName,
        'alertType': alertType,
        'clinicalData': clinicalData ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Send appointment reminder
  Future<String> sendAppointmentReminder({
    required String appointmentId,
    required String patientName,
    required DateTime appointmentTime,
    required String clinicianId,
    int reminderMinutes = 30,
  }) async {
    final reminderTime = appointmentTime.subtract(Duration(minutes: reminderMinutes));
    
    return await sendNotification(
      title: '📅 Appointment Reminder',
      body: 'Appointment with $patientName in ${reminderMinutes} minutes',
      category: 'reminders',
      targetUserIds: [clinicianId],
      priority: NotificationPriority.normal,
      type: NotificationType.reminder,
      scheduledAt: reminderTime,
      data: {
        'appointmentId': appointmentId,
        'patientName': patientName,
        'appointmentTime': appointmentTime.toIso8601String(),
        'reminderMinutes': reminderMinutes,
      },
    );
  }

  // Send medication reminder
  Future<String> sendMedicationReminder({
    required String patientId,
    required String patientName,
    required String medicationName,
    required String dosage,
    required DateTime reminderTime,
    required String clinicianId,
  }) async {
    return await sendNotification(
      title: '💊 Medication Reminder',
      body: '$patientName - $medicationName $dosage',
      category: 'reminders',
      targetUserIds: [clinicianId],
      priority: NotificationPriority.normal,
      type: NotificationType.reminder,
      scheduledAt: reminderTime,
      data: {
        'patientId': patientId,
        'patientName': patientName,
        'medicationName': medicationName,
        'dosage': dosage,
        'reminderTime': reminderTime.toIso8601String(),
      },
    );
  }

  // Send system update notification
  Future<String> sendSystemUpdate({
    required String updateType,
    required String message,
    required List<String> targetUserIds,
    NotificationPriority priority = NotificationPriority.low,
  }) async {
    return await sendNotification(
      title: '🔄 System Update: $updateType',
      body: message,
      category: 'updates',
      targetUserIds: targetUserIds,
      priority: priority,
      type: NotificationType.info,
      data: {
        'updateType': updateType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Get notifications for user
  Future<List<PushNotification>> getNotificationsForUser(String userId) async {
    try {
      final notifications = await _getNotifications();
      return notifications.where((n) => n.targetUserIds.contains(userId)).toList();
    } catch (e) {
      print('Error getting notifications for user: $e');
      return [];
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final notifications = await getNotificationsForUser(userId);
      return notifications.where((n) => n.status == NotificationStatus.delivered).length;
    } catch (e) {
      print('Error getting unread notifications count: $e');
      return 0;
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId, String userId) async {
    try {
      final notifications = await _getNotifications();
      final notificationIndex = notifications.indexWhere((n) => n.id == notificationId);
      
      if (notificationIndex >= 0) {
        final notification = notifications[notificationIndex];
        if (notification.targetUserIds.contains(userId)) {
          notification.status = NotificationStatus.read;
          notification.updatedAt = DateTime.now();
          await _saveNotifications(notifications);
          return true;
        }
      }
      return false;

    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Clear old notifications
  Future<void> clearOldNotifications({int daysToKeep = 30}) async {
    try {
      final notifications = await _getNotifications();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final filteredNotifications = notifications.where((n) => 
        n.createdAt.isAfter(cutoffDate)
      ).toList();
      
      await _saveNotifications(filteredNotifications);
      print('✅ Cleared notifications older than $daysToKeep days');

    } catch (e) {
      print('Error clearing old notifications: $e');
    }
  }

  // Check if current time is in quiet hours
  bool _isInQuietHours() {
    if (!_settings.quietHoursEnabled) return false;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final start = _settings.quietHoursStart;
    final end = _settings.quietHoursEnd;
    
    if (start.compareTo(end) <= 0) {
      // Same day (e.g., 08:00 to 22:00)
      return currentTime.compareTo(start) >= 0 && currentTime.compareTo(end) <= 0;
    } else {
      // Overnight (e.g., 22:00 to 08:00)
      return currentTime.compareTo(start) >= 0 || currentTime.compareTo(end) <= 0;
    }
  }

  // Get next quiet hours end time
  DateTime _getNextQuietHoursEnd() {
    final now = DateTime.now();
    final endTime = _settings.quietHoursEnd;
    final endParts = endTime.split(':');
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);
    
    var nextEnd = DateTime(now.year, now.month, now.day, endHour, endMinute);
    
    // If we're past today's end time, schedule for tomorrow
    if (nextEnd.isBefore(now)) {
      nextEnd = nextEnd.add(const Duration(days: 1));
    }
    
    return nextEnd;
  }

  // Save notification settings
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, json.encode(_settings.toJson()));
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  // Load notification settings
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        _settings = NotificationSettings.fromJson(json.decode(settingsJson));
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  // Save notification subscriptions
  Future<void> _saveSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_subscriptionsKey, json.encode(
        _subscriptions.values.map((s) => s.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving notification subscriptions: $e');
    }
  }

  // Load notification subscriptions
  Future<void> _loadSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionsJson = prefs.getString(_subscriptionsKey);
      
      if (subscriptionsJson != null) {
        final subscriptions = json.decode(subscriptionsJson) as List<dynamic>;
        for (final subscriptionJson in subscriptions) {
          final subscription = NotificationSubscription.fromJson(subscriptionJson);
          _subscriptions['${subscription.userId}_${subscription.category}'] = subscription;
        }
      }
    } catch (e) {
      print('Error loading notification subscriptions: $e');
    }
  }

  // Save notification
  Future<void> _saveNotification(PushNotification notification) async {
    try {
      final notifications = await _getNotifications();
      
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index >= 0) {
        notifications[index] = notification;
      } else {
        notifications.add(notification);
      }
      
      await _saveNotifications(notifications);
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  // Save notifications
  Future<void> _saveNotifications(List<PushNotification> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, json.encode(
        notifications.map((n) => n.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Get notifications
  Future<List<PushNotification>> _getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final notifications = json.decode(notificationsJson) as List<dynamic>;
        return notifications.map((json) => PushNotification.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Generate secure ID
  String _generateSecureId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Dispose resources
  void dispose() {
    _notificationStreamController.close();
    _deliveryStreamController.close();
  }
}

// Data classes
class NotificationSettings {
  final bool enabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool badgeEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final Map<String, bool> categories;

  const NotificationSettings({
    required this.enabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.badgeEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.categories,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? badgeEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    Map<String, bool>? categories,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      badgeEnabled: badgeEnabled ?? this.badgeEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'badgeEnabled': badgeEnabled,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'categories': categories,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      badgeEnabled: json['badgeEnabled'] ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '08:00',
      categories: Map<String, bool>.from(json['categories'] ?? {}),
    );
  }
}

class NotificationSubscription {
  final String id;
  final String userId;
  final String category;
  final String deviceToken;
  final Map<String, dynamic> metadata;
  bool isActive;
  final DateTime createdAt;
  DateTime updatedAt;

  NotificationSubscription({
    required this.id,
    required this.userId,
    required this.category,
    required this.deviceToken,
    required this.metadata,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'deviceToken': deviceToken,
      'metadata': metadata,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NotificationSubscription.fromJson(Map<String, dynamic> json) {
    return NotificationSubscription(
      id: json['id'],
      userId: json['userId'],
      category: json['category'],
      deviceToken: json['deviceToken'],
      metadata: json['metadata'] ?? {},
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class PushNotification {
  final String id;
  final String title;
  final String body;
  final String category;
  final List<String> targetUserIds;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final NotificationPriority priority;
  final NotificationType type;
  NotificationStatus status;
  DateTime? scheduledAt;
  final DateTime createdAt;
  DateTime updatedAt;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.targetUserIds,
    this.imageUrl,
    required this.data,
    required this.priority,
    required this.type,
    required this.status,
    this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'targetUserIds': targetUserIds,
      'imageUrl': imageUrl,
      'data': data,
      'priority': priority.name,
      'type': type.name,
      'status': status.name,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      category: json['category'],
      targetUserIds: List<String>.from(json['targetUserIds']),
      imageUrl: json['imageUrl'],
      data: json['data'] ?? {},
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.alert,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.pending,
      ),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

enum NotificationType {
  alert,
  reminder,
  info,
  success,
  warning,
  error,
}

enum NotificationStatus {
  pending,
  scheduled,
  delivered,
  read,
  failed,
}

enum DeliveryStatus {
  pending,
  delivered,
  failed,
  cancelled,
}

class NotificationDeliveryStatus {
  final String id;
  final String notificationId;
  final String userId;
  final String deviceToken;
  final DeliveryStatus status;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const NotificationDeliveryStatus({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.deviceToken,
    required this.status,
    required this.timestamp,
    required this.metadata,
  });
}
