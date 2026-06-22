import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/note_format.dart';

void main() {
  group('NoteFormat structure', () {
    test('SOAP has the canonical 4 sections in order', () {
      final ids = NoteFormat.soap.sections.map((s) => s.id).toList();
      expect(ids, ['subjective', 'objective', 'assessment', 'plan']);
      expect(NoteFormat.soap.sections.map((s) => s.letter).toList(), [
        'S',
        'O',
        'A',
        'P',
      ]);
    });

    test('BIRP has 4 sections (Behavior · Intervention · Response · Plan)', () {
      final ids = NoteFormat.birp.sections.map((s) => s.id).toList();
      expect(ids, ['behavior', 'intervention', 'response', 'plan']);
      expect(NoteFormat.birp.sections.map((s) => s.letter).toList(), [
        'B',
        'I',
        'R',
        'P',
      ]);
    });

    test('DAP has 3 sections (Data · Assessment · Plan)', () {
      final ids = NoteFormat.dap.sections.map((s) => s.id).toList();
      expect(ids, ['data', 'assessment', 'plan']);
      expect(NoteFormat.dap.sections.map((s) => s.letter).toList(), [
        'D',
        'A',
        'P',
      ]);
    });

    test('every section has a non-empty label and hint', () {
      for (final f in NoteFormat.values) {
        for (final s in f.sections) {
          expect(s.label, isNotEmpty, reason: '${f.id}/${s.id} label empty');
          expect(s.hint, isNotEmpty, reason: '${f.id}/${s.id} hint empty');
        }
      }
    });
  });

  group('NoteFormat.fromId', () {
    test('maps known ids', () {
      expect(NoteFormat.fromId('soap'), NoteFormat.soap);
      expect(NoteFormat.fromId('birp'), NoteFormat.birp);
      expect(NoteFormat.fromId('dap'), NoteFormat.dap);
    });

    test('defaults to SOAP for unknown / null ids — never throws', () {
      expect(NoteFormat.fromId('xyz'), NoteFormat.soap);
      expect(NoteFormat.fromId(null), NoteFormat.soap);
      expect(NoteFormat.fromId(''), NoteFormat.soap);
    });
  });

  group('NoteFormat.toMarkdown', () {
    test('renders each section with header + body in order', () {
      final md = NoteFormat.soap.toMarkdown({
        'subjective': 'Reports low mood',
        'objective': 'PHQ-9 = 14',
        'assessment': 'MDD recurrent',
        'plan': 'CBT weekly',
      });
      expect(md, contains('**S — Subjective**'));
      expect(md, contains('Reports low mood'));
      expect(md, contains('**O — Objective**'));
      expect(md, contains('PHQ-9 = 14'));
      expect(md, contains('**A — Assessment**'));
      expect(md, contains('**P — Plan**'));
      // Sections appear in canonical order.
      expect(md.indexOf('Subjective') < md.indexOf('Objective'), isTrue);
      expect(md.indexOf('Objective') < md.indexOf('Assessment'), isTrue);
      expect(md.indexOf('Assessment') < md.indexOf('Plan'), isTrue);
    });

    test('empty sections still emit a placeholder (structure preserved)', () {
      final md = NoteFormat.dap.toMarkdown(const {});
      expect(md, contains('**D — Data**'));
      expect(md, contains('_(not documented)_'));
      expect(md, contains('**A — Assessment**'));
      expect(md, contains('**P — Plan**'));
    });

    test('ignores extra keys that are not part of the format', () {
      // SOAP doesn't have a "behavior" section; passing it should not crash
      // or leak into the markdown.
      final md = NoteFormat.soap.toMarkdown({
        'subjective': 'A',
        'behavior': 'should not appear',
      });
      expect(md, isNot(contains('should not appear')));
      expect(md, isNot(contains('Behavior')));
    });

    test('whitespace-only contents are treated as empty', () {
      final md = NoteFormat.dap.toMarkdown({
        'data': '   \n  ',
        'assessment': 'real content',
        'plan': '',
      });
      expect(md, contains('_(not documented)_')); // data was whitespace-only
      expect(md, contains('real content'));
    });
  });

  group('id stability (back-compat with persisted SessionNote.format)', () {
    test('ids stay as plain lowercase ASCII', () {
      for (final f in NoteFormat.values) {
        expect(f.id, matches(RegExp(r'^[a-z]+$')));
      }
    });
  });
}
