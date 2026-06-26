import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/usage_budget_catalog.dart';

void main() {
  group('UsageBudgetCatalog — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(UsageBudgetCatalog.budgets, isNotEmpty);
    });

    test('every (modelId, tier) pair is unique', () {
      final keys = UsageBudgetCatalog.budgets
          .map((b) => '${b.modelId}|${b.tier.name}')
          .toList();
      expect(
        keys.toSet().length,
        keys.length,
        reason: 'duplicate (model, tier) pairs',
      );
    });

    test('forModelAndTier resolves every entry', () {
      for (final b in UsageBudgetCatalog.budgets) {
        expect(UsageBudgetCatalog.forModelAndTier(b.modelId, b.tier), same(b));
      }
      expect(
        UsageBudgetCatalog.forModelAndTier('does-not-exist', BudgetTier.free),
        isNull,
      );
    });

    test('every record has owner + non-negative budgets', () {
      for (final b in UsageBudgetCatalog.budgets) {
        expect(b.escalationOwner, isNotEmpty);
        expect(b.dailyTokenBudget, greaterThanOrEqualTo(0));
        expect(b.monthlyTokenBudget, greaterThanOrEqualTo(0));
        expect(b.dailyCostCeilingEur, greaterThanOrEqualTo(0));
        expect(b.monthlyCostCeilingEur, greaterThanOrEqualTo(0));
      }
    });

    test('warning < throttle threshold for every record', () {
      for (final b in UsageBudgetCatalog.budgets) {
        expect(
          b.warningThresholdPercent,
          lessThanOrEqualTo(b.throttleAtPercent),
          reason:
              '${b.modelId}/${b.tier.name}: warning at '
              '${b.warningThresholdPercent}% must fire before throttle at '
              '${b.throttleAtPercent}%',
        );
      }
    });

    test('thresholds are within [0, 100]', () {
      for (final b in UsageBudgetCatalog.budgets) {
        expect(b.warningThresholdPercent, inInclusiveRange(0, 100));
        expect(b.throttleAtPercent, inInclusiveRange(0, 100));
      }
    });

    test('daily token budget ≤ monthly token budget (when both > 0)', () {
      for (final b in UsageBudgetCatalog.budgets) {
        if (b.dailyTokenBudget == 0 || b.monthlyTokenBudget == 0) continue;
        expect(
          b.dailyTokenBudget,
          lessThanOrEqualTo(b.monthlyTokenBudget),
          reason: '${b.modelId}/${b.tier.name}: daily > monthly is absurd',
        );
      }
    });

    test('free tier uses slowDown throttle (no hard kill on free)', () {
      for (final b in UsageBudgetCatalog.byTier(BudgetTier.free)) {
        expect(
          b.throttleAction,
          BudgetThrottleAction.slowDown,
          reason:
              '${b.modelId}: free tier MUST degrade gracefully — no '
              'hard kill or fail-open on free users',
        );
      }
    });

    test('enterprise tier has unlimited budgets (0 = no cap)', () {
      for (final b in UsageBudgetCatalog.byTier(BudgetTier.enterprise)) {
        expect(
          b.monthlyTokenBudget,
          0,
          reason:
              '${b.modelId}: enterprise = unlimited tokens; budgets exist '
              'for monitoring only',
        );
        expect(b.monthlyCostCeilingEur, 0);
      }
    });

    test('CSSRS triage model never has a non-zero token budget', () {
      // Safety-critical: a budget kill would silently disable suicide
      // risk triage. The row exists for monitoring; throttle is
      // failOpen at 100% (never actually trips since budget is 0).
      for (final b in UsageBudgetCatalog.budgets) {
        if (b.modelId == 'claude-3-5-sonnet-cssrs-triage') {
          expect(
            b.monthlyTokenBudget,
            0,
            reason:
                '${b.modelId}/${b.tier.name}: safety-critical model MUST '
                'NOT have a finite budget — a kill switch on triage '
                'would silently disable suicide risk screening',
          );
        }
      }
    });

    test('escalation owners span beyond a single owner', () {
      final owners = UsageBudgetCatalog.budgets
          .map((b) => b.escalationOwner)
          .toSet();
      expect(
        owners.length,
        greaterThanOrEqualTo(3),
        reason: 'spread escalation across roles (no bus factor 1)',
      );
    });

    test('byTier slices correctly', () {
      for (final t in BudgetTier.values) {
        for (final b in UsageBudgetCatalog.byTier(t)) {
          expect(b.tier, t);
        }
      }
    });
  });

  group('isThrottleTripped', () {
    test('false when budget is 0 (unlimited / enterprise)', () {
      final b = UsageBudgetCatalog.byTier(BudgetTier.enterprise).first;
      expect(isThrottleTripped(budget: b, tokensUsed: 1 << 30), isFalse);
    });

    test('false below the throttle threshold', () {
      final b = UsageBudgetCatalog.forModelAndTier(
        'claude-3-5-sonnet-clinical-draft',
        BudgetTier.free,
      )!;
      // budget = 1_000_000 monthly; throttle at 90% → 900_000.
      expect(isThrottleTripped(budget: b, tokensUsed: 800000), isFalse);
    });

    test('true at exactly the throttle threshold', () {
      final b = UsageBudgetCatalog.forModelAndTier(
        'claude-3-5-sonnet-clinical-draft',
        BudgetTier.free,
      )!;
      expect(isThrottleTripped(budget: b, tokensUsed: 900000), isTrue);
    });

    test('true past the throttle threshold', () {
      final b = UsageBudgetCatalog.forModelAndTier(
        'claude-3-5-sonnet-clinical-draft',
        BudgetTier.free,
      )!;
      expect(isThrottleTripped(budget: b, tokensUsed: 1100000), isTrue);
    });
  });

  group('isInWarningWindow', () {
    test('false when budget is 0', () {
      final b = UsageBudgetCatalog.byTier(BudgetTier.enterprise).first;
      expect(isInWarningWindow(budget: b, tokensUsed: 1 << 30), isFalse);
    });

    test('true between warning + throttle', () {
      final b = UsageBudgetCatalog.forModelAndTier(
        'claude-3-5-sonnet-clinical-draft',
        BudgetTier.free,
      )!;
      // 800_000 = 80% → at warning threshold.
      expect(isInWarningWindow(budget: b, tokensUsed: 800000), isTrue);
      // 899_999 = 89.99% → still warning, not throttle.
      expect(isInWarningWindow(budget: b, tokensUsed: 899999), isTrue);
    });

    test('false at or past throttle threshold', () {
      final b = UsageBudgetCatalog.forModelAndTier(
        'claude-3-5-sonnet-clinical-draft',
        BudgetTier.free,
      )!;
      expect(isInWarningWindow(budget: b, tokensUsed: 900000), isFalse);
    });

    test('false below warning threshold', () {
      final b = UsageBudgetCatalog.forModelAndTier(
        'claude-3-5-sonnet-clinical-draft',
        BudgetTier.free,
      )!;
      expect(isInWarningWindow(budget: b, tokensUsed: 500000), isFalse);
    });
  });
}
