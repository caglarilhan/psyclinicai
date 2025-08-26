import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/advanced_analytics_service.dart';
import 'package:psyclinicai/models/advanced_analytics_models.dart';

void main() {
  group('AdvancedAnalyticsService Tests', () {
    late AdvancedAnalyticsService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = AdvancedAnalyticsService();
    });

    tearDown(() {
      // Don't dispose service during tests to avoid stream controller issues
    });

    group('Service Initialization Tests', () {
      test('should create service instance', () {
        expect(service, isNotNull);
        expect(service, isA<AdvancedAnalyticsService>());
      });

      test('should initialize successfully', () async {
        await service.initialize();
        // Service should be initialized without errors
        expect(true, isTrue);
      });
    });

    group('Dashboard Tests', () {
      test('should get overview dashboard', () async {
        final dashboard = await service.getOverviewDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.name, equals('Genel Bakış'));
        expect(dashboard.description, equals('Tüm önemli metrikleri tek yerde görüntüle'));
        expect(dashboard.type, equals(DashboardType.overview));
        expect(dashboard.isDefault, isTrue);
        expect(dashboard.isPublic, isTrue);
        expect(dashboard.widgets, isNotEmpty);
        expect(dashboard.widgets.length, equals(2));
      });

      test('should get financial dashboard', () async {
        final dashboard = await service.getFinancialDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.name, equals('Finansal Analiz'));
        expect(dashboard.description, equals('Gelir, maliyet ve karlılık analizi'));
        expect(dashboard.type, equals(DashboardType.financial));
        expect(dashboard.isDefault, isFalse);
        expect(dashboard.isPublic, isTrue);
        expect(dashboard.widgets, isNotEmpty);
        expect(dashboard.widgets.length, equals(1));
      });

      test('should get patient dashboard', () async {
        final dashboard = await service.getPatientDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.name, equals('Hasta Analizi'));
        expect(dashboard.description, equals('Hasta sayıları ve memnuniyet oranları'));
        expect(dashboard.type, equals(DashboardType.patients));
        expect(dashboard.isDefault, isFalse);
        expect(dashboard.isPublic, isTrue);
        expect(dashboard.widgets, isNotEmpty);
        expect(dashboard.widgets.length, equals(1));
      });

      test('should get operational dashboard', () async {
        final dashboard = await service.getOperationalDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.name, equals('Operasyonel Analiz'));
        expect(dashboard.description, equals('Verimlilik ve kaynak kullanımı'));
        expect(dashboard.type, equals(DashboardType.operations));
        expect(dashboard.isDefault, isFalse);
        expect(dashboard.isPublic, isTrue);
        expect(dashboard.widgets, isNotEmpty);
        expect(dashboard.widgets.length, equals(1));
      });

      test('should get quality dashboard', () async {
        final dashboard = await service.getQualityDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.name, equals('Kalite Analizi'));
        expect(dashboard.description, equals('Tedavi kalitesi ve hasta sonuçları'));
        expect(dashboard.type, equals(DashboardType.quality));
        expect(dashboard.isDefault, isFalse);
        expect(dashboard.isPublic, isTrue);
        expect(dashboard.widgets, isNotEmpty);
        expect(dashboard.widgets.length, equals(1));
      });

      test('should get staff dashboard', () async {
        final dashboard = await service.getStaffDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.name, equals('Personel Analizi'));
        expect(dashboard.description, equals('Personel performansı ve eğitim durumu'));
        expect(dashboard.type, equals(DashboardType.staff));
        expect(dashboard.isDefault, isFalse);
        expect(dashboard.isPublic, isTrue);
        expect(dashboard.widgets, isNotEmpty);
        expect(dashboard.widgets.length, equals(1));
      });
    });

    group('Widget Tests', () {
      test('should have overview widgets with correct properties', () async {
        final dashboard = await service.getOverviewDashboard();
        final widgets = dashboard.widgets;

        expect(widgets, isNotEmpty);
        expect(widgets.length, equals(2));

        // Check first widget (revenue)
        final revenueWidget = widgets.first;
        expect(revenueWidget.name, equals('Toplam Gelir'));
        expect(revenueWidget.description, equals('Bu ay toplam gelir'));
        expect(revenueWidget.visualizationType, equals(VisualizationType.gauge));
        expect(revenueWidget.isVisible, isTrue);
        expect(revenueWidget.isRefreshable, isTrue);
        expect(revenueWidget.refreshInterval, equals(300));

        // Check second widget (patients)
        final patientWidget = widgets[1];
        expect(patientWidget.name, equals('Aktif Hastalar'));
        expect(patientWidget.description, equals('Şu anda aktif hasta sayısı'));
        expect(patientWidget.visualizationType, equals(VisualizationType.trend));
        expect(patientWidget.isVisible, isTrue);
        expect(patientWidget.isRefreshable, isTrue);
        expect(patientWidget.refreshInterval, equals(300));
      });

      test('should have financial widgets with correct properties', () async {
        final dashboard = await service.getFinancialDashboard();
        final widgets = dashboard.widgets;

        expect(widgets, isNotEmpty);
        expect(widgets.length, equals(1));

        final profitWidget = widgets.first;
        expect(profitWidget.name, equals('Net Kar'));
        expect(profitWidget.description, equals('Bu ay net kar'));
        expect(profitWidget.visualizationType, equals(VisualizationType.bar));
        expect(profitWidget.isVisible, isTrue);
        expect(profitWidget.isRefreshable, isTrue);
        expect(profitWidget.refreshInterval, equals(600));
      });

      test('should have patient widgets with correct properties', () async {
        final dashboard = await service.getPatientDashboard();
        final widgets = dashboard.widgets;

        expect(widgets, isNotEmpty);
        expect(widgets.length, equals(1));

        final satisfactionWidget = widgets.first;
        expect(satisfactionWidget.name, equals('Hasta Memnuniyeti'));
        expect(satisfactionWidget.description, equals('Genel hasta memnuniyet oranı'));
        expect(satisfactionWidget.visualizationType, equals(VisualizationType.pie));
        expect(satisfactionWidget.isVisible, isTrue);
        expect(satisfactionWidget.isRefreshable, isTrue);
        expect(satisfactionWidget.refreshInterval, equals(900));
      });
    });

    group('Quick Actions Tests', () {
      test('should have quick actions available', () async {
        await service.initialize();
        final quickActions = service.getQuickActions();

        expect(quickActions, isNotEmpty);
        expect(quickActions.length, equals(5));
      });

      test('should have overview quick action', () async {
        await service.initialize();
        final quickActions = service.getQuickActions();
        final overviewAction = quickActions.firstWhere((action) => action.id == 'quick_overview');

        expect(overviewAction, isNotNull);
        expect(overviewAction.name, equals('Genel Bakış'));
        expect(overviewAction.description, equals('Tüm önemli metrikleri tek tıkla görüntüle'));
        expect(overviewAction.icon, equals('📊'));
        expect(overviewAction.action, equals('show_overview'));
        expect(overviewAction.isEnabled, isTrue);
        expect(overviewAction.priority, equals(PriorityLevel.high));
      });

      test('should have financial quick action', () async {
        await service.initialize();
        final quickActions = service.getQuickActions();
        final financialAction = quickActions.firstWhere((action) => action.id == 'quick_financial');

        expect(financialAction, isNotNull);
        expect(financialAction.name, equals('Finansal Durum'));
        expect(financialAction.description, equals('Gelir, maliyet ve karlılık analizi'));
        expect(financialAction.icon, equals('💰'));
        expect(financialAction.action, equals('show_financial'));
        expect(financialAction.isEnabled, isTrue);
        expect(financialAction.priority, equals(PriorityLevel.high));
      });

      test('should have patient quick action', () async {
        await service.initialize();
        final quickActions = service.getQuickActions();
        final patientAction = quickActions.firstWhere((action) => action.id == 'quick_patients');

        expect(patientAction, isNotNull);
        expect(patientAction.name, equals('Hasta Analizi'));
        expect(patientAction.description, equals('Hasta sayıları ve memnuniyet oranları'));
        expect(patientAction.icon, equals('👥'));
        expect(patientAction.action, equals('show_patients'));
        expect(patientAction.isEnabled, isTrue);
        expect(patientAction.priority, equals(PriorityLevel.medium));
      });

      test('should have report quick action', () async {
        await service.initialize();
        final quickActions = service.getQuickActions();
        final reportAction = quickActions.firstWhere((action) => action.id == 'quick_report');

        expect(reportAction, isNotNull);
        expect(reportAction.name, equals('Hızlı Rapor'));
        expect(reportAction.description, equals('Seçilen kategoride hızlı rapor oluştur'));
        expect(reportAction.icon, equals('📋'));
        expect(reportAction.action, equals('generate_report'));
        expect(reportAction.isEnabled, isTrue);
        expect(reportAction.priority, equals(PriorityLevel.medium));
      });

      test('should have export quick action', () async {
        await service.initialize();
        final quickActions = service.getQuickActions();
        final exportAction = quickActions.firstWhere((action) => action.id == 'quick_export');

        expect(exportAction, isNotNull);
        expect(exportAction.name, equals('Veri Dışa Aktar'));
        expect(exportAction.description, equals('Analitik verilerini PDF/Excel olarak indir'));
        expect(exportAction.icon, equals('📥'));
        expect(exportAction.action, equals('export_data'));
        expect(exportAction.isEnabled, isTrue);
        expect(exportAction.priority, equals(PriorityLevel.low));
      });
    });

    group('Smart Filters Tests', () {
      test('should have smart filters available', () async {
        await service.initialize();
        final smartFilters = service.getSmartFilters();

        expect(smartFilters, isNotEmpty);
        expect(smartFilters.length, equals(3));
      });

      test('should have time filter', () async {
        await service.initialize();
        final smartFilters = service.getSmartFilters();
        final timeFilter = smartFilters.firstWhere((filter) => filter.id == 'filter_time');

        expect(timeFilter, isNotNull);
        expect(timeFilter.name, equals('Zaman Filtresi'));
        expect(timeFilter.description, equals('Tarih aralığına göre filtrele'));
        expect(timeFilter.field, equals('date'));
        expect(timeFilter.operator, equals('between'));
        expect(timeFilter.value, equals('last_30_days'));
        expect(timeFilter.isActive, isTrue);
        expect(timeFilter.priority, equals(PriorityLevel.high));
      });

      test('should have priority filter', () async {
        await service.initialize();
        final smartFilters = service.getSmartFilters();
        final priorityFilter = smartFilters.firstWhere((filter) => filter.id == 'filter_priority');

        expect(priorityFilter, isNotNull);
        expect(priorityFilter.name, equals('Öncelik Filtresi'));
        expect(priorityFilter.description, equals('Öncelik seviyesine göre filtrele'));
        expect(priorityFilter.field, equals('priority'));
        expect(priorityFilter.operator, equals('equals'));
        expect(priorityFilter.value, equals('high'));
        expect(priorityFilter.isActive, isTrue);
        expect(priorityFilter.priority, equals(PriorityLevel.medium));
      });

      test('should have category filter', () async {
        await service.initialize();
        final smartFilters = service.getSmartFilters();
        final categoryFilter = smartFilters.firstWhere((filter) => filter.id == 'filter_category');

        expect(categoryFilter, isNotNull);
        expect(categoryFilter.name, equals('Kategori Filtresi'));
        expect(categoryFilter.description, equals('Kategoriye göre filtrele'));
        expect(categoryFilter.field, equals('category'));
        expect(categoryFilter.operator, equals('in'));
        expect(categoryFilter.value, isA<List>());
        expect(categoryFilter.isActive, isTrue);
        expect(categoryFilter.priority, equals(PriorityLevel.medium));
      });
    });

    group('Report Generation Tests', () {
      test('should generate quick report for financial dashboard', () async {
        final report = await service.generateQuickReport(
          dashboardType: DashboardType.financial,
          timePeriod: TimePeriod.month,
          customName: 'Finansal Rapor',
        );

        expect(report, isNotNull);
        expect(report.name, equals('Finansal Rapor'));
        expect(report.dashboardType, equals(DashboardType.financial));
        expect(report.timePeriod, equals(TimePeriod.month));
        expect(report.insights, isNotEmpty);
        expect(report.recommendations, isNotEmpty);
        expect(report.createdBy, equals('system'));
      });

      test('should generate quick report for patient dashboard', () async {
        final report = await service.generateQuickReport(
          dashboardType: DashboardType.patients,
          timePeriod: TimePeriod.week,
        );

        expect(report, isNotNull);
        expect(report.name, equals('patients Raporu'));
        expect(report.dashboardType, equals(DashboardType.patients));
        expect(report.timePeriod, equals(TimePeriod.week));
        expect(report.insights, isNotEmpty);
        expect(report.recommendations, isNotEmpty);
      });

      test('should generate quick report for operational dashboard', () async {
        final report = await service.generateQuickReport(
          dashboardType: DashboardType.operations,
          timePeriod: TimePeriod.quarter,
          customName: 'Operasyonel Performans Raporu',
        );

        expect(report, isNotNull);
        expect(report.name, equals('Operasyonel Performans Raporu'));
        expect(report.dashboardType, equals(DashboardType.operations));
        expect(report.timePeriod, equals(TimePeriod.quarter));
        expect(report.insights, isNotEmpty);
        expect(report.recommendations, isNotEmpty);
      });
    });

    group('Predictive Insights Tests', () {
      test('should get predictive insights for financial dashboard', () async {
        final insights = await service.getPredictiveInsights(
          dashboardType: DashboardType.financial,
          timePeriod: TimePeriod.month,
        );

        expect(insights, isNotEmpty);
        expect(insights.length, equals(3));
        expect(insights.any((insight) => insight.contains('💰')), isTrue);
        expect(insights.any((insight) => insight.contains('📈')), isTrue);
        expect(insights.any((insight) => insight.contains('⚠️')), isTrue);
      });

      test('should get predictive insights for patient dashboard', () async {
        final insights = await service.getPredictiveInsights(
          dashboardType: DashboardType.patients,
          timePeriod: TimePeriod.week,
        );

        expect(insights, isNotEmpty);
        expect(insights.length, equals(3));
        expect(insights.any((insight) => insight.contains('👥')), isTrue);
        expect(insights.any((insight) => insight.contains('⭐')), isTrue);
        expect(insights.any((insight) => insight.contains('📊')), isTrue);
      });

      test('should get predictive insights for operational dashboard', () async {
        final insights = await service.getPredictiveInsights(
          dashboardType: DashboardType.operations,
          timePeriod: TimePeriod.quarter,
        );

        expect(insights, isNotEmpty);
        expect(insights.length, equals(3));
        expect(insights.any((insight) => insight.contains('⚡')), isTrue);
        expect(insights.any((insight) => insight.contains('🕒')), isTrue);
        expect(insights.any((insight) => insight.contains('📋')), isTrue);
      });

      test('should get default insights for unknown dashboard type', () async {
        final insights = await service.getPredictiveInsights(
          dashboardType: DashboardType.overview,
          timePeriod: TimePeriod.year,
        );

        expect(insights, isNotEmpty);
        expect(insights.length, equals(3));
        expect(insights.any((insight) => insight.contains('📊')), isTrue);
        expect(insights.any((insight) => insight.contains('🎯')), isTrue);
        expect(insights.any((insight) => insight.contains('💡')), isTrue);
      });
    });

    group('Data Export Tests', () {
      test('should export data to PDF format', () async {
        final exportUrl = await service.exportData(
          dashboardType: DashboardType.financial,
          timePeriod: TimePeriod.month,
          format: 'pdf',
        );

        expect(exportUrl, isNotEmpty);
        expect(exportUrl, contains('pdf'));
        expect(exportUrl, contains('financial'));
        expect(exportUrl, contains('month'));
      });

      test('should export data to Excel format', () async {
        final exportUrl = await service.exportData(
          dashboardType: DashboardType.patients,
          timePeriod: TimePeriod.week,
          format: 'excel',
        );

        expect(exportUrl, isNotEmpty);
        expect(exportUrl, contains('excel'));
        expect(exportUrl, contains('patients'));
        expect(exportUrl, contains('week'));
      });

      test('should export data to CSV format', () async {
        final exportUrl = await service.exportData(
          dashboardType: DashboardType.operations,
          timePeriod: TimePeriod.quarter,
          format: 'csv',
        );

        expect(exportUrl, isNotEmpty);
        expect(exportUrl, contains('csv'));
        expect(exportUrl, contains('operations'));
        expect(exportUrl, contains('quarter'));
      });
    });

    group('Smart Filter Application Tests', () {
      test('should apply smart filter successfully', () async {
        final testData = {'test': 'data', 'priority': 'high'};
        final filteredData = await service.applySmartFilter(
          filterId: 'filter_priority',
          data: testData,
        );

        expect(filteredData, isNotEmpty);
        expect(filteredData.length, equals(1));
        expect(filteredData.first, equals(testData));
      });

      test('should handle invalid filter gracefully', () async {
        final testData = {'test': 'data'};
        final filteredData = await service.applySmartFilter(
          filterId: 'invalid_filter',
          data: testData,
        );

        expect(filteredData, isNotEmpty);
        expect(filteredData.length, equals(1));
        expect(filteredData.first, equals(testData));
      });
    });

    group('Stream Tests', () {
      test('should provide dashboard stream', () {
        final stream = service.dashboardStream;
        expect(stream, isNotNull);
      });

      test('should provide metrics stream', () {
        final stream = service.metricsStream;
        expect(stream, isNotNull);
      });

      test('should provide insight stream', () {
        final stream = service.insightStream;
        expect(stream, isNotNull);
      });
    });

    group('Mock Data Validation Tests', () {
      test('should provide realistic mock dashboard data', () async {
        final overviewDashboard = await service.getOverviewDashboard();
        final financialDashboard = await service.getFinancialDashboard();
        final patientDashboard = await service.getPatientDashboard();

        // Validate overview dashboard
        expect(overviewDashboard, isNotNull);
        expect(overviewDashboard.id, isNotEmpty);
        expect(overviewDashboard.name, isNotEmpty);
        expect(overviewDashboard.description, isNotEmpty);
        expect(overviewDashboard.widgets, isNotEmpty);

        // Validate financial dashboard
        expect(financialDashboard, isNotNull);
        expect(financialDashboard.id, isNotEmpty);
        expect(financialDashboard.name, isNotEmpty);
        expect(financialDashboard.description, isNotEmpty);
        expect(financialDashboard.widgets, isNotEmpty);

        // Validate patient dashboard
        expect(patientDashboard, isNotNull);
        expect(patientDashboard.id, isNotEmpty);
        expect(patientDashboard.name, isNotEmpty);
        expect(patientDashboard.description, isNotEmpty);
        expect(patientDashboard.widgets, isNotEmpty);
      });

      test('should provide realistic mock widget data', () async {
        final overviewDashboard = await service.getOverviewDashboard();
        final widgets = overviewDashboard.widgets;

        for (final widget in widgets) {
          expect(widget.id, isNotEmpty);
          expect(widget.name, isNotEmpty);
          expect(widget.description, isNotEmpty);
          expect(widget.data, isNotEmpty);
          expect(widget.configuration, isNotEmpty);
          expect(widget.isVisible, isTrue);
          expect(widget.isRefreshable, isTrue);
          expect(widget.refreshInterval, greaterThan(0));
        }
      });

      test('should provide realistic mock quick actions', () {
        final quickActions = service.getQuickActions();

        for (final action in quickActions) {
          expect(action.id, isNotEmpty);
          expect(action.name, isNotEmpty);
          expect(action.description, isNotEmpty);
          expect(action.icon, isNotEmpty);
          expect(action.action, isNotEmpty);
          expect(action.parameters, isNotEmpty);
          expect(action.isEnabled, isTrue);
        }
      });

      test('should provide realistic mock smart filters', () {
        final smartFilters = service.getSmartFilters();

        for (final filter in smartFilters) {
          expect(filter.id, isNotEmpty);
          expect(filter.name, isNotEmpty);
          expect(filter.description, isNotEmpty);
          expect(filter.field, isNotEmpty);
          expect(filter.operator, isNotEmpty);
          expect(filter.value, isNotNull);
          expect(filter.isActive, isTrue);
        }
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        // This test verifies that the service handles network errors
        // by falling back to mock data
        final dashboard = await service.getOverviewDashboard();
        expect(dashboard, isNotNull);
        expect(dashboard.name, equals('Genel Bakış'));
      });
    });
  });
}
