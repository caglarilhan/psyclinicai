/// Widget coverage for TemplatePickerSheet — lists all templates,
/// modality chip filters the list, "Use this template" returns the
/// chosen value.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/treatment_plan/template_picker_sheet.dart';
import 'package:psyclinicai/services/treatment_plan_templates.dart';

Future<void> _pumpHost(
  WidgetTester tester,
  void Function(BuildContext) onTap,
) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1800));
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => onTap(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders all six templates and the Use button is disabled', (
    tester,
  ) async {
    await _pumpHost(tester, (context) {
      unawaited(
        showModalBottomSheet<TreatmentPlanTemplate>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const TemplatePickerSheet(),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('CBT — Generalised anxiety'), findsOneWidget);
    expect(find.text('DBT — Emotion dysregulation'), findsOneWidget);
    expect(find.text('EMDR — PTSD'), findsOneWidget);
    expect(find.text('Family — Couple distress'), findsOneWidget);

    final use = find.ancestor(
      of: find.text('Use this template'),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    expect(use, findsOneWidget);
    expect((tester.widget(use.last) as ButtonStyleButton).enabled, isFalse);
  });

  testWidgets('modality chip filters the list', (tester) async {
    await _pumpHost(tester, (context) {
      unawaited(
        showModalBottomSheet<TreatmentPlanTemplate>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const TemplatePickerSheet(),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final cbtChip = find.widgetWithText(ChoiceChip, 'CBT');
    await tester.tap(cbtChip);
    await tester.pumpAndSettle();

    expect(find.text('CBT — Generalised anxiety'), findsOneWidget);
    expect(find.text('CBT — Major depression'), findsOneWidget);
    expect(find.text('DBT — Emotion dysregulation'), findsNothing);
    expect(find.text('EMDR — PTSD'), findsNothing);
  });

  testWidgets('picking a tile + Use returns the template', (tester) async {
    TreatmentPlanTemplate? captured;
    await _pumpHost(tester, (context) async {
      captured = await showModalBottomSheet<TreatmentPlanTemplate>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const TemplatePickerSheet(),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('EMDR — PTSD'));
    await tester.pumpAndSettle();

    final use = find.text('Use this template');
    await tester.ensureVisible(use);
    await tester.tap(use);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.id, 'emdr-ptsd');
  });
}
