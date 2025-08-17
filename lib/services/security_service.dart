import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' hide Key;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ai_logger.dart';
import '../models/security_models.dart';

class SecurityService extends ChangeNotifier {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final AILogger _logger = AILogger();
  
  // Encryption keys
  late Encrypter _encrypter;
  late IV _iv;
  late Key _key;
  
  // Security state
  bool _isInitialized = false;
  SecurityLevel _currentSecurityLevel = SecurityLevel.medium;
  List<AuditLog> _auditLogs = [];
  Map<String, UserRole> _userRoles = {};
  Map<String, List<String>> _permissions = {};
  
  // Security settings
  bool _encryptionEnabled = true;
  bool _auditLoggingEnabled = true;
  bool _roleBasedAccessEnabled = true;
  int _sessionTimeoutMinutes = 30;
  int _maxLoginAttempts = 5;
  int _lockoutDurationMinutes = 15;

  // Getters
  bool get isInitialized => _isInitialized;
  SecurityLevel get currentSecurityLevel => _currentSecurityLevel;
  List<AuditLog> get auditLogs => _auditLogs;
  bool get encryptionEnabled => _encryptionEnabled;
  bool get auditLoggingEnabled => _auditLoggingEnabled;
  bool get roleBasedAccessEnabled => _roleBasedAccessEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.info('SecurityService initializing...', context: 'SecurityService');
      
      // Initialize encryption
      await _initializeEncryption();
      
      // Load security settings
      await _loadSecuritySettings();
      
      // Initialize user roles and permissions
      await _initializeAccessControl();
      
      // Load audit logs
      await _loadAuditLogs();
      
      _isInitialized = true;
      _logger.info('SecurityService initialized successfully', context: 'SecurityService');
      
