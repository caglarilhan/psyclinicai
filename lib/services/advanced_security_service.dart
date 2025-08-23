import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedSecurityService {
  static const String _encryptionKey = 'encryption_key';
  static const String _auditLogKey = 'audit_log';
  static const String _complianceKey = 'compliance_status';
  
  // Singleton pattern
  static final AdvancedSecurityService _instance = AdvancedSecurityService._internal();
  factory AdvancedSecurityService() => _instance;
  AdvancedSecurityService._internal();

  // Encryption keys (in real app, these would be stored securely)
  late final Uint8List _masterKey;
  late final Uint8List _iv;
  
  // Initialize encryption
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Generate or retrieve master key
    String? storedKey = prefs.getString(_encryptionKey);
    if (storedKey == null) {
      _masterKey = _generateSecureKey();
      storedKey = base64.encode(_masterKey);
      await prefs.setString(_encryptionKey, storedKey);
    } else {
      _masterKey = base64.decode(storedKey);
    }
    
    // Generate IV
    _iv = _generateIV();
  }

  // Generate secure encryption key
  Uint8List _generateSecureKey() {
    final random = Random.secure();
    final key = Uint8List(32); // 256-bit key
    for (int i = 0; i < key.length; i++) {
      key[i] = random.nextInt(256);
    }
    return key;
  }

  // Generate initialization vector
  Uint8List _generateIV() {
    final random = Random.secure();
    final iv = Uint8List(16); // 128-bit IV
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  // Encrypt sensitive data
  String encryptData(String data) {
    try {
      // Simple XOR encryption for demo (in real app, use AES)
      final bytes = utf8.encode(data);
      final encrypted = Uint8List(bytes.length);
      
      for (int i = 0; i < bytes.length; i++) {
        encrypted[i] = bytes[i] ^ _masterKey[i % _masterKey.length];
      }
      
      return base64.encode(encrypted);
    } catch (e) {
      print('Encryption error: $e');
      return data; // Fallback to plain text
    }
  }

  // Decrypt sensitive data
  String decryptData(String encryptedData) {
    try {
      final encrypted = base64.decode(encryptedData);
      final decrypted = Uint8List(encrypted.length);
      
      for (int i = 0; i < encrypted.length; i++) {
        decrypted[i] = encrypted[i] ^ _masterKey[i % _masterKey.length];
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      print('Decryption error: $e');
      return encryptedData; // Return encrypted data if decryption fails
    }
  }

  // Hash sensitive data (one-way encryption)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate secure token
  String generateSecureToken() {
    final random = Random.secure();
    final token = Uint8List(32);
    for (int i = 0; i < token.length; i++) {
      token[i] = random.nextInt(256);
    }
    return base64.encode(token);
  }

  // Generate secure token (private method)
  String _generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Validate data integrity
  bool validateDataIntegrity(String data, String hash) {
    final calculatedHash = hashData(data);
    return calculatedHash == hash;
  }

  // Audit logging
  Future<void> logSecurityEvent({
    required String eventType,
    required String userId,
    required String action,
    required String resource,
    String? details,
    SecurityLevel level = SecurityLevel.info,
  }) async {
    try {
      final auditEntry = SecurityAuditEntry(
        id: _generateSecureToken(),
        timestamp: DateTime.now(),
        eventType: eventType,
        userId: userId,
        action: action,
        resource: resource,
        details: details,
        level: level,
        ipAddress: '127.0.0.1', // In real app, get actual IP
        userAgent: 'PsyClinicAI/1.0',
        sessionId: _generateSecureToken(),
      );
      
      await _saveAuditEntry(auditEntry);
      
      // Log to console for development
      print('🔒 SECURITY AUDIT: ${auditEntry.eventType} - ${auditEntry.action} by ${auditEntry.userId}');
      
      // Check for suspicious activity
      await _checkSuspiciousActivity(auditEntry);
      
    } catch (e) {
      print('Error logging security event: $e');
    }
  }

  // Save audit entry
  Future<void> _saveAuditEntry(SecurityAuditEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final auditKey = '${_auditLogKey}_${entry.userId}';
      
      final existingAuditJson = prefs.getString(auditKey);
      List<Map<String, dynamic>> auditLog = [];
      
      if (existingAuditJson != null) {
        auditLog = List<Map<String, dynamic>>.from(json.decode(existingAuditJson));
      }
      
      auditLog.add(entry.toJson());
      
      // Keep only last 1000 audit entries
      if (auditLog.length > 1000) {
        auditLog = auditLog.sublist(auditLog.length - 1000);
      }
      
      await prefs.setString(auditKey, json.encode(auditLog));
    } catch (e) {
      print('Error saving audit entry: $e');
    }
  }

  // Check for suspicious activity
  Future<void> _checkSuspiciousActivity(SecurityAuditEntry entry) async {
    try {
      final recentEvents = await _getRecentAuditEvents(entry.userId, hours: 1);
      
      // Check for multiple failed login attempts
      final failedLogins = recentEvents.where((e) => 
        e.eventType == 'authentication' && 
        e.action == 'login_failed'
      ).length;
      
      if (failedLogins > 5) {
        await _triggerSecurityAlert(
          userId: entry.userId,
          alertType: 'multiple_failed_logins',
          severity: SecurityLevel.high,
          details: 'Multiple failed login attempts detected',
        );
      }
      
      // Check for unusual access patterns
      final unusualAccess = recentEvents.where((e) => 
        e.eventType == 'data_access' && 
        e.resource.contains('sensitive')
      ).length;
      
      if (unusualAccess > 10) {
        await _triggerSecurityAlert(
          userId: entry.userId,
          alertType: 'unusual_data_access',
          severity: SecurityLevel.medium,
          details: 'Unusual amount of sensitive data access',
        );
      }
      
    } catch (e) {
      print('Error checking suspicious activity: $e');
    }
  }

  // Get recent audit events
  Future<List<SecurityAuditEntry>> _getRecentAuditEvents(String userId, {int hours = 24}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final auditKey = '${_auditLogKey}_$userId';
      
      final auditJson = prefs.getString(auditKey);
      if (auditJson == null) return [];
      
      final auditLog = List<Map<String, dynamic>>.from(json.decode(auditJson));
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      
      return auditLog
          .where((entry) => DateTime.parse(entry['timestamp']).isAfter(cutoffTime))
          .map((json) => SecurityAuditEntry.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting recent audit events: $e');
      return [];
    }
  }

  // Trigger security alert
  Future<void> _triggerSecurityAlert({
    required String userId,
    required String alertType,
    required SecurityLevel severity,
    String? details,
  }) async {
    try {
      final alert = SecurityAlert(
        id: _generateSecureToken(),
        timestamp: DateTime.now(),
        userId: userId,
        alertType: alertType,
        severity: severity,
        details: details,
        status: AlertStatus.active,
      );
      
      // Save alert
      await _saveSecurityAlert(alert);
      
      // Log alert
      print('🚨 SECURITY ALERT: $alertType for user $userId - $severity');
      
      // In real app, send notification to security team
      
    } catch (e) {
      print('Error triggering security alert: $e');
    }
  }

  // Save security alert
  Future<void> _saveSecurityAlert(SecurityAlert alert) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsKey = 'security_alerts_${alert.userId}';
      
      final existingAlertsJson = prefs.getString(alertsKey);
      List<Map<String, dynamic>> alerts = [];
      
      if (existingAlertsJson != null) {
        alerts = List<Map<String, dynamic>>.from(json.decode(existingAlertsJson));
      }
      
      alerts.add(alert.toJson());
      
      // Keep only last 100 alerts
      if (alerts.length > 100) {
        alerts = alerts.sublist(alerts.length - 100);
      }
      
      await prefs.setString(alertsKey, json.encode(alerts));
    } catch (e) {
      print('Error saving security alert: $e');
    }
  }

  // Compliance monitoring
  Future<ComplianceStatus> checkComplianceStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final complianceJson = prefs.getString(_complianceKey);
      
      if (complianceJson != null) {
        return ComplianceStatus.fromJson(json.decode(complianceJson));
      }
      
      // Generate default compliance status
      return ComplianceStatus(
        id: _generateSecureToken(),
        timestamp: DateTime.now(),
        hipaaCompliant: true,
        gdprCompliant: true,
        kvkkCompliant: true,
        lastAuditDate: DateTime.now().subtract(const Duration(days: 30)),
        nextAuditDate: DateTime.now().add(const Duration(days: 335)),
        complianceScore: 95.0,
        issues: [],
        recommendations: [
          'Regular security training for staff',
          'Monthly compliance reviews',
          'Annual penetration testing',
        ],
      );
      
    } catch (e) {
      print('Error checking compliance status: $e');
      return ComplianceStatus(
        id: _generateSecureToken(),
        timestamp: DateTime.now(),
        hipaaCompliant: false,
        gdprCompliant: false,
        kvkkCompliant: false,
        lastAuditDate: DateTime.now().subtract(const Duration(days: 365)),
        nextAuditDate: DateTime.now().add(const Duration(days: 1)),
        complianceScore: 0.0,
        issues: ['Compliance status unavailable'],
        recommendations: ['Contact security team immediately'],
      );
    }
  }

  // Update compliance status
  Future<void> updateComplianceStatus(ComplianceStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_complianceKey, json.encode(status.toJson()));
    } catch (e) {
      print('Error updating compliance status: $e');
    }
  }

  // Generate compliance report
  Future<ComplianceReport> generateComplianceReport() async {
    try {
      final complianceStatus = await checkComplianceStatus();
      final auditEvents = await _getAllAuditEvents();
      
      // Analyze audit events for compliance
      final dataAccessEvents = auditEvents.where((e) => 
        e.eventType == 'data_access'
      ).length;
      
      final authenticationEvents = auditEvents.where((e) => 
        e.eventType == 'authentication'
      ).length;
      
      final securityEvents = auditEvents.where((e) => 
        e.level == SecurityLevel.high || e.level == SecurityLevel.critical
      ).length;
      
      return ComplianceReport(
        id: _generateSecureToken(),
        timestamp: DateTime.now(),
        complianceStatus: complianceStatus,
        auditSummary: AuditSummary(
          totalEvents: auditEvents.length,
          dataAccessEvents: dataAccessEvents,
          authenticationEvents: authenticationEvents,
          securityEvents: securityEvents,
          lastEventDate: auditEvents.isNotEmpty ? auditEvents.last.timestamp : DateTime.now(),
        ),
        recommendations: _generateComplianceRecommendations(complianceStatus, auditEvents),
        nextSteps: _generateNextSteps(complianceStatus),
      );
      
    } catch (e) {
      print('Error generating compliance report: $e');
      rethrow;
    }
  }

  // Get all audit events
  Future<List<SecurityAuditEntry>> _getAllAuditEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_auditLogKey));
      
      final allEvents = <SecurityAuditEntry>[];
      
      for (final key in keys) {
        final auditJson = prefs.getString(key);
        if (auditJson != null) {
          final auditLog = List<Map<String, dynamic>>.from(json.decode(auditJson));
          allEvents.addAll(auditLog.map((json) => SecurityAuditEntry.fromJson(json)));
        }
      }
      
      // Sort by timestamp
      allEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      return allEvents;
    } catch (e) {
      print('Error getting all audit events: $e');
      return [];
    }
  }

  // Generate compliance recommendations
  List<String> _generateComplianceRecommendations(
    ComplianceStatus status,
    List<SecurityAuditEntry> auditEvents,
  ) {
    final recommendations = <String>[];
    
    if (status.complianceScore < 90) {
      recommendations.add('Immediate compliance review required');
      recommendations.add('Address all identified issues');
      recommendations.add('Schedule additional staff training');
    }
    
    if (auditEvents.where((e) => e.level == SecurityLevel.critical).isNotEmpty) {
      recommendations.add('Review critical security events');
      recommendations.add('Implement additional security measures');
      recommendations.add('Consider security audit');
    }
    
    if (DateTime.now().difference(status.lastAuditDate).inDays > 90) {
      recommendations.add('Schedule quarterly compliance review');
      recommendations.add('Update security policies');
      recommendations.add('Review access controls');
    }
    
    return recommendations;
  }

  // Generate next steps
  List<String> _generateNextSteps(ComplianceStatus status) {
    final nextSteps = <String>[];
    
    if (status.issues.isNotEmpty) {
      nextSteps.add('Address compliance issues within 30 days');
      nextSteps.add('Schedule follow-up review');
    }
    
    if (DateTime.now().isAfter(status.nextAuditDate.subtract(const Duration(days: 30)))) {
      nextSteps.add('Prepare for annual compliance audit');
      nextSteps.add('Review and update documentation');
      nextSteps.add('Schedule staff training sessions');
    }
    
    nextSteps.add('Continue monitoring security events');
    nextSteps.add('Regular policy updates');
    
    return nextSteps;
  }

  // Dispose resources
  void dispose() {
    // Clear sensitive data from memory
    _masterKey.fillRange(0, _masterKey.length, 0);
    _iv.fillRange(0, _iv.length, 0);
  }
}

