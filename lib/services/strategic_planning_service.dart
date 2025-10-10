import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/strategic_planning_models.dart';
import 'audit_log_service.dart';

class StrategicPlanningService {
  static final StrategicPlanningService _instance = StrategicPlanningService._internal();
  factory StrategicPlanningService() => _instance;
  StrategicPlanningService._internal();

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
    return 'strategic-planning-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE market_analyses (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        market_size TEXT NOT NULL,
        market_share TEXT NOT NULL,
        competitors TEXT NOT NULL,
        trends TEXT NOT NULL,
        opportunities TEXT NOT NULL,
        threats TEXT NOT NULL,
        summary TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE growth_projections (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        projection_date TEXT NOT NULL,
        revenue_projection TEXT NOT NULL,
        patient_projection TEXT NOT NULL,
        staff_projection TEXT NOT NULL,
        market_share_projection TEXT NOT NULL,
        strategies TEXT NOT NULL,
        assumptions TEXT NOT NULL,
        confidence TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_segmentations (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        segments TEXT NOT NULL,
        segment_distribution TEXT NOT NULL,
        segment_value TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE strategic_plans (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        plan_date TEXT NOT NULL,
        valid_until TEXT NOT NULL,
        vision TEXT NOT NULL,
        mission TEXT NOT NULL,
        strategic_goals TEXT NOT NULL,
        objectives TEXT NOT NULL,
        initiatives TEXT NOT NULL,
        budget TEXT NOT NULL,
        timeline TEXT NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultMarketAnalysis(db);
    await _createDefaultGrowthProjection(db);
    await _createDefaultPatientSegmentation(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultMarketAnalysis(Database db) async {
    final competitors = [
      Competitor(
        id: 'comp_001',
        name: 'SimplePractice',
        description: 'Leading practice management software',
        position: CompetitivePosition.leader,
        strengths: {
          'brand_recognition': 0.9,
          'feature_completeness': 0.8,
          'user_experience': 0.7,
        },
        weaknesses: {
          'pricing': 0.6,
          'customization': 0.5,
          'support': 0.7,
        },
        services: ['Scheduling', 'Billing', 'Notes', 'Telehealth'],
        pricing: {'monthly': 39, 'annual': 390},
        marketShare: '35%',
      ),
      Competitor(
        id: 'comp_002',
        name: 'TherapyNotes',
        description: 'Comprehensive EHR solution',
        position: CompetitivePosition.challenger,
        strengths: {
          'clinical_features': 0.9,
          'compliance': 0.8,
          'integration': 0.7,
        },
        weaknesses: {
          'user_interface': 0.6,
          'mobile_app': 0.5,
          'pricing': 0.6,
        },
        services: ['EHR', 'Billing', 'Scheduling', 'Reports'],
        pricing: {'monthly': 49, 'annual': 490},
        marketShare: '25%',
      ),
    ];

    final trends = [
      MarketTrend(
        id: 'trend_001',
        name: 'AI Integration',
        description: 'Increasing demand for AI-powered features',
        category: 'Technology',
        impact: 0.8,
        probability: 0.9,
        startDate: DateTime.now(),
        affectedSegments: ['individual', 'corporate'],
      ),
      MarketTrend(
        id: 'trend_002',
        name: 'Telehealth Growth',
        description: 'Continued growth in virtual care',
        category: 'Service Delivery',
        impact: 0.7,
        probability: 0.95,
        startDate: DateTime.now(),
        affectedSegments: ['individual', 'family', 'corporate'],
      ),
    ];

    final opportunities = [
      Opportunity(
        id: 'opp_001',
        title: 'AI-Powered Diagnostics',
        description: 'Develop AI tools for mental health assessment',
        category: 'Product Development',
        potential: 0.9,
        feasibility: 0.7,
        identifiedDate: DateTime.now(),
        requiredResources: ['AI Expertise', 'Clinical Validation', 'Development Team'],
      ),
      Opportunity(
        id: 'opp_002',
        title: 'Corporate Wellness Programs',
        description: 'Expand into corporate mental health services',
        category: 'Market Expansion',
        potential: 0.8,
        feasibility: 0.8,
        identifiedDate: DateTime.now(),
        requiredResources: ['Sales Team', 'Corporate Partnerships', 'Service Delivery'],
      ),
    ];

    final threats = [
      Threat(
        id: 'threat_001',
        title: 'Regulatory Changes',
        description: 'Potential changes in healthcare regulations',
        category: 'Regulatory',
        severity: 0.7,
        probability: 0.6,
        identifiedDate: DateTime.now(),
        mitigationStrategies: ['Compliance Monitoring', 'Legal Consultation', 'Policy Updates'],
      ),
      Threat(
        id: 'threat_002',
        title: 'Economic Downturn',
        description: 'Economic recession affecting healthcare spending',
        category: 'Economic',
        severity: 0.8,
        probability: 0.4,
        identifiedDate: DateTime.now(),
        mitigationStrategies: ['Cost Optimization', 'Diversified Revenue', 'Emergency Fund'],
      ),
    ];

    final marketAnalysis = MarketAnalysis(
      id: 'ma_001',
      organizationId: 'org_001',
      analysisDate: DateTime.now(),
      marketSize: {
        'individual': 5000000,
        'family': 2000000,
        'corporate': 1000000,
        'insurance': 3000000,
        'government': 500000,
      },
      marketShare: {
        'individual': 0.15,
        'family': 0.10,
        'corporate': 0.05,
        'insurance': 0.08,
        'government': 0.02,
      },
      competitors: competitors,
      trends: trends,
      opportunities: opportunities,
      threats: threats,
      summary: 'Strong growth potential in AI-powered mental health solutions with significant opportunities in corporate wellness and telehealth expansion.',
    );

    await db.insert('market_analyses', {
      ...marketAnalysis.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createDefaultGrowthProjection(Database db) async {
    final growthProjection = GrowthProjection(
      id: 'gp_001',
      organizationId: 'org_001',
      projectionDate: DateTime.now(),
      revenueProjection: {
        '2024': 1000000,
        '2025': 1500000,
        '2026': 2250000,
        '2027': 3375000,
        '2028': 5062500,
      },
      patientProjection: {
        '2024': 1000,
        '2025': 1500,
        '2026': 2250,
        '2027': 3375,
        '2028': 5062,
      },
      staffProjection: {
        '2024': 20,
        '2025': 30,
        '2026': 45,
        '2027': 67,
        '2028': 100,
      },
      marketShareProjection: {
        '2024': 0.05,
        '2025': 0.08,
        '2026': 0.12,
        '2027': 0.18,
        '2028': 0.25,
      },
      strategies: [GrowthStrategy.organic, GrowthStrategy.innovation],
      assumptions: {
        'market_growth': 0.15,
        'technology_adoption': 0.20,
        'competitive_position': 0.10,
      },
      confidence: 'high',
    );

    await db.insert('growth_projections', {
      ...growthProjection.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createDefaultPatientSegmentation(db) async {
    final segments = [
      PatientSegment(
        id: 'seg_001',
        name: 'Gen Z Professionals',
        description: 'Young professionals aged 22-27',
        type: MarketSegment.individual,
        characteristics: {
          'age_range': '22-27',
          'income': '50000-80000',
          'education': 'college',
          'tech_savvy': 0.9,
        },
        size: 0.25,
        value: 0.30,
        needs: ['Anxiety Management', 'Career Stress', 'Work-Life Balance'],
        preferences: ['Mobile App', 'Quick Sessions', 'AI Features'],
      ),
      PatientSegment(
        id: 'seg_002',
        name: 'Millennial Families',
        description: 'Families with young children',
        type: MarketSegment.family,
        characteristics: {
          'age_range': '28-40',
          'income': '80000-120000',
          'family_status': 'married_with_children',
          'time_constraints': 0.8,
        },
        size: 0.35,
        value: 0.40,
        needs: ['Family Therapy', 'Child Counseling', 'Parenting Support'],
        preferences: ['Evening Sessions', 'Family Packages', 'Online Resources'],
      ),
      PatientSegment(
        id: 'seg_003',
        name: 'Corporate Executives',
        description: 'Senior executives and managers',
        type: MarketSegment.corporate,
        characteristics: {
          'age_range': '35-55',
          'income': '150000+',
          'position': 'executive',
          'stress_level': 0.9,
        },
        size: 0.15,
        value: 0.25,
        needs: ['Executive Coaching', 'Stress Management', 'Leadership Development'],
        preferences: ['Premium Service', 'Flexible Scheduling', 'Confidentiality'],
      ),
    ];

    final patientSegmentation = PatientSegmentation(
      id: 'ps_001',
      organizationId: 'org_001',
      analysisDate: DateTime.now(),
      segments: segments,
      segmentDistribution: {
        'Gen Z Professionals': 0.25,
        'Millennial Families': 0.35,
        'Corporate Executives': 0.15,
        'Other': 0.25,
      },
      segmentValue: {
        'Gen Z Professionals': 0.30,
        'Millennial Families': 0.40,
        'Corporate Executives': 0.25,
        'Other': 0.05,
      },
      recommendations: [
        'Focus on mobile-first experience for Gen Z',
        'Develop family therapy packages for Millennials',
        'Create premium executive coaching services',
        'Invest in AI-powered assessment tools',
      ],
    );

    await db.insert('patient_segmentations', {
      ...patientSegmentation.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Market Analysis Management
  Future<String> createMarketAnalysis({
    required String organizationId,
    required Map<String, double> marketSize,
    required Map<String, double> marketShare,
    required List<Competitor> competitors,
    required List<MarketTrend> trends,
    required List<Opportunity> opportunities,
    required List<Threat> threats,
    required String summary,
  }) async {
    final db = await database;
    final analysisId = 'ma_${DateTime.now().millisecondsSinceEpoch}';
    
    final marketAnalysis = MarketAnalysis(
      id: analysisId,
      organizationId: organizationId,
      analysisDate: DateTime.now(),
      marketSize: marketSize,
      marketShare: marketShare,
      competitors: competitors,
      trends: trends,
      opportunities: opportunities,
      threats: threats,
      summary: summary,
    );
    
    await db.insert('market_analyses', {
      ...marketAnalysis.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'market_analysis.create',
      details: 'Market analysis created: $analysisId',
      userId: 'system',
      resourceId: analysisId,
    );
    
    return analysisId;
  }

  Future<List<MarketAnalysis>> getMarketAnalyses(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'market_analyses',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'analysis_date DESC',
    );
    
    return result.map((json) => MarketAnalysis.fromJson(json)).toList();
  }

  // Growth Projection Management
  Future<String> createGrowthProjection({
    required String organizationId,
    required Map<String, double> revenueProjection,
    required Map<String, double> patientProjection,
    required Map<String, double> staffProjection,
    required Map<String, double> marketShareProjection,
    required List<GrowthStrategy> strategies,
    required Map<String, dynamic> assumptions,
    required String confidence,
  }) async {
    final db = await database;
    final projectionId = 'gp_${DateTime.now().millisecondsSinceEpoch}';
    
    final growthProjection = GrowthProjection(
      id: projectionId,
      organizationId: organizationId,
      projectionDate: DateTime.now(),
      revenueProjection: revenueProjection,
      patientProjection: patientProjection,
      staffProjection: staffProjection,
      marketShareProjection: marketShareProjection,
      strategies: strategies,
      assumptions: assumptions,
      confidence: confidence,
    );
    
    await db.insert('growth_projections', {
      ...growthProjection.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'growth_projection.create',
      details: 'Growth projection created: $projectionId',
      userId: 'system',
      resourceId: projectionId,
    );
    
    return projectionId;
  }

  Future<List<GrowthProjection>> getGrowthProjections(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'growth_projections',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'projection_date DESC',
    );
    
    return result.map((json) => GrowthProjection.fromJson(json)).toList();
  }

  // Patient Segmentation Management
  Future<String> createPatientSegmentation({
    required String organizationId,
    required List<PatientSegment> segments,
    required Map<String, double> segmentDistribution,
    required Map<String, double> segmentValue,
    required List<String> recommendations,
  }) async {
    final db = await database;
    final segmentationId = 'ps_${DateTime.now().millisecondsSinceEpoch}';
    
    final patientSegmentation = PatientSegmentation(
      id: segmentationId,
      organizationId: organizationId,
      analysisDate: DateTime.now(),
      segments: segments,
      segmentDistribution: segmentDistribution,
      segmentValue: segmentValue,
      recommendations: recommendations,
    );
    
    await db.insert('patient_segmentations', {
      ...patientSegmentation.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'patient_segmentation.create',
      details: 'Patient segmentation created: $segmentationId',
      userId: 'system',
      resourceId: segmentationId,
    );
    
    return segmentationId;
  }

  Future<List<PatientSegmentation>> getPatientSegmentations(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'patient_segmentations',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'analysis_date DESC',
    );
    
    return result.map((json) => PatientSegmentation.fromJson(json)).toList();
  }

  // Strategic Plan Management
  Future<String> createStrategicPlan({
    required String organizationId,
    required DateTime validUntil,
    required String vision,
    required String mission,
    required List<String> strategicGoals,
    required List<StrategicObjective> objectives,
    required List<StrategicInitiative> initiatives,
    required Map<String, dynamic> budget,
    required Map<String, dynamic> timeline,
  }) async {
    final db = await database;
    final planId = 'sp_${DateTime.now().millisecondsSinceEpoch}';
    
    final strategicPlan = StrategicPlan(
      id: planId,
      organizationId: organizationId,
      planDate: DateTime.now(),
      validUntil: validUntil,
      vision: vision,
      mission: mission,
      strategicGoals: strategicGoals,
      objectives: objectives,
      initiatives: initiatives,
      budget: budget,
      timeline: timeline,
      status: 'active',
    );
    
    await db.insert('strategic_plans', {
      ...strategicPlan.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'strategic_plan.create',
      details: 'Strategic plan created: $planId',
      userId: 'system',
      resourceId: planId,
    );
    
    return planId;
  }

  Future<List<StrategicPlan>> getStrategicPlans(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'strategic_plans',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'plan_date DESC',
    );
    
    return result.map((json) => StrategicPlan.fromJson(json)).toList();
  }

  // AI-Powered Features for Strategic Planning
  Future<Map<String, dynamic>> generateMarketInsights({
    required String organizationId,
    required Map<String, dynamic> currentData,
  }) async {
    // Mock AI market insights - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final insights = <String>[];
    final recommendations = <String>[];
    final risks = <String>[];
    final opportunities = <String>[];
    
    // Mevcut verilere göre analiz
    final marketShare = currentData['marketShare'] as Map<String, double>? ?? {};
    final revenue = currentData['revenue'] as double? ?? 0.0;
    
    if (marketShare['individual'] != null && marketShare['individual']! < 0.20) {
      insights.add('Bireysel hasta segmentinde büyüme potansiyeli yüksek');
      recommendations.add('Bireysel hasta odaklı pazarlama kampanyaları');
      opportunities.add('Gen Z ve Millennial hedefleme');
    }
    
    if (marketShare['corporate'] != null && marketShare['corporate']! < 0.10) {
      insights.add('Kurumsal segmentte önemli fırsatlar var');
      recommendations.add('Kurumsal wellness programları geliştir');
      opportunities.add('B2B satış stratejisi');
    }
    
    if (revenue < 2000000) {
      insights.add('Gelir büyüme için AI özellikleri kritik');
      recommendations.add('AI destekli tanı ve tedavi araçları');
      opportunities.add('Teknoloji odaklı diferansiyasyon');
    }
    
    risks.add('Rekabet artışı bekleniyor');
    risks.add('Regülasyon değişiklikleri riski');
    risks.add('Ekonomik belirsizlik');
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'risks': risks,
      'opportunities': opportunities,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Market analysis and competitive intelligence',
    };
  }

  Future<Map<String, dynamic>> generateGrowthStrategy({
    required String organizationId,
    required Map<String, dynamic> currentMetrics,
    required List<GrowthStrategy> preferredStrategies,
  }) async {
    // Mock AI growth strategy - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 4));
    
    final strategies = <String>[];
    final actionItems = <String>[];
    final timelines = <String>[];
    final investments = <String>[];
    
    // Mevcut metrikler ve tercih edilen stratejilere göre öneriler
    final revenue = currentMetrics['revenue'] as double? ?? 0.0;
    final marketShare = currentMetrics['marketShare'] as double? ?? 0.0;
    
    if (preferredStrategies.contains(GrowthStrategy.innovation)) {
      strategies.add('AI-Powered Innovation Strategy');
      actionItems.add('AI tanı asistanı geliştir');
      actionItems.add('Otomatik raporlama sistemi');
      actionItems.add('Hasta risk değerlendirmesi');
      timelines.add('Q1-Q2: AI geliştirme');
      timelines.add('Q3: Beta test');
      timelines.add('Q4: Pazar lansmanı');
      investments.add('AI geliştirme: $500K');
      investments.add('Pazarlama: $200K');
    }
    
    if (preferredStrategies.contains(GrowthStrategy.expansion)) {
      strategies.add('Geographic Expansion Strategy');
      actionItems.add('Yeni şehirlerde klinik aç');
      actionItems.add('Telehealth hizmetleri genişlet');
      actionItems.add('Ortaklık anlaşmaları');
      timelines.add('Q1: Pazar araştırması');
      timelines.add('Q2-Q3: Klinik kurulum');
      timelines.add('Q4: Operasyon başlangıcı');
      investments.add('Klinik kurulum: $1M');
      investments.add('Personel: $300K');
    }
    
    if (preferredStrategies.contains(GrowthStrategy.partnership)) {
      strategies.add('Strategic Partnership Strategy');
      actionItems.add('Sigorta şirketleri ile anlaşma');
      actionItems.add('Hastane ortaklıkları');
      actionItems.add('Teknoloji şirketleri işbirliği');
      timelines.add('Q1: Ortaklık görüşmeleri');
      timelines.add('Q2: Anlaşma imzalama');
      timelines.add('Q3-Q4: Uygulama');
      investments.add('Ortaklık geliştirme: $150K');
      investments.add('Entegrasyon: $100K');
    }
    
    return {
      'strategies': strategies,
      'actionItems': actionItems,
      'timelines': timelines,
      'investments': investments,
      'expectedROI': 2.5 + (Random().nextDouble() * 1.0),
      'confidence': 0.80 + (Random().nextDouble() * 0.15),
      'evidence': 'Strategic planning frameworks and market analysis',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getStrategicPlanningStatistics(String organizationId) async {
    final db = await database;
    
    final marketAnalysesResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM market_analyses 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final growthProjectionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM growth_projections 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final patientSegmentationsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_segmentations 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final strategicPlansResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM strategic_plans 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    return {
      'totalMarketAnalyses': marketAnalysesResult.first['count'] as int,
      'totalGrowthProjections': growthProjectionsResult.first['count'] as int,
      'totalPatientSegmentations': patientSegmentationsResult.first['count'] as int,
      'totalStrategicPlans': strategicPlansResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getMarketTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        trends,
        analysis_date,
        summary
      FROM market_analyses
      WHERE organization_id = ?
      ORDER BY analysis_date DESC
      LIMIT 5
    ''', [organizationId]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getGrowthProjectionsTrend(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        revenue_projection,
        patient_projection,
        projection_date,
        confidence
      FROM growth_projections
      WHERE organization_id = ?
      ORDER BY projection_date DESC
      LIMIT 3
    ''', [organizationId]);
    
    return result;
  }
}
