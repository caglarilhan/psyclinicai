/// Coverage for buildAppCommands — the canonical command-palette
/// registry. Asserts that every nav rail destination is reachable
/// from Cmd+K, labels are unique, and the section partition is
/// stable.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/command_palette.dart';
import 'package:psyclinicai/widgets/command_palette_registry.dart';

Future<List<CommandPaletteEntry>> _captureCommands(WidgetTester tester) async {
  late List<CommandPaletteEntry> captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          captured = buildAppCommands(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every rail nav destination ships as a command', (tester) async {
    final commands = await _captureCommands(tester);
    final labels = commands.map((c) => c.label).toSet();
    for (final required in const [
      'Dashboard',
      'Patients',
      'Calendar',
      'New session',
      'AI assistant',
      'AI diagnosis',
      'Mood tracking',
      'Outcomes',
      'Superbill',
      'Settings',
    ]) {
      expect(
        labels,
        contains(required),
        reason: '$required missing from Cmd+K',
      );
    }
  });

  testWidgets('labels are unique', (tester) async {
    final commands = await _captureCommands(tester);
    final labels = commands.map((c) => c.label).toList();
    expect(labels.toSet().length, labels.length);
  });

  testWidgets('every command names a section', (tester) async {
    final commands = await _captureCommands(tester);
    for (final c in commands) {
      expect(c.section, isNotEmpty, reason: '${c.label} has no section');
    }
  });

  testWidgets('every command carries an icon for the row layout', (
    tester,
  ) async {
    final commands = await _captureCommands(tester);
    for (final c in commands) {
      expect(c.icon, isNotNull, reason: '${c.label} has no icon');
    }
  });

  testWidgets('scoring prefers exact-prefix matches over fuzzy', (
    tester,
  ) async {
    final commands = await _captureCommands(tester);
    final dashboard = commands.firstWhere((c) => c.label == 'Dashboard');
    final settings = commands.firstWhere((c) => c.label == 'Settings');
    expect(dashboard.score('dash'), greaterThan(settings.score('dash')));
  });

  testWidgets('empty query yields a baseline-positive score', (tester) async {
    final commands = await _captureCommands(tester);
    expect(commands.first.score(''), 1);
  });
}
