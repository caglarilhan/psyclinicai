/// Reusable widgets that compose the `/patients/intake` form:
/// - [PhiBanner]: top-of-form callout reminding the clinician
///   that the form holds PHI and that nothing syncs until save.
/// - [ChipList]: tap-to-add chip + text field used for meds,
///   allergies and supports lists.
/// - [ConsentCard]: GDPR / KVKK consent block at the bottom of
///   the form (3 ConsentRows + a typed signature field).
/// - [_ConsentRow] (file-private): a single labelled checkbox row.
///
/// HIGH-class refactor (audit 2026-06-21): extracted from the
/// 823-line intake_form_screen.dart so the screen file owns its
/// state + repository wiring only.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

class PhiBanner extends StatelessWidget {
  const PhiBanner({super.key, required this.cs, required this.theme});
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.health_and_safety_outlined, color: cs.primary),
          const SizedBox(width: PsySpacing.sm),
          Expanded(
            child: Text(
              'This form holds PHI. It is encrypted at rest on this device '
              'and synced to the patient chart only after you save.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: PsySpacing.sm),
          const PsyBadge(label: 'PHI', tone: PsyBadgeTone.info),
        ],
      ),
    );
  }
}

class ChipList extends StatefulWidget {
  const ChipList({
    super.key,
    required this.items,
    required this.hint,
    required this.onChanged,
  });
  final List<String> items;
  final String hint;
  final VoidCallback onChanged;

  @override
  State<ChipList> createState() => _ChipListState();
}

class _ChipListState extends State<ChipList> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _add() {
    final t = _ctl.text.trim();
    if (t.isEmpty) return;
    if (widget.items.contains(t)) {
      _ctl.clear();
      return;
    }
    widget.items.add(t);
    _ctl.clear();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.items.isNotEmpty)
          Wrap(
            spacing: PsySpacing.xs,
            runSpacing: PsySpacing.xs,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                InputChip(
                  label: Text(widget.items[i]),
                  onDeleted: () {
                    widget.items.removeAt(i);
                    widget.onChanged();
                  },
                ),
            ],
          ),
        if (widget.items.isNotEmpty) const SizedBox(height: PsySpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctl,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: PsySpacing.sm),
            IconButton.filledTonal(
              onPressed: _add,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class ConsentCard extends StatelessWidget {
  const ConsentCard({
    super.key,
    required this.policyVersion,
    required this.dataProcessing,
    required this.aiAssistance,
    required this.sensitiveData,
    required this.signature,
    required this.onDataChanged,
    required this.onAiChanged,
    required this.onSensitiveChanged,
    required this.onSignatureChanged,
  });

  final String policyVersion;
  final bool dataProcessing;
  final bool aiAssistance;
  final bool sensitiveData;
  final TextEditingController signature;
  final ValueChanged<bool> onDataChanged;
  final ValueChanged<bool> onAiChanged;
  final ValueChanged<bool> onSensitiveChanged;
  final VoidCallback onSignatureChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Privacy policy version',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: PsySpacing.sm),
              PsyBadge(label: policyVersion),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          _ConsentRow(
            value: dataProcessing,
            onChanged: onDataChanged,
            required: true,
            title: 'I consent to processing of my personal data',
            body:
                'GDPR Art. 6(1)(a) / KVKK Md. 5(2)(a) — required to '
                'open a clinical file and contact me.',
          ),
          _ConsentRow(
            value: sensitiveData,
            onChanged: onSensitiveChanged,
            required: true,
            title: 'I consent to processing of my health data',
            body:
                'GDPR Art. 9(2)(a) — explicit consent for the mental-'
                'health information stored in this chart.',
          ),
          _ConsentRow(
            value: aiAssistance,
            onChanged: onAiChanged,
            required: false,
            title:
                'I consent to AI-assisted note drafting (you may withdraw '
                'this at any time)',
            body:
                'Session content may be routed to the configured LLM '
                'provider to produce draft notes. Withdrawing this consent '
                'does not affect access to care.',
          ),
          const SizedBox(height: PsySpacing.md),
          Text(
            'Signature',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: PsySpacing.xs),
          TextField(
            controller: signature,
            onChanged: (_) => onSignatureChanged(),
            decoration: const InputDecoration(
              hintText: 'Type your full legal name to sign',
              prefixIcon: Icon(Icons.edit_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Typing your name above is equivalent to a wet signature for '
            'consent capture. Time-stamp and policy version are stored '
            'alongside the signature.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.body,
    required this.required,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String body;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
          const SizedBox(width: PsySpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (required)
                      const PsyBadge(
                        label: 'Required',
                        tone: PsyBadgeTone.warning,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
