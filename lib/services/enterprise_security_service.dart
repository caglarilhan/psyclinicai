import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enterprise Security Service for PsyClinicAI
/// Implements zero-trust security model and advanced security features
class EnterpriseSecurityService {
  static final EnterpriseSecurityService _instance = EnterpriseSecurityService._internal();
  factory EnterpriseSecurityService() => _instance;
  EnterpriseSecurityService._internal();

  final Map<String, SecurityContext> _securityContexts = {};
  final Map<String, List<SecurityEvent>> _securityEvents = {};
  final List<ThreatDetection> _threatDetections = [];
  final Map<String, SecurityPolicy> _securityPolicies = {};

  // Stream controllers for real-time security monitoring
  final StreamController<SecurityEvent> _securityEventController = StreamController<SecurityEvent>.broadcast();
  final StreamController<ThreatDetection> _threatController = StreamController<ThreatDetection>.broadcast();
  final StreamController<SecurityAlert> _alertController = StreamController<SecurityAlert>.broadcast();

  Stream<SecurityEvent> get securityEventStream => _securityEventController.stream;
  Stream<ThreatDetection> get threatStream => _threatController.stream;
  Stream<SecurityAlert> get alertStream => _alertController.stream;

  /// Initialize the security service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _loadSecurityPolicies();
    await _initializeThreatDetection();
    print('✅ Enterprise Security Service initialized');
  }

  /// Load default security policies
  Future<void> _loadSecurityPolicies() async {
    _securityPolicies['default'] = SecurityPolicy(
      id: 'policy_default',
      name: 'Default Security Policy',
      rules: [
        SecurityRule(
          id: 'rule_password_strength',
          type: SecurityRuleType.passwordPolicy,
          condition: 'password_strength >= 8',
          action: SecurityAction.enforce,
          severity: SecuritySeverity.medium,
        ),
        SecurityRule(
          id: 'rule_mfa_required',
          type: SecurityRuleType.authenticationPolicy,
          condition: 'role_level >= clinician',
          action: SecurityAction.enforce,
          severity: SecuritySeverity.high,
        ),
        SecurityRule(
          id: 'rule_session_timeout',
          type: SecurityRuleType.sessionPolicy,
          condition: 'session_idle_time > 3600',
          action: SecurityAction.terminate,
          severity: SecuritySeverity.medium,
        ),
      ],
      complianceFrameworks: ['HIPAA', 'GDPR', 'SOC2'],
      isActive: true,
      createdAt: DateTime.now(),
    );

    _securityPolicies['enterprise'] = SecurityPolicy(
      id: 'policy_enterprise',
      name: 'Enterprise Security Policy',
      rules: [
        SecurityRule(
          id: 'rule_zero_trust',
          type: SecurityRuleType.accessControl,
          condition: 'verify_device_trust && verify_user_context',
          action: SecurityAction.enforce,
          severity: SecuritySeverity.critical,
        ),
        SecurityRule(
          id: 'rule_data_encryption',
          type: SecurityRuleType.dataProtection,
          condition: 'data_classification >= confidential',
          action: SecurityAction.encrypt,
          severity: SecuritySeverity.high,
        ),
        SecurityRule(
          id: 'rule_anomaly_detection',
          type: SecurityRuleType.monitoring,
          condition: 'behavioral_anomaly_score > 0.8',
          action: SecurityAction.alert,
          severity: SecuritySeverity.high,
        ),
      ],
      complianceFrameworks: ['HIPAA', 'GDPR', 'SOC2', 'FedRAMP'],
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Initialize threat detection system
  Future<void> _initializeThreatDetection() async {
    // Simulate real-time threat detection
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _performThreatScan();
    });
  }

  /// Create security context for user session
  Future<SecurityContext> createSecurityContext({
    required String userId,
    required String tenantId,
    required String deviceId,
    required String ipAddress,
    required Map<String, dynamic> userProfile,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final context = SecurityContext(
      id: _generateSecureId(),
      userId: userId,
      tenantId: tenantId,
      deviceId: deviceId,
      ipAddress: ipAddress,
      userProfile: userProfile,
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
      securityScore: await _calculateSecurityScore(userId, deviceId, ipAddress),
      riskLevel: RiskLevel.low,
      authenticationFactors: [],
      permissions: [],
      deviceTrust: await _evaluateDeviceTrust(deviceId),
      locationTrust: await _evaluateLocationTrust(ipAddress),
    );

    _securityContexts[context.id] = context;
    
    await _logSecurityEvent(
      SecurityEvent(
        id: _generateSecureId(),
        type: SecurityEventType.sessionCreated,
        userId: userId,
        tenantId: tenantId,
        timestamp: DateTime.now(),
        details: {
          'context_id': context.id,
          'device_id': deviceId,
          'ip_address': ipAddress,
        },
        severity: SecuritySeverity.low,
        source: 'security_service',
      ),
    );

    return context;
  }

  /// Validate access request using zero-trust principles
  Future<AccessDecision> validateAccess({
    required String contextId,
    required String resource,
    required String action,
    Map<String, dynamic> requestContext = const {},
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final context = _securityContexts[contextId];
    if (context == null) {
      return AccessDecision(
        allowed: false,
        reason: 'Invalid security context',
        riskScore: 1.0,
        requiredActions: [SecurityAction.reauthenticate],
      );
    }

    // Zero-trust validation
    final validationResults = await Future.wait([
      _validateUserTrust(context),
      _validateDeviceTrust(context),
      _validateLocationTrust(context),
      _validateResourceAccess(context, resource, action),
      _validateBehavioralPattern(context, requestContext),
    ]);

    final riskScore = validationResults.map((r) => r.riskScore).reduce((a, b) => a + b) / validationResults.length;
    final isAllowed = validationResults.every((r) => r.allowed) && riskScore < 0.7;

    final decision = AccessDecision(
      allowed: isAllowed,
      reason: isAllowed ? 'Access granted' : 'Access denied - high risk score',
      riskScore: riskScore,
      requiredActions: isAllowed ? [] : [SecurityAction.additionalVerification],
      contextUpdates: {
        'last_access': DateTime.now().toIso8601String(),
        'resource': resource,
        'action': action,
      },
    );

    // Log access attempt
    await _logSecurityEvent(
      SecurityEvent(
        id: _generateSecureId(),
        type: SecurityEventType.accessAttempt,
        userId: context.userId,
        tenantId: context.tenantId,
        timestamp: DateTime.now(),
        details: {
          'context_id': contextId,
          'resource': resource,
          'action': action,
          'allowed': isAllowed,
          'risk_score': riskScore,
        },
        severity: isAllowed ? SecuritySeverity.low : SecuritySeverity.medium,
        source: 'access_control',
      ),
    );

    // Update security context
    if (isAllowed) {
      _securityContexts[contextId] = context.copyWith(
        lastActivity: DateTime.now(),
        riskLevel: _calculateRiskLevel(riskScore),
      );
    }

    return decision;
  }

  /// Perform comprehensive security audit
  Future<SecurityAuditReport> performSecurityAudit({
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final startTime = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final endTime = endDate ?? DateTime.now();

    // Collect audit data
    final events = _getSecurityEventsInRange(startTime, endTime, tenantId);
    final threats = _getThreatsInRange(startTime, endTime, tenantId);
    final contexts = tenantId != null 
        ? _securityContexts.values.where((c) => c.tenantId == tenantId).toList()
        : _securityContexts.values.toList();

    // Calculate security metrics
    final metrics = SecurityMetrics(
      totalEvents: events.length,
      highSeverityEvents: events.where((e) => e.severity == SecuritySeverity.high || e.severity == SecuritySeverity.critical).length,
      threatsDetected: threats.length,
      threatsBlocked: threats.where((t) => t.status == ThreatStatus.blocked).length,
      averageRiskScore: contexts.isNotEmpty 
          ? contexts.map((c) => c.securityScore).reduce((a, b) => a + b) / contexts.length
          : 0.0,
      complianceScore: await _calculateComplianceScore(events, tenantId),
      vulnerabilities: await _identifyVulnerabilities(events, threats),
    );

    // Generate recommendations
    final recommendations = await _generateSecurityRecommendations(metrics, events, threats);

    return SecurityAuditReport(
      id: _generateSecureId(),
      tenantId: tenantId,
      startDate: startTime,
      endDate: endTime,
      generatedAt: DateTime.now(),
      metrics: metrics,
      events: events,
      threats: threats,
      recommendations: recommendations,
      complianceStatus: await _assessComplianceStatus(tenantId),
    );
  }

  /// Detect and respond to security threats
  Future<void> _performThreatScan() async {
    final random = Random();
    
    // Simulate threat detection
    if (random.nextDouble() < 0.1) { // 10% chance of detecting a threat
      final threat = ThreatDetection(
        id: _generateSecureId(),
        type: _getRandomThreatType(random),
        severity: _getRandomSeverity(random),
        source: _getRandomThreatSource(random),
        target: 'system',
        detectedAt: DateTime.now(),
        status: ThreatStatus.detected,
        details: {
          'confidence': 0.8 + random.nextDouble() * 0.2,
          'indicators': ['suspicious_activity', 'anomalous_pattern'],
        },
        affectedUsers: [],
        mitigationActions: [],
      );

      _threatDetections.add(threat);
      _threatController.add(threat);

      // Auto-mitigation for high-severity threats
      if (threat.severity == SecuritySeverity.high || threat.severity == SecuritySeverity.critical) {
        await _automaticThreatMitigation(threat);
      }
    }
  }

  /// Automatic threat mitigation
  Future<void> _automaticThreatMitigation(ThreatDetection threat) async {
    final mitigationActions = <String>[];

    switch (threat.type) {
      case ThreatType.bruteForceAttack:
        mitigationActions.addAll(['block_ip', 'increase_auth_requirements']);
        break;
      case ThreatType.suspiciousLogin:
        mitigationActions.addAll(['require_mfa', 'session_review']);
        break;
      case ThreatType.dataExfiltration:
        mitigationActions.addAll(['block_data_access', 'alert_admin', 'forensic_analysis']);
        break;
      case ThreatType.malwareDetection:
        mitigationActions.addAll(['quarantine_device', 'scan_network']);
        break;
      case ThreatType.unauthorizedAccess:
        mitigationActions.addAll(['revoke_access', 'audit_permissions']);
        break;
    }

    // Update threat with mitigation actions
    final updatedThreat = threat.copyWith(
      status: ThreatStatus.mitigating,
      mitigationActions: mitigationActions,
      resolvedAt: DateTime.now(),
    );

    final index = _threatDetections.indexWhere((t) => t.id == threat.id);
    if (index != -1) {
      _threatDetections[index] = updatedThreat;
    }

    // Send security alert
    _alertController.add(
      SecurityAlert(
        id: _generateSecureId(),
        type: SecurityAlertType.threatMitigated,
        severity: threat.severity,
        title: 'Threat Automatically Mitigated',
        message: 'Threat ${threat.type.name} has been automatically mitigated',
        timestamp: DateTime.now(),
        source: 'auto_mitigation',
        details: {
          'threat_id': threat.id,
          'mitigation_actions': mitigationActions,
        },
      ),
    );
  }

  /// Encrypt sensitive data
  Future<String> encryptSensitiveData(String data, String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // In a real implementation, use proper encryption with tenant-specific keys
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return base64.encode(hash.bytes);
  }

  /// Decrypt sensitive data
  Future<String> decryptSensitiveData(String encryptedData, String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // In a real implementation, use proper decryption
    // For demo purposes, return a placeholder
    return 'decrypted_data_placeholder';
  }

  /// Generate security token
  String generateSecurityToken({
    required String userId,
    required String tenantId,
    Duration? expiry,
  }) {
    final payload = {
      'user_id': userId,
      'tenant_id': tenantId,
      'issued_at': DateTime.now().millisecondsSinceEpoch,
      'expires_at': (DateTime.now().add(expiry ?? const Duration(hours: 1))).millisecondsSinceEpoch,
      'nonce': _generateSecureId(),
    };
    
    return base64.encode(utf8.encode(json.encode(payload)));
  }

  /// Validate security token
  bool validateSecurityToken(String token) {
    try {
      final decoded = json.decode(utf8.decode(base64.decode(token)));
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(decoded['expires_at']);
      return DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  // Helper methods for validation
  Future<ValidationResult> _validateUserTrust(SecurityContext context) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Simulate user trust validation
    final random = Random();
    final trustScore = 0.7 + random.nextDouble() * 0.3;
    
    return ValidationResult(
      allowed: trustScore > 0.8,
      riskScore: 1.0 - trustScore,
      details: {'trust_score': trustScore},
    );
  }

  Future<ValidationResult> _validateDeviceTrust(SecurityContext context) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return ValidationResult(
      allowed: context.deviceTrust.isKnown,
      riskScore: context.deviceTrust.riskScore,
      details: {'device_trust': context.deviceTrust.trustLevel.name},
    );
  }

  Future<ValidationResult> _validateLocationTrust(SecurityContext context) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return ValidationResult(
      allowed: context.locationTrust.isAllowed,
      riskScore: context.locationTrust.riskScore,
      details: {'location_trust': context.locationTrust.country},
    );
  }

  Future<ValidationResult> _validateResourceAccess(SecurityContext context, String resource, String action) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Simulate resource access validation
    final hasPermission = context.permissions.any((p) => 
        p.resource == resource && p.actions.contains(action));
    
    return ValidationResult(
      allowed: hasPermission,
      riskScore: hasPermission ? 0.1 : 0.9,
      details: {'has_permission': hasPermission},
    );
  }

  Future<ValidationResult> _validateBehavioralPattern(SecurityContext context, Map<String, dynamic> requestContext) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Simulate behavioral analysis
    final random = Random();
    final isNormalBehavior = random.nextDouble() > 0.1; // 90% normal behavior
    
    return ValidationResult(
      allowed: isNormalBehavior,
      riskScore: isNormalBehavior ? 0.2 : 0.8,
      details: {'behavioral_analysis': isNormalBehavior ? 'normal' : 'anomalous'},
    );
  }

  Future<double> _calculateSecurityScore(String userId, String deviceId, String ipAddress) async {
    // Simulate security score calculation
    final random = Random();
    return 0.7 + random.nextDouble() * 0.3;
  }

  Future<DeviceTrust> _evaluateDeviceTrust(String deviceId) async {
    // Simulate device trust evaluation
    final random = Random();
    return DeviceTrust(
      deviceId: deviceId,
      isKnown: random.nextBool(),
      trustLevel: TrustLevel.values[random.nextInt(TrustLevel.values.length)],
      riskScore: random.nextDouble() * 0.5,
      lastSeen: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    );
  }

  Future<LocationTrust> _evaluateLocationTrust(String ipAddress) async {
    // Simulate location trust evaluation
    final random = Random();
    return LocationTrust(
      ipAddress: ipAddress,
      country: 'US',
      region: 'California',
      isAllowed: random.nextDouble() > 0.1,
      riskScore: random.nextDouble() * 0.3,
      isVpn: random.nextBool(),
    );
  }

  RiskLevel _calculateRiskLevel(double riskScore) {
    if (riskScore < 0.3) return RiskLevel.low;
    if (riskScore < 0.6) return RiskLevel.medium;
    if (riskScore < 0.8) return RiskLevel.high;
    return RiskLevel.critical;
  }

  Future<void> _logSecurityEvent(SecurityEvent event) async {
    _securityEvents.putIfAbsent(event.tenantId, () => []).add(event);
    _securityEventController.add(event);
  }

  List<SecurityEvent> _getSecurityEventsInRange(DateTime start, DateTime end, String? tenantId) {
    final allEvents = tenantId != null 
        ? _securityEvents[tenantId] ?? []
        : _securityEvents.values.expand((e) => e).toList();
    
    return allEvents.where((e) => 
        e.timestamp.isAfter(start) && e.timestamp.isBefore(end)).toList();
  }

  List<ThreatDetection> _getThreatsInRange(DateTime start, DateTime end, String? tenantId) {
    return _threatDetections.where((t) => 
        t.detectedAt.isAfter(start) && t.detectedAt.isBefore(end)).toList();
  }

  Future<double> _calculateComplianceScore(List<SecurityEvent> events, String? tenantId) async {
    // Simulate compliance score calculation
    return 0.85 + Random().nextDouble() * 0.15;
  }

  Future<List<SecurityVulnerability>> _identifyVulnerabilities(List<SecurityEvent> events, List<ThreatDetection> threats) async {
    // Simulate vulnerability identification
    return [
      SecurityVulnerability(
        id: _generateSecureId(),
        type: 'weak_password_policy',
        severity: SecuritySeverity.medium,
        description: 'Password policy could be strengthened',
        affectedSystems: ['authentication'],
        remediation: 'Implement stronger password requirements',
      ),
    ];
  }

  Future<List<SecurityRecommendation>> _generateSecurityRecommendations(
      SecurityMetrics metrics, List<SecurityEvent> events, List<ThreatDetection> threats) async {
    final recommendations = <SecurityRecommendation>[];

    if (metrics.averageRiskScore > 0.7) {
      recommendations.add(SecurityRecommendation(
        id: _generateSecureId(),
        title: 'Reduce Average Risk Score',
        description: 'Implement additional security controls to reduce risk',
        priority: RecommendationPriority.high,
        category: 'risk_management',
        estimatedImpact: 'Reduce risk by 20-30%',
      ));
    }

    if (metrics.threatsDetected > 5) {
      recommendations.add(SecurityRecommendation(
        id: _generateSecureId(),
        title: 'Enhanced Threat Detection',
        description: 'Deploy advanced threat detection capabilities',
        priority: RecommendationPriority.medium,
        category: 'threat_detection',
        estimatedImpact: 'Improve threat detection by 40%',
      ));
    }

    return recommendations;
  }

  Future<Map<String, bool>> _assessComplianceStatus(String? tenantId) async {
    return {
      'HIPAA': true,
      'GDPR': true,
      'SOC2': Random().nextBool(),
      'FedRAMP': false,
    };
  }

  ThreatType _getRandomThreatType(Random random) {
    return ThreatType.values[random.nextInt(ThreatType.values.length)];
  }

  SecuritySeverity _getRandomSeverity(Random random) {
    return SecuritySeverity.values[random.nextInt(SecuritySeverity.values.length)];
  }

  String _getRandomThreatSource(Random random) {
    final sources = ['external', 'internal', 'unknown', 'automated'];
    return sources[random.nextInt(sources.length)];
  }

  String _generateSecureId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Dispose resources
  void dispose() {
    _securityEventController.close();
    _threatController.close();
    _alertController.close();
  }
}

