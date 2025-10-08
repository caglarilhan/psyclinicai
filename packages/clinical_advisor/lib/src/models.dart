class ClinicalInput {
  final String role; // psychologist | psychiatrist
  final String region; // TR | EU | US | UK ...
  final String summary; // free text symptoms/complaints
  final List<String> tags; // optional structured flags

  ClinicalInput({
    required this.role,
    required this.region,
    required this.summary,
    this.tags = const [],
  });
}

class AdviceItem {
  final String title;
  final String detail;
  const AdviceItem({required this.title, required this.detail});
}

class AdvicePlan {
  final List<String> probableCategories; // e.g., Bipolar, GAD
  final List<String> redFlags; // suicide, mania, psychosis
  final List<AdviceItem> psychoeducation;
  final List<AdviceItem> psychotherapy;
  final List<AdviceItem> monitoring;
  final List<AdviceItem> pharmacology; // only as informational for psychiatrists

  const AdvicePlan({
    this.probableCategories = const [],
    this.redFlags = const [],
    this.psychoeducation = const [],
    this.psychotherapy = const [],
    this.monitoring = const [],
    this.pharmacology = const [],
  });
}

class DisorderSummary {
  final String id;
  final String name;
  const DisorderSummary({required this.id, required this.name});
}

