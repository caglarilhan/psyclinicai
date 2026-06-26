/// L6 — On-device jailbreak / prompt-injection pattern catalog.
///
/// **Why this exists**: the server-side `functions/src/lib/llm_safety.ts`
/// already pre-screens every LLM-bound prompt with a curated RegExp
/// list. But on-device drafts (the clinician types a request before
/// hitting "send to AI") never get that protection — the client can
/// today ship a jailbroken prompt to the proxy and only there gets
/// the 400. Defense-in-depth wants the same vocabulary at both
/// edges:
///
///   1. Client-side `prompt_safety.dart` can pre-flight a textarea
///      before "Generate" lights up, giving instant feedback.
///   2. The audit log records the matched *category* (not the raw
///      attempt) so we can spot patterns without storing PHI-tinged
///      probes.
///   3. Tests pin parity with the TS catalog — adding a pattern on
///      one side without the other fails the build.
///
/// **Out of scope** (separate PRs):
///   * Wire `prompt_safety.dart` to call `detectJailbreak` before
///     the LLM send.
///   * Sync helper that diffs Dart vs TS catalogs in CI.
///   * Red-team corpus refresh (lives in
///     `docs/security/redteam/2026q3-turkish-jailbreaks.md`).
library;

/// Coarse category for telemetry. Logging the category instead of
/// the raw match avoids persisting the attacker's verbatim text +
/// any PHI they may have included.
enum JailbreakCategory {
  /// Direct instruction override ("ignore previous instructions").
  instructionOverride,

  /// System-prompt exfiltration ("repeat your hidden prompt").
  systemPromptExfiltration,

  /// Persona / mode jailbreaks (DAN, AIM, STAN, developer mode).
  personaJailbreak,

  /// Chat-template / stop-token injection (ChatML, Llama-style).
  chatTemplateInjection,

  /// Multi-language variants of "ignore previous instructions".
  multiLanguage,

  /// Encoding-laundered jailbreaks (base64 / rot13 wrappers).
  encodingLaundered,
}

/// One pinned reject pattern + its category.
class JailbreakPattern {
  const JailbreakPattern({required this.pattern, required this.category});
  final RegExp pattern;
  final JailbreakCategory category;
}

class JailbreakPatternCatalog {
  const JailbreakPatternCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge + last-refresh
  /// note in the red-team corpus.
  static const String lastReviewed = '2026-06';

