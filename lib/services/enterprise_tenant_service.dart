import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psyclinicai/models/enterprise_models.dart';

/// Enterprise Tenant Management Service for PsyClinicAI
/// Provides advanced multi-tenant capabilities for enterprise deployments
class EnterpriseTenantService {
  static final EnterpriseTenantService _instance = EnterpriseTenantService._internal();
  factory EnterpriseTenantService() => _instance;
  EnterpriseTenantService._internal();

  final Map<String, EnterpriseTenant> _tenants = {};
  final Map<String, List<EnterpriseUser>> _tenantUsers = {};
  final Map<String, List<Role>> _tenantRoles = {};
  final Map<String, List<UserSession>> _activeSessions = {};

  // Stream controllers for real-time updates
  final StreamController<EnterpriseTenant> _tenantUpdateController = StreamController<EnterpriseTenant>.broadcast();
  final StreamController<EnterpriseUser> _userUpdateController = StreamController<EnterpriseUser>.broadcast();
  final StreamController<UserSession> _sessionController = StreamController<UserSession>.broadcast();

  Stream<EnterpriseTenant> get tenantUpdateStream => _tenantUpdateController.stream;
  Stream<EnterpriseUser> get userUpdateStream => _userUpdateController.stream;
  Stream<UserSession> get sessionStream => _sessionController.stream;

