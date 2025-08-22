import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saas_models.dart';

class SAASUsageService {
  static const String _usageKey = 'usage_metrics';
  static const String _billingKey = 'billing_records';
  
  // Singleton pattern
  static final SAASUsageService _instance = SAASUsageService._internal();
  factory SAASUsageService() => _instance;
  SAASUsageService._internal();

  // Track AI request usage
  Future<void> trackAIRequest(String tenantId, String feature, {Map<String, dynamic>? metadata}) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final prefs = await SharedPreferences.getInstance();
      final usageKey = '${_usageKey}_${tenantId}_$dateKey';
      
      String? existingJson = prefs.getString(usageKey);
      UsageMetrics metrics;
      
      if (existingJson != null) {
        metrics = UsageMetrics.fromJson(json.decode(existingJson));
        // Update existing metrics
        metrics = UsageMetrics(
          id: metrics.id,
          tenantId: metrics.tenantId,
          date: metrics.date,
          activeUsers: metrics.activeUsers,
          totalSessions: metrics.totalSessions,
          aiRequests: metrics.aiRequests + 1,
          storageUsedMB: metrics.storageUsedMB,
          apiCalls: metrics.apiCalls + 1,
          featureUsage: {
            ...metrics.featureUsage,
            feature: (metrics.featureUsage[feature] ?? 0) + 1,
          },
          metadata: metadata ?? metrics.metadata,
        );
      } else {
        // Create new metrics
        metrics = UsageMetrics(
          id: 'usage_${tenantId}_$dateKey',
          tenantId: tenantId,
          date: today,
          activeUsers: 0,
          totalSessions: 0,
          aiRequests: 1,
          storageUsedMB: 0,
          apiCalls: 1,
          featureUsage: {feature: 1},
          metadata: metadata ?? {},
        );
      }
      
