import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/analytics_models.dart';
import 'audit_log_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

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
    return 'analytics-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clinical_kpis (
        id TEXT PRIMARY KEY,
        metric_name TEXT NOT NULL,
        value REAL NOT NULL,
        previous_value REAL,
        target_value REAL,
        period TEXT NOT NULL,
        date TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE trend_analyses (
        id TEXT PRIMARY KEY,
        metric TEXT NOT NULL,
        period TEXT NOT NULL,
        data_points TEXT NOT NULL,
        direction TEXT NOT NULL,
        trend_strength REAL NOT NULL,
        interpretation TEXT NOT NULL,
        analyzed_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_outcome_metrics (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        assessment_type TEXT NOT NULL,
        baseline_score REAL NOT NULL,
        current_score REAL NOT NULL,
        improvement_percentage REAL NOT NULL,
        sessions_completed INTEGER NOT NULL,
        baseline_date TEXT NOT NULL,
        current_date TEXT NOT NULL,
        outcome_category TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE revenue_analytics (
        id TEXT PRIMARY KEY,
        period TEXT NOT NULL,
        total_revenue REAL NOT NULL,
        recurring_revenue REAL NOT NULL,
        one_time_revenue REAL NOT NULL,
        total_sessions INTEGER NOT NULL,
        average_session_value REAL NOT NULL,
        revenue_growth REAL NOT NULL,
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_retention_metrics (
        id TEXT PRIMARY KEY,
        period TEXT NOT NULL,
        new_patients INTEGER NOT NULL,
        retained_patients INTEGER NOT NULL,
        lost_patients INTEGER NOT NULL,
        retention_rate REAL NOT NULL,
        churn_rate REAL NOT NULL,
        average_lifetime_value REAL NOT NULL,
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Clinical KPI Management
  Future<String> createClinicalKPI({
    required String metricName,
    required double value,
    double? previousValue,
    double? targetValue,
    required AnalyticsPeriod period,
    required DateTime date,
    Map<String, dynamic> metadata = const {},
  }) async {
    final db = await database;
    final kpiId = 'kpi_${DateTime.now().millisecondsSinceEpoch}';
    
    final kpi = ClinicalKPI(
      id: kpiId,
      metricName: metricName,
      value: value,
      previousValue: previousValue,
      targetValue: targetValue,
      period: period,
      date: date,
      metadata: metadata,
    );
    
    await db.insert('clinical_kpis', {
      ...kpi.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'analytics.kpi_create',
      details: 'Clinical KPI created: $kpiId',
      userId: 'system',
      resourceId: kpiId,
    );
    
    return kpiId;
  }

  Future<List<ClinicalKPI>> getClinicalKPIs({
    AnalyticsPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (period != null) {
      whereClause += ' AND period = ?';
      whereArgs.add(period.name);
    }
    
    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    final result = await db.query(
      'clinical_kpis',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    
    return result.map((json) => ClinicalKPI.fromJson(json)).toList();
  }

  // Trend Analysis
  Future<String> createTrendAnalysis({
    required AnalyticsMetric metric,
    required AnalyticsPeriod period,
    required List<DataPoint> dataPoints,
  }) async {
    final db = await database;
    final trendId = 'trend_${DateTime.now().millisecondsSinceEpoch}';
    
    final direction = _calculateTrendDirection(dataPoints);
    final trendStrength = _calculateTrendStrength(dataPoints);
    final interpretation = _generateTrendInterpretation(metric, direction, trendStrength);
    
    final trend = TrendAnalysis(
      id: trendId,
      metric: metric,
      period: period,
      dataPoints: dataPoints,
      direction: direction,
      trendStrength: trendStrength,
      interpretation: interpretation,
      analyzedAt: DateTime.now(),
    );
    
    await db.insert('trend_analyses', {
      ...trend.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'analytics.trend_create',
      details: 'Trend analysis created: $trendId',
      userId: 'system',
      resourceId: trendId,
    );
    
    return trendId;
  }

  TrendDirection _calculateTrendDirection(List<DataPoint> dataPoints) {
    if (dataPoints.length < 2) return TrendDirection.stable;
    
    final firstValue = dataPoints.first.value;
    final lastValue = dataPoints.last.value;
    final change = lastValue - firstValue;
    final changePercentage = (change / firstValue) * 100;
    
    if (changePercentage > 5) return TrendDirection.increasing;
    if (changePercentage < -5) return TrendDirection.decreasing;
    
    // Check for volatility
    final values = dataPoints.map((dp) => dp.value).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final standardDeviation = sqrt(variance);
    
    if (standardDeviation > mean * 0.2) return TrendDirection.volatile;
    
    return TrendDirection.stable;
  }

  double _calculateTrendStrength(List<DataPoint> dataPoints) {
    if (dataPoints.length < 2) return 0.0;
    
    // Simple linear regression to calculate R-squared
    final n = dataPoints.length;
    final xValues = List.generate(n, (i) => i.toDouble());
    final yValues = dataPoints.map((dp) => dp.value).toList();
    
    final xMean = xValues.reduce((a, b) => a + b) / n;
    final yMean = yValues.reduce((a, b) => a + b) / n;
    
    double numerator = 0;
    double xDenominator = 0;
    double yDenominator = 0;
    
    for (int i = 0; i < n; i++) {
      final xDiff = xValues[i] - xMean;
      final yDiff = yValues[i] - yMean;
      
      numerator += xDiff * yDiff;
      xDenominator += xDiff * xDiff;
      yDenominator += yDiff * yDiff;
    }
    
    if (xDenominator == 0 || yDenominator == 0) return 0.0;
    
    final correlation = numerator / sqrt(xDenominator * yDenominator);
    return correlation.abs();
  }

  String _generateTrendInterpretation(AnalyticsMetric metric, TrendDirection direction, double strength) {
    final metricName = _getMetricDisplayName(metric);
    final strengthText = strength > 0.7 ? 'güçlü' : strength > 0.4 ? 'orta' : 'zayıf';
    
    switch (direction) {
      case TrendDirection.increasing:
        return '$metricName metriklerinde $strengthText bir artış trendi gözlemlenmektedir.';
      case TrendDirection.decreasing:
        return '$metricName metriklerinde $strengthText bir azalış trendi gözlemlenmektedir.';
      case TrendDirection.volatile:
        return '$metricName metriklerinde değişken bir trend gözlemlenmektedir.';
      case TrendDirection.stable:
        return '$metricName metrikleri stabil seviyelerde seyretmektedir.';
    }
  }

  String _getMetricDisplayName(AnalyticsMetric metric) {
    switch (metric) {
      case AnalyticsMetric.sessions:
        return 'Seans';
      case AnalyticsMetric.revenue:
        return 'Gelir';
      case AnalyticsMetric.patients:
        return 'Hasta';
      case AnalyticsMetric.satisfaction:
        return 'Memnuniyet';
      case AnalyticsMetric.retention:
        return 'Sadakat';
    }
  }

  Future<List<TrendAnalysis>> getTrendAnalyses({
    AnalyticsMetric? metric,
    AnalyticsPeriod? period,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (metric != null) {
      whereClause += ' AND metric = ?';
      whereArgs.add(metric.name);
    }
    
    if (period != null) {
      whereClause += ' AND period = ?';
      whereArgs.add(period.name);
    }
    
    final result = await db.query(
      'trend_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analyzed_at DESC',
    );
    
    return result.map((json) => TrendAnalysis.fromJson(json)).toList();
  }

  // Patient Outcome Metrics
  Future<String> createPatientOutcomeMetrics({
    required String patientId,
    required String assessmentType,
    required double baselineScore,
    required double currentScore,
    required int sessionsCompleted,
    required DateTime baselineDate,
    required DateTime currentDate,
  }) async {
    final db = await database;
    final outcomeId = 'outcome_${DateTime.now().millisecondsSinceEpoch}';
    
    final improvementPercentage = ((currentScore - baselineScore) / baselineScore) * 100;
    final outcomeCategory = _categorizeOutcome(improvementPercentage);
    
    final outcome = PatientOutcomeMetrics(
      id: outcomeId,
      patientId: patientId,
      assessmentType: assessmentType,
      baselineScore: baselineScore,
      currentScore: currentScore,
      improvementPercentage: improvementPercentage,
      sessionsCompleted: sessionsCompleted,
      baselineDate: baselineDate,
      currentDate: currentDate,
      outcomeCategory: outcomeCategory,
    );
    
    await db.insert('patient_outcome_metrics', {
      ...outcome.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'analytics.outcome_create',
      details: 'Patient outcome metrics created: $outcomeId',
      userId: 'system',
      resourceId: outcomeId,
    );
    
    return outcomeId;
  }

  String _categorizeOutcome(double improvementPercentage) {
    if (improvementPercentage > 50) return 'Mükemmel';
    if (improvementPercentage > 25) return 'İyi';
    if (improvementPercentage > 0) return 'Orta';
    if (improvementPercentage > -25) return 'Zayıf';
    return 'Kötü';
  }

  Future<List<PatientOutcomeMetrics>> getPatientOutcomeMetrics({
    String? patientId,
    String? assessmentType,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (patientId != null) {
      whereClause += ' AND patient_id = ?';
      whereArgs.add(patientId);
    }
    
    if (assessmentType != null) {
      whereClause += ' AND assessment_type = ?';
      whereArgs.add(assessmentType);
    }
    
    final result = await db.query(
      'patient_outcome_metrics',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'current_date DESC',
    );
    
    return result.map((json) => PatientOutcomeMetrics.fromJson(json)).toList();
  }

  // Revenue Analytics
  Future<String> createRevenueAnalytics({
    required AnalyticsPeriod period,
    required double totalRevenue,
    required double recurringRevenue,
    required double oneTimeRevenue,
    required int totalSessions,
    required double revenueGrowth,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final db = await database;
    final revenueId = 'revenue_${DateTime.now().millisecondsSinceEpoch}';
    
    final averageSessionValue = totalSessions > 0 ? totalRevenue / totalSessions : 0;
    
    final revenue = RevenueAnalytics(
      id: revenueId,
      period: period,
      totalRevenue: totalRevenue,
      recurringRevenue: recurringRevenue,
      oneTimeRevenue: oneTimeRevenue,
      totalSessions: totalSessions,
      averageSessionValue: averageSessionValue,
      revenueGrowth: revenueGrowth,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    
    await db.insert('revenue_analytics', {
      ...revenue.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'analytics.revenue_create',
      details: 'Revenue analytics created: $revenueId',
      userId: 'system',
      resourceId: revenueId,
    );
    
    return revenueId;
  }

  Future<List<RevenueAnalytics>> getRevenueAnalytics({
    AnalyticsPeriod? period,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (period != null) {
      whereClause += ' AND period = ?';
      whereArgs.add(period.name);
    }
    
    final result = await db.query(
      'revenue_analytics',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'period_start DESC',
    );
    
    return result.map((json) => RevenueAnalytics.fromJson(json)).toList();
  }

  // Patient Retention Metrics
  Future<String> createPatientRetentionMetrics({
    required AnalyticsPeriod period,
    required int newPatients,
    required int retainedPatients,
    required int lostPatients,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final db = await database;
    final retentionId = 'retention_${DateTime.now().millisecondsSinceEpoch}';
    
    final totalPatients = newPatients + retainedPatients;
    final retentionRate = totalPatients > 0 ? (retainedPatients / totalPatients) * 100 : 0;
    final churnRate = totalPatients > 0 ? (lostPatients / totalPatients) * 100 : 0;
    final averageLifetimeValue = _calculateAverageLifetimeValue(periodStart, periodEnd);
    
    final retention = PatientRetentionMetrics(
      id: retentionId,
      period: period,
      newPatients: newPatients,
      retainedPatients: retainedPatients,
      lostPatients: lostPatients,
      retentionRate: retentionRate,
      churnRate: churnRate,
      averageLifetimeValue: averageLifetimeValue,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    
    await db.insert('patient_retention_metrics', {
      ...retention.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'analytics.retention_create',
      details: 'Patient retention metrics created: $retentionId',
      userId: 'system',
      resourceId: retentionId,
    );
    
    return retentionId;
  }

  double _calculateAverageLifetimeValue(DateTime periodStart, DateTime periodEnd) {
    // Mock calculation - in real app, this would be calculated from actual data
    final daysInPeriod = periodEnd.difference(periodStart).inDays;
    return daysInPeriod * 50.0; // Mock value
  }

  Future<List<PatientRetentionMetrics>> getPatientRetentionMetrics({
    AnalyticsPeriod? period,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (period != null) {
      whereClause += ' AND period = ?';
      whereArgs.add(period.name);
    }
    
    final result = await db.query(
      'patient_retention_metrics',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'period_start DESC',
    );
    
    return result.map((json) => PatientRetentionMetrics.fromJson(json)).toList();
  }

  // Analytics Dashboard
  Future<AnalyticsDashboard> generateAnalyticsDashboard({
    required String userId,
    required AnalyticsPeriod period,
  }) async {
    final dashboardId = 'dashboard_${DateTime.now().millisecondsSinceEpoch}';
    
    // Generate mock data for demonstration
    final kpis = await _generateMockKPIs(period);
    final trends = await _generateMockTrends(period);
    final revenue = await _generateMockRevenue(period);
    final retention = await _generateMockRetention(period);
    final patientOutcomes = await _generateMockPatientOutcomes();
    
    final dashboard = AnalyticsDashboard(
      id: dashboardId,
      userId: userId,
      kpis: kpis,
      trends: trends,
      revenue: revenue,
      retention: retention,
      patientOutcomes: patientOutcomes,
      generatedAt: DateTime.now(),
      period: period,
    );
    
    await AuditLogService().insertLog(
      action: 'analytics.dashboard_generate',
      details: 'Analytics dashboard generated: $dashboardId',
      userId: userId,
      resourceId: dashboardId,
    );
    
    return dashboard;
  }

  Future<List<ClinicalKPI>> _generateMockKPIs(AnalyticsPeriod period) async {
    final now = DateTime.now();
    final kpis = <ClinicalKPI>[];
    
    // Mock KPI data
    final metrics = [
      {'name': 'Toplam Seans', 'value': 150.0, 'target': 200.0},
      {'name': 'Hasta Memnuniyeti', 'value': 4.2, 'target': 4.5},
      {'name': 'Hasta Sadakat Oranı', 'value': 85.0, 'target': 90.0},
      {'name': 'Ortalama Seans Süresi', 'value': 45.0, 'target': 50.0},
    ];
    
    for (final metric in metrics) {
      final kpi = ClinicalKPI(
        id: 'kpi_${metric['name']}_${now.millisecondsSinceEpoch}',
        metricName: metric['name'] as String,
        value: metric['value'] as double,
        previousValue: (metric['value'] as double) * 0.9,
        targetValue: metric['target'] as double,
        period: period,
        date: now,
      );
      kpis.add(kpi);
    }
    
    return kpis;
  }

  Future<List<TrendAnalysis>> _generateMockTrends(AnalyticsPeriod period) async {
    final trends = <TrendAnalysis>[];
    final now = DateTime.now();
    
    // Mock trend data
    final metrics = [
      AnalyticsMetric.sessions,
      AnalyticsMetric.revenue,
      AnalyticsMetric.patients,
    ];
    
    for (final metric in metrics) {
      final dataPoints = _generateMockDataPoints(period);
      final trend = TrendAnalysis(
        id: 'trend_${metric.name}_${now.millisecondsSinceEpoch}',
        metric: metric,
        period: period,
        dataPoints: dataPoints,
        direction: _calculateTrendDirection(dataPoints),
        trendStrength: _calculateTrendStrength(dataPoints),
        interpretation: _generateTrendInterpretation(
          metric,
          _calculateTrendDirection(dataPoints),
          _calculateTrendStrength(dataPoints),
        ),
        analyzedAt: now,
      );
      trends.add(trend);
    }
    
    return trends;
  }

  List<DataPoint> _generateMockDataPoints(AnalyticsPeriod period) {
    final dataPoints = <DataPoint>[];
    final now = DateTime.now();
    
    int daysBack;
    switch (period) {
      case AnalyticsPeriod.daily:
        daysBack = 7;
        break;
      case AnalyticsPeriod.weekly:
        daysBack = 28;
        break;
      case AnalyticsPeriod.monthly:
        daysBack = 365;
        break;
      case AnalyticsPeriod.yearly:
        daysBack = 1095;
        break;
    }
    
    for (int i = daysBack; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final value = 100 + (Random().nextDouble() * 50) + (i * 0.1); // Mock trend
      dataPoints.add(DataPoint(date: date, value: value));
    }
    
    return dataPoints;
  }

  Future<RevenueAnalytics> _generateMockRevenue(AnalyticsPeriod period) async {
    final now = DateTime.now();
    final periodStart = _getPeriodStart(now, period);
    final periodEnd = now;
    
    return RevenueAnalytics(
      id: 'revenue_${now.millisecondsSinceEpoch}',
      period: period,
      totalRevenue: 15000.0,
      recurringRevenue: 12000.0,
      oneTimeRevenue: 3000.0,
      totalSessions: 150,
      averageSessionValue: 100.0,
      revenueGrowth: 15.5,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  Future<PatientRetentionMetrics> _generateMockRetention(AnalyticsPeriod period) async {
    final now = DateTime.now();
    final periodStart = _getPeriodStart(now, period);
    final periodEnd = now;
    
    return PatientRetentionMetrics(
      id: 'retention_${now.millisecondsSinceEpoch}',
      period: period,
      newPatients: 25,
      retainedPatients: 20,
      lostPatients: 5,
      retentionRate: 80.0,
      churnRate: 20.0,
      averageLifetimeValue: 2500.0,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  Future<List<PatientOutcomeMetrics>> _generateMockPatientOutcomes() async {
    final outcomes = <PatientOutcomeMetrics>[];
    final now = DateTime.now();
    
    // Mock patient outcomes
    for (int i = 0; i < 5; i++) {
      final outcome = PatientOutcomeMetrics(
        id: 'outcome_${i}_${now.millisecondsSinceEpoch}',
        patientId: 'patient_$i',
        assessmentType: 'PHQ-9',
        baselineScore: 15.0,
        currentScore: 8.0,
        improvementPercentage: 46.7,
        sessionsCompleted: 12,
        baselineDate: now.subtract(const Duration(days: 90)),
        currentDate: now,
        outcomeCategory: 'İyi',
      );
      outcomes.add(outcome);
    }
    
    return outcomes;
  }

  DateTime _getPeriodStart(DateTime now, AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return now.subtract(const Duration(days: 1));
      case AnalyticsPeriod.weekly:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.monthly:
        return now.subtract(const Duration(days: 30));
      case AnalyticsPeriod.yearly:
        return now.subtract(const Duration(days: 365));
    }
  }
}