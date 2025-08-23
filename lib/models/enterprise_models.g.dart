// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enterprise_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnterpriseTenant _$EnterpriseTenantFromJson(Map<String, dynamic> json) =>
    EnterpriseTenant(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: json['domain'] as String,
      tier: $enumDecode(_$TenantTierEnumMap, json['tier']),
      status: $enumDecode(_$TenantStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      allowedDomains:
          (json['allowedDomains'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      maxUsers: (json['maxUsers'] as num).toInt(),
      currentUsers: (json['currentUsers'] as num).toInt(),
      storageQuotaGB: (json['storageQuotaGB'] as num).toDouble(),
      storageUsedGB: (json['storageUsedGB'] as num).toDouble(),
      features:
          (json['features'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
      billingInfo: BillingInfo.fromJson(
        json['billingInfo'] as Map<String, dynamic>,
      ),
      securityConfig: SecurityConfig.fromJson(
        json['securityConfig'] as Map<String, dynamic>,
      ),
      complianceSettings: ComplianceSettings.fromJson(
        json['complianceSettings'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$EnterpriseTenantToJson(EnterpriseTenant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'domain': instance.domain,
      'tier': _$TenantTierEnumMap[instance.tier]!,
      'status': _$TenantStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'settings': instance.settings,
      'allowedDomains': instance.allowedDomains,
      'maxUsers': instance.maxUsers,
      'currentUsers': instance.currentUsers,
      'storageQuotaGB': instance.storageQuotaGB,
      'storageUsedGB': instance.storageUsedGB,
      'features': instance.features,
      'billingInfo': instance.billingInfo,
      'securityConfig': instance.securityConfig,
      'complianceSettings': instance.complianceSettings,
    };

const _$TenantTierEnumMap = {
  TenantTier.starter: 'starter',
  TenantTier.professional: 'professional',
  TenantTier.enterprise: 'enterprise',
  TenantTier.premium: 'premium',
  TenantTier.custom: 'custom',
};

const _$TenantStatusEnumMap = {
  TenantStatus.active: 'active',
  TenantStatus.suspended: 'suspended',
  TenantStatus.terminated: 'terminated',
  TenantStatus.pending: 'pending',
  TenantStatus.trial: 'trial',
};

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => Permission.fromJson(e as Map<String, dynamic>))
      .toList(),
  type: $enumDecode(_$RoleTypeEnumMap, json['type']),
  isSystem: json['isSystem'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'permissions': instance.permissions,
  'type': _$RoleTypeEnumMap[instance.type]!,
  'isSystem': instance.isSystem,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$RoleTypeEnumMap = {
  RoleType.superAdmin: 'superAdmin',
  RoleType.tenantAdmin: 'tenantAdmin',
  RoleType.clinician: 'clinician',
  RoleType.therapist: 'therapist',
  RoleType.supervisor: 'supervisor',
  RoleType.patient: 'patient',
  RoleType.support: 'support',
  RoleType.auditor: 'auditor',
};

Permission _$PermissionFromJson(Map<String, dynamic> json) => Permission(
  id: json['id'] as String,
  resource: json['resource'] as String,
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  conditions: json['conditions'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PermissionToJson(Permission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resource': instance.resource,
      'actions': instance.actions,
      'conditions': instance.conditions,
    };

EnterpriseUser _$EnterpriseUserFromJson(Map<String, dynamic> json) =>
    EnterpriseUser(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      roles: (json['roles'] as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      profile: json['profile'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      passwordChangedAt: json['passwordChangedAt'] == null
          ? null
          : DateTime.parse(json['passwordChangedAt'] as String),
      mfaEnabled: json['mfaEnabled'] as bool,
      ssoConfig: json['ssoConfig'] == null
          ? null
          : SSOConfig.fromJson(json['ssoConfig'] as Map<String, dynamic>),
      activeSessions:
          (json['activeSessions'] as List<dynamic>?)
              ?.map((e) => UserSession.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EnterpriseUserToJson(EnterpriseUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'status': _$UserStatusEnumMap[instance.status]!,
      'roles': instance.roles,
      'profile': instance.profile,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'passwordChangedAt': instance.passwordChangedAt?.toIso8601String(),
      'mfaEnabled': instance.mfaEnabled,
      'ssoConfig': instance.ssoConfig,
      'activeSessions': instance.activeSessions,
    };

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
  UserStatus.suspended: 'suspended',
  UserStatus.pending: 'pending',
  UserStatus.locked: 'locked',
};

SSOConfig _$SSOConfigFromJson(Map<String, dynamic> json) => SSOConfig(
  provider: json['provider'] as String,
  domain: json['domain'] as String,
  settings: Map<String, String>.from(json['settings'] as Map),
  autoProvisioning: json['autoProvisioning'] as bool,
  attributeMapping: Map<String, String>.from(json['attributeMapping'] as Map),
);

Map<String, dynamic> _$SSOConfigToJson(SSOConfig instance) => <String, dynamic>{
  'provider': instance.provider,
  'domain': instance.domain,
  'settings': instance.settings,
  'autoProvisioning': instance.autoProvisioning,
  'attributeMapping': instance.attributeMapping,
};

UserSession _$UserSessionFromJson(Map<String, dynamic> json) => UserSession(
  id: json['id'] as String,
  userId: json['userId'] as String,
  deviceId: json['deviceId'] as String,
  ipAddress: json['ipAddress'] as String,
  userAgent: json['userAgent'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastActivity: DateTime.parse(json['lastActivity'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$UserSessionToJson(UserSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActivity': instance.lastActivity.toIso8601String(),
      'isActive': instance.isActive,
    };

BillingInfo _$BillingInfoFromJson(Map<String, dynamic> json) => BillingInfo(
  customerId: json['customerId'] as String,
  subscriptionId: json['subscriptionId'] as String,
  cycle: $enumDecode(_$BillingCycleEnumMap, json['cycle']),
  monthlyFee: (json['monthlyFee'] as num).toDouble(),
  yearlyFee: (json['yearlyFee'] as num).toDouble(),
  paymentMethod: PaymentMethod.fromJson(
    json['paymentMethod'] as Map<String, dynamic>,
  ),
  nextBillingDate: json['nextBillingDate'] == null
      ? null
      : DateTime.parse(json['nextBillingDate'] as String),
  status: $enumDecode(_$BillingStatusEnumMap, json['status']),
);

Map<String, dynamic> _$BillingInfoToJson(BillingInfo instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'subscriptionId': instance.subscriptionId,
      'cycle': _$BillingCycleEnumMap[instance.cycle]!,
      'monthlyFee': instance.monthlyFee,
      'yearlyFee': instance.yearlyFee,
      'paymentMethod': instance.paymentMethod,
      'nextBillingDate': instance.nextBillingDate?.toIso8601String(),
      'status': _$BillingStatusEnumMap[instance.status]!,
    };

const _$BillingCycleEnumMap = {
  BillingCycle.monthly: 'monthly',
  BillingCycle.yearly: 'yearly',
  BillingCycle.custom: 'custom',
};

const _$BillingStatusEnumMap = {
  BillingStatus.active: 'active',
  BillingStatus.pastDue: 'pastDue',
  BillingStatus.cancelled: 'cancelled',
  BillingStatus.suspended: 'suspended',
};

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      type: json['type'] as String,
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      expMonth: (json['expMonth'] as num).toInt(),
      expYear: (json['expYear'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'type': instance.type,
      'last4': instance.last4,
      'brand': instance.brand,
      'expMonth': instance.expMonth,
      'expYear': instance.expYear,
    };

SecurityConfig _$SecurityConfigFromJson(Map<String, dynamic> json) =>
    SecurityConfig(
      mfaRequired: json['mfaRequired'] as bool,
      passwordMinLength: (json['passwordMinLength'] as num).toInt(),
      passwordComplexity: json['passwordComplexity'] as bool,
      sessionTimeout: (json['sessionTimeout'] as num).toInt(),
      ipWhitelisting: json['ipWhitelisting'] as bool,
      allowedIPs:
          (json['allowedIPs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      encryption: EncryptionSettings.fromJson(
        json['encryption'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SecurityConfigToJson(SecurityConfig instance) =>
    <String, dynamic>{
      'mfaRequired': instance.mfaRequired,
      'passwordMinLength': instance.passwordMinLength,
      'passwordComplexity': instance.passwordComplexity,
      'sessionTimeout': instance.sessionTimeout,
      'ipWhitelisting': instance.ipWhitelisting,
      'allowedIPs': instance.allowedIPs,
      'encryption': instance.encryption,
    };

EncryptionSettings _$EncryptionSettingsFromJson(Map<String, dynamic> json) =>
    EncryptionSettings(
      algorithm: json['algorithm'] as String,
      keySize: (json['keySize'] as num).toInt(),
      dataAtRest: json['dataAtRest'] as bool,
      dataInTransit: json['dataInTransit'] as bool,
    );

Map<String, dynamic> _$EncryptionSettingsToJson(EncryptionSettings instance) =>
    <String, dynamic>{
      'algorithm': instance.algorithm,
      'keySize': instance.keySize,
      'dataAtRest': instance.dataAtRest,
      'dataInTransit': instance.dataInTransit,
    };

ComplianceSettings _$ComplianceSettingsFromJson(Map<String, dynamic> json) =>
    ComplianceSettings(
      hipaaCompliant: json['hipaaCompliant'] as bool,
      gdprCompliant: json['gdprCompliant'] as bool,
      soc2Compliant: json['soc2Compliant'] as bool,
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      auditSettings: AuditSettings.fromJson(
        json['auditSettings'] as Map<String, dynamic>,
      ),
      dataRetention: DataRetentionPolicy.fromJson(
        json['dataRetention'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ComplianceSettingsToJson(ComplianceSettings instance) =>
    <String, dynamic>{
      'hipaaCompliant': instance.hipaaCompliant,
      'gdprCompliant': instance.gdprCompliant,
      'soc2Compliant': instance.soc2Compliant,
      'certifications': instance.certifications,
      'auditSettings': instance.auditSettings,
      'dataRetention': instance.dataRetention,
    };

AuditSettings _$AuditSettingsFromJson(Map<String, dynamic> json) =>
    AuditSettings(
      enabled: json['enabled'] as bool,
      loggedEvents:
          (json['loggedEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      retentionDays: (json['retentionDays'] as num).toInt(),
      realTimeMonitoring: json['realTimeMonitoring'] as bool,
    );

Map<String, dynamic> _$AuditSettingsToJson(AuditSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'loggedEvents': instance.loggedEvents,
      'retentionDays': instance.retentionDays,
      'realTimeMonitoring': instance.realTimeMonitoring,
    };

DataRetentionPolicy _$DataRetentionPolicyFromJson(Map<String, dynamic> json) =>
    DataRetentionPolicy(
      patientDataDays: (json['patientDataDays'] as num).toInt(),
      sessionDataDays: (json['sessionDataDays'] as num).toInt(),
      auditLogDays: (json['auditLogDays'] as num).toInt(),
      autoDelete: json['autoDelete'] as bool,
    );

Map<String, dynamic> _$DataRetentionPolicyToJson(
  DataRetentionPolicy instance,
) => <String, dynamic>{
  'patientDataDays': instance.patientDataDays,
  'sessionDataDays': instance.sessionDataDays,
  'auditLogDays': instance.auditLogDays,
  'autoDelete': instance.autoDelete,
};