  /// All patterns are case-insensitive. Ordering does not affect
  /// detection (first match wins, but the test corpus covers every
  /// pattern individually).
  static final List<JailbreakPattern> patterns = [
    // ────────── Direct instruction override ──────────
    JailbreakPattern(
      category: JailbreakCategory.instructionOverride,
      pattern: RegExp(
        r'\bignore (all |any |every |the )?'
        r'(previous|prior|above|earlier) '
        r'(instructions?|prompts?|rules?|directives?)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.instructionOverride,
      pattern: RegExp(
        r'\bdisregard (the )?(above|previous|prior) '
        r'(instructions?|prompts?|rules?)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.instructionOverride,
      pattern: RegExp(
        r'\bforget (all |everything |the )?'
        r'(your |previous |prior )?'
        r'(instructions?|prompts?|rules?)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.instructionOverride,
      pattern: RegExp(
        r'\b(your )?previous instructions are (now )?'
        r'(void|cancelled|null)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.instructionOverride,
      pattern: RegExp(r'\bnew system prompt\s*[:\-]', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.instructionOverride,
      pattern: RegExp(
        r'\b(now )?override (your |the )?'
        r'(system|safety|guard|guardrails?)\b',
        caseSensitive: false,
      ),
    ),

    // ────────── System-prompt exfiltration ──────────
    JailbreakPattern(
      category: JailbreakCategory.systemPromptExfiltration,
      pattern: RegExp(
        r'\b(repeat|show|reveal|print|tell me|what (is|are)) '
        r'(your |the )?'
        r'(system|initial|original|hidden|secret) '
        r'(prompt|instructions?|message)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.systemPromptExfiltration,
      pattern: RegExp(
        r'\bwhat (are|were) (your |the )?'
        r'(original |initial )?'
        r'(instructions?|prompts?|rules?)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.systemPromptExfiltration,
      pattern: RegExp(
        r'\boutput (your |the )?(system|hidden|initial) '
        r'(prompt|instructions?)\b',
        caseSensitive: false,
      ),
    ),

    // ────────── Persona / mode jailbreaks ──────────
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r'\b(enable|enter|activate|switch to)\s+'
        r'(dan|stan|aim|developer|jailbreak|unrestricted|god)\s+mode\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r'\byou are (now )?'
        r'(dan|stan|aim|jailbroken|unrestricted|an? unfiltered)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(r'\bdo anything now\b', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r'\bas (an? )?(unrestricted|unfiltered|uncensored|jailbroken) '
        r'(ai|model|assistant)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r"\bact (as )?if you (have no|are not bound by|don'?t have) "
        r'(any |these )?'
        r'(rules|restrictions|guidelines|safety)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r'\bpretend (you|that you) (are|have) (no|not) '
        r'(limit|restriction|rule)',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r'\bwithout (any )?'
        r'(restrictions?|filters?|safety|guardrails?|censorship)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r'\bbypass (your |the )?'
        r'(safety|guard|filter|restrictions?|content policy)\b',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.personaJailbreak,
      pattern: RegExp(
        r"\bi'?m (your |the )?(developer|owner|admin|root)\b"
        r'.*\b(override|disable|bypass)\b',
        caseSensitive: false,
      ),
    ),

    // ────────── Chat-template / stop-token injection ──────────
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(r'<\|im_start\|>\s*system', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(r'<\|im_end\|>', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(r'<\|system\|>', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(r'<\|endoftext\|>', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(r'</s>\s*<s>\s*\[?inst', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(r'\[/?INST\]', caseSensitive: false),
    ),
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(
        r'###\s*(instruction|system|new (prompt|rules?))',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.chatTemplateInjection,
      pattern: RegExp(r'##\s*system\s*##', caseSensitive: false),
    ),

    // ────────── Multi-language variants ──────────
    // French
    JailbreakPattern(
      category: JailbreakCategory.multiLanguage,
      pattern: RegExp(
        r'\bignorez (les |toutes les )?'
        r'(instructions?|consignes?) '
        r'(précédentes?|antérieures?)',
        caseSensitive: false,
      ),
    ),
    // German
    JailbreakPattern(
      category: JailbreakCategory.multiLanguage,
      pattern: RegExp(
        r'\bignorieren sie (alle |die )?vorherigen anweisungen',
        caseSensitive: false,
      ),
    ),
    // Turkish — `\b` doesn't work with non-ASCII; use (?:^|\W) boundary.
    JailbreakPattern(
      category: JailbreakCategory.multiLanguage,
      pattern: RegExp(
        r'(?:^|\W)önceki (tüm |bütün )?'
        r'(talimatları|kuralları|komutları|yönergeleri) '
        r'(yoksay|göz\s?ardı et|unutma|sil|geç|bırak)',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.multiLanguage,
      pattern: RegExp(
        r'(?:^|\W)yukarıdaki (tüm )?'
        r'(kuralları|talimatları) (görmezden gel|atla)',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.multiLanguage,
      pattern: RegExp(
        r'(?:^|\W)bütün (önceki|yukarıdaki) '
        r'(kuralları|talimatları) (boş ver|sıfırla)',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.multiLanguage,
      pattern: RegExp(
        r'(?:^|\W)bu (rolünü|kimliğini) (unut|bırak|terk et)',
        caseSensitive: false,
      ),
    ),
    JailbreakPattern(
      category: JailbreakCategory.multiLanguage,
      pattern: RegExp(
        r'(?:^|\W)sistem (mesaj(ı|ını)|prompt(u|unu)) '
        r'(göster|açıkla|yazdır)',
        caseSensitive: false,
      ),
    ),

    // ────────── Encoding-laundered ──────────
    JailbreakPattern(
      category: JailbreakCategory.encodingLaundered,
      pattern: RegExp(
        r'\b(decode|run|execute) (this |the following )?'
        r'(base64|rot13|hex)\b',
        caseSensitive: false,
      ),
    ),
  ];
}

/// First-matching pattern + its category, or null when the text is
/// clean. The caller logs the category (never the raw text) so we
/// can spot attack trends without persisting PHI-tinged probes.
JailbreakPattern? detectJailbreak(String text) {
  if (text.isEmpty) return null;
  for (final p in JailbreakPatternCatalog.patterns) {
    if (p.pattern.hasMatch(text)) return p;
  }
  return null;
}

/// Boolean form — convenience for gate-style call sites.
bool isJailbreakAttempt(String text) => detectJailbreak(text) != null;
