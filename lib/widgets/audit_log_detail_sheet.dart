import 'package:flutter/material.dart';

import '../models/audit_log_entry.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// Bottom sheet rendering a single audit row in full detail (plan §J).
///
/// Surfaces the metadata an auditor expects to verify the chain:
/// stable id, action label, actor + entity, UTC + local timestamps,
/// the truncated hash, and a "Verify chain from here" CTA. The
/// payload diff block is rendered when the entry includes one.
class AuditLogDetailSheet extends StatelessWidget {
  const AuditLogDetailSheet({
    super.key,
    required this.entry,
    this.previousHash,
    this.payloadDiff,
    this.onVerifyChain,
  });

  final AuditLogEntry entry;

  /// Hash of the entry directly before this one in the chain. The
  /// production audit-svc returns it alongside the row; the sheet
  /// renders the truncated value so an auditor can spot a break.
  final String? previousHash;

  /// Optional diff (canonical JSON) for actions that mutated a row.
  final String? payloadDiff;

  /// Triggered by the "Verify chain from here" button.
  final VoidCallback? onVerifyChain;

  /// Convenience presenter for the row tap path.
  static Future<void> show(
    BuildContext context, {
    required AuditLogEntry entry,
    String? previousHash,
    String? payloadDiff,
    VoidCallback? onVerifyChain,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AuditLogDetailSheet(
      entry: entry,
      previousHash: previousHash,
      payloadDiff: payloadDiff,
      onVerifyChain: onVerifyChain,
    ),
  );

  String _short(String? h) {
    if (h == null || h.isEmpty) return '—';
    if (h.length <= 12) return h;
    return '${h.substring(0, 6)}…${h.substring(h.length - 6)}';
  }

  String _resultLabel(AuditResult r) {
    switch (r) {
      case AuditResult.success:
        return 'success';
      case AuditResult.failure:
        return 'failure';
      case AuditResult.denied:
        return 'denied';
    }
  }

  Color _resultColor(AuditResult r) {
    switch (r) {
      case AuditResult.success:
        return PsyColors.success;
      case AuditResult.failure:
        return PsyColors.warning;
      case AuditResult.denied:
        return PsyColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final local = entry.timestampUtc.toLocal();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Event detail', style: t.titleMedium),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PsySpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _resultColor(entry.result).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _resultLabel(entry.result),
                      style: t.labelSmall?.copyWith(
                        color: _resultColor(entry.result),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PsySpacing.md),
              _Row(label: 'Action', value: entry.action, t: t),
              _Row(label: 'Kind', value: entry.kind, t: t),
              _Row(label: 'Actor', value: entry.actor, t: t),
              _Row(label: 'Entity', value: entry.entity, t: t),
              _Row(
                label: 'Time (UTC)',
                value: entry.timestampUtc.toIso8601String(),
                t: t,
              ),
              _Row(label: 'Local', value: local.toIso8601String(), t: t),
              if (entry.ip != null) _Row(label: 'IP', value: entry.ip!, t: t),
              if (entry.device != null)
                _Row(label: 'Device', value: entry.device!, t: t),
              const SizedBox(height: PsySpacing.md),
              Text('Hash chain', style: t.titleSmall),
              const SizedBox(height: PsySpacing.xs),
              _Row(label: 'prev_hash', value: _short(previousHash), t: t),
              _Row(label: 'this_hash', value: _short(entry.hash), t: t),
              const SizedBox(height: PsySpacing.sm),
              FilledButton.tonalIcon(
                onPressed: onVerifyChain,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Verify chain from here'),
              ),
              if (payloadDiff != null) ...[
                const SizedBox(height: PsySpacing.md),
                Text('Payload diff', style: t.titleSmall),
                const SizedBox(height: PsySpacing.xs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(PsySpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payloadDiff!,
                    style: t.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.t});
  final String label;
  final String value;
  final TextTheme t;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: t.labelMedium)),
          Expanded(child: Text(value, style: t.bodySmall)),
        ],
      ),
    );
  }
}
