/// L10 — AI usage budget catalog (pinned helper).
///
/// **Why this exists**: Anthropic + Groq + OpenAI bill by token,
/// not by request. A loose loop or a customer abusing BYOK can
/// burn through the monthly budget in hours. The N12 alerting
/// catalog has a generic cost-anomaly alert; this catalog pins
/// the per-model + per-tier budgets the alert + the throttle
/// gate enforce. SOC 2 CC7.2 + FinOps best practice expect this
/// to be documented + testable.
///
/// Pins per (model id × pricing tier):
///   1. Daily + monthly token budget.
///   2. Hard daily + monthly EUR cost ceiling.
///   3. Throttle action when ≥ 90% of budget reached
///      (slowDown / failOpen / hardKill).
///   4. Owner who gets paged when the kill switch trips.
///
/// **Distinct from**:
///   * L4 ai_decision_logger: that AUDITS calls; L10 BUDGETS them.
///   * N12 alerting_policy: that fires the alert; L10 sets the
///     budget the alert measures against.
///   * O6 feature_flag_registry `kill_groq_paid_tier`: that is the
///     instant kill lever; L10 is the per-tier daily ceiling.
///
/// **Out of scope** (separate PRs):
///   * Cost cron that joins Anthropic + Groq billing API with
///     these budgets.
///   * LLM relay throttle gate that enforces `slowDown` at 90%.
///   * Dashboard widget rendering spend vs budget.
library;

/// Throttle action when usage crosses the budget ceiling.
enum BudgetThrottleAction {
  /// Inject a small queueing delay (200 ms) to soften the spike;
  /// continue serving.
  slowDown,

  /// Stop new requests; serve previously-queued ones; surface a
  /// "AI temporarily unavailable" notice to clinicians.
  failOpen,

  /// Hard stop — refuse every new request. Used for the BYOK
  /// case where the customer hit their own limit.
  hardKill,
}

/// Customer pricing tier the budget applies to. Mirrors
/// O4 PricingTier name parity (free / pilot / enterprise).
enum BudgetTier { free, pilot, enterprise }

/// One pinned budget record.
class UsageBudgetRecord {
  const UsageBudgetRecord({
    required this.modelId,
    required this.tier,
    required this.dailyTokenBudget,
    required this.monthlyTokenBudget,
    required this.dailyCostCeilingEur,
    required this.monthlyCostCeilingEur,
    required this.warningThresholdPercent,
    required this.throttleAtPercent,
    required this.throttleAction,
    required this.escalationOwner,
  });

  /// MUST match an id in L3 ai_model_card.dart prompt registry
  /// (e.g. `claude-3-5-sonnet-clinical-draft`).
  final String modelId;

  final BudgetTier tier;

  /// 0 = unlimited (enterprise contract case).
  final int dailyTokenBudget;
  final int monthlyTokenBudget;

  /// EUR cents are dropped — int is enough at this scale + avoids
  /// floating-point surprises on additive sums.
  final int dailyCostCeilingEur;
  final int monthlyCostCeilingEur;

  /// % of monthly budget at which a warning fires (slack only).
  final int warningThresholdPercent;

  /// % at which `throttleAction` engages.
  final int throttleAtPercent;

  final BudgetThrottleAction throttleAction;

  /// Single accountable role.
  final String escalationOwner;
}

class UsageBudgetCatalog {
  const UsageBudgetCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned budgets. Append-only.
  static const List<UsageBudgetRecord> budgets = [
    // ────────── FREE tier: tight + slow-down ──────────
    UsageBudgetRecord(
      modelId: 'claude-3-5-sonnet-clinical-draft',
      tier: BudgetTier.free,
      dailyTokenBudget: 50000,
      monthlyTokenBudget: 1000000,
      dailyCostCeilingEur: 5,
      monthlyCostCeilingEur: 50,
      warningThresholdPercent: 80,
      throttleAtPercent: 90,
      throttleAction: BudgetThrottleAction.slowDown,
      escalationOwner: 'customer_success',
    ),
    // ────────── PILOT tier: realistic, fail-open at 90% ──────────
    UsageBudgetRecord(
      modelId: 'claude-3-5-sonnet-clinical-draft',
      tier: BudgetTier.pilot,
      dailyTokenBudget: 500000,
      monthlyTokenBudget: 10000000,
      dailyCostCeilingEur: 30,
      monthlyCostCeilingEur: 500,
      warningThresholdPercent: 80,
      throttleAtPercent: 90,
      throttleAction: BudgetThrottleAction.failOpen,
      escalationOwner: 'cto',
    ),
    UsageBudgetRecord(
      modelId: 'claude-3-5-sonnet-soap-summary',
      tier: BudgetTier.pilot,
      dailyTokenBudget: 1000000,
      monthlyTokenBudget: 20000000,
      dailyCostCeilingEur: 50,
      monthlyCostCeilingEur: 1000,
      warningThresholdPercent: 80,
      throttleAtPercent: 90,
      throttleAction: BudgetThrottleAction.failOpen,
      escalationOwner: 'cto',
    ),
    // ────────── ENTERPRISE: unlimited, monitor-only ──────────
    UsageBudgetRecord(
      modelId: 'claude-3-5-sonnet-clinical-draft',
      tier: BudgetTier.enterprise,
      dailyTokenBudget: 0,
      monthlyTokenBudget: 0,
      dailyCostCeilingEur: 0,
      monthlyCostCeilingEur: 0,
      warningThresholdPercent: 80,
      throttleAtPercent: 100,
      throttleAction: BudgetThrottleAction.failOpen,
      escalationOwner: 'cfo',
    ),
    UsageBudgetRecord(
      modelId: 'claude-3-5-sonnet-cssrs-triage',
      tier: BudgetTier.enterprise,
      // Safety-critical: never auto-kill. Budget exists so the
      // dashboard can surface anomalies, not throttle.
      dailyTokenBudget: 0,
      monthlyTokenBudget: 0,
      dailyCostCeilingEur: 0,
      monthlyCostCeilingEur: 0,
      warningThresholdPercent: 80,
      throttleAtPercent: 100,
      throttleAction: BudgetThrottleAction.failOpen,
      escalationOwner: 'ciso',
    ),
  ];

  static UsageBudgetRecord? forModelAndTier(String modelId, BudgetTier tier) {
    for (final b in budgets) {
      if (b.modelId == modelId && b.tier == tier) return b;
    }
    return null;
  }

  static List<UsageBudgetRecord> byTier(BudgetTier tier) {
    return budgets.where((b) => b.tier == tier).toList();
  }
}

/// True when [tokensUsed] crosses the throttle threshold of the
/// monthly token budget. Returns false when the budget is 0
/// (unlimited / enterprise).
bool isThrottleTripped({
  required UsageBudgetRecord budget,
  required int tokensUsed,
}) {
  if (budget.monthlyTokenBudget == 0) return false;
  final pct = (tokensUsed * 100) / budget.monthlyTokenBudget;
  return pct >= budget.throttleAtPercent;
}

/// True when [tokensUsed] is past the warning threshold but not
/// yet at throttle. Drives the "approaching budget" Slack ping.
bool isInWarningWindow({
  required UsageBudgetRecord budget,
  required int tokensUsed,
}) {
  if (budget.monthlyTokenBudget == 0) return false;
  final pct = (tokensUsed * 100) / budget.monthlyTokenBudget;
  return pct >= budget.warningThresholdPercent &&
      pct < budget.throttleAtPercent;
}
