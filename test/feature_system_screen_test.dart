/// CI #6 close — smoke coverage for the Feature System catalog
/// screen. Self-contained (no repos / no network), so the screen
/// renders the role + category filters and the catalog body from
/// the in-screen feature list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/feature_system/feature_system_screen.dart';

void main() {
  testWidgets('renders the catalog title + role/category filters', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: FeatureSystemScreen()));
    await tester.pumpAndSettle();

    expect(find.text('PsyClinicAI — Feature System'), findsOneWidget);
    // Role + category filter chips/labels surface the default
    // selection ("Psychiatrist" + "All"); copy regressions would
    // mean the filter bar drifted from the in-screen catalog.
    expect(find.textContaining('Psychiatrist'), findsWidgets);
  });
}
