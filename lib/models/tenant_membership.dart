/// One clinician's membership in a tenant (clinic). A user can
/// belong to several tenants — locum doctors, supervisors covering
/// multiple practices, group operators. The AppBar tenant switcher
/// pivots on this list.
enum TenantRole {
  owner('owner', 'Owner'),
  admin('admin', 'Admin'),
  clinician('clinician', 'Clinician'),
  trainee('trainee', 'Trainee');

  const TenantRole(this.id, this.label);
  final String id;
  final String label;

  bool get canManageBilling =>
      this == TenantRole.owner || this == TenantRole.admin;
  bool get canSignNotes => this != TenantRole.trainee;

  static TenantRole fromId(String id) =>
      values.firstWhere((r) => r.id == id, orElse: () => TenantRole.clinician);
}

class TenantMembership {
  factory TenantMembership.fromJson(Map<String, dynamic> json) {
    return TenantMembership(
      tenantId: json['tenant_id'] as String,
      tenantName: json['tenant_name'] as String,
      uid: json['uid'] as String,
      role: TenantRole.fromId(json['role'] as String? ?? 'clinician'),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
  const TenantMembership({
    required this.tenantId,
    required this.tenantName,
    required this.uid,
    required this.role,
    required this.joinedAt,
    this.isDefault = false,
  });

  final String tenantId;
  final String tenantName;
  final String uid;
  final TenantRole role;
  final DateTime joinedAt;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
    'tenant_id': tenantId,
    'tenant_name': tenantName,
    'uid': uid,
    'role': role.id,
    'joined_at': joinedAt.toUtc().toIso8601String(),
    'is_default': isDefault,
  };
}
