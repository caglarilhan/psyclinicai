class ExternalIntegration {
  final String id;
  final String name;
  final String description;
  final IntegrationType type;
  final IntegrationStatus status;
  final String? apiEndpoint;
  final String? apiKey;
  final Map<String, dynamic> configuration;
  final List<String> supportedFeatures;
  final DateTime createdAt;
  final DateTime? lastSyncAt;
  final String? lastSyncStatus;
  final Map<String, dynamic> metadata;

  const ExternalIntegration({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.status = IntegrationStatus.inactive,
    this.apiEndpoint,
    this.apiKey,
    this.configuration = const {},
    this.supportedFeatures = const [],
    required this.createdAt,
    this.lastSyncAt,
    this.lastSyncStatus,
    this.metadata = const {},
  });

  factory ExternalIntegration.fromJson(Map<String, dynamic> json) {
    return ExternalIntegration(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: IntegrationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IntegrationType.api,
      ),
      status: IntegrationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IntegrationStatus.inactive,
      ),
      apiEndpoint: json['apiEndpoint'] as String?,
      apiKey: json['apiKey'] as String?,
      configuration: Map<String, dynamic>.from(json['configuration'] as Map? ?? {}),
      supportedFeatures: List<String>.from(json['supportedFeatures'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSyncAt: json['lastSyncAt'] != null 
          ? DateTime.parse(json['lastSyncAt'] as String) 
          : null,
      lastSyncStatus: json['lastSyncStatus'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'apiEndpoint': apiEndpoint,
      'apiKey': apiKey,
      'configuration': configuration,
      'supportedFeatures': supportedFeatures,
      'createdAt': createdAt.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'lastSyncStatus': lastSyncStatus,
      'metadata': metadata,
    };
  }

  // Check if integration is active
  bool get isActive {
    return status == IntegrationStatus.active;
  }

  // Check if integration needs sync
  bool get needsSync {
    if (lastSyncAt == null) return true;
    final hoursSinceLastSync = DateTime.now().difference(lastSyncAt!).inHours;
    return hoursSinceLastSync > 24; // Sync every 24 hours
  }
}

class DataSync {
  final String id;
  final String integrationId;
  final SyncType type;
  final SyncStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalRecords;
  final int syncedRecords;
  final int failedRecords;
  final String? errorMessage;
  final Map<String, dynamic> syncData;
  final Map<String, dynamic> metadata;

  const DataSync({
    required this.id,
    required this.integrationId,
    required this.type,
    this.status = SyncStatus.pending,
    required this.startedAt,
    this.completedAt,
    this.totalRecords = 0,
    this.syncedRecords = 0,
    this.failedRecords = 0,
    this.errorMessage,
    this.syncData = const {},
    this.metadata = const {},
  });

  factory DataSync.fromJson(Map<String, dynamic> json) {
    return DataSync(
      id: json['id'] as String,
      integrationId: json['integrationId'] as String,
      type: SyncType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncType.full,
      ),
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      totalRecords: json['totalRecords'] as int? ?? 0,
      syncedRecords: json['syncedRecords'] as int? ?? 0,
      failedRecords: json['failedRecords'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      syncData: Map<String, dynamic>.from(json['syncData'] as Map? ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'integrationId': integrationId,
      'type': type.name,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalRecords': totalRecords,
      'syncedRecords': syncedRecords,
      'failedRecords': failedRecords,
      'errorMessage': errorMessage,
      'syncData': syncData,
      'metadata': metadata,
    };
  }

  // Calculate sync progress
  double get progress {
    if (totalRecords == 0) return 0.0;
    return (syncedRecords + failedRecords) / totalRecords;
  }

  // Check if sync is completed
  bool get isCompleted {
    return status == SyncStatus.completed;
  }

  // Check if sync failed
  bool get isFailed {
    return status == SyncStatus.failed;
  }
}

class APICredential {
  final String id;
  final String integrationId;
  final String name;
  final CredentialType type;
  final String? apiKey;
  final String? secretKey;
  final String? username;
  final String? password;
  final String? token;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const APICredential({
    required this.id,
    required this.integrationId,
    required this.name,
    required this.type,
    this.apiKey,
    this.secretKey,
    this.username,
    this.password,
    this.token,
    this.expiresAt,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory APICredential.fromJson(Map<String, dynamic> json) {
    return APICredential(
      id: json['id'] as String,
      integrationId: json['integrationId'] as String,
      name: json['name'] as String,
      type: CredentialType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CredentialType.apiKey,
      ),
      apiKey: json['apiKey'] as String?,
      secretKey: json['secretKey'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'integrationId': integrationId,
      'name': name,
      'type': type.name,
      'apiKey': apiKey,
      'secretKey': secretKey,
      'username': username,
      'password': password,
      'token': token,
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Check if credential is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  // Check if credential is valid
  bool get isValid {
    return isActive && !isExpired;
  }
}

class IntegrationLog {
  final String id;
  final String integrationId;
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? errorCode;
  final String? stackTrace;
  final Map<String, dynamic> context;
  final String? userId;
  final String? sessionId;

  const IntegrationLog({
    required this.id,
    required this.integrationId,
    required this.level,
    required this.message,
    required this.timestamp,
    this.errorCode,
    this.stackTrace,
    this.context = const {},
    this.userId,
    this.sessionId,
  });

  factory IntegrationLog.fromJson(Map<String, dynamic> json) {
    return IntegrationLog(
      id: json['id'] as String,
      integrationId: json['integrationId'] as String,
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorCode: json['errorCode'] as String?,
      stackTrace: json['stackTrace'] as String?,
      context: Map<String, dynamic>.from(json['context'] as Map? ?? {}),
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'integrationId': integrationId,
      'level': level.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'errorCode': errorCode,
      'stackTrace': stackTrace,
      'context': context,
      'userId': userId,
      'sessionId': sessionId,
    };
  }
}

enum IntegrationType {
  api,
  webhook,
  file,
  database,
  email,
  sms,
  voice,
  video,
  other,
}

enum IntegrationStatus {
  active,
  inactive,
  error,
  maintenance,
  deprecated,
}

enum SyncType {
  full,
  incremental,
  delta,
  manual,
}

enum SyncStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

enum CredentialType {
  apiKey,
  oauth,
  basic,
  bearer,
  custom,
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}
