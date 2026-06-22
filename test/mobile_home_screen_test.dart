/// CI #6 close — smoke coverage for the mobile-specific home
/// screen. Uses a SliverAppBar + 4-tab NavigationBar with
/// auto-scrolling page view in the hero; broken render would
/// silently break the mobile app's primary entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/screens/mobile/mobile_home_screen.dart';
import 'package:psyclinicai/services/language_service.dart';

void main() {
  testWidgets('renders the mobile home shell + bottom navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final languageService = LanguageService();

    await tester.pumpWidget(
      ChangeNotifierProvider<LanguageService>.value(
        value: languageService,
        child: const MaterialApp(home: MobileHomeScreen()),
      ),
    );
    // Pump a couple of frames so the SliverAppBar + BottomNavBar
    // layout passes complete. We do NOT pumpAndSettle because the
    // screen schedules an autoscroll Future.delayed that
    // recursively reschedules itself.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Swallow the missing-asset exception (assets/images/pattern.png
    // is not bundled into the test asset bundle).
    tester.takeException();

    // BottomNavigationBar items — labels come from LanguageService
    // which defaults to Turkish. We assert the well-known label
    // "Profil" (4th tab is hard-coded in the screen source).
    expect(find.text('Profil'), findsOneWidget);
    // Brand icon — the SliverAppBar + multiple feature tiles paint
    // the psychology icon; assert "at least one" so we tolerate the
    // repetition without pinning a specific widget tree depth.
    expect(find.byIcon(Icons.psychology), findsWidgets);

    // Replace the widget tree with an empty placeholder, then pump
    // past the 3s autoscroll mark so the `if (mounted)` guard fires
    // and the recursive Future chain terminates cleanly before the
    // test exits.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
  });
}
