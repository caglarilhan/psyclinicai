import 'package:json_annotation/json_annotation.dart';

part 'session_models.g.dart';

/// Session data model for therapy sessions
@JsonSerializable()
class SessionData {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime date;
  final int duration;
  final String type;
  final String status;
  final String location;
  final String notes;
  final List<String> goals;
  final List<String> interventions;
  final List<String> assessments;
  final List<String> progressNotes;
  final List<String> symptoms;
  final String patientResponse;
  final String treatmentPlan;
  final List<String> nextSteps;
  final List<String> homework;
  final String recommendations;
  final String followUpPlan;
  final List<String> referrals;
  final String? summary;
  final List<String> attachments;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionData({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.date,
    required this.duration,
    required this.type,
    required this.status,
    required this.location,
    required this.notes,
    required this.goals,
    required this.interventions,
    required this.assessments,
    required this.progressNotes,
    required this.symptoms,
    required this.patientResponse,
    required this.treatmentPlan,
    required this.nextSteps,
    required this.homework,
    required this.recommendations,
    required this.followUpPlan,
    required this.referrals,
    this.summary,
    required this.attachments,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) =>
      _$SessionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionDataToJson(this);
}

enum SessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}

enum SessionType {
  individual,
  group,
  family,
  couple,
  emergency,
  followUp,
  initial,
}

enum SessionModality {
  inPerson,
  video,
  phone,
  chat,
  hybrid,
}

