import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/account_deletion_request.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// In-memory singleton that holds the user's current deletion request.
/// A durable repository (Firestore + scheduled purge job) lands in
/// Sprint 6; this layer keeps the UI testable today.
class AccountDeletionState extends ValueNotifier<AccountDeletionRequest?> {
  AccountDeletionState._() : super(null);
  static final AccountDeletionState instance = AccountDeletionState._();

  void request({required String userId, String? reasonCode}) {
    value = AccountDeletionRequest(
      userId: userId,
      requestedAt: DateTime.now().toUtc(),
      reasonCode: reasonCode,
    );
  }

  void cancel() {
    final cur = value;
    if (cur == null) return;
    value = cur.copyWith(cancelledAt: DateTime.now().toUtc());
  }

  void clear() {
    value = null;
  }
}

/// `/settings/account_deletion` — GDPR Art. 17 erasure portal.
///
/// Submits a deletion request, surfaces the 30-day grace countdown, and
/// lets the clinician undo the request before the purge job runs. The
/// purge itself is owned by the back-end (out of scope here).
class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  static const List<String> _reasons = [
    'switching-provider',
    'no-longer-needed',
    'privacy-concerns',
    'cost',
    'other',
  ];

  String _reason = 'switching-provider';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/settings',
      title: 'Delete my account',
      subtitle:
          'GDPR Article 17 — right to erasure. 30-day grace period before '
          'we purge.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Delete my account', null),
      ],
      child: ValueListenableBuilder<AccountDeletionRequest?>(
        valueListenable: AccountDeletionState.instance,
        builder: (context, request, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _statusCard(theme, cs, request),
              const SizedBox(height: PsySpacing.xl),
              if (request == null ||
                  request.statusAt(DateTime.now()) !=
                      DeletionStatus.pendingGrace)
                _requestForm(theme, cs)
              else
                _activeRequestActions(theme, cs, request),
              const SizedBox(height: PsySpacing.xl),
              _legalNote(theme, cs),
              const SizedBox(height: PsySpacing.huge),
            ],
          );
        },
      ),
    );
  }

  Widget _statusCard(
      ThemeData theme, ColorScheme cs, AccountDeletionRequest? request) {
    final now = DateTime.now();
    final status =
        request?.statusAt(now) ?? DeletionStatus.pendingGrace;
    final hasRequest = request != null;
    return PsyCard(
      tinted: true,
      child: Row(children: [
        Icon(
          hasRequest
              ? Icons.hourglass_top_outlined
              : Icons.shield_outlined,
          color: cs.primary,
        ),
        const SizedBox(width: PsySpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6))),
                const SizedBox(width: PsySpacing.sm),
                _statusBadge(status, hasRequest),
              ]),
              const SizedBox(height: 4),
              Text(
                hasRequest
                    ? 'Requested ${request.requestedAt.toLocal()}. Grace '
                        'ends ${request.graceEndsAt.toLocal()}.'
                    : 'No deletion request on file. Your data continues '
                        'under the standard retention policy.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                    height: 1.45),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _statusBadge(DeletionStatus s, bool hasRequest) {
    if (!hasRequest) {
      return const PsyBadge(label: 'No request', tone: PsyBadgeTone.neutral);
    }
    switch (s) {
      case DeletionStatus.pendingGrace:
        return const PsyBadge(
            label: 'Grace period', tone: PsyBadgeTone.warning);
      case DeletionStatus.cancelled:
        return const PsyBadge(label: 'Cancelled', tone: PsyBadgeTone.neutral);
      case DeletionStatus.completed:
        return const PsyBadge(label: 'Purged', tone: PsyBadgeTone.danger);
    }
  }

  Widget _requestForm(ThemeData theme, ColorScheme cs) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request deletion',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'We hold the request for 30 days so you can undo. After that '
            'a scheduled job removes every record we control. Audit log '
            'entries are pseudonymised but retained per HIPAA §164.316.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72), height: 1.5),
          ),
          const SizedBox(height: PsySpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _reason,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _reasons
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _reason = v ?? _reason),
          ),
          const SizedBox(height: PsySpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _onRequest,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Request deletion'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
                minimumSize: const Size(0, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeRequestActions(
      ThemeData theme, ColorScheme cs, AccountDeletionRequest request) {
    final now = DateTime.now();
    final remaining = request.graceEndsAt.difference(now);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grace period active',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.xs),
          Text(
            '${remaining.inDays} day(s) left before purge. Cancelling now '
            'restores normal access and clears the pending request.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72), height: 1.5),
          ),
          const SizedBox(height: PsySpacing.lg),
          Row(children: [
            FilledButton.icon(
              onPressed: _onCancel,
              icon: const Icon(Icons.undo),
              label: const Text('Cancel deletion'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _legalNote(ThemeData theme, ColorScheme cs) {
    return Text(
      'Erasure rights under GDPR Art. 17 are not absolute. We retain audit '
      'log entries (HIPAA §164.316), invoiced sessions (German HGB §257), '
      'and aggregated outcome statistics (anonymised). Contact '
      'privacy@psyclinicai.com if you need a deeper purge or a proof '
      'certificate after the grace window closes.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.55),
        height: 1.5,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  void _onRequest() {
    final user = FirebaseAuthService.instance.profile;
    AccountDeletionState.instance.request(
      userId: user?.userId ?? 'demo-user',
      reasonCode: _reason,
    );
    unawaited(TelemetryService.instance.capture(
      'compliance.account_deletion_requested',
      properties: {'reason': _reason},
    ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Deletion requested — 30-day grace started.')));
  }

  void _onCancel() {
    AccountDeletionState.instance.cancel();
    unawaited(TelemetryService.instance.capture(
        'compliance.account_deletion_cancelled'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Deletion cancelled. Account restored.')));
  }
}
