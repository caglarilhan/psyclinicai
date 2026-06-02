import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/deposit_charge.dart';
import 'package:psyclinicai/widgets/no_show_charge_button.dart';

DepositCharge _deposit({DepositStatus status = DepositStatus.held}) =>
    DepositCharge(
      id: 'd-1',
      clinicId: 'c-1',
      patientId: 'p-1',
      appointmentId: 'appt-1',
      amountCents: 7500,
      currency: 'EUR',
      status: status,
    );

Future<void> _pump(
  WidgetTester tester, {
  required DepositCharge deposit,
  VoidCallback? onCapture,
  VoidCallback? onRefund,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NoShowChargeButton(
          deposit: deposit,
          onCapture: onCapture,
          onRefund: onRefund,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('NoShowChargeButton', () {
    testWidgets('renders amount + status chip + both CTAs when held',
        (tester) async {
      await _pump(tester, deposit: _deposit());
      expect(find.text('Deposit · EUR 75.00'), findsOneWidget);
      expect(find.text('held'), findsOneWidget);
      expect(find.text('Capture no-show'), findsOneWidget);
      expect(find.text('Refund deposit'), findsOneWidget);
    });

    testWidgets('captured deposit disables both CTAs', (tester) async {
      await _pump(
        tester,
        deposit: _deposit(status: DepositStatus.captured),
      );
      final capture = tester.widgetList<Widget>(
        find.byWidgetPredicate((w) => w is FilledButton),
      ).whereType<FilledButton>().first;
      expect(capture.onPressed, isNull);
    });

    testWidgets('capture CTA fires the callback when held', (tester) async {
      var called = false;
      await _pump(
        tester,
        deposit: _deposit(),
        onCapture: () => called = true,
      );
      await tester.tap(find.text('Capture no-show'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });
  });
}
