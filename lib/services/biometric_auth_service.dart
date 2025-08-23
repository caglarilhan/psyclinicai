import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService {
  static const String _biometricKey = 'biometric_auth';
  
  // Singleton pattern
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  // Stream controllers
  final StreamController<BiometricAuthEvent> _authStreamController = 
      StreamController<BiometricAuthEvent>.broadcast();
  
  final StreamController<BiometricAlert> _alertStreamController = 
      StreamController<BiometricAlert>.broadcast();

  // Get streams
  Stream<BiometricAuthEvent> get authStream => _authStreamController.stream;
  Stream<BiometricAlert> get alertStream => _alertStreamController.stream;

  // Check if biometric is available
  Future<bool> isBiometricAvailable() async => true;

  // Check if biometric is enrolled
  Future<bool> isBiometricEnrolled(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricKey = '${_biometricKey}_$userId';
      return prefs.getString(biometricKey) != null;
    } catch (e) {
      print('Error checking biometric enrollment: $e');
      return false;
    }
  }

  // Enroll fingerprint
  Future<bool> enrollFingerprint({
    required String userId,
    required String fingerprintData,
    String? description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricKey = '${_biometricKey}_$userId';
      
      final biometricProfile = BiometricProfile(
        id: _generateSecureId(),
        userId: userId,
        type: BiometricType.fingerprint,
        data: fingerprintData,
        description: description ?? 'Primary fingerprint',
        enrolledAt: DateTime.now(),
        lastUsed: DateTime.now(),
        isActive: true,
        confidence: 0.95,
      );
      
      await prefs.setString(biometricKey, json.encode(biometricProfile.toJson()));
      
      _authStreamController.add(BiometricAuthEvent(
        id: _generateSecureId(),
        userId: userId,
        eventType: BiometricEventType.enrollment,
        biometricType: BiometricType.fingerprint,
        timestamp: DateTime.now(),
        success: true,
        details: 'Fingerprint enrolled successfully',
      ));
      
      print('✅ Fingerprint enrolled for user: $userId');
      return true;
      
    } catch (e) {
      print('Error enrolling fingerprint: $e');
      return false;
    }
  }

  // Enroll face recognition
  Future<bool> enrollFaceRecognition({
    required String userId,
    required String faceData,
    String? description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricKey = '${_biometricKey}_$userId';
      
      final biometricProfile = BiometricProfile(
        id: _generateSecureId(),
        userId: userId,
        type: BiometricType.face,
        data: faceData,
        description: description ?? 'Primary face recognition',
        enrolledAt: DateTime.now(),
        lastUsed: DateTime.now(),
        isActive: true,
        confidence: 0.92,
      );
      
      await prefs.setString(biometricKey, json.encode(biometricProfile.toJson()));
      
      _authStreamController.add(BiometricAuthEvent(
        id: _generateSecureId(),
        userId: userId,
        eventType: BiometricEventType.enrollment,
        biometricType: BiometricType.face,
        timestamp: DateTime.now(),
        success: true,
        details: 'Face recognition enrolled successfully',
      ));
      
      print('✅ Face recognition enrolled for user: $userId');
      return true;
      
    } catch (e) {
      print('Error enrolling face recognition: $e');
      return false;
    }
  }

  // Authenticate with fingerprint
  Future<BiometricAuthResult> authenticateWithFingerprint({
    required String userId,
    required String fingerprintData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricKey = '${_biometricKey}_$userId';
      
      final biometricJson = prefs.getString(biometricKey);
      if (biometricJson == null) {
        return BiometricAuthResult(
          success: false,
          message: 'No biometric profile found',
          confidence: 0.0,
          attempts: 0,
        );
      }
      
      final biometricProfile = BiometricProfile.fromJson(json.decode(biometricJson));
      
      if (biometricProfile.type != BiometricType.fingerprint) {
        return BiometricAuthResult(
          success: false,
          message: 'Fingerprint not enrolled',
          confidence: 0.0,
          attempts: 0,
        );
      }
      
      // Simulate fingerprint matching
      final matchResult = await _simulateFingerprintMatch(
        storedData: biometricProfile.data,
        providedData: fingerprintData,
      );
      
      if (matchResult.success) {
        // Update last used timestamp
        final updatedProfile = biometricProfile.copyWith(
          lastUsed: DateTime.now(),
          confidence: matchResult.confidence,
        );
        
        await prefs.setString(biometricKey, json.encode(updatedProfile.toJson()));
        
        _authStreamController.add(BiometricAuthEvent(
          id: _generateSecureId(),
          userId: userId,
          eventType: BiometricEventType.authentication,
          biometricType: BiometricType.fingerprint,
          timestamp: DateTime.now(),
          success: true,
          details: 'Fingerprint authentication successful',
        ));
        
        return BiometricAuthResult(
          success: true,
          message: 'Authentication successful',
          confidence: matchResult.confidence,
          attempts: 1,
        );
      } else {
        _authStreamController.add(BiometricAuthEvent(
          id: _generateSecureId(),
          userId: userId,
          eventType: BiometricEventType.authentication,
          biometricType: BiometricType.fingerprint,
          timestamp: DateTime.now(),
          success: false,
          details: 'Fingerprint authentication failed',
        ));
        
        await _checkSuspiciousBiometricActivity(userId);
        
        return BiometricAuthResult(
          success: false,
          message: 'Authentication failed',
          confidence: matchResult.confidence,
          attempts: 1,
        );
      }
      
    } catch (e) {
      print('Error authenticating with fingerprint: $e');
      return BiometricAuthResult(
        success: false,
        message: 'Authentication error: $e',
        confidence: 0.0,
        attempts: 0,
      );
    }
  }

  // Authenticate with face recognition
  Future<BiometricAuthResult> authenticateWithFace({
    required String userId,
    required String faceData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricKey = '${_biometricKey}_$userId';
      
      final biometricJson = prefs.getString(biometricKey);
      if (biometricJson == null) {
        return BiometricAuthResult(
          success: false,
          message: 'No biometric profile found',
          confidence: 0.0,
          attempts: 0,
        );
      }
      
      final biometricProfile = BiometricProfile.fromJson(json.decode(biometricJson));
      
      if (biometricProfile.type != BiometricType.face) {
        return BiometricAuthResult(
          success: false,
          message: 'Face recognition not enrolled',
          confidence: 0.0,
          attempts: 0,
        );
      }
      
      // Simulate face recognition matching
      final matchResult = await _simulateFaceRecognitionMatch(
        storedData: biometricProfile.data,
        providedData: faceData,
      );
      
      if (matchResult.success) {
        final updatedProfile = biometricProfile.copyWith(
          lastUsed: DateTime.now(),
          confidence: matchResult.confidence,
        );
        
        await prefs.setString(biometricKey, json.encode(updatedProfile.toJson()));
        
        _authStreamController.add(BiometricAuthEvent(
          id: _generateSecureId(),
          userId: userId,
          eventType: BiometricEventType.authentication,
          biometricType: BiometricType.face,
          timestamp: DateTime.now(),
          success: true,
          details: 'Face recognition authentication successful',
        ));
        
        return BiometricAuthResult(
          success: true,
          message: 'Authentication successful',
          confidence: matchResult.confidence,
          attempts: 1,
        );
      } else {
        _authStreamController.add(BiometricAuthEvent(
          id: _generateSecureId(),
          userId: userId,
          eventType: BiometricEventType.authentication,
          biometricType: BiometricType.face,
          timestamp: DateTime.now(),
          success: false,
          details: 'Face recognition authentication failed',
        ));
        
        await _checkSuspiciousBiometricActivity(userId);
        
        return BiometricAuthResult(
          success: false,
          message: 'Authentication failed',
          confidence: matchResult.confidence,
          attempts: 1,
        );
      }
      
    } catch (e) {
      print('Error authenticating with face recognition: $e');
      return BiometricAuthResult(
        success: false,
        message: 'Authentication error: $e',
        confidence: 0.0,
        attempts: 0,
      );
    }
  }

  // Simulate fingerprint matching
  Future<BiometricMatchResult> _simulateFingerprintMatch({
    required String storedData,
    required String providedData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final random = Random();
    
    if (storedData == providedData) {
      return BiometricMatchResult(
        success: true,
        confidence: 0.98 + random.nextDouble() * 0.02,
        matchScore: 0.95 + random.nextDouble() * 0.05,
      );
    } else {
      final similarity = _calculateSimilarity(storedData, providedData);
      
      if (similarity > 0.85) {
        return BiometricMatchResult(
          success: true,
          confidence: 0.85 + random.nextDouble() * 0.1,
          matchScore: similarity,
        );
      } else {
        return BiometricMatchResult(
          success: false,
          confidence: similarity,
          matchScore: similarity,
        );
      }
    }
  }

  // Simulate face recognition matching
  Future<BiometricMatchResult> _simulateFaceRecognitionMatch({
    required String storedData,
    required String providedData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final random = Random();
    
    if (storedData == providedData) {
      return BiometricMatchResult(
        success: true,
        confidence: 0.95 + random.nextDouble() * 0.05,
        matchScore: 0.92 + random.nextDouble() * 0.08,
      );
    } else {
      final similarity = _calculateSimilarity(storedData, providedData);
      
      if (similarity > 0.80) {
        return BiometricMatchResult(
          success: true,
          confidence: 0.80 + random.nextDouble() * 0.15,
          matchScore: similarity,
        );
      } else {
        return BiometricMatchResult(
          success: false,
          confidence: similarity,
          matchScore: similarity,
        );
      }
    }
  }

  // Calculate similarity
  double _calculateSimilarity(String data1, String data2) {
    if (data1 == data2) return 1.0;
    
    final length1 = data1.length;
    final length2 = data2.length;
    
    if (length1 == 0 || length2 == 0) return 0.0;
    
    int matches = 0;
    final minLength = length1 < length2 ? length1 : length2;
    
    for (int i = 0; i < minLength; i++) {
      if (data1[i] == data2[i]) matches++;
    }
    
    return matches / minLength;
  }

  // Check for suspicious activity
  Future<void> _checkSuspiciousBiometricActivity(String userId) async {
    try {
      final recentEvents = await _getRecentBiometricEvents(userId, hours: 1);
      
      final failedAttempts = recentEvents.where((e) => 
        e.eventType == BiometricEventType.authentication && 
        !e.success
      ).length;
      
      if (failedAttempts > 3) {
        await _triggerBiometricAlert(
          userId: userId,
          alertType: 'multiple_failed_attempts',
          severity: BiometricAlertSeverity.high,
          details: 'Multiple failed biometric authentication attempts',
        );
      }
      
    } catch (e) {
      print('Error checking suspicious biometric activity: $e');
    }
  }

  // Get recent biometric events
  Future<List<BiometricAuthEvent>> _getRecentBiometricEvents(String userId, {int hours = 24}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsKey = 'biometric_events_$userId';
      
      final eventsJson = prefs.getString(eventsKey);
      if (eventsJson == null) return [];
      
      final events = List<Map<String, dynamic>>.from(json.decode(eventsJson));
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      
      return events
          .where((entry) => DateTime.parse(entry['timestamp']).isAfter(cutoffTime))
          .map((json) => BiometricAuthEvent.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting recent biometric events: $e');
      return [];
    }
  }

  // Trigger biometric alert
  Future<void> _triggerBiometricAlert({
    required String userId,
    required String alertType,
    required BiometricAlertSeverity severity,
    String? details,
  }) async {
    try {
      final alert = BiometricAlert(
        id: _generateSecureId(),
        timestamp: DateTime.now(),
        userId: userId,
        alertType: alertType,
        severity: severity,
        details: details,
        status: BiometricAlertStatus.active,
      );
      
      _alertStreamController.add(alert);
      print('🚨 BIOMETRIC ALERT: $alertType for user $userId - $severity');
      
    } catch (e) {
      print('Error triggering biometric alert: $e');
    }
  }

  // Get biometric profile
  Future<BiometricProfile?> getBiometricProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricKey = '${_biometricKey}_$userId';
      
      final biometricJson = prefs.getString(biometricKey);
      if (biometricJson == null) return null;
      
      return BiometricProfile.fromJson(json.decode(biometricJson));
    } catch (e) {
      print('Error getting biometric profile: $e');
      return null;
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
    _authStreamController.close();
    _alertStreamController.close();
  }
}

