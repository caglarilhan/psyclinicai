/// Refundable deposit + late-cancel / no-show capture (Sprint 11).
///
/// Stripe PaymentIntent in `manual_capture` mode: card is held when
/// the patient confirms the slot, captured if they no-show inside
/// the policy window, refunded otherwise.
///
/// Lifecycle:
///   pending  → held         (intent created, hold placed)
///   held     → captured     (no-show / late cancel — funds taken)
///   held     → refunded     (patient attended or cancelled in time)
///   pending  → cancelled    (clinician aborted before any hold)
class DepositCharge {
  DepositCharge({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.appointmentId,
    required this.amountCents,
    required this.currency,
    this.status = DepositStatus.pending,
    this.paymentIntentId,
    this.noShowReasonCode,
    this.refundedCents,
    DateTime? createdAt,
    this.capturedAt,
    this.refundedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc() {
    if (amountCents < 0) {
      throw ArgumentError(
        'DepositCharge.amountCents cannot be negative (got $amountCents).',
      );
    }
    if (refundedCents != null) {
      if (refundedCents! < 0 || refundedCents! > amountCents) {
        throw ArgumentError(
          'refundedCents must be between 0 and amountCents '
          '(got $refundedCents of $amountCents).',
        );
      }
    }
  }

  factory DepositCharge.fromJson(Map<String, dynamic> json) => DepositCharge(
        id: json['id'] as String? ?? '',
        clinicId: json['clinicId'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        appointmentId: json['appointmentId'] as String? ?? '',
        amountCents: (json['amountCents'] as num? ?? 0).toInt(),
        currency: json['currency'] as String? ?? 'EUR',
        status: DepositStatus.fromId(json['status'] as String?),
        paymentIntentId: json['paymentIntentId'] as String?,
        noShowReasonCode: json['noShowReasonCode'] as String?,
        refundedCents: (json['refundedCents'] as num?)?.toInt(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? ''),
        refundedAt: DateTime.tryParse(json['refundedAt'] as String? ?? ''),
      );

  final String id;
  final String clinicId;
  final String patientId;
  final String appointmentId;

  /// ISO-4217 minor unit — keep money in integers, never floats.
  final int amountCents;
  final String currency;

  final DepositStatus status;
  final String? paymentIntentId;
  final String? noShowReasonCode;

  /// Amount actually returned to the patient (for partial-refund
  /// clinics). Null on full refund or capture; the boolean status
  /// (`refunded` vs `partiallyRefunded`) is the canonical signal —
  /// this is the cents detail the receipt prints.
  final int? refundedCents;

  final DateTime createdAt;
  final DateTime? capturedAt;
  final DateTime? refundedAt;

  /// Returns null when the requested transition is allowed; otherwise
  /// the reason. UI uses this to label disabled buttons; the
  /// repository must also enforce this before persisting.
  String? transitionBlockedReason(DepositStatus next) {
    if (status == next) return 'Already in that state';
    switch (status) {
      case DepositStatus.pending:
        if (next == DepositStatus.held ||
            next == DepositStatus.cancelled) {
          return null;
        }
        return 'A pending deposit must be held or cancelled first';
      case DepositStatus.held:
        if (next == DepositStatus.captured ||
            next == DepositStatus.refunded ||
            next == DepositStatus.partiallyRefunded) {
          return null;
        }
        return 'A held deposit can only be captured or refunded';
      case DepositStatus.captured:
      case DepositStatus.refunded:
      case DepositStatus.partiallyRefunded:
      case DepositStatus.cancelled:
        return 'This deposit is in a final state';
    }
  }

  DepositCharge copyWith({
    DepositStatus? status,
    String? paymentIntentId,
    String? noShowReasonCode,
    int? refundedCents,
    DateTime? capturedAt,
    DateTime? refundedAt,
  }) =>
      DepositCharge(
        id: id,
        clinicId: clinicId,
        patientId: patientId,
        appointmentId: appointmentId,
        amountCents: amountCents,
        currency: currency,
        status: status ?? this.status,
        paymentIntentId: paymentIntentId ?? this.paymentIntentId,
        noShowReasonCode: noShowReasonCode ?? this.noShowReasonCode,
        refundedCents: refundedCents ?? this.refundedCents,
        createdAt: createdAt,
        capturedAt: capturedAt ?? this.capturedAt,
        refundedAt: refundedAt ?? this.refundedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clinicId': clinicId,
        'patientId': patientId,
        'appointmentId': appointmentId,
        'amountCents': amountCents,
        'currency': currency,
        'status': status.id,
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
        if (noShowReasonCode != null) 'noShowReasonCode': noShowReasonCode,
        if (refundedCents != null) 'refundedCents': refundedCents,
        'createdAt': createdAt.toIso8601String(),
        if (capturedAt != null) 'capturedAt': capturedAt!.toIso8601String(),
        if (refundedAt != null) 'refundedAt': refundedAt!.toIso8601String(),
      };
}

enum DepositStatus {
  pending('pending'),
  held('held'),
  captured('captured'),
  refunded('refunded'),
  partiallyRefunded('partially_refunded'),
  cancelled('cancelled');

  const DepositStatus(this.id);
  final String id;

  static DepositStatus fromId(String? id) {
    for (final s in DepositStatus.values) {
      if (s.id == id) return s;
    }
    return DepositStatus.pending;
  }
}
