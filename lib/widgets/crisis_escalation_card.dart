// ignore_for_file: deprecated_member_use
// Radio.groupValue / onChanged deprecated after Flutter 3.32; the RadioGroup
// migration is tracked separately. See Sprint 27 chore.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/crisis_resource.dart';
import '../services/assessments/cssrs_escalation_service.dart';
import '../services/crisis/crisis_resource_registry.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// Inline card used on the C-SSRS result screen when the screener crosses
/// any positive band. Pairs the clinical guidance with one tap to start the
/// safety plan and a list of locale-appropriate crisis resources.
///
/// The card is intentionally *not* dismissible — clinicians who want to
/// suppress it must do so by re-running the screener or navigating away.
/// For the imminent / immediate tiers a blocking modal is also shown via
/// [showCrisisEscalationModal] before the card is reached.
class CrisisEscalationCard extends StatelessWidget {
  const CrisisEscalationCard({
    super.key,
    required this.escalation,
    required this.resources,
    required this.onInitiateSafetyPlan,
  });

  final CssrsEscalation escalation;
  final List<CrisisResource> resources;

  /// Invoked when the clinician taps the primary "Build safety plan now"
  /// action. Parent owns navigation so the card stays presentation-only.
  final VoidCallback onInitiateSafetyPlan;

  @override
  Widget build(BuildContext context) {
    if (!escalation.hasAnyRisk) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _tierAccent(escalation.tier);

    return Semantics(
      container: true,
      label: 'Crisis escalation — ${escalation.headline}',
      child: Container(
        padding: const EdgeInsets.all(PsySpacing.xl),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(escalation: escalation, accent: accent),
            const SizedBox(height: PsySpacing.md),
            Text(escalation.guidance,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
            if (escalation.requiresSafetyPlan) ...[
              const SizedBox(height: PsySpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onInitiateSafetyPlan,
                  icon: const Icon(Icons.health_and_safety_outlined),
                  label: Text(escalation.requiresImmediateAction
                      ? 'Start safety plan now'
                      : 'Build safety plan with the client'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ],
            if (escalation.supervisorHint.isNotEmpty) ...[
              const SizedBox(height: PsySpacing.md),
              _SupervisorHint(text: escalation.supervisorHint),
            ],
            const SizedBox(height: PsySpacing.xl),
            _CrisisResourceList(resources: resources),
          ],
        ),
      ),
    );
  }
}

/// Show the high-risk blocking modal *before* presenting the result screen
/// when the C-SSRS lands in the immediate / imminent tiers. The modal is
/// barrier-dismissible only via explicit buttons so the clinician makes a
/// deliberate choice. Returns a [CrisisModalResult] — when the clinician
/// picks "I'll handle this manually" on the immediate / imminent tiers we
/// force them through a reason picker so the dismissal carries an
/// audit-grade reason code.
Future<CrisisModalResult> showCrisisEscalationModal({
  required BuildContext context,
  required CssrsEscalation escalation,
  required List<CrisisResource> resources,
}) async {
  final result = await showDialog<CrisisModalResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) =>
        _CrisisModal(escalation: escalation, resources: resources),
  );
  return result ??
      const CrisisModalResult(outcome: CrisisModalOutcome.dismissed);
}

/// Reason codes the clinician can pick on the dismissal flow. Lower-
/// case stable ids so analytics + audit log can aggregate without
/// translating display labels.
const Map<String, String> _dismissReasonLabels = {
  'hospitalized':
      'Patient is on the way to / already at an inpatient setting',
  'family_present':
      'Family or trusted adult is with the patient and informed',
  'supervisor_handoff':
      'Handed off to a supervisor / on-call psychiatrist',
  'in_session_plan':
      'Completing a safety plan inside this session instead',
  'other': 'Other (documented in the session note)',
};

/// Shows the dismissal reason picker. Returns the picked reason code,
/// or `null` if the clinician cancelled.
Future<String?> _pickDismissReason(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _DismissReasonPicker(),
  );
}

