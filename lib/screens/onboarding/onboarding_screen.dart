import 'package:flutter/material.dart';

import '../../services/copilot/api_key_storage.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firestore_schema.dart';
import '../../services/data/onboarding_service.dart';
import '../../services/data/seed_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// 5-step first-run wizard. Replaces the previously-empty post-signup
/// landing in the dashboard so a new clinician sees structured value in
/// the first five minutes.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _step = 0;
  static const _totalSteps = 5;

  String _practiceType = 'solo';
  final _byokCtrl = TextEditingController();
  bool _seedDemo = true;
  String _firstAction = 'session';

  @override
  void dispose() {
    _ctrl.dispose();
    _byokCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step >= _totalSteps - 1) {
      _finish();
      return;
    }
    setState(() => _step += 1);
    _ctrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic);
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
    _ctrl.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic);
  }

  Future<void> _finish() async {
    final uid = FirebaseAuthService.instance.profile?.userId;

    final key = _byokCtrl.text.trim();
    if (key.isNotEmpty) {
      await ApiKeyStorage.instance.setAnthropicKey(key);
    }

    if (_seedDemo) {
      // Best-effort — silent no-op in demo mode (Firebase off).
      await SeedService.instance.seedDemoChart();
    }

    if (uid != null) {
      await OnboardingService.instance.markCompleted(uid);
    }

    if (!mounted) return;
    final route = switch (_firstAction) {
      'session' => '/session',
      'superbill' => '/superbill',
      'phq9' => '/assessments/phq9',
      _ => '/dashboard',
    };
    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _skip() async {
    final uid = FirebaseAuthService.instance.profile?.userId;
    if (uid != null) {
      await OnboardingService.instance.markCompleted(uid);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = FirebaseAuthService.instance.profile;
    final firstName = profile?.fullName.split(' ').first ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology, color: cs.primary, size: 24),
            const SizedBox(width: 8),
            Text('Welcome to PsyClinicAI',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip for now'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _ProgressBar(step: _step, total: _totalSteps, cs: cs),
          Expanded(
            child: PageView(
              controller: _ctrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _WelcomeStep(
                    firstName: firstName,
                    role: profile?.role.label ?? 'Clinician',
                    theme: theme,
                    cs: cs),
                _PracticeStep(
                  selected: _practiceType,
                  onChanged: (v) => setState(() => _practiceType = v),
                  theme: theme,
                  cs: cs,
                ),
                _ByokStep(ctrl: _byokCtrl, theme: theme, cs: cs),
                _SampleDataStep(
                  seed: _seedDemo,
                  onChanged: (v) => setState(() => _seedDemo = v),
                  theme: theme,
                  cs: cs,
                ),
                _FirstActionStep(
                  selected: _firstAction,
                  onChanged: (v) => setState(() => _firstAction = v),
                  theme: theme,
                  cs: cs,
                ),
              ],
            ),
          ),
          _NavBar(
            step: _step,
            total: _totalSteps,
            onBack: _back,
            onNext: _next,
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar(
      {required this.step, required this.total, required this.cs});
  final int step;
  final int total;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.xxl, vertical: PsySpacing.md),
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

class _NavBar extends StatelessWidget {
  const _NavBar({
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
      padding: const EdgeInsets.fromLTRB(
          PsySpacing.xxl, PsySpacing.lg, PsySpacing.xxl, PsySpacing.xxl),
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
                trailingIcon:
                    isLast ? Icons.rocket_launch : Icons.arrow_forward,
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

// ───────── Step 1 ─────────
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep(
      {required this.firstName,
      required this.role,
      required this.theme,
      required this.cs});
  final String firstName;
  final String role;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      eyebrow: 'Step 1 of 5',
      title: 'Welcome, $firstName.',
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
                child: Icon(Icons.badge_outlined,
                    color: cs.onPrimary, size: 28),
              ),
              const SizedBox(width: PsySpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstName,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(role,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.xl),
        Text(
          'What happens next:',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: PsySpacing.md),
        const _Bullet(text: 'Tell us your practice type'),
        const _Bullet(
            text: 'Paste your Anthropic BYOK key (or skip for now)'),
        const _Bullet(
            text: 'Choose if we seed a synthetic demo patient'),
        const _Bullet(text: 'Pick what you want to do first'),
      ],
    );
  }
}

// ───────── Step 2 ─────────
class _PracticeStep extends StatelessWidget {
  const _PracticeStep(
      {required this.selected,
      required this.onChanged,
      required this.theme,
      required this.cs});
  final String selected;
  final ValueChanged<String> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final options = <(String, IconData, String, String)>[
      ('solo', Icons.person_outline, 'Solo practice',
          'One clinician. The most common pilot starting point.'),
      ('group', Icons.groups_outlined, 'Group practice',
          '2–10 clinicians sharing patients and superbills.'),
      ('telehealth', Icons.video_call_outlined, 'Telehealth-first',
          'All sessions remote. Audio still stays on each device.'),
    ];
    return _StepShell(
      eyebrow: 'Step 2 of 5',
      title: 'How does your practice run?',
      lede:
          'This shapes which dashboard widgets show up first. You can '
          'change it any time in Settings.',
      children: options
          .map((o) => Padding(
                padding: const EdgeInsets.only(bottom: PsySpacing.md),
                child: _ChoiceCard(
                  selected: selected == o.$1,
                  icon: o.$2,
                  title: o.$3,
                  body: o.$4,
                  onTap: () => onChanged(o.$1),
                  cs: cs,
                  theme: theme,
                ),
              ))
          .toList(),
    );
  }
}