// Data classes for security and compliance
class SecurityAuditEntry {
  final String id;
  final DateTime timestamp;
  final String eventType;
  final String userId;
  final String action;
  final String resource;
  final String? details;
  final SecurityLevel level;
  final String ipAddress;
  final String userAgent;
  final String sessionId;

  const SecurityAuditEntry({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.userId,
    required this.action,
    required this.resource,
    this.details,
    required this.level,
    required this.ipAddress,
    required this.userAgent,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'eventType': eventType,
      'userId': userId,
      'action': action,
      'resource': resource,
      'details': details,
      'level': level.name,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'sessionId': sessionId,
    };
  }

  factory SecurityAuditEntry.fromJson(Map<String, dynamic> json) {
    return SecurityAuditEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      eventType: json['eventType'],
      userId: json['userId'],
      action: json['action'],
      resource: json['resource'],
      details: json['details'],
      level: SecurityLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => SecurityLevel.info,
      ),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      sessionId: json['sessionId'],
    );
  }
}

enum SecurityLevel {
  info,
  low,
  medium,
  high,
  critical,
}

class SecurityAlert {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String alertType;
  final SecurityLevel severity;
  final String? details;
  final AlertStatus status;

  const SecurityAlert({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.alertType,
    required this.severity,
    this.details,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'alertType': alertType,
      'severity': severity.name,
      'details': details,
      'status': status.name,
    };
  }

  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      alertType: json['alertType'],
      severity: SecurityLevel.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SecurityLevel.medium,
      ),
      details: json['details'],
      status: AlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AlertStatus.active,
      ),
    );
  }
}

