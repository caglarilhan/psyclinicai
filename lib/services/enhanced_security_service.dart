import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psyclinicai/models/security_models.dart';

class EnhancedSecurityService {
  static final EnhancedSecurityService _instance = EnhancedSecurityService._internal();
  factory EnhancedSecurityService() => _instance;
  EnhancedSecurityService._internal();

  // Controllers
  final StreamController<List<EnhancedComplianceFramework>> _complianceController = StreamController<List<EnhancedComplianceFramework>>.broadcast();
  final StreamController<List<EnhancedDataRetentionPolicy>> _retentionController = StreamController<List<EnhancedDataRetentionPolicy>>.broadcast();
  final StreamController<List<EnhancedEncryptionConfig>> _encryptionController = StreamController<List<EnhancedEncryptionConfig>>.broadcast();
  final StreamController<List<EnhancedAccessControlPolicy>> _accessController = StreamController<List<EnhancedAccessControlPolicy>>.broadcast();
  final StreamController<List<EnhancedDataAnonymizationRule>> _anonymizationController = StreamController<List<EnhancedDataAnonymizationRule>>.broadcast();
  final StreamController<List<EnhancedSecurityIncident>> _incidentController = StreamController<List<EnhancedSecurityIncident>>.broadcast();
  final StreamController<List<SecurityAuditLog>> _auditController = StreamController<List<SecurityAuditLog>>.broadcast();

  // Data
  List<EnhancedComplianceFramework> _complianceFrameworks = [];
  List<EnhancedDataRetentionPolicy> _retentionPolicies = [];
  List<EnhancedEncryptionConfig> _encryptionConfigs = [];
  List<EnhancedAccessControlPolicy> _accessPolicies = [];
  List<EnhancedDataAnonymizationRule> _anonymizationRules = [];
  List<EnhancedSecurityIncident> _securityIncidents = [];
  List<SecurityAuditLog> _auditLogs = [];

  // Streams
  Stream<List<EnhancedComplianceFramework>> get complianceStream => _complianceController.stream;
  Stream<List<EnhancedDataRetentionPolicy>> get retentionStream => _retentionController.stream;
  Stream<List<EnhancedEncryptionConfig>> get encryptionStream => _encryptionController.stream;
  Stream<List<EnhancedAccessControlPolicy>> get accessStream => _accessController.stream;
  Stream<List<EnhancedDataAnonymizationRule>> get anonymizationStream => _anonymizationController.stream;
  Stream<List<EnhancedSecurityIncident>> get incidentStream => _incidentController.stream;
  Stream<List<SecurityAuditLog>> get auditStream => _auditController.stream;

  // Getters
  List<EnhancedComplianceFramework> get complianceFrameworks => List.unmodifiable(_complianceFrameworks);
  List<EnhancedDataRetentionPolicy> get retentionPolicies => List.unmodifiable(_retentionPolicies);
  List<EnhancedEncryptionConfig> get encryptionConfigs => List.unmodifiable(_encryptionConfigs);
  List<EnhancedAccessControlPolicy> get accessPolicies => List.unmodifiable(_accessPolicies);
  List<EnhancedDataAnonymizationRule> get anonymizationRules => List.unmodifiable(_anonymizationRules);
  List<EnhancedSecurityIncident> get securityIncidents => List.unmodifiable(_securityIncidents);
  List<SecurityAuditLog> get auditLogs => List.unmodifiable(_auditLogs);

  Future<void> initialize() async {
    await _loadData();
    _createDemoData();
    _notifyListeners();
  }

  // Compliance Framework Methods
  Future<void> createComplianceFramework(EnhancedComplianceFramework framework) async {
    _complianceFrameworks.add(framework);
    await _saveComplianceFrameworks();
    _notifyListeners();
  }

  Future<void> updateComplianceFramework(String id, EnhancedComplianceFramework updatedFramework) async {
    final index = _complianceFrameworks.indexWhere((f) => f.id == id);
    if (index != -1) {
      _complianceFrameworks[index] = updatedFramework;
      await _saveComplianceFrameworks();
      _notifyListeners();
    }
  }

  Future<void> deleteComplianceFramework(String id) async {
    _complianceFrameworks.removeWhere((f) => f.id == id);
    await _saveComplianceFrameworks();
    _notifyListeners();
  }

