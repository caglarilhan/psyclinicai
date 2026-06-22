import 'package:flutter/material.dart';

import '../models/note_format.dart';
import '../theme/tokens.dart';

/// A multi-section note editor that swaps its layout based on the chosen
/// [NoteFormat] (SOAP / BIRP / DAP). Each section is its own [TextField]
/// with its own controller; on every keystroke or format switch the
/// parent receives a fresh [StructuredNoteValue] carrying both the
/// markdown rendering and the per-section map.
///
/// The widget intentionally owns its controllers so the parent can stay
/// declarative and so changing formats does not orphan focus or text.
class StructuredNoteEditor extends StatefulWidget {
  const StructuredNoteEditor({
    super.key,
    this.initialFormat = NoteFormat.soap,
    this.initialSections = const {},
    required this.onChanged,
  });

  final NoteFormat initialFormat;

  /// Pre-populates the section text fields, keyed by [NoteSection.id].
  /// Sections not present in the map start empty.
  final Map<String, String> initialSections;

  /// Called whenever the user types or switches format. The value carries
  /// the markdown that should be persisted plus the structured map so
  /// the parent can hand it back later for editing.
  final ValueChanged<StructuredNoteValue> onChanged;

  @override
  State<StructuredNoteEditor> createState() => _StructuredNoteEditorState();
}

class _StructuredNoteEditorState extends State<StructuredNoteEditor> {
  late NoteFormat _format;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _format = widget.initialFormat;
    for (final s in _format.sections) {
      _controllers[s.id] = TextEditingController(
        text: widget.initialSections[s.id] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ensureController(String id) {
    return _controllers.putIfAbsent(
      id,
      () => TextEditingController(text: widget.initialSections[id] ?? ''),
    );
  }

  void _emit() {
    final map = <String, String>{
      for (final s in _format.sections) s.id: _controllers[s.id]?.text ?? '',
    };
    widget.onChanged(
      StructuredNoteValue(
        format: _format,
        sections: map,
        markdown: _format.toMarkdown(map),
      ),
    );
  }

  void _onFormatChanged(NoteFormat next) {
    if (next == _format) return;
    setState(() => _format = next);
    // Make sure any new sections have a controller. Old sections that
    // belong to the previous format are kept so a clinician can flip back
    // without losing what they typed.
    for (final s in _format.sections) {
      _ensureController(s.id);
    }
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormatPicker(current: _format, onChanged: _onFormatChanged),
        const SizedBox(height: PsySpacing.md),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
            itemBuilder: (context, i) {
              final section = _format.sections[i];
              final controller = _ensureController(section.id);
              return _SectionField(
                section: section,
                controller: controller,
                onChanged: (_) => _emit(),
                cs: cs,
                theme: theme,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: PsySpacing.md),
            itemCount: _format.sections.length,
          ),
        ),
      ],
    );
  }
}

/// Snapshot emitted by [StructuredNoteEditor.onChanged].
class StructuredNoteValue {
  const StructuredNoteValue({
    required this.format,
    required this.sections,
    required this.markdown,
  });

  final NoteFormat format;
  final Map<String, String> sections;
  final String markdown;

  /// True when every section is empty.
  bool get isEmpty => sections.values.every((v) => v.trim().isEmpty);
}

class _FormatPicker extends StatelessWidget {
  const _FormatPicker({required this.current, required this.onChanged});
  final NoteFormat current;
  final ValueChanged<NoteFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Text(
          'Format',
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(width: PsySpacing.md),
        Expanded(
          child: SegmentedButton<NoteFormat>(
            segments: NoteFormat.values
                .map(
                  (f) => ButtonSegment<NoteFormat>(
                    value: f,
                    label: Text(f.shortName),
                  ),
                )
                .toList(),
            selected: {current},
            onSelectionChanged: (s) => onChanged(s.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStateProperty.all(
                theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: PsySpacing.md),
        Tooltip(
          message: current.description,
          child: Icon(
            Icons.info_outline,
            size: 18,
            color: cs.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _SectionField extends StatelessWidget {
  const _SectionField({
    required this.section,
    required this.controller,
    required this.onChanged,
    required this.cs,
    required this.theme,
  });

  final NoteSection section;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PsyRadius.sm),
              ),
              child: Text(
                section.letter,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: PsySpacing.sm),
            Text(
              section.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.xs),
        TextField(
          controller: controller,
          onChanged: onChanged,
          minLines: 3,
          maxLines: 8,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: section.hint,
            hintMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PsyRadius.md),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.md,
              vertical: PsySpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}