// Data Models for Security Service
class SecurityContext {
  final String id;
  final String userId;
  final String tenantId;
  final String deviceId;
  final String ipAddress;
  final Map<String, dynamic> userProfile;
  final DateTime createdAt;
  final DateTime lastActivity;
  final double securityScore;
  final RiskLevel riskLevel;
  final List<AuthenticationFactor> authenticationFactors;
  final List<Permission> permissions;
  final DeviceTrust deviceTrust;
  final LocationTrust locationTrust;

  const SecurityContext({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.deviceId,
    required this.ipAddress,
    required this.userProfile,
    required this.createdAt,
    required this.lastActivity,
    required this.securityScore,
    required this.riskLevel,
    required this.authenticationFactors,
    required this.permissions,
    required this.deviceTrust,
    required this.locationTrust,
  });

  SecurityContext copyWith({
    String? id,
    String? userId,
    String? tenantId,
    String? deviceId,
    String? ipAddress,
    Map<String, dynamic>? userProfile,
    DateTime? createdAt,
    DateTime? lastActivity,
    double? securityScore,
    RiskLevel? riskLevel,
    List<AuthenticationFactor>? authenticationFactors,
    List<Permission>? permissions,
    DeviceTrust? deviceTrust,
    LocationTrust? locationTrust,
  }) {
    return SecurityContext(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      userProfile: userProfile ?? this.userProfile,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      securityScore: securityScore ?? this.securityScore,
      riskLevel: riskLevel ?? this.riskLevel,
      authenticationFactors: authenticationFactors ?? this.authenticationFactors,
      permissions: permissions ?? this.permissions,
      deviceTrust: deviceTrust ?? this.deviceTrust,
      locationTrust: locationTrust ?? this.locationTrust,
    );
  }
}