// Data classes
class BiometricProfile {
  final String id;
  final String userId;
  final BiometricType type;
  final String data;
  final String description;
  final DateTime enrolledAt;
  final DateTime lastUsed;
  final bool isActive;
  final double confidence;

  const BiometricProfile({
    required this.id,
    required this.userId,
    required this.type,
    required this.data,
    required this.description,
    required this.enrolledAt,
    required this.lastUsed,
    required this.isActive,
    required this.confidence,
  });

  BiometricProfile copyWith({
    String? id,
    String? userId,
    BiometricType? type,
    String? data,
    String? description,
    DateTime? enrolledAt,
    DateTime? lastUsed,
    bool? isActive,
    double? confidence,
  }) {
    return BiometricProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      data: data ?? this.data,
      description: description ?? this.description,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isActive: isActive ?? this.isActive,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'data': data,
      'description': description,
      'enrolledAt': enrolledAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'isActive': isActive,
      'confidence': confidence,
    };
  }

  factory BiometricProfile.fromJson(Map<String, dynamic> json) {
    return BiometricProfile(
      id: json['id'],
      userId: json['userId'],
      type: BiometricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BiometricType.fingerprint,
      ),
      data: json['data'],
      description: json['description'],
      enrolledAt: DateTime.parse(json['enrolledAt']),
      lastUsed: DateTime.parse(json['lastUsed']),
      isActive: json['isActive'],
      confidence: json['confidence'].toDouble(),
    );
  }
}

