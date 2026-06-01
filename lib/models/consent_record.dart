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
class ConsentRecord {
  ConsentRecord({
    required this.patientId,
    required this.policyVersion,
    required this.dataProcessingConsent,
    required this.aiAssistanceConsent,
    required this.sensitiveDataConsent,
    required this.signedFullName,
    DateTime? signedAt,
  }) : signedAt = signedAt ?? DateTime.now();

  factory ConsentRecord.fromJson(Map<String, dynamic> json) => ConsentRecord(
        patientId: json['patientId'] as String? ?? '',
        policyVersion: json['policyVersion'] as String? ?? '',
        dataProcessingConsent:
            json['dataProcessingConsent'] as bool? ?? false,
        aiAssistanceConsent: json['aiAssistanceConsent'] as bool? ?? false,
        sensitiveDataConsent: json['sensitiveDataConsent'] as bool? ?? false,
        signedFullName: json['signedFullName'] as String? ?? '',
        signedAt: DateTime.tryParse(json['signedAt'] as String? ?? ''),
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

  /// True only when the legally required consents are granted and the
  /// signature line is non-empty. AI assistance consent is granular —
  /// the patient can withdraw it and still receive care, so it is NOT
  /// required for validity.
  bool get isValid =>
      dataProcessingConsent &&
      sensitiveDataConsent &&
      signedFullName.trim().isNotEmpty &&
      policyVersion.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'policyVersion': policyVersion,
        'dataProcessingConsent': dataProcessingConsent,
        'aiAssistanceConsent': aiAssistanceConsent,
        'sensitiveDataConsent': sensitiveDataConsent,
        'signedFullName': signedFullName,
        'signedAt': signedAt.toUtc().toIso8601String(),
      };

  ConsentRecord copyWith({
    bool? dataProcessingConsent,
    bool? aiAssistanceConsent,
    bool? sensitiveDataConsent,
    String? signedFullName,
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
      );
}
