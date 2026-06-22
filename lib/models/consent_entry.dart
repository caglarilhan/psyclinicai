/// Per-patient, per-category consent entry (plan §E).
///
/// `ConsentRecord` already captures the intake-level aggregate flags
/// (data processing, AI assistance, sensitive data). The "Consent
/// Center" surface from the screen plan needs a row-per-category
/// representation so the patient (or clinician on their behalf) can
/// revoke a single category without touching the others — a
/// requirement of GDPR Art. 7(3) "withdrawal of consent shall be as
/// easy as giving it".
///
/// One entry per `(patientId, kind, policyVersion)` tuple. A revoke
/// flips `revokedAt`; the row is **never** hard-deleted because the
/// audit trail must show the patient consented at time T even if
/// they later changed their mind.
class ConsentEntry {
  ConsentEntry({
    required this.id,
    required this.patientId,
    required this.kind,
    required this.policyVersion,
    required this.signature,
    this.notes = '',
    DateTime? signedAt,
    this.revokedAt,
  }) : signedAt = signedAt ?? DateTime.now().toUtc() {
    if (policyVersion.isEmpty) {
      throw ArgumentError('ConsentEntry.policyVersion is required.');
    }
    if (signature.trim().isEmpty) {
      throw ArgumentError(
        'ConsentEntry.signature must be a non-empty signed value.',
      );
    }
  }

  factory ConsentEntry.fromJson(Map<String, dynamic> json) => ConsentEntry(
    id: json['id'] as String? ?? '',
    patientId: json['patientId'] as String? ?? '',
    kind: ConsentKind.fromId(json['kind'] as String?),
    policyVersion: json['policyVersion'] as String? ?? '',
    signature: json['signature'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    signedAt: DateTime.tryParse(json['signedAt'] as String? ?? ''),
    revokedAt: DateTime.tryParse(json['revokedAt'] as String? ?? ''),
  );

  final String id;
  final String patientId;
  final ConsentKind kind;

  /// Policy / DPA version this consent applies to. Audit trail shows
  /// which policy text the patient signed.
  final String policyVersion;

  /// Signed payload — either a typed name (clinician-witnessed) or an
  /// opaque eIDAS SES signature blob (URL / hash). The model does not
  /// interpret the contents; downstream layers verify.
  final String signature;

  /// Clinician-visible free-text note.
  final String notes;

  final DateTime signedAt;
  final DateTime? revokedAt;

  /// True while the consent is still in force.
  bool get isActive => revokedAt == null;

  /// `revokedAt` flipped from null → timestamp is the only allowed
  /// state change. Returns the revoked copy; throws if the entry is
  /// already revoked.
  ConsentEntry revoke({DateTime? at}) {
    if (revokedAt != null) {
      throw StateError(
        'ConsentEntry $id is already revoked at '
        '${revokedAt!.toIso8601String()}',
      );
    }
    return ConsentEntry(
      id: id,
      patientId: patientId,
      kind: kind,
      policyVersion: policyVersion,
      signature: signature,
      notes: notes,
      signedAt: signedAt,
      revokedAt: (at ?? DateTime.now()).toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'kind': kind.id,
    'policyVersion': policyVersion,
    'signature': signature,
    if (notes.isNotEmpty) 'notes': notes,
    'signedAt': signedAt.toIso8601String(),
    if (revokedAt != null) 'revokedAt': revokedAt!.toIso8601String(),
  };
}

/// Six consent categories surfaced in the Consent Center (plan §E).
enum ConsentKind {
  hipaaNopp('hipaa_nopp'),
  gdprProcessing('gdpr_processing'),
  aiProcessing('ai_processing'),
  audioRecording('audio_recording'),
  telehealth('telehealth'),
  marketing('marketing');

  const ConsentKind(this.id);
  final String id;

  static ConsentKind fromId(String? id) {
    for (final k in ConsentKind.values) {
      if (k.id == id) return k;
    }
    return ConsentKind.gdprProcessing;
  }

  /// Downstream effect when this consent is revoked — used by the
  /// repository to know what to block when `revoke()` succeeds. Pure
  /// metadata: the actual blocking happens elsewhere.
  String get revokeEffect {
    switch (this) {
      case ConsentKind.aiProcessing:
        return 'block AI assistance for the patient';
      case ConsentKind.audioRecording:
        return 'disable session recording';
      case ConsentKind.telehealth:
        return 'block telehealth scheduling';
      case ConsentKind.marketing:
        return 'unsubscribe from marketing';
      case ConsentKind.hipaaNopp:
      case ConsentKind.gdprProcessing:
        return 'requires DPO review — revoking these means closing '
            'the chart and triggering Art. 17 erasure';
    }
  }
}
