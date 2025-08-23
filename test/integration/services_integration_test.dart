import 'package:flutter_test/flutter_test.dart';
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
import '../test_config.dart';

void main() {
  group('Services Integration Tests', () {
    late AIAnalyticsService aiService;
    late PredictiveAnalyticsService predictiveService;
    late VoiceAnalysisService voiceService;
    late FacialAnalysisService facialService;
    late SmartNotificationsService smartNotificationsService;
    late AdvancedSecurityService securityService;
    late BiometricAuthService biometricService;
    late OfflineService offlineService;
    late FHIRIntegrationService fhirService;
    late SAAS tenantService;
    late SAASUsageService usageService;
    late PaymentBillingService billingService;
    late RealtimeCollaborationService collaborationService;
    late PushNotificationsService pushNotificationsService;
    late APIGatewayService apiGatewayService;
    late ProductionDeploymentService deploymentService;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    setUp(() {
      aiService = AIAnalyticsService();
      predictiveService = PredictiveAnalyticsService();
      voiceService = VoiceAnalysisService();
      facialService = FacialAnalysisService();
      smartNotificationsService = SmartNotificationsService();
      securityService = AdvancedSecurityService();
      biometricService = BiometricAuthService();
      offlineService = OfflineService();
      fhirService = FHIRIntegrationService();
      tenantService = SAAS tenantService();
      usageService = SAASUsageService();
      billingService = PaymentBillingService();
      collaborationService = RealtimeCollaborationService();
      pushNotificationsService = PushNotificationsService();
      apiGatewayService = APIGatewayService();
      deploymentService = ProductionDeploymentService();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group('AI Services Integration', () {
      test('should integrate AI analytics with predictive analytics', () async {
        // Create AI task
        final aiTask = await aiService.createAITask(
          type: 'sentiment_analysis',
          inputData: 'Patient shows signs of depression',
          priority: 'high',
        );

        expect(aiTask, isNotNull);
        expect(aiTask.id, isNotEmpty);

        // Execute AI task
        final aiResult = await aiService.executeTask(aiTask.id);
        expect(aiResult['success'], isTrue);

        // Get predictive analytics
        final predictions = await predictiveService.getAvailableModels();
        expect(predictions, isNotEmpty);

        // Create treatment outcome prediction
        final treatmentPrediction = await predictiveService.predictTreatmentOutcome(
          patientId: TestConfig.testPatientId,
          treatmentData: {
            'medication': 'Sertraline',
            'dosage': '50mg',
            'duration': '8 weeks',
            'patient_data': aiResult['results'],
          },
        );

        expect(treatmentPrediction, isNotNull);
        expect(treatmentPrediction.patientId, equals(TestConfig.testPatientId));
        expect(treatmentPrediction.prediction, isNotNull);
      });

      test('should integrate voice and facial analysis', () async {
        // Start voice analysis
        await voiceService.startVoiceAnalysis(
          sessionId: 'test_voice_session',
          patientId: TestConfig.testPatientId,
        );

        // Start facial analysis
        await facialService.startFacialAnalysis(
          sessionId: 'test_facial_session',
          patientId: TestConfig.testPatientId,
        );

        // Wait for analysis
        await TestConfig.waitForLongAsync();

        // Get voice analysis results
        final voiceResults = voiceService.analysisStream;
        expect(voiceResults, isNotNull);

        // Get facial analysis results
        final facialResults = facialService.analysisStream;
        expect(facialResults, isNotNull);

        // Stop analysis
        await voiceService.stopVoiceAnalysis();
        await facialService.stopFacialAnalysis();
      });
    });

    group('Security and Authentication Integration', () {
      test('should integrate security with biometric authentication', () async {
        // Initialize security service
        await securityService.initialize();

        // Create biometric profile
        final profile = await biometricService.createBiometricProfile(
          userId: TestConfig.testUserId,
          biometricType: 'fingerprint',
          biometricData: 'test_fingerprint_data',
        );

        expect(profile, isNotNull);
        expect(profile.userId, equals(TestConfig.testUserId));

        // Encrypt sensitive data
        final encryptedData = await securityService.encryptData('sensitive_patient_data');
        expect(encryptedData, isNotEmpty);

        // Decrypt data
        final decryptedData = await securityService.decryptData(encryptedData);
        expect(decryptedData, equals('sensitive_patient_data'));

        // Log security event
        await securityService.logSecurityEvent(
          userId: TestConfig.testUserId,
          action: 'biometric_authentication',
          details: 'Fingerprint authentication successful',
          securityLevel: 'high',
        );
      });

      test('should integrate offline service with security', () async {
        // Initialize offline service
        await offlineService.initialize();

        // Enable offline mode
        await offlineService.enableOfflineMode();

        // Save offline data with encryption
        final secureData = await securityService.encryptData('offline_patient_data');
        await offlineService.saveOfflineData(
          key: 'patient_001_notes',
          dataType: 'patient_notes',
          content: secureData,
        );

        // Verify offline data
        final offlineData = await offlineService.getOfflineDataByKey('patient_001_notes');
        expect(offlineData, isNotNull);
        expect(offlineData!.content, equals(secureData));

        // Disable offline mode
        await offlineService.disableOfflineMode();
      });
    });

    group('SaaS and Billing Integration', () {
      test('should integrate tenant service with billing', () async {
        // Initialize services
        await tenantService.initialize();
        await billingService.initialize();

        // Create tenant
        final tenant = await tenantService.createTenant(
          name: 'Test Clinic',
          domain: 'testclinic.com',
          region: 'TR',
          plan: 'professional',
        );

        expect(tenant, isNotNull);
        expect(tenant.name, equals('Test Clinic'));

        // Create subscription
        final subscription = await billingService.createSubscription(
          tenantId: tenant.id,
          planName: 'professional',
          paymentMethodId: 'test_payment_method',
        );

        expect(subscription, isNotNull);
        expect(subscription.tenantId, equals(tenant.id));

        // Update tenant subscription
        await tenantService.updateSubscription(
          subscriptionId: subscription.id,
          status: 'active',
        );

        // Verify integration
        final updatedTenant = await tenantService.getCurrentTenant();
        expect(updatedTenant, isNotNull);
        expect(updatedTenant!.subscriptionId, equals(subscription.id));
      });

      test('should integrate usage tracking with billing', () async {
        // Initialize usage service
        await usageService.initialize();

        // Track AI usage
        await usageService.trackAIRequest(
          tenantId: TestConfig.testTenantId,
          requestType: 'sentiment_analysis',
          tokensUsed: 1000,
        );

        // Track storage usage
        await usageService.trackStorageUsage(
          tenantId: TestConfig.testTenantId,
          bytesUsed: 1024 * 1024 * 100, // 100MB
        );

        // Get usage metrics
        final monthlyUsage = await usageService.getMonthlyUsage(TestConfig.testTenantId);
        expect(monthlyUsage, isNotNull);
        expect(monthlyUsage.aiRequests, greaterThan(0));
        expect(monthlyUsage.storageBytes, greaterThan(0));

        // Check usage limits
        final withinLimits = await usageService.checkUsageLimits(TestConfig.testTenantId);
        expect(withinLimits, isA<bool>());
      });
    });

    group('Collaboration and Notifications Integration', () {
      test('should integrate collaboration with smart notifications', () async {
        // Initialize services
        await collaborationService.initialize();
        await smartNotificationsService.initialize();

        // Create collaboration session
        final session = await collaborationService.createSession(
          sessionId: 'test_collab_session',
          title: 'Patient Case Review',
          creatorId: TestConfig.testClinicianId,
          creatorName: 'Dr. Smith',
          type: 'clinical',
        );

        expect(session, isNotNull);
        expect(session.id, isNotEmpty);

        // Join session
        final joined = await collaborationService.joinSession(
          sessionId: session.id,
          userId: 'clinician_002',
          userName: 'Dr. Johnson',
        );

        expect(joined, isTrue);

        // Send message
        final message = await collaborationService.sendMessage(
          sessionId: session.id,
          userId: TestConfig.testClinicianId,
          userName: 'Dr. Smith',
          content: 'Patient shows improvement in mood',
        );

        expect(message, isNotNull);
        expect(message.content, equals('Patient shows improvement in mood'));

        // Send smart notification
        final notification = await smartNotificationsService.sendSmartNotification(
          SmartNotification(
            id: 'test_notification',
            title: 'New Message in Session',
            body: 'Dr. Smith: Patient shows improvement in mood',
            category: 'collaboration',
            priority: 'normal',
            timestamp: DateTime.now(),
            isRead: false,
            metadata: {
              'sessionId': session.id,
              'messageId': message.id,
            },
          ),
        );

        expect(notification, isNotNull);
      });

      test('should integrate push notifications with collaboration', () async {
        // Initialize push notifications service
        await pushNotificationsService.initialize();

        // Subscribe to collaboration notifications
        final subscribed = await pushNotificationsService.subscribeToCategory(
          userId: TestConfig.testClinicianId,
          category: 'collaboration',
          deviceToken: 'test_device_token',
        );

        expect(subscribed, isTrue);

        // Send collaboration notification
        final notificationId = await pushNotificationsService.sendNotification(
          title: 'New Collaboration Session',
          body: 'Dr. Johnson invited you to join a session',
          category: 'collaboration',
          targetUserIds: [TestConfig.testClinicianId],
          priority: 'high',
        );

        expect(notificationId, isNotEmpty);

        // Get notifications for user
        final notifications = await pushNotificationsService.getNotificationsForUser(TestConfig.testClinicianId);
        expect(notifications, isNotEmpty);

        // Mark as read
        final markedAsRead = await pushNotificationsService.markNotificationAsRead(
          notificationId,
          TestConfig.testClinicianId,
        );

        expect(markedAsRead, isTrue);
      });
    });

    group('API Gateway and FHIR Integration', () {
      test('should integrate API gateway with FHIR service', () async {
        // Initialize services
        await apiGatewayService.initialize();
        await fhirService.initialize();

        // Process API request through gateway
        final apiResponse = await apiGatewayService.processRequest(
          path: '/api/v1/fhir/sync',
          method: 'POST',
          userId: TestConfig.testUserId,
          userRole: 'admin',
          body: {
            'resourceType': 'Patient',
            'patientId': TestConfig.testPatientId,
          },
        );

        expect(apiResponse, isNotNull);
        expect(apiResponse.success, isTrue);

        // Verify FHIR integration
        final fhirStatus = await fhirService.getFHIRStatus();
        expect(fhirStatus, isNotNull);
        expect(fhirStatus.isConnected, isTrue);

        // Get FHIR statistics
        final fhirStats = await fhirService.getFHIRStatistics();
        expect(fhirStats, isNotNull);
        expect(fhirStats.totalRecords, isA<int>());
      });

      test('should handle API rate limiting', () async {
        // Initialize API gateway
        await apiGatewayService.initialize();

        // Make multiple requests to trigger rate limiting
        final responses = <APIResponse>[];
        
        for (int i = 0; i < 25; i++) {
          final response = await apiGatewayService.processRequest(
            path: '/api/v1/ai/analyze',
            method: 'POST',
            userId: TestConfig.testUserId,
            userRole: 'clinician',
            body: {
              'type': 'sentiment_analysis',
              'data': 'Test data $i',
            },
          );
          responses.add(response);
        }

        // Check if rate limiting was applied
        final rateLimitedResponses = responses.where((r) => r.statusCode == 429).length;
        expect(rateLimitedResponses, greaterThan(0));

        // Get rate limit info
        final rateLimitInfo = await apiGatewayService.getRateLimitInfo(TestConfig.testUserId);
        expect(rateLimitInfo, isNotEmpty);
      });
    });

    group('Production Deployment Integration', () {
      test('should integrate deployment with all services', () async {
        // Initialize deployment service
        await deploymentService.initialize();

        // Start deployment
        final deployment = await deploymentService.startDeployment(
          configId: 'minimal',
          version: '1.0.0-test',
          description: 'Integration test deployment',
          initiatedBy: TestConfig.testUserId,
        );

        expect(deployment, isNotNull);
        expect(deployment.status, equals('started'));

        // Wait for deployment to progress
        await TestConfig.waitForLongAsync();

        // Check deployment status
        final activeDeployments = deploymentService.activeDeployments;
        expect(activeDeployments, isNotEmpty);

        // Cancel deployment for testing
        final cancelled = await deploymentService.cancelDeployment(deployment.id);
        expect(cancelled, isTrue);

        // Get deployment statistics
        final stats = await deploymentService.getDeploymentStatistics();
        expect(stats, isNotNull);
        expect(stats.totalDeployments30d, greaterThanOrEqualTo(1));
      });

      test('should handle deployment health checks', () async {
        // Initialize deployment service
        await deploymentService.initialize();

        // Get deployment environments
        final environments = deploymentService.environments;
        expect(environments, isNotEmpty);

        // Check environment status
        for (final environment in environments.values) {
          expect(environment.status, isNotNull);
          expect(environment.version, isNotEmpty);
          expect(environment.features, isNotEmpty);
        }

        // Get deployment configurations
        final configs = deploymentService.deploymentConfigs;
        expect(configs, isNotEmpty);

        for (final config in configs.values) {
          expect(config.features, isNotEmpty);
          expect(config.estimatedDuration, greaterThan(0));
        }
      });
    });

    group('End-to-End Workflow Integration', () {
      test('should complete full patient workflow', () async {
        // 1. Create tenant and subscription
        await tenantService.initialize();
        await billingService.initialize();

        final tenant = await tenantService.createTenant(
          name: 'Integration Test Clinic',
          domain: 'integrationtest.com',
          region: 'TR',
          plan: 'professional',
        );

        final subscription = await billingService.createSubscription(
          tenantId: tenant.id,
          planName: 'professional',
          paymentMethodId: 'test_payment_method',
        );

        // 2. AI Analysis
        final aiTask = await aiService.createAITask(
          type: 'sentiment_analysis',
          inputData: 'Patient reports feeling anxious and depressed',
          priority: 'high',
        );

        final aiResult = await aiService.executeTask(aiTask.id);

        // 3. Predictive Analytics
        final prediction = await predictiveService.predictTreatmentOutcome(
          patientId: TestConfig.testPatientId,
          treatmentData: {
            'medication': 'Escitalopram',
            'dosage': '10mg',
            'duration': '12 weeks',
            'patient_data': aiResult['results'],
          },
        );

        // 4. Voice and Facial Analysis
        await voiceService.startVoiceAnalysis(
          sessionId: 'workflow_session',
          patientId: TestConfig.testPatientId,
        );

        await facialService.startFacialAnalysis(
          sessionId: 'workflow_session',
          patientId: TestConfig.testPatientId,
        );

        // 5. Collaboration Session
        final session = await collaborationService.createSession(
          sessionId: 'workflow_collab',
          title: 'Patient Treatment Plan',
          creatorId: TestConfig.testClinicianId,
          creatorName: 'Dr. Integration',
          type: 'clinical',
        );

        // 6. Smart Notifications
        final notification = await smartNotificationsService.sendSmartNotification(
          SmartNotification(
            id: 'workflow_notification',
            title: 'Treatment Plan Ready',
            body: 'AI analysis and predictions completed for patient',
            category: 'clinical',
            priority: 'high',
            timestamp: DateTime.now(),
            isRead: false,
            metadata: {
              'patientId': TestConfig.testPatientId,
              'aiTaskId': aiTask.id,
              'predictionId': prediction.id,
              'sessionId': session.id,
            },
          ),
        );

        // 7. Push Notification
        final pushNotificationId = await pushNotificationsService.sendNotification(
          title: 'Treatment Plan Available',
          body: 'New treatment plan ready for review',
          category: 'clinical',
          targetUserIds: [TestConfig.testClinicianId],
          priority: 'high',
        );

        // 8. API Gateway Request
        final apiResponse = await apiGatewayService.processRequest(
          path: '/api/v1/patients/${TestConfig.testPatientId}/treatment-plan',
          method: 'POST',
          userId: TestConfig.testClinicianId,
          userRole: 'clinician',
          body: {
            'aiAnalysis': aiResult,
            'prediction': prediction.toJson(),
            'collaborationSession': session.id,
            'notifications': [notification.id, pushNotificationId],
          },
        );

        // 9. FHIR Integration
        final fhirPatient = await fhirService.searchFHIRPatients(
          query: TestConfig.testPatientId,
        );

        // 10. Usage Tracking
        await usageService.trackAIRequest(
          tenantId: tenant.id,
          requestType: 'sentiment_analysis',
          tokensUsed: 1500,
        );

        // 11. Security Audit
        await securityService.logSecurityEvent(
          userId: TestConfig.testClinicianId,
          action: 'treatment_plan_created',
          details: 'Complete workflow completed successfully',
          securityLevel: 'high',
        );

        // 12. Offline Sync
        await offlineService.saveOfflineData(
          key: 'workflow_${TestConfig.testPatientId}',
          dataType: 'treatment_plan',
          content: 'Complete workflow data',
        );

        // Verify all components worked together
        expect(tenant, isNotNull);
        expect(subscription, isNotNull);
        expect(aiResult['success'], isTrue);
        expect(prediction, isNotNull);
        expect(session, isNotNull);
        expect(notification, isNotNull);
        expect(pushNotificationId, isNotEmpty);
        expect(apiResponse.success, isTrue);
        expect(fhirPatient, isNotEmpty);
        expect(offlineService.isOffline, isFalse);

        // Cleanup
        await voiceService.stopVoiceAnalysis();
        await facialService.stopFacialAnalysis();
        await collaborationService.leaveSession(
          sessionId: session.id,
          userId: TestConfig.testClinicianId,
        );
      });
    });

    group('Performance and Load Testing', () {
      test('should handle concurrent service operations', () async {
        // Initialize all services
        await Future.wait([
          aiService.initialize(),
          predictiveService.initialize(),
          voiceService.initialize(),
          facialService.initialize(),
          smartNotificationsService.initialize(),
          securityService.initialize(),
          biometricService.initialize(),
          offlineService.initialize(),
          fhirService.initialize(),
          tenantService.initialize(),
          usageService.initialize(),
          billingService.initialize(),
          collaborationService.initialize(),
          pushNotificationsService.initialize(),
          apiGatewayService.initialize(),
          deploymentService.initialize(),
        ]);

        // Perform concurrent operations
        final futures = <Future>[];

        // Concurrent AI tasks
        for (int i = 0; i < 10; i++) {
          futures.add(aiService.createAITask(
            type: 'concurrent_test_$i',
            inputData: 'Concurrent test data $i',
            priority: 'normal',
          ));
        }

        // Concurrent API requests
        for (int i = 0; i < 10; i++) {
          futures.add(apiGatewayService.processRequest(
            path: '/api/v1/test/concurrent',
            method: 'GET',
            userId: 'user_$i',
            userRole: 'clinician',
          ));
        }

        // Concurrent notifications
        for (int i = 0; i < 10; i++) {
          futures.add(pushNotificationsService.sendNotification(
            title: 'Concurrent Test $i',
            body: 'Concurrent notification test',
            category: 'test',
            targetUserIds: [TestConfig.testClinicianId],
          ));
        }

        // Wait for all operations to complete
        final results = await Future.wait(futures);

        // Verify all operations completed
        expect(results.length, equals(30));
        
        for (final result in results) {
          expect(result, isNotNull);
        }
      });

      test('should handle large data volumes', () async {
        // Initialize services
        await aiService.initialize();
        await usageService.initialize();

        // Create large dataset
        final largeData = 'A' * 100000; // 100KB
        
        // Process large data through AI service
        final startTime = DateTime.now();
        
        final aiTask = await aiService.createAITask(
          type: 'large_data_processing',
          inputData: largeData,
          priority: 'high',
        );

        final aiResult = await aiService.executeTask(aiTask.id);
        
        final endTime = DateTime.now();
        final processingTime = endTime.difference(startTime).inMilliseconds;

        // Verify processing completed
        expect(aiResult['success'], isTrue);
        expect(processingTime, lessThan(10000)); // Should complete within 10 seconds

        // Track usage
        await usageService.trackAIRequest(
          tenantId: TestConfig.testTenantId,
          requestType: 'large_data_processing',
          tokensUsed: 50000,
        );

        // Verify usage tracking
        final usage = await usageService.getMonthlyUsage(TestConfig.testTenantId);
        expect(usage.aiRequests, greaterThan(0));
      });
    });
  });
}
