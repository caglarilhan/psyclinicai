/// Patient-signed consent for processing under GDPR Art. 6(1)(a), Art. 9(2)(a),
/// and KVKK Md. 5(2)(a). Captured during intake; persisted alongside the
/// intake form and exposed in the audit log. Decision-support note for
/// auditors: this is a record of consent, not a substitute for the legal
/// review of the consent text itself.
///
/// JSON shape (back-compat: any missing key defaults to a conservative
/// value — `false` for booleans, empty strings, current time for dates):
///
/// ```
/// {
///   "patientId": "<opaque id>",
///   "policyVersion": "2026-06",
///   "dataProcessingConsent": true,
///   "aiAssistanceConsent": true,
///   "sensitiveDataConsent": true,
///   "signedFullName": "Type the patient's full legal name",
///   "signedAt": "2026-06-01T10:23:00.000Z"
/// }
/// ```
/// Lawful processing bases recorded with each consent. L-8 fix
/// (audit 2026-06-21): the previous record only tracked GDPR
/// implicitly via [ConsentRecord.dataProcessingConsent]. KVKK Md. 5
/// distinguishes "açık rıza" (explicit consent) from other bases
/// (sağlık verisi için Md. 6 — sır saklama yükümlülüğü altındaki
/// sağlık çalışanı). This enum lets the consent record state, per
/// row, which legal frameworks the patient agreed under so a Turkish
/// patient is no longer silently folded into the GDPR-only shape.
enum ConsentBasis {
  /// GDPR Art. 6(1)(a) general personal-data consent.
  gdprArt6Consent('gdpr_art_6_consent'),

  /// GDPR Art. 9(2)(a) explicit consent for special-category data.
  gdprArt9Explicit('gdpr_art_9_explicit'),

  /// KVKK Md. 5(2)(a) — açık rıza (explicit consent).
  kvkkMd5Explicit('kvkk_md_5_explicit'),

  /// KVKK Md. 6 — sağlık + cinsel hayata ilişkin özel nitelikli veri.
  kvkkMd6Health('kvkk_md_6_health'),

  /// HIPAA §164.508 authorisation for non-TPO disclosure.
  hipaaAuthorisation('hipaa_authorisation');

  const ConsentBasis(this.wire);

  /// Stable wire encoding used in Firestore + audit log.
  final String wire;

  static ConsentBasis? fromWire(String value) {
    for (final b in ConsentBasis.values) {
      if (b.wire == value) return b;
    }
    return null;
  }
}

class ConsentRecord {
  ConsentRecord({
    required this.patientId,
    required this.policyVersion,
    required this.dataProcessingConsent,
    required this.aiAssistanceConsent,
    required this.sensitiveDataConsent,
    required this.signedFullName,
    DateTime? signedAt,
    this.withdrawnAt,
    Set<ConsentBasis>? applicableBases,
  })  : signedAt = signedAt ?? DateTime.now(),
        applicableBases =
            Set<ConsentBasis>.unmodifiable(applicableBases ?? const {});

  factory ConsentRecord.fromJson(Map<String, dynamic> json) => ConsentRecord(
        patientId: json['patientId'] as String? ?? '',
        policyVersion: json['policyVersion'] as String? ?? '',
        dataProcessingConsent:
            json['dataProcessingConsent'] as bool? ?? false,
        aiAssistanceConsent: json['aiAssistanceConsent'] as bool? ?? false,
        sensitiveDataConsent: json['sensitiveDataConsent'] as bool? ?? false,
        signedFullName: json['signedFullName'] as String? ?? '',
        signedAt: DateTime.tryParse(json['signedAt'] as String? ?? ''),
        withdrawnAt: DateTime.tryParse(json['withdrawnAt'] as String? ?? ''),
        applicableBases: ((json['applicableBases'] as List<dynamic>?) ??
                const [])
            .map((e) => ConsentBasis.fromWire(e.toString()))
            .whereType<ConsentBasis>()
            .toSet(),
      );

  /// Opaque patient id (same identifier used elsewhere in the chart).
  final String patientId;

  /// Version of the privacy / consent text the patient agreed to. Stored
  /// as YYYY-MM so legal can correlate disputes with the policy in effect
  /// at the time. Required — empty version is a malformed record.
  final String policyVersion;

