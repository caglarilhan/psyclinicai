class FamilyMember {
  final String id;
  final String patientId;
  final String name;
  final String relationship; // Anne, Baba, Eş, Çocuk, vb.
  final String phoneNumber;
  final String? email;
  final String? address;
  final bool isPrimaryContact;
  final bool canReceiveUpdates;
  final bool canMakeDecisions;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const FamilyMember({
    required this.id,
    required this.patientId,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.address,
    this.isPrimaryContact = false,
    this.canReceiveUpdates = true,
    this.canMakeDecisions = false,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      isPrimaryContact: json['isPrimaryContact'] as bool? ?? false,
      canReceiveUpdates: json['canReceiveUpdates'] as bool? ?? true,
      canMakeDecisions: json['canMakeDecisions'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'isPrimaryContact': isPrimaryContact,
      'canReceiveUpdates': canReceiveUpdates,
      'canMakeDecisions': canMakeDecisions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  FamilyMember copyWith({
    String? id,
    String? patientId,
    String? name,
    String? relationship,
    String? phoneNumber,
    String? email,
    String? address,
    bool? isPrimaryContact,
    bool? canReceiveUpdates,
    bool? canMakeDecisions,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
      canReceiveUpdates: canReceiveUpdates ?? this.canReceiveUpdates,
      canMakeDecisions: canMakeDecisions ?? this.canMakeDecisions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class FamilyCommunication {
  final String id;
  final String patientId;
  final String familyMemberId;
  final CommunicationType type;
  final String subject;
  final String message;
  final DateTime sentAt;
  final String sentBy; // clinician ID
  final CommunicationStatus status;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? response;
  final DateTime? responseAt;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  const FamilyCommunication({
    required this.id,
    required this.patientId,
    required this.familyMemberId,
    required this.type,
    required this.subject,
    required this.message,
    required this.sentAt,
    required this.sentBy,
    this.status = CommunicationStatus.sent,
    this.deliveredAt,
    this.readAt,
    this.response,
    this.responseAt,
    this.attachments = const [],
    this.metadata = const {},
  });

  factory FamilyCommunication.fromJson(Map<String, dynamic> json) {
    return FamilyCommunication(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      familyMemberId: json['familyMemberId'] as String,
      type: CommunicationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CommunicationType.update,
      ),
      subject: json['subject'] as String,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      sentBy: json['sentBy'] as String,
      status: CommunicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CommunicationStatus.sent,
      ),
      deliveredAt: json['deliveredAt'] != null 
          ? DateTime.parse(json['deliveredAt'] as String) 
          : null,
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'] as String) 
          : null,
      response: json['response'] as String?,
      responseAt: json['responseAt'] != null 
          ? DateTime.parse(json['responseAt'] as String) 
          : null,
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'familyMemberId': familyMemberId,
      'type': type.name,
      'subject': subject,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'sentBy': sentBy,
      'status': status.name,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'response': response,
      'responseAt': responseAt?.toIso8601String(),
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  FamilyCommunication copyWith({
    String? id,
    String? patientId,
    String? familyMemberId,
    CommunicationType? type,
    String? subject,
    String? message,
    DateTime? sentAt,
    String? sentBy,
    CommunicationStatus? status,
    DateTime? deliveredAt,
    DateTime? readAt,
    String? response,
    DateTime? responseAt,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return FamilyCommunication(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      sentBy: sentBy ?? this.sentBy,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      response: response ?? this.response,
      responseAt: responseAt ?? this.responseAt,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}

class FamilyMeeting {
  final String id;
  final String patientId;
  final List<String> familyMemberIds;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final Duration duration;
  final String location;
  final MeetingType type;
  final String organizedBy; // clinician ID
  final MeetingStatus status;
  final String? notes;
  final List<String> attendees;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic> outcomes;

  const FamilyMeeting({
    required this.id,
    required this.patientId,
    required this.familyMemberIds,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.duration,
    required this.location,
    required this.type,
    required this.organizedBy,
    this.status = MeetingStatus.scheduled,
    this.notes,
    this.attendees = const [],
    this.startedAt,
    this.endedAt,
    this.outcomes = const {},
  });

  factory FamilyMeeting.fromJson(Map<String, dynamic> json) {
    return FamilyMeeting(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      familyMemberIds: List<String>.from(json['familyMemberIds'] as List),
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      duration: Duration(minutes: json['duration'] as int),
      location: json['location'] as String? ?? 'Belirtilmemiş',
      type: FamilyMeetingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FamilyMeetingType.family,
      ),
      organizedBy: json['organizedBy'] as String,
      status: MeetingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MeetingStatus.scheduled,
      ),
      notes: json['notes'] as String?,
      attendees: List<String>.from(json['attendees'] as List? ?? []),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String) 
          : null,
      outcomes: Map<String, dynamic>.from(json['outcomes'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'familyMemberIds': familyMemberIds,
      'title': title,
      'description': description,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration.inMinutes,
      'location': location,
      'type': type.name,
      'organizedBy': organizedBy,
      'status': status.name,
      'notes': notes,
      'attendees': attendees,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'outcomes': outcomes,
    };
  }
}

class FamilyConsent {
  final String id;
  final String patientId;
  final String familyMemberId;
  final ConsentType type;
  final String description;
  final DateTime requestedAt;
  final String requestedBy; // clinician ID
  final ConsentStatus status;
  final DateTime? grantedAt;
  final DateTime? expiresAt;
  final String? notes;
  final Map<String, dynamic> permissions;

  const FamilyConsent({
    required this.id,
    required this.patientId,
    required this.familyMemberId,
    required this.type,
    required this.description,
    required this.requestedAt,
    required this.requestedBy,
    this.status = ConsentStatus.pending,
    this.grantedAt,
    this.expiresAt,
    this.notes,
    this.permissions = const {},
  });

  factory FamilyConsent.fromJson(Map<String, dynamic> json) {
    return FamilyConsent(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      familyMemberId: json['familyMemberId'] as String,
      type: ConsentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConsentType.informationAccess,
      ),
      description: json['description'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      requestedBy: json['requestedBy'] as String,
      status: ConsentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsentStatus.pending,
      ),
      grantedAt: json['grantedAt'] != null 
          ? DateTime.parse(json['grantedAt'] as String) 
          : null,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      notes: json['notes'] as String?,
      permissions: Map<String, dynamic>.from(json['permissions'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'familyMemberId': familyMemberId,
      'type': type.name,
      'description': description,
      'requestedAt': requestedAt.toIso8601String(),
      'requestedBy': requestedBy,
      'status': status.name,
      'grantedAt': grantedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'notes': notes,
      'permissions': permissions,
    };
  }
}

enum CommunicationType {
  update,
  emergency,
  appointment,
  medication,
  discharge,
  general,
}

enum CommunicationStatus {
  sent,
  delivered,
  read,
  responded,
  failed,
}

enum MeetingType {
  consultation,
  familyTherapy,
  dischargePlanning,
  crisisIntervention,
  education,
}

enum MeetingStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

enum ConsentType {
  informationAccess,
  decisionMaking,
  emergencyContact,
  treatmentParticipation,
  dataSharing,
}

enum ConsentStatus {
  pending,
  granted,
  denied,
  expired,
  revoked,
}
