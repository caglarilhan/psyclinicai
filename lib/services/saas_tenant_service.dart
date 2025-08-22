import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saas_models.dart';

class SAASTenantService {
  static const String _tenantKey = 'current_tenant';
  static const String _subscriptionKey = 'current_subscription';
  
  Tenant? _currentTenant;
  Subscription? _currentSubscription;
  
  // Singleton pattern
  static final SAASTenantService _instance = SAASTenantService._internal();
  factory SAASTenantService() => _instance;
  SAASTenantService._internal();

  // Get current tenant
  Tenant? get currentTenant => _currentTenant;
  Subscription? get currentSubscription => _currentSubscription;

  // Initialize tenant service
  Future<void> initialize() async {
    await _loadCurrentTenant();
    await _loadCurrentSubscription();
  }

  // Load current tenant from storage
  Future<void> _loadCurrentTenant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tenantJson = prefs.getString(_tenantKey);
      if (tenantJson != null) {
        _currentTenant = Tenant.fromJson(json.decode(tenantJson));
      }
    } catch (e) {
      print('Error loading current tenant: $e');
    }
  }

  // Load current subscription from storage
  Future<void> _loadCurrentSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = prefs.getString(_subscriptionKey);
      if (subscriptionJson != null) {
        _currentSubscription = Subscription.fromJson(json.decode(subscriptionJson));
      }
    } catch (e) {
      print('Error loading current subscription: $e');
    }
  }

  // Set current tenant
  Future<void> setCurrentTenant(Tenant tenant) async {
    _currentTenant = tenant;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tenantKey, json.encode(tenant.toJson()));
    } catch (e) {
      print('Error saving current tenant: $e');
    }
  }

  // Set current subscription
  Future<void> setCurrentSubscription(Subscription subscription) async {
    _currentSubscription = subscription;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_subscriptionKey, json.encode(subscription.toJson()));
    } catch (e) {
      print('Error saving current subscription: $e');
    }
  }

  // Check if feature is available for current tenant
  bool isFeatureAvailable(String featureName) {
    if (_currentSubscription == null) return false;
    return _currentSubscription!.features.contains(featureName);
  }

  // Check if user limit reached
  bool isUserLimitReached(int currentUserCount) {
    if (_currentSubscription == null) return false;
    return currentUserCount >= _currentSubscription!.maxUsers;
  }

  // Check if storage limit reached
  bool isStorageLimitReached(int currentStorageMB) {
    if (_currentSubscription == null) return false;
    return currentStorageMB >= (_currentSubscription!.maxStorageGB * 1024);
  }

  // Get tenant plan limits
  Map<String, dynamic> getPlanLimits() {
    if (_currentSubscription == null) {
      return {
        'maxUsers': 0,
        'maxStorageGB': 0,
        'features': [],
        'limits': {},
      };
    }
    
    return {
      'maxUsers': _currentSubscription!.maxUsers,
      'maxStorageGB': _currentSubscription!.maxStorageGB,
      'features': _currentSubscription!.features,
      'limits': _currentSubscription!.limits,
    };
  }

  // Check if tenant is in trial
  bool get isInTrial {
    if (_currentTenant == null) return false;
    if (_currentTenant!.trialEndsAt == null) return false;
    return DateTime.now().isBefore(_currentTenant!.trialEndsAt!);
  }

  // Get trial days remaining
  int get trialDaysRemaining {
    if (!isInTrial) return 0;
    final remaining = _currentTenant!.trialEndsAt!.difference(DateTime.now());
    return remaining.inDays;
  }

  // Check if subscription is active
  bool get isSubscriptionActive {
    if (_currentSubscription == null) return false;
    return _currentSubscription!.status == SubscriptionStatus.active ||
           _currentSubscription!.status == SubscriptionStatus.trialing;
  }

  // Get tenant region
  String get tenantRegion {
    return _currentTenant?.region ?? 'TR';
  }

  // Get tenant domain
  String get tenantDomain {
    return _currentTenant?.domain ?? 'default';
  }

  // Clear current tenant (logout)
  Future<void> clearCurrentTenant() async {
    _currentTenant = null;
    _currentSubscription = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tenantKey);
      await prefs.remove(_subscriptionKey);
    } catch (e) {
      print('Error clearing tenant data: $e');
    }
  }

  // Mock data for development
  Future<void> loadMockTenant() async {
    final mockTenant = Tenant(
      id: 'mock_tenant_001',
      name: 'Demo Clinic',
      domain: 'demo.psyclinicai.com',
      region: 'TR',
      plan: TenantPlan.professional,
      status: TenantStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      trialEndsAt: DateTime.now().add(const Duration(days: 7)),
    );

    final mockSubscription = Subscription(
      id: 'mock_sub_001',
      tenantId: 'mock_tenant_001',
      planId: 'professional',
      status: SubscriptionStatus.trialing,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 335)),
      trialEndsAt: DateTime.now().add(const Duration(days: 7)),
      maxUsers: 50,
      maxStorageGB: 100,
      features: [
        'ai_diagnosis',
        'telehealth',
        'advanced_analytics',
        'multi_tenant',
        'api_access',
      ],
      limits: {
        'ai_requests_per_month': 10000,
        'video_calls_per_month': 1000,
        'storage_gb': 100,
        'api_rate_limit': 1000,
      },
    );

    await setCurrentTenant(mockTenant);
    await setCurrentSubscription(mockSubscription);
  }
}
