class HomeworkTemplate {
  final String id;
  final String title;
  final String description;

  const HomeworkTemplate({
    required this.id,
    required this.title,
    required this.description,
  });
}

class HomeworkAssignment {
  final String id;
  final String clientId;
  final String clinicianId;
  final String templateId;
  final String customInstructions;
  final DateTime assignedAt;
  final DateTime? dueDate;
  final bool completed;

  HomeworkAssignment({
    required this.id,
    required this.clientId,
    required this.clinicianId,
    required this.templateId,
    required this.customInstructions,
    required this.assignedAt,
    this.dueDate,
    this.completed = false,
  });
}