class Session {
  final String id;
  final String clientId;
  final String title;
  final String notes;
  final List<String> goals;
  final String homework;
  final String nextSessionPlan;
  final DateTime sessionDate;
  final Duration duration;
  final SessionStatus status;
  final SessionType type;
  final SessionModality modality;
  final String? therapistId;
  final String? location;
  final double? cost;
  final String? insuranceInfo;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Session({
    required this.id,
    required this.clientId,
    required this.title,
    required this.notes,
    required this.goals,
    required this.homework,
    required this.nextSessionPlan,
    required this.sessionDate,
    required this.duration,
    required this.status,
    required this.type,
    required this.modality,
    this.therapistId,
    this.location,
    this.cost,
    this.insuranceInfo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Session copyWith({
    String? id,
    String? clientId,
    String? title,
    String? notes,
    List<String>? goals,
    String? homework,
    String? nextSessionPlan,
    DateTime? sessionDate,
    Duration? duration,
    SessionStatus? status,
    SessionType? type,
    SessionModality? modality,
    String? therapistId,
    String? location,
    double? cost,
    String? insuranceInfo,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      goals: goals ?? this.goals,
      homework: homework ?? this.homework,
      nextSessionPlan: nextSessionPlan ?? this.nextSessionPlan,
      sessionDate: sessionDate ?? this.sessionDate,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      type: type ?? this.type,
      modality: modality ?? this.modality,
      therapistId: therapistId ?? this.therapistId,
      location: location ?? this.location,
      cost: cost ?? this.cost,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'title': title,
      'notes': notes,
      'goals': goals,
      'homework': homework,
      'nextSessionPlan': nextSessionPlan,
      'sessionDate': sessionDate.toIso8601String(),
      'duration': duration.inMinutes,
      'status': status.name,
      'type': type.name,
      'modality': modality.name,
      'therapistId': therapistId,
      'location': location,
      'cost': cost,
      'insuranceInfo': insuranceInfo,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String,
      goals: List<String>.from(json['goals'] as List),
      homework: json['homework'] as String,
      nextSessionPlan: json['nextSessionPlan'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      duration: Duration(minutes: json['duration'] as int),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.individual,
      ),
      modality: SessionModality.values.firstWhere(
        (e) => e.name == json['modality'],
        orElse: () => SessionModality.inPerson,
      ),
      therapistId: json['therapistId'] as String?,
      location: json['location'] as String?,
      cost: json['cost'] as double?,
      insuranceInfo: json['insuranceInfo'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Session(id: $id, title: $title, clientId: $clientId, status: $status)';
  }
}

class SessionNote {
  final String id;
  final String sessionId;
  final String content;
  final NoteType type;
  final DateTime timestamp;
  final String? authorId;
  final String? authorName;
  final bool isPrivate;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  const SessionNote({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.authorId,
    this.authorName,
    this.isPrivate = false,
    this.tags = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'authorId': authorId,
      'authorName': authorName,
      'isPrivate': isPrivate,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory SessionNote.fromJson(Map<String, dynamic> json) {
    return SessionNote(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      content: json['content'] as String,
      type: NoteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NoteType.general,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

enum NoteType {
  general,
  observation,
  intervention,
  assessment,
  plan,
  homework,
  family,
  crisis,
  medication,
  referral,
}

class AISummary {
  final String id;
  final String sessionId;
  final String summary;
  final String keyPoints;
  final String emotionalState;
  final String progressAssessment;
  final String recommendations;
  final List<String> riskFactors;
  final List<String> strengths;
  final double confidence;
  final DateTime generatedAt;
  final String modelVersion;
  final Map<String, dynamic>? metadata;

  const AISummary({
    required this.id,
    required this.sessionId,
    required this.summary,
    required this.keyPoints,
    required this.emotionalState,
    required this.progressAssessment,
    required this.recommendations,
    required this.riskFactors,
    required this.strengths,
    required this.confidence,
    required this.generatedAt,
    required this.modelVersion,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'summary': summary,
      'keyPoints': keyPoints,
      'emotionalState': emotionalState,
      'progressAssessment': progressAssessment,
      'recommendations': recommendations,
      'riskFactors': riskFactors,
      'strengths': strengths,
      'confidence': confidence,
      'generatedAt': generatedAt.toIso8601String(),
      'modelVersion': modelVersion,
      'metadata': metadata,
    };
  }

  factory AISummary.fromJson(Map<String, dynamic> json) {
    return AISummary(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      summary: json['summary'] as String,
      keyPoints: json['keyPoints'] as String,
      emotionalState: json['emotionalState'] as String,
      progressAssessment: json['progressAssessment'] as String,
      recommendations: json['recommendations'] as String,
      riskFactors: List<String>.from(json['riskFactors'] as List),
      strengths: List<String>.from(json['strengths'] as List),
      confidence: json['confidence'] as double,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      modelVersion: json['modelVersion'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class Client {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime dateOfBirth;
  final String gender;
  final String? address;
  final String? emergencyContact;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final List<String> diagnoses;
  final List<String> medications;
  final List<String> allergies;
  final String? notes;
  final DateTime firstSessionDate;
  final DateTime lastSessionDate;
  final int totalSessions;
  final ClientStatus status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.dateOfBirth,
    required this.gender,
    this.address,
    this.emergencyContact,
    this.insuranceProvider,
    this.insuranceNumber,
    this.diagnoses = const [],
    this.medications = const [],
    this.allergies = const [],
    this.notes,
    required this.firstSessionDate,
    required this.lastSessionDate,
    this.totalSessions = 0,
    required this.status,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? emergencyContact,
    String? insuranceProvider,
    String? insuranceNumber,
    List<String>? diagnoses,
    List<String>? medications,
    List<String>? allergies,
    String? notes,
    DateTime? firstSessionDate,
    DateTime? lastSessionDate,
    int? totalSessions,
    ClientStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      diagnoses: diagnoses ?? this.diagnoses,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      firstSessionDate: firstSessionDate ?? this.firstSessionDate,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      totalSessions: totalSessions ?? this.totalSessions,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'address': address,
      'emergencyContact': emergencyContact,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'diagnoses': diagnoses,
      'medications': medications,
      'allergies': allergies,
      'notes': notes,
      'firstSessionDate': firstSessionDate.toIso8601String(),
      'lastSessionDate': lastSessionDate.toIso8601String(),
      'totalSessions': totalSessions,
      'status': status.name,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      address: json['address'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      insuranceProvider: json['insuranceProvider'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
      diagnoses: List<String>.from(json['diagnoses'] as List? ?? []),
      medications: List<String>.from(json['medications'] as List? ?? []),
      allergies: List<String>.from(json['allergies'] as List? ?? []),
      notes: json['notes'] as String?,
      firstSessionDate: DateTime.parse(json['firstSessionDate'] as String),
      lastSessionDate: DateTime.parse(json['lastSessionDate'] as String),
      totalSessions: json['totalSessions'] as int? ?? 0,
      status: ClientStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ClientStatus.active,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Client(id: $id, name: $name, email: $email)';
  }
}

enum ClientStatus {
  active,
  inactive,
  discharged,
  onHold,
  emergency,
}

class SessionGoal {
  final String id;
  final String sessionId;
  final String description;
  final GoalType type;
  final GoalPriority priority;
  final GoalStatus status;
  final double progress;
  final DateTime targetDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionGoal({
    required this.id,
    required this.sessionId,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    this.progress = 0.0,
    required this.targetDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'progress': progress,
      'targetDate': targetDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SessionGoal.fromJson(Map<String, dynamic> json) {
    return SessionGoal(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      description: json['description'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.behavioral,
      ),
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => GoalPriority.medium,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.inProgress,
      ),
      progress: json['progress'] as double? ?? 0.0,
      targetDate: DateTime.parse(json['targetDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

enum GoalType {
  behavioral,
  cognitive,
  emotional,
  social,
  physical,
  academic,
  occupational,
  family,
  relationship,
  other,
}

enum GoalPriority {
  low,
  medium,
  high,
  critical,
}

enum GoalStatus {
  notStarted,
  inProgress,
  completed,
  onHold,
  cancelled,
}

class SessionHomework {
  final String id;
  final String sessionId;
  final String description;
  final HomeworkType type;
  final DateTime assignedDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final HomeworkStatus status;
  final String? clientNotes;
  final String? therapistNotes;
  final double? difficulty;
  final double? satisfaction;
  final Map<String, dynamic>? metadata;

  const SessionHomework({
    required this.id,
    required this.sessionId,
    required this.description,
    required this.type,
    required this.assignedDate,
    this.dueDate,
    this.completedDate,
    required this.status,
    this.clientNotes,
    this.therapistNotes,
    this.difficulty,
    this.satisfaction,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'description': description,
      'type': type.name,
      'assignedDate': assignedDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status.name,
      'clientNotes': clientNotes,
      'therapistNotes': therapistNotes,
      'difficulty': difficulty,
      'satisfaction': satisfaction,
      'metadata': metadata,
    };
  }

  factory SessionHomework.fromJson(Map<String, dynamic> json) {
    return SessionHomework(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      description: json['description'] as String,
      type: HomeworkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HomeworkType.exercise,
      ),
      assignedDate: DateTime.parse(json['assignedDate'] as String),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'] as String) 
          : null,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'] as String) 
          : null,
      status: HomeworkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HomeworkStatus.assigned,
      ),
      clientNotes: json['clientNotes'] as String?,
      therapistNotes: json['therapistNotes'] as String?,
      difficulty: json['difficulty'] as double?,
      satisfaction: json['satisfaction'] as double?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

enum HomeworkType {
  exercise,
  journaling,
  reading,
  meditation,
  social,
  physical,
  cognitive,
  emotional,
  family,
  other,
}

enum HomeworkStatus {
  assigned,
  inProgress,
  completed,
  overdue,
  cancelled,
}
