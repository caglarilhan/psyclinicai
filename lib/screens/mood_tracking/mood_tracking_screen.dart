import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/mood_repository.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/mood_tracking` — daily mood / sleep / anxiety check-in for a
/// patient. Three 1–5 sliders + free-text note. Persists to Firestore
/// (live mode) or to an in-memory list (demo mode).
class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  static const _patientId = 'john-demo';

  int _mood = 3;
  int _sleep = 3;
  int _anxiety = 3;
  final _notes = TextEditingController();
  bool _saving = false;
  String? _msg;
  final List<MoodEntry> _demoEntries = [];

  @override
  void initState() {
    super.initState();
    if (!PsyFirebase.isReady) _seedDemo();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _seedDemo() {
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      _demoEntries.add(
        MoodEntry(
          id: 'demo-$i',
          mood: 2 + ((i * 7) % 4),
          sleep: 2 + ((i * 3) % 4),
          anxiety: 5 - ((i * 5) % 4),
          notes: i == 0 ? 'Slept well, felt energised' : '',
          completedAt: now.subtract(Duration(days: i)),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _msg = null;
    });
    if (PsyFirebase.isReady) {
      final profile = FirebaseAuthService.instance.profile;
      if (profile != null) {
        try {
          await MoodRepository.instance.add(
            clinicId: profile.clinicId,
            patientId: _patientId,
            mood: _mood,
            sleep: _sleep,
            anxiety: _anxiety,
            notes: _notes.text.trim(),
          );
          _msg = "Saved today's check-in.";
        } catch (e) {
          _msg = 'Save failed: $e';
        }
      } else {
        _msg = 'Sign in to save check-ins.';
      }
    } else {
      _demoEntries.add(
        MoodEntry(
          id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
          mood: _mood,
          sleep: _sleep,
          anxiety: _anxiety,
          notes: _notes.text.trim(),
          completedAt: DateTime.now(),
        ),
      );
      _msg = 'Saved (demo mode — in-memory only).';
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _notes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/mood_tracking',
      title: 'Mood tracker',
      subtitle: 'Daily mood, sleep & anxiety check-ins with a 30-day trend.',
      scrollable: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PsyCard(
            tinted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's check-in",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PsySpacing.lg),
                _Slider(
                  label: 'Mood',
                  value: _mood,
                  onChanged: (v) => setState(() => _mood = v),
                  theme: theme,
                  color: PsyColors.success,
                ),
                _Slider(
                  label: 'Sleep quality',
                  value: _sleep,
                  onChanged: (v) => setState(() => _sleep = v),
                  theme: theme,
                  color: PsyColors.info,
                ),
                _Slider(
                  label: 'Anxiety (lower is better)',
                  value: _anxiety,
                  onChanged: (v) => setState(() => _anxiety = v),
                  theme: theme,
                  color: PsyColors.warning,
                ),
                const SizedBox(height: PsySpacing.md),
                TextField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: PsySpacing.lg),
                Row(
                  children: [
                    PsyButton(
                      label: 'Save check-in',
                      icon: Icons.check,
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                    if (_msg != null) ...[
                      const SizedBox(width: PsySpacing.lg),
                      Expanded(
                        child: Text(
                          _msg!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            '30-day trend',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          _TrendCard(patientId: _patientId, demoEntries: _demoEntries),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            'Recent entries',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          _EntryList(patientId: _patientId, demoEntries: _demoEntries),
        ],
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.color,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final ThemeData theme;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PsySpacing.md,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsyRadius.full),
                ),
                child: Text(
                  '$value / 5',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(
              context,
            ).copyWith(activeTrackColor: color, thumbColor: color),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.patientId, required this.demoEntries});
  final String patientId;
  final List<MoodEntry> demoEntries;

  @override
  Widget build(BuildContext context) {
    if (!PsyFirebase.isReady) return _chart(context, demoEntries);
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) {
      return _empty(context, 'Sign in to load your patient roster.');
    }
    return StreamBuilder<List<MoodEntry>>(
      stream: MoodRepository.instance.watch(profile.clinicId, patientId),
      builder: (ctx, snap) {
        final entries = snap.data ?? const <MoodEntry>[];
        if (entries.isEmpty) {
          return _empty(context, 'Add a check-in to start the trend.');
        }
        return _chart(context, entries);
      },
    );
  }

  Widget _empty(BuildContext context, String body) {
    final theme = Theme.of(context);
    return PsyCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PsySpacing.xxl),
        child: Center(child: Text(body, style: theme.textTheme.bodyMedium)),
      ),
    );
  }

  Widget _chart(BuildContext context, List<MoodEntry> entries) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ordered = entries.toList()
      ..sort(
        (a, b) => (a.completedAt ?? DateTime(0)).compareTo(
          b.completedAt ?? DateTime(0),
        ),
      );
    final mood = <FlSpot>[];
    final sleep = <FlSpot>[];
    final anxiety = <FlSpot>[];
    for (var i = 0; i < ordered.length; i++) {
      mood.add(FlSpot(i.toDouble(), ordered[i].mood.toDouble()));
      sleep.add(FlSpot(i.toDouble(), ordered[i].sleep.toDouble()));
      anxiety.add(FlSpot(i.toDouble(), ordered[i].anxiety.toDouble()));
    }
    LineChartBarData line(List<FlSpot> spots, Color c) => LineChartBarData(
      spots: spots,
      isCurved: true,
      color: c,
      barWidth: 2.4,
      dotData: FlDotData(
        getDotPainter: (s, p, b, i) => FlDotCirclePainter(
          radius: 3,
          color: c,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
    );
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _legend('Mood', PsyColors.success),
              const SizedBox(width: PsySpacing.lg),
              _legend('Sleep', PsyColors.info),
              const SizedBox(width: PsySpacing.lg),
              _legend('Anxiety', PsyColors.warning),
              const Spacer(),
              Text(
                '${ordered.length} entries',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.lg),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 5,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  bottomTitles: AxisTitles(),
                ),
                lineBarsData: [
                  line(mood, PsyColors.success),
                  line(sleep, PsyColors.info),
                  line(anxiety, PsyColors.warning),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color c) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.patientId, required this.demoEntries});
  final String patientId;
  final List<MoodEntry> demoEntries;

  @override
  Widget build(BuildContext context) {
    if (!PsyFirebase.isReady) {
      final reversed = demoEntries.reversed.toList();
      return _list(context, reversed);
    }
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) {
      return const PsyCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('Sign in to load entries.')),
        ),
      );
    }
    return StreamBuilder<List<MoodEntry>>(
      stream: MoodRepository.instance.watch(profile.clinicId, patientId),
      builder: (ctx, snap) {
        final entries = snap.data ?? const <MoodEntry>[];
        return _list(context, entries);
      },
    );
  }

  Widget _list(BuildContext context, List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return const PsyCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('No entries yet.')),
        ),
      );
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: PsyCard(
                child: Row(
                  children: [
                    _stat('Mood', e.mood, PsyColors.success),
                    const SizedBox(width: PsySpacing.lg),
                    _stat('Sleep', e.sleep, PsyColors.info),
                    const SizedBox(width: PsySpacing.lg),
                    _stat('Anxiety', e.anxiety, PsyColors.warning),
                    const SizedBox(width: PsySpacing.xl),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (e.notes.isNotEmpty)
                            Text(e.notes, style: theme.textTheme.bodyMedium),
                          Text(
                            e.completedAt == null ? '—' : _fmt(e.completedAt!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _stat(String label, int v, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$v',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
