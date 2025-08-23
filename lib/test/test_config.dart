import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      // Core services - only initialize those that exist and have initialize methods
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

  /// Wait for async operations
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Wait for longer async operations
  static Future<void> waitForLongAsync() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Assert service is initialized
  static void assertServiceInitialized(dynamic service) {
    expect(service, isNotNull);
  }

  /// Assert data is valid
  static void assertDataValid(Map<String, dynamic> data, List<String> requiredFields) {
    for (final field in requiredFields) {
      expect(data.containsKey(field), isTrue, reason: 'Missing required field: $field');
    }
  }

  /// Assert list is not empty
  static void assertListNotEmpty(List list) {
    expect(list, isNotEmpty);
  }

  /// Assert success response
  static void assertSuccessResponse(Map<String, dynamic> response) {
    expect(response['success'], isTrue);
  }

  /// Assert error response
  static void assertErrorResponse(Map<String, dynamic> response) {
    expect(response['error'], isNotNull);
  }

  /// Generate test patient data
  static Map<String, dynamic> generateTestPatientData() {
    return {
      'id': testPatientId,
      'name': 'Test Patient',
      'age': 30,
      'diagnosis': 'Depression',
      'symptoms': ['sadness', 'fatigue'],
      'medications': ['SSRI'],
      'lastVisit': DateTime.now().subtract(const Duration(days: 7)),
    };
  }

  /// Generate test AI analysis data
  static Map<String, dynamic> generateTestAIAnalysisData() {
    return {
      'patientId': testPatientId,
      'analysisType': 'sentiment',
      'confidence': 0.85,
      'timestamp': DateTime.now(),
      'results': {
        'mood': 'negative',
        'stress_level': 0.7,
        'recommendations': ['therapy', 'medication'],
      },
    };
  }

  /// Generate test billing data
  static Map<String, dynamic> generateTestBillingData() {
    return {
      'tenantId': testTenantId,
      'amount': 99.99,
      'currency': 'USD',
      'status': 'pending',
      'createdAt': DateTime.now(),
    };
  }

  /// Generate test collaboration data
  static Map<String, dynamic> generateTestCollaborationData() {
    return {
      'sessionId': 'test_session_001',
      'participants': [testUserId, testClinicianId],
      'startTime': DateTime.now(),
      'status': 'active',
    };
  }

  /// Generate test notification data
  static Map<String, dynamic> generateTestNotificationData() {
    return {
      'id': 'test_notification_001',
      'userId': testUserId,
      'title': 'Test Notification',
      'message': 'This is a test notification',
      'priority': 'high',
      'timestamp': DateTime.now(),
    };
  }

  /// Generate test API request data
  static Map<String, dynamic> generateTestAPIRequestData() {
    return {
      'endpoint': '/api/test',
      'method': 'GET',
      'headers': {'Authorization': 'Bearer test_token'},
      'timestamp': DateTime.now(),
    };
  }

  /// Generate test deployment data
  static Map<String, dynamic> generateTestDeploymentData() {
    return {
      'environment': 'staging',
      'version': '1.0.0',
      'status': 'deploying',
      'startTime': DateTime.now(),
    };
  }
}

/// Test utilities for common operations
class TestUtils {
  /// Create test user
  static Map<String, dynamic> createTestUser() {
    return {
      'id': TestConfig.testUserId,
      'name': 'Test User',
      'email': 'test@example.com',
      'role': 'clinician',
    };
  }

  /// Create test patient
  static Map<String, dynamic> createTestPatient() {
    return {
      'id': TestConfig.testPatientId,
      'name': 'Test Patient',
      'age': 30,
      'diagnosis': 'Depression',
    };
  }

  /// Create test AI task
  static Map<String, dynamic> createTestAITask() {
    return {
      'id': 'test_task_001',
      'type': 'sentiment_analysis',
      'status': 'pending',
      'patientId': TestConfig.testPatientId,
    };
  }

  /// Create test billing record
  static Map<String, dynamic> createTestBillingRecord() {
    return {
      'id': 'test_billing_001',
      'tenantId': TestConfig.testTenantId,
      'amount': 99.99,
      'status': 'pending',
    };
  }

  /// Create test collaboration session
  static Map<String, dynamic> createTestCollaborationSession() {
    return {
      'id': 'test_session_001',
      'type': 'consultation',
      'status': 'active',
      'participants': [TestConfig.testUserId],
    };
  }

  /// Create test notification
  static Map<String, dynamic> createTestNotification() {
    return {
      'id': 'test_notification_001',
      'title': 'Test',
      'message': 'Test message',
      'priority': 'normal',
    };
  }

  /// Create test API endpoint
  static Map<String, dynamic> createTestAPIEndpoint() {
    return {
      'path': '/api/test',
      'method': 'GET',
      'rateLimit': 100,
    };
  }

  /// Create test deployment
  static Map<String, dynamic> createTestDeployment() {
    return {
      'id': 'test_deployment_001',
      'environment': 'staging',
      'version': '1.0.0',
      'status': 'deploying',
    };
  }
}
