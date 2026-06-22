/// The 5 PageView children of the onboarding wizard.
///
/// Each step is stateless and reads/writes its slice of state via
/// the props the screen passes in (`selected`, `seed`, `ctrl`,
/// `onChanged`). The screen still owns the underlying
/// `_OnboardingScreenState` fields — these widgets are pure render.
///
/// HIGH-class refactor (audit 2026-06-21): extracted from
/// onboarding_screen.dart so the steps live next to each other
/// instead of sprawling across the screen file.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/ds/psy_card.dart';
import 'onboarding_chrome.dart';

// ───────── Step 1 ─────────
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    super.key,
    required this.firstName,
    required this.role,
    required this.theme,
    required this.cs,
  });
  // null when there's no signed-in profile yet (demo mode) — the card shows
  // the role instead of a placeholder "there" name.
  final String? firstName;
  final String role;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final greeting = (firstName == null || firstName!.isEmpty)
        ? 'Welcome.'
        : 'Welcome, ${firstName!}.';
    final cardPrimary = (firstName == null || firstName!.isEmpty)
        ? role
        : firstName!;
    final cardSecondary = (firstName == null || firstName!.isEmpty)
        ? 'Licensed clinician'
        : role;
    return StepShell(
      eyebrow: 'Step 1 of 5',
      title: greeting,
      lede:
          "We'll have you ready in under four minutes. First — confirm "
          'your role so we can tailor the workspace.',
      children: [
        PsyCard(
          tinted: true,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.primary,
                child: Icon(
                  Icons.badge_outlined,
                  color: cs.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: PsySpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardPrimary,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cardSecondary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.xl),
        Text(
          'What happens next:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        const Bullet(text: 'Tell us your practice type'),
        const Bullet(text: 'Paste your Anthropic BYOK key (or skip for now)'),
        const Bullet(text: 'Choose if we seed a synthetic demo patient'),
        const Bullet(text: 'Pick what you want to do first'),
      ],
    );
  }
}

// ───────── Step 2 ─────────
class PracticeStep extends StatelessWidget {
  const PracticeStep({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.theme,
    required this.cs,
  });
  final String selected;
  final ValueChanged<String> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final options = <(String, IconData, String, String)>[
      (
        'solo',
        Icons.person_outline,
        'Solo practice',
        'One clinician. The most common pilot starting point.',
      ),
      (
        'group',
        Icons.groups_outlined,
        'Group practice',
        '2–10 clinicians sharing patients and superbills.',
      ),
      (
        'telehealth',
        Icons.video_call_outlined,
        'Telehealth-first',
        'All sessions remote. Audio still stays on each device.',
      ),
    ];
    return StepShell(
      eyebrow: 'Step 2 of 5',
      title: 'How does your practice run?',
      lede:
          'This shapes which dashboard widgets show up first. You can '
          'change it any time in Settings.',
      children: options
          .map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: ChoiceCard(
                selected: selected == o.$1,
                icon: o.$2,
                title: o.$3,
                body: o.$4,
                onTap: () => onChanged(o.$1),
                cs: cs,
                theme: theme,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ───────── Step 3 ─────────
class ByokStep extends StatelessWidget {
  const ByokStep({
    super.key,
    required this.ctrl,
    required this.theme,
    required this.cs,
  });
  final TextEditingController ctrl;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return StepShell(
      eyebrow: 'Step 3 of 5 · Optional',
      title: 'Start in demo mode.',
      lede:
          'Every feature works on demo data — no key needed. Add your '
          'Anthropic key later from Settings when you want live AI on real '
          'sessions.',
      children: [
        PsyCard(
          tinted: true,
          padding: const EdgeInsets.all(PsySpacing.lg),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: cs.primary, size: 22),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Text(
                  "Continue → you'll land on demo data with John Demo and "
                  'sample sessions. No card, no key, no commitment.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        // Advanced: clinicians who already have a key can paste it now.
        Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: PsySpacing.sm),
            title: Text(
              'I already have an Anthropic key',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              TextField(
                controller: ctrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'sk-ant-api03-…',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              const SizedBox(height: PsySpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Stored only on this device. Never sent to our servers.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────── Step 4 ─────────
class SampleDataStep extends StatelessWidget {
  const SampleDataStep({
    super.key,
    required this.seed,
    required this.onChanged,
    required this.theme,
    required this.cs,
  });
  final bool seed;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return StepShell(
      eyebrow: 'Step 4 of 5',
      title: 'Seed a demo patient?',
      lede:
          'We can create one synthetic patient (John Demo) with two past '
          'sessions and a PHQ-9 history so your dashboard looks alive on '
          'day one. Pure demo data — no PHI, no audit trail.',
      children: [
        ChoiceCard(
          selected: seed,
          icon: Icons.auto_awesome,
          title: 'Yes, give me a demo patient',
          body: 'Seed John Demo + 2 sessions + 1 PHQ-9 + 1 superbill draft.',
          onTap: () => onChanged(true),
          cs: cs,
          theme: theme,
        ),
        const SizedBox(height: PsySpacing.md),
        ChoiceCard(
          selected: !seed,
          icon: Icons.do_not_disturb_alt,
          title: 'No, start with an empty workspace',
          body:
              'I prefer the discipline of starting from zero. I can add '
              'a patient myself.',
          onTap: () => onChanged(false),
          cs: cs,
          theme: theme,
        ),
      ],
    );
  }
}

// ───────── Step 5 ─────────
class FirstActionStep extends StatelessWidget {
  const FirstActionStep({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.theme,
    required this.cs,
  });
  final String selected;
  final ValueChanged<String> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    // PHQ-9 first: a brand-new clinician likely has no patient yet, so an
    // assessment is the safest demo entry point. Live session next, superbill
    // last (depends on a logged session + diagnosis).
    final options = <(String, IconData, String, String)>[
      (
        'phq9',
        Icons.psychology_outlined,
        'Send a PHQ-9',
        'Try the depression screener to see the outcome dashboard.',
      ),
      (
        'session',
        Icons.mic_none,
        'Start a live session',
        'See the AI Co-Pilot in motion right now.',
      ),
      (
        'superbill',
        Icons.receipt_long_outlined,
        'Create a superbill',
        'CPT + ICD-10 + CMS-1500 PDF in under a minute.',
      ),
    ];
    return StepShell(
      eyebrow: 'Step 5 of 5',
      title: 'What do you want to do first?',
      lede: "We'll drop you straight into that screen when you click Finish.",
      children: options
          .map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: ChoiceCard(
                selected: selected == o.$1,
                icon: o.$2,
                title: o.$3,
                body: o.$4,
                onTap: () => onChanged(o.$1),
                cs: cs,
                theme: theme,
              ),
            ),
          )
          .toList(),
    );
  }
}
