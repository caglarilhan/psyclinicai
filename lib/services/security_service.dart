import 'dart:math';
import 'dart:convert';
import '../models/security_models.dart';
import '../config/region_config.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  bool _isInitialized = false;
  final List<AuditLog> _auditLogs = [];
  final List<ComplianceReport> _complianceReports = [];
  final List<SecurityIncident> _securityIncidents = [];
  final List<DataRetentionPolicy> _retentionPolicies = [];
  final List<AccessControlPolicy> _accessPolicies = [];
  final List<DataAnonymizationRule> _anonymizationRules = [];
  final Random _random = Random();

  // Şifreleme konfigürasyonu
  late EncryptionConfig _encryptionConfig;
  
  // Güvenlik durumu
  late SecurityStatusDetails _securityStatus;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Şifreleme konfigürasyonu
    _encryptionConfig = EncryptionConfig(
      algorithm: 'AES-256',
      keySize: 256,
      keyRotationPeriod: '90 days',
      hardwareAcceleration: true,
      supportedAlgorithms: ['AES-256', 'AES-128', 'ChaCha20'],
      lastKeyRotation: DateTime.now(),
      nextKeyRotation: DateTime.now().add(const Duration(days: 90)),
    );

    // Güvenlik durumu
    _securityStatus = SecurityStatusDetails(
      overallScore: 85.0,
      encryptionScore: 90.0,
      accessControlScore: 80.0,
      auditScore: 85.0,
      lastUpdated: DateTime.now(),
      issues: [
        SecurityIssue(
          id: '1',
          title: 'İki faktörlü kimlik doğrulama eksik',
          description: 'Hassas verilere erişim için 2FA aktif değil',
          type: SecurityIssueType.access,
          severity: SecurityIssueSeverity.medium,
          detectedAt: DateTime.now().subtract(const Duration(days: 5)),
          isResolved: false,
        ),
      ],
    );

    // Veri saklama politikaları
    _retentionPolicies.addAll([
      DataRetentionPolicy(
        id: '1',
        name: 'Seans Kayıtları',
        description: 'Terapi seans kayıtları 7 yıl saklanır',
        retentionPeriod: const Duration(days: 2555), // 7 yıl
        dataTypes: ['session_notes', 'ai_summary', 'client_info'],
        autoDelete: true,
        lastReview: DateTime.now().subtract(const Duration(days: 30)),
        reviewedBy: 'Dr. Ahmet Yılmaz',
      ),
      DataRetentionPolicy(
        id: '2',
        name: 'Tanı Verileri',
        description: 'Tanı ve değerlendirme verileri 10 yıl saklanır',
        retentionPeriod: const Duration(days: 3650), // 10 yıl
        dataTypes: ['diagnosis', 'assessment', 'test_results'],
        autoDelete: true,
        lastReview: DateTime.now().subtract(const Duration(days: 30)),
        reviewedBy: 'Dr. Ahmet Yılmaz',
      ),
    ]);

    // Erişim kontrol politikaları
    _accessPolicies.addAll([
      AccessControlPolicy(
        id: '1',
        name: 'Terapist Erişimi',
        description: 'Terapistler kendi danışanlarının verilerine erişebilir',
        roles: ['therapist'],
        resources: ['client_data', 'session_notes', 'diagnosis'],
        permissions: ['read', 'write', 'update'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'admin',
      ),
      AccessControlPolicy(
        id: '2',
        name: 'Admin Erişimi',
        description: 'Adminler tüm verilere erişebilir',
        roles: ['admin'],
        resources: ['*'],
        permissions: ['read', 'write', 'update', 'delete'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'system',
      ),
    ]);

    // Veri anonimleştirme kuralları
    _anonymizationRules.addAll([
      DataAnonymizationRule(
        id: '1',
        fieldName: 'clientId',
        type: AnonymizationType.mask,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      DataAnonymizationRule(
        id: '2',
        fieldName: 'phoneNumber',
        type: AnonymizationType.mask,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      DataAnonymizationRule(
        id: '3',
        fieldName: 'email',
        type: AnonymizationType.hash,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ]);

    // Demo audit log verileri
    _auditLogs.addAll([
      AuditLog(
        id: '1',
        userId: 'user1',
        action: 'Sisteme giriş yapıldı',
        resource: 'system',
        type: AuditLogType.login,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ipAddress: '192.168.1.100',
        userAgent: 'Chrome/120.0.0.0',
      ),
      AuditLog(
        id: '2',
        userId: 'user1',
        action: 'Danışan verisi görüntülendi',
        resource: 'client123',
        type: AuditLogType.dataAccess,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ipAddress: '192.168.1.100',
      ),
      AuditLog(
        id: '3',
        userId: 'user1',
        action: 'Seans notu güncellendi',
        resource: 'session_notes',
        type: AuditLogType.dataModification,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ipAddress: '192.168.1.100',
      ),
      AuditLog(
        id: '4',
        userId: 'user2',
        action: 'Sisteme giriş yapıldı',
        resource: 'system',
        type: AuditLogType.login,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ipAddress: '192.168.1.101',
        userAgent: 'Firefox/119.0',
      ),
      AuditLog(
        id: '5',
        userId: 'user2',
        action: 'Güvenlik ayarları değiştirildi',
        resource: 'security_settings',
        type: AuditLogType.security,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ipAddress: '192.168.1.101',
      ),
    ]);

    // Demo compliance report verileri
    _complianceReports.addAll([
      ComplianceReport(
        id: '1',
        title: 'KVKK Uyumluluğu',
        framework: ComplianceFramework.kvkk,
        status: ComplianceStatus.compliant,
        reportDate: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Tüm KVKK gereksinimleri karşılanıyor',
        requirements: [
          ComplianceRequirement(
            id: 'kvkk1',
            title: 'Açık Rıza',
            description: 'Kullanıcı açık rıza veriyor',
            framework: ComplianceFramework.kvkk,
            status: ComplianceStatus.compliant,
            lastChecked: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ComplianceRequirement(
            id: 'kvkk2',
            title: 'Veri Güvenliği',
            description: 'AES-256 şifreleme aktif',
            framework: ComplianceFramework.kvkk,
            status: ComplianceStatus.compliant,
            lastChecked: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ComplianceRequirement(
            id: 'kvkk3',
            title: 'Veri Silme Hakkı',
            description: 'Kullanıcı verilerini silebiliyor',
            framework: ComplianceFramework.kvkk,
            status: ComplianceStatus.compliant,
            lastChecked: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      ComplianceReport(
        id: '2',
        title: 'HIPAA Uyumluluğu',
        framework: ComplianceFramework.hipaa,
        status: ComplianceStatus.compliant,
        reportDate: DateTime.now().subtract(const Duration(days: 5)),
        notes: 'HIPAA gereksinimleri karşılanıyor',
        requirements: [
          ComplianceRequirement(
            id: 'hipaa1',
            title: 'PHI Koruması',
            description: 'Sağlık bilgileri korunuyor',
            framework: ComplianceFramework.hipaa,
            status: ComplianceStatus.compliant,
            lastChecked: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ComplianceRequirement(
            id: 'hipaa2',
            title: 'Audit Trail',
            description: 'Tüm erişimler loglanıyor',
            framework: ComplianceFramework.hipaa,
            status: ComplianceStatus.compliant,
            lastChecked: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
    ]);

    // Demo güvenlik olayları
    _securityIncidents.addAll([
      SecurityIncident(
        id: '1',
        title: 'Başarısız Giriş Denemesi',
        description: 'Bilinmeyen IP adresinden başarısız giriş denemesi',
        type: SecurityIncidentType.unauthorizedAccess,
        severity: SecurityIncidentSeverity.low,
        detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isResolved: true,
        resolvedAt: DateTime.now().subtract(const Duration(hours: 1)),
        resolutionNotes: 'IP adresi engellendi',
        affectedUsers: ['user1'],
      ),
      SecurityIncident(
        id: '2',
        title: 'Şüpheli Veri Erişimi',
        description: 'Normal saatler dışında veri erişimi tespit edildi',
        type: SecurityIncidentType.unauthorizedAccess,
        severity: SecurityIncidentSeverity.medium,
        detectedAt: DateTime.now().subtract(const Duration(days: 1)),
        isResolved: false,
        affectedUsers: ['user2'],
      ),
    ]);

    _isInitialized = true;
  }

  // Şifreleme işlemleri
  String encryptData(String data) {
    // Basit AES-256 simülasyonu (gerçek uygulamada crypto kütüphanesi kullanılır)
    final bytes = utf8.encode(data);
    final key = _generateEncryptionKey();
    return base64.encode(bytes); // Basit encoding
  }

  String decryptData(String encryptedData) {
    // Basit AES-256 simülasyonu
    final bytes = base64.decode(encryptedData);
    return utf8.decode(bytes);
  }

  String _generateEncryptionKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Veri anonimleştirme
  String anonymizeData(String data, AnonymizationType type) {
    switch (type) {
      case AnonymizationType.mask:
        if (data.length > 4) {
          return '${'*' * (data.length - 4)}${data.substring(data.length - 4)}';
        }
        return '****';
      case AnonymizationType.hash:
        final bytes = utf8.encode(data);
        final digest = base64.encode(bytes); // Basit hash simülasyonu
        return digest;
      case AnonymizationType.replace:
        return '[ANONYMIZED]';
      case AnonymizationType.remove:
        return '';
      case AnonymizationType.randomize:
        return 'RND_${_random.nextInt(9999)}';
    }
  }

  // Erişim kontrolü
  bool hasPermission(String userId, String resource, String permission) {
    final userRole = _getUserRole(userId);
    final policy = _accessPolicies.firstWhere(
      (p) => p.roles.contains(userRole) && 
             (p.resources.contains(resource) || p.resources.contains('*')),
      orElse: () => AccessControlPolicy(
        id: '',
        name: '',
        description: '',
        roles: [],
        resources: [],
        permissions: [],
        isActive: false,
        createdAt: DateTime.now(),
        createdBy: 'system',
      ),
    );
    
    return policy.isActive && policy.permissions.contains(permission);
  }

  String _getUserRole(String userId) {
    // Basit rol belirleme (gerçek uygulamada veritabanından alınır)
    if (userId.startsWith('admin')) return 'admin';
    if (userId.startsWith('therapist')) return 'therapist';
    return 'user';
  }

  // Güvenlik olayı yönetimi
  SecurityIncident createSecurityIncident({
    required String title,
    required String description,
    required SecurityIncidentType type,
    required SecurityIncidentSeverity severity,
    required List<String> affectedUsers,
  }) {
    final incident = SecurityIncident(
      id: 'incident_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      severity: severity,
      detectedAt: DateTime.now(),
      isResolved: false,
      affectedUsers: affectedUsers,
    );
    
    _securityIncidents.add(incident);
    _addAuditLog(
      userId: 'system',
      userName: 'System',
      action: 'Güvenlik olayı oluşturuldu: $title',
      type: AuditLogType.security,
    );
    
    return incident;
  }

  bool resolveSecurityIncident(String incidentId, String resolvedBy, String notes) {
    final index = _securityIncidents.indexWhere((i) => i.id == incidentId);
    if (index != -1) {
      final incident = _securityIncidents[index];
      _securityIncidents[index] = SecurityIncident(
        id: incident.id,
        title: incident.title,
        description: incident.description,
        type: incident.type,
        severity: incident.severity,
        detectedAt: incident.detectedAt,
        isResolved: true,
        resolvedAt: DateTime.now(),
        resolutionNotes: notes,
        affectedUsers: incident.affectedUsers,
      );
      
      _addAuditLog(
        userId: resolvedBy,
        userName: resolvedBy,
        action: 'Güvenlik olayı çözüldü: ${incident.title}',
        type: AuditLogType.security,
      );
      
      return true;
    }
    return false;
  }

  // Veri saklama politikası yönetimi
  List<DataRetentionPolicy> getRetentionPolicies() => List.unmodifiable(_retentionPolicies);
  
  DataRetentionPolicy? getRetentionPolicyById(String id) {
    try {
      return _retentionPolicies.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  DataRetentionPolicy addRetentionPolicy(DataRetentionPolicy policy) {
    final newPolicy = DataRetentionPolicy(
      id: 'policy_${DateTime.now().millisecondsSinceEpoch}',
      name: policy.name,
      description: policy.description,
      retentionPeriod: policy.retentionPeriod,
      dataTypes: policy.dataTypes,
      autoDelete: policy.autoDelete,
      lastReview: DateTime.now(),
      reviewedBy: 'admin',
    );
    
    _retentionPolicies.add(newPolicy);
    _addAuditLog(
      userId: 'admin',
      userName: 'Admin',
      action: 'Veri saklama politikası eklendi: ${policy.name}',
      type: AuditLogType.security,
    );
    
    return newPolicy;
  }

  // Erişim kontrol politikası yönetimi
  List<AccessControlPolicy> getAccessPolicies() => List.unmodifiable(_accessPolicies);
  
  AccessControlPolicy? getAccessPolicyById(String id) {
    try {
      return _accessPolicies.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  AccessControlPolicy addAccessPolicy(AccessControlPolicy policy) {
    final newPolicy = AccessControlPolicy(
      id: 'policy_${DateTime.now().millisecondsSinceEpoch}',
      name: policy.name,
      description: policy.description,
      roles: policy.roles,
      resources: policy.resources,
      permissions: policy.permissions,
      isActive: policy.isActive,
      createdAt: DateTime.now(),
      createdBy: 'admin',
    );
    
    _accessPolicies.add(newPolicy);
    _addAuditLog(
      userId: 'admin',
      userName: 'Admin',
      action: 'Erişim kontrol politikası eklendi: ${policy.name}',
      type: AuditLogType.security,
    );
    
    return newPolicy;
  }

  // Veri anonimleştirme kuralı yönetimi
  List<DataAnonymizationRule> getAnonymizationRules() => List.unmodifiable(_anonymizationRules);
  
  DataAnonymizationRule? getAnonymizationRuleById(String id) {
    try {
      return _anonymizationRules.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  DataAnonymizationRule addAnonymizationRule(DataAnonymizationRule rule) {
    final newRule = DataAnonymizationRule(
      id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
      fieldName: rule.fieldName,
      type: rule.type,
      replacementValue: rule.replacementValue,
      isActive: rule.isActive,
      createdAt: DateTime.now(),
    );
    
    _anonymizationRules.add(newRule);
    _addAuditLog(
      userId: 'admin',
      userName: 'Admin',
      action: 'Anonimleştirme kuralı eklendi: ${rule.fieldName}',
      type: AuditLogType.security,
    );
    
    return newRule;
  }

  // Güvenlik durumu
  SecurityStatusDetails getSecurityStatus() => _securityStatus;
  
  void updateSecurityStatus(SecurityStatusDetails status) {
    _securityStatus = status;
    _addAuditLog(
      userId: 'system',
      userName: 'System',
      action: 'Güvenlik durumu güncellendi',
      type: AuditLogType.security,
    );
  }

  // Şifreleme konfigürasyonu
  EncryptionConfig getEncryptionConfig() => _encryptionConfig;
  
  void updateEncryptionConfig(EncryptionConfig config) {
    _encryptionConfig = config;
    _addAuditLog(
      userId: 'admin',
      userName: 'Admin',
      action: 'Şifreleme konfigürasyonu güncellendi',
      type: AuditLogType.security,
    );
  }

  // Güvenlik olayları
  List<SecurityIncident> getSecurityIncidents() => List.unmodifiable(_securityIncidents);
  
  List<SecurityIncident> getActiveIncidents() {
    return _securityIncidents.where((i) => !i.isResolved).toList();
  }
  
  List<SecurityIncident> getIncidentsBySeverity(SecurityIncidentSeverity severity) {
    return _securityIncidents.where((i) => i.severity == severity).toList();
  }

  // Yasal uyumluluk kontrolü
  Map<ComplianceFramework, bool> checkCompliance() {
    final region = RegionConfig.activeRegion;
    final compliance = <ComplianceFramework, bool>{};
    
    switch (region) {
      case 'US':
        compliance[ComplianceFramework.hipaa] = true;
        compliance[ComplianceFramework.gdpr] = false;
        compliance[ComplianceFramework.kvkk] = false;
        compliance[ComplianceFramework.pipeda] = false;
        break;
      case 'EU':
        compliance[ComplianceFramework.hipaa] = false;
        compliance[ComplianceFramework.gdpr] = true;
        compliance[ComplianceFramework.kvkk] = false;
        compliance[ComplianceFramework.pipeda] = false;
        break;
      case 'TR':
        compliance[ComplianceFramework.hipaa] = false;
        compliance[ComplianceFramework.gdpr] = false;
        compliance[ComplianceFramework.kvkk] = true;
        compliance[ComplianceFramework.pipeda] = false;
        break;
      case 'CA':
        compliance[ComplianceFramework.hipaa] = false;
        compliance[ComplianceFramework.gdpr] = false;
        compliance[ComplianceFramework.kvkk] = false;
        compliance[ComplianceFramework.pipeda] = true;
        break;
      default:
        compliance[ComplianceFramework.hipaa] = false;
        compliance[ComplianceFramework.gdpr] = false;
        compliance[ComplianceFramework.kvkk] = false;
        compliance[ComplianceFramework.pipeda] = false;
    }
    
    return compliance;
  }

  // Veri export/silme
  String exportUserData(String userId) {
    // Kullanıcı verilerini JSON formatında export et
    final userData = {
      'userId': userId,
      'exportDate': DateTime.now().toIso8601String(),
      'data': {
        'profile': 'user_profile_data',
        'sessions': 'session_data',
        'diagnoses': 'diagnosis_data',
      },
    };
    
    _addAuditLog(
      userId: userId,
      userName: userId,
      action: 'Veri export edildi',
      type: AuditLogType.dataAccess,
    );
    
    return jsonEncode(userData);
  }

  bool deleteUserData(String userId) {
    // Kullanıcı verilerini sil (gerçek uygulamada veritabanından silinir)
    _addAuditLog(
      userId: userId,
      userName: userId,
      action: 'Veri silme talebi',
      type: AuditLogType.dataModification,
    );
    
    return true; // Başarılı
  }

  // Mevcut metodlar
  void addAuditLog(AuditLog log) => _addAuditLog(
    userId: log.userId,
    userName: 'user',
    action: log.action,
    type: log.type,
    resourceId: log.resource,
    resourceType: 'resource',
    ipAddress: log.ipAddress,
    userAgent: log.userAgent,
  );

  void _addAuditLog({
    required String userId,
    required String userName,
    required String action,
    required AuditLogType type,
    String? resourceId,
    String? resourceType,
    String? ipAddress,
    String? userAgent,
  }) {
    final log = AuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      action: action,
      resource: resourceId ?? 'system',
      type: type,
      timestamp: DateTime.now(),
      ipAddress: ipAddress ?? 'unknown',
      userAgent: userAgent,
    );
    
    _auditLogs.add(log);
  }

  List<AuditLog> getAuditLogs() => List.unmodifiable(_auditLogs);
  
  List<AuditLog> getAuditLogsByUser(String userId) {
    return _auditLogs.where((log) => log.userId == userId).toList();
  }
  
  List<AuditLog> getAuditLogsByType(AuditLogType type) {
    return _auditLogs.where((log) => log.type == type).toList();
  }
  
  List<AuditLog> getAuditLogsByDateRange(DateTime start, DateTime end) {
    return _auditLogs.where((log) => 
        log.timestamp.isAfter(start.subtract(const Duration(days: 1))) && 
        log.timestamp.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  List<ComplianceReport> getComplianceReports() => List.unmodifiable(_complianceReports);
  
  ComplianceReport? getComplianceReportById(String id) {
    try {
      return _complianceReports.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearAllData() {
    _auditLogs.clear();
    _complianceReports.clear();
    _securityIncidents.clear();
    _retentionPolicies.clear();
    _accessPolicies.clear();
    _anonymizationRules.clear();
  }
}
