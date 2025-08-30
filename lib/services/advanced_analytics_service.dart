import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedAnalyticsService {
  static final AdvancedAnalyticsService _instance = AdvancedAnalyticsService._internal();
  factory AdvancedAnalyticsService() => _instance;
  AdvancedAnalyticsService._internal();

  // Analytics durumu
  bool _isInitialized = false;
  Map<String, dynamic> _analyticsData = {};
  List<Map<String, dynamic>> _trends = [];
  List<Map<String, dynamic>> _predictions = [];
  List<Map<String, dynamic>> _customReports = [];
  
  // Analytics kategorileri
  final Map<String, String> _analyticsCategories = {
    'sessions': 'Seans Analizi',
    'clients': 'Müşteri Analizi',
    'revenue': 'Gelir Analizi',
    'performance': 'Performans Analizi',
    'trends': 'Trend Analizi',
    'predictions': 'Tahmin Analizi',
  };
  
  // Stream controllers
  final StreamController<Map<String, dynamic>> _dataController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _trendController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _predictionController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;
  Stream<Map<String, dynamic>> get trendStream => _trendController.stream;
  Stream<Map<String, dynamic>> get predictionStream => _predictionController.stream;

  // Getter'lar
  bool get isInitialized => _isInitialized;
  Map<String, dynamic> get analyticsData => Map.unmodifiable(_analyticsData);
  List<Map<String, dynamic>> get trends => List.unmodifiable(_trends);
  List<Map<String, dynamic>> get predictions => List.unmodifiable(_predictions);
  List<Map<String, dynamic>> get customReports => List.unmodifiable(_customReports);
  Map<String, String> get analyticsCategories => Map.unmodifiable(_analyticsCategories);

  // Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadAnalyticsData();
    await _loadTrends();
    await _loadPredictions();
    await _loadCustomReports();
    
    _isInitialized = true;
    
    // Demo data oluştur
    await _createDemoData();
  }

  // Demo data oluştur
  Future<void> _createDemoData() async {
    if (_analyticsData.isEmpty) {
      _analyticsData = {
        'sessions': {
          'total': 1250,
          'growth': 15.5,
          'averageDuration': 45,
          'completionRate': 92.3,
          'satisfactionScore': 4.6,
        },
        'clients': {
          'total': 320,
          'retentionRate': 87.2,
          'newClients': 45,
          'activeClients': 280,
          'averageAge': 34,
        },
        'revenue': {
          'total': 125000,
          'growth': 22.8,
          'averagePerSession': 100,
          'monthlyRecurring': 85000,
          'projectedAnnual': 1500000,
        },
        'performance': {
          'responseTime': 2.3,
          'uptime': 99.8,
          'userSatisfaction': 4.7,
          'errorRate': 0.2,
          'systemLoad': 65.4,
        },
        'trends': {
          'sessionsGrowth': [12, 15, 18, 22, 25, 28, 30, 32],
          'revenueGrowth': [8, 12, 16, 20, 24, 28, 32, 35],
          'clientGrowth': [5, 8, 12, 15, 18, 22, 25, 28],
        },
      };
      
      _saveAnalyticsData();
      _dataController.add(_analyticsData);
    }

    if (_trends.isEmpty) {
      await _generateTrendAnalysis();
    }

    if (_predictions.isEmpty) {
      await _generatePredictions();
    }

    if (_customReports.isEmpty) {
      await _createDemoReports();
    }
  }

  // Trend analizi oluştur
  Future<void> _generateTrendAnalysis() async {
    final trend1 = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'metric': 'sessionsGrowth',
      'trend': {
        'direction': 'increasing',
        'strength': 0.85,
        'duration': '8 months',
      },
      'confidence': 0.92,
      'insights': [
        'Seans sayısı son 8 ayda sürekli artış gösteriyor',
        'Aylık ortalama %15 büyüme hızı',
        'En yüksek artış hafta sonları görülüyor',
        'Online seansların payı %40\'a çıktı',
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };

    final trend2 = {
      'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      'metric': 'revenueGrowth',
      'trend': {
        'direction': 'increasing',
        'strength': 0.78,
        'duration': '6 months',
      },
      'confidence': 0.88,
      'insights': [
        'Gelir artışı seans artışından daha hızlı',
        'Premium hizmetlerin payı %25\'e çıktı',
        'Müşteri başına ortalama gelir artıyor',
        'Yeni fiyatlandırma stratejisi başarılı',
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };

    final trend3 = {
      'id': (DateTime.now().millisecondsSinceEpoch + 2).toString(),
      'metric': 'clientGrowth',
      'trend': {
        'direction': 'increasing',
        'strength': 0.72,
        'duration': '4 months',
      },
      'confidence': 0.85,
      'insights': [
        'Yeni müşteri kazanımı hızlanıyor',
        'Referans oranı %35\'e çıktı',
        'Genç müşteri segmenti büyüyor',
        'Online pazarlama etkili',
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };

    _trends.addAll([trend1, trend2, trend3]);
    _saveTrends();
    
    for (final trend in [trend1, trend2, trend3]) {
      _trendController.add(trend);
    }
  }

  // Tahminler oluştur
  Future<void> _generatePredictions() async {
    final prediction1 = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'metric': 'sessionsGrowth',
      'forecast': [35, 38, 42, 45, 48, 52, 55, 58],
      'confidence': 0.89,
      'timeframe': '8 months',
      'factors': [
        'Mevcut büyüme trendi',
        'Sezonsal etkiler',
        'Pazarlama kampanyaları',
        'Müşteri memnuniyeti',
      ],
      'recommendations': [
        'Kapasite artırımı planlanmalı',
        'Yeni terapist alımı gerekli',
        'Online platform geliştirilmeli',
        'Müşteri sadakat programı başlatılmalı',
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };

    final prediction2 = {
      'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      'metric': 'revenueGrowth',
      'forecast': [38, 42, 46, 50, 54, 58, 62, 66],
      'confidence': 0.85,
      'timeframe': '8 months',
      'factors': [
        'Seans artışı',
        'Fiyat optimizasyonu',
        'Premium hizmetler',
        'Müşteri segmentasyonu',
      ],
      'recommendations': [
        'Fiyatlandırma stratejisi gözden geçirilmeli',
        'Premium paketler genişletilmeli',
        'Müşteri segmentasyonu iyileştirilmeli',
        'Gelir optimizasyonu odaklanılmalı',
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };

    final prediction3 = {
      'id': (DateTime.now().millisecondsSinceEpoch + 2).toString(),
      'metric': 'clientGrowth',
      'forecast': [30, 33, 36, 39, 42, 45, 48, 51],
      'confidence': 0.82,
      'timeframe': '8 months',
      'factors': [
        'Pazarlama etkinliği',
        'Referans sistemi',
        'Müşteri memnuniyeti',
        'Rekabet durumu',
      ],
      'recommendations': [
        'Pazarlama bütçesi artırılmalı',
        'Referans programı güçlendirilmeli',
        'Müşteri deneyimi iyileştirilmeli',
        'Rekabet analizi yapılmalı',
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };

    _predictions.addAll([prediction1, prediction2, prediction3]);
    _savePredictions();
    
    for (final prediction in [prediction1, prediction2, prediction3]) {
      _predictionController.add(prediction);
    }
  }

  // Demo raporlar oluştur
  Future<void> _createDemoReports() async {
    final report1 = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': 'Aylık Performans Raporu',
      'description': 'Seans, gelir ve müşteri performans analizi',
      'category': 'performance',
      'metrics': ['sessions', 'revenue', 'clients'],
      'isActive': true,
      'schedule': 'monthly',
      'lastGenerated': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    final report2 = {
      'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      'name': 'Trend Analiz Raporu',
      'description': 'Büyüme trendleri ve tahminler',
      'category': 'trends',
      'metrics': ['sessionsGrowth', 'revenueGrowth', 'clientGrowth'],
      'isActive': true,
      'schedule': 'weekly',
      'lastGenerated': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    final report3 = {
      'id': (DateTime.now().millisecondsSinceEpoch + 2).toString(),
      'name': 'Müşteri Segmentasyon Raporu',
      'description': 'Müşteri demografisi ve davranış analizi',
      'category': 'clients',
      'metrics': ['clientDemographics', 'clientBehavior', 'retentionRate'],
      'isActive': false,
      'schedule': 'quarterly',
      'lastGenerated': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    _customReports.addAll([report1, report2, report3]);
    _saveCustomReports();
  }

  // Analytics data güncelle
  Future<void> updateAnalyticsData(Map<String, dynamic> data) async {
    _analyticsData.addAll(data);
    _saveAnalyticsData();
    _dataController.add(_analyticsData);
  }

  // Trend analizi başlat
  Future<void> analyzeTrends({
    required String metric,
    required int timePeriod,
    Map<String, dynamic>? filters,
  }) async {
    // Simulate AI analysis
    await Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(2000)));
    
    final trend = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'metric': metric,
      'trend': {
        'direction': _getRandomDirection(),
        'strength': Random().nextDouble(),
        'duration': '$timePeriod days',
      },
      'confidence': 0.7 + Random().nextDouble() * 0.3,
      'insights': _generateInsights(metric),
      'createdAt': DateTime.now().toIso8601String(),
    };

    _trends.add(trend);
    _saveTrends();
    _trendController.add(trend);
  }

  // Tahmin oluştur
  Future<void> generatePrediction({
    required String metric,
    required int periods,
    Map<String, dynamic>? parameters,
  }) async {
    // Simulate AI prediction
    await Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(2500)));
    
    final forecast = List.generate(periods, (index) {
      final baseValue = 30 + Random().nextInt(40);
      final growth = 1 + (index * 0.05);
      return (baseValue * growth).roundToDouble();
    });

    final prediction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'metric': metric,
      'forecast': forecast,
      'confidence': 0.75 + Random().nextDouble() * 0.2,
      'timeframe': '$periods periods',
      'factors': _generateFactors(metric),
      'recommendations': _generateRecommendations(metric),
      'createdAt': DateTime.now().toIso8601String(),
    };

    _predictions.add(prediction);
    _savePredictions();
    _predictionController.add(prediction);
  }

  // Özel rapor oluştur
  Future<void> createCustomReport({
    required String name,
    required String description,
    required String category,
    required List<String> metrics,
    String? schedule,
  }) async {
    final report = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'description': description,
      'category': category,
      'metrics': metrics,
      'isActive': true,
      'schedule': schedule ?? 'manual',
      'lastGenerated': null,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _customReports.add(report);
    _saveCustomReports();
  }

  // Rapor çalıştır
  Future<List<Map<String, dynamic>>> runReport(String reportId) async {
    final report = _customReports.firstWhere((r) => r['id'] == reportId);
    
    // Simulate report generation
    await Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(3000)));
    
    final results = <Map<String, dynamic>>[];
    for (final metric in report['metrics']) {
      results.add({
        'metric': metric,
        'value': _getMetricValue(metric),
        'trend': _getRandomDirection(),
        'change': Random().nextDouble() * 20 - 10,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    // Update last generated
    final index = _customReports.indexWhere((r) => r['id'] == reportId);
    if (index != -1) {
      _customReports[index]['lastGenerated'] = DateTime.now().toIso8601String();
      _saveCustomReports();
    }

    return results;
  }

  // Analytics istatistikleri
  Map<String, dynamic> getAnalyticsStats() {
    return {
      'totalTrends': _trends.length,
      'totalPredictions': _predictions.length,
      'totalReports': _customReports.length,
      'activeReports': _customReports.where((r) => r['isActive'] == true).length,
      'lastUpdated': DateTime.now().toIso8601String(),
      'dataPoints': _analyticsData.length,
    };
  }

  // Helper methods
  String _getRandomDirection() {
    final directions = ['increasing', 'decreasing', 'stable'];
    return directions[Random().nextInt(directions.length)];
  }

  List<String> _generateInsights(String metric) {
    final insights = {
      'sessionsGrowth': [
        'Seans sayısı artış trendinde',
        'Hafta sonları en yoğun dönem',
        'Online seansların payı artıyor',
        'Müşteri memnuniyeti yüksek',
      ],
      'revenueGrowth': [
        'Gelir artışı seans artışından hızlı',
        'Premium hizmetler popüler',
        'Fiyat optimizasyonu başarılı',
        'Müşteri başına gelir artıyor',
      ],
      'clientGrowth': [
        'Yeni müşteri kazanımı hızlanıyor',
        'Referans sistemi etkili',
        'Genç segment büyüyor',
        'Online pazarlama başarılı',
      ],
    };

    return insights[metric] ?? ['Genel artış trendi', 'Pozitif performans'];
  }

  List<String> _generateFactors(String metric) {
    final factors = {
      'sessionsGrowth': [
        'Mevcut büyüme trendi',
        'Sezonsal etkiler',
        'Pazarlama kampanyaları',
        'Müşteri memnuniyeti',
      ],
      'revenueGrowth': [
        'Seans artışı',
        'Fiyat optimizasyonu',
        'Premium hizmetler',
        'Müşteri segmentasyonu',
      ],
      'clientGrowth': [
        'Pazarlama etkinliği',
        'Referans sistemi',
        'Müşteri memnuniyeti',
        'Rekabet durumu',
      ],
    };

    return factors[metric] ?? ['Genel faktörler', 'Pazar koşulları'];
  }

  List<String> _generateRecommendations(String metric) {
    final recommendations = {
      'sessionsGrowth': [
        'Kapasite artırımı planlanmalı',
        'Yeni terapist alımı gerekli',
        'Online platform geliştirilmeli',
        'Müşteri sadakat programı başlatılmalı',
      ],
      'revenueGrowth': [
        'Fiyatlandırma stratejisi gözden geçirilmeli',
        'Premium paketler genişletilmeli',
        'Müşteri segmentasyonu iyileştirilmeli',
        'Gelir optimizasyonu odaklanılmalı',
      ],
      'clientGrowth': [
        'Pazarlama bütçesi artırılmalı',
        'Referans programı güçlendirilmeli',
        'Müşteri deneyimi iyileştirilmeli',
        'Rekabet analizi yapılmalı',
      ],
    };

    return recommendations[metric] ?? ['Genel öneriler', 'Sürekli iyileştirme'];
  }

  dynamic _getMetricValue(String metric) {
    final values = {
      'sessions': _analyticsData['sessions']?['total'] ?? 0,
      'revenue': _analyticsData['revenue']?['total'] ?? 0,
      'clients': _analyticsData['clients']?['total'] ?? 0,
      'sessionsGrowth': _analyticsData['trends']?['sessionsGrowth']?.last ?? 0,
      'revenueGrowth': _analyticsData['trends']?['revenueGrowth']?.last ?? 0,
      'clientGrowth': _analyticsData['trends']?['clientGrowth']?.last ?? 0,
    };

    return values[metric] ?? 0;
  }

  // Data persistence
  Future<void> _saveAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('analytics_data', json.encode(_analyticsData));
  }

  Future<void> _loadAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('analytics_data');
    if (data != null) {
      _analyticsData = Map<String, dynamic>.from(json.decode(data));
    }
  }

  Future<void> _saveTrends() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('analytics_trends', json.encode(_trends));
  }

  Future<void> _loadTrends() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('analytics_trends');
    if (data != null) {
      _trends = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  Future<void> _savePredictions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('analytics_predictions', json.encode(_predictions));
  }

  Future<void> _loadPredictions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('analytics_predictions');
    if (data != null) {
      _predictions = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  Future<void> _saveCustomReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('analytics_reports', json.encode(_customReports));
  }

  Future<void> _loadCustomReports() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('analytics_reports');
    if (data != null) {
      _customReports = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Dispose
  void dispose() {
    _dataController.close();
    _trendController.close();
    _predictionController.close();
  }
}
