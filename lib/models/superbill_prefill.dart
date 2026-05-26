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
  });

  final String? patientName;
  final List<String> icd10Codes;
  final String? cptCode;
  final DateTime? serviceDate;

  bool get isEmpty => icd10Codes.isEmpty && cptCode == null;
}
