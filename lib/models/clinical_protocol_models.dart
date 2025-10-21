class ClinicalProtocol {
  final String id;
  final String title;
  final String description;
  final ProtocolCategory category;
  final ProtocolType type;
  final String version;
  final String content; // HTML/Markdown content
  final List<String> tags;
  final List<String> applicableDisorders;
  final List<String> targetAudience; // Psikolog, Psikiyatrist, Hemşire, vb.
  final String? evidenceLevel; // A, B, C, D
  final String? source; // Kaynak literatür
  final List<String> prerequisites;
  final List<String> contraindications;
  final String? estimatedDuration;
  final String? requiredResources;
  final String? createdBy;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewDate;
  final ProtocolStatus status;
  final bool isPublic;
  final List<String> sharedWith; // Ekip üyeleri
  final Map<String, dynamic> metadata;

  const ClinicalProtocol({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.version,
    required this.content,
    this.tags = const [],
    this.applicableDisorders = const [],
    this.targetAudience = const [],
    this.evidenceLevel,
    this.source,
    this.prerequisites = const [],
    this.contraindications = const [],
    this.estimatedDuration,
    this.requiredResources,
    this.createdBy,
    this.reviewedBy,
    required this.createdAt,
    this.updatedAt,
    this.reviewDate,
    this.status = ProtocolStatus.draft,
    this.isPublic = false,
    this.sharedWith = const [],
    this.metadata = const {},
  });

  factory ClinicalProtocol.fromJson(Map<String, dynamic> json) {
    return ClinicalProtocol(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ProtocolCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProtocolCategory.therapy,
      ),
      type: ProtocolType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProtocolType.standard,
      ),
      version: json['version'] as String,
      content: json['content'] as String,
      tags: List<String>.from(json['tags'] as List? ?? []),
      applicableDisorders: List<String>.from(json['applicableDisorders'] as List? ?? []),
      targetAudience: List<String>.from(json['targetAudience'] as List? ?? []),
      evidenceLevel: json['evidenceLevel'] as String?,
      source: json['source'] as String?,
      prerequisites: List<String>.from(json['prerequisites'] as List? ?? []),
      contraindications: List<String>.from(json['contraindications'] as List? ?? []),
      estimatedDuration: json['estimatedDuration'] as String?,
      requiredResources: json['requiredResources'] as String?,
      createdBy: json['createdBy'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      reviewDate: json['reviewDate'] != null 
          ? DateTime.parse(json['reviewDate'] as String) 
          : null,
      status: ProtocolStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProtocolStatus.draft,
      ),
      isPublic: json['isPublic'] as bool? ?? false,
      sharedWith: List<String>.from(json['sharedWith'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'type': type.name,
      'version': version,
      'content': content,
      'tags': tags,
      'applicableDisorders': applicableDisorders,
      'targetAudience': targetAudience,
      'evidenceLevel': evidenceLevel,
      'source': source,
      'prerequisites': prerequisites,
      'contraindications': contraindications,
      'estimatedDuration': estimatedDuration,
      'requiredResources': requiredResources,
      'createdBy': createdBy,
      'reviewedBy': reviewedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
      'status': status.name,
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'metadata': metadata,
    };
  }

  // Check if protocol needs review
  bool get needsReview {
    if (reviewDate == null) return true;
    return reviewDate!.isBefore(DateTime.now().subtract(const Duration(days: 365)));
  }

  // Check if protocol is accessible by user
  bool isAccessibleBy(String userId) {
    return isPublic || 
           createdBy == userId || 
           sharedWith.contains(userId);
  }
}

class ProtocolTemplate {
  final String id;
  final String name;
  final String description;
  final ProtocolCategory category;
  final String templateContent;
  final List<String> requiredFields;
  final List<String> optionalFields;
  final String? instructions;
  final String createdBy;
  final DateTime createdAt;
  final bool isActive;

  const ProtocolTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.templateContent,
    required this.requiredFields,
    this.optionalFields = const [],
    this.instructions,
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
  });

  factory ProtocolTemplate.fromJson(Map<String, dynamic> json) {
    return ProtocolTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ProtocolCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProtocolCategory.therapy,
      ),
      templateContent: json['templateContent'] as String,
      requiredFields: List<String>.from(json['requiredFields'] as List),
      optionalFields: List<String>.from(json['optionalFields'] as List? ?? []),
      instructions: json['instructions'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'templateContent': templateContent,
      'requiredFields': requiredFields,
      'optionalFields': optionalFields,
      'instructions': instructions,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class ProtocolUsage {
  final String id;
  final String protocolId;
  final String userId;
  final String patientId;
  final DateTime usedAt;
  final String? notes;
  final Map<String, dynamic> customizations;
  final UsageOutcome outcome;
  final String? feedback;

  const ProtocolUsage({
    required this.id,
    required this.protocolId,
    required this.userId,
    required this.patientId,
    required this.usedAt,
    this.notes,
    this.customizations = const {},
    this.outcome = UsageOutcome.successful,
    this.feedback,
  });

  factory ProtocolUsage.fromJson(Map<String, dynamic> json) {
    return ProtocolUsage(
      id: json['id'] as String,
      protocolId: json['protocolId'] as String,
      userId: json['userId'] as String,
      patientId: json['patientId'] as String,
      usedAt: DateTime.parse(json['usedAt'] as String),
      notes: json['notes'] as String?,
      customizations: Map<String, dynamic>.from(json['customizations'] as Map? ?? {}),
      outcome: UsageOutcome.values.firstWhere(
        (e) => e.name == json['outcome'],
        orElse: () => UsageOutcome.successful,
      ),
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'protocolId': protocolId,
      'userId': userId,
      'patientId': patientId,
      'usedAt': usedAt.toIso8601String(),
      'notes': notes,
      'customizations': customizations,
      'outcome': outcome.name,
      'feedback': feedback,
    };
  }
}

enum ProtocolCategory {
  therapy,
  assessment,
  crisis,
  medication,
  psychoeducation,
  group,
  family,
  research,
  administrative,
}

enum ProtocolType {
  standard,
  emergency,
  research,
  training,
  custom,
}

enum ProtocolStatus {
  draft,
  review,
  approved,
  active,
  archived,
  deprecated,
}

enum UsageOutcome {
  successful,
  partial,
  unsuccessful,
  modified,
}
