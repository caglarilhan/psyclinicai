/// Shared chrome for the 5-step onboarding wizard:
/// - [ProgressBar]: filled-vs-empty pill row sized for `total` steps.
/// - [OnboardingNavBar]: bottom Back + Continue/Finish row with the
///   standard 720-px max-width constraint the steps also use.
/// - [StepShell]: eyebrow + title + lede + scrolling body that every
///   step composes; centred at 720 px so type sizes stay calm.
/// - [ChoiceCard]: tap-to-select bordered card used by the practice,
///   sample-data and first-action steps.
/// - [Bullet]: small indented bullet line used in step bodies.
///
/// HIGH-class refactor (audit 2026-06-21): extracted from
/// onboarding_screen.dart so the screen owns its state machine
/// (page controller + finish/skip flow) only.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/ds/psy_button.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.step,
    required this.total,
    required this.cs,
  });
  final int step;
  final int total;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.xxl,
        vertical: PsySpacing.md,
      ),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? cs.primary
                    : cs.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class OnboardingNavBar extends StatelessWidget {
  const OnboardingNavBar({
    super.key,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onNext,
    required this.cs,
  });
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final isLast = step == total - 1;
    return Container(
      // Tighter top + bottom — Continue sits closer to the content instead of
      // hovering ~80px below it on short steps.
      padding: const EdgeInsets.fromLTRB(
        PsySpacing.xxl,
        PsySpacing.sm,
        PsySpacing.xxl,
        PsySpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            children: [
              PsyButton(
                label: 'Back',
                icon: Icons.arrow_back,
                variant: PsyButtonVariant.ghost,
                onPressed: step == 0 ? null : onBack,
              ),
              const Spacer(),
              PsyButton(
                label: isLast ? 'Finish & start' : 'Continue',
                trailingIcon: isLast
                    ? Icons.rocket_launch
                    : Icons.arrow_forward,
                size: PsyButtonSize.lg,
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepShell extends StatelessWidget {
  const StepShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.lede,
    required this.children,
  });
  final String eyebrow;
  final String title;
  final String lede;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.xxl,
        vertical: PsySpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: PsySpacing.lg),
              Text(
                lede,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: PsySpacing.xxl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.selected,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    required this.cs,
    required this.theme,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PsyRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        // Compact rev: padding lg→md, icon 40→36, title titleMedium→
        // titleSmall+w700, body bodyMedium→bodySmall. Net ~22% height drop
        // so all role choices fit above the fold on 390-wide phones.
        padding: const EdgeInsets.all(PsySpacing.md),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PsyRadius.md),
              ),
              child: Icon(icon, color: cs.primary, size: 20),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: cs.primary, size: 22)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: cs.outlineVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class Bullet extends StatelessWidget {
  const Bullet({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 12),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
