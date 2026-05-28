import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/app_shell.dart';

void main() {
  // Wide viewport → desktop layout (persistent rail + header).
  Future<void> wide(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget host(Widget child) => MaterialApp(home: child);

  testWidgets('renders title, body, breadcrumb and nav destinations',
      (tester) async {
    await wide(tester);
    await tester.pumpWidget(host(const AppShell(
      routeName: '/patients',
      title: 'Patients',
      child: Text('BODY-CONTENT'),
    )));
    await tester.pump();

    expect(find.text('BODY-CONTENT'), findsOneWidget);
    // Title + breadcrumb + nav rail all surface the label.
    expect(find.text('Patients'), findsWidgets);
    // Persistent nav rail destinations.
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Session'), findsWidgets);
  });

  testWidgets('page title is exposed as a semantic header (a11y)',
      (tester) async {
    await wide(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const AppShell(
      routeName: '/dashboard',
      title: 'Outcomes',
      child: SizedBox(),
    )));
    await tester.pump();

    var foundHeader = false;
    void walk(SemanticsNode n) {
      // ignore: deprecated_member_use
      final isHeader = n.hasFlag(SemanticsFlag.isHeader);
      if (isHeader && n.label.contains('Outcomes')) {
        foundHeader = true;
      }
      n.visitChildren((c) {
        walk(c);
        return true;
      });
    }

    // ignore: deprecated_member_use
    walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    expect(foundHeader, isTrue,
        reason: 'page title should expose a semantic header');
    handle.dispose();
  });

  testWidgets('shows the primaryAction CTA when provided', (tester) async {
    await wide(tester);
    await tester.pumpWidget(host(AppShell(
      routeName: '/superbill',
      title: 'Superbill',
      primaryAction:
          FilledButton(onPressed: () {}, child: const Text('Generate')),
      child: const SizedBox(),
    )));
    await tester.pump();
    expect(find.text('Generate'), findsOneWidget);
  });
}
