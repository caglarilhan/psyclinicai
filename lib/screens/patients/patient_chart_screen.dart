import 'package:flutter/material.dart';

import '../../services/data/patient_slug.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import 'patient_list_screen.dart' show PatientDetailArgs;

/// `/patients/chart` — six-tab clinical chart (plan §A).
///
/// Header strip surfaces the at-a-glance facts (initial avatar, risk
/// flag, MRN, insurer, last seen). Below it, six tabs cover the full
/// chart: Timeline, Documents, Notes, Assessments, Treatment Plan,
/// Billing. Each tab loads its own placeholder card today;
/// production data lands when the matching Firestore stream is
/// wired (Sprint 17 backend).
class PatientChartScreen extends StatefulWidget {
  const PatientChartScreen({super.key, required this.args, this.initialTab});

  final PatientDetailArgs args;

  /// Allows deep-link `?tab=assessments` to land on a specific tab.
  final PatientChartTab? initialTab;

  @override
  State<PatientChartScreen> createState() => _PatientChartScreenState();
}

enum PatientChartTab {
  timeline,
  documents,
  notes,
  assessments,
  treatmentPlan,
  billing,
}

class _PatientChartScreenState extends State<PatientChartScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(
    length: PatientChartTab.values.length,
    vsync: this,
    initialIndex: (widget.initialTab ?? PatientChartTab.timeline).index,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/patients/chart',
      title: widget.args.name,
      subtitle:
          'Clinical chart · MRN PSY-${PatientSlug.encodeForDisplay(widget.args.id)}',
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(args: widget.args),
          const SizedBox(height: PsySpacing.md),
          TabBar(
            controller: _controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Documents'),
              Tab(text: 'Notes'),
              Tab(text: 'Assessments'),
              Tab(text: 'Treatment plan'),
              Tab(text: 'Billing'),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [
                _TimelineTab(),
                _DocumentsTab(),
                _NotesTab(),
                _AssessmentsTab(),
                _TreatmentPlanTab(),
                _BillingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.args});
  final PatientDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final initials = args.name.isEmpty
        ? '?'
        : args.name
              .split(' ')
              .where((p) => p.isNotEmpty)
              .map((p) => p[0].toUpperCase())
              .take(2)
              .join();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    initials,
                    style: t.titleMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: PsySpacing.sm,
                        runSpacing: 4,
                        children: [
                          Text(args.name, style: t.titleLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PsySpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: PsyColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Risk · medium',
                              style: t.labelSmall?.copyWith(
                                color: PsyColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '42 y · he/him · MRN PSY-${PatientSlug.encodeForDisplay(args.id)} · BCBS',
                        style: t.bodySmall,
                      ),
                      Text(
                        'Last seen yesterday',
                        style: t.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsySpacing.sm),
            Wrap(
              spacing: PsySpacing.sm,
              runSpacing: PsySpacing.xs,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed('/session', arguments: args),
                  icon: const Icon(Icons.mic_none),
                  label: const Text('New session'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/appointments'),
                  icon: const Icon(Icons.event),
                  label: const Text('Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
      children: const [
        _TimelineEntry(
          icon: Icons.draw,
          title: 'Session signed · 50 min · SOAP',
          subtitle: '2026-06-01',
        ),
        _TimelineEntry(
          icon: Icons.assessment_outlined,
          title: 'PHQ-9 score 14 (moderate)',
          subtitle: '2026-05-30',
        ),
        _TimelineEntry(
          icon: Icons.list_alt,
          title: 'Treatment plan v2',
          subtitle: '2026-05-25',
        ),
        _TimelineEntry(
          icon: Icons.shield_outlined,
          title: 'Safety plan updated',
          subtitle: '2026-05-20',
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();
  @override
  Widget build(BuildContext context) {
    return const _Empty(
      icon: Icons.folder_open,
      title: 'No documents yet',
      body: 'Intake forms, consents and uploaded files appear here.',
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab();
  @override
  Widget build(BuildContext context) {
    return const _Empty(
      icon: Icons.note_alt_outlined,
      title: 'No signed notes yet',
      body: 'Start a session and sign the note to populate this list.',
    );
  }
}

class _AssessmentsTab extends StatelessWidget {
  const _AssessmentsTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
      children: const [
        ListTile(
          leading: Icon(Icons.show_chart),
          title: Text('PHQ-9 · last score 14 (moderate)'),
          subtitle: Text('Trend down 3 vs previous'),
        ),
        ListTile(
          leading: Icon(Icons.show_chart),
          title: Text('GAD-7 · last score 9 (mild)'),
          subtitle: Text('Trend stable'),
        ),
        ListTile(
          leading: Icon(Icons.show_chart),
          title: Text('C-SSRS · low'),
          subtitle: Text('No active ideation reported'),
        ),
      ],
    );
  }
}

class _TreatmentPlanTab extends StatelessWidget {
  const _TreatmentPlanTab();
  @override
  Widget build(BuildContext context) {
    return const _Empty(
      icon: Icons.list_alt,
      title: 'No treatment plan yet',
      body: 'SMART goals + interventions land here once drafted.',
    );
  }
}

class _BillingTab extends StatelessWidget {
  const _BillingTab();
  @override
  Widget build(BuildContext context) {
    return const _Empty(
      icon: Icons.receipt_long,
      title: 'No superbills yet',
      body: 'Sign a session to generate the first superbill.',
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(PsySpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).hintColor),
              const SizedBox(height: PsySpacing.sm),
              Text(title, style: t.titleSmall),
              const SizedBox(height: 4),
              Text(body, style: t.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
