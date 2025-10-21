class DigitalTherapyMaterial {
  final String id;
  final String title;
  final String description;
  final MaterialType type;
  final String content;
  final String? filePath;
  final String? thumbnailPath;
  final List<String> tags;
  final List<String> targetDisorders;
  final List<String> targetAudience;
  final DifficultyLevel difficulty;
  final Duration? estimatedDuration;
  final String? instructions;
  final String? prerequisites;
  final String? learningObjectives;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isPublic;
  final List<String> sharedWith;
  final Map<String, dynamic> metadata;

  const DigitalTherapyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    this.filePath,
    this.thumbnailPath,
    this.tags = const [],
    this.targetDisorders = const [],
    this.targetAudience = const [],
    this.difficulty = DifficultyLevel.beginner,
    this.estimatedDuration,
    this.instructions,
    this.prerequisites,
    this.learningObjectives,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isPublic = false,
    this.sharedWith = const [],
    this.metadata = const {},
  });

  factory DigitalTherapyMaterial.fromJson(Map<String, dynamic> json) {
    return DigitalTherapyMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: MaterialType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MaterialType.pdf,
      ),
      content: json['content'] as String,
      filePath: json['filePath'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      targetDisorders: List<String>.from(json['targetDisorders'] as List? ?? []),
      targetAudience: List<String>.from(json['targetAudience'] as List? ?? []),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      estimatedDuration: json['estimatedDuration'] != null 
          ? Duration(minutes: json['estimatedDuration'] as int) 
          : null,
      instructions: json['instructions'] as String?,
      prerequisites: json['prerequisites'] as String?,
      learningObjectives: json['learningObjectives'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
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
      'type': type.name,
      'content': content,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'tags': tags,
      'targetDisorders': targetDisorders,
      'targetAudience': targetAudience,
      'difficulty': difficulty.name,
      'estimatedDuration': estimatedDuration?.inMinutes,
      'instructions': instructions,
      'prerequisites': prerequisites,
      'learningObjectives': learningObjectives,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'metadata': metadata,
    };
  }

  // Check if material is accessible by user
  bool isAccessibleBy(String userId) {
    return isPublic || 
           createdBy == userId || 
           sharedWith.contains(userId);
  }
}

class MaterialAssignment {
  final String id;
  final String materialId;
  final String patientId;
  final String assignedBy;
  final DateTime assignedAt;
  final DateTime? dueDate;
  final AssignmentStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? progressPercentage;
  final String? notes;
  final String? patientFeedback;
  final Map<String, dynamic> metadata;

  const MaterialAssignment({
    required this.id,
    required this.materialId,
    required this.patientId,
    required this.assignedBy,
    required this.assignedAt,
    this.dueDate,
    this.status = AssignmentStatus.assigned,
    this.startedAt,
    this.completedAt,
    this.progressPercentage,
    this.notes,
    this.patientFeedback,
    this.metadata = const {},
  });

  factory MaterialAssignment.fromJson(Map<String, dynamic> json) {
    return MaterialAssignment(
      id: json['id'] as String,
      materialId: json['materialId'] as String,
      patientId: json['patientId'] as String,
      assignedBy: json['assignedBy'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'] as String) 
          : null,
      status: AssignmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssignmentStatus.assigned,
      ),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      patientFeedback: json['patientFeedback'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'patientId': patientId,
      'assignedBy': assignedBy,
      'assignedAt': assignedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progressPercentage': progressPercentage,
      'notes': notes,
      'patientFeedback': patientFeedback,
      'metadata': metadata,
    };
  }

  // Check if assignment is overdue
  bool get isOverdue {
    if (dueDate == null || status == AssignmentStatus.completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  // Check if assignment is urgent
  bool get isUrgent {
    if (dueDate == null) return false;
    final daysUntilDue = dueDate!.difference(DateTime.now()).inDays;
    return daysUntilDue <= 1 && status != AssignmentStatus.completed;
  }
}

class MaterialProgress {
  final String id;
  final String assignmentId;
  final String patientId;
  final DateTime timestamp;
  final double progressPercentage;
  final String? notes;
  final Map<String, dynamic> interactionData;
  final Map<String, dynamic> metadata;

  const MaterialProgress({
    required this.id,
    required this.assignmentId,
    required this.patientId,
    required this.timestamp,
    required this.progressPercentage,
    this.notes,
    this.interactionData = const {},
    this.metadata = const {},
  });

  factory MaterialProgress.fromJson(Map<String, dynamic> json) {
    return MaterialProgress(
      id: json['id'] as String,
      assignmentId: json['assignmentId'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      notes: json['notes'] as String?,
      interactionData: Map<String, dynamic>.from(json['interactionData'] as Map? ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'patientId': patientId,
      'timestamp': timestamp.toIso8601String(),
      'progressPercentage': progressPercentage,
      'notes': notes,
      'interactionData': interactionData,
      'metadata': metadata,
    };
  }
}

class MaterialCollection {
  final String id;
  final String name;
  final String description;
  final List<String> materialIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isPublic;
  final List<String> sharedWith;
  final Map<String, dynamic> metadata;

  const MaterialCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.materialIds,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isPublic = false,
    this.sharedWith = const [],
    this.metadata = const {},
  });

  factory MaterialCollection.fromJson(Map<String, dynamic> json) {
    return MaterialCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      materialIds: List<String>.from(json['materialIds'] as List),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      isPublic: json['isPublic'] as bool? ?? false,
      sharedWith: List<String>.from(json['sharedWith'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'materialIds': materialIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'metadata': metadata,
    };
  }

  // Check if collection is accessible by user
  bool isAccessibleBy(String userId) {
    return isPublic || 
           createdBy == userId || 
           sharedWith.contains(userId);
  }
}

enum MaterialType {
  pdf,
  video,
  audio,
  interactive,
  worksheet,
  exercise,
  assessment,
  other,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

enum AssignmentStatus {
  assigned,
  started,
  inProgress,
  completed,
  overdue,
  cancelled,
}
