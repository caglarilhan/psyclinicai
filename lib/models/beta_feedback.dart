/// Beta cohort feedback record. Sprint 25 W2.
enum BetaFeedbackKind {
  bug('bug', 'Bug'),
  idea('idea', 'Idea'),
  praise('praise', 'Praise'),
  blocker('blocker', 'Blocker');

  const BetaFeedbackKind(this.id, this.label);
  final String id;
  final String label;

  static BetaFeedbackKind fromId(String id) =>
      values.firstWhere((k) => k.id == id, orElse: () => BetaFeedbackKind.idea);
}

enum BetaFeedbackSeverity {
  low,
  medium,
  high,
  blocker;

  static BetaFeedbackSeverity forKind(BetaFeedbackKind kind) {
    switch (kind) {
      case BetaFeedbackKind.blocker:
        return BetaFeedbackSeverity.blocker;
      case BetaFeedbackKind.bug:
        return BetaFeedbackSeverity.high;
      case BetaFeedbackKind.idea:
        return BetaFeedbackSeverity.medium;
      case BetaFeedbackKind.praise:
        return BetaFeedbackSeverity.low;
    }
  }
}

/// Patterns that strongly suggest a clinician pasted PHI into the
/// free-text field. Matching is fail-closed — we refuse the record
/// rather than try to redact it, because partial redaction of a
/// session note still leaks context.
final List<RegExp> _phiSentinels = [
  RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // US SSN
  RegExp(r'\b\d{9,}\b'), // MRN / long digit runs
  RegExp(r'\bDOB[:\s]', caseSensitive: false),
  RegExp(r'\bMRN[:\s]', caseSensitive: false),
  RegExp(r'\bICD-?10[:\s]', caseSensitive: false),
  RegExp(r'\bC-?SSRS\b'),
  RegExp(r'\bsession note\b', caseSensitive: false),
  RegExp(r'\bSOAP\b'),
];

class BetaFeedback {
  BetaFeedback({
    required this.id,
    required this.kind,
    required this.body,
    required this.route,
    required this.uid,
    required this.phiAttestation,
    DateTime? submittedAt,
    BetaFeedbackSeverity? severity,
  }) : submittedAt = submittedAt ?? DateTime.now().toUtc(),
       severity = severity ?? BetaFeedbackSeverity.forKind(kind) {
    if (body.trim().isEmpty) {
      throw ArgumentError('BetaFeedback.body cannot be empty.');
    }
    if (body.length > 2000) {
      throw ArgumentError('BetaFeedback.body exceeds 2000 chars.');
    }
    if (!phiAttestation) {
      throw ArgumentError(
        'BetaFeedback requires the clinician to attest the body '
        'contains no patient identifiers.',
      );
    }
    for (final sentinel in _phiSentinels) {
      if (sentinel.hasMatch(body)) {
        throw ArgumentError(
          'BetaFeedback.body looks like it contains PHI '
          '(${sentinel.pattern}). Refusing to submit.',
        );
      }
    }
  }

  /// The submitter ticked the "no patient identifiers in this report"
  /// confirmation. Persisted alongside the body so the audit trail
  /// shows the attestation existed at submission time.
  final bool phiAttestation;

  final String id;
  final BetaFeedbackKind kind;
  final String body;
  final String route;
  final String uid;
  final DateTime submittedAt;
  final BetaFeedbackSeverity severity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.id,
    'body': body,
    'route': route,
    'uid': uid,
    'severity': severity.name,
    'phi_attested': phiAttestation,
    'submitted_at': submittedAt.toUtc().toIso8601String(),
  };

  factory BetaFeedback.fromJson(Map<String, dynamic> json) => BetaFeedback(
    id: json['id'] as String,
    kind: BetaFeedbackKind.fromId(json['kind'] as String),
    body: json['body'] as String,
    route: json['route'] as String,
    uid: json['uid'] as String,
    phiAttestation: json['phi_attested'] as bool? ?? false,
    submittedAt: DateTime.parse(json['submitted_at'] as String),
    severity: BetaFeedbackSeverity.values.firstWhere(
      (s) => s.name == json['severity'],
      orElse: () => BetaFeedbackSeverity.medium,
    ),
  );
}

abstract class BetaFeedbackRepository {
  Future<void> submit(BetaFeedback feedback);
  Future<List<BetaFeedback>> readAll();
}

class InMemoryBetaFeedbackRepository implements BetaFeedbackRepository {
  final List<BetaFeedback> _store = [];

  @override
  Future<void> submit(BetaFeedback feedback) async {
    _store.add(feedback);
  }

  @override
  Future<List<BetaFeedback>> readAll() async => List.unmodifiable(_store);
}
