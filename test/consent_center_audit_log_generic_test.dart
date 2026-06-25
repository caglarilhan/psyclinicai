/// H1 — generic consent audit log coverage. PR #96 added grant +
/// revoke audit rows for the KVKK kind only; this test pins the
/// generalised behaviour shipped in H1: every non-KVKK ConsentKind
/// now produces `consent.granted.<kind.id>` on grant and
/// `consent.revoked.<kind.id>` on revoke.
///
/// KVKK retains its dedicated `kvkk.consent_granted` /
/// `kvkk.consent_revoked` action labels for legacy / SIEM-rule
/// reasons — covered by the existing kvkk_consent_audit_log_test.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/screens/patients/consent_center_screen.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _resetAuditRepo() {
  final bucket = 'audit_log_test_${DateTime.now().microsecondsSinceEpoch}';
  AuditLogRepository.setInstanceForTest(
    AuditLogRepository(storageBucket: bucket),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(900, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    const MaterialApp(home: ConsentCenterScreen(patientId: 'pat-generic')),
  );
  await tester.pumpAndSettle();
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

  testWidgets(
    'Recording AI processing consent appends consent.granted.ai_processing',
    (tester) async {
      await _pump(tester);

      final label = find.text('AI processing');
      await tester.ensureVisible(label);
      final card = find.ancestor(of: label, matching: find.byType(Card));
      final cta = find.descendant(
        of: card,
        matching: find.widgetWithText(FilledButton, 'Record consent'),
      );
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      final repo = AuditLogRepository.instance;
      final granted = repo.all
          .where((e) => e.action == 'consent.granted.ai_processing')
          .toList(growable: false);
      expect(granted, hasLength(1));
      expect(granted.first.kind, 'consent');
      expect(granted.first.entity, contains('patient:pat-generic'));
      expect(granted.first.result, AuditResult.success);
    },
  );

  testWidgets(
    'Revoking telehealth consent appends consent.revoked.telehealth',
    (tester) async {
      // Pre-seed an active telehealth consent so the tile shows Revoke.
      InMemoryConsentEntryRepository.instance.record(
        ConsentEntry(
          id: 'ce-tele-1',
          patientId: 'pat-generic',
          kind: ConsentKind.telehealth,
          policyVersion: '2026-06',
          signature: 'typed:Demo',
        ),
      );

      await _pump(tester);

      final label = find.text('Telehealth');
      await tester.ensureVisible(label);
      final card = find.ancestor(of: label, matching: find.byType(Card));
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
          .where((e) => e.action == 'consent.revoked.telehealth')
          .toList(growable: false);
      expect(revoked, hasLength(1));
      expect(revoked.first.kind, 'consent');
      expect(revoked.first.entity, contains('entry:ce-tele-1'));
    },
  );

  testWidgets(
    'KVKK grant still uses the dedicated kvkk.consent_granted action',
    (tester) async {
      // Regression guard for PR #96 — the generic helper must NOT
      // shadow the KVKK-specific action name.
      await _pump(tester);

      final label = find.text('KVKK md. 6 — açık rıza (sağlık verisi)');
      await tester.ensureVisible(label);
      final card = find.ancestor(of: label, matching: find.byType(Card));
      final cta = find.descendant(
        of: card,
        matching: find.widgetWithText(FilledButton, 'Record consent'),
      );
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      // Sign the KVKK form to trigger the audit row.
      final boxes = find.byType(CheckboxListTile);
      await tester.tap(boxes.first);
      await tester.pump();
      await tester.tap(boxes.last);
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'Demo Hasta');
      await tester.pump();
      await tester.tap(find.byKey(const Key('kvkkAcikRiza.submit')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      final repo = AuditLogRepository.instance;
      final actions = repo.all.map((e) => e.action).toSet();
      expect(
        actions,
        contains('kvkk.consent_granted'),
        reason: 'KVKK kept its dedicated action name from PR #96.',
      );
      expect(
        actions,
        isNot(contains('consent.granted.kvkk_md6_health')),
        reason:
            'Generic action label must NOT also fire for KVKK — the '
            'dedicated label is the SIEM rule target.',
      );
    },
  );
}
