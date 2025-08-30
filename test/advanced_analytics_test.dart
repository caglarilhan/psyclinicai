import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:psyclinicai/services/advanced_analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getAll':
          return <String, dynamic>{};
        case 'setString':
          return true;
        case 'getString':
          return null;
        default:
          return null;
      }
    });
  });
  
  group('Advanced Analytics Service Tests', () {
    late AdvancedAnalyticsService analyticsService;

    setUp(() {
      analyticsService = AdvancedAnalyticsService();
    });

    test('Service initialization', () async {
      expect(analyticsService.isInitialized, false);
      
      await analyticsService.initialize();
      
      expect(analyticsService.isInitialized, true);
      expect(analyticsService.analyticsData, isNotEmpty);
      expect(analyticsService.trends, isNotEmpty);
      expect(analyticsService.predictions, isNotEmpty);
      expect(analyticsService.customReports, isNotEmpty);
    });

    test('Analytics data structure', () async {
      await analyticsService.initialize();
      
      final data = analyticsService.analyticsData;
      
      expect(data['sessions'], isNotNull);
      expect(data['clients'], isNotNull);
      expect(data['revenue'], isNotNull);
      expect(data['performance'], isNotNull);
      expect(data['trends'], isNotNull);
      
      expect(data['sessions']['total'], isA<int>());
      expect(data['sessions']['growth'], isA<double>());
      expect(data['clients']['total'], isA<int>());
      expect(data['revenue']['total'], isA<int>());
    });

    test('Trend analysis', () async {
      await analyticsService.initialize();
      
      final initialTrendCount = analyticsService.trends.length;
      
      await analyticsService.analyzeTrends(
        metric: 'sessionsGrowth',
        timePeriod: 30,
      );
      
      expect(analyticsService.trends.length, greaterThan(initialTrendCount));
      
      final latestTrend = analyticsService.trends.last;
      expect(latestTrend['metric'], 'sessionsGrowth');
      expect(latestTrend['trend'], isNotNull);
      expect(latestTrend['confidence'], isA<double>());
      expect(latestTrend['insights'], isA<List>());
    });

    test('Prediction generation', () async {
      await analyticsService.initialize();
      
      final initialPredictionCount = analyticsService.predictions.length;
      
      await analyticsService.generatePrediction(
        metric: 'revenueGrowth',
        periods: 6,
      );
      
      expect(analyticsService.predictions.length, greaterThan(initialPredictionCount));
      
      final latestPrediction = analyticsService.predictions.last;
      expect(latestPrediction['metric'], 'revenueGrowth');
      expect(latestPrediction['forecast'], isA<List>());
      expect(latestPrediction['forecast'].length, 6);
      expect(latestPrediction['confidence'], isA<double>());
      expect(latestPrediction['recommendations'], isA<List>());
    });

    test('Custom report creation', () async {
      await analyticsService.initialize();
      
      final initialReportCount = analyticsService.customReports.length;
      
      await analyticsService.createCustomReport(
        name: 'Test Raporu',
        description: 'Test açıklaması',
        category: 'performance',
        metrics: ['sessions', 'revenue'],
        schedule: 'weekly',
      );
      
      expect(analyticsService.customReports.length, greaterThan(initialReportCount));
      
      final latestReport = analyticsService.customReports.last;
      expect(latestReport['name'], 'Test Raporu');
      expect(latestReport['description'], 'Test açıklaması');
      expect(latestReport['category'], 'performance');
      expect(latestReport['metrics'], ['sessions', 'revenue']);
      expect(latestReport['isActive'], true);
    });

    test('Report execution', () async {
      await analyticsService.initialize();
      
      final report = analyticsService.customReports.first;
      final reportId = report['id'];
      
      final results = await analyticsService.runReport(reportId);
      
      expect(results, isA<List>());
      expect(results.isNotEmpty, true);
      
      for (final result in results) {
        expect(result['metric'], isA<String>());
        expect(result['value'], isNotNull);
        expect(result['trend'], isA<String>());
        expect(result['change'], isA<double>());
        expect(result['timestamp'], isA<String>());
      }
    });

    test('Analytics statistics', () async {
      await analyticsService.initialize();
      
      final stats = analyticsService.getAnalyticsStats();
      
      expect(stats['totalTrends'], isA<int>());
      expect(stats['totalPredictions'], isA<int>());
      expect(stats['totalReports'], isA<int>());
      expect(stats['activeReports'], isA<int>());
      expect(stats['lastUpdated'], isA<String>());
      expect(stats['dataPoints'], isA<int>());
      
      expect(stats['totalTrends'], greaterThan(0));
      expect(stats['totalPredictions'], greaterThan(0));
      expect(stats['totalReports'], greaterThan(0));
    });

    test('Data update functionality', () async {
      await analyticsService.initialize();
      
      final newData = {
        'sessions': {
          'total': 1500,
          'growth': 20.0,
        },
        'performance': {
          'responseTime': 1.8,
          'uptime': 99.9,
        },
      };
      
      await analyticsService.updateAnalyticsData(newData);
      
      final updatedData = analyticsService.analyticsData;
      expect(updatedData['sessions']['total'], 1500);
      expect(updatedData['sessions']['growth'], 20.0);
      expect(updatedData['performance']['responseTime'], 1.8);
      expect(updatedData['performance']['uptime'], 99.9);
    });

    test('Analytics categories', () async {
      await analyticsService.initialize();
      
      final categories = analyticsService.analyticsCategories;
      
      expect(categories['sessions'], 'Seans Analizi');
      expect(categories['clients'], 'Müşteri Analizi');
      expect(categories['revenue'], 'Gelir Analizi');
      expect(categories['performance'], 'Performans Analizi');
      expect(categories['trends'], 'Trend Analizi');
      expect(categories['predictions'], 'Tahmin Analizi');
    });

    test('Stream functionality', () async {
      await analyticsService.initialize();
      
      // Test data stream
      analyticsService.dataStream.listen((data) {
        expect(data, isA<Map<String, dynamic>>());
        expect(data.isNotEmpty, true);
      });
      
      // Test trend stream
      analyticsService.trendStream.listen((trend) {
        expect(trend, isA<Map<String, dynamic>>());
        expect(trend['metric'], isA<String>());
        expect(trend['trend'], isNotNull);
      });
      
      // Test prediction stream
      analyticsService.predictionStream.listen((prediction) {
        expect(prediction, isA<Map<String, dynamic>>());
        expect(prediction['metric'], isA<String>());
        expect(prediction['forecast'], isA<List>());
      });
    });

    test('Error handling for invalid report ID', () async {
      await analyticsService.initialize();
      
      expect(
        () => analyticsService.runReport('invalid_id'),
        throwsA(isA<StateError>()),
      );
    });

    test('Service disposal', () async {
      await analyticsService.initialize();
      
      // Should not throw when disposing
      expect(() => analyticsService.dispose(), returnsNormally);
    });
  });
}