  /// GDPR Art. 6(1)(a) — general personal-data processing consent.
  final bool dataProcessingConsent;

  /// Discrete consent to AI-assisted note drafting and clinical co-pilot
  /// features (data routed through the configured LLM provider).
  final bool aiAssistanceConsent;

  /// GDPR Art. 9(2)(a) — explicit consent for special-category health
  /// data (mental-health diagnoses, scale scores, safety plans).
  final bool sensitiveDataConsent;

  /// Typed full name acting as a wet-signature substitute. We keep this
  /// instead of an image to stay text-only and audit-friendly. A real
  /// eIDAS-grade signature flow is in the security backlog.
  final String signedFullName;

  /// Server-clock-trusted timestamp. Stored as UTC ISO-8601.
  final DateTime signedAt;

  /// GDPR Art. 7(3) — moment the patient withdrew this consent. When
  /// set, the record is no longer a valid grant; downstream gates
  /// ([ConsentGuard]) must deny. Null on a fresh signature.
  final DateTime? withdrawnAt;

  /// Lawful bases the patient agreed under. Empty set on records
  /// created before the L-8 fix; UI defaults new TR signatures to
  /// `{kvkkMd5Explicit, kvkkMd6Health}` and EU/US to the
  /// equivalent GDPR/HIPAA combinations.
  final Set<ConsentBasis> applicableBases;

  /// True when ANY KVKK basis is recorded — useful for the
  /// Turkey-locale UI flow to render KVKK-specific copy.
  bool get coversKvkk =>
      applicableBases.contains(ConsentBasis.kvkkMd5Explicit) ||
      applicableBases.contains(ConsentBasis.kvkkMd6Health);

  /// True when ANY GDPR basis is recorded.
  bool get coversGdpr =>
      applicableBases.contains(ConsentBasis.gdprArt6Consent) ||
      applicableBases.contains(ConsentBasis.gdprArt9Explicit);

  /// True when HIPAA §164.508 authorisation is on the record.
  bool get coversHipaa =>
      applicableBases.contains(ConsentBasis.hipaaAuthorisation);

  /// True only when the legally required consents are granted, the
  /// signature line is non-empty, AND the patient has not subsequently
  /// withdrawn. AI assistance consent is granular — the patient can
  /// withdraw THAT specifically and still receive care, so it is NOT
  /// required for validity.
  bool get isValid =>
      withdrawnAt == null &&
      dataProcessingConsent &&
      sensitiveDataConsent &&
      signedFullName.trim().isNotEmpty &&
      policyVersion.isNotEmpty;

  /// True when this record has been formally withdrawn — surfaced on
  /// the patient chart so a clinician can re-sign before a new
  /// session.
  bool get isWithdrawn => withdrawnAt != null;

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'policyVersion': policyVersion,
        'dataProcessingConsent': dataProcessingConsent,
        'aiAssistanceConsent': aiAssistanceConsent,
        'sensitiveDataConsent': sensitiveDataConsent,
        'signedFullName': signedFullName,
        'signedAt': signedAt.toUtc().toIso8601String(),
        if (withdrawnAt != null)
          'withdrawnAt': withdrawnAt!.toUtc().toIso8601String(),
        if (applicableBases.isNotEmpty)
          'applicableBases':
              applicableBases.map((b) => b.wire).toList(growable: false),
      };

  ConsentRecord copyWith({
    bool? dataProcessingConsent,
    bool? aiAssistanceConsent,
    bool? sensitiveDataConsent,
    String? signedFullName,
    DateTime? withdrawnAt,
    Set<ConsentBasis>? applicableBases,
  }) =>
      ConsentRecord(
        patientId: patientId,
        policyVersion: policyVersion,
        dataProcessingConsent:
            dataProcessingConsent ?? this.dataProcessingConsent,
        aiAssistanceConsent: aiAssistanceConsent ?? this.aiAssistanceConsent,
        sensitiveDataConsent:
            sensitiveDataConsent ?? this.sensitiveDataConsent,
        signedFullName: signedFullName ?? this.signedFullName,
        signedAt: signedAt,
        withdrawnAt: withdrawnAt ?? this.withdrawnAt,
        applicableBases: applicableBases ?? this.applicableBases,
      );
}
