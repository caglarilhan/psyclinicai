/// Widget coverage for SideEffectSheet — symptom field gates the
/// Save button, Save returns a populated MedicationSideEffect, and
/// moderate severity surfaces the tolerability-tile flag note.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/medication_side_effect.dart';
import 'package:psyclinicai/screens/medications/side_effect_sheet.dart';

Future<void> _pumpHost(
  WidgetTester tester,
  void Function(BuildContext) onTap,
) async {
  await tester.binding.setSurfaceSize(const Size(900, 1600));
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

  testWidgets('Save is disabled until a symptom is typed', (tester) async {
    await _pumpHost(tester, (context) {
      unawaited(
        showModalBottomSheet<MedicationSideEffect>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const SideEffectSheet(
            patientId: 'p1',
            medicationId: 'm1',
            clinicianId: 'c1',
          ),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    bool saveEnabled() {
      final btns = find
          .ancestor(
            of: find.text('Save side effect'),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          )
          .evaluate();
      return (btns.last.widget as ButtonStyleButton).enabled;
    }

    expect(saveEnabled(), isFalse);

    final symptomField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.hintText ?? '').contains('dry mouth'),
    );
    await tester.enterText(symptomField, 'Nausea');
    await tester.pump();
    expect(saveEnabled(), isTrue);
  });

  testWidgets('Save returns a populated MedicationSideEffect', (tester) async {
    MedicationSideEffect? captured;
    await _pumpHost(tester, (context) async {
      captured = await showModalBottomSheet<MedicationSideEffect>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const SideEffectSheet(
          patientId: 'p1',
          medicationId: 'm1',
          clinicianId: 'c1',
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final symptomField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.hintText ?? '').contains('dry mouth'),
    );
    await tester.enterText(symptomField, 'Drowsiness');
    await tester.pump();

    final save = find.text('Save side effect');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.symptom, 'Drowsiness');
    expect(captured!.patientId, 'p1');
    expect(captured!.medicationId, 'm1');
    expect(captured!.severity, SideEffectSeverity.mild);
  });

  testWidgets('Moderate severity surfaces the tolerability-tile flag', (
    tester,
  ) async {
    await _pumpHost(tester, (context) {
      unawaited(
        showModalBottomSheet<MedicationSideEffect>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const SideEffectSheet(
            patientId: 'p1',
            medicationId: 'm1',
            clinicianId: 'c1',
          ),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final moderate = find.text('Moderate');
    await tester.ensureVisible(moderate);
    await tester.tap(moderate);
    await tester.pumpAndSettle();
    expect(
      find.text('Moderate+ events flag the patient pulse tolerability tile.'),
      findsOneWidget,
    );
  });
}