enum BiometricType {
  fingerprint,
  face,
  iris,
  voice,
}

class BiometricAuthResult {
  final bool success;
  final String message;
  final double confidence;
  final int attempts;

  const BiometricAuthResult({
    required this.success,
    required this.message,
    required this.confidence,
    required this.attempts,
  });
}

class BiometricMatchResult {
  final bool success;
  final double confidence;
  final double matchScore;

  const BiometricMatchResult({
    required this.success,
    required this.confidence,
    required this.matchScore,
  });
}

class BiometricAuthEvent {
  final String id;
  final String userId;
  final BiometricEventType eventType;
  final BiometricType biometricType;
  final DateTime timestamp;
  final bool success;
  final String? details;

  const BiometricAuthEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.biometricType,
    required this.timestamp,
    required this.success,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType.name,
      'biometricType': biometricType.name,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'details': details,
    };
  }

  factory BiometricAuthEvent.fromJson(Map<String, dynamic> json) {
    return BiometricAuthEvent(
      id: json['id'],
      userId: json['userId'],
      eventType: BiometricEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => BiometricEventType.authentication,
      ),
      biometricType: BiometricType.values.firstWhere(
        (e) => e.name == json['biometricType'],
        orElse: () => BiometricType.fingerprint,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'],
      details: json['details'],
    );
  }
}

enum BiometricEventType {
  enrollment,
  authentication,
  deletion,
  update,
}

class BiometricAlert {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String alertType;
  final BiometricAlertSeverity severity;
  final String? details;
  final BiometricAlertStatus status;

  const BiometricAlert({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.alertType,
    required this.severity,
    this.details,
    required this.status,
  });
}

enum BiometricAlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum BiometricAlertStatus {
  active,
  acknowledged,
  resolved,
  false_positive,
}
