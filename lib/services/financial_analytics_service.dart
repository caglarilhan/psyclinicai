import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/financial_analytics_models.dart';
import 'audit_log_service.dart';

class FinancialAnalyticsService {
  static final FinancialAnalyticsService _instance = FinancialAnalyticsService._internal();
  factory FinancialAnalyticsService() => _instance;
  FinancialAnalyticsService._internal();

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
    return 'financial-analytics-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cash_flows (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        flow_date TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        reference TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE investments (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        investment_date TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        expected_return REAL NOT NULL,
        expected_return_date TEXT NOT NULL,
        status TEXT NOT NULL,
        roi TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cost_analyses (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        costs_by_category TEXT NOT NULL,
        costs_by_department TEXT NOT NULL,
        costs_by_period TEXT NOT NULL,
        optimizations TEXT NOT NULL,
        trends TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE financial_projections (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        projection_date TEXT NOT NULL,
        revenue_projection TEXT NOT NULL,
        expense_projection TEXT NOT NULL,
        profit_projection TEXT NOT NULL,
        cash_flow_projection TEXT NOT NULL,
        assumptions TEXT NOT NULL,
        confidence TEXT NOT NULL,
        scenarios TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE financial_metrics (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        revenue_metrics TEXT NOT NULL,
        profit_metrics TEXT NOT NULL,
        margin_metrics TEXT NOT NULL,
        roi_metrics TEXT NOT NULL,
        trends TEXT NOT NULL,
        benchmarks TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        budget_date TEXT NOT NULL,
        valid_until TEXT NOT NULL,
        revenue_budget TEXT NOT NULL,
        expense_budget TEXT NOT NULL,
        department_budgets TEXT NOT NULL,
        assumptions TEXT NOT NULL,
        status TEXT NOT NULL,
        variance TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE financial_reports (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        report_type TEXT NOT NULL,
        summary TEXT NOT NULL,
        details TEXT NOT NULL,
        key_findings TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultCashFlows(db);
    await _createDefaultInvestments(db);
    await _createDefaultCostAnalyses(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultCashFlows(Database db) async {
    final cashFlows = [
      CashFlow(
        id: 'cf_001',
        organizationId: 'org_001',
        flowDate: DateTime.now().subtract(const Duration(days: 5)),
        type: CashFlowType.operating,
        description: 'Hasta konsültasyon ücretleri',
        amount: 15000.0,
        category: 'Revenue',
        reference: 'INV-001',
      ),
      CashFlow(
        id: 'cf_002',
        organizationId: 'org_001',
        flowDate: DateTime.now().subtract(const Duration(days: 3)),
        type: CashFlowType.operating,
        description: 'Personel maaşları',
        amount: -8000.0,
        category: 'Personnel',
        reference: 'PAY-001',
      ),
      CashFlow(
        id: 'cf_003',
        organizationId: 'org_001',
        flowDate: DateTime.now().subtract(const Duration(days: 1)),
        type: CashFlowType.investing,
        description: 'Yeni ekipman alımı',
        amount: -5000.0,
        category: 'Equipment',
        reference: 'EQ-001',
      ),
    ];

    for (final cashFlow in cashFlows) {
      await db.insert('cash_flows', {
        ...cashFlow.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _createDefaultInvestments(db) async {
    final investments = [
      Investment(
        id: 'inv_001',
        organizationId: 'org_001',
        investmentDate: DateTime.now().subtract(const Duration(days: 30)),
        type: InvestmentType.technology,
        title: 'AI Destekli Tanı Sistemi',
        description: 'Yapay zeka destekli mental health tanı sistemi',
        amount: 50000.0,
        expectedReturn: 75000.0,
        expectedReturnDate: DateTime.now().add(const Duration(days: 365)),
        status: 'active',
        roi: {
          'expected_roi': 0.5,
          'payback_period': 12,
          'npv': 25000.0,
          'irr': 0.15,
        },
      ),
      Investment(
        id: 'inv_002',
        organizationId: 'org_001',
        investmentDate: DateTime.now().subtract(const Duration(days: 60)),
        type: InvestmentType.equipment,
        title: 'Telehealth Ekipmanları',
        description: 'Uzaktan hasta takibi için ekipmanlar',
        amount: 25000.0,
        expectedReturn: 40000.0,
        expectedReturnDate: DateTime.now().add(const Duration(days: 180)),
        status: 'active',
        roi: {
          'expected_roi': 0.6,
          'payback_period': 6,
          'npv': 15000.0,
          'irr': 0.20,
        },
      ),
    ];

    for (final investment in investments) {
      await db.insert('investments', {
        ...investment.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _createDefaultCostAnalyses(db) async {
    final optimizations = [
      CostOptimization(
        id: 'co_001',
        title: 'Enerji Tasarrufu',
        description: 'LED aydınlatma ve enerji verimli ekipmanlar',
        category: CostCategory.facility,
        currentCost: 2000.0,
        optimizedCost: 1200.0,
        savings: 800.0,
        implementationSteps: [
          'LED aydınlatma kurulumu',
          'Enerji verimli ekipman alımı',
          'Enerji izleme sistemi',
        ],
        targetDate: DateTime.now().add(const Duration(days: 90)),
        status: 'planned',
      ),
      CostOptimization(
        id: 'co_002',
        title: 'Dijital Dokümantasyon',
        description: 'Kağıt kullanımını azaltarak maliyet tasarrufu',
        category: CostCategory.supplies,
        currentCost: 1500.0,
        optimizedCost: 500.0,
        savings: 1000.0,
        implementationSteps: [
          'Dijital dokümantasyon sistemi',
          'Personel eğitimi',
          'Kağıt kullanımı izleme',
        ],
        targetDate: DateTime.now().add(const Duration(days: 60)),
        status: 'in_progress',
      ),
    ];

    final costAnalysis = CostAnalysis(
      id: 'ca_001',
      organizationId: 'org_001',
      analysisDate: DateTime.now(),
      costsByCategory: {
        'Personnel': 80000.0,
        'Facility': 15000.0,
        'Equipment': 10000.0,
        'Supplies': 5000.0,
        'Marketing': 3000.0,
        'Administration': 2000.0,
      },
      costsByDepartment: {
        'Psychiatry': 40000.0,
        'Psychology': 30000.0,
        'Administration': 15000.0,
        'Support': 10000.0,
      },
      costsByPeriod: {
        'Monthly': 115000.0,
        'Quarterly': 345000.0,
        'Yearly': 1380000.0,
      },
      optimizations: optimizations,
      trends: {
        'cost_trend': 0.05,
        'efficiency_trend': 0.12,
        'savings_potential': 0.15,
      },
    );

    await db.insert('cost_analyses', {
      ...costAnalysis.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Cash Flow Management
  Future<String> createCashFlow({
    required String organizationId,
    required CashFlowType type,
    required String description,
    required double amount,
    required String category,
    String? reference,
  }) async {
    final db = await database;
    final cashFlowId = 'cf_${DateTime.now().millisecondsSinceEpoch}';
    
    final cashFlow = CashFlow(
      id: cashFlowId,
      organizationId: organizationId,
      flowDate: DateTime.now(),
      type: type,
      description: description,
      amount: amount,
      category: category,
      reference: reference,
    );
    
    await db.insert('cash_flows', {
      ...cashFlow.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'cash_flow.create',
      details: 'Cash flow created: $cashFlowId',
      userId: 'system',
      resourceId: cashFlowId,
    );
    
    return cashFlowId;
  }

  Future<List<CashFlow>> getCashFlows(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'cash_flows',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'flow_date DESC',
    );
    
    return result.map((json) => CashFlow.fromJson(json)).toList();
  }

  // Investment Management
  Future<String> createInvestment({
    required String organizationId,
    required InvestmentType type,
    required String title,
    required String description,
    required double amount,
    required double expectedReturn,
    required DateTime expectedReturnDate,
    required Map<String, dynamic> roi,
  }) async {
    final db = await database;
    final investmentId = 'inv_${DateTime.now().millisecondsSinceEpoch}';
    
    final investment = Investment(
      id: investmentId,
      organizationId: organizationId,
      investmentDate: DateTime.now(),
      type: type,
      title: title,
      description: description,
      amount: amount,
      expectedReturn: expectedReturn,
      expectedReturnDate: expectedReturnDate,
      status: 'active',
      roi: roi,
    );
    
    await db.insert('investments', {
      ...investment.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'investment.create',
      details: 'Investment created: $investmentId',
      userId: 'system',
      resourceId: investmentId,
    );
    
    return investmentId;
  }

  Future<List<Investment>> getInvestments(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'investments',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'investment_date DESC',
    );
    
    return result.map((json) => Investment.fromJson(json)).toList();
  }

  // Cost Analysis Management
  Future<String> createCostAnalysis({
    required String organizationId,
    required Map<String, double> costsByCategory,
    required Map<String, double> costsByDepartment,
    required Map<String, double> costsByPeriod,
    required List<CostOptimization> optimizations,
    required Map<String, dynamic> trends,
  }) async {
    final db = await database;
    final analysisId = 'ca_${DateTime.now().millisecondsSinceEpoch}';
    
    final analysis = CostAnalysis(
      id: analysisId,
      organizationId: organizationId,
      analysisDate: DateTime.now(),
      costsByCategory: costsByCategory,
      costsByDepartment: costsByDepartment,
      costsByPeriod: costsByPeriod,
      optimizations: optimizations,
      trends: trends,
    );
    
    await db.insert('cost_analyses', {
      ...analysis.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'cost_analysis.create',
      details: 'Cost analysis created: $analysisId',
      userId: 'system',
      resourceId: analysisId,
    );
    
    return analysisId;
  }

  Future<List<CostAnalysis>> getCostAnalyses(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'cost_analyses',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'analysis_date DESC',
    );
    
    return result.map((json) => CostAnalysis.fromJson(json)).toList();
  }

  // Financial Projection Management
  Future<String> createFinancialProjection({
    required String organizationId,
    required Map<String, double> revenueProjection,
    required Map<String, double> expenseProjection,
    required Map<String, double> profitProjection,
    required Map<String, double> cashFlowProjection,
    required List<String> assumptions,
    required String confidence,
    required Map<String, dynamic> scenarios,
  }) async {
    final db = await database;
    final projectionId = 'fp_${DateTime.now().millisecondsSinceEpoch}';
    
    final projection = FinancialProjection(
      id: projectionId,
      organizationId: organizationId,
      projectionDate: DateTime.now(),
      revenueProjection: revenueProjection,
      expenseProjection: expenseProjection,
      profitProjection: profitProjection,
      cashFlowProjection: cashFlowProjection,
      assumptions: assumptions,
      confidence: confidence,
      scenarios: scenarios,
    );
    
    await db.insert('financial_projections', {
      ...projection.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'financial_projection.create',
      details: 'Financial projection created: $projectionId',
      userId: 'system',
      resourceId: projectionId,
    );
    
    return projectionId;
  }

  Future<List<FinancialProjection>> getFinancialProjections(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'financial_projections',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'projection_date DESC',
    );
    
    return result.map((json) => FinancialProjection.fromJson(json)).toList();
  }

  // AI-Powered Features for Financial Analytics
  Future<Map<String, dynamic>> generateCashFlowInsights({
    required String organizationId,
    required Map<String, dynamic> cashFlowData,
  }) async {
    // Mock AI cash flow insights - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final insights = <String>[];
    final recommendations = <String>[];
    final trends = <String>[];
    final actionItems = <String>[];
    
    final operatingCashFlow = cashFlowData['operating_cash_flow'] as double? ?? 0.0;
    final investingCashFlow = cashFlowData['investing_cash_flow'] as double? ?? 0.0;
    final financingCashFlow = cashFlowData['financing_cash_flow'] as double? ?? 0.0;
    final netCashFlow = operatingCashFlow + investingCashFlow + financingCashFlow;
    
    if (operatingCashFlow < 0) {
      insights.add('Operasyonel nakit akışı negatif');
      recommendations.add('Gelir artırma stratejileri geliştir');
      actionItems.add('Hasta sayısını artır');
      actionItems.add('Hizmet fiyatlarını gözden geçir');
    }
    
    if (investingCashFlow < -10000) {
      insights.add('Yatırım harcamaları yüksek');
      recommendations.add('Yatırım ROI\'sini izle');
      actionItems.add('Yatırım performansını değerlendir');
    }
    
    if (netCashFlow < 0) {
      insights.add('Net nakit akışı negatif');
      recommendations.add('Nakit yönetimi stratejileri');
      actionItems.add('Kısa vadeli finansman seçenekleri');
    }
    
    trends.add('Nakit akışı son 3 ayda %12 artış gösteriyor');
    trends.add('Operasyonel verimlilik iyileşme trendinde');
    trends.add('Yatırım getirisi hedeflerin üzerinde');
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'trends': trends,
      'actionItems': actionItems,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Cash flow analysis and financial modeling',
    };
  }

  Future<Map<String, dynamic>> generateInvestmentAnalysis({
    required String organizationId,
    required Map<String, dynamic> investmentData,
  }) async {
    // Mock AI investment analysis - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final analysis = <String>[];
    final recommendations = <String>[];
    final riskFactors = <String>[];
    final opportunities = <String>[];
    
    final totalInvestment = investmentData['total_investment'] as double? ?? 0.0;
    final expectedROI = investmentData['expected_roi'] as double? ?? 0.0;
    final paybackPeriod = investmentData['payback_period'] as double? ?? 0.0;
    
    if (expectedROI > 0.2) {
      analysis.add('Yatırım getirisi yüksek');
      recommendations.add('Benzer yatırımları değerlendir');
      opportunities.add('Teknoloji yatırımları genişletilebilir');
    }
    
    if (paybackPeriod < 12) {
      analysis.add('Geri ödeme süresi kısa');
      recommendations.add('Hızlı geri dönüş yatırımlarına odaklan');
      opportunities.add('Kısa vadeli yatırım fırsatları');
    }
    
    if (totalInvestment > 100000) {
      analysis.add('Büyük yatırım projeleri aktif');
      riskFactors.add('Yüksek yatırım riski');
      recommendations.add('Risk yönetimi stratejileri güçlendir');
    }
    
    return {
      'analysis': analysis,
      'recommendations': recommendations,
      'riskFactors': riskFactors,
      'opportunities': opportunities,
      'confidence': 0.80 + (Random().nextDouble() * 0.15),
      'evidence': 'Investment analysis and ROI modeling',
    };
  }

  Future<Map<String, dynamic>> generateCostOptimization({
    required String organizationId,
    required Map<String, dynamic> costData,
  }) async {
    // Mock AI cost optimization - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final optimizations = <String>[];
    final savingsOpportunities = <String>[];
    final implementationSteps = <String>[];
    final expectedSavings = <String>[];
    
    final personnelCosts = costData['personnel_costs'] as double? ?? 0.0;
    final facilityCosts = costData['facility_costs'] as double? ?? 0.0;
    final equipmentCosts = costData['equipment_costs'] as double? ?? 0.0;
    final totalCosts = personnelCosts + facilityCosts + equipmentCosts;
    
    if (personnelCosts > totalCosts * 0.6) {
      optimizations.add('Personel maliyetleri yüksek');
      savingsOpportunities.add('Otomasyon ile personel verimliliği artır');
      implementationSteps.add('AI destekli süreçler');
      expectedSavings.add('%15-20 personel maliyeti tasarrufu');
    }
    
    if (facilityCosts > totalCosts * 0.2) {
      optimizations.add('Tesis maliyetleri optimize edilmeli');
      savingsOpportunities.add('Enerji verimliliği artır');
      implementationSteps.add('LED aydınlatma ve izolasyon');
      expectedSavings.add('%25-30 enerji maliyeti tasarrufu');
    }
    
    if (equipmentCosts > totalCosts * 0.15) {
      optimizations.add('Ekipman maliyetleri yüksek');
      savingsOpportunities.add('Ekipman paylaşım sistemi');
      implementationSteps.add('Dinamik ekipman tahsisi');
      expectedSavings.add('%20-25 ekipman maliyeti tasarrufu');
    }
    
    return {
      'optimizations': optimizations,
      'savingsOpportunities': savingsOpportunities,
      'implementationSteps': implementationSteps,
      'expectedSavings': expectedSavings,
      'confidence': 0.88 + (Random().nextDouble() * 0.07),
      'evidence': 'Cost analysis and optimization algorithms',
    };
  }

  Future<Map<String, dynamic>> generateFinancialProjection({
    required String organizationId,
    required Map<String, dynamic> currentData,
    required List<String> assumptions,
  }) async {
    // Mock AI financial projection - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 4));
    
    final projections = <String>[];
    final scenarios = <String>[];
    final risks = <String>[];
    final opportunities = <String>[];
    
    final currentRevenue = currentData['current_revenue'] as double? ?? 0.0;
    final growthRate = currentData['growth_rate'] as double? ?? 0.0;
    final marketSize = currentData['market_size'] as double? ?? 0.0;
    
    // Optimistic scenario
    final optimisticRevenue = currentRevenue * (1 + growthRate * 1.5);
    projections.add('Optimistik senaryo: ${optimisticRevenue.toStringAsFixed(0)} TL');
    scenarios.add('Pazar büyümesi %20, rekabet avantajı');
    
    // Realistic scenario
    final realisticRevenue = currentRevenue * (1 + growthRate);
    projections.add('Gerçekçi senaryo: ${realisticRevenue.toStringAsFixed(0)} TL');
    scenarios.add('Mevcut trend devamı, stabil büyüme');
    
    // Pessimistic scenario
    final pessimisticRevenue = currentRevenue * (1 + growthRate * 0.5);
    projections.add('Kötümser senaryo: ${pessimisticRevenue.toStringAsFixed(0)} TL');
    scenarios.add('Pazar daralması, artan rekabet');
    
    if (marketSize > currentRevenue * 10) {
      opportunities.add('Büyük pazar potansiyeli mevcut');
      opportunities.add('Genişleme fırsatları değerlendirilebilir');
    }
    
    risks.add('Ekonomik belirsizlik riski');
    risks.add('Regülasyon değişiklikleri');
    risks.add('Rekabet artışı');
    
    return {
      'projections': projections,
      'scenarios': scenarios,
      'risks': risks,
      'opportunities': opportunities,
      'confidence': 0.82 + (Random().nextDouble() * 0.13),
      'evidence': 'Financial modeling and market analysis',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getFinancialStatistics(String organizationId) async {
    final db = await database;
    
    final cashFlowsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM cash_flows 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final investmentsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM investments 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final costAnalysesResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM cost_analyses 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final projectionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM financial_projections 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    return {
      'totalCashFlows': cashFlowsResult.first['count'] as int,
      'totalInvestments': investmentsResult.first['count'] as int,
      'totalCostAnalyses': costAnalysesResult.first['count'] as int,
      'totalProjections': projectionsResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getCashFlowTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        cf.flow_date,
        cf.type,
        cf.amount,
        cf.category
      FROM cash_flows cf
      WHERE cf.organization_id = ?
      ORDER BY cf.flow_date DESC
      LIMIT 12
    ''', [organizationId]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getInvestmentTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        inv.investment_date,
        inv.type,
        inv.amount,
        inv.expected_return,
        inv.status
      FROM investments inv
      WHERE inv.organization_id = ?
      ORDER BY inv.investment_date DESC
      LIMIT 12
    ''', [organizationId]);
    
    return result;
  }
}
