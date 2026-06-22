/// A between-session homework assignment for a patient — the client-facing end
/// of the golden thread (goal → in-session work → homework → next session).
class HomeworkItem {
  factory HomeworkItem.fromJson(Map<String, dynamic> json) => HomeworkItem(
    id: json['id'] as String,
    patientId: json['patientId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    note: json['note'] as String? ?? '',
    dueDate:
        DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
    done: json['done'] as bool? ?? false,
    linkedGoal: json['linkedGoal'] as String?,
  );
  HomeworkItem({
    required this.id,
    required this.patientId,
    required this.title,
    this.note = '',
    required this.dueDate,
    this.done = false,
    this.linkedGoal,
  });

  final String id;
  final String patientId;
  final String title;
  final String note;
  final DateTime dueDate;
  final bool done;

  /// Optional treatment-plan goal text this homework supports.
  final String? linkedGoal;

  HomeworkItem copyWith({bool? done}) => HomeworkItem(
    id: id,
    patientId: patientId,
    title: title,
    note: note,
    dueDate: dueDate,
    done: done ?? this.done,
    linkedGoal: linkedGoal,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'title': title,
    'note': note,
    'dueDate': dueDate.toIso8601String(),
    'done': done,
    'linkedGoal': linkedGoal,
  };
}
