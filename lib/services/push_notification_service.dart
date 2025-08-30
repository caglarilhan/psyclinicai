import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  // Notification durumu
  bool _isInitialized = false;
  bool _hasPermission = false;
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _scheduledNotifications = [];
  
  // Notification kategorileri
  final Map<String, String> _categories = {
    'session': 'Seans Bildirimleri',
    'appointment': 'Randevu Bildirimleri',
    'emergency': 'Acil Durum',
    'reminder': 'Hatırlatmalar',
    'system': 'Sistem Bildirimleri',
    'marketing': 'Pazarlama',
  };
  
  // Stream controllers
  final StreamController<Map<String, dynamic>> _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _permissionController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get permissionStream => _permissionController.stream;

  // Getter'lar
  bool get isInitialized => _isInitialized;
  bool get hasPermission => _hasPermission;
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  List<Map<String, dynamic>> get scheduledNotifications => List.unmodifiable(_scheduledNotifications);
  Map<String, String> get categories => Map.unmodifiable(_categories);

  // Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadNotifications();
    await _loadScheduledNotifications();
    await _requestPermissions();
    
    _isInitialized = true;
    
    // Demo notification gönder
    await Future.delayed(const Duration(seconds: 2));
    await _sendDemoNotification();
  }

  // İzinleri iste
  Future<void> _requestPermissions() async {
    try {
      // TODO: Gerçek push notification izinleri
      _hasPermission = true;
      _permissionController.add({
        'status': 'granted',
        'message': 'Push notification izinleri verildi',
      });
    } catch (e) {
      _hasPermission = false;
      _permissionController.add({
        'status': 'denied',
        'message': 'Push notification izinleri reddedildi',
      });
    }
  }

  // Demo notification gönder
  Future<void> _sendDemoNotification() async {
    await sendNotification(
      title: 'Hoş Geldiniz!',
      body: 'PsyClinic AI uygulamasına hoş geldiniz. Size nasıl yardımcı olabilirim?',
      category: 'system',
      data: {'type': 'welcome'},
    );
  }

  // Notification gönder
  Future<void> sendNotification({
    required String title,
    required String body,
    String? category,
    Map<String, dynamic>? data,
    String? imageUrl,
    bool isSilent = false,
  }) async {
    if (!_hasPermission) {
      throw Exception('Push notification izinleri verilmedi');
    }

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'category': category ?? 'system',
      'data': data ?? {},
      'imageUrl': imageUrl,
      'isSilent': isSilent,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'isDelivered': true,
    };

    _notifications.insert(0, notification);
    _saveNotifications();
    
    // Stream'e gönder
    _notificationController.add(notification);
    
    // TODO: Gerçek push notification gönderimi
    print('Push Notification: $title - $body');
  }

  // Zamanlanmış notification oluştur
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? category,
    Map<String, dynamic>? data,
    String? imageUrl,
    bool isRepeating = false,
    String? repeatInterval,
  }) async {
    if (!_hasPermission) {
      throw Exception('Push notification izinleri verilmedi');
    }

    final scheduledNotification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'category': category ?? 'reminder',
      'data': data ?? {},
      'imageUrl': imageUrl,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isRepeating': isRepeating,
      'repeatInterval': repeatInterval,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _scheduledNotifications.add(scheduledNotification);
    _saveScheduledNotifications();
    
    // TODO: Gerçek zamanlanmış notification
    print('Scheduled Notification: $title at ${scheduledDate.toString()}');
  }

  // Session reminder oluştur
  Future<void> scheduleSessionReminder({
    required String clientName,
    required DateTime sessionTime,
    required String sessionType,
  }) async {
    await scheduleNotification(
      title: 'Seans Hatırlatması',
      body: '$clientName ile $sessionType seansınız ${_formatTime(sessionTime)} başlayacak',
      scheduledDate: sessionTime.subtract(const Duration(hours: 1)),
      category: 'session',
      data: {
        'type': 'session_reminder',
        'clientName': clientName,
        'sessionTime': sessionTime.toIso8601String(),
        'sessionType': sessionType,
      },
    );
  }

  // Appointment reminder oluştur
  Future<void> scheduleAppointmentReminder({
    required String clientName,
    required DateTime appointmentTime,
    required String appointmentType,
  }) async {
    await scheduleNotification(
      title: 'Randevu Hatırlatması',
      body: '$clientName ile $appointmentType randevunuz ${_formatTime(appointmentTime)} başlayacak',
      scheduledDate: appointmentTime.subtract(const Duration(hours: 2)),
      category: 'appointment',
      data: {
        'type': 'appointment_reminder',
        'clientName': clientName,
        'appointmentTime': appointmentTime.toIso8601String(),
        'appointmentType': appointmentType,
      },
    );
  }

  // Emergency notification gönder
  Future<void> sendEmergencyNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await sendNotification(
      title: title,
      body: body,
      category: 'emergency',
      data: data,
      isSilent: false,
    );
  }

  // Marketing notification gönder
  Future<void> sendMarketingNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    await sendNotification(
      title: title,
      body: body,
      category: 'marketing',
      imageUrl: imageUrl,
      data: data,
    );
  }

  // Notification'ı okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _saveNotifications();
    }
  }

  // Tüm notification'ları okundu olarak işaretle
  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _saveNotifications();
  }

  // Notification'ı sil
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    _saveNotifications();
  }

  // Zamanlanmış notification'ı iptal et
  Future<void> cancelScheduledNotification(String notificationId) async {
    final index = _scheduledNotifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _scheduledNotifications[index]['isActive'] = false;
      _saveScheduledNotifications();
    }
  }

  // Tüm zamanlanmış notification'ları iptal et
  Future<void> cancelAllScheduledNotifications() async {
    for (var notification in _scheduledNotifications) {
      notification['isActive'] = false;
    }
    _saveScheduledNotifications();
  }

  // Notification'ları temizle
  Future<void> clearNotifications() async {
    _notifications.clear();
    _saveNotifications();
  }

  // Kategoriye göre notification'ları filtrele
  List<Map<String, dynamic>> getNotificationsByCategory(String category) {
    return _notifications.where((n) => n['category'] == category).toList();
  }

  // Okunmamış notification sayısı
  int get unreadCount {
    return _notifications.where((n) => n['isRead'] == false).length;
  }

  // Aktif zamanlanmış notification sayısı
  int get activeScheduledCount {
    return _scheduledNotifications.where((n) => n['isActive'] == true).length;
  }

  // Notification istatistikleri
  Map<String, dynamic> getNotificationStats() {
    final categoryStats = <String, int>{};
    for (var category in _categories.keys) {
      categoryStats[category] = getNotificationsByCategory(category).length;
    }

    return {
      'totalNotifications': _notifications.length,
      'unreadCount': unreadCount,
      'scheduledCount': _scheduledNotifications.length,
      'activeScheduledCount': activeScheduledCount,
      'categoryStats': categoryStats,
      'hasPermission': _hasPermission,
      'isInitialized': _isInitialized,
    };
  }

  // Notification ayarları
  Map<String, dynamic> getNotificationSettings() {
    return {
      'sessionReminders': true,
      'appointmentReminders': true,
      'emergencyNotifications': true,
      'marketingNotifications': false,
      'systemNotifications': true,
      'soundEnabled': true,
      'vibrationEnabled': true,
      'quietHoursEnabled': false,
      'quietHoursStart': '22:00',
      'quietHoursEnd': '08:00',
    };
  }

  // Notification ayarlarını güncelle
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_settings', json.encode(settings));
  }

  // Notification ayarlarını yükle
  Future<Map<String, dynamic>> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notification_settings');
    if (data != null) {
      return Map<String, dynamic>.from(json.decode(data));
    }
    return getNotificationSettings();
  }

  // Notification'ları kaydet
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', json.encode(_notifications));
  }

  // Notification'ları yükle
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notifications');
    if (data != null) {
      _notifications = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Zamanlanmış notification'ları kaydet
  Future<void> _saveScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduled_notifications', json.encode(_scheduledNotifications));
  }

  // Zamanlanmış notification'ları yükle
  Future<void> _loadScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('scheduled_notifications');
    if (data != null) {
      _scheduledNotifications = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Zaman formatı
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Dispose
  void dispose() {
    _notificationController.close();
    _permissionController.close();
  }
}
