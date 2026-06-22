/// CI #6 close — smoke coverage for the e-prescribing screen.
/// The screen is currently a coming-soon scaffold (SureScripts +
/// DEA EPCS GA Q4 2026), so the only behaviour worth gating is
/// that the AppShell + market picker card renders without throwing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/e_prescription/e_prescription_screen.dart';

void main() {
  testWidgets('renders the e-prescribing roadmap shell', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: EPrescriptionScreen()));
    await tester.pumpAndSettle();

    expect(find.text('e-Prescribing'), findsWidgets);
    // The current copy promises a Q4 2026 GA — anchor on the
    // SureScripts roadmap row.
    expect(find.textContaining('SureScripts'), findsWidgets);
  });
}
