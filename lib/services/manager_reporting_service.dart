import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manager_reporting_models.dart';

class ManagerReportingService {
  static final ManagerReportingService _instance = ManagerReportingService._internal();
  factory ManagerReportingService() => _instance;
  ManagerReportingService._internal();

  final List<ManagerReport> _reports = [];
  final List<DashboardWidget> _dashboardWidgets = [];
  final List<PerformanceMetric> _performanceMetrics = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadReports();
    await _loadDashboardWidgets();
    await _loadPerformanceMetrics();
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_reports.isEmpty) {
      await _loadDemoReports();
    }
    if (_dashboardWidgets.isEmpty) {
      await _loadDemoDashboardWidgets();
    }
    if (_performanceMetrics.isEmpty) {
      await _loadDemoPerformanceMetrics();
    }
  }

  // Load reports from storage
  Future<void> _loadReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getStringList('manager_reports') ?? [];
      _reports.clear();
      
      for (final reportJson in reportsJson) {
        final report = ManagerReport.fromJson(jsonDecode(reportJson));
        _reports.add(report);
      }
    } catch (e) {
      print('Error loading manager reports: $e');
      _reports.clear();
    }
  }

  // Save reports to storage
  Future<void> _saveReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = _reports
          .map((report) => jsonEncode(report.toJson()))
          .toList();
      await prefs.setStringList('manager_reports', reportsJson);
    } catch (e) {
      print('Error saving manager reports: $e');
    }
  }

  // Load dashboard widgets from storage
  Future<void> _loadDashboardWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetsJson = prefs.getStringList('manager_dashboard_widgets') ?? [];
      _dashboardWidgets.clear();
      
      for (final widgetJson in widgetsJson) {
        final widget = DashboardWidget.fromJson(jsonDecode(widgetJson));
        _dashboardWidgets.add(widget);
      }
    } catch (e) {
      print('Error loading dashboard widgets: $e');
      _dashboardWidgets.clear();
    }
  }

  // Save dashboard widgets to storage
  Future<void> _saveDashboardWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetsJson = _dashboardWidgets
          .map((widget) => jsonEncode(widget.toJson()))
          .toList();
      await prefs.setStringList('manager_dashboard_widgets', widgetsJson);
    } catch (e) {
      print('Error saving dashboard widgets: $e');
    }
  }

  // Load performance metrics from storage
  Future<void> _loadPerformanceMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getStringList('manager_performance_metrics') ?? [];
      _performanceMetrics.clear();
      
      for (final metricJson in metricsJson) {
        final metric = PerformanceMetric.fromJson(jsonDecode(metricJson));
        _performanceMetrics.add(metric);
      }
    } catch (e) {
      print('Error loading performance metrics: $e');
      _performanceMetrics.clear();
    }
  }

  // Save performance metrics to storage
  Future<void> _savePerformanceMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = _performanceMetrics
          .map((metric) => jsonEncode(metric.toJson()))
          .toList();
      await prefs.setStringList('manager_performance_metrics', metricsJson);
    } catch (e) {
      print('Error saving performance metrics: $e');
    }
  }

  // Create report
  Future<ManagerReport> createReport({
    required String title,
    required String description,
    required ReportType type,
    required ReportFrequency frequency,
    required String createdBy,
    Map<String, dynamic>? parameters,
    String? notes,
  }) async {
    final report = ManagerReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      frequency: frequency,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      parameters: parameters ?? {},
      notes: notes,
    );

    _reports.add(report);
    await _saveReports();

    return report;
  }

  // Generate report
  Future<bool> generateReport(String reportId, String generatedBy) async {
    try {
      final index = _reports.indexWhere((report) => report.id == reportId);
      if (index == -1) return false;

      final report = _reports[index];
      final generatedData = await _generateReportData(report);
      final metrics = await _calculateMetrics(report);
      final charts = await _generateCharts(report, generatedData);

      _reports[index] = report.copyWith(
        status: ReportStatus.generated,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        data: generatedData,
        metrics: metrics,
        charts: charts,
      );

      await _saveReports();
      return true;
    } catch (e) {
      print('Error generating report: $e');
      return false;
    }
  }

  // Publish report
  Future<bool> publishReport(String reportId, String filePath) async {
    try {
      final index = _reports.indexWhere((report) => report.id == reportId);
      if (index == -1) return false;

      _reports[index] = _reports[index].copyWith(
        status: ReportStatus.published,
        publishedAt: DateTime.now(),
        filePath: filePath,
      );

      await _saveReports();
      return true;
    } catch (e) {
      print('Error publishing report: $e');
      return false;
    }
  }

  // Archive report
  Future<bool> archiveReport(String reportId) async {
    try {
      final index = _reports.indexWhere((report) => report.id == reportId);
      if (index == -1) return false;

      _reports[index] = _reports[index].copyWith(
        status: ReportStatus.archived,
      );

      await _saveReports();
      return true;
    } catch (e) {
      print('Error archiving report: $e');
      return false;
    }
  }

  // Generate report data based on type
  Future<Map<String, dynamic>> _generateReportData(ManagerReport report) async {
    switch (report.type) {
      case ReportType.financial:
        return await _generateFinancialData(report);
      case ReportType.patient:
        return await _generatePatientData(report);
      case ReportType.staff:
        return await _generateStaffData(report);
      case ReportType.system:
        return await _generateSystemData(report);
      case ReportType.performance:
        return await _generatePerformanceData(report);
      case ReportType.compliance:
        return await _generateComplianceData(report);
      case ReportType.custom:
        return await _generateCustomData(report);
    }
  }

  // Generate financial data
  Future<Map<String, dynamic>> _generateFinancialData(ManagerReport report) async {
    return {
      'totalRevenue': 125000.0,
      'totalExpenses': 85000.0,
      'netProfit': 40000.0,
      'revenueByMonth': {
        'Ocak': 12000.0,
        'Şubat': 13500.0,
        'Mart': 11800.0,
        'Nisan': 14200.0,
        'Mayıs': 15600.0,
        'Haziran': 13800.0,
      },
      'expenseCategories': {
        'Personel': 45000.0,
        'Kira': 12000.0,
        'Ekipman': 8000.0,
        'İlaç': 15000.0,
        'Diğer': 5000.0,
      },
      'profitMargin': 32.0,
      'growthRate': 12.5,
    };
  }

  // Generate patient data
  Future<Map<String, dynamic>> _generatePatientData(ManagerReport report) async {
    return {
      'totalPatients': 1250,
      'newPatients': 85,
      'activePatients': 980,
      'dischargedPatients': 45,
      'patientSatisfaction': 4.2,
      'averageSessionDuration': 45.0,
      'noShowRate': 8.5,
      'patientDemographics': {
        'ageGroups': {
          '18-25': 180,
          '26-35': 320,
          '36-45': 280,
          '46-55': 200,
          '56-65': 150,
          '65+': 120,
        },
        'gender': {
          'Kadın': 720,
          'Erkek': 530,
        },
      },
      'diagnosisDistribution': {
        'Depresyon': 320,
        'Anksiyete': 280,
        'Bipolar': 150,
        'Şizofreni': 80,
        'Diğer': 420,
      },
    };
  }

  // Generate staff data
  Future<Map<String, dynamic>> _generateStaffData(ManagerReport report) async {
    return {
      'totalStaff': 25,
      'doctors': 8,
      'psychologists': 6,
      'nurses': 4,
      'secretaries': 3,
      'managers': 2,
      'other': 2,
      'staffSatisfaction': 4.1,
      'averageWorkload': 85.0,
      'overtimeHours': 120.0,
      'staffTurnover': 5.0,
      'trainingHours': 240.0,
      'performanceScores': {
        'Mükemmel': 8,
        'İyi': 12,
        'Orta': 4,
        'Zayıf': 1,
      },
    };
  }

  // Generate system data
  Future<Map<String, dynamic>> _generateSystemData(ManagerReport report) async {
    return {
      'systemUptime': 99.5,
      'averageResponseTime': 1.2,
      'totalUsers': 45,
      'activeUsers': 38,
      'dataStorage': 2.5,
      'backupStatus': 'Başarılı',
      'securityIncidents': 0,
      'systemUpdates': 3,
      'featureUsage': {
        'Randevu Yönetimi': 95.0,
        'Hasta Kayıtları': 88.0,
        'İlaç Takibi': 72.0,
        'Raporlama': 65.0,
        'AI Tanı': 58.0,
      },
    };
  }

  // Generate performance data
  Future<Map<String, dynamic>> _generatePerformanceData(ManagerReport report) async {
    return {
      'overallPerformance': 87.5,
      'patientOutcomes': 82.0,
      'staffEfficiency': 91.0,
      'systemReliability': 95.0,
      'financialPerformance': 78.0,
      'complianceScore': 96.0,
      'keyPerformanceIndicators': {
        'Hasta Memnuniyeti': 4.2,
        'Personel Memnuniyeti': 4.1,
        'Sistem Güvenilirliği': 99.5,
        'Mali Performans': 78.0,
        'Uyumluluk': 96.0,
      },
    };
  }

  // Generate compliance data
  Future<Map<String, dynamic>> _generateComplianceData(ManagerReport report) async {
    return {
      'kvkkCompliance': 98.0,
      'hipaaCompliance': 95.0,
      'gdprCompliance': 97.0,
      'auditResults': 'Başarılı',
      'lastAuditDate': '2024-01-15',
      'nextAuditDate': '2024-07-15',
      'complianceIssues': 2,
      'resolvedIssues': 2,
      'pendingIssues': 0,
      'complianceTraining': {
        'completed': 45,
        'pending': 3,
        'completionRate': 93.8,
      },
    };
  }

  // Generate custom data
  Future<Map<String, dynamic>> _generateCustomData(ManagerReport report) async {
    return {
      'customMetric1': 150.0,
      'customMetric2': 75.5,
      'customMetric3': 200.0,
      'customData': report.parameters,
    };
  }

  // Calculate metrics
  Future<List<ReportMetric>> _calculateMetrics(ManagerReport report) async {
    final data = report.data;
    final metrics = <ReportMetric>[];

    switch (report.type) {
      case ReportType.financial:
        metrics.addAll([
          ReportMetric(
            id: 'revenue_metric',
            name: 'Toplam Gelir',
            description: 'Aylık toplam gelir',
            type: MetricType.sum,
            value: data['totalRevenue'],
            unit: 'TL',
            calculatedAt: DateTime.now(),
          ),
          ReportMetric(
            id: 'profit_margin_metric',
            name: 'Kar Marjı',
            description: 'Net kar marjı yüzdesi',
            type: MetricType.percentage,
            value: data['profitMargin'],
            unit: '%',
            calculatedAt: DateTime.now(),
          ),
        ]);
        break;
      case ReportType.patient:
        metrics.addAll([
          ReportMetric(
            id: 'total_patients_metric',
            name: 'Toplam Hasta',
            description: 'Toplam hasta sayısı',
            type: MetricType.count,
            value: data['totalPatients'],
            unit: 'kişi',
            calculatedAt: DateTime.now(),
          ),
          ReportMetric(
            id: 'satisfaction_metric',
            name: 'Hasta Memnuniyeti',
            description: 'Ortalama hasta memnuniyet puanı',
            type: MetricType.average,
            value: data['patientSatisfaction'],
            unit: '/5',
            calculatedAt: DateTime.now(),
          ),
        ]);
        break;
      case ReportType.staff: // Eksik case eklendi
        metrics.addAll([
          ReportMetric(
            id: 'total_staff_metric',
            name: 'Toplam Personel',
            description: 'Toplam personel sayısı',
            type: MetricType.count,
            value: data['totalStaff'],
            unit: 'kişi',
            calculatedAt: DateTime.now(),
          ),
          ReportMetric(
            id: 'staff_satisfaction_metric',
            name: 'Personel Memnuniyeti',
            description: 'Ortalama personel memnuniyet puanı',
            type: MetricType.average,
            value: data['staffSatisfaction'],
            unit: '/5',
            calculatedAt: DateTime.now(),
          ),
        ]);
        break;
      case ReportType.system: // Eksik case eklendi
        metrics.addAll([
          ReportMetric(
            id: 'system_uptime_metric',
            name: 'Sistem Çalışma Süresi',
            description: 'Sistemin çalışma süresi yüzdesi',
            type: MetricType.percentage,
            value: data['systemUptime'],
            unit: '%',
            calculatedAt: DateTime.now(),
          ),
          ReportMetric(
            id: 'error_rate_metric',
            name: 'Hata Oranı',
            description: 'Sistem hata oranı',
            type: MetricType.percentage,
            value: data['errorRate'],
            unit: '%',
            calculatedAt: DateTime.now(),
          ),
        ]);
        break;
      case ReportType.performance:
        metrics.addAll([
          ReportMetric(
            id: 'performance_metric',
            name: 'Genel Performans',
            description: 'Sistem performans skoru',
            type: MetricType.average,
            value: data['performanceScore'] ?? 85.0,
            unit: '/100',
            calculatedAt: DateTime.now(),
          ),
        ]);
        break;
      case ReportType.compliance:
        metrics.addAll([
          ReportMetric(
            id: 'compliance_metric',
            name: 'Uyumluluk Skoru',
            description: 'Regülasyonlara uyum skoru',
            type: MetricType.percentage,
            value: data['complianceScore'] ?? 95.0,
            unit: '%',
            calculatedAt: DateTime.now(),
          ),
        ]);
        break;
      case ReportType.custom:
        // Custom report metrics handled dynamically
        break;
    }
    
    return metrics;
  }

  // Generate charts
  Future<List<ReportChart>> _generateCharts(ManagerReport report, Map<String, dynamic> data) async {
    final charts = <ReportChart>[];

    switch (report.type) {
      case ReportType.financial:
        charts.add(ReportChart(
          id: 'revenue_chart',
          title: 'Aylık Gelir Trendi',
          chartType: 'line',
          data: {
            'labels': data['revenueByMonth'].keys.toList(),
            'datasets': [
              {
                'label': 'Gelir',
                'data': data['revenueByMonth'].values.toList(),
              }
            ]
          },
          options: {
            'responsive': true,
            'scales': {
              'y': {'beginAtZero': true}
            }
          },
          createdAt: DateTime.now(),
        ));
        break;
      case ReportType.patient:
        charts.add(ReportChart(
          id: 'diagnosis_chart',
          title: 'Tanı Dağılımı',
          chartType: 'pie',
          data: {
            'labels': data['diagnosisDistribution'].keys.toList(),
            'datasets': [
              {
                'data': data['diagnosisDistribution'].values.toList(),
              }
            ]
          },
          options: {
            'responsive': true,
          },
          createdAt: DateTime.now(),
        ));
        break;
      case ReportType.staff: // Eksik case eklendi
        charts.add(ReportChart(
          id: 'staff_chart',
          title: 'Personel Dağılımı',
          chartType: 'bar',
          data: {
            'labels': data['staffDistribution'].keys.toList(),
            'datasets': [
              {
                'label': 'Personel Sayısı',
                'data': data['staffDistribution'].values.toList(),
              }
            ]
          },
          options: {
            'responsive': true,
            'scales': {
              'y': {'beginAtZero': true}
            }
          },
          createdAt: DateTime.now(),
        ));
        break;
      case ReportType.system: // Eksik case eklendi
        charts.add(ReportChart(
          id: 'system_chart',
          title: 'Sistem Performansı',
          chartType: 'line',
          data: {
            'labels': data['systemMetrics'].keys.toList(),
            'datasets': [
              {
                'label': 'Performans',
                'data': data['systemMetrics'].values.toList(),
              }
            ]
          },
          options: {
            'responsive': true,
            'scales': {
              'y': {'beginAtZero': true}
            }
          },
          createdAt: DateTime.now(),
        ));
        break;
      case ReportType.performance:
        charts.add(ReportChart(
          id: 'performance_chart',
          title: 'Performans Grafiği',
          chartType: 'line',
          data: {
            'labels': ['Ocak', 'Şubat', 'Mart', 'Nisan'],
            'datasets': [{'label': 'Performans', 'data': [80, 85, 90, 85]}]
          },
          options: {'responsive': true},
          createdAt: DateTime.now(),
        ));
        break;
      case ReportType.compliance:
        charts.add(ReportChart(
          id: 'compliance_chart',
          title: 'Uyumluluk Grafiği',
          chartType: 'bar',
          data: {
            'labels': ['KVKK', 'ISO', 'HIPAA'],
            'datasets': [{'label': 'Uyum', 'data': [95, 92, 98]}]
          },
          options: {'responsive': true},
          createdAt: DateTime.now(),
        ));
        break;
      case ReportType.custom:
        // Custom charts handled dynamically
        break;
    }
    
    return charts;
  }

  // Add dashboard widget
  Future<DashboardWidget> addDashboardWidget({
    required String title,
    required String widgetType,
    required Map<String, dynamic> configuration,
    required String createdBy,
  }) async {
    final widget = DashboardWidget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      widgetType: widgetType,
      configuration: configuration,
      position: _dashboardWidgets.length,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _dashboardWidgets.add(widget);
    await _saveDashboardWidgets();

    return widget;
  }

  // Update dashboard widget
  Future<bool> updateDashboardWidget(DashboardWidget updatedWidget) async {
    try {
      final index = _dashboardWidgets.indexWhere((widget) => widget.id == updatedWidget.id);
      if (index == -1) return false;

      _dashboardWidgets[index] = updatedWidget;
      await _saveDashboardWidgets();

      return true;
    } catch (e) {
      print('Error updating dashboard widget: $e');
      return false;
    }
  }

  // Remove dashboard widget
  Future<bool> removeDashboardWidget(String widgetId) async {
    try {
      final index = _dashboardWidgets.indexWhere((widget) => widget.id == widgetId);
      if (index == -1) return false;

      _dashboardWidgets.removeAt(index);
      await _saveDashboardWidgets();

      return true;
    } catch (e) {
      print('Error removing dashboard widget: $e');
      return false;
    }
  }

  // Add performance metric
  Future<PerformanceMetric> addPerformanceMetric({
    required String name,
    required String description,
    required String category,
    required dynamic currentValue,
    required dynamic previousValue,
    required dynamic targetValue,
    required String unit,
  }) async {
    final metric = PerformanceMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      category: category,
      currentValue: currentValue,
      previousValue: previousValue,
      targetValue: targetValue,
      unit: unit,
      calculatedAt: DateTime.now(),
    );

    _performanceMetrics.add(metric);
    await _savePerformanceMetrics();

    return metric;
  }

  // Get reports by type
  List<ManagerReport> getReportsByType(ReportType type) {
    return _reports
        .where((report) => report.type == type)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get reports by status
  List<ManagerReport> getReportsByStatus(ReportStatus status) {
    return _reports
        .where((report) => report.status == status)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get active dashboard widgets
  List<DashboardWidget> getActiveDashboardWidgets() {
    return _dashboardWidgets
        .where((widget) => widget.isVisible)
        .toList()
        ..sort((a, b) => a.position.compareTo(b.position));
  }

  // Get performance metrics by category
  List<PerformanceMetric> getPerformanceMetricsByCategory(String category) {
    return _performanceMetrics
        .where((metric) => metric.category == category)
        .toList()
        ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalReports = _reports.length;
    final draftReports = _reports.where((r) => r.status == ReportStatus.draft).length;
    final generatedReports = _reports.where((r) => r.status == ReportStatus.generated).length;
    final publishedReports = _reports.where((r) => r.status == ReportStatus.published).length;
    final archivedReports = _reports.where((r) => r.status == ReportStatus.archived).length;

    final totalWidgets = _dashboardWidgets.length;
    final activeWidgets = _dashboardWidgets.where((w) => w.isVisible).length;

    final totalMetrics = _performanceMetrics.length;
    final categories = _performanceMetrics.map((m) => m.category).toSet().length;

    return {
      'totalReports': totalReports,
      'draftReports': draftReports,
      'generatedReports': generatedReports,
      'publishedReports': publishedReports,
      'archivedReports': archivedReports,
      'totalWidgets': totalWidgets,
      'activeWidgets': activeWidgets,
      'totalMetrics': totalMetrics,
      'categories': categories,
    };
  }

  // Load demo reports
  Future<void> _loadDemoReports() async {
    // Demo reports implementation
    // Add your demo reports here if needed
  }

  // Load demo dashboard widgets
  Future<void> _loadDemoDashboardWidgets() async {
    // Add demo dashboard widgets
    final demoWidgets = [
      DashboardWidget(
        id: 'widget_001',
        title: 'Finansal Özet',
        widgetType: 'financial_summary',
        configuration: {
          'showRevenue': true,
          'showExpenses': true,
          'showProfit': true,
        },
        position: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'manager_001',
      ),
      DashboardWidget(
        id: 'widget_002',
        title: 'Hasta İstatistikleri',
        widgetType: 'patient_stats',
        configuration: {
          'showTotalPatients': true,
          'showNewPatients': true,
          'showSatisfaction': true,
        },
        position: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        createdBy: 'manager_001',
      ),
      DashboardWidget(
        id: 'widget_003',
        title: 'Sistem Durumu',
        widgetType: 'system_status',
        configuration: {
          'showUptime': true,
          'showUsers': true,
          'showPerformance': true,
        },
        position: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        createdBy: 'manager_001',
      ),
    ];

    for (final widget in demoWidgets) {
      _dashboardWidgets.add(widget);
    }

    await _saveDashboardWidgets();
  }

  // Load demo performance metrics
  Future<void> _loadDemoPerformanceMetrics() async {
    // Add demo performance metrics
    final demoMetrics = [
      PerformanceMetric(
        id: 'metric_001',
        name: 'Hasta Memnuniyeti',
        description: 'Ortalama hasta memnuniyet puanı',
        category: 'Hasta',
        currentValue: 4.2,
        previousValue: 4.1,
        targetValue: 4.5,
        unit: '/5',
        calculatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PerformanceMetric(
        id: 'metric_002',
        name: 'Personel Memnuniyeti',
        description: 'Ortalama personel memnuniyet puanı',
        category: 'Personel',
        currentValue: 4.1,
        previousValue: 4.0,
        targetValue: 4.3,
        unit: '/5',
        calculatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PerformanceMetric(
        id: 'metric_003',
        name: 'Sistem Güvenilirliği',
        description: 'Sistem çalışma süresi yüzdesi',
        category: 'Sistem',
        currentValue: 99.5,
        previousValue: 99.2,
        targetValue: 99.8,
        unit: '%',
        calculatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    for (final metric in demoMetrics) {
      _performanceMetrics.add(metric);
    }

    await _savePerformanceMetrics();
  }
}
