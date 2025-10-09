class Organization {
  final String id;
  final String name;
  final DateTime createdAt;

  Organization({required this.id, required this.name, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json['id'],
        name: json['name'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

enum UserRole { admin, therapist, assistant, billing, auditor }

class User {
  final String id;
  final String email;
  final String fullName;
  final List<UserRole> roles;
  final String organizationId;
  final bool is2FAEnabled;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.organizationId,
    this.is2FAEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'roles': roles.map((e) => e.name).toList(),
        'organizationId': organizationId,
        'is2FAEnabled': is2FAEnabled,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        fullName: json['fullName'],
        roles: (json['roles'] as List).map((e) => UserRole.values.firstWhere((r) => r.name == e)).toList(),
        organizationId: json['organizationId'],
        is2FAEnabled: json['is2FAEnabled'] ?? true,
      );
}

class TwoFactorChallenge {
  final String userId;
  final String code; // 6 haneli
  final DateTime expiresAt;

  TwoFactorChallenge({required this.userId, required this.code, required this.expiresAt});
}


