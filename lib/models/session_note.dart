/// A finished session note persisted locally per patient. This is the raw
/// material the Clinical Memory brief synthesizes — every note written makes
/// the next pre-session brief richer (the continuity flywheel).
///
/// H-12 fix (audit 2026-06-21): introduces the sign + lock + addendum
/// fields a clinical record needs to satisfy HIPAA §164.312(c)(1)
/// (integrity) + Joint Commission RC.01.01.01 (clinical record
/// authentication). Once `signed` is true the body MUST NOT be edited
/// in place — corrections happen via a paired addendum doc that
/// references this note's id through [addendumOf]. The Firestore rule
/// (mirrored in `firestore.rules`) enforces the immutability.
class SessionNote {

  factory SessionNote.fromJson(Map<String, dynamic> json) => SessionNote(
        id: json['id'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        markdown: json['markdown'] as String? ?? '',
        format: json['format'] as String? ?? 'soap',
        flaggedRisk: json['flaggedRisk'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        signed: json['signed'] as bool? ?? false,
        signedAt: DateTime.tryParse(json['signedAt'] as String? ?? ''),
        signedBy: json['signedBy'] as String?,
        addendumOf: json['addendumOf'] as String?,
      );
  SessionNote({
    required this.id,
    required this.patientId,
    required this.markdown,
    this.format = 'soap',
    this.flaggedRisk = false,
    DateTime? createdAt,
    this.signed = false,
    this.signedAt,
    this.signedBy,
    this.addendumOf,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String patientId;
  final String markdown;
  final String format;
  final bool flaggedRisk;
  final DateTime createdAt;

  /// True after the licensed clinician has authenticated the note.
  /// Subsequent edits are blocked by the Firestore rule — use an
  /// addendum (see [addendumOf]) for corrections.
  final bool signed;

  /// Server-clock-trusted moment of signature. Present iff [signed]
  /// is true.
  final DateTime? signedAt;

  /// Firebase uid of the signing clinician. Distinct from the note
  /// author when an intern's draft is co-signed by a supervisor.
  final String? signedBy;

  /// Non-null on an addendum note — the id of the signed parent note
  /// this addendum corrects or extends. The UI renders addenda
  /// inline under their parent.
  final String? addendumOf;

  /// True when this note is itself an addendum to a previously
  /// signed note. Addenda follow the same sign+lock contract once
  /// authenticated.
  bool get isAddendum => addendumOf != null && addendumOf!.isNotEmpty;

  /// Returns a copy of the note flipped to `signed: true`. The
  /// caller (note service) supplies the [by] uid + [at] timestamp;
  /// the model never resolves those itself so tests can pin them.
  SessionNote sign({required String by, required DateTime at}) {
    if (signed) return this;
    return SessionNote(
      id: id,
      patientId: patientId,
      markdown: markdown,
      format: format,
      flaggedRisk: flaggedRisk,
      createdAt: createdAt,
      signed: true,
      signedAt: at,
      signedBy: by,
      addendumOf: addendumOf,
    );
  }

  /// Construct a new addendum note referencing this signed parent.
  /// Throws [StateError] when the parent is not yet signed — addenda
  /// only make sense once the original is locked.
  SessionNote addendum({
    required String addendumId,
    required String body,
    DateTime? at,
  }) {
    if (!signed) {
      throw StateError(
        'Cannot add an addendum to an unsigned note ($id). Sign '
        'the parent first; corrections to an unsigned draft happen '
        'via plain editing.',
      );
    }
    return SessionNote(
      id: addendumId,
      patientId: patientId,
      markdown: body,
      format: format,
      flaggedRisk: flaggedRisk,
      createdAt: at ?? DateTime.now(),
      addendumOf: id,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'markdown': markdown,
        'format': format,
        'flaggedRisk': flaggedRisk,
        'createdAt': createdAt.toIso8601String(),
        'signed': signed,
        if (signedAt != null) 'signedAt': signedAt!.toIso8601String(),
        if (signedBy != null) 'signedBy': signedBy,
        if (addendumOf != null) 'addendumOf': addendumOf,
      };
}
