/// Coverage for the KVKK intake slot — the widget that hosts the
/// açık rıza form on the intake screen + the consent center:
///   * unsigned state renders the form,
///   * signing flips the slot to the confirmation tile,
///   * the signed ConsentEntry lands in
///     InMemoryConsentEntryRepository with the right kind +
///     policyVersion + patient id,
///   * initiallySigned=true short-circuits straight to the
///     confirmation tile (re-entry path).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';
import 'package:psyclinicai/widgets/consent/kvkk_acik_riza_form.dart';
import 'package:psyclinicai/widgets/consent/kvkk_intake_slot.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  setUp(() {
    InMemoryConsentEntryRepository.instance.clearForTesting();
  });

  testWidgets('unsigned slot renders the açık rıza form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const KvkkIntakeSlot(
          patientId: 'pat-1',
          patientName: 'Demo',
          policyVersion: 'kvkk-aydinlatma-v2026.06',
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(KvkkAcikRizaForm), findsOneWidget);
    expect(find.byIcon(Icons.verified_user), findsNothing);
  });

  testWidgets('signing flips the slot + persists a ConsentEntry', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var onSignedFired = false;
    await tester.pumpWidget(
      _host(
        KvkkIntakeSlot(
          patientId: 'pat-1',
          patientName: 'Demo',
          policyVersion: 'kvkk-aydinlatma-v2026.06',
          onSigned: () => onSignedFired = true,
        ),
      ),
    );
    await tester.pump();

    final boxes = find.byType(CheckboxListTile);
    await tester.tap(boxes.first);
    await tester.pump();
    await tester.tap(boxes.last);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Demo');
    await tester.pump();
    await tester.tap(find.byKey(const Key('kvkkAcikRiza.submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Slot collapsed; repository holds the entry.
    expect(find.byType(KvkkAcikRizaForm), findsNothing);
    expect(find.byIcon(Icons.verified_user), findsOneWidget);
    expect(onSignedFired, isTrue);

    final active = InMemoryConsentEntryRepository.instance.activeOf(
      'pat-1',
      ConsentKind.kvkkSpecialCategoryHealth,
    );
    expect(active, isNotNull);
    expect(active!.signature, 'Demo');
    expect(active.policyVersion, 'kvkk-aydinlatma-v2026.06');
  });

  testWidgets(
    'initiallySigned short-circuits straight to the confirmation tile',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const KvkkIntakeSlot(
            patientId: 'pat-1',
            patientName: 'Demo',
            policyVersion: 'kvkk-aydinlatma-v2026.06',
            initiallySigned: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KvkkAcikRizaForm), findsNothing);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
    },
  );
}
