/// Group-practice RBAC matrix (audit 2026-06-21, M3 deliverable).
///
/// Existing `ClinicianRole` (psychiatrist/psychologist/...) describes
/// the clinical *license*. A separate organisational *practice role*
/// controls who can do what inside a multi-clinician tenant:
///
///   • `admin`       — practice owner / clinical director
///   • `biller`      — runs claims + payments, no clinical PHI write
///   • `supervisor`  — co-signs intern notes, runs supervision reports
///   • `clinician`   — sees own caseload, drafts + signs notes
///   • `intern`      — drafts notes; cannot sign without a supervisor
///
/// Sources of truth:
///   1. **This matrix** is the single Dart-side reference; UI uses
///      `PracticeRbac.has(role, perm)` to gate widgets / actions.
///   2. **Firestore rules** mirror these decisions per collection so a
///      compromised client cannot bypass the gate. The matrix below
///      drives the rule generator (Sprint 29 S-05 follow-up).
///
/// Audit findings tied to this file:
///   - H-3 (audit_log read rule was uid-keyed): once RBAC ships, the
///     rule changes to "membership doc OR admin/supervisor". The
///     matrix below names the `viewAuditLog` permission used there.
///   - Missing-feature #5 (Group-practice RBAC): table-stakes for any
///     >1 clinician tenant. Without this nothing past Solo sells.
library;

/// Permissions surfaced to the UI + repository layer. New permissions
/// should be added here, mapped in [_matrix], and then enforced in the
/// corresponding Firestore rule + screen guard.
enum PracticePermission {
  /// See the directory of every patient in the practice. Clinician
  /// without this permission sees only their assigned caseload.
  viewAllPatients,

  /// Open + edit a clinical session note. Interns can draft but cannot
  /// flip the `signed` bit on a note (that requires `signProgressNote`).
  editClinicalNote,

  /// Mark a clinical note as `signed` (locks the doc, allows addendum).
  /// Only supervisors + fully-licensed clinicians; interns can't.
  signProgressNote,

  /// Submit a superbill / 837P claim to a payer. Biller workflow.
  submitBilling,

  /// View revenue, denial $$, monthly statements. Practice owner +
  /// biller. Withheld from clinicians to avoid distorting clinical
  /// decisions with revenue context.
  viewFinancials,

  /// Generate + sign a supervision report covering one or more
  /// supervisees. Supervisor permission only.
  signSupervisionReport,

  /// Add / remove practice members + change roles. Admin only.
  manageUsers,

  /// Read the immutable audit log. Admin only (SOC 2 CC6.1).
  viewAuditLog,

  /// Trigger an AI-bound copilot request (relay → Anthropic). Available
  /// to everyone who can write a clinical note — interns included
  /// because the AI assistance is itself the supervised activity.
  submitAiRequest,

  /// Run a GDPR Art. 15 + 20 patient data export. Admin only — the
  /// export contains every clinician's notes about the patient, so
  /// scoping it to one clinician would only mask the cross-clinic
  /// surface and slow the legal response.
  runDsarExport,

  /// Open the Stripe Customer Portal to manage subscription + cards.
  /// Admin only — payment method is the practice's, not the clinician's.
  manageBilling,
}

/// Organisational practice roles. See file header for the verbal
/// description; this enum is the wire format for Firebase custom claims
/// (`practice_role` claim) and Firestore membership docs.
enum PracticeRole { admin, biller, supervisor, clinician, intern }

class PracticeRbac {
  const PracticeRbac._();

  static const Map<PracticeRole, Set<PracticePermission>> _matrix = {
    PracticeRole.admin: {
      PracticePermission.viewAllPatients,
      PracticePermission.editClinicalNote,
      PracticePermission.signProgressNote,
      PracticePermission.submitBilling,
      PracticePermission.viewFinancials,
      PracticePermission.signSupervisionReport,
      PracticePermission.manageUsers,
      PracticePermission.viewAuditLog,
      PracticePermission.submitAiRequest,
      PracticePermission.runDsarExport,
      PracticePermission.manageBilling,
    },
    PracticeRole.biller: {
      // Biller cannot read note bodies (PHI minimisation) — UI / rules
      // expose only billable-codes view + claims status. They see all
      // patients structurally to file claims correctly.
      PracticePermission.viewAllPatients,
      PracticePermission.submitBilling,
      PracticePermission.viewFinancials,
    },
    PracticeRole.supervisor: {
      PracticePermission.viewAllPatients,
      PracticePermission.editClinicalNote,
      PracticePermission.signProgressNote,
      PracticePermission.signSupervisionReport,
      PracticePermission.submitAiRequest,
    },
    PracticeRole.clinician: {
      // No viewAllPatients — only own caseload, enforced separately.
      PracticePermission.editClinicalNote,
      PracticePermission.signProgressNote,
      PracticePermission.submitAiRequest,
    },
    PracticeRole.intern: {
      // Can draft but not sign — that is the supervision wedge.
      PracticePermission.editClinicalNote,
      PracticePermission.submitAiRequest,
    },
  };

  /// True when [role] is allowed to perform [permission]. False for any
  /// role not present in the matrix (defensive default — unknown roles
  /// are denied everything until explicitly added).
  static bool has(PracticeRole role, PracticePermission permission) {
    return _matrix[role]?.contains(permission) ?? false;
  }

  /// Convenience for the UI to render a "can this user do X?" check
  /// against an optional role (e.g. before the auth bootstrap resolves
  /// the claim). Null role → denied.
  static bool maybeHas(PracticeRole? role, PracticePermission permission) {
    if (role == null) return false;
    return has(role, permission);
  }

  /// Every permission granted to [role]. Useful for the settings screen
  /// (which lists what the user can do) and for the Firestore rule
  /// generator that mirrors this matrix on the server side.
  static Set<PracticePermission> permissionsOf(PracticeRole role) {
    return Set.unmodifiable(_matrix[role] ?? const {});
  }

  /// All roles known to the matrix. Surfaced for admin UIs that need
  /// to render the role dropdown.
  static List<PracticeRole> get allRoles =>
      List.unmodifiable(PracticeRole.values);

  /// Parse a stored role string (custom claim or Firestore doc field)
  /// into the typed enum. Returns null for unknown values — callers
  /// must then treat the user as having no role (= denied everything).
  static PracticeRole? fromWireName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final r in PracticeRole.values) {
      if (r.name == name) return r;
    }
    return null;
  }
}
