import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/compliance_models.dart';
import 'audit_log_service.dart';

class ComplianceService {
  static final ComplianceService _instance = ComplianceService._internal();
  factory ComplianceService() => _instance;
  ComplianceService._internal();

  static const _secureStorage = FlutterSecureStorage();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'psyclinicai.enc.db');
    String? encryptionKey = await _getEncryptionKey();
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: encryptionKey,
    );
  }

  Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'db_encryption_key');
    if (key == null) {
      key = _generateRandomKey();
      await _secureStorage.write(key: 'db_encryption_key', value: key);
    }
    return key;
  }

  String _generateRandomKey() {
    return 'compliance-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE compliance_reports (
        id TEXT PRIMARY KEY,
        region TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        valid_until TEXT NOT NULL,
        generated_by TEXT NOT NULL,
        checks TEXT NOT NULL,
        violations TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE compliance_violations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        severity TEXT NOT NULL,
        detected_at TEXT NOT NULL,
        detected_by TEXT NOT NULL,
        resolved_at TEXT,
        resolved_by TEXT,
        resolution TEXT,
        details TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE compliance_recommendations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        implemented_at TEXT,
        implemented_by TEXT,
        implementation TEXT,
        details TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE data_processing_records (
        id TEXT PRIMARY KEY,
        purpose TEXT NOT NULL,
        legal_basis TEXT NOT NULL,
        data_categories TEXT NOT NULL,
        recipients TEXT NOT NULL,
        third_country_transfer TEXT,
        retention_period TEXT NOT NULL,
        data_controller TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        details TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE privacy_impact_assessments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        region TEXT NOT NULL,
        type TEXT NOT NULL,
        data_subjects TEXT NOT NULL,
        data_categories TEXT NOT NULL,
        processing_purpose TEXT NOT NULL,
        legal_basis TEXT NOT NULL,
        risks TEXT NOT NULL,
        mitigations TEXT NOT NULL,
        status TEXT NOT NULL,
        assessed_at TEXT NOT NULL,
        assessed_by TEXT NOT NULL,
        approved_at TEXT,
        approved_by TEXT,
        details TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Compliance Report Management
  Future<String> createComplianceReport({
    required ComplianceRegion region,
    required ComplianceType type,
    required String generatedBy,
  }) async {
    final db = await database;
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';
    
    final now = DateTime.now();
    final validUntil = now.add(const Duration(days: 365));
    
    final checks = await _generateComplianceChecks(region, type);
    final violations = await _detectComplianceViolations(region, type);
    final recommendations = await _generateComplianceRecommendations(region, type);
    
    final status = violations.isEmpty ? ComplianceStatus.compliant : ComplianceStatus.nonCompliant;
    
    final report = ComplianceReport(
      id: reportId,
      region: region,
      type: type,
      status: status,
      generatedAt: now,
      validUntil: validUntil,
      generatedBy: generatedBy,
      checks: checks,
      violations: violations,
      recommendations: recommendations,
    );
    
    await db.insert('compliance_reports', {
      ...report.toJson(),
      'created_at': now.toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'compliance.report_create',
      details: 'Compliance report created: $reportId',
      userId: generatedBy,
      resourceId: reportId,
    );
    
    return reportId;
  }

  Future<List<ComplianceCheck>> _generateComplianceChecks(ComplianceRegion region, ComplianceType type) async {
    final checks = <ComplianceCheck>[];
    final now = DateTime.now();
    
    // Generate region-specific compliance checks
    switch (region) {
      case ComplianceRegion.US:
        checks.addAll(_generateHIPAAComplianceChecks(now));
        break;
      case ComplianceRegion.EU:
        checks.addAll(_generateGDPRComplianceChecks(now));
        break;
      case ComplianceRegion.TR:
        checks.addAll(_generateKVKKComplianceChecks(now));
        break;
      case ComplianceRegion.CA:
        checks.addAll(_generatePIPEDAComplianceChecks(now));
        break;
      case ComplianceRegion.AU:
        checks.addAll(_generatePrivacyActComplianceChecks(now));
        break;
    }
    
    return checks;
  }

  List<ComplianceCheck> _generateHIPAAComplianceChecks(DateTime now) {
    return [
      ComplianceCheck(
        id: 'hipaa_001',
        title: 'Administrative Safeguards',
        description: 'Policies and procedures for HIPAA compliance',
        status: ComplianceStatus.compliant,
        details: 'All administrative safeguards are in place',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'hipaa_002',
        title: 'Physical Safeguards',
        description: 'Physical security measures for PHI protection',
        status: ComplianceStatus.compliant,
        details: 'Physical safeguards are properly implemented',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'hipaa_003',
        title: 'Technical Safeguards',
        description: 'Technical security measures for PHI protection',
        status: ComplianceStatus.compliant,
        details: 'Technical safeguards are properly configured',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'hipaa_004',
        title: 'Business Associate Agreements',
        description: 'BAAs with all business associates',
        status: ComplianceStatus.partial,
        details: 'Some BAAs need to be updated',
        checkedAt: now,
        checkedBy: 'system',
      ),
    ];
  }

  List<ComplianceCheck> _generateGDPRComplianceChecks(DateTime now) {
    return [
      ComplianceCheck(
        id: 'gdpr_001',
        title: 'Lawful Basis for Processing',
        description: 'Clear legal basis for all data processing activities',
        status: ComplianceStatus.compliant,
        details: 'All processing activities have lawful basis',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'gdpr_002',
        title: 'Data Subject Rights',
        description: 'Mechanisms for data subject rights fulfillment',
        status: ComplianceStatus.compliant,
        details: 'Data subject rights are properly implemented',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'gdpr_003',
        title: 'Data Protection Impact Assessment',
        description: 'DPIAs for high-risk processing activities',
        status: ComplianceStatus.pending,
        details: 'Some DPIAs need to be completed',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'gdpr_004',
        title: 'Data Breach Notification',
        description: 'Procedures for data breach notification',
        status: ComplianceStatus.compliant,
        details: 'Breach notification procedures are in place',
        checkedAt: now,
        checkedBy: 'system',
      ),
    ];
  }

  List<ComplianceCheck> _generateKVKKComplianceChecks(DateTime now) {
    return [
      ComplianceCheck(
        id: 'kvkk_001',
        title: 'Aydınlatma Yükümlülüğü',
        description: 'Kişisel verilerin işlenmesi hakkında bilgilendirme',
        status: ComplianceStatus.compliant,
        details: 'Aydınlatma metinleri güncel ve eksiksiz',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'kvkk_002',
        title: 'Açık Rıza',
        description: 'Kişisel veri işleme için açık rıza alınması',
        status: ComplianceStatus.compliant,
        details: 'Açık rıza mekanizmaları düzgün çalışıyor',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'kvkk_003',
        title: 'Veri Güvenliği',
        description: 'Kişisel verilerin güvenliğinin sağlanması',
        status: ComplianceStatus.compliant,
        details: 'Teknik ve idari tedbirler alınmış',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'kvkk_004',
        title: 'Veri Sorumlusu Sicili',
        description: 'VERBİS kaydının yapılması',
        status: ComplianceStatus.pending,
        details: 'VERBİS kaydı tamamlanmalı',
        checkedAt: now,
        checkedBy: 'system',
      ),
    ];
  }

  List<ComplianceCheck> _generatePIPEDAComplianceChecks(DateTime now) {
    return [
      ComplianceCheck(
        id: 'pipeda_001',
        title: 'Consent',
        description: 'Valid consent for personal information collection',
        status: ComplianceStatus.compliant,
        details: 'Consent mechanisms are properly implemented',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'pipeda_002',
        title: 'Purpose Limitation',
        description: 'Personal information used only for stated purposes',
        status: ComplianceStatus.compliant,
        details: 'Purpose limitation is properly enforced',
        checkedAt: now,
        checkedBy: 'system',
      ),
    ];
  }

  List<ComplianceCheck> _generatePrivacyActComplianceChecks(DateTime now) {
    return [
      ComplianceCheck(
        id: 'privacy_act_001',
        title: 'Collection Limitation',
        description: 'Personal information collected only when necessary',
        status: ComplianceStatus.compliant,
        details: 'Collection limitation principles are followed',
        checkedAt: now,
        checkedBy: 'system',
      ),
      ComplianceCheck(
        id: 'privacy_act_002',
        title: 'Use Limitation',
        description: 'Personal information used only for stated purposes',
        status: ComplianceStatus.compliant,
        details: 'Use limitation is properly enforced',
        checkedAt: now,
        checkedBy: 'system',
      ),
    ];
  }

  Future<List<ComplianceViolation>> _detectComplianceViolations(ComplianceRegion region, ComplianceType type) async {
    final violations = <ComplianceViolation>[];
    final now = DateTime.now();
    
    // Mock violation detection - in real app, this would be based on actual system analysis
    if (region == ComplianceRegion.US && type == ComplianceType.HIPAA) {
      violations.add(ComplianceViolation(
        id: 'violation_001',
        title: 'Missing Business Associate Agreement',
        description: 'Some business associates do not have valid BAAs',
        severity: ComplianceSeverity.medium,
        detectedAt: now,
        detectedBy: 'system',
      ));
    }
    
    if (region == ComplianceRegion.TR && type == ComplianceType.KVKK) {
      violations.add(ComplianceViolation(
        id: 'violation_002',
        title: 'VERBİS Kaydı Eksik',
        description: 'Veri sorumlusu sicili kaydı tamamlanmamış',
        severity: ComplianceSeverity.high,
        detectedAt: now,
        detectedBy: 'system',
      ));
    }
    
    return violations;
  }

  Future<List<ComplianceRecommendation>> _generateComplianceRecommendations(ComplianceRegion region, ComplianceType type) async {
    final recommendations = <ComplianceRecommendation>[];
    final now = DateTime.now();
    
    // Generate region-specific recommendations
    switch (region) {
      case ComplianceRegion.US:
        recommendations.addAll(_generateHIPAARecommendations(now));
        break;
      case ComplianceRegion.EU:
        recommendations.addAll(_generateGDPRRecommendations(now));
        break;
      case ComplianceRegion.TR:
        recommendations.addAll(_generateKVKKRecommendations(now));
        break;
      case ComplianceRegion.CA:
        recommendations.addAll(_generatePIPEDARecommendations(now));
        break;
      case ComplianceRegion.AU:
        recommendations.addAll(_generatePrivacyActRecommendations(now));
        break;
    }
    
    return recommendations;
  }

  List<ComplianceRecommendation> _generateHIPAARecommendations(DateTime now) {
    return [
      ComplianceRecommendation(
        id: 'rec_hipaa_001',
        title: 'Update Business Associate Agreements',
        description: 'Review and update all BAAs to ensure compliance',
        priority: CompliancePriority.high,
        createdAt: now,
        createdBy: 'system',
      ),
      ComplianceRecommendation(
        id: 'rec_hipaa_002',
        title: 'Conduct Risk Assessment',
        description: 'Perform comprehensive risk assessment',
        priority: CompliancePriority.medium,
        createdAt: now,
        createdBy: 'system',
      ),
    ];
  }

  List<ComplianceRecommendation> _generateGDPRRecommendations(DateTime now) {
    return [
      ComplianceRecommendation(
        id: 'rec_gdpr_001',
        title: 'Complete Data Protection Impact Assessments',
        description: 'Conduct DPIAs for high-risk processing activities',
        priority: CompliancePriority.high,
        createdAt: now,
        createdBy: 'system',
      ),
      ComplianceRecommendation(
        id: 'rec_gdpr_002',
        title: 'Update Privacy Policy',
        description: 'Ensure privacy policy is comprehensive and up-to-date',
        priority: CompliancePriority.medium,
        createdAt: now,
        createdBy: 'system',
      ),
    ];
  }

  List<ComplianceRecommendation> _generateKVKKRecommendations(DateTime now) {
    return [
      ComplianceRecommendation(
        id: 'rec_kvkk_001',
        title: 'VERBİS Kaydını Tamamla',
        description: 'Veri sorumlusu sicili kaydını tamamlayın',
        priority: CompliancePriority.urgent,
        createdAt: now,
        createdBy: 'system',
      ),
      ComplianceRecommendation(
        id: 'rec_kvkk_002',
        title: 'Aydınlatma Metinlerini Güncelle',
        description: 'Aydınlatma metinlerini gözden geçirin ve güncelleyin',
        priority: CompliancePriority.medium,
        createdAt: now,
        createdBy: 'system',
      ),
    ];
  }

  List<ComplianceRecommendation> _generatePIPEDARecommendations(DateTime now) {
    return [
      ComplianceRecommendation(
        id: 'rec_pipeda_001',
        title: 'Review Consent Mechanisms',
        description: 'Ensure consent mechanisms are robust and compliant',
        priority: CompliancePriority.medium,
        createdAt: now,
        createdBy: 'system',
      ),
    ];
  }

  List<ComplianceRecommendation> _generatePrivacyActRecommendations(DateTime now) {
    return [
      ComplianceRecommendation(
        id: 'rec_privacy_act_001',
        title: 'Update Privacy Policy',
        description: 'Ensure privacy policy complies with Privacy Act',
        priority: CompliancePriority.medium,
        createdAt: now,
        createdBy: 'system',
      ),
    ];
  }

  Future<ComplianceReport?> getComplianceReport(String reportId) async {
    final db = await database;
    final result = await db.query(
      'compliance_reports',
      where: 'id = ?',
      whereArgs: [reportId],
    );
    
    if (result.isEmpty) return null;
    return ComplianceReport.fromJson(result.first);
  }

  Future<List<ComplianceReport>> getComplianceReports({
    ComplianceRegion? region,
    ComplianceType? type,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (region != null) {
      whereClause += ' AND region = ?';
      whereArgs.add(region.name);
    }
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.name);
    }
    
    final result = await db.query(
      'compliance_reports',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'generated_at DESC',
    );
    
    return result.map((json) => ComplianceReport.fromJson(json)).toList();
  }

  // Compliance Violation Management
  Future<String> createComplianceViolation({
    required String title,
    required String description,
    required ComplianceSeverity severity,
    required String detectedBy,
    Map<String, dynamic> details = const {},
  }) async {
    final db = await database;
    final violationId = 'violation_${DateTime.now().millisecondsSinceEpoch}';
    
    final violation = ComplianceViolation(
      id: violationId,
      title: title,
      description: description,
      severity: severity,
      detectedAt: DateTime.now(),
      detectedBy: detectedBy,
      details: details,
    );
    
    await db.insert('compliance_violations', {
      ...violation.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'compliance.violation_create',
      details: 'Compliance violation created: $violationId',
      userId: detectedBy,
      resourceId: violationId,
    );
    
    return violationId;
  }

  Future<bool> resolveComplianceViolation({
    required String violationId,
    required String resolution,
    required String resolvedBy,
  }) async {
    final db = await database;
    
    final result = await db.update(
      'compliance_violations',
      {
        'resolved_at': DateTime.now().toIso8601String(),
        'resolved_by': resolvedBy,
        'resolution': resolution,
      },
      where: 'id = ?',
      whereArgs: [violationId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'compliance.violation_resolve',
        details: 'Compliance violation resolved: $violationId',
        userId: resolvedBy,
        resourceId: violationId,
      );
    }
    
    return result > 0;
  }

  Future<List<ComplianceViolation>> getActiveComplianceViolations() async {
    final db = await database;
    final result = await db.query(
      'compliance_violations',
      where: 'resolved_at IS NULL',
      orderBy: 'detected_at DESC',
    );
    
    return result.map((json) => ComplianceViolation.fromJson(json)).toList();
  }

  // Compliance Recommendation Management
  Future<String> createComplianceRecommendation({
    required String title,
    required String description,
    required CompliancePriority priority,
    required String createdBy,
    Map<String, dynamic> details = const {},
  }) async {
    final db = await database;
    final recommendationId = 'rec_${DateTime.now().millisecondsSinceEpoch}';
    
    final recommendation = ComplianceRecommendation(
      id: recommendationId,
      title: title,
      description: description,
      priority: priority,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      details: details,
    );
    
    await db.insert('compliance_recommendations', {
      ...recommendation.toJson(),
    });
    
    await AuditLogService().insertLog(
      action: 'compliance.recommendation_create',
      details: 'Compliance recommendation created: $recommendationId',
      userId: createdBy,
      resourceId: recommendationId,
    );
    
    return recommendationId;
  }

  Future<bool> implementComplianceRecommendation({
    required String recommendationId,
    required String implementation,
    required String implementedBy,
  }) async {
    final db = await database;
    
    final result = await db.update(
      'compliance_recommendations',
      {
        'implemented_at': DateTime.now().toIso8601String(),
        'implemented_by': implementedBy,
        'implementation': implementation,
      },
      where: 'id = ?',
      whereArgs: [recommendationId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'compliance.recommendation_implement',
        details: 'Compliance recommendation implemented: $recommendationId',
        userId: implementedBy,
        resourceId: recommendationId,
      );
    }
    
    return result > 0;
  }

  Future<List<ComplianceRecommendation>> getPendingComplianceRecommendations() async {
    final db = await database;
    final result = await db.query(
      'compliance_recommendations',
      where: 'implemented_at IS NULL',
      orderBy: 'created_at DESC',
    );
    
    return result.map((json) => ComplianceRecommendation.fromJson(json)).toList();
  }

  // Compliance Dashboard
  Future<ComplianceDashboard> generateComplianceDashboard({
    required String userId,
  }) async {
    final dashboardId = 'dashboard_${DateTime.now().millisecondsSinceEpoch}';
    
    final reports = await getComplianceReports();
    final activeViolations = await getActiveComplianceViolations();
    final pendingRecommendations = await getPendingComplianceRecommendations();
    
    final regionalStatus = <ComplianceRegion, ComplianceStatus>{};
    for (final region in ComplianceRegion.values) {
      final regionReports = reports.where((r) => r.region == region).toList();
      if (regionReports.isEmpty) {
        regionalStatus[region] = ComplianceStatus.pending;
      } else {
        final latestReport = regionReports.first;
        regionalStatus[region] = latestReport.status;
      }
    }
    
    final summary = {
      'totalReports': reports.length,
      'activeViolations': activeViolations.length,
      'pendingRecommendations': pendingRecommendations.length,
      'compliantRegions': regionalStatus.values.where((s) => s == ComplianceStatus.compliant).length,
      'nonCompliantRegions': regionalStatus.values.where((s) => s == ComplianceStatus.nonCompliant).length,
    };
    
    final dashboard = ComplianceDashboard(
      id: dashboardId,
      userId: userId,
      reports: reports,
      activeViolations: activeViolations,
      pendingRecommendations: pendingRecommendations,
      regionalStatus: regionalStatus,
      generatedAt: DateTime.now(),
      summary: summary,
    );
    
    await AuditLogService().insertLog(
      action: 'compliance.dashboard_generate',
      details: 'Compliance dashboard generated: $dashboardId',
      userId: userId,
      resourceId: dashboardId,
    );
    
    return dashboard;
  }

  // Data Processing Record Management
  Future<String> createDataProcessingRecord({
    required String purpose,
    required String legalBasis,
    required List<String> dataCategories,
    required List<String> recipients,
    String? thirdCountryTransfer,
    required DateTime retentionPeriod,
    required String dataController,
  }) async {
    final db = await database;
    final recordId = 'dpr_${DateTime.now().millisecondsSinceEpoch}';
    
    final record = DataProcessingRecord(
      id: recordId,
      purpose: purpose,
      legalBasis: legalBasis,
      dataCategories: dataCategories,
      recipients: recipients,
      thirdCountryTransfer: thirdCountryTransfer,
      retentionPeriod: retentionPeriod,
      dataController: dataController,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await db.insert('data_processing_records', {
      ...record.toJson(),
    });
    
    await AuditLogService().insertLog(
      action: 'compliance.dpr_create',
      details: 'Data processing record created: $recordId',
      userId: 'system',
      resourceId: recordId,
    );
    
    return recordId;
  }

  Future<List<DataProcessingRecord>> getDataProcessingRecords() async {
    final db = await database;
    final result = await db.query(
      'data_processing_records',
      orderBy: 'created_at DESC',
    );
    
    return result.map((json) => DataProcessingRecord.fromJson(json)).toList();
  }

  // Privacy Impact Assessment Management
  Future<String> createPrivacyImpactAssessment({
    required String title,
    required String description,
    required ComplianceRegion region,
    required ComplianceType type,
    required List<String> dataSubjects,
    required List<String> dataCategories,
    required String processingPurpose,
    required String legalBasis,
    required List<String> risks,
    required List<String> mitigations,
    required String assessedBy,
  }) async {
    final db = await database;
    final assessmentId = 'pia_${DateTime.now().millisecondsSinceEpoch}';
    
    final assessment = PrivacyImpactAssessment(
      id: assessmentId,
      title: title,
      description: description,
      region: region,
      type: type,
      dataSubjects: dataSubjects,
      dataCategories: dataCategories,
      processingPurpose: processingPurpose,
      legalBasis: legalBasis,
      risks: risks,
      mitigations: mitigations,
      status: ComplianceStatus.pending,
      assessedAt: DateTime.now(),
      assessedBy: assessedBy,
    );
    
    await db.insert('privacy_impact_assessments', {
      ...assessment.toJson(),
    });
    
    await AuditLogService().insertLog(
      action: 'compliance.pia_create',
      details: 'Privacy impact assessment created: $assessmentId',
      userId: assessedBy,
      resourceId: assessmentId,
    );
    
    return assessmentId;
  }

  Future<bool> approvePrivacyImpactAssessment({
    required String assessmentId,
    required String approvedBy,
  }) async {
    final db = await database;
    
    final result = await db.update(
      'privacy_impact_assessments',
      {
        'status': ComplianceStatus.compliant.name,
        'approved_at': DateTime.now().toIso8601String(),
        'approved_by': approvedBy,
      },
      where: 'id = ?',
      whereArgs: [assessmentId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'compliance.pia_approve',
        details: 'Privacy impact assessment approved: $assessmentId',
        userId: approvedBy,
        resourceId: assessmentId,
      );
    }
    
    return result > 0;
  }

  Future<List<PrivacyImpactAssessment>> getPrivacyImpactAssessments({
    ComplianceRegion? region,
    ComplianceStatus? status,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (region != null) {
      whereClause += ' AND region = ?';
      whereArgs.add(region.name);
    }
    
    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status.name);
    }
    
    final result = await db.query(
      'privacy_impact_assessments',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'assessed_at DESC',
    );
    
    return result.map((json) => PrivacyImpactAssessment.fromJson(json)).toList();
  }
}
