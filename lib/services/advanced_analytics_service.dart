import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/advanced_analytics_models.dart';

/// Advanced Analytics Service - Kullanıcı dostu analitik servisi
class AdvancedAnalyticsService {
  static const String _baseUrl = 'https://api.analytics.psyclinicai.com/v1';
  static const String _apiKey = 'demo_key_12345';

  // Cache for analytics data
  final Map<String, AnalyticsDashboard> _dashboardsCache = {};
  final Map<String, FinancialAnalytics> _financialCache = {};
  final Map<String, PatientAnalytics> _patientCache = {};
  final Map<String, OperationalAnalytics> _operationalCache = {};
  final Map<String, QualityAnalytics> _qualityCache = {};
  final Map<String, StaffAnalytics> _staffCache = {};

  // Stream controllers for real-time updates
  final StreamController<AnalyticsDashboard> _dashboardController =
      StreamController<AnalyticsDashboard>.broadcast();
  final StreamController<Map<String, dynamic>> _metricsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _insightController =
      StreamController<String>.broadcast();

  // Quick actions and smart filters
  final List<QuickAction> _quickActions = [];
  final List<SmartFilter> _smartFilters = [];

  /// Get stream for dashboard updates
  Stream<AnalyticsDashboard> get dashboardStream => _dashboardController.stream;

  /// Get stream for metrics updates
  Stream<Map<String, dynamic>> get metricsStream => _metricsController.stream;

  /// Get stream for insights
  Stream<String> get insightStream => _insightController.stream;

  /// Initialize analytics service
  Future<void> initialize() async {
    await _loadDefaultDashboards();
    await _setupQuickActions();
    await _setupSmartFilters();
  }

