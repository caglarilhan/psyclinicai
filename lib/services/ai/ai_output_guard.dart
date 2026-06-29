/// L1 — Clinical AI output safety gate.
///
/// **Why this exists**: every AI service in the app
/// (`SafetyPlanAiService`, `TreatmentPlanAiService`,
/// `DiagnosisService`, `ChatService`) consents-gates the *call*
/// (PR I2), but nothing inspects the *response*. An LLM that hands
/// a clinician concrete lethal-means instructions (specific
/// medication + dose, weapon access steps, bridge name) for a
/// suicidal patient is a clinical safety incident, not a feature.
/// This gate runs a conservative lexical classifier over each AI
/// completion before it surfaces to the UI, so the caller can:
///   * **block** the surface entirely (`blocked: true`),
///   * **warn** the clinician with a banner ('requireWarning'),
///   * **sanitize** by redacting hits and showing a footer.
///
/// **Conservative by policy**: false positives (extra warnings)
/// are preferred over false negatives (a clinician gets a means
/// suggestion). The lexicon is intentionally narrow — concrete
/// nouns + numbers, not vague topical words. "self-harm" the
/// concept is fine to mention; "30 pills of acetaminophen" is not.
///
/// **Not a substitute for clinical judgment**: this gate is one
/// layer of defense alongside the FDA Clinical Decision Support
/// disclaimer surfaced by `AiDisclaimer.compact`. The clinician
/// owns the decision; the gate stops the worst literal-instruction
/// failure modes.
///
/// **Roadmap** (separate PRs):
///   * L1.5 — LLM-as-judge second-pass for ambiguous outputs
///   * L1.6 — pre-launch classifier benchmark suite (synthetic
///     patient personas + adversarial prompts)
///   * L4 — clinical_decision_supports/{id} audit row per call
library;

import '../../utils/phi_redaction.dart';

/// Categories of risk content the gate detects.
enum AiOutputRiskCategory {
  /// Concrete suicide methods (specific medications + doses,
  /// firearm + ammunition combos, bridge / location names paired
  /// with intent verbs).
  suicideMethods,

  /// Explicit medication overdose instructions (dose + frequency
  /// combinations marked as harmful).
  drugOverdose,

  /// Weapon-access language paired with violent intent.
  weaponAccess,

  /// Concrete self-harm instructions (cutting depth / location).
  selfHarmInstruction,

  /// Detailed violent-act planning (target + method + timing).
  violentPlanning,

  /// PHI echoed back in the AI output (emails / SSNs / patient
  /// IDs the redactor still catches in the response stream).
  phiLeak,
}

/// One detection inside the AI output. Carries enough context for
/// the clinician banner without dragging the full output.
class AiOutputRiskHit {
  const AiOutputRiskHit({
    required this.category,
    required this.matched,
    required this.startIndex,
  });

  final AiOutputRiskCategory category;

  /// The actual substring that matched. The UI uses this to
  /// underline + tooltip the at-risk passage in the AI text.
  final String matched;

  /// Character offset in the original AI output (0-based). Useful
  /// for the redaction pass — replace `text.substring(startIndex,
  /// startIndex + matched.length)` with `[REDACTED]`.
  final int startIndex;
}

/// Aggregate verdict the AI service consumes.
class AiOutputRiskAssessment {
  const AiOutputRiskAssessment({
    required this.hits,
    required this.blocked,
    required this.requireWarning,
    required this.scrubbedText,
  });

  final List<AiOutputRiskHit> hits;

  /// True when the gate refuses to surface the output at all
  /// (multiple high-severity hits OR a `suicideMethods` /
  /// `selfHarmInstruction` hit on its own).
  final bool blocked;

  /// True when the output may surface but the UI MUST render a
  /// banner ("AI output flagged — review carefully"). Always true
  /// when blocked is true; can also be true when only PHI or
  /// weapon-access hits fire.
  final bool requireWarning;

  /// The AI output with every hit replaced by `[REDACTED]`. The
  /// UI shows this when `blocked` is true OR the clinician opts in
  /// to a "show with redactions" view.
  final String scrubbedText;
}

