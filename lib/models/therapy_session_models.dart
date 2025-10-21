class TherapySession {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime scheduledAt;
  final Duration duration;
  final SessionType type;
  final SessionStatus status;
  final String? notes;
  final String? goals;
  final String? interventions;
  final String? homework;
  final String? nextSessionPlan;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic> sessionData;
  final List<String> attendees;
  final String? location;
  final bool isTelehealth;
  final String? telehealthLink;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TherapySession({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.scheduledAt,
    required this.duration,
    required this.type,
    this.status = SessionStatus.scheduled,
    this.notes,
    this.goals,
    this.interventions,
    this.homework,
    this.nextSessionPlan,
    this.startedAt,
    this.endedAt,
    this.sessionData = const {},
    this.attendees = const [],
    this.location,
    this.isTelehealth = false,
    this.telehealthLink,
    required this.createdAt,
    this.updatedAt,
  });

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      therapistId: json['therapistId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      duration: Duration(minutes: json['duration'] as int),
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.individual,
      ),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      notes: json['notes'] as String?,
      goals: json['goals'] as String?,
      interventions: json['interventions'] as String?,
      homework: json['homework'] as String?,
      nextSessionPlan: json['nextSessionPlan'] as String?,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String) 
          : null,
      sessionData: Map<String, dynamic>.from(json['sessionData'] as Map? ?? {}),
      attendees: List<String>.from(json['attendees'] as List? ?? []),
      location: json['location'] as String?,
      isTelehealth: json['isTelehealth'] as bool? ?? false,
      telehealthLink: json['telehealthLink'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'therapistId': therapistId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration.inMinutes,
      'type': type.name,
      'status': status.name,
      'notes': notes,
      'goals': goals,
      'interventions': interventions,
      'homework': homework,
      'nextSessionPlan': nextSessionPlan,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'sessionData': sessionData,
      'attendees': attendees,
      'location': location,
      'isTelehealth': isTelehealth,
      'telehealthLink': telehealthLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Session duration calculation
  Duration? get actualDuration {
    if (startedAt == null || endedAt == null) return null;
    return endedAt!.difference(startedAt!);
  }

  // Check if session is overdue
  bool get isOverdue {
    return status == SessionStatus.scheduled && 
           scheduledAt.isBefore(DateTime.now());
  }

  // Check if session is upcoming (within next hour)
  bool get isUpcoming {
    final now = DateTime.now();
    final oneHourFromNow = now.add(const Duration(hours: 1));
    return status == SessionStatus.scheduled && 
           scheduledAt.isAfter(now) && 
           scheduledAt.isBefore(oneHourFromNow);
  }
}

class SessionNote {
  final String id;
  final String sessionId;
  final String therapistId;
  final DateTime createdAt;
  final String content;
  final NoteType type;
  final List<String> tags;
  final bool isConfidential;
  final String? followUpAction;

  const SessionNote({
    required this.id,
    required this.sessionId,
    required this.therapistId,
    required this.createdAt,
    required this.content,
    required this.type,
    this.tags = const [],
    this.isConfidential = false,
    this.followUpAction,
  });

  factory SessionNote.fromJson(Map<String, dynamic> json) {
    return SessionNote(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      therapistId: json['therapistId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: json['content'] as String,
      type: NoteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NoteType.general,
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      isConfidential: json['isConfidential'] as bool? ?? false,
      followUpAction: json['followUpAction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'therapistId': therapistId,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'type': type.name,
      'tags': tags,
      'isConfidential': isConfidential,
      'followUpAction': followUpAction,
    };
  }
}

class SessionGoal {
  final String id;
  final String sessionId;
  final String description;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? achievedAt;
  final String? notes;

  const SessionGoal({
    required this.id,
    required this.sessionId,
    required this.description,
    this.status = GoalStatus.pending,
    required this.createdAt,
    this.achievedAt,
    this.notes,
  });

  factory SessionGoal.fromJson(Map<String, dynamic> json) {
    return SessionGoal(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      description: json['description'] as String,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      achievedAt: json['achievedAt'] != null 
          ? DateTime.parse(json['achievedAt'] as String) 
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'achievedAt': achievedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

class SessionIntervention {
  final String id;
  final String sessionId;
  final String name;
  final InterventionType type;
  final String description;
  final Duration duration;
  final String? outcome;
  final String? notes;
  final DateTime timestamp;

  const SessionIntervention({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.type,
    required this.description,
    required this.duration,
    this.outcome,
    this.notes,
    required this.timestamp,
  });

  factory SessionIntervention.fromJson(Map<String, dynamic> json) {
    return SessionIntervention(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      name: json['name'] as String,
      type: InterventionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InterventionType.cognitive,
      ),
      description: json['description'] as String,
      duration: Duration(minutes: json['duration'] as int),
      outcome: json['outcome'] as String?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'name': name,
      'type': type.name,
      'description': description,
      'duration': duration.inMinutes,
      'outcome': outcome,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SessionHomework {
  final String id;
  final String sessionId;
  final String title;
  final String description;
  final DateTime assignedAt;
  final DateTime dueDate;
  final HomeworkStatus status;
  final String? completionNotes;
  final DateTime? completedAt;
  final String? feedback;

  const SessionHomework({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.description,
    required this.assignedAt,
    required this.dueDate,
    this.status = HomeworkStatus.assigned,
    this.completionNotes,
    this.completedAt,
    this.feedback,
  });

  factory SessionHomework.fromJson(Map<String, dynamic> json) {
    return SessionHomework(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: HomeworkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HomeworkStatus.assigned,
      ),
      completionNotes: json['completionNotes'] as String?,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'title': title,
      'description': description,
      'assignedAt': assignedAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'completionNotes': completionNotes,
      'completedAt': completedAt?.toIso8601String(),
      'feedback': feedback,
    };
  }

  // Check if homework is overdue
  bool get isOverdue {
    return status != HomeworkStatus.completed && 
           dueDate.isBefore(DateTime.now());
  }
}

enum SessionType {
  individual,
  group,
  family,
  couple,
  supervision,
  consultation,
}

enum SessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
  rescheduled,
}

enum NoteType {
  general,
  clinical,
  progress,
  crisis,
  supervision,
  administrative,
}

enum GoalStatus {
  pending,
  inProgress,
  achieved,
  modified,
  discontinued,
}

enum InterventionType {
  cognitive,
  behavioral,
  psychodynamic,
  humanistic,
  systemic,
  mindfulness,
  psychoeducation,
  other,
}

enum HomeworkStatus {
  assigned,
  inProgress,
  completed,
  overdue,
  cancelled,
}