  /// Get overview dashboard - Tek tıkla genel bakış
  Future<AnalyticsDashboard> getOverviewDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboards/overview'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dashboard = AnalyticsDashboard.fromJson(data);
        _dashboardsCache[dashboard.id] = dashboard;
        return dashboard;
      } else {
        throw Exception('Failed to load overview dashboard: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock overview dashboard for demo purposes
      return _createMockOverviewDashboard();
    }
  }

  /// Get financial dashboard - Tek tıkla finansal analiz
  Future<AnalyticsDashboard> getFinancialDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboards/financial'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dashboard = AnalyticsDashboard.fromJson(data);
        _dashboardsCache[dashboard.id] = dashboard;
        return dashboard;
      } else {
        throw Exception('Failed to load financial dashboard: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock financial dashboard for demo purposes
      return _createMockFinancialDashboard();
    }
  }

  /// Get patient dashboard - Tek tıkla hasta analizi
  Future<AnalyticsDashboard> getPatientDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboards/patients'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dashboard = AnalyticsDashboard.fromJson(data);
        _dashboardsCache[dashboard.id] = dashboard;
        return dashboard;
      } else {
        throw Exception('Failed to load patient dashboard: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock patient dashboard for demo purposes
      return _createMockPatientDashboard();
    }
  }

  /// Get operational dashboard - Tek tıkla operasyonel analiz
  Future<AnalyticsDashboard> getOperationalDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboards/operations'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dashboard = AnalyticsDashboard.fromJson(data);
        _dashboardsCache[dashboard.id] = dashboard;
        return dashboard;
      } else {
        throw Exception('Failed to load operational dashboard: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock operational dashboard for demo purposes
      return _createMockOperationalDashboard();
    }
  }

  /// Get quality dashboard - Tek tıkla kalite analizi
  Future<AnalyticsDashboard> getQualityDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboards/quality'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dashboard = AnalyticsDashboard.fromJson(data);
        _dashboardsCache[dashboard.id] = dashboard;
        return dashboard;
      } else {
        throw Exception('Failed to load quality dashboard: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock quality dashboard for demo purposes
      return _createMockQualityDashboard();
    }
  }

  /// Get staff dashboard - Tek tıkla personel analizi
  Future<AnalyticsDashboard> getStaffDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboards/staff'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dashboard = AnalyticsDashboard.fromJson(data);
        _dashboardsCache[dashboard.id] = dashboard;
        return dashboard;
      } else {
        throw Exception('Failed to load staff dashboard: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock staff dashboard for demo purposes
      return _createMockStaffDashboard();
    }
  }

  /// Generate quick report - Tek tıkla rapor oluştur
  Future<AnalyticsReport> generateQuickReport({
    required DashboardType dashboardType,
    required TimePeriod timePeriod,
    String? customName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reports/generate'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'dashboard_type': dashboardType.name,
          'time_period': timePeriod.name,
          'custom_name': customName,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return AnalyticsReport.fromJson(data);
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock report for demo purposes
      return _createMockReport(dashboardType, timePeriod, customName);
    }
  }

  /// Get quick actions - Hızlı işlemler
  List<QuickAction> getQuickActions() {
    return List.unmodifiable(_quickActions);
  }

  /// Get smart filters - Akıllı filtreler
  List<SmartFilter> getSmartFilters() {
    return List.unmodifiable(_smartFilters);
  }

  /// Apply smart filter - Akıllı filtre uygula
  Future<List<Map<String, dynamic>>> applySmartFilter({
    required String filterId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final filter = _smartFilters.firstWhere((f) => f.id == filterId);
      if (!filter.isActive) {
        return [data];
      }

      // Apply filter logic
      final filteredData = _applyFilterLogic(filter, data);
      return filteredData;
    } catch (e) {
      return [data];
    }
  }

  /// Get predictive insights - AI destekli öngörüler
  Future<List<String>> getPredictiveInsights({
    required DashboardType dashboardType,
    required TimePeriod timePeriod,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/insights/predictive').replace(queryParameters: {
          'dashboard_type': dashboardType.name,
          'time_period': timePeriod.name,
        }),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['insights']);
      } else {
        throw Exception('Failed to load predictive insights: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock insights for demo purposes
      return _generateMockInsights(dashboardType, timePeriod);
    }
  }

  /// Export data - Veri dışa aktar
  Future<String> exportData({
    required DashboardType dashboardType,
    required TimePeriod timePeriod,
    required String format, // 'pdf', 'excel', 'csv'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/export'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'dashboard_type': dashboardType.name,
          'time_period': timePeriod.name,
          'format': format,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['download_url'];
      } else {
        throw Exception('Failed to export data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock export URL for demo purposes
      return 'https://export.psyclinicai.com/mock_export_${dashboardType.name}_${timePeriod.name}.$format';
    }
  }

  /// Dispose resources
  void dispose() {
    if (!_dashboardController.isClosed) {
      _dashboardController.close();
    }
    if (!_metricsController.isClosed) {
      _metricsController.close();
    }
    if (!_insightController.isClosed) {
      _insightController.close();
    }
  }

  // Private helper methods
  Future<void> _loadDefaultDashboards() async {
    // Load default dashboards
    final overviewDashboard = _createMockOverviewDashboard();
    final financialDashboard = _createMockFinancialDashboard();
    final patientDashboard = _createMockPatientDashboard();
    final operationalDashboard = _createMockOperationalDashboard();
    final qualityDashboard = _createMockQualityDashboard();
    final staffDashboard = _createMockStaffDashboard();

    _dashboardsCache[overviewDashboard.id] = overviewDashboard;
    _dashboardsCache[financialDashboard.id] = financialDashboard;
    _dashboardsCache[patientDashboard.id] = patientDashboard;
    _dashboardsCache[operationalDashboard.id] = operationalDashboard;
    _dashboardsCache[qualityDashboard.id] = qualityDashboard;
    _dashboardsCache[staffDashboard.id] = staffDashboard;
  }

  Future<void> _setupQuickActions() async {
    _quickActions.addAll([
      QuickAction(
        id: 'quick_overview',
        name: 'Genel Bakış',
        description: 'Tüm önemli metrikleri tek tıkla görüntüle',
        icon: '📊',
        action: 'show_overview',
        parameters: {'dashboard_type': 'overview'},
        isEnabled: true,
        priority: PriorityLevel.high,
        metadata: {},
      ),
      QuickAction(
        id: 'quick_financial',
        name: 'Finansal Durum',
        description: 'Gelir, maliyet ve karlılık analizi',
        icon: '💰',
        action: 'show_financial',
        parameters: {'dashboard_type': 'financial'},
        isEnabled: true,
        priority: PriorityLevel.high,
        metadata: {},
      ),
      QuickAction(
        id: 'quick_patients',
        name: 'Hasta Analizi',
        description: 'Hasta sayıları ve memnuniyet oranları',
        icon: '👥',
        action: 'show_patients',
        parameters: {'dashboard_type': 'patients'},
        isEnabled: true,
        priority: PriorityLevel.medium,
        metadata: {},
      ),
      QuickAction(
        id: 'quick_report',
        name: 'Hızlı Rapor',
        description: 'Seçilen kategoride hızlı rapor oluştur',
        icon: '📋',
        action: 'generate_report',
        parameters: {'time_period': 'month'},
        isEnabled: true,
        priority: PriorityLevel.medium,
        metadata: {},
      ),
      QuickAction(
        id: 'quick_export',
        name: 'Veri Dışa Aktar',
        description: 'Analitik verilerini PDF/Excel olarak indir',
        icon: '📥',
        action: 'export_data',
        parameters: {'format': 'pdf'},
        isEnabled: true,
        priority: PriorityLevel.low,
        metadata: {},
      ),
    ]);
  }

  Future<void> _setupSmartFilters() async {
    _smartFilters.addAll([
      SmartFilter(
        id: 'filter_time',
        name: 'Zaman Filtresi',
        description: 'Tarih aralığına göre filtrele',
        field: 'date',
        operator: 'between',
        value: 'last_30_days',
        isActive: true,
        priority: PriorityLevel.high,
        metadata: {},
      ),
      SmartFilter(
        id: 'filter_priority',
        name: 'Öncelik Filtresi',
        description: 'Öncelik seviyesine göre filtrele',
        field: 'priority',
        operator: 'equals',
        value: 'high',
        isActive: true,
        priority: PriorityLevel.medium,
        metadata: {},
      ),
      SmartFilter(
        id: 'filter_category',
        name: 'Kategori Filtresi',
        description: 'Kategoriye göre filtrele',
        field: 'category',
        operator: 'in',
        value: ['financial', 'operational'],
        isActive: true,
        priority: PriorityLevel.medium,
        metadata: {},
      ),
    ]);
  }

  List<Map<String, dynamic>> _applyFilterLogic(
    SmartFilter filter,
    Map<String, dynamic> data,
  ) {
    // Simple filter logic for demo purposes
    if (filter.field == 'priority' && filter.operator == 'equals') {
      return [data];
    }
    return [data];
  }

  List<String> _generateMockInsights(
    DashboardType dashboardType,
    TimePeriod timePeriod,
  ) {
    final insights = <String>[];
    
    switch (dashboardType) {
      case DashboardType.financial:
        insights.addAll([
          '💰 Gelir bu ay %15 arttı',
          '📈 Karlılık oranı hedefin üzerinde',
          '⚠️ Operasyonel maliyetler kontrol altında',
        ]);
        break;
      case DashboardType.patients:
        insights.addAll([
          '👥 Yeni hasta kayıtları %20 arttı',
          '⭐ Hasta memnuniyeti %95 seviyesinde',
          '📊 Tedavi başarı oranı yükseliyor',
        ]);
        break;
      case DashboardType.operations:
        insights.addAll([
          '⚡ Operasyonel verimlilik %12 arttı',
          '🕒 Ortalama seans süresi optimize edildi',
          '📋 Kaynak kullanımı dengeli',
        ]);
        break;
      default:
        insights.addAll([
          '📊 Genel performans iyi gidiyor',
          '🎯 Hedeflere ulaşım yolunda',
          '💡 İyileştirme alanları tespit edildi',
        ]);
    }
    
    return insights;
  }

  AnalyticsReport _createMockReport(
    DashboardType dashboardType,
    TimePeriod timePeriod,
    String? customName,
  ) {
    return AnalyticsReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      name: customName ?? '${dashboardType.name} Raporu',
      description: '${dashboardType.name} kategorisinde ${timePeriod.name} raporu',
      dashboardType: dashboardType,
      timePeriod: timePeriod,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      data: {'mock_data': true},
      insights: _generateMockInsights(dashboardType, timePeriod),
      recommendations: [
        'Veri kalitesini artırın',
        'Düzenli raporlama yapın',
        'Trend analizlerini takip edin',
      ],
      metadata: {},
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Mock dashboard creators
  AnalyticsDashboard _createMockOverviewDashboard() {
    return AnalyticsDashboard(
      id: 'overview_dashboard',
      name: 'Genel Bakış',
      description: 'Tüm önemli metrikleri tek yerde görüntüle',
      type: DashboardType.overview,
      widgets: _createMockOverviewWidgets(),
      settings: {'refresh_interval': 300, 'auto_refresh': true},
      isDefault: true,
      isPublic: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  AnalyticsDashboard _createMockFinancialDashboard() {
    return AnalyticsDashboard(
      id: 'financial_dashboard',
      name: 'Finansal Analiz',
      description: 'Gelir, maliyet ve karlılık analizi',
      type: DashboardType.financial,
      widgets: _createMockFinancialWidgets(),
      settings: {'refresh_interval': 600, 'auto_refresh': true},
      isDefault: false,
      isPublic: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  AnalyticsDashboard _createMockPatientDashboard() {
    return AnalyticsDashboard(
      id: 'patient_dashboard',
      name: 'Hasta Analizi',
      description: 'Hasta sayıları ve memnuniyet oranları',
      type: DashboardType.patients,
      widgets: _createMockPatientWidgets(),
      settings: {'refresh_interval': 900, 'auto_refresh': true},
      isDefault: false,
      isPublic: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  AnalyticsDashboard _createMockOperationalDashboard() {
    return AnalyticsDashboard(
      id: 'operational_dashboard',
      name: 'Operasyonel Analiz',
      description: 'Verimlilik ve kaynak kullanımı',
      type: DashboardType.operations,
      widgets: _createMockOperationalWidgets(),
      settings: {'refresh_interval': 1200, 'auto_refresh': true},
      isDefault: false,
      isPublic: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  AnalyticsDashboard _createMockQualityDashboard() {
    return AnalyticsDashboard(
      id: 'quality_dashboard',
      name: 'Kalite Analizi',
      description: 'Tedavi kalitesi ve hasta sonuçları',
      type: DashboardType.quality,
      widgets: _createMockQualityWidgets(),
      settings: {'refresh_interval': 1800, 'auto_refresh': true},
      isDefault: false,
      isPublic: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  AnalyticsDashboard _createMockStaffDashboard() {
    return AnalyticsDashboard(
      id: 'staff_dashboard',
      name: 'Personel Analizi',
      description: 'Personel performansı ve eğitim durumu',
      type: DashboardType.staff,
      widgets: _createMockStaffWidgets(),
      settings: {'refresh_interval': 2400, 'auto_refresh': true},
      isDefault: false,
      isPublic: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Mock widget creators
  List<DashboardWidget> _createMockOverviewWidgets() {
    return [
      DashboardWidget(
        id: 'overview_revenue',
        name: 'Toplam Gelir',
        description: 'Bu ay toplam gelir',
        visualizationType: VisualizationType.gauge,
        data: {'value': 125000, 'target': 150000, 'unit': 'TL'},
        configuration: {'color': 'green', 'size': 'large'},
        positionX: 0,
        positionY: 0,
        width: 4,
        height: 3,
        isVisible: true,
        isRefreshable: true,
        refreshInterval: 300,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DashboardWidget(
        id: 'overview_patients',
        name: 'Aktif Hastalar',
        description: 'Şu anda aktif hasta sayısı',
        visualizationType: VisualizationType.trend,
        data: {'value': 45, 'change': 5, 'trend': 'up'},
        configuration: {'color': 'blue', 'size': 'medium'},
        positionX: 4,
        positionY: 0,
        width: 4,
        height: 3,
        isVisible: true,
        isRefreshable: true,
        refreshInterval: 300,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<DashboardWidget> _createMockFinancialWidgets() {
    return [
      DashboardWidget(
        id: 'financial_profit',
        name: 'Net Kar',
        description: 'Bu ay net kar',
        visualizationType: VisualizationType.bar,
        data: {'value': 35000, 'previous': 28000, 'unit': 'TL'},
        configuration: {'color': 'green', 'size': 'large'},
        positionX: 0,
        positionY: 0,
        width: 6,
        height: 4,
        isVisible: true,
        isRefreshable: true,
        refreshInterval: 600,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<DashboardWidget> _createMockPatientWidgets() {
    return [
      DashboardWidget(
        id: 'patient_satisfaction',
        name: 'Hasta Memnuniyeti',
        description: 'Genel hasta memnuniyet oranı',
        visualizationType: VisualizationType.pie,
        data: {'satisfied': 85, 'neutral': 10, 'unsatisfied': 5},
        configuration: {'color': 'blue', 'size': 'medium'},
        positionX: 0,
        positionY: 0,
        width: 4,
        height: 4,
        isVisible: true,
        isRefreshable: true,
        refreshInterval: 900,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<DashboardWidget> _createMockOperationalWidgets() {
    return [
      DashboardWidget(
        id: 'operational_efficiency',
        name: 'Operasyonel Verimlilik',
        description: 'Genel operasyonel verimlilik skoru',
        visualizationType: VisualizationType.line,
        data: {'value': 87.5, 'trend': 'up', 'unit': '%'},
        configuration: {'color': 'orange', 'size': 'medium'},
        positionX: 0,
        positionY: 0,
        width: 6,
        height: 4,
        isVisible: true,
        isRefreshable: true,
        refreshInterval: 1200,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<DashboardWidget> _createMockQualityWidgets() {
    return [
      DashboardWidget(
        id: 'quality_score',
        name: 'Genel Kalite Skoru',
        description: 'Tedavi kalitesi genel skoru',
        visualizationType: VisualizationType.gauge,
        data: {'value': 92.3, 'target': 90, 'unit': '%'},
        configuration: {'color': 'green', 'size': 'large'},
        positionX: 0,
        positionY: 0,
        width: 4,
        height: 4,
        isVisible: true,
        isRefreshable: true,
        refreshInterval: 1800,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<DashboardWidget> _createMockStaffWidgets() {
    return [
      DashboardWidget(
        id: 'staff_performance',
        name: 'Personel Performansı',
        description: 'Ortalama personel performans skoru',
        visualizationType: VisualizationType.bar,
        data: {'value': 88.7, 'previous': 85.2, 'unit': '%'},
        configuration: {'color': 'purple', 'size': 'medium'},
        positionX: 0,
        positionY: 0,
        width: 6,
        height: 4,
        isVisible: true,
        isRefreshable: true,
        refreshInterval: 2400,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
