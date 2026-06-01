/// A vendor we share data with so the platform can run. Every entry
/// shipped to the trust center comes from [SubprocessorRegistry].
///
/// GDPR Article 28(2) requires written authorisation before engaging a
/// new sub-processor; we keep [lastReviewed] on the registry so legal can
/// confirm the list at audit time. The "transfer" field captures the
/// instrument that legitimises any cross-border data movement (Standard
/// Contractual Clauses, the UK IDTA, adequacy decisions, or "no transfer
/// needed" when the data stays inside the EEA).
library;

/// Coarse risk classification used for the trust-center colour chip.
enum SubprocessorRisk { low, medium, high }

class Subprocessor {
  const Subprocessor({
    required this.id,
    required this.name,
    required this.purpose,
    required this.data,
    required this.location,
    required this.transferMechanism,
    required this.risk,
    this.dpaUrl,
    this.statusPageUrl,
  });

  /// Stable identifier — used in change-notification emails and tests.
  /// Lower-case kebab.
  final String id;

  /// Legal entity name as it appears on the signed DPA.
  final String name;

  /// One short sentence — what this vendor lets us do that the platform
  /// could not do alone.
  final String purpose;

  /// What categories of data they receive (e.g. "session transcript text,
  /// no audio"). Specific so DSAR responses can quote it verbatim.
  final String data;

  /// Region the data physically lands in (e.g. "Frankfurt · eu-central-1").
  final String location;

  /// How any cross-border movement is legitimised: SCCs, UK IDTA, an
  /// adequacy decision, or "no transfer mechanism required" when the
  /// vendor is inside the EEA / UK.
  final String transferMechanism;

  final SubprocessorRisk risk;

  /// Optional public link to the vendor's DPA (helpful for prospects).
  final String? dpaUrl;

  /// Optional vendor status page so the trust center can chain in.
  final String? statusPageUrl;
}
