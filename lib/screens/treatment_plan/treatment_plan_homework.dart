/// Homework + letter widgets for `/treatment_plan`:
/// - [HomeworkTile]: a single homework row with check-toggle + due
///   date + optional goal link icon.
/// - [HomeworkDialog]: "Assign homework" alert that pops the
///   trimmed title text back through Navigator.pop, or null on
///   cancel.
/// - [LetterSheet]: bottom-sheet draft of an AI-generated
///   reimbursement letter with a placeholder caveat.
///
/// HIGH-4 (audit 2026-06-21): slice B of the
/// treatment_plan_screen.dart split.
library;

import 'package:flutter/material.dart';

import '../../models/homework_item.dart';
import '../../theme/tokens.dart';

class HomeworkTile extends StatelessWidget {
  const HomeworkTile({
    super.key,
    required this.item,
    required this.theme,
    required this.cs,
    required this.onToggle,
  });
  final HomeworkItem item;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final due =
        '${item.dueDate.year}-${item.dueDate.month.toString().padLeft(2, '0')}-${item.dueDate.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.md,
        vertical: PsySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(PsyRadius.full),
            child: Icon(
              item.done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: item.done
                  ? const Color(0xFF16A34A)
                  : cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: item.done ? TextDecoration.lineThrough : null,
                    color: item.done
                        ? cs.onSurface.withValues(alpha: 0.5)
                        : null,
                  ),
                ),
                Text(
                  'Due $due',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (item.linkedGoal != null)
            Tooltip(
              message: 'Goal: ${item.linkedGoal}',
              child: Icon(
                Icons.link,
                size: 16,
                color: cs.primary.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class HomeworkDialog extends StatefulWidget {
  const HomeworkDialog({super.key});
  @override
  State<HomeworkDialog> createState() => _HomeworkDialogState();
}

class _HomeworkDialogState extends State<HomeworkDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign homework'),
      content: TextField(
        controller: _ctl,
        onChanged: (_) => setState(() {}),
        minLines: 2,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Homework (one actionable task)',
          alignLabelWithHint: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _ctl.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_ctl.text.trim()),
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

class LetterSheet extends StatelessWidget {
  const LetterSheet({super.key, required this.letter});
  final String letter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Reimbursement letter (draft)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(
                  letter,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-drafted — review, fill the [placeholders], and verify before '
              'sending. Select text to copy.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
