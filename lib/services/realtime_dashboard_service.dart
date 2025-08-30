import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class RealtimeDashboardService {
  static final RealtimeDashboardService _instance = RealtimeDashboardService._internal();
  factory RealtimeDashboardService() => _instance;
  RealtimeDashboardService._internal();

  // Real-time data
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _liveUpdates = [];
  Map<String, dynamic> _performanceMetrics = {};
  
  // Stream controllers
  final StreamController<Map<String, dynamic>> _dataController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _updateController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _performanceController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;
  Stream<Map<String, dynamic>> get updateStream => _updateController.stream;
  Stream<Map<String, dynamic>> get performanceStream => _performanceController.stream;

  // Getter'lar
  Map<String, dynamic> get dashboardData => Map.unmodifiable(_dashboardData);
  List<Map<String, dynamic>> get liveUpdates => List.unmodifiable(_liveUpdates);
  Map<String, dynamic> get performanceMetrics => Map.unmodifiable(_performanceMetrics);

  // Timer'lar
  Timer? _dataUpdateTimer;
  Timer? _performanceTimer;
  Timer? _notificationTimer;

  // Servisi başlat
  Future<void> initialize() async {
    await _loadDashboardData();
    await _loadLiveUpdates();
    await _loadPerformanceMetrics();
    
    // Real-time data updates
    _startDataUpdates();
    
    // Performance monitoring
    _startPerformanceMonitoring();
    
    // Live notifications
    _startLiveNotifications();
  }

  // Data updates başlat
  void _startDataUpdates() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateDashboardData();
    });
  }

  // Performance monitoring başlat
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _updatePerformanceMetrics();
    });
  }

  // Live notifications başlat
  void _startLiveNotifications() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _generateLiveNotifications();
    });
  }

  // Dashboard data güncelle
  void _updateDashboardData() {
    final now = DateTime.now();
    
    // Simulate real-time data
    _dashboardData = {
      'activeSessions': _generateRandomNumber(5, 15),
      'pendingAppointments': _generateRandomNumber(3, 10),
      'totalClients': _generateRandomNumber(50, 200),
      'monthlyRevenue': _generateRandomNumber(5000, 25000),
      'sessionCompletionRate': _generateRandomNumber(85, 98),
      'clientSatisfaction': _generateRandomNumber(4.0, 5.0),
      'lastUpdate': now.toIso8601String(),
      
      // Real-time charts data
      'hourlySessions': _generateHourlyData(),
      'weeklyRevenue': _generateWeeklyData(),
      'clientGrowth': _generateGrowthData(),
      'sessionTypes': _generateSessionTypesData(),
    };
    
    _dataController.add(_dashboardData);
    _saveDashboardData();
  }

  // Performance metrics güncelle
  void _updatePerformanceMetrics() {
    final now = DateTime.now();
    
    _performanceMetrics = {
      'responseTime': _generateRandomNumber(50, 200),
      'memoryUsage': _generateRandomNumber(60, 90),
      'cpuUsage': _generateRandomNumber(20, 80),
      'networkLatency': _generateRandomNumber(10, 100),
      'errorRate': _generateRandomNumber(0.1, 2.0),
      'uptime': _generateRandomNumber(99.0, 99.9),
      'lastUpdate': now.toIso8601String(),
    };
    
    _performanceController.add(_performanceMetrics);
    _savePerformanceMetrics();
  }

  // Live notifications oluştur
  void _generateLiveNotifications() {
    final notifications = [
      'Yeni randevu oluşturuldu',
      'Seans tamamlandı',
      'Yeni danışan kaydı',
      'Ödeme alındı',
      'Sistem güncellemesi tamamlandı',
      'Yedekleme başarılı',
    ];
    
    final randomNotification = notifications[Random().nextInt(notifications.length)];
    
    final update = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': randomNotification,
      'type': _getRandomUpdateType(),
      'timestamp': DateTime.now().toIso8601String(),
      'priority': _getRandomPriority(),
    };
    
    _liveUpdates.insert(0, update);
    
    // Keep only last 50 updates
    if (_liveUpdates.length > 50) {
      _liveUpdates = _liveUpdates.take(50).toList();
    }
    
    _updateController.add(update);
    _saveLiveUpdates();
  }

  // Hourly data oluştur
  List<Map<String, dynamic>> _generateHourlyData() {
    final data = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = 23; i >= 0; i--) {
      final hour = now.subtract(Duration(hours: i));
      data.add({
        'hour': '${hour.hour.toString().padLeft(2, '0')}:00',
        'sessions': _generateRandomNumber(0, 8),
        'revenue': _generateRandomNumber(0, 500),
      });
    }
    
    return data;
  }

  // Weekly data oluştur
  List<Map<String, dynamic>> _generateWeeklyData() {
    final data = <Map<String, dynamic>>[];
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    
    for (int i = 6; i >= 0; i--) {
      data.add({
        'day': days[6 - i],
        'revenue': _generateRandomNumber(100, 1000),
        'sessions': _generateRandomNumber(5, 20),
        'clients': _generateRandomNumber(3, 15),
      });
    }
    
    return data;
  }

  // Growth data oluştur
  List<Map<String, dynamic>> _generateGrowthData() {
    final data = <Map<String, dynamic>>[];
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz'];
    
    for (int i = 5; i >= 0; i--) {
      data.add({
        'month': months[5 - i],
        'clients': _generateRandomNumber(20, 100),
        'growth': _generateRandomNumber(5, 25),
      });
    }
    
    return data;
  }

  // Session types data oluştur
  List<Map<String, dynamic>> _generateSessionTypesData() {
    return [
      {'type': 'Bireysel Terapi', 'count': _generateRandomNumber(30, 60), 'color': Colors.blue},
      {'type': 'Çift Terapisi', 'count': _generateRandomNumber(10, 25), 'color': Colors.green},
      {'type': 'Aile Terapisi', 'count': _generateRandomNumber(5, 15), 'color': Colors.orange},
      {'type': 'Grup Terapisi', 'count': _generateRandomNumber(3, 10), 'color': Colors.purple},
      {'type': 'Online Terapi', 'count': _generateRandomNumber(15, 35), 'color': Colors.red},
    ];
  }

  // Random number oluştur
  double _generateRandomNumber(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  // Random update type
  String _getRandomUpdateType() {
    final types = ['info', 'success', 'warning', 'error'];
    return types[Random().nextInt(types.length)];
  }

  // Random priority
  String _getRandomPriority() {
    final priorities = ['low', 'medium', 'high'];
    return priorities[Random().nextInt(priorities.length)];
  }

  // Custom widget data oluştur
  Map<String, dynamic> createCustomWidget(String widgetType, Map<String, dynamic> config) {
    switch (widgetType) {
      case 'chart':
        return _createChartWidget(config);
      case 'metric':
        return _createMetricWidget(config);
      case 'list':
        return _createListWidget(config);
      case 'gauge':
        return _createGaugeWidget(config);
      default:
        return {'error': 'Unknown widget type'};
    }
  }

  // Chart widget oluştur
  Map<String, dynamic> _createChartWidget(Map<String, dynamic> config) {
    final chartType = config['type'] ?? 'line';
    final dataPoints = config['dataPoints'] ?? 10;
    
    final data = <Map<String, dynamic>>[];
    for (int i = 0; i < dataPoints; i++) {
      data.add({
        'x': i,
        'y': _generateRandomNumber(0, 100),
        'label': 'Point $i',
      });
    }
    
    return {
      'type': 'chart',
      'chartType': chartType,
      'data': data,
      'config': config,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  // Metric widget oluştur
  Map<String, dynamic> _createMetricWidget(Map<String, dynamic> config) {
    final metricName = config['name'] ?? 'Metric';
    final value = _generateRandomNumber(0, 1000);
    final change = _generateRandomNumber(-20, 20);
    
    return {
      'type': 'metric',
      'name': metricName,
      'value': value,
      'change': change,
      'trend': change > 0 ? 'up' : 'down',
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  // List widget oluştur
  Map<String, dynamic> _createListWidget(Map<String, dynamic> config) {
    final itemCount = config['itemCount'] ?? 5;
    final items = <Map<String, dynamic>>[];
    
    for (int i = 0; i < itemCount; i++) {
      items.add({
        'id': i,
        'title': 'Item $i',
        'subtitle': 'Description for item $i',
        'value': _generateRandomNumber(0, 100),
        'status': _getRandomStatus(),
      });
    }
    
    return {
      'type': 'list',
      'items': items,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  // Gauge widget oluştur
  Map<String, dynamic> _createGaugeWidget(Map<String, dynamic> config) {
    final value = _generateRandomNumber(0, 100);
    final min = config['min'] ?? 0;
    final max = config['max'] ?? 100;
    
    return {
      'type': 'gauge',
      'value': value,
      'min': min,
      'max': max,
      'percentage': (value / max) * 100,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  // Random status
  String _getRandomStatus() {
    final statuses = ['active', 'pending', 'completed', 'cancelled'];
    return statuses[Random().nextInt(statuses.length)];
  }

  // Dashboard data kaydet
  Future<void> _saveDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dashboard_data', json.encode(_dashboardData));
  }

  // Dashboard data yükle
  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('dashboard_data');
    if (data != null) {
      _dashboardData = json.decode(data);
    }
  }

  // Live updates kaydet
  Future<void> _saveLiveUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('live_updates', json.encode(_liveUpdates));
  }

  // Live updates yükle
  Future<void> _loadLiveUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('live_updates');
    if (data != null) {
      _liveUpdates = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Performance metrics kaydet
  Future<void> _savePerformanceMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('performance_metrics', json.encode(_performanceMetrics));
  }

  // Performance metrics yükle
  Future<void> _loadPerformanceMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('performance_metrics');
    if (data != null) {
      _performanceMetrics = json.decode(data);
    }
  }

  // Live update ekle
  void addLiveUpdate(String message, String type, String priority) {
    final update = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': message,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'priority': priority,
    };
    
    _liveUpdates.insert(0, update);
    
    if (_liveUpdates.length > 50) {
      _liveUpdates = _liveUpdates.take(50).toList();
    }
    
    _updateController.add(update);
    _saveLiveUpdates();
  }

  // Live update sil
  Future<void> deleteLiveUpdate(String updateId) async {
    _liveUpdates.removeWhere((update) => update['id'] == updateId);
    _saveLiveUpdates();
  }

  // Tüm live updates temizle
  Future<void> clearAllLiveUpdates() async {
    _liveUpdates.clear();
    _saveLiveUpdates();
  }

  // Dashboard istatistikleri
  Map<String, dynamic> getDashboardStats() {
    return {
      'totalUpdates': _liveUpdates.length,
      'lastDataUpdate': _dashboardData['lastUpdate'],
      'lastPerformanceUpdate': _performanceMetrics['lastUpdate'],
      'activeWidgets': _dashboardData.length,
      'dataRefreshRate': '5 seconds',
      'performanceRefreshRate': '10 seconds',
    };
  }

  // Dispose
  void dispose() {
    _dataUpdateTimer?.cancel();
    _performanceTimer?.cancel();
    _notificationTimer?.cancel();
    _dataController.close();
    _updateController.close();
    _performanceController.close();
  }
}