      await prefs.setString(usageKey, json.encode(metrics.toJson()));
    } catch (e) {
      print('Error tracking AI request: $e');
    }
  }

  // Track storage usage
  Future<void> trackStorageUsage(String tenantId, int sizeMB) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final prefs = await SharedPreferences.getInstance();
      final usageKey = '${_usageKey}_${tenantId}_$dateKey';
      
      String? existingJson = prefs.getString(usageKey);
      UsageMetrics metrics;
      
      if (existingJson != null) {
        metrics = UsageMetrics.fromJson(json.decode(existingJson));
        metrics = UsageMetrics(
          id: metrics.id,
          tenantId: metrics.tenantId,
          date: metrics.date,
          activeUsers: metrics.activeUsers,
          totalSessions: metrics.totalSessions,
          aiRequests: metrics.aiRequests,
          storageUsedMB: metrics.storageUsedMB + sizeMB,
          apiCalls: metrics.apiCalls,
          featureUsage: metrics.featureUsage,
          metadata: metrics.metadata,
        );
      } else {
        metrics = UsageMetrics(
          id: 'usage_${tenantId}_$dateKey',
          tenantId: tenantId,
          date: today,
          activeUsers: 0,
          totalSessions: 0,
          aiRequests: 0,
          storageUsedMB: sizeMB,
          apiCalls: 0,
          featureUsage: {},
          metadata: {},
        );
      }
      
      await prefs.setString(usageKey, json.encode(metrics.toJson()));
    } catch (e) {
      print('Error tracking storage usage: $e');
    }
  }

  // Track user session
  Future<void> trackUserSession(String tenantId, String userId) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final prefs = await SharedPreferences.getInstance();
      final usageKey = '${_usageKey}_${tenantId}_$dateKey';
      
      String? existingJson = prefs.getString(usageKey);
      UsageMetrics metrics;
      
      if (existingJson != null) {
        metrics = UsageMetrics.fromJson(json.decode(existingJson));
        
        // Check if user already counted today
        final userSessionsKey = 'user_sessions_${tenantId}_$dateKey';
        final userSessionsJson = prefs.getString(userSessionsKey);
        Set<String> userSessions = {};
        
        if (userSessionsJson != null) {
          userSessions = Set<String>.from(json.decode(userSessionsJson));
        }
        
        final newUser = userSessions.add(userId);
        
        metrics = UsageMetrics(
          id: metrics.id,
          tenantId: metrics.tenantId,
          date: metrics.date,
          activeUsers: userSessions.length,
          totalSessions: metrics.totalSessions + 1,
          aiRequests: metrics.aiRequests,
          storageUsedMB: metrics.storageUsedMB,
          apiCalls: metrics.apiCalls,
          featureUsage: metrics.featureUsage,
          metadata: metrics.metadata,
        );
        
        // Save user sessions
        await prefs.setString(userSessionsKey, json.encode(userSessions.toList()));
      } else {
        metrics = UsageMetrics(
          id: 'usage_${tenantId}_$dateKey',
          tenantId: tenantId,
          date: today,
          activeUsers: 1,
          totalSessions: 1,
          aiRequests: 0,
          storageUsedMB: 0,
          apiCalls: 0,
          featureUsage: {},
          metadata: {},
        );
        
        // Save user sessions
        final userSessionsKey = 'user_sessions_${tenantId}_$dateKey';
        await prefs.setString(userSessionsKey, json.encode([userId]));
      }
      
      await prefs.setString(usageKey, json.encode(metrics.toJson()));
    } catch (e) {
      print('Error tracking user session: $e');
    }
  }

  // Get usage metrics for a specific date
  Future<UsageMetrics?> getUsageMetrics(String tenantId, DateTime date) async {
    try {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final prefs = await SharedPreferences.getInstance();
      final usageKey = '${_usageKey}_${tenantId}_$dateKey';
      
      final usageJson = prefs.getString(usageKey);
      if (usageJson != null) {
        return UsageMetrics.fromJson(json.decode(usageJson));
      }
      return null;
    } catch (e) {
      print('Error getting usage metrics: $e');
      return null;
    }
  }

  // Get usage metrics for a date range
  Future<List<UsageMetrics>> getUsageMetricsRange(String tenantId, DateTime startDate, DateTime endDate) async {
    final List<UsageMetrics> metrics = [];
    
    try {
      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        final metricsForDate = await getUsageMetrics(tenantId, currentDate);
        if (metricsForDate != null) {
          metrics.add(metricsForDate);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    } catch (e) {
      print('Error getting usage metrics range: $e');
    }
    
    return metrics;
  }

  // Get current month usage
  Future<UsageMetrics?> getCurrentMonthUsage(String tenantId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final monthUsageKey = 'monthly_usage_${tenantId}_$monthKey';
      
      final monthUsageJson = prefs.getString(monthUsageKey);
      if (monthUsageJson != null) {
        return UsageMetrics.fromJson(json.decode(monthUsageJson));
      }
      
      // Calculate monthly totals from daily metrics
      final dailyMetrics = await getUsageMetricsRange(tenantId, startOfMonth, now);
      if (dailyMetrics.isEmpty) return null;
      
      // Aggregate daily metrics
      int totalAIRequests = 0;
      int totalSessions = 0;
      int totalStorageMB = 0;
      int totalAPICalls = 0;
      Map<String, dynamic> totalFeatureUsage = {};
      Set<String> uniqueUsers = {};
      
      for (final metric in dailyMetrics) {
        totalAIRequests += metric.aiRequests;
        totalSessions += metric.totalSessions;
        totalStorageMB += metric.storageUsedMB;
        totalAPICalls += metric.apiCalls;
        
        // Aggregate feature usage
        for (final entry in metric.featureUsage.entries) {
          totalFeatureUsage[entry.key] = (totalFeatureUsage[entry.key] ?? 0) + entry.value;
        }
      }
      
      // Get unique users for the month
      for (final metric in dailyMetrics) {
        final userSessionsKey = 'user_sessions_${tenantId}_${metric.date.year}-${metric.date.month.toString().padLeft(2, '0')}-${metric.date.day.toString().padLeft(2, '0')}';
        final userSessionsJson = prefs.getString(userSessionsKey);
        if (userSessionsJson != null) {
          final users = List<String>.from(json.decode(userSessionsJson));
          uniqueUsers.addAll(users);
        }
      }
      
      final monthlyMetrics = UsageMetrics(
        id: 'monthly_${tenantId}_$monthKey',
        tenantId: tenantId,
        date: startOfMonth,
        activeUsers: uniqueUsers.length,
        totalSessions: totalSessions,
        aiRequests: totalAIRequests,
        storageUsedMB: totalStorageMB,
        apiCalls: totalAPICalls,
        featureUsage: totalFeatureUsage,
        metadata: {},
      );
      
      // Save monthly metrics
      await prefs.setString(monthUsageKey, json.encode(monthlyMetrics.toJson()));
      
      return monthlyMetrics;
    } catch (e) {
      print('Error getting current month usage: $e');
      return null;
    }
  }

  // Check if usage limits exceeded
  Future<Map<String, bool>> checkUsageLimits(String tenantId, Map<String, dynamic> limits) async {
    try {
      final currentMonthUsage = await getCurrentMonthUsage(tenantId);
      if (currentMonthUsage == null) {
        return {
          'ai_requests': false,
          'storage': false,
          'api_calls': false,
        };
      }
      
      return {
        'ai_requests': currentMonthUsage!.aiRequests >= (limits['ai_requests_per_month'] ?? 0),
        'storage': currentMonthUsage!.storageUsedMB >= ((limits['storage_gb'] ?? 0) * 1024),
        'api_calls': currentMonthUsage!.apiCalls >= (limits['api_rate_limit'] ?? 0),
      };
    } catch (e) {
      print('Error checking usage limits: $e');
      return {
        'ai_requests': false,
        'storage': false,
        'api_calls': false,
      };
    }
  }

  // Generate usage report
  Future<Map<String, dynamic>> generateUsageReport(String tenantId, DateTime startDate, DateTime endDate) async {
    try {
      final metrics = await getUsageMetricsRange(tenantId, startDate, endDate);
      
      if (metrics.isEmpty) {
        return {
          'total_ai_requests': 0,
          'total_sessions': 0,
          'total_storage_mb': 0,
          'total_api_calls': 0,
          'average_daily_users': 0,
          'feature_usage': {},
          'period': '${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
        };
      }
      
      int totalAIRequests = 0;
      int totalSessions = 0;
      int totalStorageMB = 0;
      int totalAPICalls = 0;
      Map<String, dynamic> totalFeatureUsage = {};
      Set<String> uniqueUsers = {};
      
      for (final metric in metrics) {
        totalAIRequests += metric.aiRequests;
        totalSessions += metric.totalSessions;
        totalStorageMB += metric.storageUsedMB;
        totalAPICalls += metric.apiCalls;
        
        for (final entry in metric.featureUsage.entries) {
          totalFeatureUsage[entry.key] = (totalFeatureUsage[entry.key] ?? 0) + entry.value;
        }
      }
      
      final daysInPeriod = endDate.difference(startDate).inDays + 1;
      final averageDailyUsers = uniqueUsers.length / daysInPeriod;
      
      return {
        'total_ai_requests': totalAIRequests,
        'total_sessions': totalSessions,
        'total_storage_mb': totalStorageMB,
        'total_api_calls': totalAPICalls,
        'average_daily_users': averageDailyUsers.round(),
        'feature_usage': totalFeatureUsage,
        'period': '${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
        'daily_breakdown': metrics.map((m) => m.toJson()).toList(),
      };
    } catch (e) {
      print('Error generating usage report: $e');
      return {
        'error': e.toString(),
        'period': '${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      };
    }
  }
}
