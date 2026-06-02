/// How AI inference is sourced for a given workspace.
///
/// The mode is set by the practice admin and is **the single source of
/// truth** for whether AI services may run at all and through which
/// pipeline. Sprint 7 wires this in front of every AI service so a
/// claim of "BYOK-only" on the trust center cannot be quietly broken
/// by a platform key in the environment.
library;

/// Coarse policy values surfaced in the admin UI.
enum WorkspaceAiMode {
  /// Clinician supplies their own API key. Platform keys are NEVER
  /// used as a fallback, even when one is present in the environment.
  /// This is what the trust center promises today.
  byok,

  /// Platform-shared key (covered by the BAA / DPA). Cheaper for the
  /// practice but increases the sub-processor footprint — only
  /// available to tenants who opted in explicitly.
  platform,

  /// AI features are disabled for the workspace. The session screen
  /// shows the structured note editor without an AI panel.
  disabled;

  static WorkspaceAiMode fromId(String? id) {
    for (final m in WorkspaceAiMode.values) {
      if (m.name == id) return m;
    }
    return WorkspaceAiMode.byok;
  }
}

/// Convenience predicate — true when the AI gate is closed at the
/// workspace level regardless of per-patient consent.
bool isAiDisabled(WorkspaceAiMode mode) => mode == WorkspaceAiMode.disabled;

/// True only when the workspace expects a clinician-supplied key. The
/// AI service must verify a key is present BEFORE making the request;
/// the absence of a key in this mode is a configuration error, not a
/// silent fallback to a platform key.
bool requiresByokKey(WorkspaceAiMode mode) =>
    mode == WorkspaceAiMode.byok;
