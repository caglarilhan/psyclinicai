/// A crisis support resource (hotline, text line, emergency number, or
/// directory) surfaced to clinicians when a screener crosses a risk threshold.
///
/// These are presented as decision-support — the clinician decides what to
/// share with the client. Numbers and URIs follow the official sources listed
/// in [CrisisResourceRegistry].
library;

/// What a resource is, used to group them visually.
enum CrisisResourceKind {
  /// National emergency services (911, 112).
  emergency,

  /// Dedicated suicide / mental-health crisis hotline.
  hotline,

  /// SMS / text-based crisis service.
  textLine,

  /// Online directory or chat (e.g. findahelpline.com).
  directory,
}

class CrisisResource {
  const CrisisResource({
    required this.id,
    required this.region,
    required this.name,
    required this.displayNumber,
    required this.kind,
    required this.availability,
    required this.description,
    this.dialUri,
    this.webUri,
    this.smsInstruction,
  });

  /// Stable identifier — used in telemetry / audit logs.
  final String id;

  /// ISO 3166-1 alpha-2 country code, or 'EU' / 'INTL' for cross-region.
  final String region;

  /// Display name (e.g. "988 Suicide & Crisis Lifeline").
  final String name;

  /// The number or short code as a clinician would read it aloud.
  final String displayNumber;

  final CrisisResourceKind kind;

  /// E.g. "24/7 · free".
  final String availability;

  /// One short sentence on who this is for.
  final String description;

  /// `tel:` URI in international format when possible.
  final String? dialUri;

  /// Optional web fallback (directory, chat, info page).
  final String? webUri;

  /// Short SMS instruction if [kind] is [CrisisResourceKind.textLine].
  final String? smsInstruction;

  bool get isEmergency => kind == CrisisResourceKind.emergency;
}