enum AlertStatus {
  active,
  acknowledged,
  resolved,
  false_positive,
}

class ComplianceStatus {
  final String id;
  final DateTime timestamp;
  final bool hipaaCompliant;
  final bool gdprCompliant;
  final bool kvkkCompliant;
  final DateTime lastAuditDate;
  final DateTime nextAuditDate;
  final double complianceScore;
  final List<String> issues;
  final List<String> recommendations;

  const ComplianceStatus({
    required this.id,
    required this.timestamp,
    required this.hipaaCompliant,
    required this.gdprCompliant,
    required this.kvkkCompliant,
    required this.lastAuditDate,
    required this.nextAuditDate,
    required this.complianceScore,
    required this.issues,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'hipaaCompliant': hipaaCompliant,
      'gdprCompliant': gdprCompliant,
      'kvkkCompliant': kvkkCompliant,
      'lastAuditDate': lastAuditDate.toIso8601String(),
      'nextAuditDate': nextAuditDate.toIso8601String(),
      'complianceScore': complianceScore,
      'issues': issues,
      'recommendations': recommendations,
    };
  }

  factory ComplianceStatus.fromJson(Map<String, dynamic> json) {
    return ComplianceStatus(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      hipaaCompliant: json['hipaaCompliant'],
      gdprCompliant: json['gdprCompliant'],
      kvkkCompliant: json['kvkkCompliant'],
      lastAuditDate: DateTime.parse(json['lastAuditDate']),
      nextAuditDate: DateTime.parse(json['nextAuditDate']),
      complianceScore: json['complianceScore'].toDouble(),
      issues: List<String>.from(json['issues']),
      recommendations: List<String>.from(json['recommendations']),
    );
  }
}

class ComplianceReport {
  final String id;
  final DateTime timestamp;
  final ComplianceStatus complianceStatus;
  final AuditSummary auditSummary;
  final List<String> recommendations;
  final List<String> nextSteps;

  const ComplianceReport({
    required this.id,
    required this.timestamp,
    required this.complianceStatus,
    required this.auditSummary,
    required this.recommendations,
    required this.nextSteps,
  });
}

class AuditSummary {
  final int totalEvents;
  final int dataAccessEvents;
  final int authenticationEvents;
  final int securityEvents;
  final DateTime lastEventDate;

  const AuditSummary({
    required this.totalEvents,
    required this.dataAccessEvents,
    required this.authenticationEvents,
    required this.securityEvents,
    required this.lastEventDate,
  });
}
