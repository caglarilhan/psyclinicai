import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    // Local notifications are mobile-only; no-op on web (plugin unsupported).
    if (kIsWeb) {
      _initialized = true;
      return;
    }
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
    if (kIsWeb) return;
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
    if (kIsWeb) return;
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
