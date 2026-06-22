import 'package:flutter/material.dart';

import '../models/clinical_brief.dart';
import '../models/session_note.dart';
import '../models/treatment_plan_models.dart';
import '../services/copilot/clinical_memory_service.dart';
import '../services/data/homework_repository.dart';
import '../services/data/safety_plan_repository.dart';
import '../services/data/session_note_repository.dart';
import '../services/treatment_plan_service.dart';
import '../theme/tokens.dart';

/// "Session prep" card — the Clinical Memory pre-session brief. Self-contained:
/// loads the patient's notes, goals, homework, and safety plan, builds the
/// Tier-1 brief offline, and offers a Tier-2 (BYOK Claude) narrative + "today,
/// focus on" suggestions. Decision-support, not a directive.
class ClinicalBriefCard extends StatefulWidget {
  const ClinicalBriefCard({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  State<ClinicalBriefCard> createState() => _ClinicalBriefCardState();
}

class _ClinicalBriefCardState extends State<ClinicalBriefCard> {
  final _notes = SessionNoteRepository();
  final _plans = TreatmentPlanService();
  final _homework = HomeworkRepository();
  final _safety = SafetyPlanRepository();
  final _service = ClinicalMemoryService();

  bool _loading = true;
  bool _aiBusy = false;
  ClinicalBrief? _brief;
  TreatmentPlan? _plan;
  List<SessionNote> _notesList = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _notes.initialize();
    await _plans.initialize();
    await _homework.initialize();
    await _safety.initialize();

    final notes = _notes.forPatient(widget.patientId);
    final plan = _plans.getTreatmentPlanForPatient(widget.patientId);
    final hw = _homework.forPatient(widget.patientId);
    final safety = _safety.forPatient(widget.patientId);

    final brief = _service.build(
      patientName: widget.patientName,
      notes: notes,
      plan: plan,
      homework: hw,
      hasSafetyPlan: safety != null && !safety.isEmpty,
    );
    if (mounted) {
      setState(() {
        _brief = brief;
        _plan = plan;
        _notesList = notes;
        _loading = false;
      });
    }
  }

  Future<void> _generateAi() async {
    final brief = _brief;
    if (brief == null) return;
    setState(() => _aiBusy = true);
    try {
      final updated = await _service.synthesize(
        brief,
        notes: _notesList,
        plan: _plan,
      );
      if (mounted) setState(() => _brief = updated);
    } on ClinicalMemoryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.noKey
              ? SnackBarAction(
                  label: 'API keys',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings/api_keys'),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _aiBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brief = _brief;

    return Container(
      padding: const EdgeInsets.all(PsySpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.10),
            cs.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: cs.primary),
              const SizedBox(width: PsySpacing.sm),
              Text(
                'Session prep',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: PsySpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsyRadius.full),
                ),
                child: Text(
                  'Clinical Memory',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (!_loading && brief != null && !brief.isFirstSession)
                OutlinedButton.icon(
                  onPressed: _aiBusy ? null : _generateAi,
                  icon: _aiBusy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          brief.narrative == null
                              ? Icons.auto_awesome_outlined
                              : Icons.refresh,
                        ),
                  label: Text(
                    brief.narrative == null
                        ? 'Generate AI brief'
                        : 'Regenerate',
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (brief == null || brief.isFirstSession)
            Text(
              'First session — no history yet. Your brief builds itself as you '
              'log sessions, goals, and homework here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            )
          else
            _body(theme, cs, brief),
        ],
      ),
    );
  }

  Widget _body(ThemeData theme, ColorScheme cs, ClinicalBrief b) {
    final muted = cs.onSurface.withValues(alpha: 0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${b.sessionCount} prior ${b.sessionCount == 1 ? 'session' : 'sessions'}'
          '${b.lastSessionAt != null ? ' · last ${_ago(b.lastSessionAt!)}' : ''}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PsySpacing.sm),

        // AI narrative (Tier 2) or last-session recap (Tier 1).
        if (b.narrative != null && b.narrative!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PsySpacing.md),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(PsyRadius.md),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(
              b.narrative!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          )
        else if (b.lastRecap != null)
          Text(
            'Last session: ${b.lastRecap}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted,
              height: 1.45,
            ),
          ),

        const SizedBox(height: PsySpacing.md),

        // Status chips.
        Wrap(
          spacing: PsySpacing.sm,
          runSpacing: PsySpacing.xs,
          children: [
            if (b.activeGoals.isNotEmpty)
              _chip(
                theme,
                cs,
                Icons.flag_outlined,
                '${b.activeGoals.length} active ${b.activeGoals.length == 1 ? 'goal' : 'goals'}',
                cs.primary,
              ),
            if (b.homeworkOverdue > 0)
              _chip(
                theme,
                cs,
                Icons.assignment_late_outlined,
                '${b.homeworkOverdue} homework overdue',
                cs.error,
              ),
            if (b.homeworkPending > 0)
              _chip(
                theme,
                cs,
                Icons.assignment_outlined,
                '${b.homeworkPending} homework pending',
                const Color(0xFFD97706),
              ),
            if (b.riskNote != null)
              _chip(
                theme,
                cs,
                Icons.warning_amber_rounded,
                'Risk flagged',
                cs.error,
              ),
            _chip(
              theme,
              cs,
              b.hasSafetyPlan
                  ? Icons.health_and_safety
                  : Icons.health_and_safety_outlined,
              b.hasSafetyPlan ? 'Safety plan on file' : 'No safety plan',
              b.hasSafetyPlan ? cs.primary : const Color(0xFFD97706),
            ),
          ],
        ),

        if (b.todos.isNotEmpty) ...[
          const SizedBox(height: PsySpacing.md),
          Text(
            'Today, focus on',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          ...b.todos.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, size: 18, color: cs.primary),
                  Expanded(child: Text(t, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: PsySpacing.sm),
        Text(
          'Decision-support — review clinically.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _chip(
    ThemeData theme,
    ColorScheme cs,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PsyRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _ago(DateTime d) {
    final days = DateTime.now().difference(d).inDays;
    if (days <= 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 7) return '$days days ago';
    final weeks = (days / 7).floor();
    return weeks == 1 ? 'a week ago' : '$weeks weeks ago';
  }
}
