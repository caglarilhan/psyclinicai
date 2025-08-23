/// Biometric authentication models and enums
enum BiometricStatus {
  unknown,
  available,
  notAvailable,
  notSupported,
  enabled,
  disabled,
  error,
}

enum BiometricType {
  fingerprint,
  face,
  iris,
  voice,
}

enum BiometricEventType {
  enrolled,
  removed,
  enabled,
  disabled,
  authenticated,
  failed,
  locked,
  unlocked,
}

enum BiometricAlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum BiometricAlertStatus {
  active,
  acknowledged,
  resolved,
  dismissed,
}

/// Biometric profile data
class BiometricProfile {
  final String id;
  final String userId;
  final BiometricType type;
  final String name;
  final DateTime enrolledAt;
  final DateTime lastUsed;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const BiometricProfile({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.enrolledAt,
    required this.lastUsed,
    required this.isActive,
    this.metadata = const {},
  });

  BiometricProfile copyWith({
    String? id,
    String? userId,
    BiometricType? type,
    String? name,
    DateTime? enrolledAt,
    DateTime? lastUsed,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return BiometricProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'name': name,
      'enrolledAt': enrolledAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory BiometricProfile.fromJson(Map<String, dynamic> json) {
    return BiometricProfile(
      id: json['id'],
      userId: json['userId'],
      type: BiometricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BiometricType.fingerprint,
      ),
      name: json['name'],
      enrolledAt: DateTime.parse(json['enrolledAt']),
      lastUsed: DateTime.parse(json['lastUsed']),
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'] ?? {},
    );
  }
}

/// Biometric authentication event
class BiometricEvent {
  final String id;
  final String userId;
  final BiometricEventType eventType;
  final BiometricType biometricType;
  final DateTime timestamp;
  final String? deviceId;
  final Map<String, dynamic> metadata;

  const BiometricEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.biometricType,
    required this.timestamp,
    this.deviceId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType.name,
      'biometricType': biometricType.name,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'metadata': metadata,
    };
  }

  factory BiometricEvent.fromJson(Map<String, dynamic> json) {
    return BiometricEvent(
      id: json['id'],
      userId: json['userId'],
      eventType: BiometricEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => BiometricEventType.authenticated,
      ),
      biometricType: BiometricType.values.firstWhere(
        (e) => e.name == json['biometricType'],
        orElse: () => BiometricType.fingerprint,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['deviceId'],
      metadata: json['metadata'] ?? {},
    );
  }
}

/// Biometric security alert
class BiometricAlert {
  final String id;
  final String userId;
  final BiometricAlertSeverity severity;
  final BiometricAlertStatus status;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  const BiometricAlert({
    required this.id,
    required this.userId,
    required this.severity,
    required this.status,
    required this.title,
    required this.message,
    required this.createdAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'severity': severity.name,
      'status': status.name,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory BiometricAlert.fromJson(Map<String, dynamic> json) {
    return BiometricAlert(
      id: json['id'],
      userId: json['userId'],
      severity: BiometricAlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => BiometricAlertSeverity.medium,
      ),
      status: BiometricAlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BiometricAlertStatus.active,
      ),
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      acknowledgedAt: json['acknowledgedAt'] != null 
          ? DateTime.parse(json['acknowledgedAt'])
          : null,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'])
          : null,
      metadata: json['metadata'] ?? {},
    );
  }
}
