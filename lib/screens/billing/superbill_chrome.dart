/// Layout chrome shared across the SuperbillScreen sections:
/// the bordered SectionCard wrapper, the labelled Field / DateField
/// text inputs, and the gradient InvoiceMetaCard at the top of
/// the form. None of them touch business state — they read a
/// TextEditingController or a DateTime and call onPick / onPickDate
/// callbacks — so they extract cleanly from the god-file.
///
/// HIGH-4 (audit 2026-06-21): slice 2 of the superbill_screen.dart
/// split. Pulling these four out drops another ~215 lines from
/// the screen file.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bordered, padded container the form uses to group a section
/// of fields (Provider, Patient, Diagnoses, Service lines, Totals).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    required this.cs,
    required this.theme,
    this.trailing,
  });

  final String title;
  final Widget child;
  final ColorScheme cs;
  final ThemeData theme;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Bordered, labelled single-line text field used by every form
/// section. Dense + same OutlineInputBorder radius so the form
/// reads as a single visual unit.
class SuperbillField extends StatelessWidget {
  const SuperbillField({
    super.key,
    required this.controller,
    required this.label,
  });
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

/// Tap-to-pick date field with the same chrome as [SuperbillField].
class SuperbillDateField extends StatelessWidget {
  const SuperbillDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          isDense: true,
        ),
        child: InkWell(
          onTap: onPick,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null ? '—' : DateFormat('yyyy-MM-dd').format(value!),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top hero card on the superbill: brand icon + title + caption,
/// with invoice number + service date pinned to the right on wide
/// layouts (stacked on mobile).
class InvoiceMetaCard extends StatelessWidget {
  const InvoiceMetaCard({
    super.key,
    required this.cs,
    required this.theme,
    required this.invoiceNumber,
    required this.serviceDate,
    required this.onPickDate,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final TextEditingController invoiceNumber;
  final DateTime serviceDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.4),
            cs.primaryContainer.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 560;
          final header = Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long, color: cs.primary, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Superbill Draft',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Out-of-network insurance reimbursement receipt. '
                      'Provider must verify codes before submission.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final fields = Column(
            children: [
              SuperbillField(controller: invoiceNumber, label: 'Invoice #'),
              SuperbillDateField(
                label: 'Service date',
                value: serviceDate,
                onPick: onPickDate,
              ),
            ],
          );
          // Below ~560 px the fixed-220 sidecar starved the title to 34 px
          // and the text rendered one letter per line — stack on mobile.
          if (wide) {
            return Row(
              children: [
                Expanded(child: header),
                const SizedBox(width: 20),
                SizedBox(width: 220, child: fields),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [header, const SizedBox(height: 16), fields],
          );
        },
      ),
    );
  }
}