// ───────── Step 3 ─────────
class _ByokStep extends StatelessWidget {
  const _ByokStep(
      {required this.ctrl, required this.theme, required this.cs});
  final TextEditingController ctrl;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      eyebrow: 'Step 3 of 5',
      title: 'Bring your own Anthropic key.',
      lede:
          'PsyClinicAI never holds the BAA-protected data path — you '
          'sign the BAA directly with Anthropic and paste your key here. '
          'Skip if you want to explore demo mode first.',
      children: [
        TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'sk-ant-api03-…',
            hintText: 'Paste your Anthropic API key',
            prefixIcon: Icon(Icons.key_outlined),
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        Row(
          children: [
            Icon(Icons.lock_outline,
                size: 14, color: cs.onSurface.withValues(alpha: 0.55)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Stored in your browser keychain. Never sent to our '
                'servers; never logged.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.xl),
        PsyCard(
          tinted: true,
          padding: const EdgeInsets.all(PsySpacing.lg),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: cs.primary, size: 20),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Text(
                  'Need a key? Visit console.anthropic.com → API Keys → '
                  'Create. Costs ~\$0.003 per session today.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────── Step 4 ─────────
class _SampleDataStep extends StatelessWidget {
  const _SampleDataStep(
      {required this.seed,
      required this.onChanged,
      required this.theme,
      required this.cs});
  final bool seed;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      eyebrow: 'Step 4 of 5',
      title: 'Seed a demo patient?',
      lede:
          'We can create one synthetic patient (John Demo) with two past '
          'sessions and a PHQ-9 history so your dashboard looks alive on '
          'day one. Pure demo data — no PHI, no audit trail.',
      children: [
        _ChoiceCard(
          selected: seed,
          icon: Icons.auto_awesome,
          title: 'Yes, give me a demo patient',
          body:
              'Seed John Demo + 2 sessions + 1 PHQ-9 + 1 superbill draft.',
          onTap: () => onChanged(true),
          cs: cs,
          theme: theme,
        ),
        const SizedBox(height: PsySpacing.md),
        _ChoiceCard(
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
class _FirstActionStep extends StatelessWidget {
  const _FirstActionStep(
      {required this.selected,
      required this.onChanged,
      required this.theme,
      required this.cs});
  final String selected;
  final ValueChanged<String> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final options = <(String, IconData, String, String)>[
      ('session', Icons.mic_none, 'Start a live session',
          'See the AI Co-Pilot in motion right now.'),
      ('superbill', Icons.receipt_long_outlined, 'Create a superbill',
          'CPT + ICD-10 + CMS-1500 PDF in under a minute.'),
      ('phq9', Icons.psychology_outlined, 'Send a PHQ-9',
          'Try the depression screener to see the outcome dashboard.'),
    ];
    return _StepShell(
      eyebrow: 'Step 5 of 5',
      title: 'What do you want to do first?',
      lede:
          "We'll drop you straight into that screen when you click Finish.",
      children: options
          .map((o) => Padding(
                padding: const EdgeInsets.only(bottom: PsySpacing.md),
                child: _ChoiceCard(
                  selected: selected == o.$1,
                  icon: o.$2,
                  title: o.$3,
                  body: o.$4,
                  onTap: () => onChanged(o.$1),
                  cs: cs,
                  theme: theme,
                ),
              ))
          .toList(),
    );
  }
}

// ───────── Shared widgets ─────────
class _StepShell extends StatelessWidget {
  const _StepShell({
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
          horizontal: PsySpacing.xxl, vertical: PsySpacing.xl),
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
              Text(title,
                  style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: PsySpacing.lg),
              Text(lede,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                    height: 1.55,
                  )),
              const SizedBox(height: PsySpacing.xxl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
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
        padding: const EdgeInsets.all(PsySpacing.xl),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.08)
              : cs.surface,
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PsyRadius.md),
              ),
              child: Icon(icon, color: cs.primary, size: 22),
            ),
            const SizedBox(width: PsySpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: PsySpacing.xs),
                  Text(body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      )),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: cs.primary, size: 24)
            else
              Icon(Icons.radio_button_unchecked,
                  color: cs.outlineVariant, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
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
            child: Text(text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.78),
                  height: 1.55,
                )),
          ),
        ],
      ),
    );
  }
}
