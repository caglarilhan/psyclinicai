import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Stream controllers
  final StreamController<BiometricStatus> _statusController = StreamController<BiometricStatus>.broadcast();
  final StreamController<AuthResult> _authResultController = StreamController<AuthResult>.broadcast();
  
  // Streams
  Stream<BiometricStatus> get statusStream => _statusController.stream;
  Stream<AuthResult> get authResultStream => _authResultController.stream;

  // Biometric status
  BiometricStatus _currentStatus = BiometricStatus.unknown;
  bool _isInitialized = false;

  // Getters
  BiometricStatus get currentStatus => _currentStatus;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      // Biometric availability kontrolü
      await _checkBiometricAvailability();
      
      // Biometric settings'i yükle
      await _loadBiometricSettings();
      
      _isInitialized = true;
      print('BiometricAuthService initialized successfully');
    } catch (e) {
      print('BiometricAuthService initialization failed: $e');
      _currentStatus = BiometricStatus.notAvailable;
      _statusController.add(_currentStatus);
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Biometric hardware support kontrolü
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!isDeviceSupported) {
        _currentStatus = BiometricStatus.notSupported;
        _statusController.add(_currentStatus);
        return;
      }

      // Available biometrics kontrolü
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        _currentStatus = BiometricStatus.notAvailable;
        _statusController.add(_currentStatus);
        return;
      }

      // Biometric type'ları kontrol et
      final hasFingerprint = availableBiometrics.contains(BiometricType.fingerprint);
      final hasFace = availableBiometrics.contains(BiometricType.face);
      final hasIris = availableBiometrics.contains(BiometricType.iris);

      if (hasFingerprint || hasFace || hasIris) {
        _currentStatus = BiometricStatus.available;
        _statusController.add(_currentStatus);
      } else {
        _currentStatus = BiometricStatus.notAvailable;
        _statusController.add(_currentStatus);
      }

    } catch (e) {
      print('Error checking biometric availability: $e');
      _currentStatus = BiometricStatus.error;
      _statusController.add(_currentStatus);
    }
  }

  Future<void> _loadBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Biometric enabled setting
    final isEnabled = prefs.getBool('biometric_enabled') ?? false;
    
    if (isEnabled && _currentStatus == BiometricStatus.available) {
      _currentStatus = BiometricStatus.enabled;
      _statusController.add(_currentStatus);
    }
  }

  // Biometric authentication
  Future<AuthResult> authenticate({
    required String reason,
    String? cancelButton,
    String? localizedFallbackTitle,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool biometricOnly = true,
  }) async {
    try {
      if (_currentStatus != BiometricStatus.available && 
          _currentStatus != BiometricStatus.enabled) {
        return AuthResult(
          success: false,
          error: 'Biometric authentication is not available',
          errorCode: 'not_available',
        );
      }

      // Authentication options
      final authOptions = AuthenticationOptions(
        biometricOnly: biometricOnly,
        stickyAuth: stickyAuth,
        useErrorDialogs: useErrorDialogs,
      );

      // Localized strings
      final localizedStrings = LocalizedStrings(
        cancelButton: cancelButton ?? 'İptal',
        localizedFallbackTitle: localizedFallbackTitle ?? 'Şifre Kullan',
      );

      // Authentication attempt
      final success = await _localAuth.authenticate(
        localizedReason: reason,
        options: authOptions,
      );

      if (success) {
        // Başarılı authentication sonrası
        await _onSuccessfulAuth();
        
        final result = AuthResult(
          success: true,
          error: null,
          errorCode: null,
        );
        
        _authResultController.add(result);
        return result;
      } else {
        final result = AuthResult(
          success: false,
          error: 'Authentication cancelled by user',
          errorCode: 'user_cancelled',
        );
        
        _authResultController.add(result);
        return result;
      }

    } on PlatformException catch (e) {
      final errorCode = _mapPlatformException(e.code);
      final errorMessage = _getErrorMessage(errorCode);
      
      final result = AuthResult(
        success: false,
        error: errorMessage,
        errorCode: errorCode,
      );
      
      _authResultController.add(result);
      return result;
    } catch (e) {
      final result = AuthResult(
        success: false,
        error: 'Unexpected error: $e',
        errorCode: 'unknown_error',
      );
      
      _authResultController.add(result);
      return result;
    }
  }

  // Fingerprint authentication (specific)
  Future<AuthResult> authenticateWithFingerprint({
    required String reason,
    bool stickyAuth = false,
  }) async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (!availableBiometrics.contains(BiometricType.fingerprint)) {
        return AuthResult(
          success: false,
          error: 'Fingerprint authentication is not available',
          errorCode: 'fingerprint_not_available',
        );
      }

      return await authenticate(
        reason: reason,
        stickyAuth: stickyAuth,
        biometricOnly: true,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Fingerprint authentication failed: $e',
        errorCode: 'fingerprint_error',
      );
    }
  }

  // Face authentication (specific)
  Future<AuthResult> authenticateWithFace({
    required String reason,
    bool stickyAuth = false,
  }) async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (!availableBiometrics.contains(BiometricType.face)) {
        return AuthResult(
          success: false,
          error: 'Face authentication is not available',
          errorCode: 'face_not_available',
        );
      }

      return await authenticate(
        reason: reason,
        stickyAuth: stickyAuth,
        biometricOnly: true,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Face authentication failed: $e',
        errorCode: 'face_error',
      );
    }
  }

  // Iris authentication (specific)
  Future<AuthResult> authenticateWithIris({
    required String reason,
    bool stickyAuth = false,
  }) async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (!availableBiometrics.contains(BiometricType.iris)) {
        return AuthResult(
          success: false,
          error: 'Iris authentication is not available',
          errorCode: 'iris_not_available',
        );
      }

      return await authenticate(
        reason: reason,
        stickyAuth: stickyAuth,
        biometricOnly: true,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Iris authentication failed: $e',
        errorCode: 'iris_error',
      );
    }
  }

  // Biometric settings management
  Future<void> enableBiometric() async {
    if (_currentStatus != BiometricStatus.available) {
      throw Exception('Biometric authentication is not available');
    }

    // Test authentication
    final testResult = await authenticate(
      reason: 'Biometric authentication\'ı etkinleştirmek için kimlik doğrulaması yapın',
      cancelButton: 'İptal',
    );

    if (testResult.success) {
      // Settings'i kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', true);
      
      // Status'u güncelle
      _currentStatus = BiometricStatus.enabled;
      _statusController.add(_currentStatus);
      
      print('Biometric authentication enabled successfully');
    } else {
      throw Exception('Biometric test failed: ${testResult.error}');
    }
  }

  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', false);
    
    _currentStatus = BiometricStatus.available;
    _statusController.add(_currentStatus);
    
    print('Biometric authentication disabled');
  }

  Future<void> resetBiometric() async {
    try {
      // Biometric data'yı temizle
      await _localAuth.stopAuthentication();
      
      // Settings'i sıfırla
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('biometric_enabled');
      await prefs.remove('biometric_last_used');
      
      // Status'u güncelle
      _currentStatus = BiometricStatus.available;
      _statusController.add(_currentStatus);
      
      print('Biometric authentication reset successfully');
    } catch (e) {
      print('Error resetting biometric: $e');
    }
  }

  // Biometric usage tracking
  Future<void> _onSuccessfulAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    
    await prefs.setString('biometric_last_used', now);
    
    // Usage statistics
    final usageCount = prefs.getInt('biometric_usage_count') ?? 0;
    await prefs.setInt('biometric_usage_count', usageCount + 1);
  }

  // Biometric statistics
  Future<BiometricStats> getBiometricStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    final lastUsed = prefs.getString('biometric_last_used');
    final usageCount = prefs.getInt('biometric_usage_count') ?? 0;
    final isEnabled = prefs.getBool('biometric_enabled') ?? false;
    
    return BiometricStats(
      isEnabled: isEnabled,
      lastUsed: lastUsed != null ? DateTime.parse(lastUsed) : null,
      usageCount: usageCount,
      status: _currentStatus,
    );
  }

  // Security level assessment
  Future<SecurityLevel> assessSecurityLevel() async {
    if (_currentStatus != BiometricStatus.enabled) {
      return SecurityLevel.none;
    }

    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.iris)) {
        return SecurityLevel.high; // Iris en güvenli
      } else if (availableBiometrics.contains(BiometricType.face)) {
        return SecurityLevel.medium; // Face orta güvenli
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return SecurityLevel.medium; // Fingerprint orta güvenli
      } else {
        return SecurityLevel.low;
      }
    } catch (e) {
      return SecurityLevel.low;
    }
  }

  // Biometric health check
  Future<BiometricHealth> checkBiometricHealth() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      final health = BiometricHealth(
        isDeviceSupported: isDeviceSupported,
        availableBiometrics: availableBiometrics,
        status: _currentStatus,
        lastCheck: DateTime.now(),
        isHealthy: _currentStatus == BiometricStatus.available || 
                   _currentStatus == BiometricStatus.enabled,
      );
      
      return health;
    } catch (e) {
      return BiometricHealth(
        isDeviceSupported: false,
        availableBiometrics: [],
        status: _currentStatus,
        lastCheck: DateTime.now(),
        isHealthy: false,
        error: e.toString(),
      );
    }
  }

  // Platform exception mapping
  String _mapPlatformException(String code) {
    switch (code) {
      case 'NotAvailable':
        return 'not_available';
      case 'NotEnrolled':
        return 'not_enrolled';
      case 'LockedOut':
        return 'locked_out';
      case 'PermanentlyLockedOut':
        return 'permanently_locked_out';
      case 'PasscodeNotSet':
        return 'passcode_not_set';
      case 'UserCancel':
        return 'user_cancelled';
      case 'AuthenticationFailed':
        return 'authentication_failed';
      case 'UserFallback':
        return 'user_fallback';
      case 'SystemCancel':
        return 'system_cancelled';
      case 'InvalidContext':
        return 'invalid_context';
      default:
        return 'unknown_error';
    }
  }

  // Error message mapping
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'not_available':
        return 'Biyometrik kimlik doğrulama mevcut değil';
      case 'not_enrolled':
        return 'Biyometrik veri kaydedilmemiş';
      case 'locked_out':
        return 'Çok fazla başarısız deneme. Lütfen bekleyin';
      case 'permanently_locked_out':
        return 'Biyometrik kimlik doğrulama kalıcı olarak kilitlendi';
      case 'passcode_not_set':
        return 'Cihaz şifresi ayarlanmamış';
      case 'user_cancelled':
        return 'Kullanıcı tarafından iptal edildi';
      case 'authentication_failed':
        return 'Kimlik doğrulama başarısız';
      case 'user_fallback':
        return 'Kullanıcı alternatif yöntem seçti';
      case 'system_cancelled':
        return 'Sistem tarafından iptal edildi';
      case 'invalid_context':
        return 'Geçersiz kimlik doğrulama bağlamı';
      default:
        return 'Bilinmeyen hata oluştu';
    }
  }

  // Biometric enrollment check
  Future<bool> isBiometricEnrolled() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Biometric type detection
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Biometric strength assessment
  Future<BiometricStrength> assessBiometricStrength() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.iris)) {
        return BiometricStrength.veryStrong;
      } else if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricStrength.strong;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricStrength.medium;
      } else {
        return BiometricStrength.weak;
      }
    } catch (e) {
      return BiometricStrength.weak;
    }
  }

  void dispose() {
    _statusController.close();
    _authResultController.close();
  }
}

