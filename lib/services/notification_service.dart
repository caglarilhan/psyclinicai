import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _fln.initialize(initSettings);

    _initialized = true;
  }

  Future<void> scheduleAppointmentReminders({
    required String appointmentId,
    required String title,
    required String body,
    required DateTime startTime,
  }) async {
    await initialize();

    // 24 saat ve 1 saat önce hatırlatma
    final reminders = <Duration>[
      const Duration(hours: 24),
      const Duration(hours: 1),
    ];

    for (final d in reminders) {
      final trigger = startTime.subtract(d);
      if (trigger.isBefore(DateTime.now())) continue;
      final id = _notificationId(appointmentId, d);
      await _fln.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(trigger, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointments',
            'Randevu Hatırlatmaları',
            channelDescription: 'Randevulardan önce bildirim gönderir',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  Future<void> cancelAppointmentReminders(String appointmentId) async {
    await initialize();
    await _fln.cancel(_notificationId(appointmentId, const Duration(hours: 24)));
    await _fln.cancel(_notificationId(appointmentId, const Duration(hours: 1)));
  }

  int _notificationId(String appointmentId, Duration d) {
    // basit deterministik id: hash + offset
    final base = appointmentId.hashCode & 0x7fffffff;
    final offset = d.inHours == 24 ? 1 : 2;
    return base % 1000000 * 10 + offset;
  }
}

import 'package:flutter/material.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<NotificationData> _notificationController = StreamController<NotificationData>.broadcast();

  Stream<NotificationData> get notificationStream => _notificationController.stream;

  Future<void> initialize() async {
    // Notification servisi başlatıldı
  }

  // Seans hatırlatıcısı
  Future<void> scheduleSessionReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // TODO: Local notification implementation
    final notificationData = NotificationData(
      id: id,
      title: title,
      body: body,
      type: NotificationType.session,
    );
    _notificationController.add(notificationData);
  }

  // Acil durum bildirimi
  Future<void> showEmergencyNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final notificationData = NotificationData(
      id: id,
      title: title,
      body: body,
      type: NotificationType.emergency,
    );
    _notificationController.add(notificationData);
  }

  // Genel bildirim
  Future<void> showGeneralNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final notificationData = NotificationData(
      id: id,
      title: title,
      body: body,
      type: NotificationType.general,
    );
    _notificationController.add(notificationData);
  }

  // Başarı bildirimi
  Future<void> showSuccessNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final notificationData = NotificationData(
      id: id,
      title: title,
      body: body,
      type: NotificationType.success,
    );
    _notificationController.add(notificationData);
  }

  void dispose() {
    _notificationController.close();
  }
}

// Bildirim veri modeli
class NotificationData {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime? timestamp;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.timestamp,
  });
}

// Bildirim türleri
enum NotificationType {
  general,
  emergency,
  success,
  session,
  reminder,
}
