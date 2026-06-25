/// G2 — pins the audit-trail contract for KVKK md. 6 consent grant
/// + revoke. Telemetry is for dashboards; the audit log is the
/// forensic record an auditor (KVK Kurumu) walks back through.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/screens/patients/consent_center_screen.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';
import 'package:psyclinicai/widgets/consent/kvkk_intake_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _host(Widget child) => MaterialApp(
  home: ChangeNotifierProvider<ConsentEntryRepository>.value(
    value: InMemoryConsentEntryRepository.instance,
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

Widget _hostScreen(Widget screen) =>
    ChangeNotifierProvider<ConsentEntryRepository>.value(
      value: InMemoryConsentEntryRepository.instance,
      // Provider above MaterialApp so the dialog (Navigator overlay) sees it.
      child: MaterialApp(home: screen),
    );

void _resetAuditRepo() {
  // Each test gets a fresh, bucket-isolated repo so the audit chain
  // starts at zero and there's no cross-test bleed.
  final bucket = 'audit_log_test_${DateTime.now().microsecondsSinceEpoch}';
  AuditLogRepository.setInstanceForTest(
    AuditLogRepository(storageBucket: bucket),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    InMemoryConsentEntryRepository.instance.clearForTesting();
    _resetAuditRepo();
  });

  tearDown(() {
    AuditLogRepository.setInstanceForTest(null);
  });

  testWidgets('KvkkIntakeSlot.sign appends a kvkk.consent_granted audit row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const KvkkIntakeSlot(
          patientId: 'pat-audit',
          patientName: 'Demo',
          policyVersion: 'kvkk-aydinlatma-v2026.06',
        ),
      ),
    );
    await tester.pump();

    final boxes = find.byType(CheckboxListTile);
    await tester.tap(boxes.first);
    await tester.pump();
    await tester.tap(boxes.last);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Demo');
    await tester.pump();
    await tester.tap(find.byKey(const Key('kvkkAcikRiza.submit')));
    // Allow the audit_log_repository's SP write to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final repo = AuditLogRepository.instance;
    final granted = repo.all
        .where((e) => e.action == 'kvkk.consent_granted')
        .toList(growable: false);
    expect(granted, hasLength(1));
    final row = granted.first;
    expect(row.kind, 'consent');
    expect(row.entity, contains('patient:pat-audit'));
    expect(row.entity, contains('policy:kvkk-aydinlatma-v2026.06'));
    expect(row.result, AuditResult.success);
  });

  testWidgets(
    'ConsentCenter.revoke on KVKK kind appends kvkk.consent_revoked',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      InMemoryConsentEntryRepository.instance.record(
        ConsentEntry(
          id: 'ce-kvkk-1',
          patientId: 'pat-rev',
          kind: ConsentKind.kvkkSpecialCategoryHealth,
          policyVersion: 'kvkk-aydinlatma-v2026.06',
          signature: 'typed:Demo',
        ),
      );

      await tester.pumpWidget(
        _hostScreen(const ConsentCenterScreen(patientId: 'pat-rev')),
      );
      await tester.pumpAndSettle();

      final kvkkLabel = find.text('KVKK md. 6 — açık rıza (sağlık verisi)');
      await tester.ensureVisible(kvkkLabel);
      final card = find.ancestor(of: kvkkLabel, matching: find.byType(Card));
      final revokeBtn = find.descendant(
        of: card,
        matching: find.widgetWithText(OutlinedButton, 'Revoke'),
      );
      await tester.ensureVisible(revokeBtn);
      await tester.tap(revokeBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      final repo = AuditLogRepository.instance;
      final revoked = repo.all
          .where((e) => e.action == 'kvkk.consent_revoked')
          .toList(growable: false);
      expect(revoked, hasLength(1));
      final row = revoked.first;
      expect(row.kind, 'consent');
      expect(row.entity, contains('patient:pat-rev'));
      expect(row.entity, contains('entry:ce-kvkk-1'));
      expect(row.result, AuditResult.success);
    },
  );

  testWidgets(
    'ConsentCenter.revoke on a NON-KVKK kind does not append a KVKK row',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      InMemoryConsentEntryRepository.instance.record(
        ConsentEntry(
          id: 'ce-ai-1',
          patientId: 'pat-ai',
          kind: ConsentKind.aiProcessing,
          policyVersion: '2026-06',
          signature: 'typed:Demo',
        ),
      );

      await tester.pumpWidget(
        _hostScreen(const ConsentCenterScreen(patientId: 'pat-ai')),
      );
      await tester.pumpAndSettle();

      final aiLabel = find.text('AI processing');
      await tester.ensureVisible(aiLabel);
      final card = find.ancestor(of: aiLabel, matching: find.byType(Card));
      final revokeBtn = find.descendant(
        of: card,
        matching: find.widgetWithText(OutlinedButton, 'Revoke'),
      );
      await tester.ensureVisible(revokeBtn);
      await tester.tap(revokeBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      final repo = AuditLogRepository.instance;
      expect(
        repo.all.where((e) => e.action == 'kvkk.consent_revoked'),
        isEmpty,
        reason:
            'KVKK audit branch fired on a non-KVKK kind — the gate '
            'must stay specific to kvkkSpecialCategoryHealth.',
      );
    },
  );
}
