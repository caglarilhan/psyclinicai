import 'dart:convert';

enum ProfessionalType { psychiatrist, clinicalPsychologist, psychologist, therapist, counselor, socialWorker, nurse, admin }
enum CommunicationType { secureMessage, videoCall, voiceCall, fileShare, appointmentRequest, emergency }
enum CollaborationType { consultation, supervision, caseConference, peerReview, training }

class InterProfessionalCommunication {
  final String id;
  final String senderId;
  final String receiverId;
  final CommunicationType type;
  final String subject;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isUrgent;
  final bool isConfidential;
  final String? patientId;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  InterProfessionalCommunication({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.subject,
    required this.content,
    required this.sentAt,
    this.readAt,
    this.isUrgent = false,
    this.isConfidential = false,
    this.patientId,
    this.attachments = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.name,
      'subject': subject,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isUrgent': isUrgent,
      'isConfidential': isConfidential,
      'patientId': patientId,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  factory InterProfessionalCommunication.fromJson(Map<String, dynamic> json) {
    return InterProfessionalCommunication(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      type: CommunicationType.values.firstWhere((e) => e.name == json['type']),
      subject: json['subject'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      isUrgent: json['isUrgent'] ?? false,
      isConfidential: json['isConfidential'] ?? false,
      patientId: json['patientId'],
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }
}

class CollaborativeCase {
  final String id;
  final String patientId;
  final String primaryProviderId;
  final List<String> collaboratingProviderIds;
  final CollaborationType collaborationType;
  final String caseTitle;
  final String caseDescription;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final String status;
  final List<CaseNote> caseNotes;
  final List<CaseDecision> decisions;
  final Map<String, dynamic> sharedData;
  final Map<String, dynamic> metadata;

  CollaborativeCase({
    required this.id,
    required this.patientId,
    required this.primaryProviderId,
    required this.collaboratingProviderIds,
    required this.collaborationType,
    required this.caseTitle,
    required this.caseDescription,
    required this.createdAt,
    this.lastUpdated,
    required this.status,
    required this.caseNotes,
    required this.decisions,
    required this.sharedData,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'primaryProviderId': primaryProviderId,
      'collaboratingProviderIds': collaboratingProviderIds,
      'collaborationType': collaborationType.name,
      'caseTitle': caseTitle,
      'caseDescription': caseDescription,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'status': status,
      'caseNotes': caseNotes.map((n) => n.toJson()).toList(),
      'decisions': decisions.map((d) => d.toJson()).toList(),
      'sharedData': sharedData,
      'metadata': metadata,
    };
  }

  factory CollaborativeCase.fromJson(Map<String, dynamic> json) {
    return CollaborativeCase(
      id: json['id'],
      patientId: json['patientId'],
      primaryProviderId: json['primaryProviderId'],
      collaboratingProviderIds: List<String>.from(json['collaboratingProviderIds']),
      collaborationType: CollaborationType.values.firstWhere((e) => e.name == json['collaborationType']),
      caseTitle: json['caseTitle'],
      caseDescription: json['caseDescription'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      status: json['status'],
      caseNotes: (json['caseNotes'] as List).map((n) => CaseNote.fromJson(n)).toList(),
      decisions: (json['decisions'] as List).map((d) => CaseDecision.fromJson(d)).toList(),
      sharedData: Map<String, dynamic>.from(json['sharedData']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class CaseNote {
  final String id;
  final String authorId;
  final DateTime createdAt;
  final String content;
  final String noteType;
  final bool isConfidential;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  CaseNote({
    required this.id,
    required this.authorId,
    required this.createdAt,
    required this.content,
    required this.noteType,
    this.isConfidential = false,
    this.tags = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'noteType': noteType,
      'isConfidential': isConfidential,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory CaseNote.fromJson(Map<String, dynamic> json) {
    return CaseNote(
      id: json['id'],
      authorId: json['authorId'],
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
      noteType: json['noteType'],
      isConfidential: json['isConfidential'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }
}

class CaseDecision {
  final String id;
  final String decisionMakerId;
  final DateTime decisionDate;
  final String decision;
  final String rationale;
  final List<String> supportingEvidence;
  final String decisionType;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final Map<String, dynamic> metadata;

  CaseDecision({
    required this.id,
    required this.decisionMakerId,
    required this.decisionDate,
    required this.decision,
    required this.rationale,
    required this.supportingEvidence,
    required this.decisionType,
    this.requiresFollowUp = false,
    this.followUpDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'decisionMakerId': decisionMakerId,
      'decisionDate': decisionDate.toIso8601String(),
      'decision': decision,
      'rationale': rationale,
      'supportingEvidence': supportingEvidence,
      'decisionType': decisionType,
      'requiresFollowUp': requiresFollowUp,
      'followUpDate': followUpDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory CaseDecision.fromJson(Map<String, dynamic> json) {
    return CaseDecision(
      id: json['id'],
      decisionMakerId: json['decisionMakerId'],
      decisionDate: DateTime.parse(json['decisionDate']),
      decision: json['decision'],
      rationale: json['rationale'],
      supportingEvidence: List<String>.from(json['supportingEvidence']),
      decisionType: json['decisionType'],
      requiresFollowUp: json['requiresFollowUp'] ?? false,
      followUpDate: json['followUpDate'] != null ? DateTime.parse(json['followUpDate']) : null,
      metadata: json['metadata'] ?? {},
    );
  }
}

class ProfessionalNetwork {
  final String id;
  final String professionalId;
  final List<String> connectedProfessionalIds;
  final Map<String, String> connectionTypes; // professionalId -> connectionType
  final Map<String, DateTime> connectionDates;
  final Map<String, String> connectionNotes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  ProfessionalNetwork({
    required this.id,
    required this.professionalId,
    required this.connectedProfessionalIds,
    required this.connectionTypes,
    required this.connectionDates,
    required this.connectionNotes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'connectedProfessionalIds': connectedProfessionalIds,
      'connectionTypes': connectionTypes,
      'connectionDates': connectionDates.map((k, v) => MapEntry(k, v.toIso8601String())),
      'connectionNotes': connectionNotes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ProfessionalNetwork.fromJson(Map<String, dynamic> json) {
    return ProfessionalNetwork(
      id: json['id'],
      professionalId: json['professionalId'],
      connectedProfessionalIds: List<String>.from(json['connectedProfessionalIds']),
      connectionTypes: Map<String, String>.from(json['connectionTypes']),
      connectionDates: (json['connectionDates'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, DateTime.parse(v)),
      ),
      connectionNotes: Map<String, String>.from(json['connectionNotes']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class KnowledgeBase {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final ProfessionalType targetAudience;
  final String category;
  final String authorId;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final int viewCount;
  final int likeCount;
  final List<String> references;
  final bool isPublished;
  final bool isFeatured;
  final Map<String, dynamic> metadata;

  KnowledgeBase({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.targetAudience,
    required this.category,
    required this.authorId,
    required this.createdAt,
    this.lastUpdated,
    this.viewCount = 0,
    this.likeCount = 0,
    this.references = const [],
    this.isPublished = false,
    this.isFeatured = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'targetAudience': targetAudience.name,
      'category': category,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'references': references,
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'metadata': metadata,
    };
  }

  factory KnowledgeBase.fromJson(Map<String, dynamic> json) {
    return KnowledgeBase(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags']),
      targetAudience: ProfessionalType.values.firstWhere((e) => e.name == json['targetAudience']),
      category: json['category'],
      authorId: json['authorId'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      references: List<String>.from(json['references'] ?? []),
      isPublished: json['isPublished'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      metadata: json['metadata'] ?? {},
    );
  }
}

class ContinuingEducation {
  final String id;
  final String title;
  final String description;
  final List<ProfessionalType> targetAudience;
  final String category;
  final int duration; // minutes
  final String format; // online, in-person, hybrid
  final String provider;
  final double credits;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final List<String> learningObjectives;
  final List<String> prerequisites;
  final Map<String, dynamic> metadata;

  ContinuingEducation({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAudience,
    required this.category,
    required this.duration,
    required this.format,
    required this.provider,
    required this.credits,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.learningObjectives,
    required this.prerequisites,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAudience': targetAudience.map((e) => e.name).toList(),
      'category': category,
      'duration': duration,
      'format': format,
      'provider': provider,
      'credits': credits,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'learningObjectives': learningObjectives,
      'prerequisites': prerequisites,
      'metadata': metadata,
    };
  }

  factory ContinuingEducation.fromJson(Map<String, dynamic> json) {
    return ContinuingEducation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetAudience: (json['targetAudience'] as List).map((e) => ProfessionalType.values.firstWhere((t) => t.name == e)).toList(),
      category: json['category'],
      duration: json['duration'],
      format: json['format'],
      provider: json['provider'],
      credits: json['credits'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'],
      learningObjectives: List<String>.from(json['learningObjectives']),
      prerequisites: List<String>.from(json['prerequisites']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class ProfessionalDevelopment {
  final String id;
  final String professionalId;
  final String educationId;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final String status;
  final double? score;
  final String? certificate;
  final Map<String, dynamic> progress;
  final Map<String, dynamic> metadata;

  ProfessionalDevelopment({
    required this.id,
    required this.professionalId,
    required this.educationId,
    required this.enrolledAt,
    this.completedAt,
    required this.status,
    this.score,
    this.certificate,
    this.progress = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'educationId': educationId,
      'enrolledAt': enrolledAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status,
      'score': score,
      'certificate': certificate,
      'progress': progress,
      'metadata': metadata,
    };
  }

  factory ProfessionalDevelopment.fromJson(Map<String, dynamic> json) {
    return ProfessionalDevelopment(
      id: json['id'],
      professionalId: json['professionalId'],
      educationId: json['educationId'],
      enrolledAt: DateTime.parse(json['enrolledAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      status: json['status'],
      score: json['score']?.toDouble(),
      certificate: json['certificate'],
      progress: json['progress'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }
}

class ResearchCollaboration {
  final String id;
  final String title;
  final String description;
  final List<String> researcherIds;
  final String principalInvestigatorId;
  final String researchType;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> objectives;
  final List<String> methodologies;
  final Map<String, dynamic> results;
  final List<String> publications;
  final Map<String, dynamic> metadata;

  ResearchCollaboration({
    required this.id,
    required this.title,
    required this.description,
    required this.researcherIds,
    required this.principalInvestigatorId,
    required this.researchType,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.objectives,
    required this.methodologies,
    this.results = const {},
    this.publications = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'researcherIds': researcherIds,
      'principalInvestigatorId': principalInvestigatorId,
      'researchType': researchType,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'objectives': objectives,
      'methodologies': methodologies,
      'results': results,
      'publications': publications,
      'metadata': metadata,
    };
  }

  factory ResearchCollaboration.fromJson(Map<String, dynamic> json) {
    return ResearchCollaboration(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      researcherIds: List<String>.from(json['researcherIds']),
      principalInvestigatorId: json['principalInvestigatorId'],
      researchType: json['researchType'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      objectives: List<String>.from(json['objectives']),
      methodologies: List<String>.from(json['methodologies']),
      results: json['results'] ?? {},
      publications: List<String>.from(json['publications'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }
}
