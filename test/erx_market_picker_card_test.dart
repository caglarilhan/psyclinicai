import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/prescription.dart';
import 'package:psyclinicai/widgets/erx_market_picker_card.dart';

void main() {
  group('ErxMarketPickerCard', () {
    testWidgets('renders one row per supported market', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErxMarketPickerCard(
              selected: PrescriptionMarket.eu,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('EU'), findsAtLeastNWidgets(1));
      expect(find.textContaining('MEDULA'), findsOneWidget);
      expect(find.textContaining('SureScripts'), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping a market updates selection', (tester) async {
      PrescriptionMarket? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErxMarketPickerCard(
              selected: PrescriptionMarket.eu,
              onChanged: (m) => captured = m,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('MEDULA'));
      await tester.pumpAndSettle();
      expect(captured, PrescriptionMarket.tr);
    });

    testWidgets('US market shows the Sprint 16 placeholder note',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErxMarketPickerCard(
              selected: PrescriptionMarket.eu,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Sprint 16'), findsAtLeastNWidgets(1));
    });
  });
}
