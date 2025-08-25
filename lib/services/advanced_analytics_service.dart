import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/advanced_analytics_models.dart';

/// Advanced Analytics Service for comprehensive business intelligence
class AdvancedAnalyticsService {
  static const String _analyticsUrl = 'https://api.analytics.psycliniciai.com/v1';
  static const String _apiKey = 'demo_analytics_key_12345';
  
  // Analytics data cache
  final Map<String, dynamic> _analyticsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Stream controllers for real-time analytics
  final StreamController<Map<String, dynamic>> _analyticsController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _insightsController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  /// Initialize the analytics service
  Future<void> initialize() async {
    await _loadAnalyticsData();
  }

  /// Get comprehensive BI dashboard data
  Future<BIDashboardData> getBIDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/bi-dashboard'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BIDashboardData.fromJson(data);
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    return _getMockBIDashboardData();
  }

  /// Get financial analytics
  Future<Map<String, dynamic>> getFinancialAnalytics({Duration? timeRange}) async {
    final cacheKey = 'financial_${timeRange?.inDays ?? 30}';
    
    if (_isCacheValid(cacheKey)) {
      return _analyticsCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/financial?days=${timeRange?.inDays ?? 30}'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateCache(cacheKey, data);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    final mockData = _getMockFinancialAnalytics(timeRange);
    _updateCache(cacheKey, mockData);
    return mockData;
  }

  /// Get operational analytics
  Future<Map<String, dynamic>> getOperationalAnalytics({Duration? timeRange}) async {
    final cacheKey = 'operational_${timeRange?.inDays ?? 30}';
    
    if (_isCacheValid(cacheKey)) {
      return _analyticsCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/operational?days=${timeRange?.inDays ?? 30}'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateCache(cacheKey, data);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    final mockData = _getMockOperationalAnalytics(timeRange);
    _updateCache(cacheKey, mockData);
    return mockData;
  }

  /// Get patient analytics
  Future<Map<String, dynamic>> getPatientAnalytics({Duration? timeRange}) async {
    final cacheKey = 'patient_${timeRange?.inDays ?? 30}';
    
    if (_isCacheValid(cacheKey)) {
      return _analyticsCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/patient?days=${timeRange?.inDays ?? 30}'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateCache(cacheKey, data);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    final mockData = _getMockPatientAnalytics(timeRange);
    _updateCache(cacheKey, mockData);
    return mockData;
  }

  /// Get staff performance analytics
  Future<Map<String, dynamic>> getStaffAnalytics({Duration? timeRange}) async {
    final cacheKey = 'staff_${timeRange?.inDays ?? 30}';
    
    if (_isCacheValid(cacheKey)) {
      return _analyticsCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/staff?days=${timeRange?.inDays ?? 30}'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateCache(cacheKey, data);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    final mockData = _getMockStaffAnalytics(timeRange);
    _updateCache(cacheKey, mockData);
    return mockData;
  }

  /// Get quality metrics analytics
  Future<Map<String, dynamic>> getQualityAnalytics({Duration? timeRange}) async {
    final cacheKey = 'quality_${timeRange?.inDays ?? 30}';
    
    if (_isCacheValid(cacheKey)) {
      return _analyticsCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/quality?days=${timeRange?.inDays ?? 30}'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateCache(cacheKey, data);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    final mockData = _getMockQualityAnalytics(timeRange);
    _updateCache(cacheKey, mockData);
    return mockData;
  }

  /// Get predictive analytics models
  Future<List<PredictiveModel>> getPredictiveModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/predictive-models'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PredictiveModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    return _getMockPredictiveModels();
  }

  /// Get performance metrics
  Future<List<PerformanceMetrics>> getPerformanceMetrics({String? category}) async {
    try {
      final url = category != null 
          ? '$_analyticsUrl/performance-metrics?category=$category'
          : '$_analyticsUrl/performance-metrics';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PerformanceMetrics.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    return _getMockPerformanceMetrics(category);
  }

  /// Generate business insights
  Future<List<Map<String, dynamic>>> generateBusinessInsights() async {
    try {
      final response = await http.post(
        Uri.parse('$_analyticsUrl/generate-insights'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'includeRecommendations': true,
        }),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Map<String, dynamic>.from(json)).toList();
      }
    } catch (e) {
      // Fallback to mock insights
    }
    
    return _getMockBusinessInsights();
  }

  /// Get trend analysis
  Future<Map<String, dynamic>> getTrendAnalysis({
    String? metric,
    Duration? timeRange,
    String? granularity,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (metric != null) queryParams['metric'] = metric;
      if (timeRange != null) queryParams['days'] = timeRange.inDays.toString();
      if (granularity != null) queryParams['granularity'] = granularity;
      
      final uri = Uri.parse('$_analyticsUrl/trend-analysis').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    return _getMockTrendAnalysis(metric, timeRange, granularity);
  }

  /// Get comparative analysis
  Future<Map<String, dynamic>> getComparativeAnalysis({
    String? metric,
    String? comparisonType,
    Duration? timeRange,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (metric != null) queryParams['metric'] = metric;
      if (comparisonType != null) queryParams['comparisonType'] = comparisonType;
      if (timeRange != null) queryParams['days'] = timeRange.inDays.toString();
      
      final uri = Uri.parse('$_analyticsUrl/comparative-analysis').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    return _getMockComparativeAnalysis(metric, comparisonType, timeRange);
  }

  /// Get real-time analytics
  Future<Map<String, dynamic>> getRealTimeAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$_analyticsUrl/real-time'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _analyticsController.add(data);
        return data;
      }
    } catch (e) {
      // Fallback to mock data
    }
    
    final mockData = _getMockRealTimeAnalytics();
    _analyticsController.add(mockData);
    return mockData;
  }

  /// Export analytics data
  Future<String> exportAnalyticsData({
    String format = 'csv',
    Duration? timeRange,
    List<String>? metrics,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_analyticsUrl/export'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'format': format,
          'timeRange': timeRange?.inDays,
          'metrics': metrics,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['downloadUrl'] ?? 'Export failed';
      }
    } catch (e) {
      return 'Export failed: ${e.toString()}';
    }
    
    return 'Mock export completed';
  }

  // Private helper methods

  bool _isCacheValid(String key) {
    if (!_cacheTimestamps.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key]!;
    final age = DateTime.now().difference(timestamp);
    
    // Cache valid for 5 minutes
    return age.inMinutes < 5;
  }

  void _updateCache(String key, dynamic data) {
    _analyticsCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  Future<void> _loadAnalyticsData() async {
    // Load initial analytics data
    await getBIDashboardData();
    await getFinancialAnalytics();
    await getOperationalAnalytics();
    await getPatientAnalytics();
    await getStaffAnalytics();
    await getQualityAnalytics();
  }

  // Mock data methods

  BIDashboardData _getMockBIDashboardData() {
    return BIDashboardData(
      financialMetrics: {
        'revenue': 125000.0,
        'expenses': 85000.0,
        'profit': 40000.0,
        'profitMargin': 32.0,
        'revenueGrowth': 15.5,
        'expenseGrowth': 8.2,
      },
      operationalMetrics: {
        'appointments': 450,
        'noShows': 23,
        'showRate': 94.9,
        'averageSessionDuration': 55.0,
        'utilizationRate': 87.3,
        'waitTime': 12.5,
      },
      patientMetrics: {
        'totalPatients': 1250,
        'newPatients': 45,
        'returningPatients': 1205,
        'patientSatisfaction': 4.6,
        'retentionRate': 89.2,
        'averageAge': 34.5,
      },
      staffMetrics: {
        'totalStaff': 18,
        'therapists': 12,
        'supportStaff': 6,
        'staffSatisfaction': 4.4,
        'turnoverRate': 8.5,
        'productivity': 92.1,
      },
      qualityMetrics: {
        'treatmentSuccess': 87.5,
        'patientOutcomes': 4.3,
        'complianceRate': 96.8,
        'safetyIncidents': 0,
        'accreditationScore': 94.2,
        'qualityRating': 4.7,
      },
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> _getMockFinancialAnalytics(Duration? timeRange) {
    final days = timeRange?.inDays ?? 30;
    final random = Random();
    
    return {
      'revenue': {
        'total': 125000.0 + (random.nextDouble() * 10000),
        'trend': 'increasing',
        'breakdown': {
          'therapy_sessions': 85000.0,
          'medication_management': 25000.0,
          'assessments': 15000.0,
        },
        'projection': 135000.0,
      },
      'expenses': {
        'total': 85000.0 + (random.nextDouble() * 5000),
        'trend': 'stable',
        'breakdown': {
          'staff_salaries': 60000.0,
          'facility_costs': 15000.0,
          'technology': 5000.0,
          'marketing': 5000.0,
        },
      },
      'profitability': {
        'gross_margin': 32.0,
        'net_margin': 28.5,
        'ebitda': 45000.0,
        'roi': 18.5,
      },
    };
  }

  Map<String, dynamic> _getMockOperationalAnalytics(Duration? timeRange) {
    final days = timeRange?.inDays ?? 30;
    final random = Random();
    
    return {
      'efficiency': {
        'appointment_utilization': 87.3 + (random.nextDouble() * 5),
        'staff_productivity': 92.1 + (random.nextDouble() * 3),
        'resource_optimization': 89.5 + (random.nextDouble() * 4),
      },
      'capacity': {
        'total_capacity': 500,
        'used_capacity': 450,
        'available_capacity': 50,
        'capacity_utilization': 90.0,
      },
      'quality': {
        'patient_satisfaction': 4.6 + (random.nextDouble() * 0.2),
        'treatment_outcomes': 87.5 + (random.nextDouble() * 3),
        'compliance_rate': 96.8 + (random.nextDouble() * 2),
      },
    };
  }

  Map<String, dynamic> _getMockPatientAnalytics(Duration? timeRange) {
    final days = timeRange?.inDays ?? 30;
    final random = Random();
    
    return {
      'demographics': {
        'age_distribution': {
          '18-25': 25.0,
          '26-35': 35.0,
          '36-45': 20.0,
          '46-55': 15.0,
          '55+': 5.0,
        },
        'gender_distribution': {
          'female': 65.0,
          'male': 30.0,
          'non_binary': 5.0,
        },
      },
      'behavior': {
        'appointment_attendance': 94.9 + (random.nextDouble() * 2),
        'treatment_compliance': 89.2 + (random.nextDouble() * 3),
        'patient_retention': 87.5 + (random.nextDouble() * 4),
      },
      'outcomes': {
        'symptom_improvement': 82.3 + (random.nextDouble() * 5),
        'functional_improvement': 78.9 + (random.nextDouble() * 4),
        'quality_of_life': 4.2 + (random.nextDouble() * 0.3),
      },
    };
  }

  Map<String, dynamic> _getMockStaffAnalytics(Duration? timeRange) {
    final days = timeRange?.inDays ?? 30;
    final random = Random();
    
    return {
      'performance': {
        'productivity': 92.1 + (random.nextDouble() * 3),
        'efficiency': 88.7 + (random.nextDouble() * 4),
        'quality_score': 4.4 + (random.nextDouble() * 0.2),
      },
      'satisfaction': {
        'overall_satisfaction': 4.4 + (random.nextDouble() * 0.2),
        'work_life_balance': 4.2 + (random.nextDouble() * 0.3),
        'career_growth': 4.1 + (random.nextDouble() * 0.3),
      },
      'retention': {
        'turnover_rate': 8.5 + (random.nextDouble() * 2),
        'average_tenure': 4.2 + (random.nextDouble() * 0.5),
        'retention_rate': 91.5 + (random.nextDouble() * 3),
      },
    };
  }

  Map<String, dynamic> _getMockQualityAnalytics(Duration? timeRange) {
    final days = timeRange?.inDays ?? 30;
    final random = Random();
    
    return {
      'clinical_quality': {
        'treatment_success': 87.5 + (random.nextDouble() * 3),
        'patient_outcomes': 4.3 + (random.nextDouble() * 0.2),
        'evidence_based_practices': 94.2 + (random.nextDouble() * 2),
      },
      'safety': {
        'incident_rate': 0.0,
        'near_misses': 2,
        'safety_score': 98.5 + (random.nextDouble() * 1),
      },
      'compliance': {
        'regulatory_compliance': 96.8 + (random.nextDouble() * 2),
        'accreditation_score': 94.2 + (random.nextDouble() * 2),
        'audit_results': 'Passed',
      },
    };
  }

  List<PredictiveModel> _getMockPredictiveModels() {
    return [
      PredictiveModel(
        id: 'patient_attrition',
        name: 'Patient Attrition Prediction',
        description: 'Predicts likelihood of patient dropout',
        type: 'classification',
        accuracy: 0.87,
        lastTrained: DateTime.now().subtract(const Duration(days: 7)),
        parameters: {'algorithm': 'random_forest', 'features': 15},
        features: ['age', 'diagnosis', 'attendance_rate', 'satisfaction_score'],
        performance: {'precision': 0.85, 'recall': 0.89, 'f1_score': 0.87},
      ),
      PredictiveModel(
        id: 'revenue_forecast',
        name: 'Revenue Forecasting',
        description: 'Predicts future revenue based on historical data',
        type: 'regression',
        accuracy: 0.92,
        lastTrained: DateTime.now().subtract(const Duration(days: 14)),
        parameters: {'algorithm': 'lstm', 'lookback': 30},
        features: ['historical_revenue', 'seasonality', 'marketing_spend'],
        performance: {'mae': 0.08, 'rmse': 0.12, 'r2': 0.92},
      ),
      PredictiveModel(
        id: 'staff_turnover',
        name: 'Staff Turnover Prediction',
        description: 'Identifies staff at risk of leaving',
        type: 'classification',
        accuracy: 0.79,
        lastTrained: DateTime.now().subtract(const Duration(days: 21)),
        parameters: {'algorithm': 'gradient_boosting', 'features': 12},
        features: ['tenure', 'satisfaction', 'performance', 'workload'],
        performance: {'precision': 0.81, 'recall': 0.77, 'f1_score': 0.79},
      ),
    ];
  }

  List<PerformanceMetrics> _getMockPerformanceMetrics(String? category) {
    final random = Random();
    final metrics = <PerformanceMetrics>[];
    
    if (category == null || category == 'financial') {
      metrics.add(PerformanceMetrics(
        metricId: 'revenue_growth',
        name: 'Revenue Growth',
        category: 'financial',
        currentValue: 15.5 + (random.nextDouble() * 2),
        previousValue: 12.3,
        targetValue: 20.0,
        changePercentage: 26.0,
        trend: 'increasing',
        lastUpdated: DateTime.now(),
        metadata: {'currency': 'USD', 'period': 'monthly'},
      ));
    }
    
    if (category == null || category == 'operational') {
      metrics.add(PerformanceMetrics(
        metricId: 'patient_satisfaction',
        name: 'Patient Satisfaction',
        category: 'operational',
        currentValue: 4.6 + (random.nextDouble() * 0.2),
        previousValue: 4.4,
        targetValue: 4.5,
        changePercentage: 4.5,
        trend: 'increasing',
        lastUpdated: DateTime.now(),
        metadata: {'scale': '1-5', 'sample_size': 1250},
      ));
    }
    
    if (category == null || category == 'quality') {
      metrics.add(PerformanceMetrics(
        metricId: 'treatment_success',
        name: 'Treatment Success Rate',
        category: 'quality',
        currentValue: 87.5 + (random.nextDouble() * 3),
        previousValue: 85.2,
        targetValue: 90.0,
        changePercentage: 2.7,
        trend: 'increasing',
        lastUpdated: DateTime.now(),
        metadata: {'measurement': 'percentage', 'timeframe': '6_months'},
      ));
    }
    
    return metrics;
  }

  List<Map<String, dynamic>> _getMockBusinessInsights() {
    return [
      {
        'type': 'opportunity',
        'title': 'Revenue Growth Opportunity',
        'description': 'Patient satisfaction scores above 4.5 correlate with 15% higher retention rates',
        'impact': 'high',
        'confidence': 0.87,
        'recommendations': [
          'Focus on improving patient experience',
          'Implement satisfaction surveys',
          'Train staff on patient communication',
        ],
        'metrics': ['patient_satisfaction', 'retention_rate', 'revenue'],
      },
      {
        'type': 'risk',
        'title': 'Staff Turnover Risk',
        'description': 'Staff satisfaction has decreased by 8% over the last quarter',
        'impact': 'medium',
        'confidence': 0.79,
        'recommendations': [
          'Conduct staff satisfaction surveys',
          'Review workload distribution',
          'Implement professional development programs',
        ],
        'metrics': ['staff_satisfaction', 'turnover_rate', 'productivity'],
      },
      {
        'type': 'trend',
        'title': 'Seasonal Patient Volume',
        'description': 'Patient volume increases by 25% during winter months',
        'impact': 'low',
        'confidence': 0.92,
        'recommendations': [
          'Adjust staffing levels seasonally',
          'Plan marketing campaigns accordingly',
          'Optimize resource allocation',
        ],
        'metrics': ['patient_volume', 'seasonality', 'resource_utilization'],
      },
    ];
  }

  Map<String, dynamic> _getMockTrendAnalysis(String? metric, Duration? timeRange, String? granularity) {
    final days = timeRange?.inDays ?? 30;
    final random = Random();
    
    return {
      'metric': metric ?? 'overall_performance',
      'timeRange': days,
      'granularity': granularity ?? 'daily',
      'trend': 'increasing',
      'data': List.generate(days, (index) {
        return {
          'date': DateTime.now().subtract(Duration(days: days - index - 1)).toIso8601String(),
          'value': 80.0 + (random.nextDouble() * 20) + (index * 0.5),
        };
      }),
      'summary': {
        'startValue': 80.0,
        'endValue': 95.0,
        'change': 15.0,
        'changePercentage': 18.75,
        'trend': 'increasing',
      },
    };
  }

  Map<String, dynamic> _getMockComparativeAnalysis(String? metric, String? comparisonType, Duration? timeRange) {
    final days = timeRange?.inDays ?? 30;
    final random = Random();
    
    return {
      'metric': metric ?? 'patient_satisfaction',
      'comparisonType': comparisonType ?? 'period_comparison',
      'timeRange': days,
      'currentPeriod': {
        'start': DateTime.now().subtract(Duration(days: days)).toIso8601String(),
        'end': DateTime.now().toIso8601String(),
        'value': 4.6 + (random.nextDouble() * 0.2),
      },
      'previousPeriod': {
        'start': DateTime.now().subtract(Duration(days: days * 2)).toIso8601String(),
        'end': DateTime.now().subtract(Duration(days: days)).toIso8601String(),
        'value': 4.4,
      },
      'comparison': {
        'difference': 0.2,
        'percentageChange': 4.5,
        'trend': 'improving',
        'significance': 'statistically_significant',
      },
    };
  }

  Map<String, dynamic> _getMockRealTimeAnalytics() {
    final random = Random();
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'activePatients': 25 + random.nextInt(10),
      'activeSessions': 8 + random.nextInt(5),
      'waitingPatients': 3 + random.nextInt(3),
      'staffOnline': 12 + random.nextInt(3),
      'systemStatus': 'healthy',
      'performance': {
        'responseTime': 0.8 + (random.nextDouble() * 0.4),
        'uptime': 99.9 + (random.nextDouble() * 0.1),
        'errorRate': 0.01 + (random.nextDouble() * 0.02),
      },
    };
  }

  /// Get streams for real-time analytics
  Stream<Map<String, dynamic>> get analyticsStream => _analyticsController.stream;
  Stream<Map<String, dynamic>> get insightsStream => _insightsController.stream;

  /// Dispose resources
  void dispose() {
    _analyticsController.close();
    _insightsController.close();
  }
}