// Data classes
class AuthResult {
  final bool success;
  final String? error;
  final String? errorCode;

  AuthResult({
    required this.success,
    this.error,
    this.errorCode,
  });
}

class BiometricStats {
  final bool isEnabled;
  final DateTime? lastUsed;
  final int usageCount;
  final BiometricStatus status;

  BiometricStats({
    required this.isEnabled,
    this.lastUsed,
    required this.usageCount,
    required this.status,
  });
}

class BiometricHealth {
  final bool isDeviceSupported;
  final List<BiometricType> availableBiometrics;
  final BiometricStatus status;
  final DateTime lastCheck;
  final bool isHealthy;
  final String? error;

  BiometricHealth({
    required this.isDeviceSupported,
    required this.availableBiometrics,
    required this.status,
    required this.lastCheck,
    required this.isHealthy,
    this.error,
  });
}

// Enums
enum BiometricStatus {
  unknown,
  notSupported,
  notAvailable,
  available,
  enabled,
  error,
}

enum SecurityLevel {
  none,
  low,
  medium,
  high,
}

enum BiometricStrength {
  weak,
  medium,
  strong,
  veryStrong,
}

// Localized strings for different languages
class LocalizedStrings {
  final String cancelButton;
  final String localizedFallbackTitle;

  LocalizedStrings({
    required this.cancelButton,
    required this.localizedFallbackTitle,
  });
}
