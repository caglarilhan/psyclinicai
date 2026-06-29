/// K3 — pins the AuditLogScreen ↔ AuditLogRepository wire.
///
/// The screen used to render `demoAuditEntries()` only; this test
/// fleet verifies that with the production singleton populated:
///   1. Live rows from the singleton render in the list,
///   2. The chain-verify button surfaces a success SnackBar when
///      the chain is intact,
///   3. With an empty repo the demo fallback kicks in.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/screens/settings/audit_log_screen.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuditLogEntry _entry(String id, {DateTime? ts}) => AuditLogEntry(
  id: id,
  kind: 'consent',
  action: 'kvkk.consent_granted',
  actor: 'pat-1',
  entity: 'patient:pat-1 entry:ce-$id policy:2026-06',
  timestampUtc: ts ?? DateTime.utc(2026, 6, 25, 12),
  result: AuditResult.success,
);

Future<void> _seedRepo(List<AuditLogEntry> rows) async {
  final bucket = 'audit_screen_test_${DateTime.now().microsecondsSinceEpoch}';
  final repo = AuditLogRepository(storageBucket: bucket);
  await repo.initialize();
  for (final r in rows) {
    await repo.append(r);
  }
  AuditLogRepository.setInstanceForTest(repo);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AuditLogRepository.setInstanceForTest(null);
  });

  tearDown(() {
    AuditLogRepository.setInstanceForTest(null);
  });

  testWidgets('renders live rows from AuditLogRepository.instance', (
    tester,
  ) async {
    await _seedRepo([
      _entry('seed-1', ts: DateTime.utc(2026, 6, 25, 12)),
      _entry('seed-2', ts: DateTime.utc(2026, 6, 25, 12, 30)),
    ]);
    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: AuditLogScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('kvkk.consent_granted'), findsWidgets);
  });

  testWidgets('Verify chain → success SnackBar on intact chain', (
    tester,
  ) async {
    await _seedRepo([_entry('verify-1', ts: DateTime.utc(2026, 6, 25, 12))]);
    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: AuditLogScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final verifyBtn = find.widgetWithText(OutlinedButton, 'Verify chain');
    await tester.ensureVisible(verifyBtn);
    await tester.tap(verifyBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Chain intact'), findsOneWidget);
  });

  testWidgets('falls back to demo entries when the repo is empty', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: AuditLogScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Demo data anchor — fixture always carries at least one signin row.
    expect(find.textContaining('Sign'), findsWidgets);
  });
}
