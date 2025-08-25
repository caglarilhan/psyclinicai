import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _firebaseMessaging;
  
  StreamController<RemoteMessage> _messageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  // Bildirim türleri
  static const String _channelId = 'psyclinic_notifications';
  static const String _channelName = 'PsyClinic Bildirimleri';
  static const String _channelDescription = 'PsyClinic AI uygulama bildirimleri';

  // Bildirim kategorileri
  static const String _appointmentCategory = 'appointment';
  static const String _emergencyCategory = 'emergency';
  static const String _reminderCategory = 'reminder';
  static const String _updateCategory = 'update';

  Future<void> initialize() async {
    try {
      // Test ortamında Firebase başlatılmadıysa sessizce geç
      final bool isTestEnv = const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
      if (isTestEnv) {
        print('PushNotificationService: test ortamı, Firebase initialize atlanıyor');
        await _setupLocalNotifications();
        return;
      }
      _firebaseMessaging = FirebaseMessaging.instance;
      // Firebase Cloud Messaging izinleri
      await _requestPermissions();
      
      // Local notifications kurulumu
      await _setupLocalNotifications();
      
      // Firebase message handlers
      await _setupFirebaseMessaging();
      
      // Background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Notification tap handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      print('PushNotificationService initialized successfully');
    } catch (e) {
      print('PushNotificationService initialization failed: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (_firebaseMessaging == null) return;
    // iOS izinleri
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true, // Acil durumlar için
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }
  }

  Future<void> _setupLocalNotifications() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupFirebaseMessaging() async {
    if (_firebaseMessaging == null) return;
    // FCM token al
    String? token = await _firebaseMessaging!.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await _saveFCMToken(token);
    }

    // Token refresh listener
    _firebaseMessaging!.onTokenRefresh.listen((newToken) {
      _saveFCMToken(newToken);
    });
  }

  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');
    
    // Local notification göster
    _showLocalNotification(message);
    
    // Stream'e gönder
    _messageStreamController.add(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    // Bildirime tıklandığında yapılacak işlemler
    _handleNotificationAction(message);
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Local bildirime tıklandığında yapılacak işlemler
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      category: null, // AndroidNotificationCategory removed for compatibility
      actions: _getNotificationActions(message.data['category']),
    );

    final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: _getNotificationCategory(message.data['category']),
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'PsyClinic AI',
      message.notification?.body ?? 'Yeni bildirim',
      notificationDetails,
      payload: json.encode(message.data),
    );
  }

  String _getNotificationCategory(String? category) {
    switch (category) {
      case _appointmentCategory:
        return 'appointment';
      case _emergencyCategory:
        return 'emergency';
      case _reminderCategory:
        return 'reminder';
      case _updateCategory:
        return 'update';
      default:
        return 'general';
    }
  }

  List<AndroidNotificationAction> _getNotificationActions(String? category) {
    switch (category) {
      case _appointmentCategory:
        return [
          const AndroidNotificationAction('view', 'Görüntüle'),
          const AndroidNotificationAction('reschedule', 'Yeniden Planla'),
        ];
      case _emergencyCategory:
        return [
          const AndroidNotificationAction('call', 'Ara'),
          const AndroidNotificationAction('view', 'Görüntüle'),
        ];
      case _reminderCategory:
        return [
          const AndroidNotificationAction('snooze', 'Ertelen'),
          const AndroidNotificationAction('dismiss', 'Kapat'),
        ];
      default:
        return [
          const AndroidNotificationAction('view', 'Görüntüle'),
        ];
    }
  }

  void _handleNotificationAction(RemoteMessage message) {
    final category = message.data['category'];
    final action = message.data['action'];
    
    switch (category) {
      case _appointmentCategory:
        _handleAppointmentAction(action, message);
        break;
      case _emergencyCategory:
        _handleEmergencyAction(action, message);
        break;
      case _reminderCategory:
        _handleReminderAction(action, message);
        break;
      default:
        _handleGeneralAction(action, message);
        break;
    }
  }

  void _handleAppointmentAction(String? action, RemoteMessage message) {
    switch (action) {
      case 'view':
        // Randevu detayını göster
        print('Show appointment details');
        break;
      case 'reschedule':
        // Randevu yeniden planlama
        print('Reschedule appointment');
        break;
    }
  }

  void _handleEmergencyAction(String? action, RemoteMessage message) {
    switch (action) {
      case 'call':
        // Acil durum numarasını ara
        print('Call emergency number');
        break;
      case 'view':
        // Acil durum detayını göster
        print('Show emergency details');
        break;
    }
  }

  void _handleReminderAction(String? action, RemoteMessage message) {
    switch (action) {
      case 'snooze':
        // Hatırlatıcıyı ertelen
        _scheduleReminder(message, Duration(minutes: 15));
        break;
      case 'dismiss':
        // Hatırlatıcıyı kapat
        print('Dismiss reminder');
        break;
    }
  }

  void _handleGeneralAction(String? action, RemoteMessage message) {
    switch (action) {
      case 'view':
        // Genel bildirim detayını göster
        print('Show general notification details');
        break;
    }
  }

  // Manuel bildirim gönderme
  Future<void> showAppointmentReminder({
    required String title,
    required String body,
    required DateTime appointmentTime,
    required String appointmentId,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      category: null,
      actions: [
        const AndroidNotificationAction('view', 'Görüntüle'),
        const AndroidNotificationAction('snooze', '15 dk Ertelen'),
      ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'appointment',
      ),
    );

    await _localNotifications.show(
      appointmentId.hashCode,
      title,
      body,
      notificationDetails,
      payload: json.encode({
        'type': 'appointment_reminder',
        'appointmentId': appointmentId,
        'appointmentTime': appointmentTime.toIso8601String(),
      }),
    );
  }

  Future<void> showEmergencyAlert({
    required String title,
    required String body,
    required String emergencyType,
    required String clientId,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      category: null,
      actions: [
        const AndroidNotificationAction('call', 'Acil Ara'),
        const AndroidNotificationAction('view', 'Görüntüle'),
      ],
      color: const Color(0xFFFF0000), // Kırmızı
      ledColor: const Color(0xFFFF0000),
      ledOnMs: 1000,
      ledOffMs: 1000,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'emergency',
        interruptionLevel: InterruptionLevel.critical,
      ),
    );

    await _localNotifications.show(
      'emergency_$clientId'.hashCode,
      title,
      body,
      notificationDetails,
      payload: json.encode({
        'type': 'emergency_alert',
        'emergencyType': emergencyType,
        'clientId': clientId,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> showMedicationReminder({
    required String title,
    required String body,
    required String medicationName,
    required String clientId,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      category: null,
      actions: [
        const AndroidNotificationAction('taken', 'Alındı'),
        const AndroidNotificationAction('snooze', 'Ertelen'),
      ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'reminder',
      ),
    );

    await _localNotifications.show(
      'medication_$clientId'.hashCode,
      title,
      body,
      notificationDetails,
      payload: json.encode({
        'type': 'medication_reminder',
        'medicationName': medicationName,
        'clientId': clientId,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // Hatırlatıcı erteleme
  Future<void> _scheduleReminder(RemoteMessage message, Duration delay) async {
    final scheduledTime = TZDateTime.now(local).add(delay);
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.zonedSchedule(
      message.hashCode,
      message.notification?.title ?? 'Hatırlatıcı',
      message.notification?.body ?? 'Ertelenen hatırlatıcı',
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: message.data.toString(),
    );
  }

  // Bildirim ayarları
  Future<void> updateNotificationSettings({
    required bool appointmentReminders,
    required bool medicationReminders,
    required bool emergencyAlerts,
    required bool systemUpdates,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('appointment_reminders', appointmentReminders);
    await prefs.setBool('medication_reminders', medicationReminders);
    await prefs.setBool('emergency_alerts', emergencyAlerts);
    await prefs.setBool('system_updates', systemUpdates);
    await prefs.setBool('sound_enabled', soundEnabled);
    await prefs.setBool('vibration_enabled', vibrationEnabled);
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'appointment_reminders': prefs.getBool('appointment_reminders') ?? true,
      'medication_reminders': prefs.getBool('medication_reminders') ?? true,
      'emergency_alerts': prefs.getBool('emergency_alerts') ?? true,
      'system_updates': prefs.getBool('system_updates') ?? false,
      'sound_enabled': prefs.getBool('sound_enabled') ?? true,
      'vibration_enabled': prefs.getBool('vibration_enabled') ?? true,
    };
  }

  // Bildirim geçmişi
  Future<List<NotificationHistory>> getNotificationHistory() async {
    // Bu özellik için local database kullanılacak
    return [];
  }

  // Tüm bildirimleri temizle
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Belirli bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  void dispose() {
    _messageStreamController.close();
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
  
  // Background'da local notification göster
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'psyclinic_notifications',
    'PsyClinic Bildirimleri',
    channelDescription: 'PsyClinic AI uygulama bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  await localNotifications.show(
    message.hashCode,
    message.notification?.title ?? 'PsyClinic AI',
    message.notification?.body ?? 'Yeni bildirim',
    notificationDetails,
  );
}

// Bildirim geçmişi modeli
class NotificationHistory {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String category;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationHistory({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.isRead,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'category': category,
    'isRead': isRead,
    'data': data,
  };

  factory NotificationHistory.fromJson(Map<String, dynamic> json) => NotificationHistory(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    timestamp: DateTime.parse(json['timestamp']),
    category: json['category'],
    isRead: json['isRead'],
    data: json['data'],
  );
}
