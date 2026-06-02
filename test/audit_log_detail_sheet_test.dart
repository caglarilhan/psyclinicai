import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/widgets/audit_log_detail_sheet.dart';

AuditLogEntry _entry({
  AuditResult result = AuditResult.success,
  String? hash,
}) =>
    AuditLogEntry(
      id: 'evt-1',
      kind: 'read',
      action: 'patient.read',
      actor: 'sarah@example.com',
      entity: 'patient/PSY-00417',
      timestampUtc: DateTime.utc(2026, 6, 1, 18, 24, 13),
      result: result,
      ip: '203.0.113.10',
      device: 'macOS 14 / Safari',
      hash: hash ?? 'aabbccddeeff112233445566',
    );

Future<void> _pump(
  WidgetTester tester, {
  required AuditLogEntry entry,
  String? previousHash,
  String? payloadDiff,
  VoidCallback? onVerify,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AuditLogDetailSheet(
          entry: entry,
          previousHash: previousHash,
          payloadDiff: payloadDiff,
          onVerifyChain: onVerify,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AuditLogDetailSheet', () {
    testWidgets('renders action, actor, entity and a verify CTA',
        (tester) async {
      await _pump(tester, entry: _entry());
      expect(find.text('patient.read'), findsOneWidget);
      expect(find.text('sarah@example.com'), findsOneWidget);
      expect(find.text('patient/PSY-00417'), findsOneWidget);
      expect(find.text('Verify chain from here'), findsOneWidget);
    });

    testWidgets('hash is truncated for readability', (tester) async {
      await _pump(
        tester,
        entry: _entry(hash: 'a' * 30),
        previousHash: 'b' * 30,
      );
      expect(find.textContaining('aaaaaa'), findsOneWidget);
      expect(find.textContaining('bbbbbb'), findsOneWidget);
    });

    testWidgets('result chip renders the correct label', (tester) async {
      await _pump(tester, entry: _entry(result: AuditResult.denied));
      expect(find.text('denied'), findsOneWidget);
    });

    testWidgets('payload diff block renders when supplied', (tester) async {
      await _pump(
        tester,
        entry: _entry(),
        payloadDiff: '{"viewed":"dob"}',
      );
      expect(find.text('Payload diff'), findsOneWidget);
      expect(find.text('{"viewed":"dob"}'), findsOneWidget);
    });

    testWidgets('verify CTA fires the callback', (tester) async {
      var called = false;
      await _pump(
        tester,
        entry: _entry(),
        onVerify: () => called = true,
      );
      await tester.tap(find.text('Verify chain from here'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });
  });
}
