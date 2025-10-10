import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/clinical_manager_models.dart';
import 'audit_log_service.dart';

class ClinicalManagerService {
  static final ClinicalManagerService _instance = ClinicalManagerService._internal();
  factory ClinicalManagerService() => _instance;
  ClinicalManagerService._internal();

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
    return 'clinical-manager-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clinical_departments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        manager_id TEXT NOT NULL,
        staff_ids TEXT NOT NULL,
        budget INTEGER NOT NULL,
        target_patient_capacity INTEGER NOT NULL,
        current_patient_count INTEGER NOT NULL,
        performance_metrics TEXT NOT NULL,
        compliance_requirements TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE staff_performance (
        id TEXT PRIMARY KEY,
        staff_id TEXT NOT NULL,
        department_id TEXT NOT NULL,
        evaluation_date TEXT NOT NULL,
        metrics TEXT NOT NULL,
        overall_score REAL NOT NULL,
        strengths TEXT NOT NULL,
        areas_for_improvement TEXT NOT NULL,
        development_goals TEXT NOT NULL,
        evaluator_id TEXT NOT NULL,
        evaluation_notes TEXT NOT NULL,
        next_evaluation_date TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE compliance_audits (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        compliance_type TEXT NOT NULL,
        audit_date TEXT NOT NULL,
        auditor_id TEXT NOT NULL,
        checks TEXT NOT NULL,
        compliance_score REAL NOT NULL,
        violations TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        next_audit_date TEXT NOT NULL,
        audit_report TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE financial_reports (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        total_revenue REAL NOT NULL,
        total_expenses REAL NOT NULL,
        net_income REAL NOT NULL,
        revenue_by_department TEXT NOT NULL,
        expenses_by_category TEXT NOT NULL,
        alerts TEXT NOT NULL,
        report_summary TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE quality_metrics (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        patient_satisfaction TEXT NOT NULL,
        treatment_outcomes TEXT NOT NULL,
        staff_performance TEXT NOT NULL,
        compliance_scores TEXT NOT NULL,
        improvement_areas TEXT NOT NULL,
        best_practices TEXT NOT NULL,
        overall_assessment TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE resource_allocations (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        allocation_date TEXT NOT NULL,
        staff_allocation TEXT NOT NULL,
        budget_allocation TEXT NOT NULL,
        room_allocation TEXT NOT NULL,
        equipment_allocation TEXT NOT NULL,
        allocation_rationale TEXT NOT NULL,
        review_date TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultDepartments(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultDepartments(Database db) async {
    final departments = [
      ClinicalDepartment(
        id: 'dept_001',
        name: 'Psikiyatri Bölümü',
        type: DepartmentType.psychiatry,
        managerId: 'manager_001',
        staffIds: ['psychiatrist_001', 'psychiatrist_002', 'nurse_001'],
        budget: 500000,
        targetPatientCapacity: 200,
        currentPatientCount: 150,
        performanceMetrics: {
          'patientSatisfaction': 4.2,
          'treatmentOutcomes': 3.8,
          'sessionAttendance': 0.85,
          'documentationQuality': 4.0,
          'compliance': 4.5,
        },
        complianceRequirements: ['HIPAA', 'KVKK', 'Medical Board'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ClinicalDepartment(
        id: 'dept_002',
        name: 'Klinik Psikoloji Bölümü',
        type: DepartmentType.psychology,
        managerId: 'manager_002',
        staffIds: ['psychologist_001', 'psychologist_002', 'psychologist_003'],
        budget: 300000,
        targetPatientCapacity: 150,
        currentPatientCount: 120,
        performanceMetrics: {
          'patientSatisfaction': 4.5,
          'treatmentOutcomes': 4.1,
          'sessionAttendance': 0.90,
          'documentationQuality': 4.3,
          'compliance': 4.7,
        },
        complianceRequirements: ['APA Ethics', 'KVKK', 'Psychology Board'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ClinicalDepartment(
        id: 'dept_003',
        name: 'Terapi Bölümü',
        type: DepartmentType.therapy,
        managerId: 'manager_003',
        staffIds: ['therapist_001', 'therapist_002', 'counselor_001'],
        budget: 200000,
        targetPatientCapacity: 100,
        currentPatientCount: 80,
        performanceMetrics: {
          'patientSatisfaction': 4.3,
          'treatmentOutcomes': 3.9,
          'sessionAttendance': 0.88,
          'documentationQuality': 4.1,
          'compliance': 4.4,
        },
        complianceRequirements: ['HIPAA', 'KVKK', 'Therapy Board'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final department in departments) {
      await db.insert('clinical_departments', {
        ...department.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Department Management
  Future<List<ClinicalDepartment>> getDepartments() async {
    final db = await database;
    final result = await db.query(
      'clinical_departments',
      orderBy: 'name ASC',
    );
    
    return result.map((json) => ClinicalDepartment.fromJson(json)).toList();
  }

  Future<ClinicalDepartment?> getDepartment(String departmentId) async {
    final db = await database;
    final result = await db.query(
      'clinical_departments',
      where: 'id = ?',
      whereArgs: [departmentId],
    );
    
    if (result.isEmpty) return null;
    return ClinicalDepartment.fromJson(result.first);
  }

  Future<String> createDepartment({
    required String name,
    required DepartmentType type,
    required String managerId,
    required List<String> staffIds,
    required int budget,
    required int targetPatientCapacity,
    required List<String> complianceRequirements,
  }) async {
    final db = await database;
    final departmentId = 'dept_${DateTime.now().millisecondsSinceEpoch}';
    
    final department = ClinicalDepartment(
      id: departmentId,
      name: name,
      type: type,
      managerId: managerId,
      staffIds: staffIds,
      budget: budget,
      targetPatientCapacity: targetPatientCapacity,
      currentPatientCount: 0,
      performanceMetrics: {},
      complianceRequirements: complianceRequirements,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await db.insert('clinical_departments', {
      ...department.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'department.create',
      details: 'Department created: $departmentId',
      userId: managerId,
      resourceId: departmentId,
    );
    
    return departmentId;
  }

  Future<bool> updateDepartment(ClinicalDepartment department) async {
    final db = await database;
    
    final result = await db.update(
      'clinical_departments',
      {
        ...department.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [department.id],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'department.update',
        details: 'Department updated: ${department.id}',
        userId: department.managerId,
        resourceId: department.id,
      );
    }
    
    return result > 0;
  }

  // Staff Performance Management
  Future<String> createStaffPerformanceEvaluation({
    required String staffId,
    required String departmentId,
    required Map<PerformanceMetric, double> metrics,
    required List<String> strengths,
    required List<String> areasForImprovement,
    required List<String> developmentGoals,
    required String evaluatorId,
    required String evaluationNotes,
    required DateTime nextEvaluationDate,
  }) async {
    final db = await database;
    final evaluationId = 'sp_${DateTime.now().millisecondsSinceEpoch}';
    
    final overallScore = metrics.values.reduce((a, b) => a + b) / metrics.length;
    
    final performance = StaffPerformance(
      id: evaluationId,
      staffId: staffId,
      departmentId: departmentId,
      evaluationDate: DateTime.now(),
      metrics: metrics,
      overallScore: overallScore,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      developmentGoals: developmentGoals,
      evaluatorId: evaluatorId,
      evaluationNotes: evaluationNotes,
      nextEvaluationDate: nextEvaluationDate,
    );
    
    await db.insert('staff_performance', {
      ...performance.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'staff_performance.create',
      details: 'Staff performance evaluation created: $evaluationId',
      userId: evaluatorId,
      resourceId: evaluationId,
    );
    
    return evaluationId;
  }

  Future<List<StaffPerformance>> getStaffPerformanceHistory(String staffId) async {
    final db = await database;
    final result = await db.query(
      'staff_performance',
      where: 'staff_id = ?',
      whereArgs: [staffId],
      orderBy: 'evaluation_date DESC',
    );
    
    return result.map((json) => StaffPerformance.fromJson(json)).toList();
  }

  Future<List<StaffPerformance>> getDepartmentPerformanceHistory(String departmentId) async {
    final db = await database;
    final result = await db.query(
      'staff_performance',
      where: 'department_id = ?',
      whereArgs: [departmentId],
      orderBy: 'evaluation_date DESC',
    );
    
    return result.map((json) => StaffPerformance.fromJson(json)).toList();
  }

  // Compliance Management
  Future<String> createComplianceAudit({
    required String organizationId,
    required ComplianceType complianceType,
    required String auditorId,
    required List<ComplianceCheck> checks,
    required List<String> violations,
    required List<String> recommendations,
    required DateTime nextAuditDate,
    required String auditReport,
  }) async {
    final db = await database;
    final auditId = 'ca_${DateTime.now().millisecondsSinceEpoch}';
    
    final compliantChecks = checks.where((c) => c.isCompliant).length;
    final complianceScore = compliantChecks / checks.length * 100;
    
    final audit = ComplianceAudit(
      id: auditId,
      organizationId: organizationId,
      complianceType: complianceType,
      auditDate: DateTime.now(),
      auditorId: auditorId,
      checks: checks,
      complianceScore: complianceScore,
      violations: violations,
      recommendations: recommendations,
      nextAuditDate: nextAuditDate,
      auditReport: auditReport,
    );
    
    await db.insert('compliance_audits', {
      ...audit.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'compliance_audit.create',
      details: 'Compliance audit created: $auditId',
      userId: auditorId,
      resourceId: auditId,
    );
    
    return auditId;
  }

  Future<List<ComplianceAudit>> getComplianceAudits(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'compliance_audits',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'audit_date DESC',
    );
    
    return result.map((json) => ComplianceAudit.fromJson(json)).toList();
  }

  Future<List<ComplianceAudit>> getUpcomingAudits(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'compliance_audits',
      where: 'organization_id = ? AND next_audit_date > ?',
      whereArgs: [organizationId, DateTime.now().toIso8601String()],
      orderBy: 'next_audit_date ASC',
    );
    
    return result.map((json) => ComplianceAudit.fromJson(json)).toList();
  }

  // Financial Management
  Future<String> createFinancialReport({
    required String organizationId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalRevenue,
    required double totalExpenses,
    required Map<String, double> revenueByDepartment,
    required Map<String, double> expensesByCategory,
    required List<FinancialAlert> alerts,
    required String reportSummary,
  }) async {
    final db = await database;
    final reportId = 'fr_${DateTime.now().millisecondsSinceEpoch}';
    
    final netIncome = totalRevenue - totalExpenses;
    
    final report = FinancialReport(
      id: reportId,
      organizationId: organizationId,
      reportDate: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netIncome: netIncome,
      revenueByDepartment: revenueByDepartment,
      expensesByCategory: expensesByCategory,
      alerts: alerts,
      reportSummary: reportSummary,
    );
    
    await db.insert('financial_reports', {
      ...report.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'financial_report.create',
      details: 'Financial report created: $reportId',
      userId: 'system',
      resourceId: reportId,
    );
    
    return reportId;
  }

  Future<List<FinancialReport>> getFinancialReports(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'financial_reports',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'report_date DESC',
    );
    
    return result.map((json) => FinancialReport.fromJson(json)).toList();
  }

  Future<List<FinancialAlert>> getActiveFinancialAlerts(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'financial_reports',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'report_date DESC',
      limit: 1,
    );
    
    if (result.isEmpty) return [];
    
    final report = FinancialReport.fromJson(result.first);
    return report.alerts.where((alert) => !alert.isResolved).toList();
  }

  // Quality Metrics Management
  Future<String> createQualityMetricsReport({
    required String organizationId,
    required Map<String, double> patientSatisfaction,
    required Map<String, double> treatmentOutcomes,
    required Map<String, double> staffPerformance,
    required Map<String, double> complianceScores,
    required List<String> improvementAreas,
    required List<String> bestPractices,
    required String overallAssessment,
  }) async {
    final db = await database;
    final reportId = 'qm_${DateTime.now().millisecondsSinceEpoch}';
    
    final metrics = QualityMetrics(
      id: reportId,
      organizationId: organizationId,
      reportDate: DateTime.now(),
      patientSatisfaction: patientSatisfaction,
      treatmentOutcomes: treatmentOutcomes,
      staffPerformance: staffPerformance,
      complianceScores: complianceScores,
      improvementAreas: improvementAreas,
      bestPractices: bestPractices,
      overallAssessment: overallAssessment,
    );
    
    await db.insert('quality_metrics', {
      ...metrics.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'quality_metrics.create',
      details: 'Quality metrics report created: $reportId',
      userId: 'system',
      resourceId: reportId,
    );
    
    return reportId;
  }

  Future<List<QualityMetrics>> getQualityMetricsHistory(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'quality_metrics',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'report_date DESC',
    );
    
    return result.map((json) => QualityMetrics.fromJson(json)).toList();
  }

  // Resource Allocation Management
  Future<String> createResourceAllocation({
    required String organizationId,
    required Map<String, int> staffAllocation,
    required Map<String, double> budgetAllocation,
    required Map<String, int> roomAllocation,
    required Map<String, int> equipmentAllocation,
    required String allocationRationale,
    required DateTime reviewDate,
  }) async {
    final db = await database;
    final allocationId = 'ra_${DateTime.now().millisecondsSinceEpoch}';
    
    final allocation = ResourceAllocation(
      id: allocationId,
      organizationId: organizationId,
      allocationDate: DateTime.now(),
      staffAllocation: staffAllocation,
      budgetAllocation: budgetAllocation,
      roomAllocation: roomAllocation,
      equipmentAllocation: equipmentAllocation,
      allocationRationale: allocationRationale,
      reviewDate: reviewDate,
    );
    
    await db.insert('resource_allocations', {
      ...allocation.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'resource_allocation.create',
      details: 'Resource allocation created: $allocationId',
      userId: 'system',
      resourceId: allocationId,
    );
    
    return allocationId;
  }

  Future<List<ResourceAllocation>> getResourceAllocations(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'resource_allocations',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'allocation_date DESC',
    );
    
    return result.map((json) => ResourceAllocation.fromJson(json)).toList();
  }

  // AI-Powered Features for Clinical Managers
  Future<Map<String, dynamic>> generatePerformanceInsights({
    required String departmentId,
    required Map<String, dynamic> performanceData,
  }) async {
    // Mock AI performance insights - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final insights = <String>[];
    final recommendations = <String>[];
    final alerts = <String>[];
    
    final patientSatisfaction = performanceData['patientSatisfaction'] as double? ?? 0.0;
    final treatmentOutcomes = performanceData['treatmentOutcomes'] as double? ?? 0.0;
    final sessionAttendance = performanceData['sessionAttendance'] as double? ?? 0.0;
    
    if (patientSatisfaction < 3.5) {
      insights.add('Hasta memnuniyeti düşük - acil müdahale gerekli');
      recommendations.add('Hasta geri bildirim anketleri düzenle');
      recommendations.add('Personel eğitimi planla');
      alerts.add('Hasta memnuniyeti kritik seviyede');
    } else if (patientSatisfaction > 4.5) {
      insights.add('Hasta memnuniyeti mükemmel - örnek alınacak uygulamalar');
      recommendations.add('Başarılı uygulamaları diğer bölümlere yay');
    }
    
    if (sessionAttendance < 0.8) {
      insights.add('Seans katılım oranı düşük');
      recommendations.add('Randevu hatırlatma sistemi güçlendir');
      recommendations.add('No-show nedenlerini araştır');
    }
    
    if (treatmentOutcomes < 3.0) {
      alerts.add('Tedavi sonuçları yetersiz - klinik müdahale gerekli');
      recommendations.add('Tedavi protokollerini gözden geçir');
      recommendations.add('Süpervizyon sıklığını artır');
    }
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'alerts': alerts,
      'confidence': 0.88 + (Random().nextDouble() * 0.07),
      'evidence': 'Performance analytics and benchmarking',
    };
  }

  Future<Map<String, dynamic>> generateBudgetOptimization({
    required String organizationId,
    required Map<String, double> currentBudget,
    required Map<String, double> performanceMetrics,
  }) async {
    // Mock AI budget optimization - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final optimizations = <String>[];
    final reallocations = <Map<String, dynamic>>[];
    final savings = <String>[];
    
    // Performans metriklerine göre bütçe optimizasyonu
    for (final entry in performanceMetrics.entries) {
      final department = entry.key;
      final performance = entry.value;
      final currentBudget = currentBudget[department] ?? 0.0;
      
      if (performance > 4.5) {
        // Yüksek performans - bütçe artırımı öner
        reallocations.add({
          'department': department,
          'currentBudget': currentBudget,
          'recommendedBudget': currentBudget * 1.1,
          'reason': 'Yüksek performans - kaynak artırımı',
        });
      } else if (performance < 3.0) {
        // Düşük performans - bütçe optimizasyonu öner
        reallocations.add({
          'department': department,
          'currentBudget': currentBudget,
          'recommendedBudget': currentBudget * 0.9,
          'reason': 'Düşük performans - kaynak optimizasyonu',
        });
      }
    }
    
    optimizations.add('Performans bazlı bütçe dağılımı önerildi');
    optimizations.add('ROI analizi tamamlandı');
    
    savings.add('Toplam %5-10 tasarruf potansiyeli');
    savings.add('Verimlilik artışı bekleniyor');
    
    return {
      'optimizations': optimizations,
      'reallocations': reallocations,
      'savings': savings,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Financial performance analysis',
    };
  }

  Future<Map<String, dynamic>> generateComplianceRiskAssessment({
    required String organizationId,
    required List<ComplianceType> complianceTypes,
  }) async {
    // Mock AI compliance risk assessment - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final risks = <String>[];
    final recommendations = <String>[];
    final priorities = <String>[];
    
    for (final complianceType in complianceTypes) {
      switch (complianceType) {
        case ComplianceType.hipaa:
          risks.add('HIPAA: Hasta veri güvenliği riski');
          recommendations.add('Veri şifreleme protokollerini güçlendir');
          recommendations.add('Personel eğitimi düzenle');
          priorities.add('Yüksek öncelik - yasal yükümlülük');
          break;
        case ComplianceType.gdpr:
          risks.add('GDPR: Veri işleme onayları eksik');
          recommendations.add('Açık rıza formları güncelle');
          recommendations.add('Veri işleme kayıtları tut');
          priorities.add('Orta öncelik - AB müşterileri için');
          break;
        case ComplianceType.kvkk:
          risks.add('KVKK: Veri saklama süreleri aşılıyor');
          recommendations.add('Veri saklama politikalarını gözden geçir');
          recommendations.add('Otomatik silme sistemi kur');
          priorities.add('Yüksek öncelik - Türk yasal gereklilik');
          break;
      }
    }
    
    return {
      'risks': risks,
      'recommendations': recommendations,
      'priorities': priorities,
      'confidence': 0.92 + (Random().nextDouble() * 0.05),
      'evidence': 'Compliance framework analysis',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getClinicalManagerStatistics(String managerId) async {
    final db = await database;
    
    final departmentsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM clinical_departments 
      WHERE manager_id = ?
    ''', [managerId]);
    
    final staffPerformanceResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM staff_performance 
      WHERE evaluator_id = ?
    ''', [managerId]);
    
    final complianceAuditsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM compliance_audits 
      WHERE auditor_id = ?
    ''', [managerId]);
    
    final financialReportsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM financial_reports
    ''');
    
    return {
      'managedDepartments': departmentsResult.first['count'] as int,
      'staffEvaluations': staffPerformanceResult.first['count'] as int,
      'complianceAudits': complianceAuditsResult.first['count'] as int,
      'financialReports': financialReportsResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getDepartmentPerformanceComparison() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        name,
        type,
        current_patient_count,
        target_patient_capacity,
        (current_patient_count * 100.0 / target_patient_capacity) as capacity_utilization,
        performance_metrics
      FROM clinical_departments
      ORDER BY capacity_utilization DESC
    ''');
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getComplianceTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        compliance_type,
        compliance_score,
        audit_date,
        violations
      FROM compliance_audits
      WHERE organization_id = ?
      ORDER BY audit_date DESC
      LIMIT 10
    ''', [organizationId]);
    
    return result;
  }
}
