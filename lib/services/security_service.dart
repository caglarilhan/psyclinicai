import 'dart:math';
import '../models/security_models.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  bool _isInitialized = false;
  final List<AuditLog> _auditLogs = [];
  final List<ComplianceReport> _complianceReports = [];
  final Random _random = Random();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Demo audit log verileri
    _auditLogs.addAll([
      AuditLog(
        id: '1',
        userId: 'user1',
        userName: 'Dr. Ahmet Yılmaz',
        action: 'Sisteme giriş yapıldı',
        type: AuditLogType.login,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ipAddress: '192.168.1.100',
        userAgent: 'Chrome/120.0.0.0',
      ),
      AuditLog(
        id: '2',
        userId: 'user1',
        userName: 'Dr. Ahmet Yılmaz',
        action: 'Danışan verisi görüntülendi',
        type: AuditLogType.dataAccess,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        resourceId: 'client123',
        resourceType: 'client',
        ipAddress: '192.168.1.100',
      ),
      AuditLog(
        id: '3',
        userId: 'user1',
        userName: 'Dr. Ahmet Yılmaz',
        action: 'Seans notu güncellendi',
        type: AuditLogType.dataModification,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        resourceId: 'session456',
        resourceType: 'session',
        ipAddress: '192.168.1.100',
      ),
      AuditLog(
        id: '4',
        userId: 'user2',
        userName: 'Dr. Ayşe Demir',
        action: 'Sisteme giriş yapıldı',
        type: AuditLogType.login,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ipAddress: '192.168.1.101',
        userAgent: 'Firefox/119.0',
      ),
      AuditLog(
        id: '5',
        userId: 'user2',
        userName: 'Dr. Ayşe Demir',
        action: 'Güvenlik ayarları değiştirildi',
        type: AuditLogType.security,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ipAddress: '192.168.1.101',
      ),
    ]);

    // Demo compliance report verileri
    _complianceReports.addAll([
      ComplianceReport(
        id: '1',
        complianceType: 'KVKK Uyumluluğu',
        status: ComplianceStatus.compliant,
        lastChecked: DateTime.now().subtract(const Duration(days: 1)),
        nextCheck: DateTime.now().add(const Duration(days: 29)),
        notes: 'Tüm KVKK gereksinimleri karşılanıyor',
        requirements: [
          ComplianceRequirement(
            id: 'kvkk1',
            title: 'Açık Rıza',
            description: 'Kullanıcı açık rıza veriyor',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ComplianceRequirement(
            id: 'kvkk2',
            title: 'Veri Güvenliği',
            description: 'AES-256 şifreleme aktif',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ComplianceRequirement(
            id: 'kvkk3',
            title: 'Veri Silme Hakkı',
            description: 'Kullanıcı verilerini silebiliyor',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      ComplianceReport(
        id: '2',
        complianceType: 'HIPAA Uyumluluğu',
        status: ComplianceStatus.warning,
        lastChecked: DateTime.now().subtract(const Duration(days: 2)),
        nextCheck: DateTime.now().add(const Duration(days: 28)),
        notes: 'Bazı HIPAA gereksinimleri eksik',
        requirements: [
          ComplianceRequirement(
            id: 'hipaa1',
            title: 'Veri Şifreleme',
            description: 'AES-256 şifreleme aktif',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ComplianceRequirement(
            id: 'hipaa2',
            title: 'Denetim Kaydı',
            description: 'Tüm erişimler kaydediliyor',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ComplianceRequirement(
            id: 'hipaa3',
            title: 'Erişim Kontrolü',
            description: 'Rol bazlı erişim eksik',
            isCompliant: false,
            notes: 'Rol bazlı erişim sistemi kurulmalı',
            lastChecked: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
      ComplianceReport(
        id: '3',
        complianceType: 'GDPR Uyumluluğu',
        status: ComplianceStatus.compliant,
        lastChecked: DateTime.now().subtract(const Duration(days: 3)),
        nextCheck: DateTime.now().add(const Duration(days: 27)),
        notes: 'GDPR gereksinimleri tam karşılanıyor',
        requirements: [
          ComplianceRequirement(
            id: 'gdpr1',
            title: 'Veri Dışa Aktarma',
            description: 'Kullanıcı verilerini dışa aktarabiliyor',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 3)),
          ),
          ComplianceRequirement(
            id: 'gdpr2',
            title: 'Veri Silme',
            description: 'Unutulma hakkı aktif',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 3)),
          ),
          ComplianceRequirement(
            id: 'gdpr3',
            title: 'DPO Ataması',
            description: 'Veri koruma görevlisi atandı',
            isCompliant: true,
            lastChecked: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      ),
    ]);

    _isInitialized = true;
  }

  // Güvenlik durumu al
  Future<SecurityStatus> getSecurityStatus() async {
    await initialize();
    
    // Demo güvenlik skorları
    final overallScore = 85.0 + _random.nextDouble() * 10;
    final encryptionScore = 95.0 + _random.nextDouble() * 5;
    final accessControlScore = 80.0 + _random.nextDouble() * 15;
    final auditScore = 90.0 + _random.nextDouble() * 10;
    
    return SecurityStatus(
      overallScore: overallScore.clamp(0.0, 100.0),
      encryptionScore: encryptionScore.clamp(0.0, 100.0),
      accessControlScore: accessControlScore.clamp(0.0, 100.0),
      auditScore: auditScore.clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
      issues: _generateSecurityIssues(),
    );
  }

  // Denetim kayıtları al
  Future<List<AuditLog>> getAuditLogs() async {
    await initialize();
    return _auditLogs;
  }

  // Uyumluluk raporları al
  Future<List<ComplianceReport>> getComplianceReports() async {
    await initialize();
    return _complianceReports;
  }

  // Güvenlik sorunları oluştur
  List<SecurityIssue> _generateSecurityIssues() {
    return [
      SecurityIssue(
        id: '1',
        title: 'Erişim Kontrolü Eksik',
        description: 'Rol bazlı erişim sistemi tam kurulmamış',
        type: SecurityIssueType.access,
        severity: SecurityIssueSeverity.medium,
        detectedAt: DateTime.now().subtract(const Duration(days: 2)),
        isResolved: false,
      ),
      SecurityIssue(
        id: '2',
        title: 'Şifreleme Anahtarı Rotasyonu',
        description: 'Şifreleme anahtarları 90 günden eski',
        type: SecurityIssueType.encryption,
        severity: SecurityIssueSeverity.low,
        detectedAt: DateTime.now().subtract(const Duration(days: 5)),
        isResolved: false,
      ),
    ];
  }

  // Yeni denetim kaydı ekle
  Future<void> addAuditLog(AuditLog log) async {
    await initialize();
    _auditLogs.insert(0, log);
  }

  // Yeni uyumluluk raporu ekle
  Future<void> addComplianceReport(ComplianceReport report) async {
    await initialize();
    _complianceReports.add(report);
  }

  // Güvenlik olayı ekle
  Future<void> addSecurityEvent(SecurityEvent event) async {
    await initialize();
    // TODO: Güvenlik olaylarını kaydet
  }

  // Güvenlik taraması çalıştır
  Future<SecurityStatus> runSecurityScan() async {
    await initialize();
    
    // Simüle edilmiş tarama süresi
    await Future.delayed(const Duration(seconds: 2));
    
    return await getSecurityStatus();
  }

  // Uyumluluk kontrolü çalıştır
  Future<List<ComplianceReport>> runComplianceCheck() async {
    await initialize();
    
    // Simüle edilmiş kontrol süresi
    await Future.delayed(const Duration(seconds: 3));
    
    return _complianceReports;
  }

  // Güvenlik raporu oluştur
  Future<Map<String, dynamic>> generateSecurityReport() async {
    await initialize();
    
    final status = await getSecurityStatus();
    final logs = await getAuditLogs();
    final reports = await getComplianceReports();
    
    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'overallScore': status.overallScore,
      'encryptionScore': status.encryptionScore,
      'accessControlScore': status.accessControlScore,
      'auditScore': status.auditScore,
      'totalAuditLogs': logs.length,
      'totalComplianceReports': reports.length,
      'securityLevel': status.securityLevel.name,
      'recommendations': _generateRecommendations(status),
    };
  }

  // Öneriler oluştur
  List<String> _generateRecommendations(SecurityStatus status) {
    final recommendations = <String>[];
    
    if (status.overallScore < 90) {
      recommendations.add('Genel güvenlik skorunu artırmak için güvenlik açıklarını giderin');
    }
    
    if (status.encryptionScore < 95) {
      recommendations.add('Şifreleme standartlarını güncelleyin');
    }
    
    if (status.accessControlScore < 85) {
      recommendations.add('Erişim kontrol sistemini güçlendirin');
    }
    
    if (status.auditScore < 90) {
      recommendations.add('Denetim kayıt sistemini iyileştirin');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Güvenlik durumu mükemmel! Mevcut standartları koruyun.');
    }
    
    return recommendations;
  }

  // Güvenlik ayarlarını güncelle
  Future<void> updateSecuritySettings(Map<String, dynamic> settings) async {
    await initialize();
    // TODO: Güvenlik ayarlarını güncelle
  }

  // Güvenlik olaylarını filtrele
  Future<List<AuditLog>> filterAuditLogs({
    AuditLogType? type,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await initialize();
    
    var filteredLogs = _auditLogs;
    
    if (type != null) {
      filteredLogs = filteredLogs.where((log) => log.type == type).toList();
    }
    
    if (userId != null) {
      filteredLogs = filteredLogs.where((log) => log.userId == userId).toList();
    }
    
    if (startDate != null) {
      filteredLogs = filteredLogs.where((log) => log.timestamp.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      filteredLogs = filteredLogs.where((log) => log.timestamp.isBefore(endDate)).toList();
    }
    
    return filteredLogs;
  }

  // Uyumluluk raporlarını filtrele
  Future<List<ComplianceReport>> filterComplianceReports({
    ComplianceStatus? status,
    String? complianceType,
  }) async {
    await initialize();
    
    var filteredReports = _complianceReports;
    
    if (status != null) {
      filteredReports = filteredReports.where((report) => report.status == status).toList();
    }
    
    if (complianceType != null) {
      filteredReports = filteredReports.where((report) => report.complianceType.contains(complianceType)).toList();
    }
    
    return filteredReports;
  }
}
