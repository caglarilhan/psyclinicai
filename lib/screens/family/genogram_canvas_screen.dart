/// `/family/genogram` — read-only visual canvas for the patient's
/// genogram (PR #14). Lays out the family graph with
/// `GenogramLayoutEngine`, renders it through `GenogramPainter`,
/// and surfaces an attribute frequency footer ("3 family members
/// with depression history") so the clinician can see patterns
/// without scrolling through the structured list.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/genogram.dart';
import '../../services/data/genogram_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';
import '../../widgets/genogram/genogram_layout.dart';
import '../../widgets/genogram/genogram_painter.dart';

class GenogramCanvasScreen extends StatefulWidget {
  const GenogramCanvasScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.repository,
  });

  final String patientId;
  final String patientName;
  final GenogramRepository? repository;

  @override
  State<GenogramCanvasScreen> createState() => _GenogramCanvasScreenState();
}

class _GenogramCanvasScreenState extends State<GenogramCanvasScreen> {
  late final GenogramRepository _repo;
  bool _loading = true;
  Genogram? _g;
  GenogramLayout? _layout;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? GenogramRepository();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    final g = _repo.forPatient(widget.patientId);
    setState(() {
      _g = g;
      _layout = g == null ? null : GenogramLayoutEngine().compute(g);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/family/genogram',
      title: 'Genogram — ${widget.patientName}',
      subtitle:
          'McGoldrick / Gerson 3-generation map. Pattern recognition tool '
          'for family-therapy planning.',
      breadcrumbs: [
        const Crumb('Home', '/dashboard'),
        const Crumb('Patients', '/patients'),
        Crumb(widget.patientName, null),
        const Crumb('Genogram', null),
      ],
      scrollable: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _g == null || _layout == null || _layout!.nodes.isEmpty
          ? const PsyEmptyState(
              icon: Icons.account_tree_outlined,
              title: 'No genogram yet',
              body:
                  'Add family members and relationships from the patient '
                  'chart to render this canvas.',
            )
          : _CanvasBody(genogram: _g!, layout: _layout!),
    );
  }
}

class _CanvasBody extends StatelessWidget {
  const _CanvasBody({required this.genogram, required this.layout});
  final Genogram genogram;
  final GenogramLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frequencies = _topAttributes(genogram);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PsyCard(
            child: InteractiveViewer(
              constrained: false,
              minScale: 0.5,
              maxScale: 3,
              boundaryMargin: const EdgeInsets.all(120),
              child: SizedBox(
                width: layout.size.width,
                height: layout.size.height,
                child: CustomPaint(
                  painter: GenogramPainter(layout: layout, theme: theme),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        if (frequencies.isNotEmpty)
          PsyCard(
            tinted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern footer',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Attributes carried by 2 or more family members.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: PsySpacing.sm),
                Wrap(
                  spacing: PsySpacing.sm,
                  runSpacing: PsySpacing.sm,
                  children: [
                    for (final f in frequencies)
                      PsyBadge(
                        label: '${f.attribute.label} x ${f.count}',
                        tone: PsyBadgeTone.info,
                      ),
                  ],
                ),
              ],
            ),
          )
        else
          PsyCard(
            child: Text(
              'No repeating attributes yet — every member carries a unique '
              'pattern so far.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  List<({GenogramAttribute attribute, int count})> _topAttributes(Genogram g) {
    final out = <({GenogramAttribute attribute, int count})>[];
    for (final attr in GenogramAttribute.values) {
      final n = g.attributeFrequency(attr);
      if (n >= 2) out.add((attribute: attr, count: n));
    }
    out.sort((a, b) => b.count.compareTo(a.count));
    return out;
  }
}
