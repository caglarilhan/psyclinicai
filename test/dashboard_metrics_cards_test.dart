import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/analytics/dashboard_metrics.dart';
import 'package:psyclinicai/widgets/dashboard_metrics_cards.dart';

DashboardMetrics _metrics({
  int sessions = 4,
  int pending = 2,
  int atRisk = 3,
  int outstandingCents = 124000,
  int oldestAge = 22,
  DashboardAppointment? next,
}) => DashboardMetrics(
  todaysSessionCount: sessions,
  nextAppointment: next,
  pendingNotesCount: pending,
  atRiskCount: atRisk,
  outstandingTotalCents: outstandingCents,
  oldestOutstandingAgeDays: oldestAge,
);

Future<void> _pump(
  WidgetTester tester,
  DashboardMetrics m, {
  ValueChanged<DashboardCardKind>? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DashboardMetricsCards(metrics: m, onTap: onTap),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DashboardMetricsCards', () {
    testWidgets('renders 4 cards with numeric values', (tester) async {
      await _pump(tester, _metrics());
      expect(find.text("Today's sessions"), findsOneWidget);
      expect(find.text('Pending notes'), findsOneWidget);
      expect(find.text('At-risk patients'), findsOneWidget);
      expect(find.text('Outstanding'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('outstanding renders the formatted currency', (tester) async {
      await _pump(tester, _metrics(outstandingCents: 12345));
      expect(find.text('EUR 123.45'), findsOneWidget);
    });

    testWidgets('next appointment hint renders when set', (tester) async {
      final m = _metrics(
        next: DashboardAppointment(
          id: 'a-1',
          patientName: 'John Demo',
          startsAt: DateTime.utc(2026, 6, 10, 14, 30),
          kind: 'therapy',
        ),
      );
      await _pump(tester, m);
      expect(find.textContaining('Next 14:30'), findsOneWidget);
      expect(find.textContaining('John Demo'), findsOneWidget);
    });

    testWidgets('tapping a card fires onTap with the card kind', (
      tester,
    ) async {
      DashboardCardKind? captured;
      await _pump(tester, _metrics(), onTap: (k) => captured = k);
      await tester.tap(find.text('Pending notes'));
      await tester.pumpAndSettle();
      expect(captured, DashboardCardKind.pendingNotes);
    });

    testWidgets('outstanding fallback hint when nothing is outstanding', (
      tester,
    ) async {
      await _pump(tester, _metrics(outstandingCents: 0, oldestAge: 0));
      expect(find.text('None outstanding'), findsOneWidget);
    });
  });
}
