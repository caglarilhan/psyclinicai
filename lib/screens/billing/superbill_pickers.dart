/// Search dialogs the SuperbillScreen pops to add an ICD-10
/// diagnosis or a CPT service line. Both are self-contained
/// stateful dialogs that pop a single result back through
/// Navigator.pop, so they extract cleanly from the
/// superbill_screen.dart god-file.
///
/// HIGH-4 (audit 2026-06-21): superbill_screen.dart was 1,239
/// lines; pulling the two pickers out drops it by ~210.
library;

import 'package:flutter/material.dart';

import '../../services/billing/cpt_lookup_service.dart';
import '../../services/billing/icd10_lookup_service.dart';

/// ICD-10 diagnosis picker — text search across code / label /
/// synonym; tapping a row pops the [Icd10Code] back to the caller.
class DiagnosisPicker extends StatefulWidget {
  const DiagnosisPicker({super.key, required this.service});
  final Icd10LookupService service;

  @override
  State<DiagnosisPicker> createState() => _DiagnosisPickerState();
}

class _DiagnosisPickerState extends State<DiagnosisPicker> {
  String _query = '';
  late List<Icd10Code> _results = widget.service.all();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 540,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pick ICD-10 diagnosis',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() {
                  _query = v;
                  _results = widget.service.search(v);
                }),
                decoration: InputDecoration(
                  hintText: 'Search by code, label, or synonym…',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          'No diagnoses match "$_query"',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: cs.outlineVariant, height: 1),
                        itemBuilder: (_, i) {
                          final c = _results[i];
                          return ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                c.code,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              c.label,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              c.category.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                            onTap: () => Navigator.of(context).pop(c),
                          );
                        },
                      ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CPT service-line picker — filter by [CptCategory], tap a row
/// to pop the [CptCode] back to the caller.
class CptPicker extends StatefulWidget {
  const CptPicker({super.key, required this.service});
  final CptLookupService service;

  @override
  State<CptPicker> createState() => _CptPickerState();
}

class _CptPickerState extends State<CptPicker> {
  CptCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final codes = _filter == null
        ? widget.service.all()
        : widget.service.byCategory(_filter!);
    return Dialog(
      child: SizedBox(
        width: 620,
        height: 580,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pick CPT code',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final c in CptCategory.values)
                    FilterChip(
                      label: Text(c.label),
                      selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: codes.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: cs.outlineVariant, height: 1),
                  itemBuilder: (_, i) {
                    final c = codes[i];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          c.code,
                          style: TextStyle(
                            color: cs.primary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(c.shortLabel),
                      subtitle: Text(
                        '${c.typicalDurationMinutes} min · \$${c.nationalAverageUsd.toStringAsFixed(0)} avg',
                      ),
                      onTap: () => Navigator.of(context).pop(c),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
