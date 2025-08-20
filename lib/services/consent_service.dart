import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consent_models.dart';
import '../utils/ai_logger.dart';

class ConsentService extends ChangeNotifier {
  static final ConsentService _instance = ConsentService._internal();
  factory ConsentService() => _instance;
  ConsentService._internal();

  final AILogger _logger = AILogger();
  
  List<ConsentRecord> _consentRecords = [];
  List<ConsentVersion> _consentVersions = [];
  Map<String, ConsentTemplate> _consentTemplates = {};
  
  // Getters
  List<ConsentRecord> get consentRecords => List.unmodifiable(_consentRecords);
  List<ConsentVersion> get consentVersions => List.unmodifiable(_consentVersions);
  Map<String, ConsentTemplate> get consentTemplates => Map.unmodifiable(_consentTemplates);

  Future<void> initialize() async {
    try {
      _logger.info('ConsentService initializing...', context: 'ConsentService');
      
      await _loadConsentData();
      await _initializeDefaultTemplates();
      
      _logger.info('ConsentService initialized successfully', context: 'ConsentService');
    } catch (e) {
      _logger.error('Failed to initialize ConsentService', context: 'ConsentService', error: e);
      rethrow;
    }
  }

  Future<void> _loadConsentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load consent records
      final recordsJson = prefs.getString('consent_records');
      if (recordsJson != null) {
        final List<dynamic> recordsList = json.decode(recordsJson);
        _consentRecords = recordsList.map((record) => ConsentRecord.fromJson(record)).toList();
      }
      
      // Load consent versions
      final versionsJson = prefs.getString('consent_versions');
      if (versionsJson != null) {
        final List<dynamic> versionsList = json.decode(versionsJson);
        _consentVersions = versionsList.map((version) => ConsentVersion.fromJson(version)).toList();
      }
      
