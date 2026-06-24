/// Coverage for RecentAuditTile — hidden on empty ledger, filters
/// to today, filters to actor when supplied, caps at 3 rows + "+N
/// more" footer, and the "View audit log" link is always present
/// when the tile is visible.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:psyclinicai/widgets/dashboard/recent_audit_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuditLogEntry _row({
  String id = 'r',
  String kind = 'phi_read',
  String action = 'Opened chart',
  String actor = 'dr.lee@psyclinicai.com',
  String entity = 'patient/pat-1',
  AuditResult result = AuditResult.success,
  DateTime? at,
}) => AuditLogEntry(
  id: id,
  kind: kind,
  action: action,
  actor: actor,
  entity: entity,
  timestampUtc: at ?? DateTime.now().toUtc(),
  result: result,
);

Future<AuditLogRepository> _seed(
  String bucket, {
  List<AuditLogEntry> rows = const [],
}) async {
  final repo = AuditLogRepository(storageBucket: bucket);
  await repo.initialize();
  for (final r in rows) {
    await repo.append(r);
  }
  return repo;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
    final repo = await _seed('al_test_tile_empty');
    await tester.pumpWidget(app(RecentAuditTile(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('View audit log'), findsNothing);
  });

  testWidgets('all-yesterday ledger renders nothing', (tester) async {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final repo = await _seed(
      'al_test_tile_yesterday',
      rows: [_row(id: 'a', at: yesterday)],
    );
    await tester.pumpWidget(app(RecentAuditTile(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('View audit log'), findsNothing);
  });

  testWidgets('renders header with count + View audit log link', (
    tester,
  ) async {
    final repo = await _seed(
      'al_test_tile_basic',
      rows: [
        _row(id: 'a'),
        _row(id: 'b'),
      ],
    );
    await tester.pumpWidget(app(RecentAuditTile(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.textContaining("Today's audit activity (2)"), findsOneWidget);
    expect(find.text('View audit log'), findsOneWidget);
  });

  testWidgets('filters to actor when supplied', (tester) async {
    final repo = await _seed(
      'al_test_tile_actor',
      rows: [
        _row(id: 'a'),
        _row(id: 'b', actor: 'someone.else@psyclinicai.com'),
      ],
    );
    await tester.pumpWidget(
      app(RecentAuditTile(repo: repo, actor: 'dr.lee@psyclinicai.com')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining("Today's audit activity (1)"), findsOneWidget);
  });

  testWidgets('caps at 3 rows + shows + N more footer', (tester) async {
    final repo = await _seed(
      'al_test_tile_cap',
      rows: [for (var i = 0; i < 5; i++) _row(id: 'r-$i')],
    );
    await tester.pumpWidget(app(RecentAuditTile(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.textContaining("Today's audit activity (5)"), findsOneWidget);
    expect(find.textContaining('+ 2 more'), findsOneWidget);
  });
}
