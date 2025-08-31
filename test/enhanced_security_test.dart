import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:psyclinicai/services/enhanced_security_service.dart';
import 'package:psyclinicai/models/security_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAll':
            return <String, dynamic>{};
          case 'setString':
          case 'setStringList':
            return true;
          case 'getStringList':
            return <String>[];
          default:
            return null;
        }
      },
    );
  });

  group('EnhancedSecurityService Tests', () {
    late EnhancedSecurityService service;

    setUp(() {
      service = EnhancedSecurityService();
    });

    tearDown(() {
      service.dispose();
    });

    test('should initialize service', () async {
      await service.initialize();
      expect(service, isNotNull);
    });

    test('should create and retrieve compliance framework', () async {
      await service.initialize();
      
      final framework = EnhancedComplianceFramework(
        id: 'test-framework',
        name: 'Test Framework',
        description: 'Test description',
        region: 'EU',
        requirements: ['GDPR'],
        configurations: {'enabled': true},
        isActive: true,
        createdAt: DateTime.now(),
      );

      await service.createComplianceFramework(framework);
      final retrieved = service.getComplianceFramework('test-framework');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-framework'));
      expect(retrieved.name, equals('Test Framework'));
    });

    test('should create and retrieve retention policy', () async {
      await service.initialize();
      
      final policy = EnhancedDataRetentionPolicy(
        id: 'test-policy',
        name: 'Test Policy',
        description: 'Test description',
        retentionPeriods: {'test_data': 365},
        dataTypes: ['test_data'],
        deletionMethod: 'secure_deletion',
        requiresApproval: true,
        approvers: ['admin'],
        createdAt: DateTime.now(),
      );

      await service.createRetentionPolicy(policy);
      final retrieved = service.getRetentionPolicy('test-policy');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-policy'));
      expect(retrieved.name, equals('Test Policy'));
    });

    test('should create and retrieve encryption config', () async {
      await service.initialize();
      
      final config = EnhancedEncryptionConfig(
        id: 'test-config',
        name: 'Test Config',
        algorithm: 'AES-256-GCM',
        keySize: 256,
        keyManagement: 'AWS KMS',
        settings: {
          'keyRotation': 90,
          'encryptionMode': 'GCM',
        },
        createdAt: DateTime.now(),
      );

      await service.createEncryptionConfig(config);
      final retrieved = service.getEncryptionConfig('test-config');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Config');
    });

    test('should create and retrieve access policy', () async {
      await service.initialize();
      
      final policy = EnhancedAccessControlPolicy(
        id: 'test-policy',
        name: 'Test Policy',
        description: 'Test description',
        roles: ['therapist'],
        permissions: ['read_patient_data'],
        resourceAccess: {'test_resource': ['read']},
        enforcementLevel: 'strict',
        requiresMFA: true,
        allowedIPs: ['192.168.1.0/24'],
        allowedDevices: ['desktop'],
        createdAt: DateTime.now(),
      );

      await service.createAccessPolicy(policy);
      final retrieved = service.getAccessPolicy('test-policy');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Policy');
    });

    test('should create and retrieve anonymization rule', () async {
      await service.initialize();
      
      final rule = EnhancedDataAnonymizationRule(
        id: 'test-rule',
        name: 'Test Rule',
        description: 'Test description',
        dataFields: ['firstName', 'lastName'],
        anonymizationMethod: 'hash',
        parameters: {
          'algorithm': 'sha256',
          'salt': 'random_salt',
        },
        isReversible: false,
        retentionKey: 'patient_id',
        createdAt: DateTime.now(),
      );

      await service.createAnonymizationRule(rule);
      final retrieved = service.getAnonymizationRule('test-rule');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Rule');
    });

    test('should create and retrieve security incident', () async {
      await service.initialize();
      
      final incident = EnhancedSecurityIncident(
        id: 'test-incident',
        title: 'Test Incident',
        description: 'Test description',
        severity: 'medium',
        status: 'investigating',
        category: 'authentication',
        reportedBy: 'system',
        reportedAt: DateTime.now(),
        affectedUsers: ['user123'],
        affectedSystems: ['auth_service'],
        details: {
          'ipAddress': '192.168.1.100',
          'attempts': 15,
        },
        actions: ['blocked_ip'],
        assignedTo: 'security_team',
        createdAt: DateTime.now(),
      );

      await service.createSecurityIncident(incident);
      final retrieved = service.getSecurityIncident('test-incident');

      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test Incident');
    });

    test('should log security audit event', () async {
      await service.initialize();
      
      final log = SecurityAuditLog(
        id: 'test-log',
        userId: 'user123',
        action: 'login',
        resource: 'auth_service',
        ipAddress: '192.168.1.100',
        userAgent: 'Mozilla/5.0',
        details: {'method': 'password'},
        isSuccessful: true,
        timestamp: DateTime.now(),
        sessionId: 'session-001',
      );

      await service.logSecurityEvent(log);
      final logs = service.getAuditLogsByUser('user123');

      expect(logs, isNotEmpty);
      expect(logs.first.userId, 'user123');
    });

    test('should get security statistics', () async {
      await service.initialize();
      
      final stats = service.getSecurityStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['totalComplianceFrameworks'], isA<int>());
      expect(stats['totalRetentionPolicies'], isA<int>());
      expect(stats['totalEncryptionConfigs'], isA<int>());
      expect(stats['totalAccessPolicies'], isA<int>());
      expect(stats['totalAnonymizationRules'], isA<int>());
      expect(stats['totalSecurityIncidents'], isA<int>());
      expect(stats['totalAuditLogs'], isA<int>());
    });

    test('should filter compliance frameworks by region', () async {
      await service.initialize();
      
      final frameworks = service.getComplianceFrameworksByRegion('EU');
      expect(frameworks, isA<List<EnhancedComplianceFramework>>());
    });

    test('should filter retention policies by data type', () async {
      await service.initialize();
      
      final policies = service.getRetentionPoliciesByDataType('patient_records');
      expect(policies, isA<List<EnhancedDataRetentionPolicy>>());
    });

    test('should filter access policies by role', () async {
      await service.initialize();
      
      final policies = service.getAccessPoliciesByRole('therapist');
      expect(policies, isA<List<EnhancedAccessControlPolicy>>());
    });

    test('should filter anonymization rules by field', () async {
      await service.initialize();
      
      final rules = service.getAnonymizationRulesByField('firstName');
      expect(rules, isA<List<EnhancedDataAnonymizationRule>>());
    });

    test('should filter security incidents by severity', () async {
      await service.initialize();
      
      final incidents = service.getSecurityIncidentsBySeverity('high');
      expect(incidents, isA<List<EnhancedSecurityIncident>>());
    });

    test('should get active security incidents', () async {
      await service.initialize();
      
      final incidents = service.getActiveSecurityIncidents();
      expect(incidents, isA<List<EnhancedSecurityIncident>>());
    });

    test('should get audit logs by action', () async {
      await service.initialize();
      
      final logs = service.getAuditLogsByAction('login');
      expect(logs, isA<List<SecurityAuditLog>>());
    });

    test('should get audit logs by date range', () async {
      await service.initialize();
      
      final start = DateTime.now().subtract(Duration(days: 7));
      final end = DateTime.now();
      final logs = service.getAuditLogsByDateRange(start, end);
      expect(logs, isA<List<SecurityAuditLog>>());
    });

    test('should validate data integrity', () async {
      await service.initialize();
      
      final framework = EnhancedComplianceFramework(
        id: 'test-framework',
        name: 'Test Framework',
        description: 'Test description',
        region: 'EU',
        requirements: ['GDPR'],
        configurations: {'enabled': true},
        isActive: true,
        createdAt: DateTime.now(),
      );

      await service.createComplianceFramework(framework);
      await service.deleteComplianceFramework('test-framework');
      final retrieved = service.getComplianceFramework('test-framework');

      expect(retrieved, isNull);
    });

    test('should handle service disposal', () {
      service.dispose();
      // Should not throw any errors
      expect(() => service.dispose(), returnsNormally);
    });
  });
}
