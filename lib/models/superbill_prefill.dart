/// Carries billing hints extracted from a session note into the superbill
/// screen so the clinician starts from the documented diagnosis + service
/// instead of re-keying them. Everything stays editable — this is a draft, not
/// an autocoder.
class SuperbillPrefill {
  const SuperbillPrefill({
    this.patientName,
    this.icd10Codes = const [],
    this.cptCode,
    this.serviceDate,
    this.noteText,
  });

  final String? patientName;
  final List<String> icd10Codes;
  final String? cptCode;
  final DateTime? serviceDate;

  /// The source note text, when launched from a session — lets the superbill
  /// run a Denial Shield check before the claim is generated.
  final String? noteText;

  bool get isEmpty => icd10Codes.isEmpty && cptCode == null;
}
