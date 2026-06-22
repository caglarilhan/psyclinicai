/// Arch M4 fix (audit 2026-06-21): ClinicianRole + ClinicianRoleX
/// used to live inside `lib/services/data/firestore_schema.dart`,
/// which forced every UI screen that needs a role label or
/// permission flag to import the entire schema constant surface
/// (table names, field names, path builders). That was a layer
/// leak called out in the audit's Mimari M4.
///
/// This module owns the domain enum alone. `firestore_schema.dart`
/// keeps `export` of these symbols so any repository / data-layer
/// caller that already imports the schema keeps compiling, but new
/// UI code should import this narrow module instead.
///
/// `practice_rbac.dart` (custom-claim RBAC) is the *cross-tenant*
/// permission story; this enum is the *individual* clinician's
/// licensure / training role. Both concepts coexist deliberately —
/// see the doc comment on practice_rbac.
library;

/// Clinician roles for RBAC.
enum ClinicianRole {
  psychiatrist,
  psychologist,
  therapist,
  nurse,
  secretary,
  administrator,
}

extension ClinicianRoleX on ClinicianRole {
  String get id => name;
  String get label => switch (this) {
    ClinicianRole.psychiatrist => 'Psychiatrist',
    ClinicianRole.psychologist => 'Psychologist',
    ClinicianRole.therapist => 'Therapist',
    ClinicianRole.nurse => 'Nurse',
    ClinicianRole.secretary => 'Secretary',
    ClinicianRole.administrator => 'Administrator',
  };

  bool get canPrescribe => this == ClinicianRole.psychiatrist;
  bool get canSeeFinancials =>
      this == ClinicianRole.administrator || this == ClinicianRole.secretary;
}
