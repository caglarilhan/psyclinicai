/// Senior-architect rapor 12 §3 finding: the workspace was missing
/// an Inbox/Tasks toplevel where patient messages, lab results, team
/// notes and overdue work converge.
enum InboxItemKind {
  patientMessage('patient_message', 'Patient message'),
  labResult('lab_result', 'Lab result'),
  teamNote('team_note', 'Team note'),
  task('task', 'Task');

  const InboxItemKind(this.id, this.label);
  final String id;
  final String label;

  static InboxItemKind fromId(String id) =>
      values.firstWhere((k) => k.id == id,
          orElse: () => InboxItemKind.teamNote);
}

class InboxItem {
  const InboxItem({
    required this.id,
    required this.kind,
    required this.fromUid,
    required this.subject,
    required this.bodyPreview,
    required this.receivedAt,
    this.subjectPatientId,
    this.readAt,
    this.dueAt,
  });

  final String id;
  final InboxItemKind kind;
  final String fromUid;
  final String subject;

  /// First ~200 chars of the body. Full content lives behind a
  /// patient-chart deep-link; the inbox only carries the preview.
  final String bodyPreview;
  final DateTime receivedAt;
  final String? subjectPatientId;
  final DateTime? readAt;
  final DateTime? dueAt;

  bool get unread => readAt == null;

  bool isOverdue({DateTime? at}) {
    final due = dueAt;
    if (due == null) return false;
    return (at ?? DateTime.now()).isAfter(due) && readAt == null;
  }

  InboxItem markRead(DateTime at) => InboxItem(
        id: id,
        kind: kind,
        fromUid: fromUid,
        subject: subject,
        bodyPreview: bodyPreview,
        receivedAt: receivedAt,
        subjectPatientId: subjectPatientId,
        readAt: at,
        dueAt: dueAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.id,
        'from_uid': fromUid,
        'subject': subject,
        'body_preview': bodyPreview,
        'received_at': receivedAt.toUtc().toIso8601String(),
        if (subjectPatientId != null)
          'subject_patient_id': subjectPatientId,
        if (readAt != null) 'read_at': readAt!.toUtc().toIso8601String(),
        if (dueAt != null) 'due_at': dueAt!.toUtc().toIso8601String(),
      };

  factory InboxItem.fromJson(Map<String, dynamic> json) {
    return InboxItem(
      id: json['id'] as String,
      kind: InboxItemKind.fromId(json['kind'] as String? ?? 'team_note'),
      fromUid: json['from_uid'] as String,
      subject: json['subject'] as String,
      bodyPreview: json['body_preview'] as String,
      receivedAt: DateTime.parse(json['received_at'] as String),
      subjectPatientId: json['subject_patient_id'] as String?,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      dueAt: json['due_at'] != null
          ? DateTime.parse(json['due_at'] as String)
          : null,
    );
  }
}
