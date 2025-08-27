import 'package:flutter/foundation.dart';
import 'dart:collection';

/// Alert kanalları
enum AlertChannel { inApp, email, sms }

/// Üretilen uyarı
class AlertEvent {
  final String key; // benzersiz uyarı anahtarı (örn: state:CA|patient:p1|duty_to_warn)
  final String message;
  final DateTime createdAt;
  final List<AlertChannel> channels;
  const AlertEvent({
    required this.key,
    required this.message,
    required this.createdAt,
    required this.channels,
  });
}

/// De-dup ve cool-down destekli basit alert servisi
class AlertingService extends ChangeNotifier {
  static final AlertingService _instance = AlertingService._internal();
  factory AlertingService() => _instance;
  AlertingService._internal();

  // key -> son gönderim zamanı
  final Map<String, DateTime> _lastSent = HashMap();
  // key -> son mesaj
  final Map<String, String> _lastMessage = HashMap();

  // Son oluşturulan uyarılar (gözlem için)
  final List<AlertEvent> _events = <AlertEvent>[];
  List<AlertEvent> get events => List.unmodifiable(_events);

  /// Aynı key için cool-down penceresinde ise tekrar göndermez.
  /// Mesaj birebir aynıysa de-dup yapar (cool-down bitse bile aynı ise atlamayı tercih edebilirsiniz; burada sadece cooldown uygularız).
  bool send({
    required String key,
    required String message,
    Duration cooldown = const Duration(minutes: 5),
    List<AlertChannel> channels = const [AlertChannel.inApp],
  }) {
    final now = DateTime.now();
    final last = _lastSent[key];

    if (last != null) {
      final withinCooldown = now.difference(last) < cooldown;
      if (withinCooldown) {
        return false; // cool-down içinde: atla
      }
    }

    // de-dup (opsiyonel): aynı mesaj ve çok yakın zamanda ise atla
    final lastMsg = _lastMessage[key];
    if (lastMsg != null && lastMsg == message && last != null && now.difference(last) < cooldown) {
      return false;
    }

    // gönderim (simülasyon)
    final event = AlertEvent(key: key, message: message, createdAt: now, channels: channels);
    _events.add(event);
    _lastSent[key] = now;
    _lastMessage[key] = message;
    notifyListeners();
    return true;
  }

  /// Belirli anahtar için kayıtları temizler
  void reset(String key) {
    _lastSent.remove(key);
    _lastMessage.remove(key);
  }

  /// Tüm geçmişi temizler (test amaçlı)
  void clearAll() {
    _lastSent.clear();
    _lastMessage.clear();
    _events.clear();
    notifyListeners();
  }
}
