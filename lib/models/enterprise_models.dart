import 'package:json_annotation/json_annotation.dart';

part 'enterprise_models.g.dart';

/// Enterprise Tenant Model
@JsonSerializable()
class EnterpriseTenant {
  final String id;
  final String name;
  final String domain;
  final TenantTier tier;
  final TenantStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> settings;
  final List<String> allowedDomains;
  final int maxUsers;
  final int currentUsers;
  final double storageQuotaGB;
  final double storageUsedGB;
  final Map<String, bool> features;
  final BillingInfo billingInfo;
  final SecurityConfig securityConfig;
  final ComplianceSettings complianceSettings;

  const EnterpriseTenant({
    required this.id,
    required this.name,
    required this.domain,
    required this.tier,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.settings = const {},
    this.allowedDomains = const [],
    required this.maxUsers,
    required this.currentUsers,
    required this.storageQuotaGB,
    required this.storageUsedGB,
    this.features = const {},
    required this.billingInfo,
    required this.securityConfig,
    required this.complianceSettings,
  });

  factory EnterpriseTenant.fromJson(Map<String, dynamic> json) => _$EnterpriseTenantFromJson(json);
  Map<String, dynamic> toJson() => _$EnterpriseTenantToJson(this);

  bool get isActive => status == TenantStatus.active;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  double get storageUsagePercentage => (storageUsedGB / storageQuotaGB) * 100;
  bool get isStorageWarning => storageUsagePercentage > 80;
  bool get isStorageCritical => storageUsagePercentage > 95;
}

enum TenantTier {
  starter,
  professional,
  enterprise,
  premium,
  custom
}

enum TenantStatus {
  active,
  suspended,
  terminated,
  pending,
  trial
}

/// Role-Based Access Control (RBAC) Models
@JsonSerializable()
class Role {
  final String id;
  final String name;
  final String description;
  final List<Permission> permissions;
  final RoleType type;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.type,
    required this.isSystem,
    required this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

enum RoleType {
  superAdmin,
  tenantAdmin,
  clinician,
  therapist,
  supervisor,
  patient,
  support,
  auditor
}

@JsonSerializable()
class Permission {
  final String id;
  final String resource;
  final List<String> actions;
  final Map<String, dynamic> conditions;

  const Permission({
    required this.id,
    required this.resource,
    required this.actions,
    this.conditions = const {},
  });

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionToJson(this);
}

/// Enterprise User Model
@JsonSerializable()
class EnterpriseUser {
  final String id;
  final String tenantId;
  final String email;
  final String firstName;
  final String lastName;
  final UserStatus status;
  final List<Role> roles;
  final Map<String, dynamic> profile;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? passwordChangedAt;
  final bool mfaEnabled;
  final SSOConfig? ssoConfig;
  final List<UserSession> activeSessions;

  const EnterpriseUser({
    required this.id,
    required this.tenantId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.roles,
    this.profile = const {},
    required this.createdAt,
    this.lastLoginAt,
    this.passwordChangedAt,
    required this.mfaEnabled,
    this.ssoConfig,
    this.activeSessions = const [],
  });

  factory EnterpriseUser.fromJson(Map<String, dynamic> json) => _$EnterpriseUserFromJson(json);
  Map<String, dynamic> toJson() => _$EnterpriseUserToJson(this);

  String get fullName => '$firstName $lastName';
  bool get isActive => status == UserStatus.active;
  bool get requiresPasswordChange => passwordChangedAt == null || 
    DateTime.now().difference(passwordChangedAt!).inDays > 90;
}

enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
  locked
}

/// SSO Configuration
@JsonSerializable()
class SSOConfig {
  final String provider;
  final String domain;
  final Map<String, String> settings;
  final bool autoProvisioning;
  final Map<String, String> attributeMapping;

  const SSOConfig({
    required this.provider,
    required this.domain,
    required this.settings,
    required this.autoProvisioning,
    required this.attributeMapping,
  });

  factory SSOConfig.fromJson(Map<String, dynamic> json) => _$SSOConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SSOConfigToJson(this);
}

