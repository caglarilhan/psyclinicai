/// Coverage for KvkkAcikRizaForm — required affirmations + signature
/// must all be present before the form yields a ConsentEntry; the
/// emitted entry must carry the KVKK md. 6 ConsentKind and the
/// policy version the form was anchored to.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/widgets/consent/kvkk_acik_riza_form.dart';

Widget _host({required void Function(ConsentEntry) onSign}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: KvkkAcikRizaForm(
          patientId: 'pat-1',
          patientName: 'Demo Hasta',
          policyVersion: 'kvkk-aydinlatma-v2026.06',
          onSign: onSign,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('submit button is disabled until both boxes + signature filled', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ConsentEntry? signed;
    await tester.pumpWidget(_host(onSign: (e) => signed = e));
    await tester.pump();

    final button = find.byKey(const Key('kvkkAcikRiza.submit'));
    expect((tester.widget(button) as ButtonStyleButton).onPressed, isNull);

    // Check first box only — still disabled.
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump();
    expect((tester.widget(button) as ButtonStyleButton).onPressed, isNull);

    // Check second box + still no signature — disabled.
    await tester.tap(find.byType(CheckboxListTile).last);
    await tester.pump();
    expect((tester.widget(button) as ButtonStyleButton).onPressed, isNull);

    // Enter signature — now enabled.
    await tester.enterText(find.byType(TextField), 'Demo Hasta');
    await tester.pump();
    expect((tester.widget(button) as ButtonStyleButton).onPressed, isNotNull);

    await tester.tap(button);
    await tester.pump();
    expect(signed, isNotNull);
    expect(signed!.kind, ConsentKind.kvkkSpecialCategoryHealth);
    expect(signed!.policyVersion, 'kvkk-aydinlatma-v2026.06');
    expect(signed!.signature, 'Demo Hasta');
    expect(signed!.patientId, 'pat-1');
  });

  testWidgets('whitespace-only signature is rejected', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ConsentEntry? signed;
    await tester.pumpWidget(_host(onSign: (e) => signed = e));
    await tester.pump();

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump();
    await tester.tap(find.byType(CheckboxListTile).last);
    await tester.pump();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    final button = find.byKey(const Key('kvkkAcikRiza.submit'));
    expect((tester.widget(button) as ButtonStyleButton).onPressed, isNull);
    expect(signed, isNull);
  });

  testWidgets('renders the Turkish header + checkbox copy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_host(onSign: (_) {}));
    await tester.pump();

    expect(find.text('KVKK md. 6 — Açık Rıza Beyanı'), findsOneWidget);
    expect(
      find.text('Açık rıza veriyorum (KVKK md. 6/2 ve md. 6/3).'),
      findsOneWidget,
    );
  });
}
