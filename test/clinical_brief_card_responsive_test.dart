/// Mobile-responsive coverage for ClinicalBriefCard.
///
/// The Session-prep title row used a `Row + Spacer + button` layout
/// that overflowed by ~268px on a 360-wide viewport (iPhone SE). It
/// now sits in a Wrap so the AI button can drop to a second run.
/// Pin the regression here so a future tweak that re-introduces a
/// fixed-width row trips the test.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/clinical_brief_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fssChannel = 'plugins.it_nomads.com/flutter_secure_storage';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Empty FSS backing — every repo bootstraps into a clean state.
    messenger.setMockMethodCallHandler(const MethodChannel(_fssChannel), (
      call,
    ) async {
      switch (call.method) {
        case 'read':
        case 'containsKey':
          return null;
        case 'readAll':
          return <String, String>{};
        default:
          return null;
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(const MethodChannel(_fssChannel), null);
  });

  testWidgets('ClinicalBriefCard renders at 360px without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final caught = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = caught.add;
    addTearDown(() => FlutterError.onError = previous);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClinicalBriefCard(
            patientId: 'demo-1',
            patientName: 'John Demo',
          ),
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

    // Header chips survive the reflow.
    expect(find.text('Session prep'), findsOneWidget);
    expect(find.text('Clinical Memory'), findsOneWidget);
  });
}
