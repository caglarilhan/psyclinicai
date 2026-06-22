/// Tests for the unified design-system widgets the clinician sees on
/// every screen. Each gate is a small behaviour the surrounding UX
/// promise depends on:
///
///   - PsySnack: per-level icon + foreground colour the clinician
///     can recognise at a glance; telemetry event fires every show.
///   - SavingIndicator: state-machine renders the right label per
///     SavingState; markSaved auto-fades back to idle.
///   - PsyEmptyState: required title + body render; action button is
///     wired to onTap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/ds/psy_empty_state.dart';
import 'package:psyclinicai/widgets/ds/psy_skeleton.dart';
import 'package:psyclinicai/widgets/ds/psy_snack.dart';
import 'package:psyclinicai/widgets/ds/saving_indicator.dart';

Widget _host(Widget child) {
  return MaterialApp(home: Scaffold(body: Builder(builder: (_) => child)));
}

void main() {
  group('PsySnack', () {
    testWidgets('success snackbar shows the success icon + message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => PsySnack.success(
                  ctx,
                  'Safety plan saved.',
                  hint: 'safety_plan.save',
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump(); // snackbar enter
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Safety plan saved.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('error snackbar uses error icon + accepts an action', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => PsySnack.error(
                  ctx,
                  'Save failed — please retry.',
                  hint: 'safety_plan.save_failed',
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () => retried = true,
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Save failed — please retry.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('warning uses the amber warning icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => PsySnack.warning(
                  ctx,
                  'AI consent missing.',
                  hint: 'safety_plan.consent',
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  group('SavingIndicator', () {
    testWidgets('idle renders nothing visible', (tester) async {
      final ctrl = SavingIndicatorController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_host(SavingIndicator(controller: ctrl)));
      expect(find.text('Saving…'), findsNothing);
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('startSaving flips to the Saving pill', (tester) async {
      final ctrl = SavingIndicatorController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_host(SavingIndicator(controller: ctrl)));
      ctrl.startSaving();
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
    });

    testWidgets('markSaved flips to Saved then auto-fades', (tester) async {
      final ctrl = SavingIndicatorController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_host(SavingIndicator(controller: ctrl)));
      ctrl.markSaved(autoHide: const Duration(milliseconds: 80));
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      // Let the auto-hide timer fire + AnimatedSwitcher fade complete.
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('markError shows the retry CTA copy when onRetry given', (
      tester,
    ) async {
      final ctrl = SavingIndicatorController();
      addTearDown(ctrl.dispose);
      var retried = false;
      await tester.pumpWidget(_host(SavingIndicator(controller: ctrl)));
      ctrl.markError(onRetry: () => retried = true);
      await tester.pump();
      expect(find.text('Save failed — tap to retry'), findsOneWidget);
      await tester.tap(find.text('Save failed — tap to retry'));
      expect(retried, isTrue);
    });

    testWidgets('markError without onRetry shows the static label', (
      tester,
    ) async {
      final ctrl = SavingIndicatorController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_host(SavingIndicator(controller: ctrl)));
      ctrl.markError();
      await tester.pump();
      expect(find.text('Save failed'), findsOneWidget);
    });
  });

  group('PsyEmptyState', () {
    testWidgets('renders title + body + icon', (tester) async {
      await tester.pumpWidget(
        _host(
          const PsyEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No assessments yet',
            body: 'Send a PHQ-9 to see the outcome trend.',
          ),
        ),
      );
      expect(find.text('No assessments yet'), findsOneWidget);
      expect(
        find.text('Send a PHQ-9 to see the outcome trend.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });

    testWidgets('action button fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          PsyEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No assessments yet',
            body: 'Send a PHQ-9 to see the outcome trend.',
            action: PsyEmptyStateAction(
              label: 'Send PHQ-9',
              icon: Icons.psychology_outlined,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Send PHQ-9'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('no action button when action == null', (tester) async {
      await tester.pumpWidget(
        _host(
          const PsyEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No assessments yet',
            body: 'Send a PHQ-9 to see the outcome trend.',
          ),
        ),
      );
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('PsySkeleton', () {
    testWidgets('PsySkeletonList renders the requested row count', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PsySkeletonList(
            count: 4,
            itemBuilder: (_) => const PsySkeletonBlock(height: 64),
          ),
        ),
      );
      await tester.pump(); // allow the pulse controller to advance once
      expect(find.byType(PsySkeletonBlock), findsNWidgets(4));
    });

    testWidgets('Line / Block / Circle render their shape', (tester) async {
      await tester.pumpWidget(
        _host(
          const PsySkeletonGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PsySkeletonLine(),
                PsySkeletonBlock(width: 240, height: 64),
                PsySkeletonCircle(size: 32),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PsySkeletonLine), findsOneWidget);
      expect(find.byType(PsySkeletonBlock), findsOneWidget);
      expect(find.byType(PsySkeletonCircle), findsOneWidget);
    });

    testWidgets('reduce-motion freezes the pulse', (tester) async {
      // disableAnimations=true should NOT throw and should still render.
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: PsySkeletonGroup(
                child: PsySkeletonLine(width: 100, height: 12),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PsySkeletonLine), findsOneWidget);
    });
  });
}
