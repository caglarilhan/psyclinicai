import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/data/firebase_bootstrap.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/e_prescription` — honest "coming Q4 2026" landing for the
/// e-prescribing module. US SureScripts integration is a 6–9 month
/// build behind DEA EPCS + IdP onboarding; until then we collect
/// early-access interest rather than ship a fake prescription pad.
class EPrescriptionScreen extends StatefulWidget {
  const EPrescriptionScreen({super.key});

  @override
  State<EPrescriptionScreen> createState() =>
      _EPrescriptionScreenState();
}

class _EPrescriptionScreenState extends State<EPrescriptionScreen> {
  final _email = TextEditingController();
  final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  bool _saving = false;
  String? _status;
  bool _ok = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final v = _email.text.trim();
    if (!_emailRe.hasMatch(v)) {
      setState(() {
        _status = 'Enter a valid email address.';
        _ok = false;
      });
      return;
    }
    if (v.length > 320) {
      setState(() {
        _status = 'Email is too long.';
        _ok = false;
      });
      return;
    }
    setState(() {
      _saving = true;
      _status = null;
    });
    if (!PsyFirebase.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _saving = false;
        _ok = true;
        _status = "Recorded locally (demo mode). We'll email you when "
            'e-prescribing goes live.';
        _email.clear();
      });
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('landing_waitlist')
          .add({
        'email': v,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'eprescribing',
      });
      if (!mounted) return;
      setState(() {
        _saving = false;
        _ok = true;
        _status =
            "You're on the early-access list. We'll email you when "
                'e-prescribing goes live.';
        _email.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _ok = false;
        _status = 'Could not save: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/e_prescription',
      title: 'e-Prescribing',
      subtitle: 'SureScripts + DEA EPCS — general availability Q4 2026.',
      scrollable: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: PsySpacing.xl),
            children: [
              Text('US e-prescribing, built right.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  )),
              const SizedBox(height: PsySpacing.md),
              Text(
                "We won't ship a prescription pad that isn't certified. "
                'PsyClinicAI e-prescribing will route through SureScripts '
                'with DEA EPCS for controlled substances. Targeting general '
                'availability in Q4 2026 (US, then EU via national '
                'connectors). Join the early-access list — we ship to '
                'your inbox first.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.78),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: PsySpacing.xxl),
              PsyCard(
                tinted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Get early access',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: PsySpacing.sm),
                    Text(
                      'We email each milestone. No newsletter, no '
                      'marketing list — just product updates.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: PsySpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              hintText: 'you@clinic.com',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        const SizedBox(width: PsySpacing.md),
                        PsyButton(
                          label: 'Notify me',
                          icon: Icons.arrow_forward,
                          loading: _saving,
                          onPressed: _saving ? null : _submit,
                        ),
                      ],
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: PsySpacing.md),
                      Row(
                        children: [
                          Icon(
                            _ok
                                ? Icons.check_circle
                                : Icons.error_outline,
                            color: _ok ? PsyColors.success : cs.error,
                            size: 18,
                          ),
                          const SizedBox(width: PsySpacing.sm),
                          Expanded(
                            child: Text(_status!,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: _ok
                                      ? PsyColors.success
                                      : cs.error,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: PsySpacing.xxxl),
              Text('Roadmap',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: PsySpacing.lg),
              const _Step(
                  done: true,
                  title: 'SureScripts onboarding application',
                  detail: 'Software-vendor agreement submitted; '
                      'integration discovery in progress.'),
              const _Step(
                  done: false,
                  title: 'DEA EPCS audit (Identrust / Symantec)',
                  detail: 'Two-factor identity proofing + audited '
                      'prescription signing for controlled substances.'),
              const _Step(
                  done: false,
                  title: 'Closed beta — 25 US prescribers',
                  detail: 'Non-controlled substances first; controlled '
                      'unlocks after EPCS audit passes.'),
              const _Step(
                  done: false,
                  title: 'General availability (Q4 2026)',
                  detail: 'SureScripts certified, EPCS-ready, '
                      'state-by-state PDMP integrations live.'),
              const SizedBox(height: PsySpacing.xxl),
              PsyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: cs.primary),
                        const SizedBox(width: PsySpacing.sm),
                        Text('Why we wait',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: PsySpacing.md),
                    Text(
                      "Prescribing isn't a UI feature — it's a chain of "
                      'liability that ends at the DEA, the pharmacy, and '
                      'the patient. We will not ship a faux-prescription '
                      'pad that prints a PDF and calls it done. When you '
                      'click Send, the script reaches the pharmacy through '
                      "a certified network or it doesn't ship.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.78),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(
      {required this.done, required this.title, required this.detail});
  final bool done;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = done ? PsyColors.success : cs.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: done
                  ? PsyColors.success.withValues(alpha: 0.15)
                  : cs.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: done
                    ? PsyColors.success
                    : cs.onSurface.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check,
                    size: 14, color: PsyColors.success)
                : null,
          ),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    )),
                const SizedBox(height: 2),
                Text(detail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                      height: 1.45,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
