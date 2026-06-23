/// One row per submission attempt for an insurance claim. The
/// `ClaimSubmission` model carries the current state machine, but
/// for appeals + resubmission we need the full ledger — what was
/// submitted, when, what response came back, and which appeal
/// letter (if any) backed the resubmission.
///
/// First attempt = the original 837P. Each subsequent attempt is
/// either a corrected resubmission (CARC code re-coding) or an
/// appeal-driven resubmission (AppealLetter referenced).
library;

import 'dart:convert';

enum ClaimAttemptOutcome {
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  paid('paid', 'Paid'),
  denied('denied', 'Denied'),
  upheld('upheld_on_appeal', 'Upheld on appeal'),
  overturned('overturned_on_appeal', 'Overturned on appeal');

  const ClaimAttemptOutcome(this.id, this.label);
  final String id;
  final String label;

  bool get isResolved =>
      this == ClaimAttemptOutcome.paid ||
      this == ClaimAttemptOutcome.upheld ||
      this == ClaimAttemptOutcome.overturned;

  static ClaimAttemptOutcome fromId(String? id) => ClaimAttemptOutcome.values
      .firstWhere((o) => o.id == id, orElse: () => ClaimAttemptOutcome.pending);
}

class ClaimAttempt {
  ClaimAttempt({
    required this.id,
    required this.claimId,
    required this.attemptNumber,
    required this.submittedAt,
    this.refNumber,
    this.outcome = ClaimAttemptOutcome.pending,
    this.adjudicatedAt,
    this.denialReasonCode,
    this.appealLetterId,
    this.notes = '',
  });

  factory ClaimAttempt.fromJson(Map<String, dynamic> json) => ClaimAttempt(
    id: json['id'] as String,
    claimId: json['claimId'] as String? ?? '',
    attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 1,
    submittedAt:
        DateTime.tryParse(json['submittedAt'] as String? ?? '') ??
        DateTime.now().toUtc(),
    refNumber: json['refNumber'] as String?,
    outcome: ClaimAttemptOutcome.fromId(json['outcome'] as String?),
    adjudicatedAt: DateTime.tryParse(json['adjudicatedAt'] as String? ?? ''),
    denialReasonCode: json['denialReasonCode'] as String?,
    appealLetterId: json['appealLetterId'] as String?,
    notes: json['notes'] as String? ?? '',
  );

  final String id;

  /// Foreign key to the parent ClaimSubmission.
  final String claimId;

  /// 1 = original submission, 2 = first resubmission, etc.
  final int attemptNumber;
  final DateTime submittedAt;

  /// Clearinghouse / payer-issued reference number for this attempt
  /// (X12 999 acknowledgement or claim id). Null until returned.
  final String? refNumber;

  final ClaimAttemptOutcome outcome;

  /// When the payer adjudicated this attempt (accepted, denied,
  /// paid, etc.).
  final DateTime? adjudicatedAt;

  /// Payer-issued CARC (Claim Adjustment Reason Code) when the
  /// attempt was denied or partially paid. Drives the next
  /// attempt's fix.
  final String? denialReasonCode;

  /// When this attempt is itself a resubmission triggered by an
  /// appeal, points at the AppealLetter that justified it.
  final String? appealLetterId;

  final String notes;

  bool get isAppealResubmission => appealLetterId != null;
  bool get isOriginal => attemptNumber == 1;

  ClaimAttempt copyWith({
    String? refNumber,
    ClaimAttemptOutcome? outcome,
    DateTime? adjudicatedAt,
    String? denialReasonCode,
    String? appealLetterId,
    String? notes,
  }) => ClaimAttempt(
    id: id,
    claimId: claimId,
    attemptNumber: attemptNumber,
    submittedAt: submittedAt,
    refNumber: refNumber ?? this.refNumber,
    outcome: outcome ?? this.outcome,
    adjudicatedAt: adjudicatedAt ?? this.adjudicatedAt,
    denialReasonCode: denialReasonCode ?? this.denialReasonCode,
    appealLetterId: appealLetterId ?? this.appealLetterId,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'claimId': claimId,
    'attemptNumber': attemptNumber,
    'submittedAt': submittedAt.toIso8601String(),
    'refNumber': refNumber,
    'outcome': outcome.id,
    'adjudicatedAt': adjudicatedAt?.toIso8601String(),
    'denialReasonCode': denialReasonCode,
    'appealLetterId': appealLetterId,
    'notes': notes,
  };

  @override
  String toString() => 'ClaimAttempt(${jsonEncode(toJson())})';
}

/// Roll-up across attempts for a single claim — used by the claim
/// board and by `denial_shield`'s recovery-rate stats.
class ClaimAttemptHistory {
  const ClaimAttemptHistory({required this.claimId, required this.attempts});

  final String claimId;
  final List<ClaimAttempt> attempts;

  bool get hasAppeal => attempts.any((a) => a.isAppealResubmission);
  int get attemptCount => attempts.length;

  ClaimAttempt? get latest => attempts.isEmpty
      ? null
      : attempts.reduce((a, b) => a.attemptNumber > b.attemptNumber ? a : b);

  bool get isResolved => latest?.outcome.isResolved ?? false;

  /// Recovery happens when a denied attempt becomes paid via a
  /// later attempt (typically the appeal).
  bool get recoveredAfterDenial {
    var sawDenial = false;
    final sorted = [...attempts]
      ..sort((x, y) => x.attemptNumber.compareTo(y.attemptNumber));
    for (final a in sorted) {
      if (a.outcome == ClaimAttemptOutcome.denied) sawDenial = true;
      if (sawDenial &&
          (a.outcome == ClaimAttemptOutcome.paid ||
              a.outcome == ClaimAttemptOutcome.overturned)) {
        return true;
      }
    }
    return false;
  }
}