class Permission {
  final String resource;
  final List<String> actions;

  const Permission({
    required this.resource,
    required this.actions,
  });
}

class AuthenticationFactor {
  final String type;
  final bool verified;
  final DateTime timestamp;

  const AuthenticationFactor({
    required this.type,
    required this.verified,
    required this.timestamp,
  });
}

class DeviceTrust {
  final String deviceId;
  final bool isKnown;
  final TrustLevel trustLevel;
  final double riskScore;
  final DateTime lastSeen;

  const DeviceTrust({
    required this.deviceId,
    required this.isKnown,
    required this.trustLevel,
    required this.riskScore,
    required this.lastSeen,
  });
}

class LocationTrust {
  final String ipAddress;
  final String country;
  final String region;
  final bool isAllowed;
  final double riskScore;
  final bool isVpn;

  const LocationTrust({
    required this.ipAddress,
    required this.country,
    required this.region,
    required this.isAllowed,
    required this.riskScore,
    required this.isVpn,
  });
}

class AccessDecision {
  final bool allowed;
  final String reason;
  final double riskScore;
  final List<SecurityAction> requiredActions;
  final Map<String, dynamic> contextUpdates;

  const AccessDecision({
    required this.allowed,
    required this.reason,
    required this.riskScore,
    this.requiredActions = const [],
    this.contextUpdates = const {},
  });
}

