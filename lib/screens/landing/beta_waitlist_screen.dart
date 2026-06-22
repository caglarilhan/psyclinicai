import 'package:flutter/material.dart';

import '../../services/data/waitlist_repository.dart';
import '../../theme/tokens.dart';
import '../../utils/theme.dart';

/// `/beta` — public wait-list for pilot clinicians.
///
/// One short form, one Firestore write to `beta_signups/{auto-id}`. No
/// auth, no PHI, no patient-facing copy. The goal is a clean handoff
/// for cold outreach: a clinician lands here from a LinkedIn post or
/// an email signature, fills four fields, gets a confirmation.
class BetaWaitlistScreen extends StatefulWidget {
  const BetaWaitlistScreen({super.key});

  @override
  State<BetaWaitlistScreen> createState() => _BetaWaitlistScreenState();
}

class _BetaWaitlistScreenState extends State<BetaWaitlistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _clinic = TextEditingController();
  final _country = TextEditingController();
  String _region = 'EU';
  String _role = 'clinician';
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _clinic.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    // KRİTİK-10 fix (audit 2026-06-21): route through WaitlistRepository
    // so this screen no longer touches Firestore directly. The
    // `extra` map carries the beta-specific fields the public landing
    // flow doesn't capture (clinic, country, region, role).
    final outcome = await WaitlistRepository.instance.recordBetaSignup(
      email: _email.text,
      extra: {
        'clinic_name': _clinic.text.trim(),
        'country': _country.text.trim(),
        'region': _region,
        'role': _role,
        'source': 'web/beta',
      },
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      switch (outcome) {
        case WaitlistOutcome.saved:
          _submitted = true;
        case WaitlistOutcome.skipped:
          _error =
              'Backend not configured for this build — try again from production.';
        case WaitlistOutcome.denied:
          _error =
              'Could not submit. Please try again — or email support@psyclinicai.com.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('PsyClinicAI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to home',
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/landing'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PsySpacing.xl),
            child: _submitted
                ? _SuccessCard(email: _email.text.trim())
                : _form(theme),
          ),
        ),
      ),
    );
  }

  Widget _form(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Join the clinical pilot',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A focused 8-week pilot for psychotherapists and psychiatrists in '
            'the EU and US. You get the platform free during the pilot in '
            'exchange for weekly 15-minute feedback calls.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Work email',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || !_emailRe.hasMatch(v.trim()))
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _clinic,
            decoration: const InputDecoration(
              labelText: 'Clinic / practice name',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().length < 2) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _country,
            decoration: const InputDecoration(
              labelText: 'Country (e.g. Germany, USA, Türkiye)',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().length < 2) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Region:'),
              const SizedBox(width: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'EU', label: Text('EU')),
                  ButtonSegment(value: 'US', label: Text('US')),
                  ButtonSegment(value: 'TR', label: Text('TR')),
                ],
                selected: {_region},
                onSelectionChanged: _submitting
                    ? null
                    : (s) => setState(() => _region = s.first),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Role:'),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'clinician', label: Text('Clinician')),
                    ButtonSegment(
                      value: 'admin',
                      label: Text('Practice admin'),
                    ),
                    ButtonSegment(
                      value: 'researcher',
                      label: Text('Researcher'),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: _submitting
                      ? null
                      : (s) => setState(() => _role = s.first),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: PsySpacing.xl),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: const Icon(Icons.send),
            label: Text(_submitting ? 'Sending…' : 'Join the wait-list'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We email you within 5 working days. No marketing list — only '
            'pilot-related messages.',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.email});
  final String email;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.xl),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 56),
            const SizedBox(height: 16),
            Text(
              "You're on the list",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We will email $email within 5 working days with the next steps. '
              'Reply to that email if you have follow-up questions in the meantime.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: PsySpacing.xl),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/landing'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to landing'),
            ),
          ],
        ),
      ),
    );
  }
}
