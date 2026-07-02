import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/telemetry_service.dart';
import '../../services/noshow/noshow_feature_catalog.dart';
import '../../services/noshow/noshow_predict_client.dart';
import '../../services/noshow/noshow_recent_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/clinician/noshow` — risk-tiered appointment queue.
///
/// MVP slice (PILAR 3 / PR-3): the clinician scores a single
/// appointment by pasting / typing its feature counts, sees the tier
/// + ROI estimate, and the recovery playbook the practice should
/// follow.
///
/// The full sprint-32 cut adds: a Firestore stream over upcoming
/// appointments, batched scoring on dashboard mount, drag-and-drop
/// "apply playbook" → cron-armed reminders. This PR keeps the screen
/// to one focused row so the whole chain is end-to-end functional.
class NoShowQueueScreen extends StatefulWidget {
  const NoShowQueueScreen({
    super.key,
    required this.client,
    required this.tenantId,
    this.recentRepo,
  });

  final NoShowPredictClient client;
  final String tenantId;

  /// Optional repo — injected in tests, defaults to a Firestore-backed
  /// implementation in production.
  final NoShowRecentRepository? recentRepo;

  @override
  State<NoShowQueueScreen> createState() => _NoShowQueueScreenState();
}

class _NoShowQueueScreenState extends State<NoShowQueueScreen> {
  final TextEditingController _apptId = TextEditingController();
  final TextEditingController _patientId = TextEditingController();
  final TextEditingController _attended = TextEditingController(text: '4');
  final TextEditingController _noShows = TextEditingController(text: '1');
  final TextEditingController _lateCancels = TextEditingController(text: '0');
  final TextEditingController _daysSince = TextEditingController(text: '14');
  bool _firstSession = false;
  bool _telehealth = false;
  bool _safetyPlan = false;
  bool _scoring = false;
  String? _error;
  NoShowPrediction? _prediction;

  /// Stable repository reference — instantiating in `build()` would spin
  /// a new StreamBuilder subscription on every `setState`.
  late final NoShowRecentRepository _recentRepo =
      widget.recentRepo ?? NoShowRecentRepository();

  @override
  void dispose() {
    _apptId.dispose();
    _patientId.dispose();
    _attended.dispose();
    _noShows.dispose();
    _lateCancels.dispose();
    _daysSince.dispose();
    super.dispose();
  }

  int _intOrZero(TextEditingController c) {
    final v = int.tryParse(c.text.trim());
    return v ?? 0;
  }