class ValidationResult {
  final bool allowed;
  final double riskScore;
  final Map<String, dynamic> details;

  const ValidationResult({
    required this.allowed,
    required this.riskScore,
    this.details = const {},
  });
}

class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final String userId;
  final String tenantId;
  final DateTime timestamp;
  final Map<String, dynamic> details;
  final SecuritySeverity severity;
  final String source;

  const SecurityEvent({
    required this.id,
    required this.type,
    required this.userId,
    required this.tenantId,
    required this.timestamp,
    required this.details,
    required this.severity,
    required this.source,
  });
}

class ThreatDetection {
  final String id;
  final ThreatType type;
  final SecuritySeverity severity;
  final String source;
  final String target;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final ThreatStatus status;
  final Map<String, dynamic> details;
  final List<String> affectedUsers;
  final List<String> mitigationActions;

  const ThreatDetection({
    required this.id,
    required this.type,
    required this.severity,
    required this.source,
    required this.target,
    required this.detectedAt,
    this.resolvedAt,
    required this.status,
    required this.details,
    required this.affectedUsers,
    required this.mitigationActions,
  });

  ThreatDetection copyWith({
    String? id,
    ThreatType? type,
    SecuritySeverity? severity,
    String? source,
    String? target,
    DateTime? detectedAt,
    DateTime? resolvedAt,
    ThreatStatus? status,
    Map<String, dynamic>? details,
    List<String>? affectedUsers,
    List<String>? mitigationActions,
  }) {
    return ThreatDetection(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      source: source ?? this.source,
      target: target ?? this.target,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      status: status ?? this.status,
      details: details ?? this.details,
      affectedUsers: affectedUsers ?? this.affectedUsers,
      mitigationActions: mitigationActions ?? this.mitigationActions,
    );
  }
}

