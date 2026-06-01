/// Structured session-note formats supported by [StructuredNoteEditor]
/// and persisted in [SessionNote.format].
///
/// Each format has a fixed ordered list of [NoteSection]s with a stable
/// section id (used as the storage key) plus a clinician-facing label and
/// hint. Adding a section to a format is a backward-compatible change —
/// old notes saved as raw markdown will still load.
library;

class NoteSection {
  const NoteSection({
    required this.id,
    required this.label,
    required this.letter,
    required this.hint,
  });

  /// Stable storage key (lower-case ASCII). Persisted in the per-section
  /// controllers map; do NOT rename without a migration.
  final String id;

  /// Full label shown in the editor ("Subjective", "Behavior", …).
  final String label;

  /// Single-letter section marker shown on the chip ("S", "O", "B", …).
  final String letter;

  /// One-line clinician hint placed inside the field as a placeholder.
  final String hint;
}

enum NoteFormat {
  /// Subjective / Objective / Assessment / Plan — the most common
  /// outpatient mental-health note.
  soap('soap', 'SOAP', 'Subjective · Objective · Assessment · Plan'),

  /// Behavior / Intervention / Response / Plan — favored by behavioral
  /// health and substance-use settings.
  birp('birp', 'BIRP', 'Behavior · Intervention · Response · Plan'),

  /// Data / Assessment / Plan — compact format used in case management
  /// and brief encounters.
  dap('dap', 'DAP', 'Data · Assessment · Plan');

  const NoteFormat(this.id, this.shortName, this.description);

  /// Stable identifier persisted in `SessionNote.format`.
  final String id;

  /// Display name on the dropdown ("SOAP", "BIRP", "DAP").
  final String shortName;

  /// One-line explanation shown under the dropdown.
  final String description;

  /// Ordered sections for the format. Order matters — it drives both the
  /// editor layout and the generated markdown.
  List<NoteSection> get sections => switch (this) {
        NoteFormat.soap => const [
            NoteSection(
              id: 'subjective',
              label: 'Subjective',
              letter: 'S',
              hint: 'Client report — chief complaint, mood, sleep, '
                  'meds, recent stressors.',
            ),
            NoteSection(
              id: 'objective',
              label: 'Objective',
              letter: 'O',
              hint: 'Observable — MSE, affect, vitals, scale scores, '
                  'attendance.',
            ),
            NoteSection(
              id: 'assessment',
              label: 'Assessment',
              letter: 'A',
              hint: 'Clinical formulation — diagnosis, risk, progress '
                  'against goals.',
            ),
            NoteSection(
              id: 'plan',
              label: 'Plan',
              letter: 'P',
              hint: 'Next steps — interventions, homework, '
                  'referrals, next session.',
            ),
          ],
        NoteFormat.birp => const [
            NoteSection(
              id: 'behavior',
              label: 'Behavior',
              letter: 'B',
              hint: 'What the client said and did this session.',
            ),
            NoteSection(
              id: 'intervention',
              label: 'Intervention',
              letter: 'I',
              hint: 'Techniques and modalities the clinician used.',
            ),
            NoteSection(
              id: 'response',
              label: 'Response',
              letter: 'R',
              hint: 'How the client responded to the interventions.',
            ),
            NoteSection(
              id: 'plan',
              label: 'Plan',
              letter: 'P',
              hint: 'Next steps, homework, follow-up cadence.',
            ),
          ],
        NoteFormat.dap => const [
            NoteSection(
              id: 'data',
              label: 'Data',
              letter: 'D',
              hint: 'Subjective + objective combined — what the client '
                  'shared and what you observed.',
            ),
            NoteSection(
              id: 'assessment',
              label: 'Assessment',
              letter: 'A',
              hint: 'Clinical impression, progress, risk.',
            ),
            NoteSection(
              id: 'plan',
              label: 'Plan',
              letter: 'P',
              hint: 'Next interventions, referrals, follow-up.',
            ),
          ],
      };

  /// Look up a format by its stored id. Defaults to SOAP for unknown values
  /// so a corrupt or future format never crashes the editor.
  static NoteFormat fromId(String? id) {
    for (final f in NoteFormat.values) {
      if (f.id == id) return f;
    }
    return NoteFormat.soap;
  }

  /// Render the section contents into a single markdown string the
  /// existing persistence layer expects. Empty sections still render their
  /// header so the structure is preserved when a draft is reopened.
  ///
  /// [sectionContents] is keyed by [NoteSection.id]; missing entries are
  /// treated as empty.
  String toMarkdown(Map<String, String> sectionContents) {
    final buffer = StringBuffer();
    for (var i = 0; i < sections.length; i++) {
      final s = sections[i];
      if (i > 0) buffer.write('\n\n');
      buffer.write('**${s.letter} — ${s.label}**\n\n');
      final body = (sectionContents[s.id] ?? '').trim();
      buffer.write(body.isEmpty ? '_(not documented)_' : body);
    }
    return buffer.toString();
  }
}
