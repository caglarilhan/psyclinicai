import 'package:flutter/material.dart';

import '../models/deposit_charge.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// Inline "Capture no-show" CTA for the superbill screen (plan §24).
///
/// Stateless. The parent owns the [DepositCharge] and the
/// confirm/cancel callbacks. The widget renders the appropriate
/// chip + button combo for the deposit's current lifecycle stage
/// and refuses to fire the capture when the model's transition
/// guard would reject it.
class NoShowChargeButton extends StatelessWidget {
  const NoShowChargeButton({
    super.key,
    required this.deposit,
    this.onCapture,
    this.onRefund,
  });

  final DepositCharge deposit;
  final VoidCallback? onCapture;
  final VoidCallback? onRefund;

  String _statusLabel(DepositStatus s) {
    switch (s) {
      case DepositStatus.pending:
        return 'pending';
      case DepositStatus.held:
        return 'held';
      case DepositStatus.captured:
        return 'captured';
      case DepositStatus.refunded:
        return 'refunded';
      case DepositStatus.partiallyRefunded:
        return 'partial refund';
      case DepositStatus.cancelled:
        return 'cancelled';
    }
  }

  Color _statusColor(DepositStatus s) {
    switch (s) {
      case DepositStatus.held:
        return PsyColors.info;
      case DepositStatus.captured:
        return PsyColors.success;
      case DepositStatus.refunded:
      case DepositStatus.partiallyRefunded:
        return PsyColors.warning;
      case DepositStatus.cancelled:
      case DepositStatus.pending:
        return PsyColors.warning;
    }
  }

  String _money() {
    final units = (deposit.amountCents / 100).toStringAsFixed(2);
    return '${deposit.currency} $units';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = _statusColor(deposit.status);
    final canCapture =
        deposit.transitionBlockedReason(DepositStatus.captured) == null;
    final canRefund =
        deposit.transitionBlockedReason(DepositStatus.refunded) == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Deposit · ${_money()}',
                    style: t.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PsySpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(deposit.status),
                    style: t.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsySpacing.sm),
            Wrap(
              spacing: PsySpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: canCapture ? onCapture : null,
                  icon: const Icon(Icons.event_busy),
                  label: const Text('Capture no-show'),
                ),
                OutlinedButton.icon(
                  onPressed: canRefund ? onRefund : null,
                  icon: const Icon(Icons.undo),
                  label: const Text('Refund deposit'),
                ),
              ],
            ),
            if (!canCapture && !canRefund) ...[
              const SizedBox(height: PsySpacing.xs),
              Text(
                deposit
                        .transitionBlockedReason(DepositStatus.captured) ??
                    '',
                style: t.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
