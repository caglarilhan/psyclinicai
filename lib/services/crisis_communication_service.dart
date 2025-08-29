import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/flag_system_models.dart';
import '../utils/ai_logger.dart';

/// Kriz İletişim Servisi
/// Kriz durumunda hasta ile otomatik iletişim kurar
class CrisisCommunicationService extends ChangeNotifier {
  static final CrisisCommunicationService _instance = CrisisCommunicationService._internal();
  factory CrisisCommunicationService() => _instance;
  CrisisCommunicationService._internal();

  final AILogger _logger = AILogger();

  // İletişim geçmişi
  final List<Map<String, dynamic>> _communicationHistory = <Map<String, dynamic>>[];
  
  // Stream'ler
  final StreamController<Map<String, dynamic>> _communicationController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  List<Map<String, dynamic>> get communicationHistory => List.unmodifiable(_communicationHistory);
  Stream<Map<String, dynamic>> get communicationStream => _communicationController.stream;

  /// Başlatma
  Future<void> initialize() async {
    _logger.info('CrisisCommunicationService initializing...', context: 'CrisisCommunicationService');
    _logger.info('CrisisCommunicationService initialized', context: 'CrisisCommunicationService');
  }

  /// Kriz durumunda otomatik iletişim başlat
  Future<void> initiateCrisisCommunication(CrisisFlag crisisFlag, Map<String, dynamic> patientContactInfo) async {
    _logger.info('Kriz iletişimi başlatılıyor: ${crisisFlag.id}', context: 'CrisisCommunicationService');
    
    final communicationId = 'comm_${DateTime.now().millisecondsSinceEpoch}';
    
    // 1. Acil telefon araması
    if (patientContactInfo['phone'] != null) {
      await _makeEmergencyCall(
        communicationId: communicationId,
        phoneNumber: patientContactInfo['phone'],
        patientName: patientContactInfo['name'] ?? 'Hasta',
        crisisType: crisisFlag.type,
        severity: crisisFlag.severity,
      );
    }

    // 2. Acil SMS
    if (patientContactInfo['phone'] != null) {
      await _sendEmergencySMS(
        communicationId: communicationId,
        phoneNumber: patientContactInfo['phone'],
        patientName: patientContactInfo['name'] ?? 'Hasta',
        crisisType: crisisFlag.type,
        severity: crisisFlag.severity,
      );
    }

    // 3. Acil email
    if (patientContactInfo['email'] != null) {
      await _sendEmergencyEmail(
        communicationId: communicationId,
        email: patientContactInfo['email'],
        patientName: patientContactInfo['name'] ?? 'Hasta',
        crisisType: crisisFlag.type,
        severity: crisisFlag.severity,
        description: crisisFlag.description,
      );
    }

    // 4. Acil durum bildirimi (112, polis, vb.)
    if (crisisFlag.severity == CrisisSeverity.critical || 
        crisisFlag.severity == CrisisSeverity.emergency) {
      await _notifyEmergencyServices(
        communicationId: communicationId,
        crisisFlag: crisisFlag,
        patientContactInfo: patientContactInfo,
      );
    }

    // 5. Aile/arkadaş bildirimi
    if (patientContactInfo['emergencyContacts'] != null) {
      await _notifyEmergencyContacts(
        communicationId: communicationId,
        crisisFlag: crisisFlag,
        emergencyContacts: patientContactInfo['emergencyContacts'],
      );
    }

    _logger.info('Kriz iletişimi tamamlandı: ${crisisFlag.id}', context: 'CrisisCommunicationService');
  }

  /// Acil telefon araması
  Future<void> _makeEmergencyCall({
    required String communicationId,
    required String phoneNumber,
    required String patientName,
    required CrisisType crisisType,
    required CrisisSeverity severity,
  }) async {
    final attempt = {
      'id': '${communicationId}_call',
      'communicationId': communicationId,
      'type': 'phone_call',
      'target': phoneNumber,
      'status': 'attempting',
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'patientName': patientName,
        'crisisType': crisisType.name,
        'severity': severity.name,
        'priority': 'high',
      },
    };

