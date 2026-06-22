/// Drug-drug interaction iskelet (Sprint 12).
///
/// Local lexicon — covers the highest-yield psychiatric pairs that a
/// general-practice prescriber should never miss. Real-world formulary
/// services (Lexicomp, IBM Micromedex, ePINS) integrate in Sprint 14.
///
/// Severities follow the SFINX / IBM Micromedex convention:
///   contraindicated → never use together
///   severe          → use only with strong rationale + close monitoring
///   moderate        → adjust dose / schedule, monitor for symptoms
///
/// Codes are ATC-style ingredient prefixes (e.g. N06AB = SSRIs) so the
/// matcher catches every drug in the class.
library;

/// One interaction match returned by [DdiChecker.check].
class DdiInteraction {
  const DdiInteraction({
    required this.left,
    required this.right,
    required this.severity,
    required this.summary,
  });

  /// The first drug's identifier (drug name OR atc code from the input).
  final String left;
  final String right;
  final DdiSeverity severity;
  final String summary;
}

enum DdiSeverity {
  contraindicated('contraindicated'),
  severe('severe'),
  moderate('moderate');

  const DdiSeverity(this.id);
  final String id;
}

class _Rule {
  const _Rule(this.aPrefix, this.bPrefix, this.severity, this.summary);
  final String aPrefix;
  final String bPrefix;
  final DdiSeverity severity;
  final String summary;
}

/// Pure DDI checker. No I/O, no globals — safe to construct anywhere.
///
/// Attribution: the in-process lexicon is a curated subset of pairs
/// surfaced repeatedly by FDA boxed warnings, NICE BNF, and UpToDate
/// "drug interaction overview" entries. Source-of-truth integration
/// (Lexicomp / IBM Micromedex / ePINS) is tracked in Sprint 15.
class DdiChecker {
  const DdiChecker({
    this.sourceVersion = 'psyclinicai-curated-v1',
    this.lastVerifiedAt = '2026-06-02',
  });

  /// Lexicon version stamped on every emitted interaction so audit
  /// logs can prove which ruleset blocked / warned on a prescription.
  final String sourceVersion;

  /// YYYY-MM-DD stamp — surfaced on the UI badge so the clinician
  /// knows how stale the local ruleset is. Sprint 15 replaces this
  /// with a live formulary feed.
  final String lastVerifiedAt;

  static const List<_Rule> _rules = [
    _Rule(
      'N06AB', // SSRI
      'N06AF', // MAOI (non-selective)
      DdiSeverity.contraindicated,
      'SSRI + MAOI → serotonin syndrome risk; 14-day washout required.',
    ),
    _Rule(
      'N06AB', // SSRI
      'J01XX08', // linezolid
      DdiSeverity.contraindicated,
      'SSRI + linezolid → FDA boxed warning for serotonin syndrome.',
    ),
    _Rule(
      'N06AF', // MAOI
      'N02AX02', // tramadol
      DdiSeverity.contraindicated,
      'MAOI + tramadol → serotonin syndrome / hypertensive crisis.',
    ),
    _Rule(
      'N06AB', // SSRI
      'N06AG', // MAO-A selective
      DdiSeverity.severe,
      'SSRI + MAO-A inhibitor → elevated serotonin; close monitoring.',
    ),
    _Rule(
      'N05BA', // benzodiazepines
      'N02A', // opioids
      DdiSeverity.severe,
      'Benzodiazepine + opioid → respiratory depression (FDA black box).',
    ),
    _Rule(
      'N03AG01', // valproate
      'N03AX09', // lamotrigine
      DdiSeverity.severe,
      'Valproate raises lamotrigine levels → rash / SJS risk.',
    ),
    _Rule(
      'N06AB04', // citalopram
      'A04AA01', // ondansetron
      DdiSeverity.severe,
      'Citalopram + ondansetron → QT prolongation risk.',
    ),
    _Rule(
      'N06AB', // SSRI
      'V11AX02', // St John's Wort (herbal — placeholder code)
      DdiSeverity.severe,
      "SSRI + St John's Wort → additive serotonergic activity.",
    ),
    _Rule(
      'N06AA', // tricyclics
      'N06AB', // SSRI
      DdiSeverity.moderate,
      'TCA + SSRI → TCA plasma levels can rise; cardiac monitoring.',
    ),
  ];

  /// Returns every interaction triggered by the given drug code list.
  /// Order of pairs is irrelevant — `(SSRI, MAOI)` and `(MAOI, SSRI)`
  /// emit a single match.
  List<DdiInteraction> check(List<String> drugCodes) {
    final matches = <DdiInteraction>[];
    final seenPairs = <String>{};
    for (var i = 0; i < drugCodes.length; i++) {
      for (var j = i + 1; j < drugCodes.length; j++) {
        final a = drugCodes[i];
        final b = drugCodes[j];
        for (final rule in _rules) {
          final matchAB =
              a.startsWith(rule.aPrefix) && b.startsWith(rule.bPrefix);
          final matchBA =
              a.startsWith(rule.bPrefix) && b.startsWith(rule.aPrefix);
          if (!matchAB && !matchBA) continue;
          final pairKey = ([a, b]..sort()).join('::');
          if (seenPairs.contains(pairKey)) continue;
          seenPairs.add(pairKey);
          matches.add(
            DdiInteraction(
              left: a,
              right: b,
              severity: rule.severity,
              summary: rule.summary,
            ),
          );
        }
      }
    }
    return matches;
  }

  /// True when ANY contraindicated pair is present — the historical
  /// gate before the Sprint 14 review.
  bool hasContraindication(List<String> drugCodes) =>
      check(drugCodes).any((m) => m.severity == DdiSeverity.contraindicated);

  /// True when ANY interaction is severe OR contraindicated. This is
  /// the gate the e-Rx adapter actually uses to block transmission;
  /// a CDC / FDA boxed-warning pair (benzo + opioid) must NOT slip
  /// through with a "warn only" label.
  bool hasBlockingInteraction(List<String> drugCodes) => check(drugCodes).any(
    (m) =>
        m.severity == DdiSeverity.contraindicated ||
        m.severity == DdiSeverity.severe,
  );
}
