import 'package:flutter/material.dart';

import '../../models/consent_record.dart';
import '../../models/patient_intake.dart';
import '../../services/data/intake_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import 'patient_list_screen.dart' show PatientDetailArgs;

/// `/patients/intake` — collaborative intake form completed at or before
/// the first clinical session. Captures the demographics + safety baseline
/// + GDPR/KVKK e-consent in a single submit.
///
/// Decision-support: the form is not a diagnostic instrument; it is a
/// structured handoff between the front desk, the clinician, and the
/// patient. The clinician will refine the chart over follow-up sessions.
class IntakeFormScreen extends StatefulWidget {
  const IntakeFormScreen({super.key, required this.args});

  final PatientDetailArgs args;

  @override
  State<IntakeFormScreen> createState() => _IntakeFormScreenState();
}

class _IntakeFormScreenState extends State<IntakeFormScreen> {
  /// YYYY-MM marker stamped onto every consent record. Bump this whenever
  /// the privacy policy text materially changes so legal can correlate
  /// disputes with the language the patient agreed to.
  static const String _consentPolicyVersion = '2026-06';

  final _repo = IntakeRepository();

  final _fullName = TextEditingController();
  final _gender = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _presenting = TextEditingController();
  final _medicalHistory = TextEditingController();
  final _mentalHistory = TextEditingController();
  final _substanceUse = TextEditingController();
  final _signature = TextEditingController();

