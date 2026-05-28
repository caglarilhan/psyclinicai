/// A finished session note persisted locally per patient. This is the raw
/// material the Clinical Memory brief synthesizes — every note written makes
/// the next pre-session brief richer (the continuity flywheel).
class SessionNote {
  SessionNote({
    required this.id,
    required this.patientId,
    required this.markdown,
    this.format = 'soap',
    this.flaggedRisk = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String patientId;
  final String markdown;
  final String format;
  final bool flaggedRisk;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'markdown': markdown,
        'format': format,
        'flaggedRisk': flaggedRisk,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SessionNote.fromJson(Map<String, dynamic> json) => SessionNote(
        id: json['id'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        markdown: json['markdown'] as String? ?? '',
        format: json['format'] as String? ?? 'soap',
        flaggedRisk: json['flaggedRisk'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );
}
