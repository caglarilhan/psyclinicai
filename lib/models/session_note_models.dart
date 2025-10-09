import 'dart:convert';

enum SessionNoteStatus { draft, locked, archived }
enum SessionNoteType { soap, dap, emdr, cbt, general }

class SessionNote {
  final String id;
  final String sessionId;
  final String clientId;
  final String therapistId;
  final SessionNoteType type;
  final String content;
  final SessionNoteStatus status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lockedAt;
  final String? lockedBy;
  final List<SessionNoteAttachment> attachments;
  final Map<String, dynamic> metadata;

  SessionNote({
    required this.id,
    required this.sessionId,
    required this.clientId,
    required this.therapistId,
    required this.type,
    required this.content,
    this.status = SessionNoteStatus.draft,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.lockedAt,
    this.lockedBy,
    this.attachments = const [],
    this.metadata = const {},
  });

  SessionNote copyWith({
    String? id,
    String? sessionId,
    String? clientId,
    String? therapistId,
    SessionNoteType? type,
    String? content,
    SessionNoteStatus? status,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lockedAt,
    String? lockedBy,
    List<SessionNoteAttachment>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return SessionNote(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      clientId: clientId ?? this.clientId,
      therapistId: therapistId ?? this.therapistId,
      type: type ?? this.type,
      content: content ?? this.content,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lockedAt: lockedAt ?? this.lockedAt,
      lockedBy: lockedBy ?? this.lockedBy,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'clientId': clientId,
      'therapistId': therapistId,
      'type': type.name,
      'content': content,
      'status': status.name,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lockedAt': lockedAt?.toIso8601String(),
      'lockedBy': lockedBy,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory SessionNote.fromJson(Map<String, dynamic> json) {
    return SessionNote(
      id: json['id'],
      sessionId: json['sessionId'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      type: SessionNoteType.values.firstWhere((e) => e.name == json['type']),
      content: json['content'],
      status: SessionNoteStatus.values.firstWhere((e) => e.name == json['status']),
      version: json['version'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lockedAt: json['lockedAt'] != null ? DateTime.parse(json['lockedAt']) : null,
      lockedBy: json['lockedBy'],
      attachments: (json['attachments'] as List?)
          ?.map((a) => SessionNoteAttachment.fromJson(a))
          .toList() ?? [],
      metadata: json['metadata'] ?? {},
    );
  }
}

class SessionNoteAttachment {
  final String id;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int fileSize;
  final DateTime uploadedAt;

  SessionNoteAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory SessionNoteAttachment.fromJson(Map<String, dynamic> json) {
    return SessionNoteAttachment(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      mimeType: json['mimeType'],
      fileSize: json['fileSize'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

class SessionNoteTemplate {
  final String id;
  final String name;
  final SessionNoteType type;
  final String content;
  final bool isDefault;
  final DateTime createdAt;

  SessionNoteTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'content': content,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SessionNoteTemplate.fromJson(Map<String, dynamic> json) {
    return SessionNoteTemplate(
      id: json['id'],
      name: json['name'],
      type: SessionNoteType.values.firstWhere((e) => e.name == json['type']),
      content: json['content'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class SessionNoteVersion {
  final String id;
  final String noteId;
  final int version;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  final String changeDescription;

  SessionNoteVersion({
    required this.id,
    required this.noteId,
    required this.version,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    required this.changeDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'version': version,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'changeDescription': changeDescription,
    };
  }

  factory SessionNoteVersion.fromJson(Map<String, dynamic> json) {
    return SessionNoteVersion(
      id: json['id'],
      noteId: json['noteId'],
      version: json['version'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      changeDescription: json['changeDescription'],
    );
  }
}