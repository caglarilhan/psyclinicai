import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorAuthService {
  static final TwoFactorAuthService _instance = TwoFactorAuthService._internal();
  factory TwoFactorAuthService() => _instance;
  TwoFactorAuthService._internal();

  // 2FA durumu
  bool _isEnabled = false;
  String? _secretKey;
  List<String> _backupCodes = [];
  String? _phoneNumber;
  String? _email;

  // Getter'lar
  bool get isEnabled => _isEnabled;
  String? get secretKey => _secretKey;
  List<String> get backupCodes => List.unmodifiable(_backupCodes);
  String? get phoneNumber => _phoneNumber;
  String? get email => _email;

  // 2FA'yı etkinleştir
  Future<bool> enable2FA({
    required String method,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      // Secret key oluştur
      _secretKey = _generateSecretKey();
      
      // Backup codes oluştur
      _backupCodes = _generateBackupCodes();
      
      // Method'u kaydet
      if (method == 'sms' && phoneNumber != null) {
        _phoneNumber = phoneNumber;
      } else if (method == 'email' && email != null) {
        _email = email;
      }
      
      _isEnabled = true;
      
      // SharedPreferences'a kaydet
      await _save2FASettings();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // 2FA'yı devre dışı bırak
  Future<bool> disable2FA() async {
    try {
      _isEnabled = false;
      _secretKey = null;
      _backupCodes.clear();
      _phoneNumber = null;
      _email = null;
      
      await _save2FASettings();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // TOTP kodu oluştur
  String generateTOTP() {
    if (_secretKey == null) return '';
    
    final now = DateTime.now();
    final timeStep = 30; // 30 saniye
    final counter = (now.millisecondsSinceEpoch / 1000 / timeStep).floor();
    
    return _generateHOTP(counter.toString());
  }

  // TOTP kodu doğrula
  bool verifyTOTP(String code) {
    if (_secretKey == null) return false;
    
    final currentCode = generateTOTP();
    final previousCode = _generateHOTP(
      ((DateTime.now().millisecondsSinceEpoch / 1000 / 30).floor() - 1).toString()
    );
    final nextCode = _generateHOTP(
      ((DateTime.now().millisecondsSinceEpoch / 1000 / 30).floor() + 1).toString()
    );
    
    return code == currentCode || code == previousCode || code == nextCode;
  }

  // SMS kodu gönder
  Future<bool> sendSMSCode() async {
    if (_phoneNumber == null) return false;
    
    try {
      final code = _generateRandomCode(6);
      // TODO: SMS gönderme implementasyonu
      
      // Demo için SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sms_code', code);
      await prefs.setInt('sms_code_expiry', DateTime.now().add(Duration(minutes: 5)).millisecondsSinceEpoch);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Email kodu gönder
  Future<bool> sendEmailCode() async {
    if (_email == null) return false;
    
    try {
      final code = _generateRandomCode(6);
      // TODO: Email gönderme implementasyonu
      
      // Demo için SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email_code', code);
      await prefs.setInt('email_code_expiry', DateTime.now().add(Duration(minutes: 5)).millisecondsSinceEpoch);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // SMS kodu doğrula
  Future<bool> verifySMSCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('sms_code');
      final expiry = prefs.getInt('sms_code_expiry');
      
      if (savedCode == null || expiry == null) return false;
      
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await prefs.remove('sms_code');
        await prefs.remove('sms_code_expiry');
        return false;
      }
      
      final isValid = code == savedCode;
      
      if (isValid) {
        await prefs.remove('sms_code');
        await prefs.remove('sms_code_expiry');
      }
      
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // Email kodu doğrula
  Future<bool> verifyEmailCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('email_code');
      final expiry = prefs.getInt('email_code_expiry');
      
      if (savedCode == null || expiry == null) return false;
      
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await prefs.remove('email_code');
        await prefs.remove('email_code_expiry');
        return false;
      }
      
      final isValid = code == savedCode;
      
      if (isValid) {
        await prefs.remove('email_code');
        await prefs.remove('email_code_expiry');
      }
      
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // Backup code doğrula
  bool verifyBackupCode(String code) {
    if (_backupCodes.contains(code)) {
      _backupCodes.remove(code);
      _save2FASettings();
      return true;
    }
    return false;
  }

  // QR Code data oluştur
  String generateQRCodeData() {
    if (_secretKey == null) return '';
    
    final issuer = 'PsyClinicAI';
    final account = _email ?? _phoneNumber ?? 'user';
    
    return 'otpauth://totp/$issuer:$account?secret=$_secretKey&issuer=$issuer';
  }

  // Secret key oluştur
  String _generateSecretKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base32.encode(bytes);
  }

  // Backup codes oluştur
  List<String> _generateBackupCodes() {
    final random = Random.secure();
    final codes = <String>[];
    
    for (int i = 0; i < 10; i++) {
      final code = List<int>.generate(8, (j) => random.nextInt(10)).join();
      codes.add(code);
    }
    
    return codes;
  }

  // Random kod oluştur
  String _generateRandomCode(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (i) => random.nextInt(10)).join();
  }

  // HOTP oluştur
  String _generateHOTP(String counter) {
    if (_secretKey == null) return '';
    
    final key = base32.decode(_secretKey!);
    final data = utf8.encode(counter.padLeft(16, '0'));
    
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(data);
    
    final offset = digest.bytes[digest.bytes.length - 1] & 0xf;
    final code = ((digest.bytes[offset] & 0x7f) << 24) |
                 ((digest.bytes[offset + 1] & 0xff) << 16) |
                 ((digest.bytes[offset + 2] & 0xff) << 8) |
                 (digest.bytes[offset + 3] & 0xff);
    
    return (code % 1000000).toString().padLeft(6, '0');
  }

  // Ayarları kaydet
  Future<void> _save2FASettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('2fa_enabled', _isEnabled);
    if (_secretKey != null) {
      await prefs.setString('2fa_secret', _secretKey!);
    }
    await prefs.setStringList('2fa_backup_codes', _backupCodes);
    if (_phoneNumber != null) {
      await prefs.setString('2fa_phone', _phoneNumber!);
    }
    if (_email != null) {
      await prefs.setString('2fa_email', _email!);
    }
  }

  // Ayarları yükle
  Future<void> load2FASettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('2fa_enabled') ?? false;
    _secretKey = prefs.getString('2fa_secret');
    _backupCodes = prefs.getStringList('2fa_backup_codes') ?? [];
    _phoneNumber = prefs.getString('2fa_phone');
    _email = prefs.getString('2fa_email');
  }

  // Yeni backup codes oluştur
  Future<List<String>> regenerateBackupCodes() async {
    _backupCodes.clear();
    _backupCodes.addAll(_generateBackupCodes());
    await _save2FASettings();
    return backupCodes;
  }

  // 2FA istatistikleri
  Map<String, dynamic> get2FAStats() {
    return {
      'isEnabled': _isEnabled,
      'method': _phoneNumber != null ? 'sms' : (_email != null ? 'email' : 'totp'),
      'backupCodesRemaining': _backupCodes.length,
      'lastUsed': null, // TODO: Implement usage tracking
    };
  }
}

// Base32 encoding için basit implementasyon
class base32 {
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  
  static String encode(List<int> bytes) {
    final buffer = StringBuffer();
    int bits = 0;
    int value = 0;
    
    for (int byte in bytes) {
      value = (value << 8) | byte;
      bits += 8;
      
      while (bits >= 5) {
        buffer.write(_alphabet[(value >> (bits - 5)) & 31]);
        bits -= 5;
      }
    }
    
    if (bits > 0) {
      buffer.write(_alphabet[(value << (5 - bits)) & 31]);
    }
    
    return buffer.toString();
  }
  
  static List<int> decode(String input) {
    final bytes = <int>[];
    int bits = 0;
    int value = 0;
    
    for (int char in input.toUpperCase().codeUnits) {
      final index = _alphabet.indexOf(String.fromCharCode(char));
      if (index == -1) continue;
      
      value = (value << 5) | index;
      bits += 5;
      
      while (bits >= 8) {
        bytes.add((value >> (bits - 8)) & 255);
        bits -= 8;
      }
    }
    
    return bytes;
  }
}