    _communicationHistory.add(attempt);
    _communicationController.add(attempt);
    notifyListeners();

    try {
      // Simüle edilmiş telefon araması
      await Future.delayed(const Duration(seconds: 2));
      
      // Arama sonucu (başarılı/başarısız)
      final isSuccessful = _simulateCallResult(phoneNumber);
      
      final updatedAttempt = {
        ...attempt,
        'status': isSuccessful ? 'successful' : 'failed',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'callDuration': isSuccessful ? '45 saniye' : null,
          'failureReason': isSuccessful ? null : 'Telefon açılmadı',
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = updatedAttempt;
      }

      _communicationController.add(updatedAttempt);
      notifyListeners();

      _logger.info('Telefon araması ${isSuccessful ? 'başarılı' : 'başarısız'}: $phoneNumber', 
          context: 'CrisisCommunicationService');

    } catch (e) {
      _logger.error('Telefon araması hatası: $e', context: 'CrisisCommunicationService');
      
      final failedAttempt = {
        ...attempt,
        'status': 'failed',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'error': e.toString(),
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = failedAttempt;
      }

      _communicationController.add(failedAttempt);
      notifyListeners();
    }
  }

  /// Acil SMS gönderimi
  Future<void> _sendEmergencySMS({
    required String communicationId,
    required String phoneNumber,
    required String patientName,
    required CrisisType crisisType,
    required CrisisSeverity severity,
  }) async {
    final attempt = {
      'id': '${communicationId}_sms',
      'communicationId': communicationId,
      'type': 'sms',
      'target': phoneNumber,
      'status': 'attempting',
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'patientName': patientName,
        'crisisType': crisisType.name,
        'severity': severity.name,
        'priority': 'high',
      },
    };

    _communicationHistory.add(attempt);
    _communicationController.add(attempt);
    notifyListeners();

    try {
      // SMS içeriği oluştur
      final smsContent = _generateEmergencySMSContent(patientName, crisisType, severity);
      
      // Simüle edilmiş SMS gönderimi
      await Future.delayed(const Duration(seconds: 1));
      
      final updatedAttempt = {
        ...attempt,
        'status': 'successful',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'smsContent': smsContent,
          'deliveryStatus': 'delivered',
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = updatedAttempt;
      }

      _communicationController.add(updatedAttempt);
      notifyListeners();

      _logger.info('Acil SMS gönderildi: $phoneNumber', context: 'CrisisCommunicationService');

    } catch (e) {
      _logger.error('SMS gönderim hatası: $e', context: 'CrisisCommunicationService');
      
      final failedAttempt = {
        ...attempt,
        'status': 'failed',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'error': e.toString(),
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = failedAttempt;
      }

      _communicationController.add(failedAttempt);
      notifyListeners();
    }
  }

  /// Acil email gönderimi
  Future<void> _sendEmergencyEmail({
    required String communicationId,
    required String email,
    required String patientName,
    required CrisisType crisisType,
    required CrisisSeverity severity,
    required String description,
  }) async {
    final attempt = {
      'id': '${communicationId}_email',
      'communicationId': communicationId,
      'type': 'email',
      'target': email,
      'status': 'attempting',
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'patientName': patientName,
        'crisisType': crisisType.name,
        'severity': severity.name,
        'priority': 'high',
      },
    };

    _communicationHistory.add(attempt);
    _communicationController.add(attempt);
    notifyListeners();

    try {
      // Email içeriği oluştur
      final emailSubject = _generateEmergencyEmailSubject(crisisType, severity);
      final emailBody = _generateEmergencyEmailBody(patientName, crisisType, severity, description);
      
      // Simüle edilmiş email gönderimi
      await Future.delayed(const Duration(seconds: 2));
      
      final updatedAttempt = {
        ...attempt,
        'status': 'successful',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'emailSubject': emailSubject,
          'emailBody': emailBody,
          'deliveryStatus': 'sent',
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = updatedAttempt;
      }

      _communicationController.add(updatedAttempt);
      notifyListeners();

      _logger.info('Acil email gönderildi: $email', context: 'CrisisCommunicationService');

    } catch (e) {
      _logger.error('Email gönderim hatası: $e', context: 'CrisisCommunicationService');
      
      final failedAttempt = {
        ...attempt,
        'status': 'failed',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'error': e.toString(),
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = failedAttempt;
      }

      _communicationController.add(failedAttempt);
      notifyListeners();
    }
  }

  /// Acil servis bildirimi
  Future<void> _notifyEmergencyServices({
    required String communicationId,
    required CrisisFlag crisisFlag,
    required Map<String, dynamic> patientContactInfo,
  }) async {
    final attempt = {
      'id': '${communicationId}_emergency',
      'communicationId': communicationId,
      'type': 'emergency_service',
      'target': '112',
      'status': 'attempting',
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'patientName': patientContactInfo['name'] ?? 'Hasta',
        'crisisType': crisisFlag.type.name,
        'severity': crisisFlag.severity.name,
        'priority': 'critical',
        'location': patientContactInfo['address'] ?? 'Bilinmiyor',
      },
    };

    _communicationHistory.add(attempt);
    _communicationController.add(attempt);
    notifyListeners();

    try {
      // Acil servis bildirimi simülasyonu
      await Future.delayed(const Duration(seconds: 3));
      
      final updatedAttempt = {
        ...attempt,
        'status': 'successful',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'responseTime': '2 dakika',
          'assignedUnit': 'Acil Psikiyatri Ekibi',
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = updatedAttempt;
      }

      _communicationController.add(updatedAttempt);
      notifyListeners();

      _logger.info('Acil servis bildirimi yapıldı: 112', context: 'CrisisCommunicationService');

    } catch (e) {
      _logger.error('Acil servis bildirimi hatası: $e', context: 'CrisisCommunicationService');
      
      final failedAttempt = {
        ...attempt,
        'status': 'failed',
        'completedAt': DateTime.now().toIso8601String(),
        'metadata': {
          ...(attempt['metadata'] as Map<String, dynamic>),
          'error': e.toString(),
        },
      };

      final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
      if (index != -1) {
        _communicationHistory[index] = failedAttempt;
      }

      _communicationController.add(failedAttempt);
      notifyListeners();
    }
  }

  /// Acil durum kişileri bildirimi
  Future<void> _notifyEmergencyContacts({
    required String communicationId,
    required CrisisFlag crisisFlag,
    required List<Map<String, dynamic>> emergencyContacts,
  }) async {
    for (final contact in emergencyContacts) {
      final attempt = {
        'id': '${communicationId}_contact_${contact['id']}',
        'communicationId': communicationId,
        'type': 'emergency_contact',
        'target': contact['phone'] ?? contact['email'] ?? 'Bilinmiyor',
        'status': 'attempting',
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': {
          'contactName': contact['name'] ?? 'Acil Durum Kişisi',
          'relationship': contact['relationship'] ?? 'Bilinmiyor',
          'crisisType': crisisFlag.type.name,
          'severity': crisisFlag.severity.name,
          'priority': 'high',
        },
      };

      _communicationHistory.add(attempt);
      _communicationController.add(attempt);
      notifyListeners();

      try {
        // Acil durum kişisi bildirimi simülasyonu
        await Future.delayed(const Duration(seconds: 1));
        
        final updatedAttempt = {
          ...attempt,
          'status': 'successful',
          'completedAt': DateTime.now().toIso8601String(),
          'metadata': {
            ...(attempt['metadata'] as Map<String, dynamic>),
            'responseTime': '1 dakika',
            'contacted': true,
          },
        };

        final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
        if (index != -1) {
          _communicationHistory[index] = updatedAttempt;
        }

        _communicationController.add(updatedAttempt);
        notifyListeners();

        _logger.info('Acil durum kişisi bilgilendirildi: ${contact['name']}', 
            context: 'CrisisCommunicationService');

      } catch (e) {
        _logger.error('Acil durum kişisi bildirimi hatası: $e', context: 'CrisisCommunicationService');
        
        final failedAttempt = {
          ...attempt,
          'status': 'failed',
          'completedAt': DateTime.now().toIso8601String(),
          'metadata': {
            ...(attempt['metadata'] as Map<String, dynamic>),
            'error': e.toString(),
          },
        };

        final index = _communicationHistory.indexWhere((c) => c['id'] == attempt['id']);
        if (index != -1) {
          _communicationHistory[index] = failedAttempt;
        }

        _communicationController.add(failedAttempt);
        notifyListeners();
      }
    }
  }

  // Yardımcı metodlar
  bool _simulateCallResult(String phoneNumber) {
    // Simüle edilmiş arama sonucu (gerçek uygulamada API'den gelecek)
    return phoneNumber.endsWith('1') || phoneNumber.endsWith('3') || phoneNumber.endsWith('5');
  }

  String _generateEmergencySMSContent(String patientName, CrisisType crisisType, CrisisSeverity severity) {
    final severityText = severity == CrisisSeverity.critical ? 'KRİTİK' : 'ACİL';
    final crisisText = _getCrisisTypeText(crisisType);
    
    return '''$severityText DURUM: $patientName için $crisisText tespit edildi. 
Lütfen hemen geri dönün veya 112'yi arayın. 
PsyClinic AI Ekibi''';
  }

  String _generateEmergencyEmailSubject(CrisisType crisisType, CrisisSeverity severity) {
    final severityText = severity == CrisisSeverity.critical ? 'KRİTİK' : 'ACİL';
    final crisisText = _getCrisisTypeText(crisisType);
    
    return '🚨 $severityText: $crisisText Durumu - Acil Müdahale Gerekli';
  }

  String _generateEmergencyEmailBody(String patientName, CrisisType crisisType, CrisisSeverity severity, String description) {
    final severityText = severity == CrisisSeverity.critical ? 'KRİTİK' : 'ACİL';
    final crisisText = _getCrisisTypeText(crisisType);
    
    return '''
Merhaba,

Bu email, $patientName için tespit edilen $severityText durum hakkındadır.

**Kriz Türü:** $crisisText
**Şiddet Seviyesi:** $severityText
**Açıklama:** $description
**Tespit Zamanı:** ${DateTime.now().toString()}

**Acil Eylemler:**
1. Hemen geri dönün
2. Hasta güvenliğini sağlayın
3. Gerekirse 112'yi arayın
4. Güvenlik planını uygulayın

**İletişim:**
- Acil: 112
- Klinik: +90 xxx xxx xx xx
- Email: crisis@psyclinici.com

Bu durum otomatik olarak tespit edilmiştir. Lütfen en kısa sürede müdahale edin.

Saygılarımızla,
PsyClinic AI Kriz Yönetim Sistemi
''';
  }

  String _getCrisisTypeText(CrisisType type) {
    switch (type) {
      case CrisisType.suicidalIdeation:
        return 'İntihar Düşüncesi';
      case CrisisType.homicidalIdeation:
        return 'Cinayet Düşüncesi';
      case CrisisType.severeAgitation:
        return 'Şiddetli Ajitasyon';
      case CrisisType.psychoticBreak:
        return 'Psikotik Kırılma';
      case CrisisType.selfHarm:
        return 'Kendine Zarar Verme';
      case CrisisType.substanceAbuse:
        return 'Madde Kullanımı';
      default:
        return 'Kriz Durumu';
    }
  }

  /// İletişim geçmişini temizle
  void clearHistory() {
    _communicationHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _communicationController.close();
    super.dispose();
  }
}