/// The single entry-point an AI service calls. Pure: same input
/// always yields the same assessment.
AiOutputRiskAssessment assessAiOutput(String text) {
  final hits = <AiOutputRiskHit>[];

  // 1. Suicide methods — concrete medication+dose + lethal-means
  //    lexicon. Patterns require BOTH a quantity AND a substance
  //    to suppress topical mentions ("acetaminophen is an
  //    analgesic" stays clean).
  hits.addAll(
    _findAll(text, _suicideMethodPatterns, AiOutputRiskCategory.suicideMethods),
  );

  // 2. Drug overdose — explicit dose instructions framed as
  //    harmful. Doctors prescribe doses too, so the trigger
  //    requires harm-intent words alongside the dose.
  hits.addAll(
    _findAll(text, _drugOverdosePatterns, AiOutputRiskCategory.drugOverdose),
  );

  // 3. Weapon access — firearm + ammunition / firing instructions
  //    paired with violent context.
  hits.addAll(
    _findAll(text, _weaponAccessPatterns, AiOutputRiskCategory.weaponAccess),
  );

  // 4. Self-harm instruction — concrete how-to (depth, location,
  //    tool).
  hits.addAll(
    _findAll(
      text,
      _selfHarmInstructionPatterns,
      AiOutputRiskCategory.selfHarmInstruction,
    ),
  );

  // 5. Violent planning — target + method + timing markers.
  hits.addAll(
    _findAll(
      text,
      _violentPlanningPatterns,
      AiOutputRiskCategory.violentPlanning,
    ),
  );

  // 6. PHI leak — reuse the existing redactor's counter; if the
  //    response carries any email / SSN / patient-id pattern,
  //    surface as a single hit (the redactor token count is the
  //    severity proxy).
  final phiResult = PhiRedactor().scrub(text);
  if (phiResult.totalRemoved > 0) {
    hits.add(
      AiOutputRiskHit(
        category: AiOutputRiskCategory.phiLeak,
        matched: '[PHI×${phiResult.totalRemoved}]',
        startIndex: 0,
      ),
    );
  }

  final hasHardBlock = hits.any(
    (h) =>
        h.category == AiOutputRiskCategory.suicideMethods ||
        h.category == AiOutputRiskCategory.selfHarmInstruction ||
        h.category == AiOutputRiskCategory.violentPlanning ||
        h.category == AiOutputRiskCategory.drugOverdose,
  );
  final blocked = hasHardBlock;
  final requireWarning = hits.isNotEmpty;

  return AiOutputRiskAssessment(
    hits: hits,
    blocked: blocked,
    requireWarning: requireWarning,
    scrubbedText: _redact(text, hits),
  );
}

/// Throws [AiOutputBlockedException] when the assessment says
/// blocked. Convenience for AI services that want fail-closed
/// semantics without inspecting the assessment.
void requireSafeOutput(String text) {
  final assessment = assessAiOutput(text);
  if (assessment.blocked) {
    throw AiOutputBlockedException(assessment: assessment);
  }
}

/// Thrown by [requireSafeOutput] when the AI output trips a hard
/// block. Carries the [AiOutputRiskAssessment] so the AI service's
/// own error handler can route the failure (telemetry hint,
/// clinician banner) without re-running the classifier.
class AiOutputBlockedException implements Exception {
  const AiOutputBlockedException({required this.assessment});

  final AiOutputRiskAssessment assessment;

  @override
  String toString() =>
      'AiOutputBlockedException(hits=${assessment.hits.length}, '
      'categories=${assessment.hits.map((h) => h.category.name).toSet()})';
}

// ---------------------------------------------------------------
// Internal — lexicon. Conservative on purpose: each pattern needs
// a concrete noun + quantity / verb pair to fire. Topical mentions
// without specifics pass through clean.
// ---------------------------------------------------------------

