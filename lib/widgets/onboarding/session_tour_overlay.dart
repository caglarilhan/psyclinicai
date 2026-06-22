/// Sprint 31 P2 — first-launch 4-step beacon tour for `/session`.
///
/// Renders on top of the session screen the very first time a
/// clinician opens it. Subsequent launches skip the overlay because
/// `SessionTourController.markSeen()` persists a flag through the
/// injected `TourPersistence`. The widget is intentionally pure-Dart
/// on the storage boundary — callers may swap in a fake for tests.
///
/// Skill-panel coverage: senior-frontend (state machine + widget
/// composition), apple-hig-expert (one-tap dismiss + safe-area
/// padding), onboarding-cro (telemetry emit on each step so the
/// activation funnel exposes drop-off).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/telemetry_service.dart';

/// Persistence contract — abstracted so unit tests inject an in-memory
/// stub without touching the secure-storage method channel.
abstract class TourPersistence {
  Future<bool> hasSeen();
  Future<void> markSeen();
}

/// In-memory implementation used by tests + by callers that don't want
/// to persist the flag (kiosk / shared-device installs).
class InMemoryTourPersistence implements TourPersistence {
  bool _seen = false;

  @override
  Future<bool> hasSeen() async => _seen;

  @override
  Future<void> markSeen() async {
    _seen = true;
  }
}

@immutable
class TourStep {
  const TourStep({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;
}

const List<TourStep> kDefaultSessionTour = [
  TourStep(
    title: '1. Paste or transcribe',
    body:
        'Paste a session transcript or tap Live STT to dictate. Audio '
        'never leaves the device — only the redacted text travels.',
    icon: Icons.mic_none,
  ),
  TourStep(
    title: '2. Review the draft SOAP',
    body:
        'The co-pilot drafts a SOAP / DAP / BIRP note in ~30 seconds. '
        'Edit inline — your edits never reach the language model.',
    icon: Icons.edit_note,
  ),
  TourStep(
    title: '3. Sign + export PDF',
    body:
        'Tap Sign + Export to seal the note and stamp the audit chain. '
        'PDF is ready for chart upload or insurance review.',
    icon: Icons.verified,
  ),
  TourStep(
    title: '4. Triage alerts panel',
    body:
        'Risk flags (C-SSRS, PHQ-9 item 9) surface here. Tap to open '
        'the escalation runbook for the patient.',
    icon: Icons.health_and_safety,
  ),
];

/// Stateful controller for the overlay. Exposed so tests can advance
/// the steps without rendering a real `MaterialApp`.
class SessionTourController extends ChangeNotifier {
  SessionTourController({
    List<TourStep> steps = kDefaultSessionTour,
    TourPersistence? persistence,
  }) : _steps = steps,
       _persistence = persistence ?? InMemoryTourPersistence();

  final List<TourStep> _steps;
  final TourPersistence _persistence;
  int _index = 0;
  bool _completed = false;

  int get currentIndex => _index;
  TourStep get currentStep => _steps[_index];
  bool get isFirstStep => _index == 0;
  bool get isLastStep => _index == _steps.length - 1;
  bool get isCompleted => _completed;
  int get totalSteps => _steps.length;

  Future<bool> shouldShow() async {
    final seen = await _persistence.hasSeen();
    return !seen;
  }

  Future<void> begin() async {
    unawaited(
      TelemetryService.instance.capture(
        TelemetryEvents.onboardingTourStarted,
        properties: {'total_steps': _steps.length},
      ),
    );
  }

  Future<void> next() async {
    if (_completed) return;
    if (_index < _steps.length - 1) {
      _index += 1;
      notifyListeners();
    } else {
      await _finish(reason: 'completed');
    }
  }

  Future<void> previous() async {
    if (_index > 0) {
      _index -= 1;
      notifyListeners();
    }
  }

  Future<void> skip() async {
    await _finish(reason: 'skipped');
  }

  Future<void> _finish({required String reason}) async {
    if (_completed) return;
    _completed = true;
    await _persistence.markSeen();
    unawaited(
      TelemetryService.instance.capture(
        reason == 'completed'
            ? TelemetryEvents.onboardingTourCompleted
            : TelemetryEvents.onboardingTourSkipped,
        properties: {'last_step_index': _index, 'total_steps': _steps.length},
      ),
    );
    notifyListeners();
  }
}

class SessionTourOverlay extends StatelessWidget {
  const SessionTourOverlay({super.key, required this.controller});

  final SessionTourController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isCompleted) return const SizedBox.shrink();
        final step = controller.currentStep;
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        return Material(
          color: Colors.black54,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              step.icon,
                              color: cs.onPrimaryContainer,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${controller.currentIndex + 1}'
                            ' / ${controller.totalSteps}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: cs.onSurface.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          TextButton(
                            onPressed: controller.skip,
                            child: const Text('Skip'),
                          ),
                          const Spacer(),
                          if (!controller.isFirstStep)
                            TextButton(
                              onPressed: controller.previous,
                              child: const Text('Back'),
                            ),
                          const SizedBox(width: 4),
                          FilledButton(
                            onPressed: controller.next,
                            child: Text(
                              controller.isLastStep ? 'Done' : 'Next',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
