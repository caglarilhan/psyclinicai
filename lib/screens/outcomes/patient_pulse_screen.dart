/// `/outcomes/pulse/:patientId` — single-patient "is this patient
/// OK right now?" snapshot. Loads from four repos (FIT ratings,
/// MAR dose log, side effects, Vanderbilt) and renders a worst-of-
/// four overall chip plus a 4-tile grid (FIT alliance, adherence,
/// tolerability, ADHD subtype). Each tile carries a colour-coded
/// signal (ok / watch / concern) and a one-line clinical hint so
/// the clinician knows where to dig in next.
///
/// Pure read-only — the screen does not edit any record; it points
/// the clinician at the right deep-link (FIT capture, MAR, SE log,
/// Vanderbilt intake).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/vanderbilt_assessment.dart';
import '../../services/data/feedback_rating_repository.dart';
import '../../services/data/medication_dose_repository.dart';
import '../../services/data/medication_side_effect_repository.dart';
import '../../services/data/patient_pulse_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../services/data/vanderbilt_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_card.dart';

class PatientPulseScreen extends StatefulWidget {
  const PatientPulseScreen({
    super.key,
    required this.patientId,
    this.patientName,
    this.fitRepo,
    this.doseRepo,
    this.seRepo,
    this.vbRepo,
    this.now,
  });

  final String patientId;
  final String? patientName;

  /// Optional injection for tests; defaults to fresh repo instances
  /// that initialise on load.
  final FeedbackRatingRepository? fitRepo;
  final MedicationDoseRepository? doseRepo;
  final MedicationSideEffectRepository? seRepo;
  final VanderbiltRepository? vbRepo;

  /// Injected wall-clock for deterministic adherence windows in tests.
  final DateTime? now;

  @override
  State<PatientPulseScreen> createState() => _PatientPulseScreenState();
}

class _PatientPulseScreenState extends State<PatientPulseScreen> {
  late final FeedbackRatingRepository _fitRepo;
  late final MedicationDoseRepository _doseRepo;
  late final MedicationSideEffectRepository _seRepo;
  late final VanderbiltRepository _vbRepo;
  bool _loading = true;
  PatientPulse? _pulse;

  @override
  void initState() {
    super.initState();
    _fitRepo = widget.fitRepo ?? FeedbackRatingRepository();
    _doseRepo = widget.doseRepo ?? MedicationDoseRepository();
    _seRepo = widget.seRepo ?? MedicationSideEffectRepository();
    _vbRepo = widget.vbRepo ?? VanderbiltRepository();
    unawaited(_load());
  }

  Future<void> _load() async {
    await Future.wait([
      _fitRepo.initialize(),
      _doseRepo.initialize(),
      _seRepo.initialize(),
      _vbRepo.initialize(),
    ]);
    if (!mounted) return;
    final pair = _vbRepo.latestPair(widget.patientId);
    final pulse = PatientPulseService.compute(
      patientId: widget.patientId,
      ratings: _fitRepo.forPatient(widget.patientId),
      doses: _doseRepo.forPatientInRange(
        widget.patientId,
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        DateTime.utc(9999),
      ),
      sideEffects: _seRepo.forPatient(widget.patientId),
      latestParent: pair.parent,
      latestTeacher: pair.teacher,
      now: widget.now,
    );
    unawaited(
      TelemetryService.instance.capture(
        'patient_pulse.viewed',
        properties: {
          'fit': pulse.fit.signal.name,
          'adherence': pulse.adherence.signal.name,
          'tolerability': pulse.tolerability.signal.name,
          'adhd': pulse.adhd.signal.name,
          'overall': pulse.overall.name,
        },
      ),
    );
    setState(() {
      _pulse = pulse;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.patientName ?? widget.patientId;
    return AppShell(
      routeName: '/outcomes/pulse',
      title: 'Patient pulse',
      subtitle:
          'Worst-of-four snapshot across alliance/outcome, adherence, '
          'tolerability, and ADHD subtype.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Outcomes', '/outcomes'),
        Crumb('Pulse', null),
      ],
      child: _loading || _pulse == null
          ? const Center(child: CircularProgressIndicator())
          : _PulseBody(pulse: _pulse!, patientName: name),
    );
  }
}