  DateTime? _dob;
  final List<String> _allergies = [];
  final List<String> _medications = [];
  bool _priorSuicideAttempt = false;
  bool _priorSelfHarm = false;
  bool _consentDataProcessing = false;
  bool _consentAi = false;
  bool _consentSensitive = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fullName.text = widget.args.name;
    _init();
  }

  Future<void> _init() async {
    await _repo.initialize();
    final existing = _repo.forPatient(widget.args.id);
    if (existing != null) _apply(existing);
    if (mounted) setState(() => _loading = false);
  }

  void _apply(PatientIntake p) {
    _fullName.text = p.fullName;
    _gender.text = p.gender ?? '';
    _phone.text = p.phone ?? '';
    _email.text = p.email ?? '';
    _emergencyName.text = p.emergencyContactName ?? '';
    _emergencyPhone.text = p.emergencyContactPhone ?? '';
    _presenting.text = p.presentingConcern;
    _medicalHistory.text = p.medicalHistory;
    _mentalHistory.text = p.mentalHealthHistory;
    _substanceUse.text = p.substanceUse;
    _dob = p.dateOfBirth;
    _allergies
      ..clear()
      ..addAll(p.allergies);
    _medications
      ..clear()
      ..addAll(p.currentMedications);
    _priorSuicideAttempt = p.priorSuicideAttempt;
    _priorSelfHarm = p.priorSelfHarm;
    final c = p.consent;
    if (c != null) {
      _consentDataProcessing = c.dataProcessingConsent;
      _consentAi = c.aiAssistanceConsent;
      _consentSensitive = c.sensitiveDataConsent;
      _signature.text = c.signedFullName;
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _gender.dispose();
    _phone.dispose();
    _email.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    _presenting.dispose();
    _medicalHistory.dispose();
    _mentalHistory.dispose();
    _substanceUse.dispose();
    _signature.dispose();
    super.dispose();
  }

  PatientIntake _current() {
    final consent = ConsentRecord(
      patientId: widget.args.id,
      policyVersion: _consentPolicyVersion,
      dataProcessingConsent: _consentDataProcessing,
      aiAssistanceConsent: _consentAi,
      sensitiveDataConsent: _consentSensitive,
      signedFullName: _signature.text.trim(),
    );
    return PatientIntake(
      patientId: widget.args.id,
      fullName: _fullName.text.trim(),
      dateOfBirth: _dob,
      gender: _gender.text.trim().isEmpty ? null : _gender.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      emergencyContactName: _emergencyName.text.trim().isEmpty
          ? null
          : _emergencyName.text.trim(),
      emergencyContactPhone: _emergencyPhone.text.trim().isEmpty
          ? null
          : _emergencyPhone.text.trim(),
      presentingConcern: _presenting.text.trim(),
      allergies: List.of(_allergies),
      currentMedications: List.of(_medications),
      medicalHistory: _medicalHistory.text.trim(),
      mentalHealthHistory: _mentalHistory.text.trim(),
      substanceUse: _substanceUse.text.trim(),
      priorSuicideAttempt: _priorSuicideAttempt,
      priorSelfHarm: _priorSelfHarm,
      consent: consent,
    );
  }

  Future<void> _save() async {
    final intake = _current();
    if (!intake.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Name, presenting concern, signature, and required consents '
            'must be completed before saving.'),
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.save(intake);
      TelemetryService.instance.capture('patient.intake_completed',
          properties: {
            'has_emergency_contact':
                intake.emergencyContactName?.isNotEmpty == true,
            'prior_attempt': intake.priorSuicideAttempt,
            'prior_self_harm': intake.priorSelfHarm,
            'ai_consent': intake.consent?.aiAssistanceConsent ?? false,
            'consent_policy_version': _consentPolicyVersion,
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Intake saved — consent recorded.'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not save the intake — please retry.'),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(DateTime.now().year - 30),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final canSave = !_saving && _current().isComplete;

    return AppShell(
      routeName: '/patients',
      title: 'Intake',
      subtitle:
          '${widget.args.name} · demographics, safety baseline, consent',
      breadcrumbs: [
        const Crumb('Home', '/dashboard'),
        const Crumb('Patients', '/patients'),
        Crumb(widget.args.name, null),
        const Crumb('Intake', null),
      ],
      primaryAction: _loading
          ? null
          : FilledButton.icon(
              onPressed: canSave ? _save : null,
              icon: const Icon(Icons.check),
              label: const Text('Save intake'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
              ),
            ),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()))
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _PhiBanner(cs: cs, theme: theme),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '1 · Demographics'),
                PsyCard(
                  child: Column(children: [
                    _field('Full legal name', _fullName,
                        hint: 'Required for the chart and consent record'),
                    _row2(
                      child1: _dobField(theme),
                      child2: _field('Gender (optional)', _gender,
                          hint: 'Self-described'),
                    ),
                    _row2(
                      child1: _field('Phone', _phone),
                      child2: _field('Email', _email,
                          keyboardType: TextInputType.emailAddress),
                    ),
                    _row2(
                      child1: _field('Emergency contact name',
                          _emergencyName,
                          hint:
                              'Who to call if you cannot reach the patient'),
                      child2:
                          _field('Emergency contact phone', _emergencyPhone),
                    ),
                  ]),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '2 · Presenting concern'),
                PsyCard(
                  child: TextField(
                    controller: _presenting,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: "In the patient's own words — what brings "
                          'them in, when it started, how it affects daily '
                          'life.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '3 · Allergies'),
                PsyCard(
                  child: _ChipList(
                    items: _allergies,
                    hint: 'Drug, food, or environmental allergen…',
                    onChanged: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '4 · Current medications'),
                PsyCard(
                  child: _ChipList(
                    items: _medications,
                    hint:
                        'Name + dose + frequency (e.g. "Sertraline 50 mg qD")',
                    onChanged: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '5 · Medical history'),
                PsyCard(
                  child: TextField(
                    controller: _medicalHistory,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Chronic conditions, surgeries, head '
                          'injuries, recent hospitalisations.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '6 · Mental health history'),
                PsyCard(
                  child: TextField(
                    controller: _mentalHistory,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Past diagnoses, prior therapy or '
                          'medication, inpatient stays.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '7 · Substance use'),
                PsyCard(
                  child: TextField(
                    controller: _substanceUse,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Alcohol, tobacco, recreational substances '
                          '— current and past patterns.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '8 · Safety screening'),
                PsyCard(
                  child: Column(children: [
                    _yesNoTile(
                      title: 'Prior suicide attempt (lifetime)',
                      subtitle: 'A yes here should trigger a full C-SSRS '
                          'during the first session.',
                      value: _priorSuicideAttempt,
                      onChanged: (v) =>
                          setState(() => _priorSuicideAttempt = v),
                    ),
                    Divider(height: 1, color: cs.outlineVariant),
                    _yesNoTile(
                      title: 'Prior non-suicidal self-harm',
                      subtitle: 'Cutting, burning, hitting, or similar.',
                      value: _priorSelfHarm,
                      onChanged: (v) => setState(() => _priorSelfHarm = v),
                    ),
                  ]),
                ),
                const SizedBox(height: PsySpacing.xl),
                _section(theme, '9 · Consent'),
                _ConsentCard(
                  policyVersion: _consentPolicyVersion,
                  dataProcessing: _consentDataProcessing,
                  aiAssistance: _consentAi,
                  sensitiveData: _consentSensitive,
                  signature: _signature,
                  onDataChanged: (v) =>
                      setState(() => _consentDataProcessing = v),
                  onAiChanged: (v) => setState(() => _consentAi = v),
                  onSensitiveChanged: (v) =>
                      setState(() => _consentSensitive = v),
                  onSignatureChanged: () => setState(() {}),
                ),
                const SizedBox(height: PsySpacing.huge),
              ],
            ),
    );
  }

  // ─────────────────────────── widgets ───────────────────────────

  Widget _section(ThemeData theme, String title) => Padding(
        padding: const EdgeInsets.only(bottom: PsySpacing.sm),
        child: Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      );

  Widget _field(String label, TextEditingController c,
      {String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _row2({required Widget child1, required Widget child2}) =>
      LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 520) {
          return Column(children: [child1, child2]);
        }
        return Row(children: [
          Expanded(child: child1),
          const SizedBox(width: PsySpacing.md),
          Expanded(child: child2),
        ]);
      });

  Widget _dobField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: InkWell(
        onTap: _pickDob,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            border: OutlineInputBorder(),
            isDense: true,
            suffixIcon: Icon(Icons.calendar_today, size: 16),
          ),
          child: Text(
            _dob == null
                ? 'Tap to pick'
                : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-'
                    '${_dob!.day.toString().padLeft(2, '0')}',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _yesNoTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _PhiBanner extends StatelessWidget {
  const _PhiBanner({required this.cs, required this.theme});
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
      child: Row(children: [
        Icon(Icons.health_and_safety_outlined, color: cs.primary),
        const SizedBox(width: PsySpacing.sm),
        Expanded(
          child: Text(
            'This form holds PHI. It is encrypted at rest on this device '
            'and synced to the patient chart only after you save.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78), height: 1.4),
          ),
        ),
        const SizedBox(width: PsySpacing.sm),
        const PsyBadge(label: 'PHI', tone: PsyBadgeTone.info),
      ]),
    );
  }
}

class _ChipList extends StatefulWidget {
  const _ChipList({
    required this.items,
    required this.hint,
    required this.onChanged,
  });
  final List<String> items;
  final String hint;
  final VoidCallback onChanged;

  @override
  State<_ChipList> createState() => _ChipListState();
}

class _ChipListState extends State<_ChipList> {
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
        Row(children: [
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
              onPressed: _add, icon: const Icon(Icons.add)),
        ]),
      ],
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
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
          Row(children: [
            Text('Privacy policy version',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(width: PsySpacing.sm),
            PsyBadge(label: policyVersion, tone: PsyBadgeTone.neutral),
          ]),
          const SizedBox(height: PsySpacing.md),
          _ConsentRow(
            value: dataProcessing,
            onChanged: onDataChanged,
            required: true,
            title: 'I consent to processing of my personal data',
            body: 'GDPR Art. 6(1)(a) / KVKK Md. 5(2)(a) — required to '
                'open a clinical file and contact me.',
          ),
          _ConsentRow(
            value: sensitiveData,
            onChanged: onSensitiveChanged,
            required: true,
            title: 'I consent to processing of my health data',
            body: 'GDPR Art. 9(2)(a) — explicit consent for the mental-'
                'health information stored in this chart.',
          ),
          _ConsentRow(
            value: aiAssistance,
            onChanged: onAiChanged,
            required: false,
            title:
                'I consent to AI-assisted note drafting (you may withdraw '
                'this at any time)',
            body: 'Session content may be routed to the configured LLM '
                'provider to produce draft notes. Withdrawing this consent '
                'does not affect access to care.',
          ),
          const SizedBox(height: PsySpacing.md),
          Text('Signature',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
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
                fontStyle: FontStyle.italic),
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
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
          ),
          const SizedBox(width: PsySpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  if (required)
                    const PsyBadge(
                        label: 'Required', tone: PsyBadgeTone.warning),
                ]),
                const SizedBox(height: 2),
                Text(body,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
