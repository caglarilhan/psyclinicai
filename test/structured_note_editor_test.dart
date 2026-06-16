import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/note_format.dart';
import 'package:psyclinicai/widgets/structured_note_editor.dart';

void main() {
  Widget host(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 800,
          width: 600,
          child: child,
        ),
      ),
    );
  }

  testWidgets('renders all SOAP section labels by default', (tester) async {
    StructuredNoteValue? last;
    await tester.pumpWidget(host(
      StructuredNoteEditor(onChanged: (v) => last = v),
    ));
    expect(find.text('Subjective'), findsOneWidget);
    expect(find.text('Objective'), findsOneWidget);
    expect(find.text('Assessment'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(last, isNull, reason: 'no emission until the user types');
  });

  testWidgets('typing emits a snapshot with markdown and sections',
      (tester) async {
    StructuredNoteValue? last;
    await tester.pumpWidget(host(
      StructuredNoteEditor(onChanged: (v) => last = v),
    ));

    // Find the Subjective field (first TextField in SOAP order).
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.first, 'Reports anxiety at work');
    await tester.pump();

    expect(last, isNotNull);
    expect(last!.format, NoteFormat.soap);
    expect(last!.sections['subjective'], 'Reports anxiety at work');
    expect(last!.markdown, contains('Reports anxiety at work'));
    expect(last!.markdown, contains('**S — Subjective**'));
    expect(last!.isEmpty, isFalse);
  });

  testWidgets('switching to BIRP renders 4 different section labels',
      (tester) async {
    StructuredNoteValue? last;
    await tester.pumpWidget(host(
      StructuredNoteEditor(onChanged: (v) => last = v),
    ));
    expect(find.text('Subjective'), findsOneWidget);

    await tester.tap(find.text('BIRP'));
    await tester.pumpAndSettle();

    expect(find.text('Behavior'), findsOneWidget);
    expect(find.text('Intervention'), findsOneWidget);
    expect(find.text('Response'), findsOneWidget);
    // 'Plan' appears in both — that's fine, BIRP also has Plan.
    expect(find.text('Subjective'), findsNothing);
    expect(last, isNotNull);
    expect(last!.format, NoteFormat.birp);
  });

  testWidgets('initialSections pre-populate the editor', (tester) async {
    StructuredNoteValue? last;
    await tester.pumpWidget(host(
      StructuredNoteEditor(
        initialFormat: NoteFormat.dap,
        initialSections: const {
          'data': 'Pre-existing data text',
          'assessment': 'Pre-existing assessment',
        },
        onChanged: (v) => last = v,
      ),
    ));
    await tester.pump();
    expect(find.text('Pre-existing data text'), findsOneWidget);
    expect(find.text('Pre-existing assessment'), findsOneWidget);
    // No emission until the user changes something.
    expect(last, isNull);
  });

  testWidgets('isEmpty is true when every section is blank', (tester) async {
    StructuredNoteValue? last;
    await tester.pumpWidget(host(
      StructuredNoteEditor(onChanged: (v) => last = v),
    ));
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, 'hello');
    await tester.pump();
    expect(last!.isEmpty, isFalse);

    await tester.enterText(fields.first, '');
    await tester.pump();
    expect(last!.isEmpty, isTrue);
  });

  testWidgets('format switch preserves text typed in the previous format',
      (tester) async {
    // ignore: unused_local_variable
    StructuredNoteValue? last;
    await tester.pumpWidget(host(
      StructuredNoteEditor(onChanged: (v) => last = v),
    ));

    await tester.enterText(find.byType(TextField).first, 'SOAP subjective');
    await tester.pump();

    await tester.tap(find.text('DAP'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SOAP'));
    await tester.pumpAndSettle();

    // Returning to SOAP, the text we typed should still be there because
    // controllers are retained across format swaps.
    expect(find.text('SOAP subjective'), findsOneWidget);
  });
}
