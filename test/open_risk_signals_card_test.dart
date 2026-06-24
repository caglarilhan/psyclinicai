/// Coverage for OpenRiskSignalsCard — hidden on empty ledger,
/// renders top 3 unacknowledged elevated/high signals with
/// "Review all" link, and the "+N more" footer for >3 open rows.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/risk_signal_service.dart';
import 'package:psyclinicai/services/data/risk_signal_repository.dart';
import 'package:psyclinicai/widgets/dashboard/open_risk_signals_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fssChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

PersistedRiskSignal _sig({
  String id = 's',
  RiskCategory category = RiskCategory.suicidalIdeation,
  RiskSeverity severity = RiskSeverity.high,
  bool acknowledged = false,
  DateTime? at,
}) => PersistedRiskSignal(
  id: id,
  sessionId: 'sess-1',
  category: category,
  severity: severity,
  matchedText: 'matched',
  snippet: 'snippet for $id',
  source: RiskSource.lexicon,
  at: at ?? DateTime.utc(2026, 6, 24, 14),
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
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final backing = <String, String>{};
    messenger.setMockMethodCallHandler(_fssChannel, (call) async {
      switch (call.method) {
        case 'read':
          return backing[(call.arguments as Map)['key'] as String];
        case 'write':
          final a = call.arguments as Map;
          backing[a['key'] as String] = a['value'] as String;
          return null;
        case 'delete':
          backing.remove((call.arguments as Map)['key'] as String);
          return null;
        case 'containsKey':
          return backing.containsKey((call.arguments as Map)['key'] as String);
        case 'deleteAll':
          backing.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(backing);
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(_fssChannel, null);
  });

  Widget app(Widget home) => MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(1200, 1200),
        disableAnimations: true,
      ),
      child: Scaffold(body: home),
    ),
  );

  testWidgets('empty ledger renders nothing', (tester) async {
    final repo = await _seed('ors_test_empty');
    await tester.pumpWidget(app(OpenRiskSignalsCard(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Review all'), findsNothing);
    expect(find.textContaining('Open risk signals'), findsNothing);
  });

  testWidgets('all-acknowledged ledger renders nothing', (tester) async {
    final repo = await _seed(
      'ors_test_all_ack',
      rows: [_sig(id: 'a', acknowledged: true)],
    );
    await tester.pumpWidget(app(OpenRiskSignalsCard(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Review all'), findsNothing);
  });

  testWidgets('renders header with count + Review all link', (tester) async {
    final repo = await _seed(
      'ors_test_basic',
      rows: [
        _sig(id: 'a'),
        _sig(id: 'b'),
      ],
    );
    await tester.pumpWidget(app(OpenRiskSignalsCard(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Open risk signals (2)'), findsOneWidget);
    expect(find.text('Review all'), findsOneWidget);
  });

  testWidgets('caps at 3 tiles + shows + N more footer', (tester) async {
    final repo = await _seed(
      'ors_test_cap',
      rows: [
        _sig(id: 'a'),
        _sig(id: 'b'),
        _sig(id: 'c'),
        _sig(id: 'd'),
        _sig(id: 'e'),
      ],
    );
    await tester.pumpWidget(app(OpenRiskSignalsCard(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Open risk signals (5)'), findsOneWidget);
    expect(find.textContaining('+ 2 more'), findsOneWidget);
  });

  testWidgets('skips low-severity (info) signals', (tester) async {
    final repo = await _seed(
      'ors_test_skip_info',
      rows: [
        _sig(id: 'a'),
        _sig(id: 'b', severity: RiskSeverity.info),
      ],
    );
    await tester.pumpWidget(app(OpenRiskSignalsCard(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Open risk signals (1)'), findsOneWidget);
  });
}
