/// Widget coverage for ClaimAttemptHistorySheet — empty state,
/// attempt tiles render with outcome + CARC chips, playbook section
/// appears for denial codes the playbook knows.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/claim_attempt.dart';
import 'package:psyclinicai/screens/billing/claim_attempt_history_sheet.dart';
import 'package:psyclinicai/services/billing/claim_attempt_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpSheet(
  WidgetTester tester,
  String claimId,
  ClaimAttemptRepository repo,
) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2000));
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () {
                unawaited(
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ClaimAttemptHistorySheet(
                      claimId: claimId,
                      repository: repo,
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('empty state when no attempts logged', (tester) async {
    final repo = ClaimAttemptRepository(storageBucket: 'cah_empty');
    await repo.initialize();
    await _pumpSheet(tester, 'claim-x', repo);
    expect(find.text('No attempts logged yet'), findsOneWidget);
  });

  testWidgets('renders attempt tile with outcome + CARC chip', (tester) async {
    final repo = ClaimAttemptRepository(storageBucket: 'cah_attempt');
    await repo.initialize();
    final a = await repo.recordAttempt(
      claimId: 'claim-1',
      submittedAt: DateTime.utc(2026, 6, 22),
    );
    await repo.recordOutcome(
      attemptId: a.id,
      outcome: ClaimAttemptOutcome.denied,
      denialReasonCode: 'CO-50',
    );
    await _pumpSheet(tester, 'claim-1', repo);
    expect(find.text('Attempt #1'), findsOneWidget);
    expect(find.text('CARC CO-50'), findsOneWidget);
    expect(find.text('Denied'), findsOneWidget);
  });

  testWidgets('playbook section appears when an attempt has a CARC fix entry', (
    tester,
  ) async {
    final repo = ClaimAttemptRepository(storageBucket: 'cah_playbook');
    await repo.initialize();
    final a = await repo.recordAttempt(
      claimId: 'claim-pb',
      submittedAt: DateTime.utc(2026, 6, 22),
    );
    await repo.recordOutcome(
      attemptId: a.id,
      outcome: ClaimAttemptOutcome.denied,
      denialReasonCode: 'CO-50',
    );
    await _pumpSheet(tester, 'claim-pb', repo);
    expect(find.text('Playbook'), findsOneWidget);
    expect(
      find.text('Add explicit medical-necessity statement'),
      findsOneWidget,
    );
  });

  testWidgets(
    'overturned attempt + denial pair surfaces Resolved + Recovered chips',
    (tester) async {
      final repo = ClaimAttemptRepository(storageBucket: 'cah_recover');
      await repo.initialize();
      final a1 = await repo.recordAttempt(
        claimId: 'claim-rec',
        submittedAt: DateTime.utc(2026, 6, 2),
      );
      await repo.recordOutcome(
        attemptId: a1.id,
        outcome: ClaimAttemptOutcome.denied,
      );
      final a2 = await repo.recordAttempt(
        claimId: 'claim-rec',
        submittedAt: DateTime.utc(2026, 6, 15),
        appealLetterId: 'letter-1',
      );
      await repo.recordOutcome(
        attemptId: a2.id,
        outcome: ClaimAttemptOutcome.overturned,
      );
      await _pumpSheet(tester, 'claim-rec', repo);
      expect(find.text('Resolved'), findsOneWidget);
      expect(find.text('Recovered'), findsOneWidget);
      expect(find.text('Appealed'), findsOneWidget);
    },
  );
}
