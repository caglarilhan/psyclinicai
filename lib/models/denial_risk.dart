/// US insurance "Denial Shield" model. Captures the likelihood that a payer
/// rejects a claim for documentation/coding reasons, with the concrete reasons
/// and the exact sentences to add. Decision-support — payer rules and
/// reimbursement amounts vary and change; this estimates risk, it does not
/// guarantee payment.

enum Payer { medicare, medicaid, bcbs, uhcOptum, aetna, cigna }

extension PayerX on Payer {
  String get label => switch (this) {
        Payer.medicare => 'Medicare',
        Payer.medicaid => 'Medicaid',
        Payer.bcbs => 'Blue Cross Blue Shield',
        Payer.uhcOptum => 'UnitedHealthcare / Optum',
        Payer.aetna => 'Aetna',
        Payer.cigna => 'Cigna',
      };

  String get short => switch (this) {
        Payer.medicare => 'Medicare',
        Payer.medicaid => 'Medicaid',
        Payer.bcbs => 'BCBS',
        Payer.uhcOptum => 'UHC/Optum',
        Payer.aetna => 'Aetna',
        Payer.cigna => 'Cigna',
      };
}

enum DenialLevel { low, medium, high }

extension DenialLevelX on DenialLevel {
  String get label => switch (this) {
        DenialLevel.low => 'Low denial risk',
        DenialLevel.medium => 'Medium denial risk',
        DenialLevel.high => 'High denial risk',
      };
}

/// One concrete denial driver + the fix that removes it.
class DenialReason {
  const DenialReason({
    required this.title,
    required this.detail,
    required this.fixSentence,
    this.insertText,
    this.critical = false,
  });

  /// Short driver, e.g. "Functional impairment not documented".
  final String title;

  /// Why this payer/code rejects it.
  final String detail;

  /// Human guidance shown to the clinician ("Add … — e.g. …").
  final String fixSentence;

  /// The clean, ready-to-append sentence for one-click "apply fix". Null when
  /// the remedy is a coding change (e.g. downcode) rather than added text.
  final String? insertText;

  /// True for hard blockers (almost-certain denial) vs. soft risks.
  final bool critical;
}

class DenialRisk {
  const DenialRisk({
    required this.level,
    required this.payer,
    required this.cptCode,
    required this.cptLabel,
    required this.reasons,
    this.revenueAtRisk,
    this.source = DenialSource.heuristic,
  });

  final DenialLevel level;
  final Payer payer;
  final String cptCode;
  final String cptLabel;
  final List<DenialReason> reasons;

  /// Estimated reimbursement (national-average) exposed if this claim denies.
  final double? revenueAtRisk;

  final DenialSource source;

  bool get isClean => reasons.isEmpty;
}

enum DenialSource { heuristic, ai }