/// User Session Management
@JsonSerializable()
class UserSession {
  final String id;
  final String userId;
  final String deviceId;
  final String ipAddress;
  final String userAgent;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;

  const UserSession({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
    required this.lastActivity,
    required this.isActive,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => _$UserSessionFromJson(json);
  Map<String, dynamic> toJson() => _$UserSessionToJson(this);
}

/// Billing Information
@JsonSerializable()
class BillingInfo {
  final String customerId;
  final String subscriptionId;
  final BillingCycle cycle;
  final double monthlyFee;
  final double yearlyFee;
  final PaymentMethod paymentMethod;
  final DateTime? nextBillingDate;
  final BillingStatus status;

  const BillingInfo({
    required this.customerId,
    required this.subscriptionId,
    required this.cycle,
    required this.monthlyFee,
    required this.yearlyFee,
    required this.paymentMethod,
    this.nextBillingDate,
    required this.status,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) => _$BillingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BillingInfoToJson(this);
}

enum BillingCycle {
  monthly,
  yearly,
  custom
}

enum BillingStatus {
  active,
  pastDue,
  cancelled,
  suspended
}

@JsonSerializable()
class PaymentMethod {
  final String type;
  final String last4;
  final String brand;
  final int expMonth;
  final int expYear;

  const PaymentMethod({
    required this.type,
    required this.last4,
    required this.brand,
    required this.expMonth,
    required this.expYear,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

/// Security Configuration
@JsonSerializable()
class SecurityConfig {
  final bool mfaRequired;
  final int passwordMinLength;
  final bool passwordComplexity;
  final int sessionTimeout;
  final bool ipWhitelisting;
  final List<String> allowedIPs;
  final EncryptionSettings encryption;

  const SecurityConfig({
    required this.mfaRequired,
    required this.passwordMinLength,
    required this.passwordComplexity,
    required this.sessionTimeout,
    required this.ipWhitelisting,
    this.allowedIPs = const [],
    required this.encryption,
  });

  factory SecurityConfig.fromJson(Map<String, dynamic> json) => _$SecurityConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SecurityConfigToJson(this);
}

@JsonSerializable()
class EncryptionSettings {
  final String algorithm;
  final int keySize;
  final bool dataAtRest;
  final bool dataInTransit;

  const EncryptionSettings({
    required this.algorithm,
    required this.keySize,
    required this.dataAtRest,
    required this.dataInTransit,
  });

  factory EncryptionSettings.fromJson(Map<String, dynamic> json) => _$EncryptionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$EncryptionSettingsToJson(this);
}

/// Compliance Settings
@JsonSerializable()
class ComplianceSettings {
  final bool hipaaCompliant;
  final bool gdprCompliant;
  final bool soc2Compliant;
  final List<String> certifications;
  final AuditSettings auditSettings;
  final DataRetentionPolicy dataRetention;

  const ComplianceSettings({
    required this.hipaaCompliant,
    required this.gdprCompliant,
    required this.soc2Compliant,
    this.certifications = const [],
    required this.auditSettings,
    required this.dataRetention,
  });

  factory ComplianceSettings.fromJson(Map<String, dynamic> json) => _$ComplianceSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceSettingsToJson(this);
}

@JsonSerializable()
class AuditSettings {
  final bool enabled;
  final List<String> loggedEvents;
  final int retentionDays;
  final bool realTimeMonitoring;

  const AuditSettings({
    required this.enabled,
    this.loggedEvents = const [],
    required this.retentionDays,
    required this.realTimeMonitoring,
  });

  factory AuditSettings.fromJson(Map<String, dynamic> json) => _$AuditSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AuditSettingsToJson(this);
}

@JsonSerializable()
class DataRetentionPolicy {
  final int patientDataDays;
  final int sessionDataDays;
  final int auditLogDays;
  final bool autoDelete;

  const DataRetentionPolicy({
    required this.patientDataDays,
    required this.sessionDataDays,
    required this.auditLogDays,
    required this.autoDelete,
  });

  factory DataRetentionPolicy.fromJson(Map<String, dynamic> json) => _$DataRetentionPolicyFromJson(json);
  Map<String, dynamic> toJson() => _$DataRetentionPolicyToJson(this);
}
