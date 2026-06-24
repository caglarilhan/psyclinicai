/// Coverage for VerifyChainSection — initial idle state, success
/// path renders "Chain intact", and a tampered ledger shows
/// "Broken at row N".
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/screens/settings/audit_log_status.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
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
  timestampUtc: at ?? DateTime.utc(2026, 6, 24, 14),
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

  Widget app(Widget child) => MaterialApp(
    home: Scaffold(body: Material(child: child)),
  );

  testWidgets('initial state shows the explainer + Verify chain button', (
    tester,
  ) async {
    final repo = await _seed('al_test_verify_idle');
    await tester.pumpWidget(app(VerifyChainSection(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Verify chain'), findsOneWidget);
    expect(find.textContaining('Walk every row'), findsOneWidget);
    expect(find.text('Chain intact'), findsNothing);
  });

  testWidgets('intact ledger renders Chain intact after tap', (tester) async {
    final repo = await _seed(
      'al_test_verify_intact',
      rows: [
        _row(id: 'a'),
        _row(id: 'b'),
        _row(id: 'c'),
      ],
    );
    await tester.pumpWidget(app(VerifyChainSection(repo: repo)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verify chain'));
    await tester.pumpAndSettle();
    expect(find.text('Chain intact'), findsOneWidget);
  });

  testWidgets('Last verified stamp appears after a successful run', (
    tester,
  ) async {
    final repo = await _seed('al_test_verify_stamp', rows: [_row(id: 'a')]);
    await tester.pumpWidget(app(VerifyChainSection(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last verified'), findsNothing);

    await tester.tap(find.text('Verify chain'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last verified'), findsOneWidget);

    // Verify the stamp is persisted across a fresh widget instance
    // (the second pump reads the SharedPreferences key set by the
    // first run).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(VerifyChainSection(repo: repo)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last verified'), findsOneWidget);
  });

  testWidgets('tampered ledger renders Broken at row N', (tester) async {
    const tamperedJson =
        '{"id":"a","kind":"signin","action":"Signed in",'
        '"actor":"demo@psyclinicai.com","entity":"session",'
        '"timestamp_utc":"2026-06-24T10:00:00.000Z",'
        '"result":"success","hash":"bogus"}';
    SharedPreferences.setMockInitialValues({
      'al_test_verify_tamper': <String>[tamperedJson],
    });
    final repo = AuditLogRepository(storageBucket: 'al_test_verify_tamper');
    await repo.initialize();
    await tester.pumpWidget(app(VerifyChainSection(repo: repo)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verify chain'));
    await tester.pumpAndSettle();
    expect(find.text('Broken at row 0'), findsOneWidget);
    expect(find.text('Chain intact'), findsNothing);
  });
}
