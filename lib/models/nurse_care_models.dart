import 'package:flutter/foundation.dart';

enum CarePriority { low, medium, high, critical }
enum CareStatus { planned, inProgress, completed, cancelled, overdue }
enum VitalSignType { bloodPressure, heartRate, temperature, respiratoryRate, oxygenSaturation, weight, height }

class CarePlan {
  final String id;
  final String patientId;
  final String nurseId;
  final String title;
  final String description;
  final CarePriority priority;
  final DateTime startDate;
  final DateTime? endDate;
  CareStatus status;
  final List<CareTask> tasks;
  final String? notes;
  final DateTime createdAt;
  DateTime? lastUpdatedAt;

  CarePlan({
    required this.id,
    required this.patientId,
    required this.nurseId,
    required this.title,
    required this.description,
    required this.priority,
    required this.startDate,
    this.endDate,
    this.status = CareStatus.planned,
    this.tasks = const [],
    this.notes,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  CarePlan copyWith({
    String? id,
    String? patientId,
    String? nurseId,
    String? title,
    String? description,
    CarePriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    CareStatus? status,
    List<CareTask>? tasks,
    String? notes,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return CarePlan(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'nurseId': nurseId,
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory CarePlan.fromJson(Map<String, dynamic> json) {
    return CarePlan(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      nurseId: json['nurseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: CarePriority.values.firstWhere(
          (e) => e.toString().split('.').last == json['priority'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: CareStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      tasks: (json['tasks'] as List)
          .map((task) => CareTask.fromJson(task as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
    );
  }
}

class CareTask {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final DateTime? completedTime;
  CareStatus status;
  final String? notes;
  final String? completedBy;

  CareTask({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.completedTime,
    this.status = CareStatus.planned,
    this.notes,
    this.completedBy,
  });

  CareTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    DateTime? completedTime,
    CareStatus? status,
    String? notes,
    String? completedBy,
  }) {
    return CareTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedTime: completedTime ?? this.completedTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      completedBy: completedBy ?? this.completedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'completedBy': completedBy,
    };
  }

  factory CareTask.fromJson(Map<String, dynamic> json) {
    return CareTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'] as String)
          : null,
      status: CareStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      notes: json['notes'] as String?,
      completedBy: json['completedBy'] as String?,
    );
  }
}

class VitalSignsRecord {
  final String id;
  final String patientId;
  final String nurseId;
  final DateTime recordedAt;
  final Map<VitalSignType, String> values;
  final String? notes;
  final bool isAbnormal;

  VitalSignsRecord({
    required this.id,
    required this.patientId,
    required this.nurseId,
    required this.recordedAt,
    required this.values,
    this.notes,
    this.isAbnormal = false,
  });

  VitalSignsRecord copyWith({
    String? id,
    String? patientId,
    String? nurseId,
    DateTime? recordedAt,
    Map<VitalSignType, String>? values,
    String? notes,
    bool? isAbnormal,
  }) {
    return VitalSignsRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      recordedAt: recordedAt ?? this.recordedAt,
      values: values ?? this.values,
      notes: notes ?? this.notes,
      isAbnormal: isAbnormal ?? this.isAbnormal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'nurseId': nurseId,
      'recordedAt': recordedAt.toIso8601String(),
      'values': values.map((key, value) => MapEntry(key.toString().split('.').last, value)),
      'notes': notes,
      'isAbnormal': isAbnormal,
    };
  }

  factory VitalSignsRecord.fromJson(Map<String, dynamic> json) {
    final valuesMap = <VitalSignType, String>{};
    final valuesJson = json['values'] as Map<String, dynamic>;
    
    for (final entry in valuesJson.entries) {
      final type = VitalSignType.values.firstWhere(
          (e) => e.toString().split('.').last == entry.key);
      valuesMap[type] = entry.value as String;
    }

    return VitalSignsRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      nurseId: json['nurseId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      values: valuesMap,
      notes: json['notes'] as String?,
      isAbnormal: json['isAbnormal'] as bool,
    );
  }
}

class MedicationAdherence {
  final String id;
  final String patientId;
  final String nurseId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final DateTime prescribedDate;
  final DateTime? lastTakenDate;
  final int adherencePercentage;
  final List<MedicationEvent> events;
  final String? notes;

  MedicationAdherence({
    required this.id,
    required this.patientId,
    required this.nurseId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.prescribedDate,
    this.lastTakenDate,
    required this.adherencePercentage,
    this.events = const [],
    this.notes,
  });

  MedicationAdherence copyWith({
    String? id,
    String? patientId,
    String? nurseId,
    String? medicationName,
    String? dosage,
    String? frequency,
    DateTime? prescribedDate,
    DateTime? lastTakenDate,
    int? adherencePercentage,
    List<MedicationEvent>? events,
    String? notes,
  }) {
    return MedicationAdherence(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      prescribedDate: prescribedDate ?? this.prescribedDate,
      lastTakenDate: lastTakenDate ?? this.lastTakenDate,
      adherencePercentage: adherencePercentage ?? this.adherencePercentage,
      events: events ?? this.events,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'nurseId': nurseId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'prescribedDate': prescribedDate.toIso8601String(),
      'lastTakenDate': lastTakenDate?.toIso8601String(),
      'adherencePercentage': adherencePercentage,
      'events': events.map((event) => event.toJson()).toList(),
      'notes': notes,
    };
  }

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) {
    return MedicationAdherence(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      nurseId: json['nurseId'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      prescribedDate: DateTime.parse(json['prescribedDate'] as String),
      lastTakenDate: json['lastTakenDate'] != null
          ? DateTime.parse(json['lastTakenDate'] as String)
          : null,
      adherencePercentage: json['adherencePercentage'] as int,
      events: (json['events'] as List)
          .map((event) => MedicationEvent.fromJson(event as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

class MedicationEvent {
  final String id;
  final DateTime eventDate;
  final bool wasTaken;
  final String? notes;
  final String? recordedBy;

  MedicationEvent({
    required this.id,
    required this.eventDate,
    required this.wasTaken,
    this.notes,
    this.recordedBy,
  });

  MedicationEvent copyWith({
    String? id,
    DateTime? eventDate,
    bool? wasTaken,
    String? notes,
    String? recordedBy,
  }) {
    return MedicationEvent(
      id: id ?? this.id,
      eventDate: eventDate ?? this.eventDate,
      wasTaken: wasTaken ?? this.wasTaken,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventDate': eventDate.toIso8601String(),
      'wasTaken': wasTaken,
      'notes': notes,
      'recordedBy': recordedBy,
    };
  }

  factory MedicationEvent.fromJson(Map<String, dynamic> json) {
    return MedicationEvent(
      id: json['id'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      wasTaken: json['wasTaken'] as bool,
      notes: json['notes'] as String?,
      recordedBy: json['recordedBy'] as String?,
    );
  }
}

class CareNote {
  final String id;
  final String patientId;
  final String nurseId;
  final DateTime noteDate;
  final String content;
  final CarePriority priority;
  final String? category;
  final bool isUrgent;

  CareNote({
    required this.id,
    required this.patientId,
    required this.nurseId,
    required this.noteDate,
    required this.content,
    required this.priority,
    this.category,
    this.isUrgent = false,
  });

  CareNote copyWith({
    String? id,
    String? patientId,
    String? nurseId,
    DateTime? noteDate,
    String? content,
    CarePriority? priority,
    String? category,
    bool? isUrgent,
  }) {
    return CareNote(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      noteDate: noteDate ?? this.noteDate,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'nurseId': nurseId,
      'noteDate': noteDate.toIso8601String(),
      'content': content,
      'priority': priority.toString().split('.').last,
      'category': category,
      'isUrgent': isUrgent,
    };
  }

  factory CareNote.fromJson(Map<String, dynamic> json) {
    return CareNote(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      nurseId: json['nurseId'] as String,
      noteDate: DateTime.parse(json['noteDate'] as String),
      content: json['content'] as String,
      priority: CarePriority.values.firstWhere(
          (e) => e.toString().split('.').last == json['priority'] as String),
      category: json['category'] as String?,
      isUrgent: json['isUrgent'] as bool,
    );
  }
}

class EmergencyProtocol {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final CarePriority priority;
  final String? category;
  final DateTime createdAt;
  final String createdBy;

  EmergencyProtocol({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.priority,
    this.category,
    required this.createdAt,
    required this.createdBy,
  });

  EmergencyProtocol copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? steps,
    CarePriority? priority,
    String? category,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return EmergencyProtocol(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps,
      'priority': priority.toString().split('.').last,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory EmergencyProtocol.fromJson(Map<String, dynamic> json) {
    return EmergencyProtocol(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: List<String>.from(json['steps'] as List),
      priority: CarePriority.values.firstWhere(
          (e) => e.toString().split('.').last == json['priority'] as String),
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }
}
