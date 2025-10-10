import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/operational_efficiency_models.dart';
import 'audit_log_service.dart';

class OperationalEfficiencyService {
  static final OperationalEfficiencyService _instance = OperationalEfficiencyService._internal();
  factory OperationalEfficiencyService() => _instance;
  OperationalEfficiencyService._internal();

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
    return 'operational-efficiency-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE appointment_optimizations (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        optimization_date TEXT NOT NULL,
        current_metrics TEXT NOT NULL,
        optimized_metrics TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        improvement_percentage REAL NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE resource_plannings (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        planning_date TEXT NOT NULL,
        resource_allocations TEXT NOT NULL,
        utilization_targets TEXT NOT NULL,
        constraints TEXT NOT NULL,
        optimizations TEXT NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE quality_controls (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        control_date TEXT NOT NULL,
        control_type TEXT NOT NULL,
        quality_metrics TEXT NOT NULL,
        issues TEXT NOT NULL,
        improvements TEXT NOT NULL,
        overall_score REAL NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE efficiency_metrics (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        utilization_rates TEXT NOT NULL,
        throughput_metrics TEXT NOT NULL,
        quality_scores TEXT NOT NULL,
        cost_metrics TEXT NOT NULL,
        satisfaction_scores TEXT NOT NULL,
        trends TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultOptimizations(db);
    await _createDefaultQualityControls(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultOptimizations(Database db) async {
    final recommendations = [
      OptimizationRecommendation(
        id: 'opt_rec_001',
        title: 'Randevu Zamanlama Optimizasyonu',
        description: 'AI destekli randevu zamanlama sistemi ile %25 verimlilik artışı',
        type: OptimizationType.appointment,
        impact: 0.8,
        effort: 0.6,
        priority: 0.9,
        requiredResources: ['AI Developer', 'Clinical Team', 'Testing'],
        targetDate: DateTime.now().add(const Duration(days: 90)),
        status: 'planned',
      ),
      OptimizationRecommendation(
        id: 'opt_rec_002',
        title: 'Kaynak Planlama İyileştirmesi',
        description: 'Dinamik kaynak tahsisi ile %20 maliyet tasarrufu',
        type: OptimizationType.resource,
        impact: 0.7,
        effort: 0.8,
        priority: 0.8,
        requiredResources: ['Operations Manager', 'Finance Team'],
        targetDate: DateTime.now().add(const Duration(days: 120)),
        status: 'planned',
      ),
    ];

    final optimization = AppointmentOptimization(
      id: 'opt_001',
      organizationId: 'org_001',
      optimizationDate: DateTime.now(),
      currentMetrics: {
        'utilization_rate': 0.75,
        'wait_time': 15.0,
        'no_show_rate': 0.12,
        'patient_satisfaction': 4.2,
      },
      optimizedMetrics: {
        'utilization_rate': 0.85,
        'wait_time': 8.0,
        'no_show_rate': 0.08,
        'patient_satisfaction': 4.6,
      },
      recommendations: recommendations,
      improvementPercentage: 15.5,
      status: 'active',
    );

    await db.insert('appointment_optimizations', {
      ...optimization.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createDefaultQualityControls(Database db) async {
    final issues = [
      QualityIssue(
        id: 'qi_001',
        title: 'Dokümantasyon Eksikliği',
        description: 'Bazı seans notlarında eksik bilgiler bulunuyor',
        category: 'Documentation',
        severity: 0.6,
        department: 'Clinical',
        responsiblePerson: 'Dr. Ayşe Yılmaz',
        identifiedDate: DateTime.now().subtract(const Duration(days: 7)),
        status: 'open',
        correctiveActions: [
          'Dokümantasyon eğitimi düzenle',
          'Kalite kontrol süreci güçlendir',
          'Otomatik kontrol sistemi kur',
        ],
      ),
    ];

    final improvements = [
      QualityImprovement(
        id: 'qim_001',
        title: 'AI Destekli Kalite Kontrol',
        description: 'AI ile otomatik kalite kontrol sistemi',
        category: 'Technology',
        expectedImpact: 0.8,
        department: 'Clinical',
        responsiblePerson: 'Dr. Mehmet Kaya',
        startDate: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 60)),
        status: 'in_progress',
        implementationSteps: [
          'AI model geliştirme',
          'Test verileri hazırlama',
          'Pilot uygulama',
          'Tam entegrasyon',
        ],
      ),
    ];

    final qualityControl = QualityControl(
      id: 'qc_001',
      organizationId: 'org_001',
      controlDate: DateTime.now(),
      controlType: 'Monthly Review',
      qualityMetrics: {
        'documentation_completeness': 0.85,
        'patient_satisfaction': 4.3,
        'clinical_outcomes': 0.78,
        'compliance_rate': 0.92,
      },
      issues: issues,
      improvements: improvements,
      overallScore: 4.1,
      status: 'completed',
    );

    await db.insert('quality_controls', {
      ...qualityControl.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Appointment Optimization Management
  Future<String> createAppointmentOptimization({
    required String organizationId,
    required Map<String, double> currentMetrics,
    required Map<String, double> optimizedMetrics,
    required List<OptimizationRecommendation> recommendations,
    required double improvementPercentage,
  }) async {
    final db = await database;
    final optimizationId = 'opt_${DateTime.now().millisecondsSinceEpoch}';
    
    final optimization = AppointmentOptimization(
      id: optimizationId,
      organizationId: organizationId,
      optimizationDate: DateTime.now(),
      currentMetrics: currentMetrics,
      optimizedMetrics: optimizedMetrics,
      recommendations: recommendations,
      improvementPercentage: improvementPercentage,
      status: 'active',
    );
    
    await db.insert('appointment_optimizations', {
      ...optimization.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'appointment_optimization.create',
      details: 'Appointment optimization created: $optimizationId',
      userId: 'system',
      resourceId: optimizationId,
    );
    
    return optimizationId;
  }

  Future<List<AppointmentOptimization>> getAppointmentOptimizations(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'appointment_optimizations',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'optimization_date DESC',
    );
    
    return result.map((json) => AppointmentOptimization.fromJson(json)).toList();
  }

  // Resource Planning Management
  Future<String> createResourcePlanning({
    required String organizationId,
    required Map<String, ResourceAllocation> resourceAllocations,
    required Map<String, double> utilizationTargets,
    required List<ResourceConstraint> constraints,
    required List<ResourceOptimization> optimizations,
  }) async {
    final db = await database;
    final planningId = 'rp_${DateTime.now().millisecondsSinceEpoch}';
    
    final planning = ResourcePlanning(
      id: planningId,
      organizationId: organizationId,
      planningDate: DateTime.now(),
      resourceAllocations: resourceAllocations,
      utilizationTargets: utilizationTargets,
      constraints: constraints,
      optimizations: optimizations,
      status: 'active',
    );
    
    await db.insert('resource_plannings', {
      ...planning.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'resource_planning.create',
      details: 'Resource planning created: $planningId',
      userId: 'system',
      resourceId: planningId,
    );
    
    return planningId;
  }

  Future<List<ResourcePlanning>> getResourcePlannings(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'resource_plannings',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'planning_date DESC',
    );
    
    return result.map((json) => ResourcePlanning.fromJson(json)).toList();
  }

  // Quality Control Management
  Future<String> createQualityControl({
    required String organizationId,
    required String controlType,
    required Map<String, double> qualityMetrics,
    required List<QualityIssue> issues,
    required List<QualityImprovement> improvements,
    required double overallScore,
  }) async {
    final db = await database;
    final controlId = 'qc_${DateTime.now().millisecondsSinceEpoch}';
    
    final control = QualityControl(
      id: controlId,
      organizationId: organizationId,
      controlDate: DateTime.now(),
      controlType: controlType,
      qualityMetrics: qualityMetrics,
      issues: issues,
      improvements: improvements,
      overallScore: overallScore,
      status: 'completed',
    );
    
    await db.insert('quality_controls', {
      ...control.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'quality_control.create',
      details: 'Quality control created: $controlId',
      userId: 'system',
      resourceId: controlId,
    );
    
    return controlId;
  }

  Future<List<QualityControl>> getQualityControls(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'quality_controls',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'control_date DESC',
    );
    
    return result.map((json) => QualityControl.fromJson(json)).toList();
  }

  // Efficiency Metrics Management
  Future<String> createEfficiencyMetrics({
    required String organizationId,
    required Map<String, double> utilizationRates,
    required Map<String, double> throughputMetrics,
    required Map<String, double> qualityScores,
    required Map<String, double> costMetrics,
    required Map<String, double> satisfactionScores,
    required List<EfficiencyTrend> trends,
  }) async {
    final db = await database;
    final metricsId = 'em_${DateTime.now().millisecondsSinceEpoch}';
    
    final metrics = EfficiencyMetrics(
      id: metricsId,
      organizationId: organizationId,
      reportDate: DateTime.now(),
      utilizationRates: utilizationRates,
      throughputMetrics: throughputMetrics,
      qualityScores: qualityScores,
      costMetrics: costMetrics,
      satisfactionScores: satisfactionScores,
      trends: trends,
    );
    
    await db.insert('efficiency_metrics', {
      ...metrics.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'efficiency_metrics.create',
      details: 'Efficiency metrics created: $metricsId',
      userId: 'system',
      resourceId: metricsId,
    );
    
    return metricsId;
  }

  Future<List<EfficiencyMetrics>> getEfficiencyMetrics(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'efficiency_metrics',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'report_date DESC',
    );
    
    return result.map((json) => EfficiencyMetrics.fromJson(json)).toList();
  }

  // AI-Powered Features for Operational Efficiency
  Future<Map<String, dynamic>> generateOptimizationRecommendations({
    required String organizationId,
    required Map<String, dynamic> currentMetrics,
    required OptimizationType optimizationType,
  }) async {
    // Mock AI optimization recommendations - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final recommendations = <String>[];
    final actionItems = <String>[];
    final expectedImprovements = <String>[];
    final implementationSteps = <String>[];
    
    switch (optimizationType) {
      case OptimizationType.appointment:
        final utilizationRate = currentMetrics['utilization_rate'] as double? ?? 0.0;
        final waitTime = currentMetrics['wait_time'] as double? ?? 0.0;
        final noShowRate = currentMetrics['no_show_rate'] as double? ?? 0.0;
        
        if (utilizationRate < 0.8) {
          recommendations.add('Randevu zamanlama algoritması optimize edilmeli');
          actionItems.add('AI destekli zamanlama sistemi kur');
          expectedImprovements.add('%15-20 kullanım oranı artışı');
          implementationSteps.add('Algoritma geliştirme → Test → Pilot → Tam entegrasyon');
        }
        
        if (waitTime > 10) {
          recommendations.add('Bekleme sürelerini azaltmak için kaynak planlaması');
          actionItems.add('Dinamik kaynak tahsisi sistemi');
          expectedImprovements.add('%30-40 bekleme süresi azalması');
          implementationSteps.add('Analiz → Planlama → Uygulama → İzleme');
        }
        
        if (noShowRate > 0.1) {
          recommendations.add('Randevu hatırlatma sistemi güçlendirilmeli');
          actionItems.add('Çok kanallı hatırlatma sistemi');
          expectedImprovements.add('%25-35 no-show oranı azalması');
          implementationSteps.add('SMS/Email → Push notification → AI tahminleme');
        }
        break;
        
      case OptimizationType.resource:
        recommendations.add('Kaynak kullanım verimliliği artırılmalı');
        actionItems.add('Gerçek zamanlı kaynak izleme');
        expectedImprovements.add('%20-25 maliyet tasarrufu');
        implementationSteps.add('Sensörler → Veri toplama → Analiz → Optimizasyon');
        break;
        
      case OptimizationType.workflow:
        recommendations.add('İş akışı süreçleri optimize edilmeli');
        actionItems.add('Otomatik iş akışı sistemi');
        expectedImprovements.add('%30-40 süreç hızlanması');
        implementationSteps.add('Süreç haritalama → Otomasyon → Test → Uygulama');
        break;
        
      case OptimizationType.quality:
        recommendations.add('Kalite kontrol süreçleri güçlendirilmeli');
        actionItems.add('AI destekli kalite kontrol');
        expectedImprovements.add('%15-25 kalite skoru artışı');
        implementationSteps.add('AI model → Eğitim → Test → Entegrasyon');
        break;
        
      case OptimizationType.cost:
        recommendations.add('Maliyet optimizasyonu stratejileri uygulanmalı');
        actionItems.add('Maliyet analiz ve optimizasyon sistemi');
        expectedImprovements.add('%10-15 maliyet azalması');
        implementationSteps.add('Analiz → Strateji → Uygulama → İzleme');
        break;
    }
    
    return {
      'recommendations': recommendations,
      'actionItems': actionItems,
      'expectedImprovements': expectedImprovements,
      'implementationSteps': implementationSteps,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Operational efficiency frameworks and industry benchmarks',
    };
  }

  Future<Map<String, dynamic>> generateResourceOptimization({
    required String organizationId,
    required Map<String, dynamic> resourceData,
    required ResourceType resourceType,
  }) async {
    // Mock AI resource optimization - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final optimizations = <String>[];
    final allocationStrategies = <String>[];
    final efficiencyGains = <String>[];
    final riskMitigations = <String>[];
    
    switch (resourceType) {
      case ResourceType.staff:
        final currentUtilization = resourceData['utilization'] as double? ?? 0.0;
        final workload = resourceData['workload'] as double? ?? 0.0;
        
        if (currentUtilization < 0.7) {
          optimizations.add('Personel kullanım oranı artırılmalı');
          allocationStrategies.add('Dinamik vardiya planlaması');
          efficiencyGains.add('%20-25 verimlilik artışı');
          riskMitigations.add('Yorgunluk izleme sistemi');
        }
        
        if (workload > 0.8) {
          optimizations.add('İş yükü dağılımı optimize edilmeli');
          allocationStrategies.add('AI destekli iş yükü dağılımı');
          efficiencyGains.add('%15-20 stres azalması');
          riskMitigations.add('Erken uyarı sistemi');
        }
        break;
        
      case ResourceType.room:
        final roomUtilization = resourceData['room_utilization'] as double? ?? 0.0;
        final maintenanceCost = resourceData['maintenance_cost'] as double? ?? 0.0;
        
        if (roomUtilization < 0.8) {
          optimizations.add('Oda kullanım verimliliği artırılmalı');
          allocationStrategies.add('Akıllı rezervasyon sistemi');
          efficiencyGains.add('%25-30 kullanım artışı');
          riskMitigations.add('Bakım planlaması');
        }
        
        if (maintenanceCost > 1000) {
          optimizations.add('Bakım maliyetleri optimize edilmeli');
          allocationStrategies.add('Öngörülü bakım sistemi');
          efficiencyGains.add('%20-30 maliyet tasarrufu');
          riskMitigations.add('Ekipman izleme');
        }
        break;
        
      case ResourceType.equipment:
        optimizations.add('Ekipman kullanım verimliliği artırılmalı');
        allocationStrategies.add('Ekipman paylaşım sistemi');
        efficiencyGains.add('%30-35 kullanım artışı');
        riskMitigations.add('Ekipman durumu izleme');
        break;
        
      case ResourceType.time:
        optimizations.add('Zaman yönetimi optimize edilmeli');
        allocationStrategies.add('AI destekli zaman planlaması');
        efficiencyGains.add('%25-35 zaman tasarrufu');
        riskMitigations.add('Zaman takibi sistemi');
        break;
        
      case ResourceType.budget:
        optimizations.add('Bütçe kullanımı optimize edilmeli');
        allocationStrategies.add('Dinamik bütçe tahsisi');
        efficiencyGains.add('%15-20 maliyet azalması');
        riskMitigations.add('Bütçe izleme sistemi');
        break;
    }
    
    return {
      'optimizations': optimizations,
      'allocationStrategies': allocationStrategies,
      'efficiencyGains': efficiencyGains,
      'riskMitigations': riskMitigations,
      'confidence': 0.80 + (Random().nextDouble() * 0.15),
      'evidence': 'Resource optimization algorithms and operational research',
    };
  }

  Future<Map<String, dynamic>> generateQualityInsights({
    required String organizationId,
    required Map<String, dynamic> qualityData,
    required String qualityType,
  }) async {
    // Mock AI quality insights - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final insights = <String>[];
    final recommendations = <String>[];
    final trends = <String>[];
    final actionItems = <String>[];
    
    final qualityScore = qualityData['overall_score'] as double? ?? 0.0;
    final patientSatisfaction = qualityData['patient_satisfaction'] as double? ?? 0.0;
    final complianceRate = qualityData['compliance_rate'] as double? ?? 0.0;
    
    if (qualityScore < 4.0) {
      insights.add('Genel kalite skoru hedefin altında');
      recommendations.add('Kalite iyileştirme programı başlat');
      actionItems.add('Kalite ekipleri oluştur');
    }
    
    if (patientSatisfaction < 4.2) {
      insights.add('Hasta memnuniyeti düşük');
      recommendations.add('Hasta deneyimi iyileştirme');
      actionItems.add('Hasta geri bildirim sistemi güçlendir');
    }
    
    if (complianceRate < 0.9) {
      insights.add('Uyumluluk oranı hedefin altında');
      recommendations.add('Uyumluluk eğitimleri düzenle');
      actionItems.add('Otomatik uyumluluk kontrolü');
    }
    
    trends.add('Kalite skorları son 3 ayda %5 artış gösteriyor');
    trends.add('Hasta memnuniyeti stabil seviyede');
    trends.add('Uyumluluk oranları iyileşme trendinde');
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'trends': trends,
      'actionItems': actionItems,
      'confidence': 0.88 + (Random().nextDouble() * 0.07),
      'evidence': 'Quality management frameworks and patient outcome data',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getOperationalStatistics(String organizationId) async {
    final db = await database;
    
    final optimizationsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM appointment_optimizations 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final resourcePlanningsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM resource_plannings 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final qualityControlsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM quality_controls 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final efficiencyMetricsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM efficiency_metrics 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    return {
      'totalOptimizations': optimizationsResult.first['count'] as int,
      'totalResourcePlannings': resourcePlanningsResult.first['count'] as int,
      'totalQualityControls': qualityControlsResult.first['count'] as int,
      'totalEfficiencyMetrics': efficiencyMetricsResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getEfficiencyTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        em.report_date,
        em.utilization_rates,
        em.quality_scores,
        em.cost_metrics
      FROM efficiency_metrics em
      WHERE em.organization_id = ?
      ORDER BY em.report_date DESC
      LIMIT 12
    ''', [organizationId]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getQualityTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        qc.control_date,
        qc.overall_score,
        qc.quality_metrics
      FROM quality_controls qc
      WHERE qc.organization_id = ?
      ORDER BY qc.control_date DESC
      LIMIT 12
    ''', [organizationId]);
    
    return result;
  }
}
