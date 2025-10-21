class ConsultationRequest {
  final String id;
  final String patientId;
  final String requestingPhysicianId;
  final String consultingPsychiatristId;
  final ConsultationType type;
  final String reason;
  final String question;
  final ConsultationUrgency urgency;
  final DateTime requestedAt;
  final DateTime? scheduledAt;
  final ConsultationStatus status;
  final String? notes;
  final Map<String, dynamic> metadata;

  const ConsultationRequest({
    required this.id,
    required this.patientId,
    required this.requestingPhysicianId,
    required this.consultingPsychiatristId,
    required this.type,
    required this.reason,
    required this.question,
    required this.urgency,
    required this.requestedAt,
    this.scheduledAt,
    this.status = ConsultationStatus.pending,
    this.notes,
    this.metadata = const {},
  });

  factory ConsultationRequest.fromJson(Map<String, dynamic> json) {
    return ConsultationRequest(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      requestingPhysicianId: json['requestingPhysicianId'] as String,
      consultingPsychiatristId: json['consultingPsychiatristId'] as String,
      type: ConsultationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConsultationType.assessment,
      ),
      reason: json['reason'] as String,
      question: json['question'] as String,
      urgency: ConsultationUrgency.values.firstWhere(
        (e) => e.name == json['urgency'],
        orElse: () => ConsultationUrgency.routine,
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      scheduledAt: json['scheduledAt'] != null 
          ? DateTime.parse(json['scheduledAt'] as String) 
          : null,
      status: ConsultationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsultationStatus.pending,
      ),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'requestingPhysicianId': requestingPhysicianId,
      'consultingPsychiatristId': consultingPsychiatristId,
      'type': type.name,
      'reason': reason,
      'question': question,
      'urgency': urgency.name,
      'requestedAt': requestedAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if consultation is urgent
  bool get isUrgent {
    return urgency == ConsultationUrgency.urgent || 
           urgency == ConsultationUrgency.emergent;
  }

  // Check if consultation is overdue
  bool get isOverdue {
    if (status == ConsultationStatus.completed) return false;
    
    final hoursSinceRequested = DateTime.now().difference(requestedAt).inHours;
    
    switch (urgency) {
      case ConsultationUrgency.emergent:
        return hoursSinceRequested > 1;
      case ConsultationUrgency.urgent:
        return hoursSinceRequested > 4;
      case ConsultationUrgency.routine:
        return hoursSinceRequested > 24;
      case ConsultationUrgency.emergency: // Eksik case eklendi
        return hoursSinceRequested > 0.5; // 30 dakika
    }
  }
}

class ConsultationResponse {
  final String id;
  final String consultationRequestId;
  final String psychiatristId;
  final DateTime respondedAt;
  final String assessment;
  final String recommendations;
  final String? followUp;
  final String? notes;
  final Map<String, dynamic> metadata;

  const ConsultationResponse({
    required this.id,
    required this.consultationRequestId,
    required this.psychiatristId,
    required this.respondedAt,
    required this.assessment,
    required this.recommendations,
    this.followUp,
    this.notes,
    this.metadata = const {},
  });

  factory ConsultationResponse.fromJson(Map<String, dynamic> json) {
    return ConsultationResponse(
      id: json['id'] as String,
      consultationRequestId: json['consultationRequestId'] as String,
      psychiatristId: json['psychiatristId'] as String,
      respondedAt: DateTime.parse(json['respondedAt'] as String),
      assessment: json['assessment'] as String,
      recommendations: json['recommendations'] as String,
      followUp: json['followUp'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consultationRequestId': consultationRequestId,
      'psychiatristId': psychiatristId,
      'respondedAt': respondedAt.toIso8601String(),
      'assessment': assessment,
      'recommendations': recommendations,
      'followUp': followUp,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class ConsultationTemplate {
  final String id;
  final String name;
  final String description;
  final ConsultationType type;
  final String template;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isPublic;
  final List<String> sharedWith;
  final Map<String, dynamic> metadata;

  const ConsultationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.template,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isPublic = false,
    this.sharedWith = const [],
    this.metadata = const {},
  });

  factory ConsultationTemplate.fromJson(Map<String, dynamic> json) {
    return ConsultationTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ConsultationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConsultationType.assessment,
      ),
      template: json['template'] as String,
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
      'template': template,
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

class ConsultationSchedule {
  final String id;
  final String psychiatristId;
  final DateTime startTime;
  final DateTime endTime;
  final String? patientId;
  final String? consultationRequestId;
  final ScheduleStatus status;
  final String? notes;
  final Map<String, dynamic> metadata;

  const ConsultationSchedule({
    required this.id,
    required this.psychiatristId,
    required this.startTime,
    required this.endTime,
    this.patientId,
    this.consultationRequestId,
    this.status = ScheduleStatus.available,
    this.notes,
    this.metadata = const {},
  });

  factory ConsultationSchedule.fromJson(Map<String, dynamic> json) {
    return ConsultationSchedule(
      id: json['id'] as String,
      psychiatristId: json['psychiatristId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      patientId: json['patientId'] as String?,
      consultationRequestId: json['consultationRequestId'] as String?,
      status: ScheduleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ScheduleStatus.available,
      ),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'psychiatristId': psychiatristId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'patientId': patientId,
      'consultationRequestId': consultationRequestId,
      'status': status.name,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if schedule is available
  bool get isAvailable {
    return status == ScheduleStatus.available;
  }

  // Check if schedule is booked
  bool get isBooked {
    return status == ScheduleStatus.booked;
  }
}

enum ConsultationType {
  assessment,
  medication,
  crisis,
  followUp,
  secondOpinion,
  other,
}

enum ConsultationUrgency {
  emergent,
  urgent,
  routine,
  emergency, // Eksik değer eklendi
}

enum ConsultationStatus {
  pending,
  scheduled,
  inProgress,
  completed,
  cancelled,
}

enum ScheduleStatus {
  available,
  booked,
  blocked,
  cancelled,
}
