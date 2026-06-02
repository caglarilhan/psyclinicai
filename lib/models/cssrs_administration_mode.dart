/// CSSRS administration mode. Posner et al. (2011) ship two validated
/// variants: clinician-administered and self-rated. They share the
/// item bank but differ in instructions, prompts and scoring
/// thresholds — surfacing one UI for both is unsafe.
enum CssrsAdministrationMode {
  clinicianAdministered(
    id: 'clinician',
    label: 'Clinician administered',
    instructions:
        'Ask each question in the patient\'s own language. Items 1-5 '
        'refer to the past month; item 6 covers lifetime and the past '
        'three months.',
  ),

  selfRated(
    id: 'self',
    label: 'Patient self-rated',
    instructions:
        'These questions ask about thoughts you may have had. Please '
        'answer honestly — your clinician will review your responses '
        'after you submit.',
  );

  const CssrsAdministrationMode({
    required this.id,
    required this.label,
    required this.instructions,
  });

  final String id;
  final String label;
  final String instructions;

  /// Escalation threshold for "positive ideation" varies by mode.
  /// Clinician interview Q4/Q5 (active ideation with method/plan)
  /// triggers immediate safety planning. Self-rated uses Q3+ because
  /// item 4/5 collateral information is missing.
  int get escalationItem => switch (this) {
        CssrsAdministrationMode.clinicianAdministered => 4,
        CssrsAdministrationMode.selfRated => 3,
      };

  static CssrsAdministrationMode fromId(String id) =>
      values.firstWhere((m) => m.id == id,
          orElse: () => CssrsAdministrationMode.clinicianAdministered);
}
