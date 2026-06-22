import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/auth/clinician_role.dart';
import '../../services/copilot/api_key_storage.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/onboarding_service.dart';
import '../../services/data/seed_service.dart';
import '../../services/data/telemetry_service.dart';
import 'onboarding_chrome.dart';
import 'onboarding_steps.dart';

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
      unawaited(_finish());
      return;
    }
    setState(() => _step += 1);
    unawaited(
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
    unawaited(
      _ctrl.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Future<void> _finish() async {
    final uid = FirebaseAuthService.instance.profile?.userId;

    final key = _byokCtrl.text.trim();
    if (key.isNotEmpty) {
      await ApiKeyStorage.instance.setAnthropicKey(key);
      unawaited(
        TelemetryService.instance.capture(TelemetryEvents.onboardingByokSaved),
      );
    }

    if (_seedDemo) {
      // Best-effort — silent no-op in demo mode (Firebase off).
      await SeedService.instance.seedDemoChart();
      unawaited(
        TelemetryService.instance.capture(
          TelemetryEvents.onboardingSeedRequested,
        ),
      );
    }

    // Even without Firebase (demo mode), persist a local 'demo' flag so the
    // next sign-in lands on /dashboard instead of replaying the wizard.
    await OnboardingService.instance.markCompleted(uid ?? 'demo');

    if (!mounted) return;
    final route = switch (_firstAction) {
      'session' => '/session',
      'superbill' => '/superbill',
      'phq9' => '/assessments/phq9',
      _ => '/dashboard',
    };
    unawaited(
      TelemetryService.instance.capture(
        TelemetryEvents.onboardingFinished,
        properties: {'first_action': _firstAction},
      ),
    );
    unawaited(Navigator.of(context).pushReplacementNamed(route));
  }

  Future<void> _skip() async {
    unawaited(
      TelemetryService.instance.capture(TelemetryEvents.onboardingSkipped),
    );
    final uid = FirebaseAuthService.instance.profile?.userId;
    await OnboardingService.instance.markCompleted(uid ?? 'demo');
    if (!mounted) return;
    unawaited(Navigator.of(context).pushReplacementNamed('/dashboard'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = FirebaseAuthService.instance.profile;
    final firstName = profile?.fullName.split(' ').first;
    final roleLabel = profile?.role.label ?? 'Clinician';

    return Scaffold(
      appBar: AppBar(
        // Same defensive scale-down as the landing AppBar — keep the brand row
        // from overflowing the middle slot on narrow phones.
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              Icon(Icons.psychology, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Welcome to PsyClinicAI',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: _skip, child: const Text('Skip for now')),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          ProgressBar(step: _step, total: _totalSteps, cs: cs),
          Expanded(
            child: PageView(
              controller: _ctrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                WelcomeStep(
                  firstName: firstName,
                  role: roleLabel,
                  theme: theme,
                  cs: cs,
                ),
                PracticeStep(
                  selected: _practiceType,
                  onChanged: (v) => setState(() => _practiceType = v),
                  theme: theme,
                  cs: cs,
                ),
                ByokStep(ctrl: _byokCtrl, theme: theme, cs: cs),
                SampleDataStep(
                  seed: _seedDemo,
                  onChanged: (v) => setState(() => _seedDemo = v),
                  theme: theme,
                  cs: cs,
                ),
                FirstActionStep(
                  selected: _firstAction,
                  onChanged: (v) => setState(() => _firstAction = v),
                  theme: theme,
                  cs: cs,
                ),
              ],
            ),
          ),
          OnboardingNavBar(
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
