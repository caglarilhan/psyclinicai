class Organization {
  Organization({required this.id, required this.name, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
  final String id;
  final String name;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// `patient` is the only non-clinician role. It scopes to the patient
/// portal surface (`/portal`) and must never grant access to any
/// clinician dashboard or to another patient's record.
enum UserRole { admin, therapist, assistant, billing, auditor, patient }

class User {
  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.organizationId,
    this.is2FAEnabled = true,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    roles: (json['roles'] as List)
        .map((e) => UserRole.values.firstWhere((r) => r.name == e))
        .toList(),
    organizationId: json['organizationId'] as String,
    is2FAEnabled: json['is2FAEnabled'] as bool? ?? true,
  );
  final String id;
  final String email;
  final String fullName;
  final List<UserRole> roles;
  final String organizationId;
  final bool is2FAEnabled;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'roles': roles.map((e) => e.name).toList(),
    'organizationId': organizationId,
    'is2FAEnabled': is2FAEnabled,
  };
}

class TwoFactorChallenge {
  TwoFactorChallenge({
    required this.userId,
    required this.code,
    required this.expiresAt,
  });
  final String userId;
  final String code; // 6 haneli
  final DateTime expiresAt;
}
