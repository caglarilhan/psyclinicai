// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) => Organization(
  id: json['id'] as String,
  name: json['name'] as String,
  displayName: json['displayName'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$OrganizationTypeEnumMap, json['type']),
  status: $enumDecode(_$OrganizationStatusEnumMap, json['status']),
  website: json['website'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
  settings: OrganizationSettings.fromJson(
    json['settings'] as Map<String, dynamic>,
  ),
  domains: (json['domains'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  logoUrl: json['logoUrl'] as String?,
  primaryColor: json['primaryColor'] as String?,
  secondaryColor: json['secondaryColor'] as String?,
);

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'description': instance.description,
      'type': _$OrganizationTypeEnumMap[instance.type]!,
      'status': _$OrganizationStatusEnumMap[instance.status]!,
      'website': instance.website,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'settings': instance.settings,
      'domains': instance.domains,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
    };

const _$OrganizationTypeEnumMap = {
  OrganizationType.clinic: 'clinic',
  OrganizationType.hospital: 'hospital',
  OrganizationType.privatePractice: 'privatePractice',
  OrganizationType.researchInstitute: 'researchInstitute',
  OrganizationType.university: 'university',
  OrganizationType.government: 'government',
  OrganizationType.nonprofit: 'nonprofit',
  OrganizationType.other: 'other',
};

const _$OrganizationStatusEnumMap = {
  OrganizationStatus.active: 'active',
  OrganizationStatus.inactive: 'inactive',
  OrganizationStatus.suspended: 'suspended',
  OrganizationStatus.pending: 'pending',
  OrganizationStatus.archived: 'archived',
};

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  street: json['street'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  postalCode: json['postalCode'] as String,
  country: json['country'] as String,
  countryCode: json['countryCode'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'street': instance.street,
  'city': instance.city,
  'state': instance.state,
  'postalCode': instance.postalCode,
  'country': instance.country,
  'countryCode': instance.countryCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

OrganizationSettings _$OrganizationSettingsFromJson(
  Map<String, dynamic> json,
) => OrganizationSettings(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  timezone: json['timezone'] as String,
  language: json['language'] as String,
  currency: json['currency'] as String,
  dateFormat: json['dateFormat'] as String,
  timeFormat: json['timeFormat'] as String,
  enableNotifications: json['enableNotifications'] as bool,
  enableAuditLogging: json['enableAuditLogging'] as bool,
  enableDataEncryption: json['enableDataEncryption'] as bool,
  allowedFileTypes: (json['allowedFileTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  maxFileSizeMB: (json['maxFileSizeMB'] as num).toInt(),
  sessionTimeoutMinutes: (json['sessionTimeoutMinutes'] as num).toInt(),
  enableTwoFactorAuth: json['enableTwoFactorAuth'] as bool,
  ipWhitelist: (json['ipWhitelist'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  customSettings: json['customSettings'] as Map<String, dynamic>,
);

Map<String, dynamic> _$OrganizationSettingsToJson(
  OrganizationSettings instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'timezone': instance.timezone,
  'language': instance.language,
  'currency': instance.currency,
  'dateFormat': instance.dateFormat,
  'timeFormat': instance.timeFormat,
  'enableNotifications': instance.enableNotifications,
  'enableAuditLogging': instance.enableAuditLogging,
  'enableDataEncryption': instance.enableDataEncryption,
  'allowedFileTypes': instance.allowedFileTypes,
  'maxFileSizeMB': instance.maxFileSizeMB,
  'sessionTimeoutMinutes': instance.sessionTimeoutMinutes,
  'enableTwoFactorAuth': instance.enableTwoFactorAuth,
  'ipWhitelist': instance.ipWhitelist,
  'customSettings': instance.customSettings,
};

OrganizationMember _$OrganizationMemberFromJson(Map<String, dynamic> json) =>
    OrganizationMember(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: $enumDecode(_$MemberRoleEnumMap, json['role']),
      status: $enumDecode(_$MemberStatusEnumMap, json['status']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      department: json['department'] as String?,
      title: json['title'] as String?,
      phone: json['phone'] as String?,
      isPrimaryContact: json['isPrimaryContact'] as bool,
    );

Map<String, dynamic> _$OrganizationMemberToJson(OrganizationMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'userId': instance.userId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'status': _$MemberStatusEnumMap[instance.status]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'permissions': instance.permissions,
      'department': instance.department,
      'title': instance.title,
      'phone': instance.phone,
      'isPrimaryContact': instance.isPrimaryContact,
    };

const _$MemberRoleEnumMap = {
  MemberRole.owner: 'owner',
  MemberRole.admin: 'admin',
  MemberRole.manager: 'manager',
  MemberRole.member: 'member',
  MemberRole.viewer: 'viewer',
  MemberRole.guest: 'guest',
};

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.inactive: 'inactive',
  MemberStatus.suspended: 'suspended',
  MemberStatus.pending: 'pending',
};

OrganizationInvitation _$OrganizationInvitationFromJson(
  Map<String, dynamic> json,
) => OrganizationInvitation(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  email: json['email'] as String,
  invitedBy: json['invitedBy'] as String,
  role: $enumDecode(_$MemberRoleEnumMap, json['role']),
  status: $enumDecode(_$InvitationStatusEnumMap, json['status']),
  invitedAt: DateTime.parse(json['invitedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  acceptedAt: json['acceptedAt'] == null
      ? null
      : DateTime.parse(json['acceptedAt'] as String),
  token: json['token'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$OrganizationInvitationToJson(
  OrganizationInvitation instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'email': instance.email,
  'invitedBy': instance.invitedBy,
  'role': _$MemberRoleEnumMap[instance.role]!,
  'status': _$InvitationStatusEnumMap[instance.status]!,
  'invitedAt': instance.invitedAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'acceptedAt': instance.acceptedAt?.toIso8601String(),
  'token': instance.token,
  'message': instance.message,
};

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.accepted: 'accepted',
  InvitationStatus.declined: 'declined',
  InvitationStatus.expired: 'expired',
  InvitationStatus.cancelled: 'cancelled',
};

OrganizationDepartment _$OrganizationDepartmentFromJson(
  Map<String, dynamic> json,
) => OrganizationDepartment(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  managerId: json['managerId'] as String?,
  parentDepartmentId: json['parentDepartmentId'] as String?,
  memberIds: (json['memberIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$DepartmentStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrganizationDepartmentToJson(
  OrganizationDepartment instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'name': instance.name,
  'description': instance.description,
  'managerId': instance.managerId,
  'parentDepartmentId': instance.parentDepartmentId,
  'memberIds': instance.memberIds,
  'status': _$DepartmentStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$DepartmentStatusEnumMap = {
  DepartmentStatus.active: 'active',
  DepartmentStatus.inactive: 'inactive',
  DepartmentStatus.archived: 'archived',
};

OrganizationIntegration _$OrganizationIntegrationFromJson(
  Map<String, dynamic> json,
) => OrganizationIntegration(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$IntegrationTypeEnumMap, json['type']),
  status: $enumDecode(_$IntegrationStatusEnumMap, json['status']),
  config: json['config'] as Map<String, dynamic>,
  connectedAt: DateTime.parse(json['connectedAt'] as String),
  lastSyncAt: json['lastSyncAt'] == null
      ? null
      : DateTime.parse(json['lastSyncAt'] as String),
  lastError: json['lastError'] as String?,
  isActive: json['isActive'] as bool,
  scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$OrganizationIntegrationToJson(
  OrganizationIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'name': instance.name,
  'type': _$IntegrationTypeEnumMap[instance.type]!,
  'status': _$IntegrationStatusEnumMap[instance.status]!,
  'config': instance.config,
  'connectedAt': instance.connectedAt.toIso8601String(),
  'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
  'lastError': instance.lastError,
  'isActive': instance.isActive,
  'scopes': instance.scopes,
  'metadata': instance.metadata,
};

const _$IntegrationTypeEnumMap = {
  IntegrationType.emr: 'emr',
  IntegrationType.billing: 'billing',
  IntegrationType.calendar: 'calendar',
  IntegrationType.communication: 'communication',
  IntegrationType.analytics: 'analytics',
  IntegrationType.security: 'security',
  IntegrationType.compliance: 'compliance',
  IntegrationType.other: 'other',
};

const _$IntegrationStatusEnumMap = {
  IntegrationStatus.connected: 'connected',
  IntegrationStatus.disconnected: 'disconnected',
  IntegrationStatus.error: 'error',
  IntegrationStatus.pending: 'pending',
  IntegrationStatus.configuring: 'configuring',
};

OrganizationAuditLog _$OrganizationAuditLogFromJson(
  Map<String, dynamic> json,
) => OrganizationAuditLog(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  userId: json['userId'] as String,
  action: json['action'] as String,
  resource: json['resource'] as String,
  details: json['details'] as String,
  ipAddress: json['ipAddress'] as String,
  userAgent: json['userAgent'] as String,
  level: $enumDecode(_$AuditLogLevelEnumMap, json['level']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$OrganizationAuditLogToJson(
  OrganizationAuditLog instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'userId': instance.userId,
  'action': instance.action,
  'resource': instance.resource,
  'details': instance.details,
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
  'level': _$AuditLogLevelEnumMap[instance.level]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'metadata': instance.metadata,
};

const _$AuditLogLevelEnumMap = {
  AuditLogLevel.info: 'info',
  AuditLogLevel.warning: 'warning',
  AuditLogLevel.error: 'error',
  AuditLogLevel.critical: 'critical',
};
