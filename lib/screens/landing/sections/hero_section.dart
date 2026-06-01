import 'package:flutter/material.dart';

import '../../../widgets/landing/hero_visual.dart';
import '_landing_tokens.dart';

/// Hero section — first viewport, drives the primary CTA.
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onPrimaryCta,
    required this.onSecondaryCta,
    this.onWaitlistEmail,
  });

  /// Plain CTA — used by /landing composer for fallback flows.
  final VoidCallback onPrimaryCta;
  final VoidCallback onSecondaryCta;

  /// Optional waitlist submit handler. When wired, the hero swaps the
  /// plain button for an inline email-capture form — much higher
  /// top-of-funnel conversion.
  final ValueChanged<String>? onWaitlistEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 1024;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // Pill is informational, not a CTA — slimmer padding + just an
          // outline (no fill) so the teal stays reserved for primary
          // actions, per "teal discipline" guideline.
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            border:
                Border.all(color: cs.primary.withValues(alpha: 0.30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FOUNDING ACCESS · 18 of 30 seats left',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your AI co-pilot\nfor therapy sessions.',
          style: theme.textTheme.displayLarge?.copyWith(
            // Mobile headline trimmed -15% (was 38) to keep enterprise
            // weight without overwhelming a 390px viewport. Desktop
            // unchanged — wider canvas tolerates the bigger type.
            fontSize: isWide ? 56 : 32,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Notes drafted in 30 seconds. Superbill PDF in one click. '
          'Audio never leaves the device.',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.78),
            height: 1.5,
            fontWeight: FontWeight.w500,
            fontSize: isWide ? 18 : 15,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'PsyClinicAI listens on-device, drafts a clinical-grade SOAP / '
          'DAP / BIRP note, and generates the CMS-1500-aligned superbill — '
          'so you spend Sunday with your family, not your notes.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.68),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TrustChip(
                icon: Icons.verified_user_outlined,
                label: 'HIPAA-aligned'),
            _TrustChip(
                icon: Icons.gavel_outlined, label: 'GDPR Article 28 DPA'),
            _TrustChip(
                icon: Icons.public_outlined, label: 'EU data residency'),
            _TrustChip(
                icon: Icons.mic_off_outlined,
                label: 'Audio stays on-device'),
            _TrustChip(
                icon: Icons.lock_outline, label: 'AES-256 + TLS 1.3'),
          ],
        ),
        const SizedBox(height: 32),
        if (onWaitlistEmail != null)
          _WaitlistForm(
              cs: cs, theme: theme, onSubmit: onWaitlistEmail!)
        else
          FilledButton.icon(
            onPressed: onPrimaryCta,
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: const Text('Reserve a founding seat'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              textStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: onSecondaryCta,
          icon: const Icon(Icons.play_circle_outline, size: 18),
          label: const Text('Watch 90-sec demo'),
          style: TextButton.styleFrom(
            foregroundColor: cs.onSurface,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationThickness: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'No credit card required during pilot · Cancel anytime · '
          'Export every byte as JSON + PDF on demand.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            height: 1.55,
          ),
        ),
      ],
    );

    final visual = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HeroVisual(),
        const SizedBox(height: 16),
        _captionStrip(cs),
      ],
    );

    return LandingTokens.sectionContainer(
      context: context,
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 5, child: copy),
                const SizedBox(width: 48),
                Expanded(flex: 6, child: visual),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 48),
                visual,
              ],
            ),
    );
  }

  Widget _captionStrip(ColorScheme cs) {
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final dot = Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(color: muted, shape: BoxShape.circle),
    );
    TextStyle s() => TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: muted,
          letterSpacing: 0.6,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('LIVE SESSION', style: s()),
        const SizedBox(width: 10),
        dot,
        const SizedBox(width: 10),
        Text('AI NOTE', style: s()),
        const SizedBox(width: 10),
        dot,
        const SizedBox(width: 10),
        Text('SUPERBILL', style: s()),
      ],
    );
  }
}

/// Inline trust chip — what Upheal puts SOC2/HIPAA badges for; we use the
/// honest signals we can defend today.
class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline email-capture form. Stripe-style: single row [email] [CTA].
/// Lower friction than navigating to /login and seeing a multi-field form.
class _WaitlistForm extends StatefulWidget {
  const _WaitlistForm({
    required this.cs,
    required this.theme,
    required this.onSubmit,
  });
  final ColorScheme cs;
  final ThemeData theme;
  final ValueChanged<String> onSubmit;

  @override
  State<_WaitlistForm> createState() => _WaitlistFormState();
}

class _WaitlistFormState extends State<_WaitlistForm> {
  final _ctrl = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _ctrl.text.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    if (!ok) {
      setState(() => _err = 'Enter a valid work email');
      return;
    }
    setState(() => _err = null);
    widget.onSubmit(v);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.cs.surface,
              border: Border.all(
                color: _err != null
                    ? widget.cs.error
                    : widget.cs.outlineVariant,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.cs.primary.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      hintText: 'you@clinic.com',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      isDense: true,
                      filled: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Get founding access'),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.cs.primary,
                      foregroundColor: widget.cs.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_err != null) ...[
          const SizedBox(height: 6),
          Text(_err!,
              style: TextStyle(
                color: widget.cs.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
        ],
      ],
    );
  }
}
