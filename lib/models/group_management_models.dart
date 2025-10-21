class GroupSession {
  final String id;
  final String title;
  final String description;
  final GroupType type;
  final String facilitatorId;
  final List<String> participantIds;
  final DateTime scheduledAt;
  final Duration duration;
  final String location;
  final SessionStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? notes;
  final List<String> objectives;
  final List<String> materials;
  final Map<String, dynamic> metadata;

  const GroupSession({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.facilitatorId,
    required this.participantIds,
    required this.scheduledAt,
    required this.duration,
    required this.location,
    this.status = SessionStatus.scheduled,
    this.startedAt,
    this.endedAt,
    this.notes,
    this.objectives = const [],
    this.materials = const [],
    this.metadata = const {},
  });

  factory GroupSession.fromJson(Map<String, dynamic> json) {
    return GroupSession(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: GroupType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GroupType.therapy,
      ),
      facilitatorId: json['facilitatorId'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      duration: Duration(minutes: json['duration'] as int),
      location: json['location'] as String,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String) 
          : null,
      notes: json['notes'] as String?,
      objectives: List<String>.from(json['objectives'] as List? ?? []),
      materials: List<String>.from(json['materials'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'facilitatorId': facilitatorId,
      'participantIds': participantIds,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration.inMinutes,
      'location': location,
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'notes': notes,
      'objectives': objectives,
      'materials': materials,
      'metadata': metadata,
    };
  }

  // Check if session is active
  bool get isActive {
    return status == SessionStatus.active;
  }

  // Check if session is completed
  bool get isCompleted {
    return status == SessionStatus.completed;
  }

  // Check if session is overdue
  bool get isOverdue {
    return status == SessionStatus.scheduled && 
           scheduledAt.isBefore(DateTime.now());
  }
}

class GroupParticipant {
  final String id;
  final String groupId;
  final String patientId;
  final ParticipantRole role;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final ParticipantStatus status;
  final String? notes;
  final Map<String, dynamic> metadata;

  const GroupParticipant({
    required this.id,
    required this.groupId,
    required this.patientId,
    this.role = ParticipantRole.member,
    required this.joinedAt,
    this.leftAt,
    this.status = ParticipantStatus.active,
    this.notes,
    this.metadata = const {},
  });

  factory GroupParticipant.fromJson(Map<String, dynamic> json) {
    return GroupParticipant(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      patientId: json['patientId'] as String,
      role: ParticipantRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => ParticipantRole.member,
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      leftAt: json['leftAt'] != null 
          ? DateTime.parse(json['leftAt'] as String) 
          : null,
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ParticipantStatus.active,
      ),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'patientId': patientId,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if participant is active
  bool get isActive {
    return status == ParticipantStatus.active && leftAt == null;
  }
}

class GroupActivity {
  final String id;
  final String groupId;
  final String sessionId;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime startTime;
  final DateTime? endTime;
  final String? facilitatorId;
  final List<String> participantIds;
  final ActivityStatus status;
  final String? notes;
  final Map<String, dynamic> results;
  final Map<String, dynamic> metadata;

  const GroupActivity({
    required this.id,
    required this.groupId,
    required this.sessionId,
    required this.title,
    required this.description,
    required this.type,
    required this.startTime,
    this.endTime,
    this.facilitatorId,
    this.participantIds = const [],
    this.status = ActivityStatus.scheduled,
    this.notes,
    this.results = const {},
    this.metadata = const {},
  });

  factory GroupActivity.fromJson(Map<String, dynamic> json) {
    return GroupActivity(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      sessionId: json['sessionId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.discussion,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      facilitatorId: json['facilitatorId'] as String?,
      participantIds: List<String>.from(json['participantIds'] as List? ?? []),
      status: ActivityStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ActivityStatus.scheduled,
      ),
      notes: json['notes'] as String?,
      results: Map<String, dynamic>.from(json['results'] as Map? ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'sessionId': sessionId,
      'title': title,
      'description': description,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'facilitatorId': facilitatorId,
      'participantIds': participantIds,
      'status': status.name,
      'notes': notes,
      'results': results,
      'metadata': metadata,
    };
  }

  // Check if activity is active
  bool get isActive {
    return status == ActivityStatus.active;
  }

  // Check if activity is completed
  bool get isCompleted {
    return status == ActivityStatus.completed;
  }
}

class GroupFeedback {
  final String id;
  final String groupId;
  final String sessionId;
  final String participantId;
  final String? facilitatorId;
  final FeedbackType type;
  final Map<String, dynamic> responses;
  final DateTime submittedAt;
  final String? notes;
  final Map<String, dynamic> metadata;

  const GroupFeedback({
    required this.id,
    required this.groupId,
    required this.sessionId,
    required this.participantId,
    this.facilitatorId,
    required this.type,
    required this.responses,
    required this.submittedAt,
    this.notes,
    this.metadata = const {},
  });

  factory GroupFeedback.fromJson(Map<String, dynamic> json) {
    return GroupFeedback(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      sessionId: json['sessionId'] as String,
      participantId: json['participantId'] as String,
      facilitatorId: json['facilitatorId'] as String?,
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.session,
      ),
      responses: Map<String, dynamic>.from(json['responses'] as Map),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'sessionId': sessionId,
      'participantId': participantId,
      'facilitatorId': facilitatorId,
      'type': type.name,
      'responses': responses,
      'submittedAt': submittedAt.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class GroupTemplate {
  final String id;
  final String name;
  final String description;
  final GroupType type;
  final List<String> objectives;
  final List<String> materials;
  final Duration duration;
  final int maxParticipants;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isPublic;
  final List<String> sharedWith;
  final Map<String, dynamic> metadata;

  const GroupTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.objectives,
    required this.materials,
    required this.duration,
    required this.maxParticipants,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isPublic = false,
    this.sharedWith = const [],
    this.metadata = const {},
  });

  factory GroupTemplate.fromJson(Map<String, dynamic> json) {
    return GroupTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: GroupType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GroupType.therapy,
      ),
      objectives: List<String>.from(json['objectives'] as List),
      materials: List<String>.from(json['materials'] as List),
      duration: Duration(minutes: json['duration'] as int),
      maxParticipants: json['maxParticipants'] as int,
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
      'type': type.name,
      'objectives': objectives,
      'materials': materials,
      'duration': duration.inMinutes,
      'maxParticipants': maxParticipants,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'metadata': metadata,
    };
  }

  // Check if template is accessible by user
  bool isAccessibleBy(String userId) {
    return isPublic || 
           createdBy == userId || 
           sharedWith.contains(userId);
  }
}

enum GroupType {
  therapy,
  support,
  psychoeducation,
  skills,
  mindfulness,
  art,
  music,
  exercise,
  other,
}

enum SessionStatus {
  scheduled,
  active,
  completed,
  cancelled,
  postponed,
}

enum ParticipantRole {
  member,
  coFacilitator,
  observer,
  guest,
}

enum ParticipantStatus {
  active,
  inactive,
  suspended,
  removed,
}

enum ActivityType {
  discussion,
  exercise,
  presentation,
  roleplay,
  meditation,
  art,
  music,
  movement,
  other,
}

enum ActivityStatus {
  scheduled,
  active,
  completed,
  cancelled,
}

enum FeedbackType {
  session,
  activity,
  group,
  facilitator,
  overall,
}