class _PulseBody extends StatelessWidget {
  const _PulseBody({required this.pulse, required this.patientName});
  final PatientPulse pulse;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PsyCard(
          tinted: true,
          child: Row(
            children: [
              _SignalDot(signal: pulse.overall, large: true),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall: ${_signalLabel(pulse.overall)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _overallHint(pulse),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    patientName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'as of ${_formatNow()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 900 ? 2 : 1;
            final children = [
              _PulseTile(
                title: 'Alliance and outcome (FIT)',
                signal: pulse.fit.signal,
                primaryValue: _fitPrimary(pulse.fit),
                primaryLabel: 'latest ORS / SRS',
                hint: _fitHint(pulse.fit),
                cta: 'Record FIT scores',
                ctaRoute: '/feedback/capture',
              ),
              _PulseTile(
                title: 'Medication adherence (MAR)',
                signal: pulse.adherence.signal,
                primaryValue: '${pulse.adherence.summary.adherencePct}%',
                primaryLabel:
                    '${pulse.adherence.summary.taken} of '
                    '${pulse.adherence.summary.scheduled - pulse.adherence.summary.skipped} taken (30d)',
                hint: _adherenceHint(pulse.adherence),
                cta: 'Open MAR',
                ctaRoute: '/medications/mar',
              ),
              _PulseTile(
                title: 'Tolerability (side effects)',
                signal: pulse.tolerability.signal,
                primaryValue: '${pulse.tolerability.summary.ongoing}',
                primaryLabel:
                    'ongoing (${pulse.tolerability.summary.clinicallySignificant} moderate+)',
                hint: _tolerabilityHint(pulse.tolerability),
                cta: 'Open SE log',
                ctaRoute: '/medications/mar',
              ),
              _PulseTile(
                title: 'ADHD subtype (Vanderbilt)',
                signal: pulse.adhd.signal,
                primaryValue: _subtypeShort(pulse.adhd.subtype),
                primaryLabel:
                    '${pulse.adhd.respondentsCovered}/2 respondents captured',
                hint: _adhdHint(pulse.adhd),
                cta: 'Run Vanderbilt',
                ctaRoute: '/assessments/vanderbilt',
              ),
            ];
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              childAspectRatio: cols == 2 ? 2.0 : 2.4,
              mainAxisSpacing: PsySpacing.md,
              crossAxisSpacing: PsySpacing.md,
              children: children,
            );
          },
        ),
      ],
    );
  }

  String _formatNow() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String _signalLabel(PulseSignal s) => switch (s) {
    PulseSignal.ok => 'On track',
    PulseSignal.watch => 'Watch',
    PulseSignal.concern => 'Needs attention',
  };

  String _overallHint(PatientPulse p) {
    if (p.overall == PulseSignal.ok) {
      return 'All four signals are within thresholds. Routine follow-up.';
    }
    final concerns = <String>[];
    if (p.fit.signal == PulseSignal.concern) concerns.add('alliance/outcome');
    if (p.adherence.signal == PulseSignal.concern) concerns.add('adherence');
    if (p.tolerability.signal == PulseSignal.concern) {
      concerns.add('tolerability');
    }
    if (p.adhd.signal == PulseSignal.concern) concerns.add('ADHD severity');
    if (concerns.isNotEmpty) {
      return 'Concern: ${concerns.join(', ')}. Open the matching tile.';
    }
    return 'One or more signals need a check — see tiles below.';
  }

  String _fitPrimary(FitPulse f) {
    final ors = f.latestOrs?.total;
    final srs = f.latestSrs?.total;
    if (ors == null && srs == null) return '—';
    if (ors == null) return 'SRS $srs / 40';
    if (srs == null) return 'ORS $ors / 40';
    return 'ORS $ors · SRS $srs';
  }

  String _fitHint(FitPulse f) {
    if (f.dropoutSignal) {
      return 'ORS dropped by 5 or more between the last two sessions — Miller dropout signal.';
    }
    if (f.latestOrs?.isBelowCutoff == true) {
      return 'ORS at or below the 25/40 clinical cutoff.';
    }
    if (f.latestSrs?.isBelowCutoff == true) {
      return 'SRS at or below the 36/40 alliance cutoff.';
    }
    if (f.latestOrs == null && f.latestSrs == null) {
      return 'No ORS / SRS captured yet — start at the next visit.';
    }
    return 'ORS and SRS above their cutoffs.';
  }

  String _adherenceHint(AdherencePulse a) {
    if (a.summary.scheduled == 0) {
      return 'No scheduled doses in the last 30 days.';
    }
    final pct = a.summary.adherencePct;
    if (pct < 80) {
      return 'Adherence below 80% — consider regimen review.';
    }
    if (pct < 90) {
      return 'Adherence 80-89% — mention at next visit.';
    }
    return 'Adherence on track.';
  }

  String _tolerabilityHint(TolerabilityPulse t) {
    if (t.summary.clinicallySignificant > 0) {
      return '${t.summary.clinicallySignificant} moderate+ side effect(s) ongoing.';
    }
    if (t.summary.ongoing > 0) {
      return '${t.summary.ongoing} mild side effect(s) ongoing.';
    }
    return 'No active side-effect reports.';
  }

  String _adhdHint(AdhdPulse a) {
    if (a.subtype == null) {
      return 'No Vanderbilt assessment captured yet.';
    }
    if (a.respondentsCovered < 2) {
      return 'Only ${a.respondentsCovered}/2 respondents — pair with the other form.';
    }
    if (a.subtype == VanderbiltSubtype.none) {
      return 'Below DSM-5 thresholds across both respondents.';
    }
    return 'Positive subtype across both respondents — discuss with patient/family.';
  }

  String _subtypeShort(VanderbiltSubtype? s) => switch (s) {
    null => '—',
    VanderbiltSubtype.none => 'None',
    VanderbiltSubtype.inattentive => 'Inattentive',
    VanderbiltSubtype.hyperactiveImpulsive => 'Hyperactive',
    VanderbiltSubtype.combined => 'Combined',
  };
}

class _PulseTile extends StatelessWidget {
  const _PulseTile({
    required this.title,
    required this.signal,
    required this.primaryValue,
    required this.primaryLabel,
    required this.hint,
    required this.cta,
    required this.ctaRoute,
  });
  final String title;
  final PulseSignal signal;
  final String primaryValue;
  final String primaryLabel;
  final String hint;
  final String cta;
  final String ctaRoute;

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
              _SignalDot(signal: signal),
              const SizedBox(width: PsySpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            primaryValue,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            primaryLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Expanded(
            child: Text(
              hint,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(ctaRoute),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(cta),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalDot extends StatelessWidget {
  const _SignalDot({required this.signal, this.large = false});
  final PulseSignal signal;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (signal) {
      PulseSignal.ok => cs.tertiary,
      PulseSignal.watch => cs.secondary,
      PulseSignal.concern => cs.error,
    };
    final size = large ? 28.0 : 12.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