  EnhancedComplianceFramework? getComplianceFramework(String id) {
    try {
      return _complianceFrameworks.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedComplianceFramework> getComplianceFrameworksByRegion(String region) {
    return _complianceFrameworks.where((f) => f.region == region && f.isActive).toList();
  }

  // Data Retention Policy Methods
  Future<void> createRetentionPolicy(EnhancedDataRetentionPolicy policy) async {
    _retentionPolicies.add(policy);
    await _saveRetentionPolicies();
    _notifyListeners();
  }

  Future<void> updateRetentionPolicy(String id, EnhancedDataRetentionPolicy updatedPolicy) async {
    final index = _retentionPolicies.indexWhere((p) => p.id == id);
    if (index != -1) {
      _retentionPolicies[index] = updatedPolicy;
      await _saveRetentionPolicies();
      _notifyListeners();
    }
  }

  Future<void> deleteRetentionPolicy(String id) async {
    _retentionPolicies.removeWhere((p) => p.id == id);
    await _saveRetentionPolicies();
    _notifyListeners();
  }

  EnhancedDataRetentionPolicy? getRetentionPolicy(String id) {
    try {
      return _retentionPolicies.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedDataRetentionPolicy> getRetentionPoliciesByDataType(String dataType) {
    return _retentionPolicies.where((p) => p.dataTypes.contains(dataType) && p.isActive).toList();
  }

  // Encryption Configuration Methods
  Future<void> createEncryptionConfig(EnhancedEncryptionConfig config) async {
    _encryptionConfigs.add(config);
    await _saveEncryptionConfigs();
    _notifyListeners();
  }

  Future<void> updateEncryptionConfig(String id, EnhancedEncryptionConfig updatedConfig) async {
    final index = _encryptionConfigs.indexWhere((c) => c.id == id);
    if (index != -1) {
      _encryptionConfigs[index] = updatedConfig;
      await _saveEncryptionConfigs();
      _notifyListeners();
    }
  }

  Future<void> deleteEncryptionConfig(String id) async {
    _encryptionConfigs.removeWhere((c) => c.id == id);
    await _saveEncryptionConfigs();
    _notifyListeners();
  }

  EnhancedEncryptionConfig? getEncryptionConfig(String id) {
    try {
      return _encryptionConfigs.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedEncryptionConfig> getActiveEncryptionConfigs() {
    return _encryptionConfigs.where((c) => c.isActive).toList();
  }

  // Access Control Policy Methods
  Future<void> createAccessPolicy(EnhancedAccessControlPolicy policy) async {
    _accessPolicies.add(policy);
    await _saveAccessPolicies();
    _notifyListeners();
  }

  Future<void> updateAccessPolicy(String id, EnhancedAccessControlPolicy updatedPolicy) async {
    final index = _accessPolicies.indexWhere((p) => p.id == id);
    if (index != -1) {
      _accessPolicies[index] = updatedPolicy;
      await _saveAccessPolicies();
      _notifyListeners();
    }
  }

  Future<void> deleteAccessPolicy(String id) async {
    _accessPolicies.removeWhere((p) => p.id == id);
    await _saveAccessPolicies();
    _notifyListeners();
  }

  EnhancedAccessControlPolicy? getAccessPolicy(String id) {
    try {
      return _accessPolicies.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedAccessControlPolicy> getAccessPoliciesByRole(String role) {
    return _accessPolicies.where((p) => p.roles.contains(role) && p.isActive).toList();
  }

  // Data Anonymization Rule Methods
  Future<void> createAnonymizationRule(EnhancedDataAnonymizationRule rule) async {
    _anonymizationRules.add(rule);
    await _saveAnonymizationRules();
    _notifyListeners();
  }

  Future<void> updateAnonymizationRule(String id, EnhancedDataAnonymizationRule updatedRule) async {
    final index = _anonymizationRules.indexWhere((r) => r.id == id);
    if (index != -1) {
      _anonymizationRules[index] = updatedRule;
      await _saveAnonymizationRules();
      _notifyListeners();
    }
  }

  Future<void> deleteAnonymizationRule(String id) async {
    _anonymizationRules.removeWhere((r) => r.id == id);
    await _saveAnonymizationRules();
    _notifyListeners();
  }

  EnhancedDataAnonymizationRule? getAnonymizationRule(String id) {
    try {
      return _anonymizationRules.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedDataAnonymizationRule> getAnonymizationRulesByField(String field) {
    return _anonymizationRules.where((r) => r.dataFields.contains(field) && r.isActive).toList();
  }

  // Security Incident Methods
  Future<void> createSecurityIncident(EnhancedSecurityIncident incident) async {
    _securityIncidents.add(incident);
    await _saveSecurityIncidents();
    _notifyListeners();
  }

  Future<void> updateSecurityIncident(String id, EnhancedSecurityIncident updatedIncident) async {
    final index = _securityIncidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      _securityIncidents[index] = updatedIncident;
      await _saveSecurityIncidents();
      _notifyListeners();
    }
  }

  Future<void> deleteSecurityIncident(String id) async {
    _securityIncidents.removeWhere((i) => i.id == id);
    await _saveSecurityIncidents();
    _notifyListeners();
  }

  EnhancedSecurityIncident? getSecurityIncident(String id) {
    try {
      return _securityIncidents.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedSecurityIncident> getSecurityIncidentsBySeverity(String severity) {
    return _securityIncidents.where((i) => i.severity == severity).toList();
  }

  List<EnhancedSecurityIncident> getActiveSecurityIncidents() {
    return _securityIncidents.where((i) => !i.isResolved).toList();
  }

  // Security Audit Log Methods
  Future<void> logSecurityEvent(SecurityAuditLog log) async {
    _auditLogs.add(log);
    await _saveAuditLogs();
    _notifyListeners();
  }

  List<SecurityAuditLog> getAuditLogsByUser(String userId) {
    return _auditLogs.where((l) => l.userId == userId).toList();
  }

  List<SecurityAuditLog> getAuditLogsByAction(String action) {
    return _auditLogs.where((l) => l.action == action).toList();
  }

  List<SecurityAuditLog> getAuditLogsByDateRange(DateTime start, DateTime end) {
    return _auditLogs.where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end)).toList();
  }

  // Statistics Methods
  Map<String, dynamic> getSecurityStats() {
    final now = DateTime.now();
    final lastMonth = now.subtract(Duration(days: 30));

    return {
      'totalComplianceFrameworks': _complianceFrameworks.length,
      'activeComplianceFrameworks': _complianceFrameworks.where((f) => f.isActive).length,
      'totalRetentionPolicies': _retentionPolicies.length,
      'activeRetentionPolicies': _retentionPolicies.where((p) => p.isActive).length,
      'totalEncryptionConfigs': _encryptionConfigs.length,
      'activeEncryptionConfigs': _encryptionConfigs.where((c) => c.isActive).length,
      'totalAccessPolicies': _accessPolicies.length,
      'activeAccessPolicies': _accessPolicies.where((p) => p.isActive).length,
      'totalAnonymizationRules': _anonymizationRules.length,
      'activeAnonymizationRules': _anonymizationRules.where((r) => r.isActive).length,
      'totalSecurityIncidents': _securityIncidents.length,
      'activeSecurityIncidents': _securityIncidents.where((i) => !i.isResolved).length,
      'resolvedSecurityIncidents': _securityIncidents.where((i) => i.isResolved).length,
      'totalAuditLogs': _auditLogs.length,
      'auditLogsLastMonth': _auditLogs.where((l) => l.timestamp.isAfter(lastMonth)).length,
      'successfulAuditLogs': _auditLogs.where((l) => l.isSuccessful).length,
      'failedAuditLogs': _auditLogs.where((l) => !l.isSuccessful).length,
    };
  }

  // Demo Data Creation
  void _createDemoData() {
    if (_complianceFrameworks.isEmpty) {
      _complianceFrameworks.addAll([
        EnhancedComplianceFramework(
          id: 'hipaa-us',
          name: 'HIPAA (US)',
          region: 'US',
          description: 'Health Insurance Portability and Accountability Act',
          requirements: [
            'Patient privacy protection',
            'Secure data transmission',
            'Access controls',
            'Audit trails',
          ],
          configurations: {
            'encryption': 'AES-256',
            'sessionTimeout': 30,
            'mfaRequired': true,
          },
          createdAt: DateTime.now(),
        ),
        EnhancedComplianceFramework(
          id: 'gdpr-eu',
          name: 'GDPR (EU)',
          region: 'EU',
          description: 'General Data Protection Regulation',
          requirements: [
            'Data subject rights',
            'Consent management',
            'Data portability',
            'Right to be forgotten',
          ],
          configurations: {
            'encryption': 'AES-256',
            'sessionTimeout': 20,
            'mfaRequired': true,
          },
          createdAt: DateTime.now(),
        ),
        EnhancedComplianceFramework(
          id: 'kvkk-turkey',
          name: 'KVKK (Turkey)',
          region: 'Turkey',
          description: 'Kişisel Verilerin Korunması Kanunu',
          requirements: [
            'Veri işleme şartları',
            'Aydınlatma yükümlülüğü',
            'Veri güvenliği',
            'Veri işleyen sorumluluğu',
          ],
          configurations: {
            'encryption': 'AES-256',
            'sessionTimeout': 25,
            'mfaRequired': true,
          },
          createdAt: DateTime.now(),
        ),
      ]);
    }

    if (_retentionPolicies.isEmpty) {
      _retentionPolicies.addAll([
        EnhancedDataRetentionPolicy(
          id: 'patient-data-7y',
          name: 'Patient Data - 7 Years',
          description: 'Patient records retention for 7 years',
          retentionPeriods: {'patient_records': 2555, 'session_notes': 2555},
          dataTypes: ['patient_records', 'session_notes', 'diagnoses'],
          deletionMethod: 'secure_deletion',
          requiresApproval: true,
          approvers: ['admin', 'compliance_officer'],
          createdAt: DateTime.now(),
        ),
        EnhancedDataRetentionPolicy(
          id: 'financial-data-10y',
          name: 'Financial Data - 10 Years',
          description: 'Financial records retention for 10 years',
          retentionPeriods: {'invoices': 3650, 'payments': 3650},
          dataTypes: ['invoices', 'payments', 'financial_reports'],
          deletionMethod: 'secure_deletion',
          requiresApproval: true,
          approvers: ['admin', 'finance_manager'],
          createdAt: DateTime.now(),
        ),
      ]);
    }

    if (_encryptionConfigs.isEmpty) {
      _encryptionConfigs.addAll([
        EnhancedEncryptionConfig(
          id: 'aes-256-standard',
          name: 'AES-256 Standard',
          algorithm: 'AES-256-GCM',
          keySize: 256,
          keyManagement: 'AWS KMS',
          isHardwareAccelerated: false,
          settings: {
            'keyRotation': 90,
            'encryptionMode': 'GCM',
            'padding': 'PKCS7',
          },
          createdAt: DateTime.now(),
        ),
        EnhancedEncryptionConfig(
          id: 'aes-256-hardware',
          name: 'AES-256 Hardware Accelerated',
          algorithm: 'AES-256-GCM',
          keySize: 256,
          keyManagement: 'Hardware Security Module',
          isHardwareAccelerated: true,
          settings: {
            'keyRotation': 30,
            'encryptionMode': 'GCM',
            'padding': 'PKCS7',
            'hsmProvider': 'AWS CloudHSM',
          },
          createdAt: DateTime.now(),
        ),
      ]);
    }

    if (_accessPolicies.isEmpty) {
      _accessPolicies.addAll([
        EnhancedAccessControlPolicy(
          id: 'therapist-access',
          name: 'Therapist Access Policy',
          description: 'Access policy for therapists',
          roles: ['therapist', 'senior_therapist'],
          permissions: ['read_patient_data', 'write_session_notes', 'view_calendar'],
          resourceAccess: {
            'patient_data': ['read', 'write'],
            'session_notes': ['read', 'write'],
            'calendar': ['read'],
          },
          enforcementLevel: 'strict',
          requiresMFA: true,
          allowedIPs: ['192.168.1.0/24', '10.0.0.0/8'],
          allowedDevices: ['mobile', 'desktop'],
          createdAt: DateTime.now(),
        ),
        EnhancedAccessControlPolicy(
          id: 'admin-access',
          name: 'Administrator Access Policy',
          description: 'Full access policy for administrators',
          roles: ['admin', 'super_admin'],
          permissions: ['all'],
          resourceAccess: {
            'all': ['read', 'write', 'delete', 'admin'],
          },
          enforcementLevel: 'strict',
          requiresMFA: true,
          allowedIPs: ['192.168.1.0/24', '10.0.0.0/8'],
          allowedDevices: ['desktop'],
          createdAt: DateTime.now(),
        ),
      ]);
    }

    if (_anonymizationRules.isEmpty) {
      _anonymizationRules.addAll([
        EnhancedDataAnonymizationRule(
          id: 'patient-name-hash',
          name: 'Patient Name Hashing',
          description: 'Hash patient names for research purposes',
          dataFields: ['firstName', 'lastName'],
          anonymizationMethod: 'sha256_hash',
          parameters: {
            'salt': 'random_salt',
            'iterations': 10000,
          },
          isReversible: false,
          retentionKey: 'patient_id',
          createdAt: DateTime.now(),
        ),
        EnhancedDataAnonymizationRule(
          id: 'phone-masking',
          name: 'Phone Number Masking',
          description: 'Mask phone numbers for privacy',
          dataFields: ['phoneNumber'],
          anonymizationMethod: 'masking',
          parameters: {
            'maskChar': '*',
            'visibleDigits': 4,
            'position': 'end',
          },
          isReversible: true,
          retentionKey: 'phone_hash',
          createdAt: DateTime.now(),
        ),
      ]);
    }

    if (_securityIncidents.isEmpty) {
      _securityIncidents.addAll([
        EnhancedSecurityIncident(
          id: 'incident-001',
          title: 'Suspicious Login Attempt',
          description: 'Multiple failed login attempts detected',
          severity: 'medium',
          status: 'investigating',
          category: 'authentication',
          reportedBy: 'system',
          reportedAt: DateTime.now().subtract(Duration(hours: 2)),
          affectedUsers: ['user123'],
          affectedSystems: ['auth_service'],
          details: {
            'ipAddress': '192.168.1.100',
            'attempts': 15,
            'timeframe': '10 minutes',
          },
          actions: ['blocked_ip', 'notified_user'],
          assignedTo: 'security_team',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        EnhancedSecurityIncident(
          id: 'incident-002',
          title: 'Data Access Violation',
          description: 'Unauthorized access to patient records',
          severity: 'high',
          status: 'resolved',
          category: 'data_breach',
          reportedBy: 'audit_system',
          reportedAt: DateTime.now().subtract(Duration(days: 1)),
          resolvedAt: DateTime.now().subtract(Duration(hours: 6)),
          affectedUsers: ['user456'],
          affectedSystems: ['patient_database'],
          details: {
            'recordsAccessed': 25,
            'duration': '5 minutes',
            'action': 'view_only',
          },
          actions: ['revoked_access', 'investigation_completed'],
          assignedTo: 'security_team',
          isResolved: true,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
      ]);
    }

    if (_auditLogs.isEmpty) {
      _auditLogs.addAll([
        SecurityAuditLog(
          id: 'audit-001',
          userId: 'user123',
          action: 'login',
          resource: 'auth_service',
          ipAddress: '192.168.1.100',
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          details: {'method': 'password', 'mfa': true},
          isSuccessful: true,
          timestamp: DateTime.now().subtract(Duration(minutes: 30)),
          sessionId: 'session-001',
        ),
        SecurityAuditLog(
          id: 'audit-002',
          userId: 'user456',
          action: 'data_access',
          resource: 'patient_records',
          ipAddress: '192.168.1.101',
          userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
          details: {'patientId': 'P001', 'action': 'view'},
          isSuccessful: true,
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
          sessionId: 'session-002',
        ),
        SecurityAuditLog(
          id: 'audit-003',
          userId: 'user789',
          action: 'login',
          resource: 'auth_service',
          ipAddress: '192.168.1.102',
          userAgent: 'Mozilla/5.0 (Linux x86_64)',
          details: {'method': 'password', 'mfa': false},
          isSuccessful: false,
          errorMessage: 'Invalid credentials',
          timestamp: DateTime.now().subtract(Duration(minutes: 15)),
          sessionId: 'session-003',
        ),
      ]);
    }
  }

  // Data Persistence
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
      // Load compliance frameworks
  final complianceJson = prefs.getStringList('enhanced_security_compliance') ?? [];
  _complianceFrameworks = complianceJson
      .map((json) => EnhancedComplianceFramework.fromJson(jsonDecode(json)))
      .toList();

      // Load retention policies
  final retentionJson = prefs.getStringList('enhanced_security_retention') ?? [];
  _retentionPolicies = retentionJson
      .map((json) => EnhancedDataRetentionPolicy.fromJson(jsonDecode(json)))
      .toList();

      // Load encryption configs
  final encryptionJson = prefs.getStringList('enhanced_security_encryption') ?? [];
  _encryptionConfigs = encryptionJson
      .map((json) => EnhancedEncryptionConfig.fromJson(jsonDecode(json)))
      .toList();

      // Load access policies
  final accessJson = prefs.getStringList('enhanced_security_access') ?? [];
  _accessPolicies = accessJson
      .map((json) => EnhancedAccessControlPolicy.fromJson(jsonDecode(json)))
      .toList();

      // Load anonymization rules
  final anonymizationJson = prefs.getStringList('enhanced_security_anonymization') ?? [];
  _anonymizationRules = anonymizationJson
      .map((json) => EnhancedDataAnonymizationRule.fromJson(jsonDecode(json)))
      .toList();

      // Load security incidents
  final incidentJson = prefs.getStringList('enhanced_security_incidents') ?? [];
  _securityIncidents = incidentJson
      .map((json) => EnhancedSecurityIncident.fromJson(jsonDecode(json)))
      .toList();

    // Load audit logs
    final auditJson = prefs.getStringList('enhanced_security_audit') ?? [];
    _auditLogs = auditJson
        .map((json) => SecurityAuditLog.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveComplianceFrameworks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _complianceFrameworks
        .map((framework) => jsonEncode(framework.toJson()))
        .toList();
    await prefs.setStringList('enhanced_security_compliance', jsonList);
  }

  Future<void> _saveRetentionPolicies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _retentionPolicies
        .map((policy) => jsonEncode(policy.toJson()))
        .toList();
    await prefs.setStringList('enhanced_security_retention', jsonList);
  }

  Future<void> _saveEncryptionConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _encryptionConfigs
        .map((config) => jsonEncode(config.toJson()))
        .toList();
    await prefs.setStringList('enhanced_security_encryption', jsonList);
  }

  Future<void> _saveAccessPolicies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _accessPolicies
        .map((policy) => jsonEncode(policy.toJson()))
        .toList();
    await prefs.setStringList('enhanced_security_access', jsonList);
  }

  Future<void> _saveAnonymizationRules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _anonymizationRules
        .map((rule) => jsonEncode(rule.toJson()))
        .toList();
    await prefs.setStringList('enhanced_security_anonymization', jsonList);
  }

  Future<void> _saveSecurityIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _securityIncidents
        .map((incident) => jsonEncode(incident.toJson()))
        .toList();
    await prefs.setStringList('enhanced_security_incidents', jsonList);
  }

  Future<void> _saveAuditLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _auditLogs
        .map((log) => jsonEncode(log.toJson()))
        .toList();
    await prefs.setStringList('enhanced_security_audit', jsonList);
  }

  void _notifyListeners() {
    if (!_complianceController.isClosed) {
      _complianceController.add(_complianceFrameworks);
    }
    if (!_retentionController.isClosed) {
      _retentionController.add(_retentionPolicies);
    }
    if (!_encryptionController.isClosed) {
      _encryptionController.add(_encryptionConfigs);
    }
    if (!_accessController.isClosed) {
      _accessController.add(_accessPolicies);
    }
    if (!_anonymizationController.isClosed) {
      _anonymizationController.add(_anonymizationRules);
    }
    if (!_incidentController.isClosed) {
      _incidentController.add(_securityIncidents);
    }
    if (!_auditController.isClosed) {
      _auditController.add(_auditLogs);
    }
  }

  void dispose() {
    _complianceController.close();
    _retentionController.close();
    _encryptionController.close();
    _accessController.close();
    _anonymizationController.close();
    _incidentController.close();
    _auditController.close();
  }
}