class _DismissReasonPicker extends StatefulWidget {
  const _DismissReasonPicker();

  @override
  State<_DismissReasonPicker> createState() => _DismissReasonPickerState();
}

class _DismissReasonPickerState extends State<_DismissReasonPicker> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AlertDialog(
      title: const Text('Document the dismissal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'C-SSRS escalation dismissal is logged with a reason so a '
            'supervisor can follow up. Pick the closest match.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7), height: 1.45),
          ),
          const SizedBox(height: PsySpacing.md),
          for (final entry in _dismissReasonLabels.entries)
            RadioListTile<String>(
              value: entry.key,
              groupValue: _picked,
              onChanged: (v) => setState(() => _picked = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(entry.value,
                  style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _picked == null
              ? null
              : () => Navigator.of(context).pop(_picked),
          child: const Text('Confirm dismissal'),
        ),
      ],
    );
  }
}

/// Carries the modal outcome plus, when relevant, the reason picked on
/// the dismissal flow.
class CrisisModalResult {
  const CrisisModalResult({required this.outcome, this.dismissReason});
  final CrisisModalOutcome outcome;

  /// Lower-case stable reason code (`'hospitalized'`, `'in_session_plan'`,
  /// `'family_present'`, `'supervisor_handoff'`, `'other'`). Null when
  /// the modal was resolved via [CrisisModalOutcome.initiateSafetyPlan]
  /// or when the tier did not require a reason (mild / monitor flows).
  final String? dismissReason;
}

/// What the clinician picked on the blocking modal.
enum CrisisModalOutcome {
  /// "Start safety plan now" — caller should navigate to the safety plan.
  initiateSafetyPlan,

  /// "I'll handle this manually" — modal closed, result screen still shows.
  dismissed,
}

// ─────────────────────────────── internals ────────────────────────────────

class _CrisisModal extends StatelessWidget {
  const _CrisisModal({required this.escalation, required this.resources});

  final CssrsEscalation escalation;
  final List<CrisisResource> resources;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _tierAccent(escalation.tier);

    return Dialog(
      insetPadding: const EdgeInsets.all(PsySpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PsyRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(PsySpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(PsySpacing.sm),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PsyRadius.md),
                  ),
                  child: Icon(Icons.warning_amber_rounded, color: accent),
                ),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Text(
                    escalation.headline,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: PsySpacing.lg),
              Text(escalation.guidance,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
              if (escalation.blockPatientRelease) ...[
                const SizedBox(height: PsySpacing.md),
                Container(
                  padding: const EdgeInsets.all(PsySpacing.md),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(PsyRadius.md),
                    border: Border.all(color: accent.withValues(alpha: 0.35)),
                  ),
                  child: Row(children: [
                    Icon(Icons.person_off_outlined, color: accent, size: 20),
                    const SizedBox(width: PsySpacing.sm),
                    Expanded(
                      child: Text(
                        'Do not let the patient leave until acute safety is '
                        'established.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: PsySpacing.xl),
              _CrisisResourceList(resources: resources, compact: true),
              const SizedBox(height: PsySpacing.xl),
              LayoutBuilder(builder: (context, c) {
                final stack = c.maxWidth < 420;
                final primary = FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(
                      const CrisisModalResult(
                          outcome: CrisisModalOutcome.initiateSafetyPlan)),
                  icon: const Icon(Icons.health_and_safety_outlined),
                  label: const Text('Start safety plan now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                  ),
                );
                final secondary = TextButton(
                  onPressed: () async {
                    // Immediate + imminent tiers MUST capture a reason
                    // code before the modal goes away. Lower tiers can
                    // dismiss without one.
                    if (escalation.requiresImmediateAction) {
                      final reason = await _pickDismissReason(context);
                      if (reason == null) return; // clinician cancelled
                      if (!context.mounted) return;
                      Navigator.of(context).pop(CrisisModalResult(
                          outcome: CrisisModalOutcome.dismissed,
                          dismissReason: reason));
                    } else {
                      Navigator.of(context).pop(const CrisisModalResult(
                          outcome: CrisisModalOutcome.dismissed));
                    }
                  },
                  child: const Text("I'll handle this manually"),
                );
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      primary,
                      const SizedBox(height: PsySpacing.sm),
                      secondary,
                    ],
                  );
                }
                return Row(children: [
                  secondary,
                  const Spacer(),
                  primary,
                ]);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.escalation, required this.accent});
  final CssrsEscalation escalation;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(PsyRadius.full),
        ),
        child: Text(
          escalation.tier.name.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      const SizedBox(width: PsySpacing.sm),
      Expanded(
        child: Text(
          escalation.headline,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ),
    ]);
  }
}

class _SupervisorHint extends StatelessWidget {
  const _SupervisorHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.md, vertical: PsySpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(children: [
        Icon(Icons.supervisor_account_outlined,
            size: 18, color: cs.onSurface.withValues(alpha: 0.65)),
        const SizedBox(width: PsySpacing.sm),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: cs.onSurface.withValues(alpha: 0.8))),
        ),
      ]),
    );
  }
}

