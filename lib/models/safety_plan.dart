/// A collaborative crisis safety plan (Stanley-Brown Safety Planning
/// Intervention structure). Decision-support scaffold the clinician completes
/// WITH the client — not a substitute for clinical risk assessment.
class SafetyPlan {
  factory SafetyPlan.fromJson(Map<String, dynamic> json) => SafetyPlan(
    patientId: json['patientId'] as String? ?? '',
    warningSigns: _strList(json['warningSigns']),
    copingStrategies: _strList(json['copingStrategies']),
    socialDistractions: _strList(json['socialDistractions']),
    supportContacts: _strList(json['supportContacts']),
    professionals: _strList(json['professionals']),
    crisisLines: _strList(json['crisisLines']),
    reasonsForLiving: _strList(json['reasonsForLiving']),
    meansSafety: json['meansSafety'] as String? ?? '',
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
  );
  SafetyPlan({
    required this.patientId,
    this.warningSigns = const [],
    this.copingStrategies = const [],
    this.socialDistractions = const [],
    this.supportContacts = const [],
    this.professionals = const [],
    this.crisisLines = const [],
    this.reasonsForLiving = const [],
    this.meansSafety = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String patientId;

  /// Step 1 — warning signs (thoughts/feelings/behaviors that precede crisis).
  final List<String> warningSigns;

  /// Step 2 — internal coping strategies (things I can do on my own).
  final List<String> copingStrategies;

  /// Step 3 — people and social settings that provide distraction.
  final List<String> socialDistractions;

  /// Step 4 — people I can ask for help (name + contact).
  final List<String> supportContacts;

  /// Step 5 — professionals/agencies to contact (incl. my clinician).
  final List<String> professionals;

  /// Step 6 — crisis lines / emergency.
  final List<String> crisisLines;

  /// Optional, evidence-supported extension (Brown & Stanley, 2012). A short
  /// list the client generates of reasons to keep living — often surfaced
  /// during de-escalation. Empty by default for legacy plans.
  final List<String> reasonsForLiving;

  /// Step 7 — making the environment safe (means restriction).
  final String meansSafety;

  final DateTime updatedAt;

  bool get isEmpty =>
      warningSigns.isEmpty &&
      copingStrategies.isEmpty &&
      socialDistractions.isEmpty &&
      supportContacts.isEmpty &&
      professionals.isEmpty &&
      crisisLines.isEmpty &&
      reasonsForLiving.isEmpty &&
      meansSafety.isEmpty;

  /// Clinical completeness floor — Stanley-Brown intent. A plan is
  /// considered clinically usable when at minimum it has:
  ///   • ≥1 warning sign,
  ///   • ≥1 internal coping strategy,
  ///   • ≥1 person OR professional the patient can contact for help,
  ///   • ≥1 crisis line / emergency contact.
  ///
  /// We surface this from the save action so a clinician does not
  /// persist a half-finished plan and walk out of the room thinking
  /// they did. The getter never blocks save by itself — the UI uses
  /// it to render a soft warning and ask for confirmation.
  bool get isClinicallyComplete {
    final hasContactToReach =
        supportContacts.isNotEmpty || professionals.isNotEmpty;
    return warningSigns.isNotEmpty &&
        copingStrategies.isNotEmpty &&
        hasContactToReach &&
        crisisLines.isNotEmpty;
  }

  /// Sections that are still empty according to [isClinicallyComplete].
  /// The save dialog uses this to show the clinician exactly which
  /// blocks still need an entry. Stable lower-case keys so localisation
  /// keys can map onto them.
  List<String> get missingClinicalSections {
    final out = <String>[];
    if (warningSigns.isEmpty) out.add('warning_signs');
    if (copingStrategies.isEmpty) out.add('coping_strategies');
    if (supportContacts.isEmpty && professionals.isEmpty) {
      out.add('people_to_reach');
    }
    if (crisisLines.isEmpty) out.add('crisis_lines');
    return out;
  }

  SafetyPlan copyWith({
    List<String>? warningSigns,
    List<String>? copingStrategies,
    List<String>? socialDistractions,
    List<String>? supportContacts,
    List<String>? professionals,
    List<String>? crisisLines,
    List<String>? reasonsForLiving,
    String? meansSafety,
  }) => SafetyPlan(
    patientId: patientId,
    warningSigns: warningSigns ?? this.warningSigns,
    copingStrategies: copingStrategies ?? this.copingStrategies,
    socialDistractions: socialDistractions ?? this.socialDistractions,
    supportContacts: supportContacts ?? this.supportContacts,
    professionals: professionals ?? this.professionals,
    crisisLines: crisisLines ?? this.crisisLines,
    reasonsForLiving: reasonsForLiving ?? this.reasonsForLiving,
    meansSafety: meansSafety ?? this.meansSafety,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'warningSigns': warningSigns,
    'copingStrategies': copingStrategies,
    'socialDistractions': socialDistractions,
    'supportContacts': supportContacts,
    'professionals': professionals,
    'crisisLines': crisisLines,
    'reasonsForLiving': reasonsForLiving,
    'meansSafety': meansSafety,
    'updatedAt': updatedAt.toIso8601String(),
  };

  static List<String> _strList(dynamic v) =>
      (v as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
}
