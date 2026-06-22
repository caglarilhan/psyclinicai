import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/command_palette.dart';

void main() {
  group('CommandPaletteEntry.score', () {
    final entry = CommandPaletteEntry(
      label: 'Open superbill',
      section: 'Billing',
      subtitle: 'CMS-1500 export',
      onSelect: () {},
    );

    test('empty query returns 1 (every entry visible)', () {
      expect(entry.score(''), 1);
    });

    test('prefix match wins over substring', () {
      expect(entry.score('open'), greaterThan(entry.score('1500')));
    });

    test('label substring beats fuzzy chars', () {
      final fuzzy = entry.score('opbll');
      final sub = entry.score('superbill');
      expect(sub, greaterThan(fuzzy));
    });

    test('no match returns 0', () {
      expect(entry.score('zzz'), 0);
    });
  });

  group('CommandPalette widget', () {
    testWidgets('renders entries + filters as user types', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final entries = [
        CommandPaletteEntry(
          label: 'Open dashboard',
          section: 'Workspace',
          onSelect: () {},
        ),
        CommandPaletteEntry(
          label: 'Schedule appointment',
          section: 'Calendar',
          onSelect: () {},
        ),
        CommandPaletteEntry(
          label: 'Send PHQ-9',
          section: 'Assessments',
          onSelect: () {},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CommandPalette(entries: entries)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open dashboard'), findsOneWidget);
      expect(find.text('Schedule appointment'), findsOneWidget);
      expect(find.text('Send PHQ-9'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'phq');
      await tester.pumpAndSettle();
      expect(find.text('Send PHQ-9'), findsOneWidget);
      expect(find.text('Open dashboard'), findsNothing);
    });

    testWidgets('empty result state when no fuzzy match', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommandPalette(
              entries: [
                CommandPaletteEntry(
                  label: 'Open dashboard',
                  section: 'Workspace',
                  onSelect: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pumpAndSettle();
      expect(find.textContaining('No match'), findsOneWidget);
    });
  });
}