final List<RegExp> _suicideMethodPatterns = [
  // Dose + lethal medication ("30 pills of acetaminophen",
  // "100 mg amitriptyline", "two boxes of paracetamol").
  RegExp(
    r'\b(\d{1,3}|one|two|three|four|five|six|ten|twenty|thirty|fifty|hundred)\s+'
    r'(pills?|tablets?|capsules?|boxes?|mg|grams?|g)\s+(of\s+)?'
    r'(acetaminophen|paracetamol|amitriptyline|tramadol|opioids?|fentanyl|'
    r'oxycodone|morphine|benzodiazepines?|alprazolam|diazepam|sleeping pills?)\b',
    caseSensitive: false,
  ),
  // Hanging / strangulation specifics.
  RegExp(
    r'\b(noose|hang(ing)?|strangulation)\s+(with|using|from)\s+'
    r'(rope|cord|belt|wire|chain)\b',
    caseSensitive: false,
  ),
  // Firearm + ammunition load.
  RegExp(
    r'\b(load(ed)?|chamber(ed)?|fire)\s+(a\s+)?(gun|pistol|revolver|rifle|firearm)\b',
    caseSensitive: false,
  ),
  // Jumping from named heights when paired with intent verb.
  RegExp(
    r'\b(jump|leap)\s+(off|from)\s+(the\s+)?(bridge|building|roof|cliff|balcony)\b',
    caseSensitive: false,
  ),
];

final List<RegExp> _drugOverdosePatterns = [
  RegExp(r'\boverdose\s+(on|with|using)\s+\w+', caseSensitive: false),
  // "Take 10 pills" — bare imperative dose without a clinical
  // prescription frame.
  RegExp(
    r'\btake\s+(\d{1,3}|ten|twenty|thirty|fifty|hundred)\s+(pills?|tablets?|capsules?)\b',
    caseSensitive: false,
  ),
];

final List<RegExp> _weaponAccessPatterns = [
  RegExp(
    r'\b(buy|purchase|acquire|obtain)\s+(a\s+)?(gun|pistol|firearm|knife|rifle)\b',
    caseSensitive: false,
  ),
  RegExp(
    r'\b(unlock|access)\s+(your|the)\s+(gun safe|weapon|firearm)\b',
    caseSensitive: false,
  ),
];

final List<RegExp> _selfHarmInstructionPatterns = [
  RegExp(r'\bcut\s+(deeper|deeply)\b', caseSensitive: false),
  RegExp(
    r'\b(deep|deeper)\s+(cuts?|incisions?)\s+(on|across)\s+(your|the)\s+'
    r'(wrist|wrists|arm|arms|thigh|thighs)\b',
    caseSensitive: false,
  ),
];

final List<RegExp> _violentPlanningPatterns = [
  RegExp(
    r'\b(kill|harm|attack|shoot|stab)\s+(your|the)\s+'
    r'(spouse|partner|husband|wife|boss|colleague|neighbour|neighbor|child|children)\b',
    caseSensitive: false,
  ),
];

List<AiOutputRiskHit> _findAll(
  String text,
  List<RegExp> patterns,
  AiOutputRiskCategory category,
) {
  final hits = <AiOutputRiskHit>[];
  for (final p in patterns) {
    for (final m in p.allMatches(text)) {
      hits.add(
        AiOutputRiskHit(
          category: category,
          matched: m.group(0)!,
          startIndex: m.start,
        ),
      );
    }
  }
  return hits;
}

String _redact(String text, List<AiOutputRiskHit> hits) {
  if (hits.isEmpty) return text;
  // Sort descending so substring offsets stay stable while we
  // splice replacements in place.
  final ordered = [...hits]
    ..sort((a, b) => b.startIndex.compareTo(a.startIndex));
  var out = text;
  for (final h in ordered) {
    // PhiLeak hit's matched string is the badge, not the slice.
    if (h.category == AiOutputRiskCategory.phiLeak) continue;
    final end = h.startIndex + h.matched.length;
    if (end > out.length) continue;
    out = '${out.substring(0, h.startIndex)}[REDACTED]${out.substring(end)}';
  }
  // Then run the existing PhiRedactor over the whole string so
  // emails / SSNs / etc. are scrubbed too.
  return PhiRedactor().scrub(out).cleanText;
}
