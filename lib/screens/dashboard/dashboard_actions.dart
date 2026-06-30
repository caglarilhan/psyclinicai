/// Quick-actions grid for the clinician dashboard — twelve
/// outcome-tied entry points (start session, caseload attention,
/// patients, outcomes, superbill, screeners, AI assistant, help)
/// laid out as a responsive 1/2/3-column wrap of
/// [ActionTile]s. Each tile hover-lifts and pushes its route.
///
/// HIGH-6 slice B (audit 2026-06-21): extracted from
/// dashboard_screen.dart.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final actions = <DashboardAction>[
      DashboardAction(
        icon: Icons.mic_none,
        label: 'Start a session',
        body: 'Live AI Co-Pilot with on-device transcription.',
        route: '/session',
      ),
      DashboardAction(
        icon: Icons.notifications_active_outlined,
        label: 'Caseload attention',
        body: 'Who needs you now — overdue work, stalled plans, risk.',
        route: '/caseload',
      ),
      DashboardAction(
        icon: Icons.group_outlined,
        label: 'Patients',
        body: 'Search the roster, add a patient, open a chart.',
        route: '/patients',
      ),
      DashboardAction(
        icon: Icons.show_chart,
        label: 'Outcomes',
        body: 'PHQ-9 + GAD-7 trend dashboard with severity bands.',
        route: '/outcomes',
      ),
      DashboardAction(
        icon: Icons.receipt_long_outlined,
        label: 'Create superbill',
        body: 'CPT + ICD-10 picker, CMS-1500-aligned PDF.',
        route: '/superbill',
      ),
      DashboardAction(
        icon: Icons.psychology_outlined,
        label: 'Send PHQ-9',
        body: 'Depression screener with severity bands.',
        route: '/assessments/phq9',
      ),
      DashboardAction(
        icon: Icons.spa_outlined,
        label: 'Send GAD-7',
        body: 'Anxiety screener with severity bands.',
        route: '/assessments/gad7',
      ),
      DashboardAction(
        icon: Icons.shield_moon_outlined,
        label: 'C-SSRS suicide screen',
        body: 'Columbia suicide-risk screener with categorical guidance.',
        route: '/scales/cssrs',
      ),
      DashboardAction(
        icon: Icons.bolt_outlined,
        label: 'PCL-5 (PTSD)',
        body: '20-item PTSD checklist with provisional threshold.',
        route: '/scales/pcl5',
      ),
      DashboardAction(
        icon: Icons.local_bar_outlined,
        label: 'AUDIT (alcohol)',
        body: 'WHO alcohol-use screener with risk bands.',
        route: '/scales/audit',
      ),
      DashboardAction(
        icon: Icons.smart_toy_outlined,
        label: 'AI assistant',
        body: 'Chat with the clinical reasoning co-pilot.',
        route: '/ai_chatbot',
      ),
      DashboardAction(
        icon: Icons.online_prediction,
        label: 'No-show risk queue',
        body:
            'Predict no-show risk for an appointment and apply the '
            'recovery playbook (reminders, deposit, waitlist).',
        route: '/clinician/noshow',
      ),
      DashboardAction(
        icon: Icons.help_outline,
        label: 'Help & docs',
        body: 'Setup guide, FAQ, security overview.',
        route: '/security',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        LayoutBuilder(
          builder: (ctx, c) {
            final cols = c.maxWidth >= PsyBreakpoints.lg
                ? 3
                : c.maxWidth >= PsyBreakpoints.sm
                ? 2
                : 1;
            final cardW = (c.maxWidth - (cols - 1) * PsySpacing.lg) / cols;
            return Wrap(
              spacing: PsySpacing.lg,
              runSpacing: PsySpacing.lg,
              children: actions
                  .map(
                    (a) => SizedBox(
                      width: cardW,
                      child: ActionTile(action: a, theme: theme, cs: cs),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class DashboardAction {
  DashboardAction({
    required this.icon,
    required this.label,
    required this.body,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String body;
  final String route;
}

class ActionTile extends StatefulWidget {
  const ActionTile({
    super.key,
    required this.action,
    required this.theme,
    required this.cs,
  });
  final DashboardAction action;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.cs;
    final action = widget.action;
    final hover = _hover;
    final radius = BorderRadius.circular(PsyRadius.lg);

    return Material(
      color: cs.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).pushNamed(action.route),
        onHover: (h) => setState(() => _hover = h),
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: PsyMotion.fast,
          curve: PsyMotion.standard,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, hover ? -3.0 : 0.0, 0.0, 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(PsySpacing.xl),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: hover
                  ? cs.primary.withValues(alpha: 0.45)
                  : cs.outlineVariant,
            ),
            boxShadow: hover
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: PsyMotion.fast,
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: hover ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(PsyRadius.sm),
                    ),
                    child: Icon(action.icon, color: cs.primary, size: 20),
                  ),
                  const Spacer(),
                  // Surprise affordance: an arrow slides in on hover.
                  AnimatedOpacity(
                    duration: PsyMotion.fast,
                    opacity: hover ? 1 : 0,
                    child: AnimatedSlide(
                      duration: PsyMotion.fast,
                      curve: PsyMotion.standard,
                      offset: hover ? Offset.zero : const Offset(-0.3, 0.3),
                      child: Icon(
                        Icons.arrow_outward,
                        color: cs.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PsySpacing.lg),
              Text(
                action.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: PsySpacing.xs),
              Text(
                action.body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