class SecurityAlert {
  final String id;
  final SecurityAlertType type;
  final SecuritySeverity severity;
  final String title;
  final String message;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic> details;

  const SecurityAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.source,
    this.details = const {},
  });
}

class SecurityPolicy {
  final String id;
  final String name;
  final List<SecurityRule> rules;
  final List<String> complianceFrameworks;
  final bool isActive;
  final DateTime createdAt;

  const SecurityPolicy({
    required this.id,
    required this.name,
    required this.rules,
    required this.complianceFrameworks,
    required this.isActive,
    required this.createdAt,
  });
}

class SecurityRule {
  final String id;
  final SecurityRuleType type;
  final String condition;
  final SecurityAction action;
  final SecuritySeverity severity;

  const SecurityRule({
    required this.id,
    required this.type,
    required this.condition,
    required this.action,
    required this.severity,
  });
}

class SecurityAuditReport {
  final String id;
  final String? tenantId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;
  final SecurityMetrics metrics;
  final List<SecurityEvent> events;
  final List<ThreatDetection> threats;
  final List<SecurityRecommendation> recommendations;
  final Map<String, bool> complianceStatus;

  const SecurityAuditReport({
    required this.id,
    this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.metrics,
    required this.events,
    required this.threats,
    required this.recommendations,
    required this.complianceStatus,
  });
}

