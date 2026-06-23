/// BottomSheet that presents Pro-tier plans (Solo / Practice /
/// Group) and routes the clinician's pick into the existing
/// `CheckoutService.startCheckout`. When the backend isn't
/// configured yet (no `BACKEND_URL`) the sheet surfaces a
/// "billing not configured" message and offers a local-only
/// fallback for demo/Free-tier accounts.
///
/// Replaces the local-only `_upgradeToPro` stub that used to flip
/// the modality tier in-memory without ever touching Stripe.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/billing/checkout_service.dart';
import '../../services/billing/subscription_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_snack.dart';

class ProUpgradeSheet extends StatefulWidget {
  const ProUpgradeSheet({
    super.key,
    this.checkoutService,
    this.localFallbackEnabled = true,
  });

  /// Optional injection for tests; defaults to a fresh CheckoutService
  /// that talks to the production billing backend.
  final CheckoutService? checkoutService;

  /// When the backend isn't configured (no BACKEND_URL), allow the
  /// clinician to flip the local tier so the rest of the UX works
  /// in demo mode. Default true; production builds with strict
  /// billing should pass false.
  final bool localFallbackEnabled;

  @override
  State<ProUpgradeSheet> createState() => _ProUpgradeSheetState();
}

class _ProUpgradeSheetState extends State<ProUpgradeSheet> {
  late final CheckoutService _checkout;
  SubscriptionTier _selected = SubscriptionTier.solo;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkout = widget.checkoutService ?? CheckoutService();
  }

  Future<void> _continue() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _checkout.startCheckout(_selected);
      // Real flow: Stripe webhook updates Firestore → app reads the
      // new tier on next launch. Surface a confirmation message here
      // and pop with the chosen tier so callers can refresh UI
      // optimistically.
      unawaited(
        TelemetryService.instance.capture(
          'pro_upgrade.checkout_started',
          properties: {'tier': _selected.name},
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(_selected);
      }
    } on CheckoutException catch (e) {
      if (e.notConfigured && widget.localFallbackEnabled) {
        // Demo / local-first mode — caller flips the tier in
        // ModalityPreferences without an actual Stripe round-trip.
        unawaited(
          TelemetryService.instance.capture(
            'pro_upgrade.local_fallback',
            properties: {'tier': _selected.name},
          ),
        );
        if (mounted) {
          Navigator.of(context).pop(_selected);
          PsySnack.success(
            context,
            'Pro tier active locally (billing backend not wired).',
            hint: 'pro_upgrade.local_fallback',
          );
        }
        return;
      }
      setState(() => _error = e.message);
      unawaited(
        TelemetryService.instance.captureError(
          e,
          StackTrace.current,
          hint: 'pro_upgrade.checkout_failed',
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(PsySpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Upgrade to Pro',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock CBT / DBT / EMDR / Family modality panels, '
                  'patient pulse dashboard, Vanderbilt + ASEBA intake, '
                  'and the treatment plan template library.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: PsySpacing.lg),
                for (final tier in const [
                  SubscriptionTier.solo,
                  SubscriptionTier.practice,
                  SubscriptionTier.group,
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: PsySpacing.sm),
                    child: _TierTile(
                      tier: tier,
                      selected: _selected == tier,
                      onTap: () => setState(() => _selected = tier),
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: PsySpacing.md),
                  PsyCard(
                    tinted: true,
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: cs.error, size: 18),
                        const SizedBox(width: PsySpacing.sm),
                        Expanded(
                          child: Text(
                            _error!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: PsySpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: PsySpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _continue,
                        icon: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.lock_open, size: 18),
                        label: Text(_busy ? 'Starting checkout…' : 'Continue'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PsySpacing.sm),
                Text(
                  'You will be redirected to a secure Stripe checkout. '
                  'Cancel any time from Settings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TierTile extends StatelessWidget {
  const _TierTile({
    required this.tier,
    required this.selected,
    required this.onTap,
  });
  final SubscriptionTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PsyRadius.lg),
      child: PsyCard(
        tinted: selected,
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? cs.primary : cs.outline,
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _seatsBlurb(tier),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            PsyBadge(label: _priceFor(tier), tone: PsyBadgeTone.brand),
          ],
        ),
      ),
    );
  }

  /// Indicative monthly pricing — actual amount is set on the
  /// Stripe product. We display from the static tier mapping so
  /// the sheet stays readable without a backend round-trip.
  String _priceFor(SubscriptionTier t) => switch (t) {
    SubscriptionTier.free => 'Free',
    SubscriptionTier.solo => r'$29 / mo',
    SubscriptionTier.practice => r'$99 / mo',
    SubscriptionTier.group => 'Custom',
  };

  String _seatsBlurb(SubscriptionTier t) => switch (t) {
    SubscriptionTier.free => 'Single clinician, trial features only',
    SubscriptionTier.solo => '1 clinician seat — independent practice',
    SubscriptionTier.practice => 'Up to 5 clinician seats',
    SubscriptionTier.group => 'Unlimited seats — clinic / hospital',
  };
}