class _CrisisResourceList extends StatelessWidget {
  const _CrisisResourceList({required this.resources, this.compact = false});
  final List<CrisisResource> resources;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (resources.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crisis resources',
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        for (final r in resources)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.sm),
            child: _ResourceTile(resource: r, compact: compact),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Last reviewed ${CrisisResourceRegistry.lastReviewed} · numbers '
            'may change — verify before relying on them in an emergency.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({required this.resource, required this.compact});
  final CrisisResource resource;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dialable = resource.dialUri != null;
    final webOnly = resource.dialUri == null && resource.webUri != null;

    return Semantics(
      button: dialable || webOnly,
      label: '${resource.name}, ${resource.displayNumber}, '
          '${resource.availability}',
      child: InkWell(
        onTap: dialable
            ? () => _launch(resource.dialUri!)
            : (webOnly ? () => _launch(resource.webUri!) : null),
        borderRadius: BorderRadius.circular(PsyRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.md, vertical: PsySpacing.sm),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(PsyRadius.md),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(children: [
            _KindBadge(kind: resource.kind),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600)),
                  if (!compact && resource.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(resource.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.65))),
                  ],
                  const SizedBox(height: 2),
                  Text(resource.availability,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
            const SizedBox(width: PsySpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: PsySpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(PsyRadius.full),
              ),
              child: Text(resource.displayNumber,
                  style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.85))),
            ),
            if (dialable || webOnly) ...[
              const SizedBox(width: PsySpacing.xs),
              Icon(
                dialable ? Icons.call_outlined : Icons.open_in_new,
                size: 18,
                color: cs.primary,
              ),
            ],
          ]),
        ),
      ),
    );
  }

  static Future<void> _launch(String uri) async {
    final parsed = Uri.tryParse(uri);
    if (parsed == null) return;
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed, mode: LaunchMode.externalApplication);
    }
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.kind});
  final CrisisResourceKind kind;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (kind) {
      CrisisResourceKind.emergency => (
          Icons.local_hospital,
          PsyColors.riskSevere,
        ),
      CrisisResourceKind.hotline => (Icons.call, PsyColors.riskModerate),
      CrisisResourceKind.textLine => (Icons.sms_outlined, PsyColors.riskMild),
      CrisisResourceKind.directory => (
          Icons.travel_explore,
          const Color(0xFF0F766E),
        ),
    };
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PsyRadius.md),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

Color _tierAccent(CssrsEscalationTier tier) => switch (tier) {
      CssrsEscalationTier.imminent => PsyColors.riskSevere,
      CssrsEscalationTier.immediate => PsyColors.riskSevere,
      CssrsEscalationTier.initiateSafetyPlan => PsyColors.riskModerate,
      CssrsEscalationTier.monitor => PsyColors.riskMild,
      CssrsEscalationTier.none => PsyColors.riskMinimal,
    };
