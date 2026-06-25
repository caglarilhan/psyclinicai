/// Coverage for the consent-center KVKK modal wire-up:
///   * tapping the KVKK tile's "Record consent" CTA opens a bottom
///     sheet hosting the KvkkIntakeSlot form (NOT the typed-stub
///     record path used by the other consent kinds),
///   * signing the form persists a ConsentEntry under
///     `ConsentKind.kvkkSpecialCategoryHealth` via the in-memory repo
///     and the modal closes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/screens/patients/consent_center_screen.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';
import 'package:psyclinicai/widgets/consent/kvkk_acik_riza_form.dart';
import 'package:psyclinicai/widgets/consent/kvkk_intake_slot.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(900, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    const MaterialApp(
      home: ConsentCenterScreen(patientId: 'p-1', patientName: 'Demo Hasta'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    InMemoryConsentEntryRepository.instance.clearForTesting();
  });

  testWidgets(
    'tapping the KVKK tile CTA opens a modal hosting KvkkIntakeSlot',
    (tester) async {
      await _pump(tester);

      // Locate the KVKK tile by its Turkish label, then tap the
      // sibling "Record consent" CTA.
      final label = find.text('KVKK md. 6 — açık rıza (sağlık verisi)');
      await tester.ensureVisible(label);
      expect(label, findsOneWidget);

      final card = find.ancestor(of: label, matching: find.byType(Card));
      final cta = find.descendant(
        of: card,
        matching: find.widgetWithText(FilledButton, 'Record consent'),
      );
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      // Modal hosts the slot — form inside.
      expect(find.byType(KvkkIntakeSlot), findsOneWidget);
      expect(find.byType(KvkkAcikRizaForm), findsOneWidget);
    },
  );

  testWidgets(
    'signing the modal form persists ConsentEntry + closes the modal',
    (tester) async {
      await _pump(tester);

      final label = find.text('KVKK md. 6 — açık rıza (sağlık verisi)');
      await tester.ensureVisible(label);
      final card = find.ancestor(of: label, matching: find.byType(Card));
      final cta = find.descendant(
        of: card,
        matching: find.widgetWithText(FilledButton, 'Record consent'),
      );
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      // Sign the form.
      final boxes = find.descendant(
        of: find.byType(KvkkAcikRizaForm),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(boxes.first);
      await tester.pump();
      await tester.tap(boxes.last);
      await tester.pump();
      final sig = find.descendant(
        of: find.byType(KvkkAcikRizaForm),
        matching: find.byType(TextField),
      );
      await tester.enterText(sig, 'Demo Hasta');
      await tester.pump();
      await tester.tap(find.byKey(const Key('kvkkAcikRiza.submit')));
      await tester.pumpAndSettle();

      // Repository holds the entry.
      final active = InMemoryConsentEntryRepository.instance.activeOf(
        'p-1',
        ConsentKind.kvkkSpecialCategoryHealth,
      );
      expect(active, isNotNull);
      expect(active!.signature, 'Demo Hasta');

      // Modal closed — the KVKK form no longer in the tree.
      expect(find.byType(KvkkIntakeSlot), findsNothing);

      // KVKK tile now shows "Active".
      final updatedLabel = find.text('KVKK md. 6 — açık rıza (sağlık verisi)');
      final updatedCard = find.ancestor(
        of: updatedLabel,
        matching: find.byType(Card),
      );
      expect(
        find.descendant(of: updatedCard, matching: find.text('Active')),
        findsOneWidget,
      );
    },
  );
}