      _logger.info('Consent data loaded: ${_consentRecords.length} records, ${_consentVersions.length} versions', 
                   context: 'ConsentService');
    } catch (e) {
      _logger.error('Failed to load consent data', context: 'ConsentService', error: e);
    }
  }

  Future<void> _initializeDefaultTemplates() async {
    _consentTemplates = {
      'kvkk_tr': ConsentTemplate(
        id: 'kvkk_tr',
        name: 'KVKK Aydınlatma Metni ve Açık Rıza',
        region: 'TR',
        version: '1.0',
        content: '''
Kişisel verileriniz 6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında işlenir.

1. Veri Sorumlusu: [Kurum Adı]
2. İşlenen Veriler: Ad, soyad, TC kimlik no, doğum tarihi, sağlık bilgileri
3. Amaç: Sağlık hizmeti sunumu, tedavi planlaması, randevu yönetimi
4. Hukuki Dayanak: Açık rıza, sözleşme, meşru menfaat
5. Saklama Süresi: Tedavi süresi + 10 yıl
6. Haklarınız: Bilgi alma, erişim, düzeltme, silme, işlemeyi sınırlama

Açık rızanızı veriyor musunuz?
        ''',
        requiredFields: ['patientName', 'tcKimlikNo', 'consentDate'],
        legalBasis: 'explicit_consent',
        retentionPeriod: 'treatment_duration_plus_10_years',
        isActive: true,
      ),
      
      'hipaa_us': ConsentTemplate(
        id: 'hipaa_us',
        name: 'HIPAA Notice of Privacy Practices',
        region: 'US',
        version: '1.0',
        content: '''
This notice describes how medical information about you may be used and disclosed and how you can get access to this information.

1. Uses and Disclosures: Treatment, payment, healthcare operations
2. Your Rights: Access, amendment, accounting of disclosures, restrictions
3. Our Responsibilities: Maintain privacy, provide notice, honor restrictions
4. Contact: Privacy Officer at [Contact Information]

Do you acknowledge receipt of this notice?
        ''',
        requiredFields: ['patientName', 'acknowledgmentDate', 'signature'],
        legalBasis: 'acknowledgment',
        retentionPeriod: '6_years',
        isActive: true,
      ),
      
      'gdpr_eu': ConsentTemplate(
        id: 'gdpr_eu',
        name: 'GDPR Consent for Special Categories of Data',
        region: 'EU',
        version: '1.0',
        content: '''
Your personal data, including health information, is processed in accordance with GDPR Article 9.

1. Data Controller: [Organization Name]
2. Legal Basis: Explicit consent for health data processing
3. Data Categories: Health data, identification data, contact information
4. Purpose: Healthcare provision, treatment planning, appointment management
5. Retention: Treatment duration + legal requirements
6. Your Rights: Access, rectification, erasure, portability, objection

Do you provide explicit consent for health data processing?
        ''',
        requiredFields: ['patientName', 'consentDate', 'explicitConsent'],
        legalBasis: 'explicit_consent',
        retentionPeriod: 'treatment_duration_plus_legal_requirements',
        isActive: true,
      ),
    };
  }

  // ===== CONSENT MANAGEMENT =====
  
  Future<ConsentRecord> createConsent({
    required String patientId,
    required String consentType,
    required String region,
    required Map<String, dynamic> consentData,
    required String recordedBy,
    String? notes,
  }) async {
    try {
      // Get latest template version
      final template = _getLatestTemplate(consentType, region);
      if (template == null) {
        throw Exception('No active template found for $consentType in $region');
      }
      
      // Create consent version
      final version = ConsentVersion(
        id: _generateId(),
        templateId: template.id,
        versionNumber: template.version,
        content: template.content,
        effectiveDate: DateTime.now(),
        isActive: true,
      );
      
      // Create consent record
      final consent = ConsentRecord(
        id: _generateId(),
        patientId: patientId,
        consentType: consentType,
        region: region,
        versionId: version.id,
        consentDate: DateTime.now(),
        expiryDate: _calculateExpiryDate(template.retentionPeriod),
        isActive: true,
        consentText: template.content,
        consentData: consentData,
        purposes: template.requiredFields,
        method: ConsentMethod.electronic,
        recordedBy: recordedBy,
        notes: notes,
        metadata: {
          'templateVersion': template.version,
          'legalBasis': template.legalBasis,
          'retentionPeriod': template.retentionPeriod,
        },
      );
      
      // Save to storage
      _consentRecords.add(consent);
      _consentVersions.add(version);
      
      await _saveConsentData();
      
      _logger.info('Consent created successfully', context: 'ConsentService', data: {
        'consentId': consent.id,
        'patientId': patientId,
        'type': consentType,
        'region': region,
      });
      
      notifyListeners();
      return consent;
      
    } catch (e) {
      _logger.error('Failed to create consent', context: 'ConsentService', error: e);
      rethrow;
    }
  }

  Future<void> updateConsent({
    required String consentId,
    required Map<String, dynamic> updates,
    required String updatedBy,
    String? reason,
  }) async {
    try {
      final consentIndex = _consentRecords.indexWhere((c) => c.id == consentId);
      if (consentIndex == -1) {
        throw Exception('Consent not found: $consentId');
      }
      
      final oldConsent = _consentRecords[consentIndex];
      
      // Create new version if content changed
      if (updates.containsKey('consentText') || updates.containsKey('consentData')) {
        final newVersion = ConsentVersion(
          id: _generateId(),
          templateId: oldConsent.versionId,
          versionNumber: _incrementVersion(oldConsent.versionId),
          content: updates['consentText'] ?? oldConsent.consentText,
          effectiveDate: DateTime.now(),
          isActive: true,
        );
        
        _consentVersions.add(newVersion);
        updates['versionId'] = newVersion.id;
      }
      
      // Update consent record
      final updatedConsent = oldConsent.copyWith(
        lastModified: DateTime.now(),
        lastModifiedBy: updatedBy,
        modificationHistory: [
          ...oldConsent.modificationHistory,
          ConsentModification(
            id: _generateId(),
            modifiedAt: DateTime.now(),
            modifiedBy: updatedBy,
            reason: reason ?? 'Update',
            changes: updates,
          ),
        ],
      );
      
      _consentRecords[consentIndex] = updatedConsent;
      
      await _saveConsentData();
      
      _logger.info('Consent updated successfully', context: 'ConsentService', data: {
        'consentId': consentId,
        'updatedBy': updatedBy,
        'reason': reason,
      });
      
      notifyListeners();
      
    } catch (e) {
      _logger.error('Failed to update consent', context: 'ConsentService', error: e);
      rethrow;
    }
  }

  Future<void> revokeConsent({
    required String consentId,
    required String revokedBy,
    required String reason,
  }) async {
    try {
      final consentIndex = _consentRecords.indexWhere((c) => c.id == consentId);
      if (consentIndex == -1) {
        throw Exception('Consent not found: $consentId');
      }
      
      final consent = _consentRecords[consentIndex];
      
      final revokedConsent = consent.copyWith(
        isActive: false,
        revokedAt: DateTime.now(),
        revokedBy: revokedBy,
        revocationReason: reason,
        modificationHistory: [
          ...consent.modificationHistory,
          ConsentModification(
            id: _generateId(),
            modifiedAt: DateTime.now(),
            modifiedBy: revokedBy,
            reason: 'Revocation',
            changes: {'isActive': false, 'revokedAt': DateTime.now().toIso8601String()},
          ),
        ],
      );
      
      _consentRecords[consentIndex] = revokedConsent;
      
      await _saveConsentData();
      
      _logger.info('Consent revoked successfully', context: 'ConsentService', data: {
        'consentId': consentId,
        'revokedBy': revokedBy,
        'reason': reason,
      });
      
      notifyListeners();
      
    } catch (e) {
      _logger.error('Failed to revoke consent', context: 'ConsentService', error: e);
      rethrow;
    }
  }

  // ===== CONSENT QUERIES =====
  
  List<ConsentRecord> getPatientConsents(String patientId) {
    return _consentRecords.where((c) => c.patientId == patientId).toList();
  }
  
  List<ConsentRecord> getActiveConsents(String patientId, String consentType) {
    return _consentRecords.where((c) => 
      c.patientId == patientId && 
      c.consentType == consentType && 
      c.isActive &&
      (c.expiryDate == null || c.expiryDate!.isAfter(DateTime.now()))
    ).toList();
  }
  
  bool hasValidConsent(String patientId, String consentType, String region) {
    final activeConsents = getActiveConsents(patientId, consentType);
    return activeConsents.any((c) => c.region == region);
  }
  
  List<ConsentRecord> getConsentsByRegion(String region) {
    return _consentRecords.where((c) => c.region == region).toList();
  }
  
  List<ConsentRecord> getExpiringConsents({int daysThreshold = 30}) {
    final threshold = DateTime.now().add(Duration(days: daysThreshold));
    return _consentRecords.where((c) => 
      c.isActive && 
      c.expiryDate != null && 
      c.expiryDate!.isBefore(threshold)
    ).toList();
  }

  // ===== COMPLIANCE & AUDIT =====
  
  Future<ConsentComplianceReport> generateComplianceReport({
    String? region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final filteredConsents = _consentRecords.where((c) {
        if (region != null && c.region != region) return false;
        if (startDate != null && c.consentDate.isBefore(startDate)) return false;
        if (endDate != null && c.consentDate.isAfter(endDate)) return false;
        return true;
      }).toList();
      
      final totalConsents = filteredConsents.length;
      final activeConsents = filteredConsents.where((c) => c.isActive).length;
      final expiredConsents = filteredConsents.where((c) => 
        c.expiryDate != null && c.expiryDate!.isBefore(DateTime.now())
      ).length;
      final revokedConsents = filteredConsents.where((c) => c.revokedAt != null).length;
      
      final complianceRate = totalConsents > 0 ? activeConsents / totalConsents : 0.0;
      
      return ConsentComplianceReport(
        id: _generateId(),
        generatedAt: DateTime.now(),
        region: region,
        startDate: startDate,
        endDate: endDate,
        totalConsents: totalConsents,
        activeConsents: activeConsents,
        expiredConsents: expiredConsents,
        revokedConsents: revokedConsents,
        complianceRate: complianceRate,
        recommendations: _generateComplianceRecommendations(
          totalConsents, activeConsents, expiredConsents, revokedConsents
        ),
      );
      
    } catch (e) {
      _logger.error('Failed to generate compliance report', context: 'ConsentService', error: e);
      rethrow;
    }
  }

  List<String> _generateComplianceRecommendations(
    int total, int active, int expired, int revoked
  ) {
    final recommendations = <String>[];
    
    if (expired > 0) {
      recommendations.add('$expired süresi dolmuş onam var. Yenileme gerekli.');
    }
    
    if (revoked > total * 0.1) {
      recommendations.add('Onam iptal oranı yüksek. Süreç gözden geçirilmeli.');
    }
    
    if (active < total * 0.8) {
      recommendations.add('Aktif onam oranı düşük. Uyumluluk riski var.');
    }
    
    return recommendations;
  }

  // ===== UTILITY METHODS =====
  
  ConsentTemplate? _getLatestTemplate(String consentType, String region) {
    final templates = _consentTemplates.values.where((t) => 
      t.id.contains(consentType) && t.region == region && t.isActive
    ).toList();
    
    if (templates.isEmpty) return null;
    
    // Return template with highest version
    templates.sort((a, b) => b.version.compareTo(a.version));
    return templates.first;
  }
  
  DateTime? _calculateExpiryDate(String retentionPeriod) {
    switch (retentionPeriod) {
      case '6_years':
        return DateTime.now().add(const Duration(days: 6 * 365));
      case 'treatment_duration_plus_10_years':
        // Default to 10 years for now
        return DateTime.now().add(const Duration(days: 10 * 365));
      case 'treatment_duration_plus_legal_requirements':
        // Default to 15 years for EU
        return DateTime.now().add(const Duration(days: 15 * 365));
      default:
        return null;
    }
  }
  
  String _incrementVersion(String currentVersion) {
    final parts = currentVersion.split('.');
    if (parts.length == 2) {
      final major = int.parse(parts[0]);
      final minor = int.parse(parts[1]);
      return '$major.${minor + 1}';
    }
    return '$currentVersion.1';
  }
  
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
  
  Future<void> _saveConsentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save consent records
      final recordsJson = json.encode(_consentRecords.map((r) => r.toJson()).toList());
      await prefs.setString('consent_records', recordsJson);
      
      // Save consent versions
      final versionsJson = json.encode(_consentVersions.map((v) => v.toJson()).toList());
      await prefs.setString('consent_versions', versionsJson);
      
    } catch (e) {
      _logger.error('Failed to save consent data', context: 'ConsentService', error: e);
      rethrow;
    }
  }
}
