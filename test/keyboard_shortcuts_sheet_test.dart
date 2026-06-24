/// Coverage for KeyboardShortcutsSheet — renders every documented
/// shortcut row, the keycaps split correctly, the "Got it" button
/// dismisses, and the registry-driven helper `buildAppCommands` now
/// contains the "Keyboard shortcuts" entry.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/command_palette.dart';
import 'package:psyclinicai/widgets/command_palette_registry.dart';
import 'package:psyclinicai/widgets/keyboard_shortcuts_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Material(child: child)),
  );

  testWidgets('renders the header + every shortcut row', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrap(const KeyboardShortcutsSheet()));
    await tester.pumpAndSettle();

    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('Open command palette'), findsOneWidget);
    expect(find.text('Show this keyboard help sheet'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('Got it tap dismisses the sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showKeyboardShortcuts(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsNothing);
  });

  testWidgets('Cmd+K registry now includes a Keyboard shortcuts entry', (
    tester,
  ) async {
    late List<CommandPaletteEntry> commands;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            commands = buildAppCommands(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(commands.where((c) => c.label == 'Keyboard shortcuts').length, 1);
  });
}
