import 'consent_record.dart';

/// A baseline patient intake captured before the first clinical session.
///
/// This is intentionally a minimum-viable form — enough to make the first
/// session safer (allergies, current meds, recent risk) and to anchor the
/// consent record. Detailed history will be expanded over follow-up
/// sessions in the chart proper.
///
/// All fields are private health information (PHI). Persistence is
/// local-first via [IntakeRepository] (SharedPreferences); Firestore
/// sync stays opt-in until BAA-bound region routing lands.
class PatientIntake {
  PatientIntake({
    required this.patientId,
    this.fullName = '',
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.email,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.presentingConcern = '',
    this.allergies = const [],
    this.currentMedications = const [],
    this.medicalHistory = '',
    this.mentalHealthHistory = '',
    this.substanceUse = '',
    this.priorSuicideAttempt = false,
    this.priorSelfHarm = false,
    this.consent,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory PatientIntake.fromJson(Map<String, dynamic> json) => PatientIntake(
        patientId: json['patientId'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? ''),
        gender: json['gender'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        emergencyContactName: json['emergencyContactName'] as String?,
        emergencyContactPhone: json['emergencyContactPhone'] as String?,
        presentingConcern: json['presentingConcern'] as String? ?? '',
        allergies: _strList(json['allergies']),
        currentMedications: _strList(json['currentMedications']),
        medicalHistory: json['medicalHistory'] as String? ?? '',
        mentalHealthHistory: json['mentalHealthHistory'] as String? ?? '',
        substanceUse: json['substanceUse'] as String? ?? '',
        priorSuicideAttempt: json['priorSuicideAttempt'] as bool? ?? false,
        priorSelfHarm: json['priorSelfHarm'] as bool? ?? false,
        consent: json['consent'] is Map<String, dynamic>
            ? ConsentRecord.fromJson(json['consent'] as Map<String, dynamic>)
            : null,
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      );

  final String patientId;

  // ─────────── Demographics ───────────
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? email;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  // ─────────── Clinical ───────────
  final String presentingConcern;
  final List<String> allergies;
  final List<String> currentMedications;
  final String medicalHistory;
  final String mentalHealthHistory;
  final String substanceUse;

  // ─────────── Safety screening ───────────
  /// Any prior suicide attempt, lifetime. A "yes" should always be paired
  /// with a follow-up C-SSRS during the first clinical session.
  final bool priorSuicideAttempt;
  final bool priorSelfHarm;

  // ─────────── Consent ───────────
  final ConsentRecord? consent;

  /// Last write timestamp (UTC ISO-8601 on disk).
  final DateTime updatedAt;

  /// A minimal intake is considered complete when the demographics block
  /// has a name, the presenting concern is filled in, and a valid consent
  /// record is attached. The session screen blocks new notes until this is
  /// `true`.
  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      presentingConcern.trim().isNotEmpty &&
      (consent?.isValid ?? false);

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'fullName': fullName,
        if (dateOfBirth != null)
          'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (gender != null) 'gender': gender,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (emergencyContactName != null)
          'emergencyContactName': emergencyContactName,
        if (emergencyContactPhone != null)
          'emergencyContactPhone': emergencyContactPhone,
        'presentingConcern': presentingConcern,
        'allergies': allergies,
        'currentMedications': currentMedications,
        'medicalHistory': medicalHistory,
        'mentalHealthHistory': mentalHealthHistory,
        'substanceUse': substanceUse,
        'priorSuicideAttempt': priorSuicideAttempt,
        'priorSelfHarm': priorSelfHarm,
        if (consent != null) 'consent': consent!.toJson(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  PatientIntake copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? email,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? presentingConcern,
    List<String>? allergies,
    List<String>? currentMedications,
    String? medicalHistory,
    String? mentalHealthHistory,
    String? substanceUse,
    bool? priorSuicideAttempt,
    bool? priorSelfHarm,
    ConsentRecord? consent,
  }) =>
      PatientIntake(
        patientId: patientId,
        fullName: fullName ?? this.fullName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        emergencyContactName:
            emergencyContactName ?? this.emergencyContactName,
        emergencyContactPhone:
            emergencyContactPhone ?? this.emergencyContactPhone,
        presentingConcern: presentingConcern ?? this.presentingConcern,
        allergies: allergies ?? this.allergies,
        currentMedications: currentMedications ?? this.currentMedications,
        medicalHistory: medicalHistory ?? this.medicalHistory,
        mentalHealthHistory: mentalHealthHistory ?? this.mentalHealthHistory,
        substanceUse: substanceUse ?? this.substanceUse,
        priorSuicideAttempt:
            priorSuicideAttempt ?? this.priorSuicideAttempt,
        priorSelfHarm: priorSelfHarm ?? this.priorSelfHarm,
        consent: consent ?? this.consent,
        updatedAt: DateTime.now(),
      );

  static List<String> _strList(dynamic v) =>
      (v as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
}
