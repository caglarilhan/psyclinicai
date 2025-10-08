import 'package:flutter/foundation.dart';

class TherapyNoteTemplate {
  final String id;
  final String name;
  final String description;
  final List<TherapyNoteField> fields;

  const TherapyNoteTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.fields,
  });
}

class TherapyNoteField {
  final String key;
  final String label;
  final NoteFieldType type;

  const TherapyNoteField({
    required this.key,
    required this.label,
    required this.type,
  });
}

enum NoteFieldType { text, longText, checklist }

class TherapyNoteEntry {
  final String id;
  final String sessionId;
  final String clinicianId;
  final String clientId;
  final String templateId;
  final Map<String, dynamic> values;
  final DateTime createdAt;

  TherapyNoteEntry({
    required this.id,
    required this.sessionId,
    required this.clinicianId,
    required this.clientId,
    required this.templateId,
    required this.values,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'clinicianId': clinicianId,
      'clientId': clientId,
      'templateId': templateId,
      'values': values,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TherapyNoteEntry.fromJson(Map<String, dynamic> json) {
    return TherapyNoteEntry(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      clinicianId: json['clinicianId'] as String,
      clientId: json['clientId'] as String,
      templateId: json['templateId'] as String,
      values: Map<String, dynamic>.from(json['values'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
