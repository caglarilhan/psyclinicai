import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureFieldsService
/// - PII (Personally Identifiable Information) alanlarını AES-256 ile şifreler.
/// - Local: flutter_secure_storage (keychain/keystore)
/// - Server: at-rest encryption için hazır JSON
class SecureFieldsService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _keyPrefix = 'secure_field_';
  static const String _masterKeyName = 'master_key';

  /// Master key oluştur veya al
  static Future<Key> _getOrCreateMasterKey() async {
    final existingKey = await _storage.read(key: _masterKeyName);
    if (existingKey != null) {
      return Key.fromBase64(existingKey);
    }

    // Yeni master key oluştur
    final key = Key.fromSecureRandom(32); // AES-256
    await _storage.write(key: _masterKeyName, value: key.base64);
    return key;
  }

  /// PII alanını şifrele ve kaydet
  static Future<void> encryptAndStore(String fieldName, String value) async {
    if (value.isEmpty) return;

    try {
      final masterKey = await _getOrCreateMasterKey();
      final encrypter = Encrypter(AES(masterKey));
      final iv = IV.fromSecureRandom(16);
      
      final encrypted = encrypter.encrypt(value, iv: iv);
      final encryptedData = {
        'data': encrypted.base64,
        'iv': iv.base64,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _storage.write(
        key: _keyPrefix + fieldName,
        value: jsonEncode(encryptedData),
      );
    } catch (e) {
      throw Exception('Şifreleme hatası: $e');
    }
  }

  /// PII alanını çöz ve getir
  static Future<String?> decryptAndRetrieve(String fieldName) async {
    try {
      final encryptedJson = await _storage.read(key: _keyPrefix + fieldName);
      if (encryptedJson == null) return null;

      final encryptedData = jsonDecode(encryptedJson) as Map<String, dynamic>;
      final masterKey = await _getOrCreateMasterKey();
      final encrypter = Encrypter(AES(masterKey));
      
      final encrypted = Encrypted.fromBase64(encryptedData['data'] as String);
      final iv = IV.fromBase64(encryptedData['iv'] as String);
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Şifre çözme hatası: $e');
    }
  }

  /// PII alanını sil
  static Future<void> deleteField(String fieldName) async {
    await _storage.delete(key: _keyPrefix + fieldName);
  }

  /// Tüm şifreli alanları listele (field name'ler)
  static Future<List<String>> listEncryptedFields() async {
    final allKeys = await _storage.readAll();
    return allKeys.keys
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.substring(_keyPrefix.length))
        .toList();
  }

  /// Server için şifreli JSON hazırla (at-rest encryption)
  static Future<Map<String, dynamic>> prepareForServer(String fieldName, String value) async {
    if (value.isEmpty) return {};

    try {
      final masterKey = await _getOrCreateMasterKey();
      final encrypter = Encrypter(AES(masterKey));
      final iv = IV.fromSecureRandom(16);
      
      final encrypted = encrypter.encrypt(value, iv: iv);
      
      return {
        'field': fieldName,
        'encrypted_data': encrypted.base64,
        'iv': iv.base64,
        'algorithm': 'AES-256-GCM',
        'timestamp': DateTime.now().toIso8601String(),
        'hash': sha256.convert(utf8.encode(value)).toString(), // Integrity check
      };
    } catch (e) {
      throw Exception('Server şifreleme hatası: $e');
    }
  }

  /// Server'dan gelen şifreli veriyi çöz
  static Future<String?> decryptFromServer(Map<String, dynamic> serverData) async {
    try {
      final masterKey = await _getOrCreateMasterKey();
      final encrypter = Encrypter(AES(masterKey));
      
      final encrypted = Encrypted.fromBase64(serverData['encrypted_data'] as String);
      final iv = IV.fromBase64(serverData['iv'] as String);
      
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      // Integrity check
      final expectedHash = serverData['hash'] as String;
      final actualHash = sha256.convert(utf8.encode(decrypted)).toString();
      
      if (expectedHash != actualHash) {
        throw Exception('Veri bütünlüğü hatası');
      }
      
      return decrypted;
    } catch (e) {
      throw Exception('Server şifre çözme hatası: $e');
    }
  }

  /// Güvenlik durumu raporu
  static Future<Map<String, dynamic>> getSecurityStatus() async {
    final fields = await listEncryptedFields();
    final masterKeyExists = await _storage.read(key: _masterKeyName) != null;
    
    return {
      'master_key_exists': masterKeyExists,
      'encrypted_fields_count': fields.length,
      'encrypted_fields': fields,
      'last_check': DateTime.now().toIso8601String(),
    };
  }

  /// Tüm şifreli verileri temizle (güvenlik)
  static Future<void> clearAllEncryptedData() async {
    final allKeys = await _storage.readAll();
    final keysToDelete = allKeys.keys
        .where((key) => key.startsWith(_keyPrefix) || key == _masterKeyName)
        .toList();
    
    for (final key in keysToDelete) {
      await _storage.delete(key: key);
    }
  }
}

/// PII alan türleri
enum PIIFieldType {
  phone,
  email,
  address,
  idNumber,
  insuranceNumber,
  emergencyContact,
  notes,
}

/// PII alan yardımcıları
class PIIFieldHelper {
  static const Map<PIIFieldType, String> _fieldNames = {
    PIIFieldType.phone: 'phone',
    PIIFieldType.email: 'email',
    PIIFieldType.address: 'address',
    PIIFieldType.idNumber: 'id_number',
    PIIFieldType.insuranceNumber: 'insurance_number',
    PIIFieldType.emergencyContact: 'emergency_contact',
    PIIFieldType.notes: 'notes',
  };

  static String getFieldName(PIIFieldType type) => _fieldNames[type]!;

  static Future<void> encryptField(PIIFieldType type, String value) async {
    await SecureFieldsService.encryptAndStore(getFieldName(type), value);
  }

  static Future<String?> decryptField(PIIFieldType type) async {
    return await SecureFieldsService.decryptAndRetrieve(getFieldName(type));
  }

  static Future<void> deleteField(PIIFieldType type) async {
    await SecureFieldsService.deleteField(getFieldName(type));
  }
}

