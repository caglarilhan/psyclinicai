class SupervisionSession {
  final String id;
  final String supervisorId;
  final String superviseeId;
  final DateTime scheduledAt;
  final Duration duration;
  final SupervisionType type;
  final SupervisionStatus status;
  final String? agenda;
  final String? notes;
  final String? feedback;
  final String? actionItems;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<String> attendees;
  final String? location;
  final bool isTelehealth;
  final String? telehealthLink;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupervisionSession({
    required this.id,
    required this.supervisorId,
    required this.superviseeId,
    required this.scheduledAt,
    required this.duration,
    required this.type,
    this.status = SupervisionStatus.scheduled,
    this.agenda,
    this.notes,
    this.feedback,
    this.actionItems,
    this.startedAt,
    this.endedAt,
    this.attendees = const [],
    this.location,
    this.isTelehealth = false,
    this.telehealthLink,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupervisionSession.fromJson(Map<String, dynamic> json) {
    return SupervisionSession(
      id: json['id'] as String,
      supervisorId: json['supervisorId'] as String,
      superviseeId: json['superviseeId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      duration: Duration(minutes: json['duration'] as int),
      type: SupervisionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SupervisionType.individual,
      ),
      status: SupervisionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SupervisionStatus.scheduled,
      ),
      agenda: json['agenda'] as String?,
      notes: json['notes'] as String?,
      feedback: json['feedback'] as String?,
      actionItems: json['actionItems'] as String?,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String) 
          : null,
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
      'supervisorId': supervisorId,
      'superviseeId': superviseeId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration.inMinutes,
      'type': type.name,
      'status': status.name,
      'agenda': agenda,
      'notes': notes,
      'feedback': feedback,
      'actionItems': actionItems,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
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
    return status == SupervisionStatus.scheduled && 
           scheduledAt.isBefore(DateTime.now());
  }
}

class SupervisionNote {
  final String id;
  final String sessionId;
  final String supervisorId;
  final DateTime createdAt;
  final String content;
  final NoteType type;
  final List<String> tags;
  final bool isConfidential;
  final String? followUpAction;

  const SupervisionNote({
    required this.id,
    required this.sessionId,
    required this.supervisorId,
    required this.createdAt,
    required this.content,
    required this.type,
    this.tags = const [],
    this.isConfidential = false,
    this.followUpAction,
  });

  factory SupervisionNote.fromJson(Map<String, dynamic> json) {
    return SupervisionNote(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      supervisorId: json['supervisorId'] as String,
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
      'supervisorId': supervisorId,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'type': type.name,
      'tags': tags,
      'isConfidential': isConfidential,
      'followUpAction': followUpAction,
    };
  }
}

class SupervisionGoal {
  final String id;
  final String sessionId;
  final String description;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? achievedAt;
  final String? notes;

  const SupervisionGoal({
    required this.id,
    required this.sessionId,
    required this.description,
    this.status = GoalStatus.pending,
    required this.createdAt,
    this.achievedAt,
    this.notes,
  });

  factory SupervisionGoal.fromJson(Map<String, dynamic> json) {
    return SupervisionGoal(
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

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final TeamRole role;
  final List<String> specialties;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final List<String> certifications;
  final DateTime joinedAt;
  final bool isActive;
  final String? supervisorId;
  final Map<String, dynamic> metadata;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.specialties = const [],
    this.licenseNumber,
    this.licenseExpiry,
    this.certifications = const [],
    required this.joinedAt,
    this.isActive = true,
    this.supervisorId,
    this.metadata = const {},
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: TeamRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => TeamRole.psychologist,
      ),
      specialties: List<String>.from(json['specialties'] as List? ?? []),
      licenseNumber: json['licenseNumber'] as String?,
      licenseExpiry: json['licenseExpiry'] != null 
          ? DateTime.parse(json['licenseExpiry'] as String) 
          : null,
      certifications: List<String>.from(json['certifications'] as List? ?? []),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      supervisorId: json['supervisorId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'specialties': specialties,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry?.toIso8601String(),
      'certifications': certifications,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
      'supervisorId': supervisorId,
      'metadata': metadata,
    };
  }

  // Check if license is expired
  bool get isLicenseExpired {
    if (licenseExpiry == null) return false;
    return licenseExpiry!.isBefore(DateTime.now());
  }

  // Check if license expires soon (within 30 days)
  bool get isLicenseExpiringSoon {
    if (licenseExpiry == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return licenseExpiry!.isAfter(DateTime.now()) && 
           licenseExpiry!.isBefore(thirtyDaysFromNow);
  }
}

class TeamMeeting {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final Duration duration;
  final String location;
  final List<String> attendees;
  final String organizedBy;
  final MeetingType type;
  final MeetingStatus status;
  final String? agenda;
  final String? notes;
  final List<String> actionItems;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const TeamMeeting({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.duration,
    required this.location,
    required this.attendees,
    required this.organizedBy,
    required this.type,
    this.status = MeetingStatus.scheduled,
    this.agenda,
    this.notes,
    this.actionItems = const [],
    this.startedAt,
    this.endedAt,
  });

  factory TeamMeeting.fromJson(Map<String, dynamic> json) {
    return TeamMeeting(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      duration: Duration(minutes: json['duration'] as int),
      location: json['location'] as String,
      attendees: List<String>.from(json['attendees'] as List),
      organizedBy: json['organizedBy'] as String,
      type: MeetingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MeetingType.team,
      ),
      status: MeetingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MeetingStatus.scheduled,
      ),
      agenda: json['agenda'] as String?,
      notes: json['notes'] as String?,
      actionItems: List<String>.from(json['actionItems'] as List? ?? []),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration.inMinutes,
      'location': location,
      'attendees': attendees,
      'organizedBy': organizedBy,
      'type': type.name,
      'status': status.name,
      'agenda': agenda,
      'notes': notes,
      'actionItems': actionItems,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }
}

enum SupervisionType {
  individual,
  group,
  peer,
  caseReview,
  training,
}

enum SupervisionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
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

enum TeamRole {
  psychiatrist,
  psychologist,
  therapist,
  counselor,
  socialWorker,
  nurse,
  administrator,
  intern,
  trainee,
}

enum MeetingType {
  team,
  caseReview,
  training,
  administrative,
  crisis,
}

enum MeetingStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}