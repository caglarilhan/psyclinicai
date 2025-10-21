import 'package:flutter/foundation.dart';

enum PatientStatus { active, inactive, discharged, transferred, deceased }
enum DocumentType { id, insurance, medicalReport, prescription, labResult, image, other }
enum RecordType { personal, medical, insurance, emergency, family, legal }
enum PriorityLevel { low, normal, high, urgent }

class PatientRecord {
  final String id;
  final String patientId;
  final String secretaryId;
  final RecordType type;
  final String title;
  final String content;
  final Map<String, dynamic>? metadata;
  final PriorityLevel priority;
  final bool isConfidential;
  final DateTime createdAt;
  DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final List<PatientDocument> documents;
  final List<RecordHistory> history;

  PatientRecord({
    required this.id,
    required this.patientId,
    required this.secretaryId,
    required this.type,
    required this.title,
    required this.content,
    this.metadata,
    this.priority = PriorityLevel.normal,
    this.isConfidential = false,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.documents = const [],
    this.history = const [],
  });

  PatientRecord copyWith({
    String? id,
    String? patientId,
    String? secretaryId,
    RecordType? type,
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
    PriorityLevel? priority,
    bool? isConfidential,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    List<PatientDocument>? documents,
    List<RecordHistory>? history,
  }) {
    return PatientRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      secretaryId: secretaryId ?? this.secretaryId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      isConfidential: isConfidential ?? this.isConfidential,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      documents: documents ?? this.documents,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'secretaryId': secretaryId,
      'type': type.toString().split('.').last,
      'title': title,
      'content': content,
      'metadata': metadata,
      'priority': priority.toString().split('.').last,
      'isConfidential': isConfidential,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }

  factory PatientRecord.fromJson(Map<String, dynamic> json) {
    return PatientRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      secretaryId: json['secretaryId'] as String,
      type: RecordType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      priority: PriorityLevel.values.firstWhere(
          (e) => e.toString().split('.').last == json['priority'] as String),
      isConfidential: json['isConfidential'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      documents: (json['documents'] as List)
          .map((doc) => PatientDocument.fromJson(doc as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List)
          .map((h) => RecordHistory.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PatientDocument {
  final String id;
  final String patientId;
  final String recordId;
  final DocumentType type;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final String? description;
  final bool isEncrypted;
  final DateTime uploadedAt;
  final String uploadedBy;
  final Map<String, dynamic>? metadata;

  PatientDocument({
    required this.id,
    required this.patientId,
    required this.recordId,
    required this.type,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    this.description,
    this.isEncrypted = false,
    required this.uploadedAt,
    required this.uploadedBy,
    this.metadata,
  });

  PatientDocument copyWith({
    String? id,
    String? patientId,
    String? recordId,
    DocumentType? type,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    String? description,
    bool? isEncrypted,
    DateTime? uploadedAt,
    String? uploadedBy,
    Map<String, dynamic>? metadata,
  }) {
    return PatientDocument(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      recordId: recordId ?? this.recordId,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      description: description ?? this.description,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'recordId': recordId,
      'type': type.toString().split('.').last,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'description': description,
      'isEncrypted': isEncrypted,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'metadata': metadata,
    };
  }

  factory PatientDocument.fromJson(Map<String, dynamic> json) {
    return PatientDocument(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      recordId: json['recordId'] as String,
      type: DocumentType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
      description: json['description'] as String?,
      isEncrypted: json['isEncrypted'] as bool,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      uploadedBy: json['uploadedBy'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class RecordHistory {
  final String id;
  final String recordId;
  final String action;
  final String? description;
  final String performedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  RecordHistory({
    required this.id,
    required this.recordId,
    required this.action,
    this.description,
    required this.performedBy,
    required this.timestamp,
    this.metadata,
  });

  RecordHistory copyWith({
    String? id,
    String? recordId,
    String? action,
    String? description,
    String? performedBy,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return RecordHistory(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      description: description ?? this.description,
      performedBy: performedBy ?? this.performedBy,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordId': recordId,
      'action': action,
      'description': description,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory RecordHistory.fromJson(Map<String, dynamic> json) {
    return RecordHistory(
      id: json['id'] as String,
      recordId: json['recordId'] as String,
      action: json['action'] as String,
      description: json['description'] as String?,
      performedBy: json['performedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class RecordTemplate {
  final String id;
  final String name;
  final RecordType type;
  final String description;
  final Map<String, dynamic> fields;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;
  final int usageCount;

  RecordTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.fields,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
    this.usageCount = 0,
  });

  RecordTemplate copyWith({
    String? id,
    String? name,
    RecordType? type,
    String? description,
    Map<String, dynamic>? fields,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
    int? usageCount,
  }) {
    return RecordTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'fields': fields,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'usageCount': usageCount,
    };
  }

  factory RecordTemplate.fromJson(Map<String, dynamic> json) {
    return RecordTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      type: RecordType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      description: json['description'] as String,
      fields: json['fields'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      usageCount: json['usageCount'] as int,
    );
  }
}

class PatientSearchCriteria {
  final String? name;
  final String? idNumber;
  final String? phone;
  final String? email;
  final PatientStatus? status;
  final DateTime? birthDateFrom;
  final DateTime? birthDateTo;
  final DateTime? registrationDateFrom;
  final DateTime? registrationDateTo;
  final RecordType? recordType;
  final PriorityLevel? priority;
  final bool? isConfidential;

  PatientSearchCriteria({
    this.name,
    this.idNumber,
    this.phone,
    this.email,
    this.status,
    this.birthDateFrom,
    this.birthDateTo,
    this.registrationDateFrom,
    this.registrationDateTo,
    this.recordType,
    this.priority,
    this.isConfidential,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'idNumber': idNumber,
      'phone': phone,
      'email': email,
      'status': status?.toString().split('.').last,
      'birthDateFrom': birthDateFrom?.toIso8601String(),
      'birthDateTo': birthDateTo?.toIso8601String(),
      'registrationDateFrom': registrationDateFrom?.toIso8601String(),
      'registrationDateTo': registrationDateTo?.toIso8601String(),
      'recordType': recordType?.toString().split('.').last,
      'priority': priority?.toString().split('.').last,
      'isConfidential': isConfidential,
    };
  }
}
