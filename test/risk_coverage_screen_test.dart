/// Coverage for RiskCoverageScreen — empty-ledger empty state, KPI
/// row, per-category breakdown, open-list rendering, and the
/// acknowledge button round-trip (ledger updates → screen rebuilds).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/admin/risk_coverage_screen.dart';
import 'package:psyclinicai/services/copilot/risk_signal_service.dart';
import 'package:psyclinicai/services/data/risk_signal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

PersistedRiskSignal _sig({
  String id = 's',
  String sessionId = 'sess-1',
  RiskCategory category = RiskCategory.suicidalIdeation,
  RiskSeverity severity = RiskSeverity.high,
  bool acknowledged = false,
}) => PersistedRiskSignal(
  id: id,
  sessionId: sessionId,
  category: category,
  severity: severity,
  matchedText: 'matched',
  snippet: 'context snippet',
  source: RiskSource.lexicon,
  at: DateTime.utc(2026, 6, 24, 14),
  acknowledged: acknowledged,
);

Future<RiskSignalRepository> _seed(
  String bucket, {
  List<PersistedRiskSignal> rows = const [],
}) async {
  final repo = RiskSignalRepository(storageBucket: bucket);
  await repo.initialize();
  for (final r in rows) {
    await repo.save(r);
  }
  return repo;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final secureStore = <String, String>{};
  Object? handleSecureStorage(MethodCall call) {
    final args = call.arguments as Map<Object?, Object?>;
    final key = args['key'] as String? ?? '';
    switch (call.method) {
      case 'read':
        return secureStore[key];
      case 'write':
        secureStore[key] = (args['value'] as String?) ?? '';
        return null;
      case 'delete':
        secureStore.remove(key);
        return null;
      case 'containsKey':
        return secureStore.containsKey(key);
      case 'readAll':
        return Map<String, String>.from(secureStore);
      case 'deleteAll':
        secureStore.clear();
        return null;
    }
    return null;
  }

  setUp(() {
    secureStore.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => handleSecureStorage(call),
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  Widget app(Widget home) => MediaQuery(
    data: const MediaQueryData(size: Size(1800, 1800), disableAnimations: true),
    child: MaterialApp(home: home),
  );

  Future<void> pumpAt1800(WidgetTester tester, Widget home) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(home));
    await tester.pumpAndSettle();
  }

  testWidgets('empty ledger renders the no-signals empty state', (
    tester,
  ) async {
    final repo = await _seed('rs_test_screen_empty');
    await pumpAt1800(tester, RiskCoverageScreen(repo: repo));
    expect(find.text('No signals recorded yet'), findsOneWidget);
    expect(find.text('Acknowledge'), findsNothing);
  });

  testWidgets('renders KPI row + breakdown when signals exist', (tester) async {
    final repo = await _seed(
      'rs_test_screen_kpis',
      rows: [
        _sig(id: 'a', acknowledged: true),
        _sig(id: 'b'),
        _sig(id: 'c', category: RiskCategory.selfHarm, acknowledged: true),
      ],
    );
    await pumpAt1800(tester, RiskCoverageScreen(repo: repo));
    expect(find.text('Total signals'.toUpperCase()), findsOneWidget);
    expect(find.text('Acknowledged'.toUpperCase()), findsOneWidget);
    expect(find.text('Coverage rate'.toUpperCase()), findsOneWidget);
    expect(find.text('Per-category breakdown'), findsOneWidget);
    expect(find.text('Suicidal ideation'), findsOneWidget);
    expect(find.text('Self-harm'), findsOneWidget);
  });

  testWidgets('unacknowledged high-severity row exposes Acknowledge button', (
    tester,
  ) async {
    final repo = await _seed(
      'rs_test_screen_ack',
      rows: [_sig(id: 'a')],
    );
    await pumpAt1800(tester, RiskCoverageScreen(repo: repo));
    expect(find.text('Acknowledge'), findsOneWidget);
  });

  testWidgets('tapping Acknowledge flips the row + rebuilds the screen', (
    tester,
  ) async {
    final repo = await _seed(
      'rs_test_screen_ack_flow',
      rows: [_sig(id: 'a')],
    );
    await pumpAt1800(tester, RiskCoverageScreen(repo: repo));

    await tester.tap(find.text('Acknowledge'));
    await tester.pumpAndSettle();

    expect(find.text('Acknowledge'), findsNothing);
    expect(
      find.textContaining('every elevated and high signal is acknowledged'),
      findsOneWidget,
    );
    final updated = repo.all.firstWhere((s) => s.id == 'a');
    expect(updated.acknowledged, isTrue);
  });
}