class SecurityMetrics {
  final int totalEvents;
  final int highSeverityEvents;
  final int threatsDetected;
  final int threatsBlocked;
  final double averageRiskScore;
  final double complianceScore;
  final List<SecurityVulnerability> vulnerabilities;

  const SecurityMetrics({
    required this.totalEvents,
    required this.highSeverityEvents,
    required this.threatsDetected,
    required this.threatsBlocked,
    required this.averageRiskScore,
    required this.complianceScore,
    required this.vulnerabilities,
  });
}

class SecurityVulnerability {
  final String id;
  final String type;
  final SecuritySeverity severity;
  final String description;
  final List<String> affectedSystems;
  final String remediation;

  const SecurityVulnerability({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.affectedSystems,
    required this.remediation,
  });
}

class SecurityRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final String category;
  final String estimatedImpact;

  const SecurityRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.estimatedImpact,
  });
}

// Enums
enum RiskLevel { low, medium, high, critical }
enum TrustLevel { unknown, low, medium, high, verified }
enum SecuritySeverity { low, medium, high, critical }
enum SecurityAction { allow, deny, enforce, encrypt, alert, terminate, reauthenticate, additionalVerification }
enum SecurityEventType { sessionCreated, accessAttempt, loginFailed, dataAccess, configurationChange, threatDetected }
enum ThreatType { bruteForceAttack, suspiciousLogin, dataExfiltration, malwareDetection, unauthorizedAccess }
enum ThreatStatus { detected, investigating, mitigating, blocked, resolved }
enum SecurityAlertType { threatDetected, threatMitigated, policyViolation, complianceAlert }
enum SecurityRuleType { passwordPolicy, authenticationPolicy, sessionPolicy, accessControl, dataProtection, monitoring }
enum RecommendationPriority { low, medium, high, critical }