      // Log initialization
      await _logAuditEvent(
        AuditEventType.system,
        'SecurityService initialized',
        'SYSTEM',
        SecurityLevel.high,
      );
      
    } catch (e) {
      _logger.error('SecurityService initialization failed', context: 'SecurityService', error: e);
      rethrow;
    }
  }

  Future<void> _initializeEncryption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Generate or retrieve encryption key
      String? storedKey = prefs.getString('encryption_key');
      if (storedKey == null) {
        storedKey = _generateEncryptionKey();
        await prefs.setString('encryption_key', storedKey);
      }
      
      // Generate or retrieve IV
      String? storedIV = prefs.getString('encryption_iv');
      if (storedIV == null) {
        storedIV = _generateIV();
        await prefs.setString('encryption_iv', storedIV);
      }
      
      _key = Key(Uint8List.fromList(storedKey.codeUnits));
      _iv = IV(Uint8List.fromList(storedIV.codeUnits));
      _encrypter = Encrypter(AES(_key));
      
      _logger.info('Encryption initialized successfully', context: 'SecurityService');
    } catch (e) {
      _logger.error('Failed to initialize encryption', context: 'SecurityService', error: e);
      rethrow;
    }
  }

  String _generateEncryptionKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  String _generateIV() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _encryptionEnabled = prefs.getBool('encryption_enabled') ?? true;
      _auditLoggingEnabled = prefs.getBool('audit_logging_enabled') ?? true;
      _roleBasedAccessEnabled = prefs.getBool('role_based_access_enabled') ?? true;
      _sessionTimeoutMinutes = prefs.getInt('session_timeout_minutes') ?? 30;
      _maxLoginAttempts = prefs.getInt('max_login_attempts') ?? 5;
      _lockoutDurationMinutes = prefs.getInt('lockout_duration_minutes') ?? 15;
      
      _logger.info('Security settings loaded', context: 'SecurityService');
    } catch (e) {
      _logger.error('Failed to load security settings', context: 'SecurityService', error: e);
    }
  }

  Future<void> _initializeAccessControl() async {
    try {
      // Initialize default roles and permissions
      _userRoles = {
        'admin': UserRole.admin,
        'therapist': UserRole.therapist,
        'supervisor': UserRole.supervisor,
        'client': UserRole.client,
        'guest': UserRole.guest,
      };

      _permissions = {
        'admin': [
          'read:all',
          'write:all',
          'delete:all',
          'security:manage',
          'users:manage',
        ],
        'therapist': [
          'read:clients',
          'write:clients',
          'read:sessions',
          'write:sessions',
        ],
        'supervisor': [
          'read:all',
          'write:reports',
          'security:view',
        ],
        'client': [
          'read:own_data',
          'write:own_data',
        ],
        'guest': [
          'read:public',
        ],
      };
      
      _logger.info('Access control initialized', context: 'SecurityService');
    } catch (e) {
      _logger.error('Failed to initialize access control', context: 'SecurityService', error: e);
    }
  }

  Future<void> _loadAuditLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString('audit_logs');
      
      if (logsJson != null) {
        final List<dynamic> logsList = json.decode(logsJson);
        _auditLogs = logsList.map((log) => AuditLog.fromJson(log)).toList();
      }
      
      _logger.info('Audit logs loaded: ${_auditLogs.length} entries', context: 'SecurityService');
    } catch (e) {
      _logger.error('Failed to load audit logs', context: 'SecurityService', error: e);
    }
  }

  Future<void> _logAuditEvent(
    AuditEventType eventType,
    String description,
    String userId,
    SecurityLevel securityLevel, {
    String? resourceId,
    String? action,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_auditLoggingEnabled) return;

    try {
      final auditLog = AuditLog(
        id: _generateId(),
        userId: userId,
        userName: _getUserName(userId),
        eventType: eventType,
        eventDescription: description,
        timestamp: DateTime.now(),
        ipAddress: '127.0.0.1', // Mock IP
        userAgent: 'PsyClinicAI/1.0',
        metadata: metadata,
        securityLevel: securityLevel,
        isSuccessful: true,
      );

      _auditLogs.add(auditLog);
      
      // Save to local storage
      await _saveAuditLogs();
      
      // Notify listeners
      notifyListeners();
      
      _logger.info('Audit event logged: $description', context: 'SecurityService');
    } catch (e) {
      _logger.error('Failed to log audit event', context: 'SecurityService', error: e);
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
  }

  String _getUserName(String userId) {
    switch (userId) {
      case 'SYSTEM':
        return 'System';
      case 'demo_user_001':
        return 'Demo User';
      default:
        return 'Unknown User';
    }
  }

  Future<void> _saveAuditLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = json.encode(_auditLogs.map((log) => log.toJson()).toList());
      await prefs.setString('audit_logs', logsJson);
    } catch (e) {
      _logger.error('Failed to save audit logs', context: 'SecurityService', error: e);
    }
  }

  // Public methods
  Future<String> encryptData(String data) async {
    if (!_encryptionEnabled) return data;
    
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      _logger.error('Failed to encrypt data', context: 'SecurityService', error: e);
      rethrow;
    }
  }

  Future<String> decryptData(String encryptedData) async {
    if (!_encryptionEnabled) return encryptedData;
    
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      _logger.error('Failed to decrypt data', context: 'SecurityService', error: e);
      rethrow;
    }
  }

  bool hasPermission(String userId, String permission) {
    if (!_roleBasedAccessEnabled) return true;
    
    final userRole = _userRoles[userId];
    if (userRole == null) return false;
    
    final permissions = _permissions[userRole.name];
    return permissions?.contains(permission) ?? false;
  }

  bool canAccessResource(String userId, String resourceType, String action) {
    final permission = '$action:$resourceType';
    return hasPermission(userId, permission);
  }

  Future<SecurityAssessment> assessSecurity() async {
    try {
      final vulnerabilities = <SecurityVulnerability>[];
      final componentScores = <String, double>{};
      final recommendations = <String>[];
      
      // Assess encryption
      if (!_encryptionEnabled) {
        vulnerabilities.add(SecurityVulnerability(
          id: _generateId(),
          title: 'Encryption Disabled',
          description: 'Data encryption is currently disabled',
          type: VulnerabilityType.encryption,
          severity: VulnerabilitySeverity.high,
          discoveredAt: DateTime.now(),
          affectedComponents: ['data_storage', 'transmission'],
          riskScore: 8.5,
        ));
        componentScores['encryption'] = 0.0;
        recommendations.add('Enable data encryption for all sensitive data');
      } else {
        componentScores['encryption'] = 9.0;
      }
      
      // Assess audit logging
      if (!_auditLoggingEnabled) {
        vulnerabilities.add(SecurityVulnerability(
          id: _generateId(),
          title: 'Audit Logging Disabled',
          description: 'Audit logging is currently disabled',
          type: VulnerabilityType.configuration,
          severity: VulnerabilitySeverity.medium,
          discoveredAt: DateTime.now(),
          affectedComponents: ['compliance', 'security_monitoring'],
          riskScore: 6.0,
        ));
        componentScores['audit_logging'] = 0.0;
        recommendations.add('Enable audit logging for compliance and security monitoring');
      } else {
        componentScores['audit_logging'] = 8.5;
      }
      
      // Assess access control
      if (!_roleBasedAccessEnabled) {
        vulnerabilities.add(SecurityVulnerability(
          id: _generateId(),
          title: 'Role-Based Access Control Disabled',
          description: 'Role-based access control is currently disabled',
          type: VulnerabilityType.authorization,
          severity: VulnerabilitySeverity.high,
          discoveredAt: DateTime.now(),
          affectedComponents: ['user_management', 'data_access'],
          riskScore: 8.0,
        ));
        componentScores['access_control'] = 0.0;
        recommendations.add('Enable role-based access control');
      } else {
        componentScores['access_control'] = 8.0;
      }
      
      // Calculate overall score
      final scores = componentScores.values.toList();
      final overallScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
      
      // Determine overall security level
      SecurityLevel overallSecurityLevel;
      if (overallScore >= 9.0) {
        overallSecurityLevel = SecurityLevel.low;
      } else if (overallScore >= 7.0) {
        overallSecurityLevel = SecurityLevel.medium;
      } else if (overallScore >= 5.0) {
        overallSecurityLevel = SecurityLevel.high;
      } else {
        overallSecurityLevel = SecurityLevel.critical;
      }
      
      final assessment = SecurityAssessment(
        id: _generateId(),
        assessmentDate: DateTime.now(),
        overallSecurityLevel: overallSecurityLevel,
        overallScore: overallScore,
        vulnerabilities: vulnerabilities,
        componentScores: componentScores,
        recommendations: recommendations,
        notes: 'Security assessment completed automatically',
      );
      
      _logger.info('Security assessment completed: Score $overallScore', context: 'SecurityService');
      
      return assessment;
    } catch (e) {
      _logger.error('Failed to assess security', context: 'SecurityService', error: e);
      rethrow;
    }
  }

  Future<void> updateSecuritySettings({
    bool? encryptionEnabled,
    bool? auditLoggingEnabled,
    bool? roleBasedAccessEnabled,
    int? sessionTimeoutMinutes,
    int? maxLoginAttempts,
    int? lockoutDurationMinutes,
  }) async {
    try {
      if (encryptionEnabled != null) _encryptionEnabled = encryptionEnabled;
      if (auditLoggingEnabled != null) _auditLoggingEnabled = auditLoggingEnabled;
      if (roleBasedAccessEnabled != null) _roleBasedAccessEnabled = roleBasedAccessEnabled;
      if (sessionTimeoutMinutes != null) _sessionTimeoutMinutes = sessionTimeoutMinutes;
      if (maxLoginAttempts != null) _maxLoginAttempts = maxLoginAttempts;
      if (lockoutDurationMinutes != null) _lockoutDurationMinutes = lockoutDurationMinutes;
      
      // Save to local storage
      await _saveSecuritySettings();
      
      // Log the change
      await _logAuditEvent(
        AuditEventType.security,
        'Security settings updated',
        'SYSTEM',
        SecurityLevel.medium,
        metadata: {
          'encryption_enabled': _encryptionEnabled,
          'audit_logging_enabled': _auditLoggingEnabled,
          'role_based_access_enabled': _roleBasedAccessEnabled,
        },
      );
      
      // Notify listeners
      notifyListeners();
      
      _logger.info('Security settings updated', context: 'SecurityService');
    } catch (e) {
      _logger.error('Failed to update security settings', context: 'SecurityService', error: e);
      rethrow;
    }
  }

  Future<void> _saveSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('encryption_enabled', _encryptionEnabled);
      await prefs.setBool('audit_logging_enabled', _auditLoggingEnabled);
      await prefs.setBool('role_based_access_enabled', _roleBasedAccessEnabled);
      await prefs.setInt('session_timeout_minutes', _sessionTimeoutMinutes);
      await prefs.setInt('max_login_attempts', _maxLoginAttempts);
      await prefs.setInt('lockout_duration_minutes', _lockoutDurationMinutes);
    } catch (e) {
      _logger.error('Failed to save security settings', context: 'SecurityService', error: e);
    }
  }

  Future<String> exportAuditLogs() async {
    try {
      final logsJson = json.encode(_auditLogs.map((log) => log.toJson()).toList());
      return logsJson;
    } catch (e) {
      _logger.error('Failed to export audit logs', context: 'SecurityService', error: e);
      rethrow;
    }
  }

  Future<void> clearAuditLogs() async {
    try {
      _auditLogs.clear();
      await _saveAuditLogs();
      
      await _logAuditEvent(
        AuditEventType.system,
        'Audit logs cleared',
        'SYSTEM',
        SecurityLevel.medium,
      );
      
      notifyListeners();
      
      _logger.info('Audit logs cleared', context: 'SecurityService');
    } catch (e) {
      _logger.error('Failed to clear audit logs', context: 'SecurityService', error: e);
      rethrow;
    }
  }
}
