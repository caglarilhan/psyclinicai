/// Mobile-responsive coverage for the screener-action row that lives
/// inside PatientDetailScreen. The full screen is too entangled
/// (Firebase, Provider, AppShell) for a narrow-viewport widget test,
/// so we isolate the part of the layout that actually changes when
/// the viewport drops to phone width.
///
/// Catches the regression where PHQ-9 + GAD-7 + View trend sat in
/// a single Row with a Spacer between siblings — at 360px the row
/// overflowed the screen by ~70px and the View-trend button fell
/// off the right edge. The buttons now sit in a Wrap and remain
/// reachable on the narrowest production device.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/patients/patient_detail_screen.dart';
import 'package:psyclinicai/screens/patients/patient_list_screen.dart'
    show PatientDetailArgs;

void main() {
  Widget hostedAt(double width, Widget child) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, 1200)),
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('SendScreenerActions reflows without overflow at 360px', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final caught = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = caught.add;
    addTearDown(() => FlutterError.onError = previous);

    await tester.pumpWidget(
      hostedAt(
        360,
        const SendScreenerActions(
          args: PatientDetailArgs(id: 'demo-1', name: 'John Demo'),
        ),
      ),
    );
    await tester.pump();

    final overflow = caught.where(
      (e) => e.exceptionAsString().contains('overflowed by'),
    );
    expect(
      overflow,
      isEmpty,
      reason:
          'Layout overflow at 360px: '
          '${overflow.map((e) => e.exceptionAsString()).join('; ')}',
    );

    expect(find.text('PHQ-9'), findsOneWidget);
    expect(find.text('GAD-7'), findsOneWidget);
    expect(find.text('View trend'), findsOneWidget);
  });

  testWidgets('SendScreenerActions keeps a single-row layout at 1400px', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      hostedAt(
        1400,
        const SendScreenerActions(
          args: PatientDetailArgs(id: 'demo-1', name: 'John Demo'),
        ),
      ),
    );
    await tester.pump();

    final phq = tester.getCenter(find.text('PHQ-9'));
    final view = tester.getCenter(find.text('View trend'));
    // Same Wrap run → identical y coordinate.
    expect(phq.dy, closeTo(view.dy, 1.0));
  });
}
