class SupervisionApproval {
  final String id;
  final String caseId;
  final String superviseeId;
  final String supervisorId;
  final ApprovalType type;
  final ApprovalStatus status;
  final String? caseSummary;
  final String? anonymizedContent;
  final List<String> sensitiveDataFields;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final String? rejectionReason;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime? expiresAt;
  final String? approvedBy;

  const SupervisionApproval({
    required this.id,
    required this.caseId,
    required this.superviseeId,
    required this.supervisorId,
    required this.type,
    this.status = ApprovalStatus.pending,
    this.caseSummary,
    this.anonymizedContent,
    this.sensitiveDataFields = const [],
    required this.requestedAt,
    this.reviewedAt,
    this.reviewNotes,
    this.rejectionReason,
    this.attachments = const [],
    this.metadata = const {},
    this.expiresAt,
    this.approvedBy,
  });

  factory SupervisionApproval.fromJson(Map<String, dynamic> json) {
    return SupervisionApproval(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      superviseeId: json['superviseeId'] as String,
      supervisorId: json['supervisorId'] as String,
      type: ApprovalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ApprovalType.caseReview,
      ),
      status: ApprovalType.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApprovalStatus.pending,
      ),
      caseSummary: json['caseSummary'] as String?,
      anonymizedContent: json['anonymizedContent'] as String?,
      sensitiveDataFields: List<String>.from(json['sensitiveDataFields'] as List? ?? []),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      reviewedAt: json['reviewedAt'] != null 
          ? DateTime.parse(json['reviewedAt'] as String) 
          : null,
      reviewNotes: json['reviewNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      approvedBy: json['approvedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'superviseeId': superviseeId,
      'supervisorId': supervisorId,
      'type': type.name,
      'status': status.name,
      'caseSummary': caseSummary,
      'anonymizedContent': anonymizedContent,
      'sensitiveDataFields': sensitiveDataFields,
      'requestedAt': requestedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
      'rejectionReason': rejectionReason,
      'attachments': attachments,
      'metadata': metadata,
      'expiresAt': expiresAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  // Check if approval is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  // Check if approval is urgent (expires within 24 hours)
  bool get isUrgent {
    if (expiresAt == null) return false;
    final twentyFourHoursFromNow = DateTime.now().add(const Duration(hours: 24));
    return expiresAt!.isBefore(twentyFourHoursFromNow);
  }
}

class DataAnonymization {
  final String id;
  final String originalContent;
  final String anonymizedContent;
  final List<AnonymizationRule> appliedRules;
  final DateTime processedAt;
  final String processedBy;
  final AnonymizationLevel level;
  final Map<String, String> replacements;

  const DataAnonymization({
    required this.id,
    required this.originalContent,
    required this.anonymizedContent,
    required this.appliedRules,
    required this.processedAt,
    required this.processedBy,
    required this.level,
    this.replacements = const {},
  });

  factory DataAnonymization.fromJson(Map<String, dynamic> json) {
    return DataAnonymization(
      id: json['id'] as String,
      originalContent: json['originalContent'] as String,
      anonymizedContent: json['anonymizedContent'] as String,
      appliedRules: (json['appliedRules'] as List<dynamic>)
          .map((rule) => AnonymizationRule.fromJson(rule as Map<String, dynamic>))
          .toList(),
      processedAt: DateTime.parse(json['processedAt'] as String),
      processedBy: json['processedBy'] as String,
      level: AnonymizationLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => AnonymizationLevel.medium,
      ),
      replacements: Map<String, String>.from(json['replacements'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalContent': originalContent,
      'anonymizedContent': anonymizedContent,
      'appliedRules': appliedRules.map((rule) => rule.toJson()).toList(),
      'processedAt': processedAt.toIso8601String(),
      'processedBy': processedBy,
      'level': level.name,
      'replacements': replacements,
    };
  }
}

class AnonymizationRule {
  final String id;
  final String name;
  final String description;
  final String pattern;
  final String replacement;
  final AnonymizationType type;
  final bool isActive;
  final int priority;

  const AnonymizationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.pattern,
    required this.replacement,
    required this.type,
    this.isActive = true,
    this.priority = 0,
  });

  factory AnonymizationRule.fromJson(Map<String, dynamic> json) {
    return AnonymizationRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pattern: json['pattern'] as String,
      replacement: json['replacement'] as String,
      type: AnonymizationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnonymizationType.name,
      ),
      isActive: json['isActive'] as bool? ?? true,
      priority: json['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pattern': pattern,
      'replacement': replacement,
      'type': type.name,
      'isActive': isActive,
      'priority': priority,
    };
  }
}

class ConsentRecord {
  final String id;
  final String patientId;
  final String caseId;
  final ConsentType type;
  final String description;
  final DateTime givenAt;
  final String givenBy;
  final DateTime? expiresAt;
  final ConsentStatus status;
  final String? notes;
  final List<String> purposes;
  final List<String> dataTypes;
  final bool isRevocable;
  final DateTime? revokedAt;
  final String? revokedBy;

  const ConsentRecord({
    required this.id,
    required this.patientId,
    required this.caseId,
    required this.type,
    required this.description,
    required this.givenAt,
    required this.givenBy,
    this.expiresAt,
    this.status = ConsentStatus.active,
    this.notes,
    this.purposes = const [],
    this.dataTypes = const [],
    this.isRevocable = true,
    this.revokedAt,
    this.revokedBy,
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      caseId: json['caseId'] as String,
      type: ConsentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConsentType.treatment,
      ),
      description: json['description'] as String,
      givenAt: DateTime.parse(json['givenAt'] as String),
      givenBy: json['givenBy'] as String,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      status: ConsentType.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsentStatus.active,
      ),
      notes: json['notes'] as String?,
      purposes: List<String>.from(json['purposes'] as List? ?? []),
      dataTypes: List<String>.from(json['dataTypes'] as List? ?? []),
      isRevocable: json['isRevocable'] as bool? ?? true,
      revokedAt: json['revokedAt'] != null 
          ? DateTime.parse(json['revokedAt'] as String) 
          : null,
      revokedBy: json['revokedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'caseId': caseId,
      'type': type.name,
      'description': description,
      'givenAt': givenAt.toIso8601String(),
      'givenBy': givenBy,
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'purposes': purposes,
      'dataTypes': dataTypes,
      'isRevocable': isRevocable,
      'revokedAt': revokedAt?.toIso8601String(),
      'revokedBy': revokedBy,
    };
  }

  // Check if consent is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  // Check if consent is valid
  bool get isValid {
    return status == ConsentStatus.active && !isExpired;
  }
}

enum ApprovalType {
  caseReview,
  supervision,
  research,
  training,
  consultation,
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
  expired,
  cancelled,
}

enum AnonymizationLevel {
  low,
  medium,
  high,
  maximum,
}

enum AnonymizationType {
  name,
  address,
  phone,
  email,
  idNumber,
  date,
  location,
  custom,
}

enum ConsentType {
  treatment,
  supervision,
  research,
  dataSharing,
  emergency,
}

enum ConsentStatus {
  active,
  expired,
  revoked,
  withdrawn,
}
