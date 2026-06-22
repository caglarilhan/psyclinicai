import 'package:flutter/material.dart';

import '../../models/stripe_connect_account.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/pii_redaction.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/payments` — Stripe + Mollie payment setup hub.
///
/// Same transparency-first pattern as the MFA / Telehealth screens: we
/// already have a CheckoutService scaffold internally, but the wiring
/// to per-session billing + SEPA / iDEAL / SOFORT is still under build.
/// We expose the roadmap and let clinicians register for early access.
class PaymentSetupScreen extends StatefulWidget {
  const PaymentSetupScreen({super.key});

  @override
  State<PaymentSetupScreen> createState() => _PaymentSetupScreenState();
}

class _PaymentSetupScreenState extends State<PaymentSetupScreen> {
  bool _requested = false;

  void _requestEarlyAccess() {
    TelemetryService.instance.capture(
      'payments.early_access_requested',
      properties: {
        // PHI redaction (B4).
        'email':
            redactEmail(FirebaseAuthService.instance.profile?.email) ??
            'anonymous',
      },
    );
    setState(() => _requested = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/settings',
      title: 'Payments',
      subtitle:
          'Stripe (cards) + Mollie (SEPA, iDEAL, SOFORT) — '
          'session billing, deposits, no-show fees.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Payments', null),
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PsyCard(
            tinted: true,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PsySpacing.md),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PsyRadius.md),
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: cs.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: PsySpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Status',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: PsySpacing.sm),
                          const PsyBadge(
                            label: 'Early access',
                            tone: PsyBadgeTone.info,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Superbills export today; in-product collection '
                        '(deposit, no-show, recurring) lands in Sprint 7.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            'Stripe Connect onboarding',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          _ConnectAccountPanel(
            account: StripeConnectAccount.demo('demo-tenant-xyz'),
            cs: cs,
            theme: theme,
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            'What we are building',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          PsyCard(
            child: Column(
              children: const [
                _Bullet(
                  icon: Icons.credit_card,
                  title: 'Stripe card + Apple/Google Pay',
                  body:
                      'PCI-DSS SAQ-A scope only — we never see the '
                      'card PAN; Stripe handles tokenisation.',
                ),
                _Divider(),
                _Bullet(
                  icon: Icons.euro_outlined,
                  title: 'SEPA Direct Debit (EU-wide)',
                  body:
                      'Mandate captured once, debited per session or '
                      'on a subscription cadence.',
                ),
                _Divider(),
                _Bullet(
                  icon: Icons.account_balance_outlined,
                  title: 'iDEAL (NL) + SOFORT (DE)',
                  body:
                      'Country-specific bank rails through Mollie — '
                      'fewer abandoned checkouts in the home markets.',
                ),
                _Divider(),
                _Bullet(
                  icon: Icons.timer_outlined,
                  title: 'Deposit + no-show fee policy',
                  body:
                      'Configure per service: take a deposit at '
                      'booking, charge a no-show fee from the saved '
                      'payment method.',
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            'Early access',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          PsyCard(
            child: _requested
                ? _RequestedNote(theme: theme, cs: cs)
                : _RequestForm(
                    theme: theme,
                    cs: cs,
                    onRequest: _requestEarlyAccess,
                  ),
          ),
          const SizedBox(height: PsySpacing.huge),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 22),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant);
}

class _RequestForm extends StatelessWidget {
  const _RequestForm({
    required this.theme,
    required this.cs,
    required this.onRequest,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us which payment method matters most for your practice and '
          'we will reach out within one business day with onboarding steps '
          'and pricing.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.78),
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onRequest,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Request early access'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
        ),
      ],
    );
  }
}

class _ConnectAccountPanel extends StatelessWidget {
  const _ConnectAccountPanel({
    required this.account,
    required this.cs,
    required this.theme,
  });
  final StripeConnectAccount account;
  final ColorScheme cs;
  final ThemeData theme;

  PsyBadgeTone _tone() {
    if (account.isReady) return PsyBadgeTone.success;
    if (account.status == StripeConnectStatus.restricted) {
      return PsyBadgeTone.warning;
    }
    if (account.status == StripeConnectStatus.disabled) {
      return PsyBadgeTone.warning;
    }
    return PsyBadgeTone.info;
  }

  String _statusLabel() {
    switch (account.status) {
      case StripeConnectStatus.none:
        return 'Not connected';
      case StripeConnectStatus.pending:
        return 'Onboarding in progress';
      case StripeConnectStatus.restricted:
        return 'Action required';
      case StripeConnectStatus.enabled:
        return 'Live';
      case StripeConnectStatus.disabled:
        return 'Paused by Stripe';
    }
  }

  String _humanReadable(String code) {
    switch (code) {
      case 'external_account':
        return 'Add a bank account for payouts';
      case 'individual.id_number':
        return 'Provide your tax identification number';
      case 'tos_acceptance.date':
        return 'Accept the latest Stripe Services Agreement';
      default:
        return code.replaceAll('_', ' ').replaceAll('.', ' › ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PsySpacing.sm),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(PsyRadius.sm),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: cs.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.accountId ?? 'No account yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stripe Connect Express · '
                      '${account.lastSyncAt == null ? "never synced" : "synced ${account.lastSyncAt!.toIso8601String()}"}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              PsyBadge(label: _statusLabel(), tone: _tone()),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          if (account.hasBlockingRequirements) ...[
            Text(
              'Outstanding requirements',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: PsySpacing.xs),
            for (final code in account.requirementsDue)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: PsyColors.warning,
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    Expanded(
                      child: Text(
                        _humanReadable(code),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: PsySpacing.md),
          ],
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  TelemetryService.instance.capture(
                    'billing.stripe_onboarding_link_opened',
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Resume onboarding'),
              ),
              const SizedBox(width: PsySpacing.sm),
              if (account.dashboardUrl != null)
                TextButton.icon(
                  onPressed: () {
                    TelemetryService.instance.capture(
                      'billing.stripe_dashboard_opened',
                    );
                  },
                  icon: const Icon(Icons.dashboard_outlined, size: 16),
                  label: const Text('Stripe dashboard'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestedNote extends StatelessWidget {
  const _RequestedNote({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: cs.primary),
        const SizedBox(width: PsySpacing.md),
        Expanded(
          child: Text(
            'You are on the early-access list. We will email pricing and '
            'a sandbox API key within one business day.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ),
      ],
    );
  }
}