  Future<void> _onScore() async {
    if (_scoring) return;
    final appt = _apptId.text.trim();
    final pid = _patientId.text.trim();
    if (appt.isEmpty || pid.isEmpty) {
      setState(() => _error = 'Appointment id + patient id required.');
      return;
    }
    setState(() {
      _scoring = true;
      _error = null;
    });
    try {
      final features = <String, Object>{
        'history_attended_count_90d': _intOrZero(_attended),
        'history_noshow_count_90d': _intOrZero(_noShows),
        'history_late_cancel_count_90d': _intOrZero(_lateCancels),
        'days_since_last_session': _intOrZero(_daysSince),
        'is_first_session': _firstSession,
        'modality': _telehealth,
        'has_active_safety_plan': _safetyPlan,
      };
      final p = await widget.client.predict(
        tenantId: widget.tenantId,
        appointmentId: appt,
        patientId: pid,
        features: features,
      );
      if (!mounted) return;
      setState(() {
        _prediction = p;
        _scoring = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _scoring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/clinician/noshow',
      title: 'No-show risk queue',
      subtitle:
          'Predict the no-show risk of an upcoming appointment, then '
          'apply the recovery playbook.',
      breadcrumbs: const [
        Crumb('Clinician', '/dashboard'),
        Crumb('No-show', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeatureCard(
            theme: theme,
            cs: cs,
            apptId: _apptId,
            patientId: _patientId,
            attended: _attended,
            noShows: _noShows,
            lateCancels: _lateCancels,
            daysSince: _daysSince,
            firstSession: _firstSession,
            onFirstSession: (v) => setState(() => _firstSession = v),
            telehealth: _telehealth,
            onTelehealth: (v) => setState(() => _telehealth = v),
            safetyPlan: _safetyPlan,
            onSafetyPlan: (v) => setState(() => _safetyPlan = v),
            scoring: _scoring,
            onScore: _onScore,
            error: _error,
          ),
          const SizedBox(height: PsySpacing.xl),
          if (_prediction != null)
            _ScorePanel(theme: theme, cs: cs, prediction: _prediction!),
          const SizedBox(height: PsySpacing.xl),
          _RecentPredictionsPanel(
            theme: theme,
            cs: cs,
            repo: _recentRepo,
            clinicId: widget.tenantId,
          ),
        ],
      ),
    );
  }
}

class _RecentPredictionsPanel extends StatelessWidget {
  const _RecentPredictionsPanel({
    required this.theme,
    required this.cs,
    required this.repo,
    required this.clinicId,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final NoShowRecentRepository repo;
  final String clinicId;

  PsyBadgeTone _tone(NoShowRiskTier t) => switch (t) {
        NoShowRiskTier.low => PsyBadgeTone.success,
        NoShowRiskTier.medium => PsyBadgeTone.warning,
        NoShowRiskTier.high => PsyBadgeTone.danger,
      };

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Recent predictions', style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Last 10 appointments you scored. Colours mirror the recovery '
            'playbook — red first for the day-of triage.',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
          ),
          const SizedBox(height: PsySpacing.md),
          StreamBuilder<List<NoShowRecentRow>>(
            stream: repo.watchRecent(clinicId: clinicId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Ping Sentry once per error surface so ops can spot a
                // Firestore rule regression or an index rebuild
                // without waiting for a clinician to email us. The
                // TelemetryService PHI-scrubs before Sentry relays.
                unawaited(
                  TelemetryService.instance.captureError(
                    snapshot.error ?? 'unknown',
                    snapshot.stackTrace,
                    hint: 'noshow.recent_stream_failed',
                  ),
                );
                return Text(
                  'Could not load recent predictions: ${snapshot.error}',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: PsySpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final rows = snapshot.data!;
              if (rows.isEmpty) {
                return Text(
                  'No predictions yet — every appointment you score above '
                  'lands here in real time.',
                  style: theme.textTheme.bodySmall,
                );
              }
              return Column(
                children: [
                  for (final r in rows)
                    Semantics(
                      label:
                          'Appointment ${r.appointmentId}, patient ${r.patientId}, '
                          '${(r.probability * 100).toStringAsFixed(0)} percent risk, '
                          '${r.tier.name} tier',
                      container: true,
                      child: MergeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 96,
                                child: Text(
                                  r.appointmentId,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  r.patientId,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: PsySpacing.sm),
                              Text(
                                '${(r.probability * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.labelMedium,
                              ),
                              const SizedBox(width: PsySpacing.sm),
                              PsyBadge(
                                label: r.tier.name.toUpperCase(),
                                tone: _tone(r.tier),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.theme,
    required this.cs,
    required this.apptId,
    required this.patientId,
    required this.attended,
    required this.noShows,
    required this.lateCancels,
    required this.daysSince,
    required this.firstSession,
    required this.onFirstSession,
    required this.telehealth,
    required this.onTelehealth,
    required this.safetyPlan,
    required this.onSafetyPlan,
    required this.scoring,
    required this.onScore,
    required this.error,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final TextEditingController apptId;
  final TextEditingController patientId;
  final TextEditingController attended;
  final TextEditingController noShows;
  final TextEditingController lateCancels;
  final TextEditingController daysSince;
  final bool firstSession;
  final ValueChanged<bool> onFirstSession;
  final bool telehealth;
  final ValueChanged<bool> onTelehealth;
  final bool safetyPlan;
  final ValueChanged<bool> onSafetyPlan;
  final bool scoring;
  final VoidCallback onScore;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Appointment + history', style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: apptId,
                  decoration: const InputDecoration(
                    labelText: 'Appointment id',
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: TextField(
                  controller: patientId,
                  decoration: const InputDecoration(labelText: 'Patient id'),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          Wrap(
            spacing: PsySpacing.md,
            runSpacing: PsySpacing.md,
            children: [
              _numField(attended, 'Attended (90d)'),
              _numField(noShows, 'No-shows (90d)'),
              _numField(lateCancels, 'Late cancels (90d)'),
              _numField(daysSince, 'Days since last visit'),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          Wrap(
            spacing: PsySpacing.md,
            children: [
              FilterChip(
                selected: firstSession,
                label: const Text('First session'),
                onSelected: onFirstSession,
              ),
              FilterChip(
                selected: telehealth,
                label: const Text('Telehealth'),
                onSelected: onTelehealth,
              ),
              FilterChip(
                selected: safetyPlan,
                label: const Text('Active safety plan'),
                onSelected: onSafetyPlan,
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
          const SizedBox(height: PsySpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: scoring ? null : onScore,
              icon: scoring
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.online_prediction),
              label: Text(scoring ? 'Scoring…' : 'Score risk'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({
    required this.theme,
    required this.cs,
    required this.prediction,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final NoShowPrediction prediction;

  PsyBadgeTone get _tone {
    switch (prediction.tier) {
      case NoShowRiskTier.low:
        return PsyBadgeTone.success;
      case NoShowRiskTier.medium:
        return PsyBadgeTone.warning;
      case NoShowRiskTier.high:
        return PsyBadgeTone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = (prediction.probability * 100).toStringAsFixed(1);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Risk score', style: theme.textTheme.titleMedium),
              const SizedBox(width: PsySpacing.md),
              PsyBadge(
                label: '${prediction.tier.name.toUpperCase()} · $pct%',
                tone: _tone,
              ),
              const Spacer(),
              PsyBadge(label: prediction.modelVersion),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          if (prediction.playbook.estUsdSavedPerSlot > 0)
            _RoiBanner(
              theme: theme,
              cs: cs,
              dollars: prediction.playbook.estUsdSavedPerSlot,
            ),
          const SizedBox(height: PsySpacing.md),
          Text('Recovery playbook', style: theme.textTheme.titleSmall),
          const SizedBox(height: PsySpacing.sm),
          _PlaybookRow(
            theme: theme,
            label: 'Confirm cadence',
            value: prediction.playbook.confirmCadenceHours.isEmpty
                ? 'No proactive reminders'
                : prediction.playbook.confirmCadenceHours
                      .map((h) => '${h}h before')
                      .join(' · '),
          ),
          _PlaybookRow(
            theme: theme,
            label: 'SMS at',
            value: '${prediction.playbook.smsConfirmHours} h before',
          ),
          _PlaybookRow(
            theme: theme,
            label: 'Call at',
            value: prediction.playbook.callConfirmHours == 0
                ? '—'
                : '${prediction.playbook.callConfirmHours} h before',
          ),
          _PlaybookRow(
            theme: theme,
            label: 'Deposit hold',
            value: prediction.playbook.depositRequired
                ? 'required'
                : 'not required',
          ),
          _PlaybookRow(
            theme: theme,
            label: 'Waitlist offer on cancel',
            value: prediction.playbook.waitlistOfferOnCancel ? 'yes' : 'no',
          ),
        ],
      ),
    );
  }
}

class _RoiBanner extends StatelessWidget {
  const _RoiBanner({
    required this.theme,
    required this.cs,
    required this.dollars,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final int dollars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: cs.onPrimaryContainer),
          const SizedBox(width: PsySpacing.sm),
          Expanded(
            child: Text(
              'Estimated value recovered if we save this slot: ~\$$dollars.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybookRow extends StatelessWidget {
  const _PlaybookRow({
    required this.theme,
    required this.label,
    required this.value,
  });
  final ThemeData theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
