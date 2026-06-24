/// Status widgets at the top of `/settings/audit_log`:
/// - [ExportTile]: a single bordered InkWell row with icon + label
///   + copy affordance, used twice (CSV + JSON exports).
/// - [IntegrityCard]: append-only · hash-chained · tamper-evident
///   attestation block with 6-year retention badge.
///
/// HIGH-class refactor (audit 2026-06-21): extracted from
/// audit_log_screen.dart so the screen file owns its state machine
/// + audit row rendering only.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../services/data/audit_log_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../utils/time_format.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

class ExportTile extends StatelessWidget {
  const ExportTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.lg,
            vertical: PsySpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsyRadius.md),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.copy_outlined, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class IntegrityCard extends StatelessWidget {
  const IntegrityCard({super.key, required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    const attestations = [
      _Attest(
        Icons.add_box_outlined,
        'Append-only',
        'No row update or delete is possible — only new entries.',
      ),
      _Attest(
        Icons.link,
        'Hash-chained',
        'Every entry stores SHA-256 of the previous row.',
      ),
      _Attest(
        Icons.fingerprint,
        'Tamper-evident',
        'Any retroactive change invalidates the downstream chain.',
      ),
    ];
    return PsyCard(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.lg,
        vertical: PsySpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: cs.primary, size: 20),
              const SizedBox(width: PsySpacing.sm),
              Text(
                'Integrity attestation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '6-year retention',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          for (var i = 0; i < attestations.length; i++) ...[
            if (i > 0) const SizedBox(height: PsySpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(attestations[i].icon, size: 16, color: cs.primary),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attestations[i].title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attestations[i].body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: PsySpacing.lg),
          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: PsySpacing.md),
          const VerifyChainSection(),
        ],
      ),
    );
  }
}

/// Live integrity check button — calls [AuditLogRepository.verifyChain]
/// and renders the result inline. The hash-chain claim in the
/// attestation above is only credible when a clinician can actually
/// run the verification; this is the surface that closes that loop.
class VerifyChainSection extends StatefulWidget {
  const VerifyChainSection({super.key, this.repo});

  /// Override for tests; production wires the default
  /// [AuditLogRepository].
  final AuditLogRepository? repo;

  @override
  State<VerifyChainSection> createState() => _VerifyChainSectionState();
}

class _VerifyChainSectionState extends State<VerifyChainSection> {
  /// SharedPreferences key id — not a credential.
  static const _lastVerifiedKey = 'audit_log.last_verified_at_v1';

  late final AuditLogRepository _repo = widget.repo ?? AuditLogRepository();
  bool _running = false;
  bool _hasRun = false;
  int? _brokenAt; // null after a successful run means "chain intact"
  DateTime? _lastVerifiedAt;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLastVerified());
  }

  Future<void> _loadLastVerified() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_lastVerifiedKey);
      if (raw == null || raw.isEmpty) return;
      final parsed = DateTime.tryParse(raw)?.toUtc();
      if (parsed == null || !mounted) return;
      setState(() => _lastVerifiedAt = parsed);
    } catch (_) {
      // Silent — stale timestamp display is fine.
    }
  }

  Future<void> _stashLastVerified(DateTime at) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_lastVerifiedKey, at.toUtc().toIso8601String());
    } catch (_) {}
  }

  Future<void> _verify() async {
    setState(() => _running = true);
    await _repo.initialize();
    final result = _repo.verifyChain();
    final at = DateTime.now().toUtc();
    if (!mounted) return;
    setState(() {
      _running = false;
      _hasRun = true;
      _brokenAt = result;
      _lastVerifiedAt = at;
    });
    unawaited(_stashLastVerified(at));
    unawaited(
      TelemetryService.instance.capture(
        'audit_log.verify',
        properties: {'result': result == null ? 'intact' : 'broken_at_$result'},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live chain check',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              if (!_hasRun)
                Text(
                  'Walk every row + recompute its SHA-256 hash.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                )
              else if (_brokenAt == null)
                const Row(
                  children: [
                    PsyBadge(
                      label: 'Chain intact',
                      tone: PsyBadgeTone.success,
                      icon: Icons.check,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    PsyBadge(
                      label: 'Broken at row $_brokenAt',
                      tone: PsyBadgeTone.danger,
                      icon: Icons.error_outline,
                    ),
                  ],
                ),
              if (_lastVerifiedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Last verified ${TimeFormat.relativeDay(_lastVerifiedAt!)} '
                  '${TimeFormat.localClock(_lastVerifiedAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: PsySpacing.md),
        FilledButton.tonalIcon(
          onPressed: _running ? null : () => unawaited(_verify()),
          icon: _running
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fact_check_outlined, size: 18),
          label: Text(_running ? 'Verifying' : 'Verify chain'),
        ),
      ],
    );
  }
}

class _Attest {
  const _Attest(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}
