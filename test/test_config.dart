import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psyclinicai/services/ai_analytics_service.dart';
import 'package:psyclinicai/services/predictive_analytics_service.dart';
import 'package:psyclinicai/services/voice_analysis_service.dart';
import 'package:psyclinicai/services/facial_analysis_service.dart';
import 'package:psyclinicai/services/smart_notifications_service.dart';
import 'package:psyclinicai/services/advanced_security_service.dart';
import 'package:psyclinicai/services/biometric_auth_service.dart';
import 'package:psyclinicai/services/offline_service.dart';
import 'package:psyclinicai/services/fhir_integration_service.dart';
import 'package:psyclinicai/services/saas_tenant_service.dart';
import 'package:psyclinicai/services/saas_usage_service.dart';
import 'package:psyclinicai/services/payment_billing_service.dart';
import 'package:psyclinicai/services/realtime_collaboration_service.dart';
import 'package:psyclinicai/services/push_notifications_service.dart';
import 'package:psyclinicai/services/api_gateway_service.dart';
import 'package:psyclinicai/services/production_deployment_service.dart';

/// Test configuration and setup utilities
class TestConfig {
  static const String testUserId = 'test_user_001';
  static const String testTenantId = 'test_tenant_001';
  static const String testPatientId = 'test_patient_001';
  static const String testClinicianId = 'test_clinician_001';

  /// Initialize test environment
  static Future<void> initialize() async {
    // Set up test SharedPreferences
    SharedPreferences.setMockInitialValues({
      'test_key': 'test_value',
      'encryption_key': 'dGVzdF9lbmNyeXB0aW9uX2tleQ==', // base64 encoded test key
      'encryption_iv': 'dGVzdF9pdl92YWx1ZQ==', // base64 encoded test IV
    });

    // Initialize all services for testing
    await _initializeServices();
    
    print('✅ Test environment initialized');
  }

  /// Initialize all services
  static Future<void> _initializeServices() async {
    try {
      // Core services
      await AIAnalyticsService().initialize();
      await PredictiveAnalyticsService().initialize();
      await VoiceAnalysisService().initialize();
      await FacialAnalysisService().initialize();
      await SmartNotificationsService().initialize();
      await AdvancedSecurityService().initialize();
      await BiometricAuthService().initialize();
      await OfflineService().initialize();
      await FHIRIntegrationService().initialize();
      await SAAS tenantService().initialize();
      await SAASUsageService().initialize();
      await PaymentBillingService().initialize();
      await RealtimeCollaborationService().initialize();
      await PushNotificationsService().initialize();
      await APIGatewayService().initialize();
      await ProductionDeploymentService().initialize();
      
      print('✅ All services initialized for testing');
    } catch (e) {
      print('⚠️ Some services failed to initialize: $e');
    }
  }

  /// Clean up test environment
  static Future<void> cleanup() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print('✅ Test environment cleaned up');
    } catch (e) {
      print('⚠️ Error cleaning up test environment: $e');
    }
  }

  /// Generate test data
  static Map<String, dynamic> generateTestPatientData() {
    return {
      'id': testPatientId,
      'name': 'Test Patient',
      'age': 30,
      'diagnosis': 'Test Diagnosis',
      'symptoms': ['Test Symptom 1', 'Test Symptom 2'],
      'medications': ['Test Medication 1'],
      'lastVisit': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    };
  }

  /// Generate test AI analysis data
  static Map<String, dynamic> generateTestAIAnalysisData() {
    return {
      'patientId': testPatientId,
      'analysisType': 'sentiment',
      'inputData': 'Test input data for AI analysis',
      'confidence': 0.85,
      'results': {
        'sentiment': 'positive',
        'risk_level': 'low',
        'recommendations': ['Test recommendation 1', 'Test recommendation 2'],
      },
    };
  }

  /// Generate test billing data
  static Map<String, dynamic> generateTestBillingData() {
    return {
      'tenantId': testTenantId,
      'planName': 'professional',
      'amount': 79.99,
      'currency': 'USD',
      'description': 'Test subscription payment',
    };
  }

  /// Generate test collaboration data
  static Map<String, dynamic> generateTestCollaborationData() {
    return {
      'sessionId': 'test_session_001',
      'title': 'Test Collaboration Session',
      'creatorId': testClinicianId,
      'creatorName': 'Test Clinician',
      'type': 'clinical',
      'description': 'Test collaboration session for testing',
    };
  }

  /// Generate test notification data
  static Map<String, dynamic> generateTestNotificationData() {
    return {
      'title': 'Test Notification',
      'body': 'This is a test notification',
      'category': 'test',
      'targetUserIds': [testClinicianId],
      'priority': 'normal',
      'type': 'info',
    };
  }

  /// Generate test API request data
  static Map<String, dynamic> generateTestAPIRequestData() {
    return {
      'path': '/api/v1/test',
      'method': 'GET',
      'userId': testUserId,
      'userRole': 'clinician',
      'headers': {'Authorization': 'Bearer test_token'},
      'queryParams': {'limit': '10'},
    };
  }

  /// Generate test deployment data
  static Map<String, dynamic> generateTestDeploymentData() {
    return {
      'configId': 'minimal',
      'version': '1.0.0-test',
      'description': 'Test deployment for testing purposes',
      'initiatedBy': testUserId,
      'customConfig': {'test_feature': true},
    };
  }

  /// Wait for async operations
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Wait for longer async operations
  static Future<void> waitForLongAsync() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Assert service is initialized
  static void assertServiceInitialized(dynamic service, String serviceName) {
    expect(service, isNotNull, reason: '$serviceName should be initialized');
  }

  /// Assert data is valid
  static void assertDataValid(Map<String, dynamic> data, List<String> requiredFields) {
    for (final field in requiredFields) {
      expect(data.containsKey(field), true, reason: 'Data should contain $field');
      expect(data[field], isNotNull, reason: '$field should not be null');
    }
  }

  /// Assert list is not empty
  static void assertListNotEmpty(List<dynamic> list, String listName) {
    expect(list, isNotEmpty, reason: '$listName should not be empty');
  }

  /// Assert success response
  static void assertSuccessResponse(Map<String, dynamic> response) {
    expect(response['success'], true, reason: 'Response should be successful');
    expect(response['statusCode'], 200, reason: 'Status code should be 200');
  }

  /// Assert error response
  static void assertErrorResponse(Map<String, dynamic> response, int expectedStatusCode) {
    expect(response['success'], false, reason: 'Response should not be successful');
    expect(response['statusCode'], expectedStatusCode, reason: 'Status code should be $expectedStatusCode');
  }
}

