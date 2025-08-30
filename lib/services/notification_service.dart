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
