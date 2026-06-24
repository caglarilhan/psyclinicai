/// Read-only chip showing the signed-in clinician's plan
/// (`Free` / `Solo` / `Practice` / `Group`). Renders next to the
/// `_UserMenu` in the AppShell header.
///
/// Tap is intentionally not wired — payment / upgrade UX is gated
/// per the session's product call "ödeme sistemi hariç" (payment
/// system out of scope). This chip surfaces the existing tier so a
/// clinician can spot a "Free" badge at a glance; the upgrade flow
/// lives behind a separate decision.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/billing/subscription_service.dart';
import '../theme/tokens.dart';

class SubscriptionChip extends StatelessWidget {
  const SubscriptionChip({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SubscriptionService?>();
    if (svc == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tier = svc.tier;
    final tone = _toneFor(tier);
    final base = _baseColor(cs, tone);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.md,
        vertical: PsySpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PsyRadius.full),
        border: Border.all(color: base.withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(tier), size: 14, color: base),
          const SizedBox(width: 6),
          Text(
            tier.label,
            style: TextStyle(
              color: base,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _Tone _toneFor(SubscriptionTier tier) => switch (tier) {
    SubscriptionTier.free => _Tone.neutral,
    SubscriptionTier.solo => _Tone.brand,
    SubscriptionTier.practice => _Tone.brand,
    SubscriptionTier.group => _Tone.brand,
  };

  IconData _iconFor(SubscriptionTier tier) => switch (tier) {
    SubscriptionTier.free => Icons.workspace_premium_outlined,
    SubscriptionTier.solo => Icons.workspace_premium,
    SubscriptionTier.practice => Icons.workspace_premium,
    SubscriptionTier.group => Icons.workspace_premium,
  };

  Color _baseColor(ColorScheme cs, _Tone tone) => switch (tone) {
    _Tone.neutral => cs.onSurface,
    _Tone.brand => cs.primary,
  };
}

enum _Tone { neutral, brand }