/// Test utilities for common operations
class TestUtils {
  /// Create mock user data
  static Map<String, dynamic> createMockUser({
    String? id,
    String? name,
    String? role,
    String? tenantId,
  }) {
    return {
      'id': id ?? TestConfig.testUserId,
      'name': name ?? 'Test User',
      'role': role ?? 'clinician',
      'tenantId': tenantId ?? TestConfig.testTenantId,
      'email': 'test@example.com',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create mock patient data
  static Map<String, dynamic> createMockPatient({
    String? id,
    String? name,
    int? age,
    String? diagnosis,
  }) {
    return {
      'id': id ?? TestConfig.testPatientId,
      'name': name ?? 'Test Patient',
      'age': age ?? 30,
      'diagnosis': diagnosis ?? 'Test Diagnosis',
      'symptoms': ['Test Symptom 1', 'Test Symptom 2'],
      'medications': ['Test Medication 1'],
      'lastVisit': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    };
  }

  /// Create mock AI task
  static Map<String, dynamic> createMockAITask({
    String? id,
    String? type,
    String? status,
  }) {
    return {
      'id': id ?? 'test_task_001',
      'type': type ?? 'sentiment_analysis',
      'status': status ?? 'pending',
      'inputData': 'Test input data',
      'createdAt': DateTime.now().toIso8601String(),
      'priority': 'normal',
    };
  }

  /// Create mock billing record
  static Map<String, dynamic> createMockBillingRecord({
    String? id,
    String? tenantId,
    double? amount,
    String? status,
  }) {
    return {
      'id': id ?? 'test_billing_001',
      'tenantId': tenantId ?? TestConfig.testTenantId,
      'amount': amount ?? 79.99,
      'currency': 'USD',
      'description': 'Test billing record',
      'status': status ?? 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create mock collaboration session
  static Map<String, dynamic> createMockCollaborationSession({
    String? id,
    String? title,
    String? creatorId,
  }) {
    return {
      'id': id ?? 'test_session_001',
      'title': title ?? 'Test Session',
      'creatorId': creatorId ?? TestConfig.testClinicianId,
      'creatorName': 'Test Clinician',
      'type': 'clinical',
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create mock notification
  static Map<String, dynamic> createMockNotification({
    String? id,
    String? title,
    String? category,
  }) {
    return {
      'id': id ?? 'test_notification_001',
      'title': title ?? 'Test Notification',
      'body': 'Test notification body',
      'category': category ?? 'test',
      'priority': 'normal',
      'type': 'info',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Create mock API endpoint
  static Map<String, dynamic> createMockAPIEndpoint({
    String? path,
    String? method,
    int? rateLimit,
  }) {
    return {
      'path': path ?? '/api/v1/test',
      'method': method ?? 'GET',
      'rateLimit': rateLimit ?? 100,
      'rateLimitWindow': 3600,
      'requiresAuth': true,
      'roles': ['clinician', 'admin'],
      'description': 'Test API endpoint',
    };
  }

  /// Create mock deployment
  static Map<String, dynamic> createMockDeployment({
    String? id,
    String? environment,
    String? version,
  }) {
    return {
      'id': id ?? 'test_deployment_001',
      'environment': environment ?? 'staging',
      'version': version ?? '1.0.0-test',
      'status': 'started',
      'startedAt': DateTime.now().toIso8601String(),
      'estimatedDuration': 600,
    };
  }
}