  /// Initialize the service with mock data
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _loadMockData();
    print('✅ Enterprise Tenant Service initialized');
  }

  /// Load mock enterprise data
  Future<void> _loadMockData() async {
    // Mock enterprise tenants
    final tenants = [
      EnterpriseTenant(
        id: 'tenant_001',
        name: 'PsyHealth Enterprise',
        domain: 'psyhealth.com',
        tier: TenantTier.enterprise,
        status: TenantStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        maxUsers: 1000,
        currentUsers: 750,
        storageQuotaGB: 1000.0,
        storageUsedGB: 650.0,
        allowedDomains: ['psyhealth.com', 'psyhealth.org'],
        features: {
          'advanced_analytics': true,
          'sso_integration': true,
          'custom_branding': true,
          'api_access': true,
          'audit_logs': true,
          'data_export': true,
        },
        billingInfo: BillingInfo(
          customerId: 'cus_enterprise_001',
          subscriptionId: 'sub_enterprise_001',
          cycle: BillingCycle.yearly,
          monthlyFee: 9999.99,
          yearlyFee: 99999.99,
          paymentMethod: PaymentMethod(
            type: 'card',
            last4: '4242',
            brand: 'visa',
            expMonth: 12,
            expYear: 2025,
          ),
          nextBillingDate: DateTime.now().add(const Duration(days: 90)),
          status: BillingStatus.active,
        ),
        securityConfig: SecurityConfig(
          mfaRequired: true,
          passwordMinLength: 12,
          passwordComplexity: true,
          sessionTimeout: 3600,
          ipWhitelisting: true,
          allowedIPs: ['192.168.1.0/24', '10.0.0.0/8'],
          encryption: EncryptionSettings(
            algorithm: 'AES-256',
            keySize: 256,
            dataAtRest: true,
            dataInTransit: true,
          ),
        ),
        complianceSettings: ComplianceSettings(
          hipaaCompliant: true,
          gdprCompliant: true,
          soc2Compliant: true,
          certifications: ['SOC 2 Type II', 'HIPAA', 'GDPR'],
          auditSettings: AuditSettings(
            enabled: true,
            loggedEvents: ['login', 'logout', 'data_access', 'data_modification'],
            retentionDays: 2555, // 7 years
            realTimeMonitoring: true,
          ),
          dataRetention: DataRetentionPolicy(
            patientDataDays: 2555, // 7 years
            sessionDataDays: 1825, // 5 years
            auditLogDays: 2555, // 7 years
            autoDelete: false,
          ),
        ),
      ),
      EnterpriseTenant(
        id: 'tenant_002',
        name: 'MindCare Professional',
        domain: 'mindcare.pro',
        tier: TenantTier.professional,
        status: TenantStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        maxUsers: 250,
        currentUsers: 180,
        storageQuotaGB: 250.0,
        storageUsedGB: 150.0,
        allowedDomains: ['mindcare.pro'],
        features: {
          'advanced_analytics': true,
          'sso_integration': false,
          'custom_branding': true,
          'api_access': true,
          'audit_logs': false,
          'data_export': true,
        },
        billingInfo: BillingInfo(
          customerId: 'cus_pro_002',
          subscriptionId: 'sub_pro_002',
          cycle: BillingCycle.monthly,
          monthlyFee: 2499.99,
          yearlyFee: 24999.99,
          paymentMethod: PaymentMethod(
            type: 'card',
            last4: '8888',
            brand: 'mastercard',
            expMonth: 6,
            expYear: 2026,
          ),
          nextBillingDate: DateTime.now().add(const Duration(days: 30)),
          status: BillingStatus.active,
        ),
        securityConfig: SecurityConfig(
          mfaRequired: false,
          passwordMinLength: 8,
          passwordComplexity: true,
          sessionTimeout: 7200,
          ipWhitelisting: false,
          allowedIPs: [],
          encryption: EncryptionSettings(
            algorithm: 'AES-256',
            keySize: 256,
            dataAtRest: true,
            dataInTransit: true,
          ),
        ),
        complianceSettings: ComplianceSettings(
          hipaaCompliant: true,
          gdprCompliant: true,
          soc2Compliant: false,
          certifications: ['HIPAA', 'GDPR'],
          auditSettings: AuditSettings(
            enabled: true,
            loggedEvents: ['login', 'logout', 'data_access'],
            retentionDays: 365,
            realTimeMonitoring: false,
          ),
          dataRetention: DataRetentionPolicy(
            patientDataDays: 1825, // 5 years
            sessionDataDays: 1095, // 3 years
            auditLogDays: 365, // 1 year
            autoDelete: true,
          ),
        ),
      ),
    ];

    for (final tenant in tenants) {
      _tenants[tenant.id] = tenant;
      await _generateMockUsers(tenant.id, tenant.currentUsers);
      await _generateMockRoles(tenant.id);
    }
  }

  /// Generate mock users for a tenant
  Future<void> _generateMockUsers(String tenantId, int userCount) async {
    final users = <EnterpriseUser>[];
    final random = Random();

    for (int i = 0; i < userCount; i++) {
      final roles = await _getRandomRoles(tenantId, random);
      
      users.add(EnterpriseUser(
        id: 'user_${tenantId}_$i',
        tenantId: tenantId,
        email: 'user$i@${_tenants[tenantId]?.domain ?? 'example.com'}',
        firstName: _generateRandomFirstName(random),
        lastName: _generateRandomLastName(random),
        status: _getRandomUserStatus(random),
        roles: roles,
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
        lastLoginAt: DateTime.now().subtract(Duration(hours: random.nextInt(720))),
        passwordChangedAt: DateTime.now().subtract(Duration(days: random.nextInt(90))),
        mfaEnabled: random.nextBool(),
        activeSessions: [],
      ));
    }

    _tenantUsers[tenantId] = users;
  }

  /// Generate mock roles for a tenant
  Future<void> _generateMockRoles(String tenantId) async {
    final roles = [
      Role(
        id: 'role_admin_$tenantId',
        name: 'Tenant Administrator',
        description: 'Full administrative access to tenant',
        permissions: [
          Permission(
            id: 'perm_admin_all',
            resource: '*',
            actions: ['create', 'read', 'update', 'delete', 'manage'],
          ),
        ],
        type: RoleType.tenantAdmin,
        isSystem: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Role(
        id: 'role_clinician_$tenantId',
        name: 'Clinician',
        description: 'Clinical access with patient management',
        permissions: [
          Permission(
            id: 'perm_patient_manage',
            resource: 'patients',
            actions: ['create', 'read', 'update'],
          ),
          Permission(
            id: 'perm_session_manage',
            resource: 'sessions',
            actions: ['create', 'read', 'update'],
          ),
        ],
        type: RoleType.clinician,
        isSystem: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Role(
        id: 'role_therapist_$tenantId',
        name: 'Therapist',
        description: 'Therapy session management',
        permissions: [
          Permission(
            id: 'perm_session_conduct',
            resource: 'sessions',
            actions: ['create', 'read', 'update'],
          ),
          Permission(
            id: 'perm_patient_view',
            resource: 'patients',
            actions: ['read'],
          ),
        ],
        type: RoleType.therapist,
        isSystem: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
    ];

    _tenantRoles[tenantId] = roles;
  }

  /// Get all tenants
  Future<List<EnterpriseTenant>> getAllTenants() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _tenants.values.toList();
  }

  /// Get tenant by ID
  Future<EnterpriseTenant?> getTenantById(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tenants[tenantId];
  }

  /// Get tenant by domain
  Future<EnterpriseTenant?> getTenantByDomain(String domain) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    for (final tenant in _tenants.values) {
      if (tenant.domain == domain || tenant.allowedDomains.contains(domain)) {
        return tenant;
      }
    }
    return null;
  }

  /// Create new tenant
  Future<EnterpriseTenant> createTenant({
    required String name,
    required String domain,
    required TenantTier tier,
    required int maxUsers,
    required double storageQuotaGB,
    Map<String, bool> features = const {},
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final tenant = EnterpriseTenant(
      id: 'tenant_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      domain: domain,
      tier: tier,
      status: TenantStatus.pending,
      createdAt: DateTime.now(),
      maxUsers: maxUsers,
      currentUsers: 0,
      storageQuotaGB: storageQuotaGB,
      storageUsedGB: 0.0,
      allowedDomains: [domain],
      features: features,
      billingInfo: BillingInfo(
        customerId: 'cus_new_${DateTime.now().millisecondsSinceEpoch}',
        subscriptionId: 'sub_new_${DateTime.now().millisecondsSinceEpoch}',
        cycle: BillingCycle.monthly,
        monthlyFee: _getTierPricing(tier)['monthly']!,
        yearlyFee: _getTierPricing(tier)['yearly']!,
        paymentMethod: PaymentMethod(
          type: 'card',
          last4: '0000',
          brand: 'pending',
          expMonth: 1,
          expYear: 2030,
        ),
        status: BillingStatus.active,
      ),
      securityConfig: _getDefaultSecurityConfig(tier),
      complianceSettings: _getDefaultComplianceSettings(tier),
    );
    
    _tenants[tenant.id] = tenant;
    _tenantUsers[tenant.id] = [];
    _tenantRoles[tenant.id] = [];
    
    _tenantUpdateController.add(tenant);
    
    return tenant;
  }

  /// Update tenant
  Future<EnterpriseTenant> updateTenant(String tenantId, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final tenant = _tenants[tenantId];
    if (tenant == null) {
      throw Exception('Tenant not found: $tenantId');
    }
    
    // In a real implementation, you would properly update the tenant
    // For now, we'll return the existing tenant
    _tenantUpdateController.add(tenant);
    
    return tenant;
  }

  /// Get tenant users
  Future<List<EnterpriseUser>> getTenantUsers(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _tenantUsers[tenantId] ?? [];
  }

  /// Get tenant roles
  Future<List<Role>> getTenantRoles(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _tenantRoles[tenantId] ?? [];
  }

  /// Create user for tenant
  Future<EnterpriseUser> createTenantUser({
    required String tenantId,
    required String email,
    required String firstName,
    required String lastName,
    required List<String> roleIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final tenant = _tenants[tenantId];
    if (tenant == null) {
      throw Exception('Tenant not found: $tenantId');
    }
    
    if (tenant.currentUsers >= tenant.maxUsers) {
      throw Exception('Tenant user limit exceeded');
    }
    
    final roles = _tenantRoles[tenantId]?.where((role) => roleIds.contains(role.id)).toList() ?? [];
    
    final user = EnterpriseUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      status: UserStatus.pending,
      roles: roles,
      createdAt: DateTime.now(),
      mfaEnabled: tenant.securityConfig.mfaRequired,
    );
    
    _tenantUsers[tenantId]?.add(user);
    _userUpdateController.add(user);
    
    return user;
  }

  /// Get tenant analytics
  Future<Map<String, dynamic>> getTenantAnalytics(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final tenant = _tenants[tenantId];
    final users = _tenantUsers[tenantId] ?? [];
    
    if (tenant == null) {
      throw Exception('Tenant not found: $tenantId');
    }
    
    final activeUsers = users.where((u) => u.status == UserStatus.active).length;
    final recentLogins = users.where((u) => 
      u.lastLoginAt != null && 
      DateTime.now().difference(u.lastLoginAt!).inDays <= 7
    ).length;
    
    return {
      'tenant_id': tenantId,
      'total_users': users.length,
      'active_users': activeUsers,
      'inactive_users': users.length - activeUsers,
      'recent_logins': recentLogins,
      'storage_usage': {
        'used_gb': tenant.storageUsedGB,
        'quota_gb': tenant.storageQuotaGB,
        'usage_percentage': tenant.storageUsagePercentage,
      },
      'compliance_status': {
        'hipaa': tenant.complianceSettings.hipaaCompliant,
        'gdpr': tenant.complianceSettings.gdprCompliant,
        'soc2': tenant.complianceSettings.soc2Compliant,
      },
    };
  }

  // Helper methods
  Map<String, double> _getTierPricing(TenantTier tier) {
    switch (tier) {
      case TenantTier.starter:
        return {'monthly': 99.99, 'yearly': 999.99};
      case TenantTier.professional:
        return {'monthly': 2499.99, 'yearly': 24999.99};
      case TenantTier.enterprise:
        return {'monthly': 9999.99, 'yearly': 99999.99};
      case TenantTier.premium:
        return {'monthly': 19999.99, 'yearly': 199999.99};
      case TenantTier.custom:
        return {'monthly': 0.0, 'yearly': 0.0};
    }
  }

  SecurityConfig _getDefaultSecurityConfig(TenantTier tier) {
    final isEnterprise = tier == TenantTier.enterprise || tier == TenantTier.premium;
    
    return SecurityConfig(
      mfaRequired: isEnterprise,
      passwordMinLength: isEnterprise ? 12 : 8,
      passwordComplexity: true,
      sessionTimeout: isEnterprise ? 3600 : 7200,
      ipWhitelisting: isEnterprise,
      allowedIPs: [],
      encryption: EncryptionSettings(
        algorithm: 'AES-256',
        keySize: 256,
        dataAtRest: true,
        dataInTransit: true,
      ),
    );
  }

  ComplianceSettings _getDefaultComplianceSettings(TenantTier tier) {
    final isEnterprise = tier == TenantTier.enterprise || tier == TenantTier.premium;
    
    return ComplianceSettings(
      hipaaCompliant: true,
      gdprCompliant: true,
      soc2Compliant: isEnterprise,
      certifications: isEnterprise ? ['HIPAA', 'GDPR', 'SOC 2 Type II'] : ['HIPAA', 'GDPR'],
      auditSettings: AuditSettings(
        enabled: true,
        loggedEvents: ['login', 'logout', 'data_access'],
        retentionDays: isEnterprise ? 2555 : 365,
        realTimeMonitoring: isEnterprise,
      ),
      dataRetention: DataRetentionPolicy(
        patientDataDays: 2555, // 7 years (regulatory requirement)
        sessionDataDays: isEnterprise ? 1825 : 1095,
        auditLogDays: isEnterprise ? 2555 : 365,
        autoDelete: !isEnterprise,
      ),
    );
  }

  Future<List<Role>> _getRandomRoles(String tenantId, Random random) async {
    final roles = _tenantRoles[tenantId] ?? [];
    if (roles.isEmpty) return [];
    
    final roleCount = random.nextInt(2) + 1; // 1-2 roles
    final selectedRoles = <Role>[];
    
    for (int i = 0; i < roleCount && i < roles.length; i++) {
      selectedRoles.add(roles[random.nextInt(roles.length)]);
    }
    
    return selectedRoles;
  }

  String _generateRandomFirstName(Random random) {
    final names = ['John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Emily'];
    return names[random.nextInt(names.length)];
  }

  String _generateRandomLastName(Random random) {
    final names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis'];
    return names[random.nextInt(names.length)];
  }

  UserStatus _getRandomUserStatus(Random random) {
    final statuses = [UserStatus.active, UserStatus.active, UserStatus.active, UserStatus.inactive];
    return statuses[random.nextInt(statuses.length)];
  }

  /// Dispose resources
  void dispose() {
    _tenantUpdateController.close();
    _userUpdateController.close();
    _sessionController.close();
  }
}
