/// L3 — AI prompt registry + versioning.
///
/// **Why this exists**: each AI service today carries its system /
/// user prompts as inline string literals. That works for shipping
/// but breaks down at audit time:
///   * **QMS / ISO 13485 §7.5.6** asks "which prompt produced this
///     decision?" Inline strings have no version, no diff history,
///     no deprecation pointer.
///   * **AI Act Annex IV (high-risk SaMD)** requires the sponsor to
///     log "the technical and functional specifications" of the
///     system, including prompts that materially shape the output.
///   * Internal AB testing needs to swap prompt variants without
///     touching service code — the registry is the swap surface.
///
/// **Scope of THIS PR**: pure data + invariants + tests. The AI
/// services keep their inline literals for now; a follow-up PR
/// (L3.x) replaces each literal with `PromptRegistry.text(<id>)`
/// once we've migrated callers one at a time. This lets the
/// registry start carrying signal (which prompts exist? when were
/// they last updated? are any deprecated without a successor?) on
/// merge day, even before every service is wired.
///
/// **Versioning rules** (pinned by the invariant tests):
///   * `version` is a monotonic int starting at 1.
///   * `deprecatedAtUtc != null` MUST pair with `replacedBy` (the
///     id of the successor prompt) — orphan deprecation is a
///     coverage gap, not a valid state.
///   * `replacedBy` MUST resolve to a real id in the registry.
library;

/// Role the prompt plays in the LLM call.
enum PromptRole {
  /// "system" message — sets the persona / format / safety frame.
  system,

  /// "user" template — clinician-supplied context wrapped in the
  /// prompt-safety fence (PromptSafety.fence).
  user,
}

/// Immutable record of one prompt version.
class PromptVersion {
  const PromptVersion({
    required this.id,
    required this.surface,
    required this.role,
    required this.version,
    required this.text,
    required this.createdAtUtc,
    this.deprecatedAtUtc,
    this.replacedBy,
  });

  /// Globally-unique id — convention `<surface>.<role>.v<version>`,
  /// e.g. `safety_plan.system.v1`. The id is what AI services pass
  /// to `PromptRegistry.text(...)`.
  final String id;

  /// Service / screen surface (e.g. `safety_plan`,
  /// `treatment_plan_goals`, `diagnosis`, `chatbot`).
  final String surface;

  final PromptRole role;

  /// Monotonic version. Starts at 1; new revisions increment.
  final int version;

  /// The prompt body. Verbatim — what the LLM sees (modulo the
  /// `PromptSafety.fence` wrapping the caller may add).
  final String text;

  /// When this version was registered.
  final DateTime createdAtUtc;

  /// When this version was retired. When set, [replacedBy] MUST
  /// point at a registered successor.
  final DateTime? deprecatedAtUtc;

  /// Id of the successor prompt (active version). Required when
  /// `deprecatedAtUtc != null`; null for active prompts.
  final String? replacedBy;

  bool get isActive => deprecatedAtUtc == null;
}

/// Pinned registry of every prompt the app ships with. Append-only:
/// new versions are added with the next monotonic integer; an old
/// version is deprecated (not removed) so the audit trail can
/// resolve historic ids.
class PromptRegistry {
  PromptRegistry._();

  /// The catalogue. Order is irrelevant; the map is keyed by id.
  static final Map<String, PromptVersion> _all = _seed();

  static Map<String, PromptVersion> _seed() {
    final t0 = DateTime.utc(2026, 6, 26);
    final entries = <PromptVersion>[
      // safety_plan — the Stanley-Brown drafter. Inline literal in
      // SafetyPlanAiService.draft (PR I2 / L1.x). Surfaced here so
      // L3.x can swap the literal for a registry read.
      PromptVersion(
        id: 'safety_plan.system.v1',
        surface: 'safety_plan',
        role: PromptRole.system,
        version: 1,
        createdAtUtc: t0,
        text:
            'You are a clinician drafting a Stanley-Brown crisis '
            'Safety Plan to complete collaboratively WITH the '
            'client. Produce concrete, client-voice starter items '
            'per section the clinician will edit. Decision-support '
            '— not a risk assessment.',
      ),

      // treatment_plan_goals — SMART goals drafter.
      PromptVersion(
        id: 'treatment_plan_goals.system.v1',
        surface: 'treatment_plan_goals',
        role: PromptRole.system,
        version: 1,
        createdAtUtc: t0,
        text:
            'You are an experienced licensed clinician drafting a '
            'treatment plan. Given a diagnosis and clinical '
            'formulation, produce 3–5 SMART goals (Specific, '
            'Measurable, Achievable, Relevant, Time-bound). '
            'Decision-support for a clinician who will review and '
            'edit. Respond with STRICT JSON only.',
      ),

      // treatment_plan_homework — bridge from goals to homework.
      PromptVersion(
        id: 'treatment_plan_homework.system.v1',
        surface: 'treatment_plan_homework',
        role: PromptRole.system,
        version: 1,
        createdAtUtc: t0,
        text:
            'Suggest 3–5 concrete homework assignment titles tied '
            'to the active goals. Decision-support — clinician '
            'reviews and edits.',
      ),

      // diagnosis — DSM-5 differential surfacing.
      PromptVersion(
        id: 'diagnosis.system.v1',
        surface: 'diagnosis',
        role: PromptRole.system,
        version: 1,
        createdAtUtc: t0,
        text:
            'You are a DSM-5 differential reasoner. Given a brief '
            'clinical context, surface 3–5 candidate diagnoses '
            'with criteria matched, criteria missing, and next '
            'assessment steps. Decision-support — the clinician '
            'owns the diagnosis.',
      ),

      // chatbot — clinical reasoning assistant.
      PromptVersion(
        id: 'chatbot.system.v1',
        surface: 'chatbot',
        role: PromptRole.system,
        version: 1,
        createdAtUtc: t0,
        text:
            'You are a clinical reasoning assistant for a licensed '
            'therapist. Keep responses concise, evidence-grounded, '
            'and bias-aware. Decision-support — the clinician owns '
            'every clinical decision.',
      ),
    ];
    return {for (final e in entries) e.id: e};
  }

  /// Returns the prompt body for [id]. Throws [PromptNotFoundException]
  /// if the id is unknown — a service typo trips loud, not silent.
  static String text(String id) {
    final p = _all[id];
    if (p == null) {
      throw PromptNotFoundException(id);
    }
    return p.text;
  }

  /// Full version record for [id].
  static PromptVersion? get(String id) => _all[id];

  /// Latest active version for [surface] + [role]. Returns null if
  /// no active prompt is registered for that pair.
  static PromptVersion? active(String surface, PromptRole role) {
    final candidates = _all.values
        .where((p) => p.surface == surface && p.role == role && p.isActive)
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.version.compareTo(a.version));
    return candidates.first;
  }

  /// Every registered version. Use for the audit-evidence export.
  static List<PromptVersion> all() => List.unmodifiable(_all.values.toList());
}

class PromptNotFoundException implements Exception {
  const PromptNotFoundException(this.id);
  final String id;
  @override
  String toString() => 'PromptNotFoundException(id=$id)';
}
