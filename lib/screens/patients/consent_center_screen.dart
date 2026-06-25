import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/audit_log_entry.dart';
import '../../models/consent_entry.dart';
import '../../services/data/audit_log_repository.dart';
import '../../services/data/consent_entry_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/consent/kvkk_intake_slot.dart';

/// `/patients/consents` — six-category consent center (plan §E).
///
/// One card per [ConsentKind]; each card shows current status (active,
/// not given, or revoked), the policy version that was signed, and a
/// revoke button when active. Revoking a category surfaces the
/// downstream consequence via `ConsentKind.revokeEffect` so the
/// clinician understands the blast radius before they confirm.
class ConsentCenterScreen extends StatefulWidget {
  const ConsentCenterScreen({
    super.key,
    this.patientId = 'demo-1',
    this.patientName = 'John Demo',
  });

  final String patientId;
  final String patientName;

  @override
  State<ConsentCenterScreen> createState() => _ConsentCenterScreenState();
}

class _ConsentCenterScreenState extends State<ConsentCenterScreen> {
  final _repo = InMemoryConsentEntryRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChange);
  }

  @override
  void dispose() {
    _repo.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _grant(ConsentKind kind) {
    // KVKK md. 6 requires explicit + auditable consent — surface the
    // full açık rıza form in a modal instead of recording a typed
    // signature stub. The KVKK path already writes its own audit row
    // via KvkkIntakeSlot; the stub path below covers every other kind.
    if (kind == ConsentKind.kvkkSpecialCategoryHealth) {
      unawaited(_openKvkkModal());
      return;
    }
    final entry = ConsentEntry(
      id: 'ce-${DateTime.now().microsecondsSinceEpoch}',
      patientId: widget.patientId,
      kind: kind,
      policyVersion: '2026-06',
      signature: 'typed:${widget.patientName}',
    );
    _repo.record(entry);
    unawaited(_appendConsentAuditEntry(entry, granted: true));
  }

  Future<void> _openKvkkModal() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(PsySpacing.lg),
            child: KvkkIntakeSlot(
              patientId: widget.patientId,
              patientName: widget.patientName,
              policyVersion: 'kvkk-aydinlatma-v2026.06',
              onSigned: () {
                if (Navigator.of(ctx).canPop()) {
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _revoke(ConsentEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke this consent?'),
        content: Text(
          'Revoking this consent will ${entry.kind.revokeEffect}. '
          'The audit row stays — the patient can re-grant later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _repo.revoke(entry.id);
      // KVKK has its own dedicated revoke action label for legacy
      // reasons (PR #96); everything else goes through the generic
      // consent.revoked.<kind.id> action.
      if (entry.kind == ConsentKind.kvkkSpecialCategoryHealth) {
        unawaited(_appendKvkkRevokeAuditEntry(entry));
      } else {
        unawaited(_appendConsentAuditEntry(entry, granted: false));
      }
    }
  }

  /// Generic helper — used for the non-KVKK consent kinds. Action
  /// name pattern: `consent.{granted|revoked}.<kind.id>` so an
  /// auditor can grep one prefix for all consent activity.
  Future<void> _appendConsentAuditEntry(
    ConsentEntry entry, {
    required bool granted,
  }) async {
    try {
      final repo = AuditLogRepository.instance;
      await repo.initialize();
      final verb = granted ? 'granted' : 'revoked';
      await repo.append(
        AuditLogEntry(
          id: 'audit-consent-$verb-${entry.id}',
          kind: 'consent',
          action: 'consent.$verb.${entry.kind.id}',
          actor: widget.patientId,
          entity:
              'patient:${widget.patientId} '
              'entry:${entry.id} '
              'policy:${entry.policyVersion}',
          timestampUtc: DateTime.now().toUtc(),
          result: AuditResult.success,
        ),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'consent.audit_failed',
        ),
      );
    }
  }

  Future<void> _appendKvkkRevokeAuditEntry(ConsentEntry entry) async {
    try {
      final repo = AuditLogRepository.instance;
      await repo.initialize();
      await repo.append(
        AuditLogEntry(
          id: 'audit-kvkk-revoke-${entry.id}',
          kind: 'consent',
          action: 'kvkk.consent_revoked',
          actor: widget.patientId,
          entity:
              'patient:${widget.patientId} '
              'entry:${entry.id} '
              'policy:${entry.policyVersion}',
          timestampUtc: DateTime.now().toUtc(),
          result: AuditResult.success,
        ),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'kvkk.consent_revoked.audit_failed',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/patients/consents',
      title: 'Consent Center',
      subtitle: '${widget.patientName} · per-category consent + revoke',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final kind in ConsentKind.values)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.sm),
              child: _ConsentCard(
                kind: kind,
                active: _repo.activeOf(widget.patientId, kind),
                onGrant: () => _grant(kind),
                onRevoke: _revoke,
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.kind,
    required this.active,
    required this.onGrant,
    required this.onRevoke,
  });

  final ConsentKind kind;
  final ConsentEntry? active;
  final VoidCallback onGrant;
  final Future<void> Function(ConsentEntry) onRevoke;

  String get _label {
    switch (kind) {
      case ConsentKind.hipaaNopp:
        return 'HIPAA Notice of Privacy Practices';
      case ConsentKind.gdprProcessing:
        return 'GDPR processing';
      case ConsentKind.kvkkSpecialCategoryHealth:
        return 'KVKK md. 6 — açık rıza (sağlık verisi)';
      case ConsentKind.aiProcessing:
        return 'AI processing';
      case ConsentKind.audioRecording:
        return 'Audio recording';
      case ConsentKind.telehealth:
        return 'Telehealth';
      case ConsentKind.marketing:
        return 'Marketing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final isActive = active != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isActive ? cs.primaryContainer : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isActive ? 'Active' : 'Not given',
                style: t.labelSmall?.copyWith(
                  color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label, style: t.titleSmall),
                  if (isActive)
                    Text(
                      'v${active!.policyVersion} · signed '
                      '${active!.signedAt.toIso8601String().substring(0, 10)}',
                      style: t.bodySmall,
                    ),
                ],
              ),
            ),
            if (isActive)
              OutlinedButton(
                onPressed: () => onRevoke(active!),
                child: const Text('Revoke'),
              )
            else
              FilledButton.tonal(
                onPressed: onGrant,
                child: const Text('Record consent'),
              ),
          ],
        ),
      ),
    );
  }
}
