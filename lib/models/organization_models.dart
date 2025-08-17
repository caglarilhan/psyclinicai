import 'package:json_annotation/json_annotation.dart';

part 'organization_models.g.dart';

@JsonSerializable()
class Organization {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final OrganizationType type;
  final OrganizationStatus status;
  final String? website;
  final String? phone;
  final String? email;
  final Address address;
  final OrganizationSettings settings;
  final List<String> domains;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;

  const Organization({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.type,
    required this.status,
    this.website,
    this.phone,
    this.email,
    required this.address,
    required this.settings,
    required this.domains,
    required this.createdAt,
    this.updatedAt,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
  });

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationToJson(this);

  bool get isActive => status == OrganizationStatus.active;
  bool get isSuspended => status == OrganizationStatus.suspended;
}

@JsonSerializable()
class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  String get fullAddress => '$street, $city, $state $postalCode, $country';
}

@JsonSerializable()
class OrganizationSettings {
  final String id;
  final String organizationId;
  final String timezone;
  final String language;
  final String currency;
  final String dateFormat;
  final String timeFormat;
  final bool enableNotifications;
  final bool enableAuditLogging;
  final bool enableDataEncryption;
  final List<String> allowedFileTypes;
  final int maxFileSizeMB;
  final int sessionTimeoutMinutes;
  final bool enableTwoFactorAuth;
  final List<String> ipWhitelist;
  final Map<String, dynamic> customSettings;

  const OrganizationSettings({
    required this.id,
    required this.organizationId,
    required this.timezone,
    required this.language,
    required this.currency,
    required this.dateFormat,
    required this.timeFormat,
    required this.enableNotifications,
    required this.enableAuditLogging,
    required this.enableDataEncryption,
    required this.allowedFileTypes,
    required this.maxFileSizeMB,
    required this.sessionTimeoutMinutes,
    required this.enableTwoFactorAuth,
    required this.ipWhitelist,
    required this.customSettings,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) =>
      _$OrganizationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationSettingsToJson(this);
}

@JsonSerializable()
class OrganizationMember {
  final String id;
  final String organizationId;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final MemberRole role;
  final MemberStatus status;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final List<String> permissions;
  final String? department;
  final String? title;
  final String? phone;
  final bool isPrimaryContact;

  const OrganizationMember({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.lastActiveAt,
    required this.permissions,
    this.department,
    this.title,
    this.phone,
    required this.isPrimaryContact,
  });

  factory OrganizationMember.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMemberFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationMemberToJson(this);

  String get fullName => '$firstName $lastName';
  bool get isActive => status == MemberStatus.active;
  bool get isAdmin => role == MemberRole.admin || role == MemberRole.owner;
}

@JsonSerializable()
class OrganizationInvitation {
  final String id;
  final String organizationId;
  final String email;
  final String invitedBy;
  final MemberRole role;
  final InvitationStatus status;
  final DateTime invitedAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final String? token;
  final String? message;

  const OrganizationInvitation({
    required this.id,
    required this.organizationId,
    required this.email,
    required this.invitedBy,
    required this.role,
    required this.status,
    required this.invitedAt,
    required this.expiresAt,
    this.acceptedAt,
    this.token,
    this.message,
  });

  factory OrganizationInvitation.fromJson(Map<String, dynamic> json) =>
      _$OrganizationInvitationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationInvitationToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending;
}

@JsonSerializable()
class OrganizationDepartment {
  final String id;
  final String organizationId;
  final String name;
  final String? description;
  final String? managerId;
  final String? parentDepartmentId;
  final List<String> memberIds;
  final DepartmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrganizationDepartment({
    required this.id,
    required this.organizationId,
    required this.name,
    this.description,
    this.managerId,
    this.parentDepartmentId,
    required this.memberIds,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrganizationDepartment.fromJson(Map<String, dynamic> json) =>
      _$OrganizationDepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationDepartmentToJson(this);

  bool get isActive => status == DepartmentStatus.active;
}

@JsonSerializable()
class OrganizationIntegration {
  final String id;
  final String organizationId;
  final String name;
  final IntegrationType type;
  final IntegrationStatus status;
  final Map<String, dynamic> config;
  final DateTime connectedAt;
  final DateTime? lastSyncAt;
  final String? lastError;
  final bool isActive;
  final List<String> scopes;
  final Map<String, dynamic> metadata;

  const OrganizationIntegration({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.type,
    required this.status,
    required this.config,
    required this.connectedAt,
    this.lastSyncAt,
    this.lastError,
    required this.isActive,
    required this.scopes,
    required this.metadata,
  });

  factory OrganizationIntegration.fromJson(Map<String, dynamic> json) =>
      _$OrganizationIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationIntegrationToJson(this);

  bool get isConnected => status == IntegrationStatus.connected;
  bool get hasError => lastError != null && lastError!.isNotEmpty;
}

@JsonSerializable()
class OrganizationAuditLog {
  final String id;
  final String organizationId;
  final String userId;
  final String action;
  final String resource;
  final String details;
  final String ipAddress;
  final String userAgent;
  final AuditLogLevel level;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const OrganizationAuditLog({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.action,
    required this.resource,
    required this.details,
    required this.ipAddress,
    required this.userAgent,
    required this.level,
    required this.timestamp,
    this.metadata,
  });

  factory OrganizationAuditLog.fromJson(Map<String, dynamic> json) =>
      _$OrganizationAuditLogFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationAuditLogToJson(this);
}

enum OrganizationType {
  clinic,
  hospital,
  privatePractice,
  researchInstitute,
  university,
  government,
  nonprofit,
  other,
}

enum OrganizationStatus {
  active,
  inactive,
  suspended,
  pending,
  archived,
}

enum MemberRole {
  owner,
  admin,
  manager,
  member,
  viewer,
  guest,
}

enum MemberStatus {
  active,
  inactive,
  suspended,
  pending,
}

enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
  cancelled,
}

enum DepartmentStatus {
  active,
  inactive,
  archived,
}

enum IntegrationType {
  emr,
  billing,
  calendar,
  communication,
  analytics,
  security,
  compliance,
  other,
}

enum IntegrationStatus {
  connected,
  disconnected,
  error,
  pending,
  configuring,
}

enum AuditLogLevel {
  info,
  warning,
  error,
  critical,
}
