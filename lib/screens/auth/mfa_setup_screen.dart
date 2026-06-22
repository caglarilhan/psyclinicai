import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/security_settings_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../services/mfa/totp_service.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/mfa` — Two-factor authentication setup hub.
///
/// Four-step TOTP enrolment wizard backed by [TotpService] (pure-Dart
/// RFC 6238). Secrets and recovery codes stay on-device for the demo;
/// production wiring posts the SHA-256 hash of each recovery code +
/// the encrypted secret to Firestore `mfa_enrolments/{uid}` once the
/// Firebase Auth multi-factor binding lands.
///
/// HIPAA §164.312(d) and SOC 2 CC6.1 both require MFA on accounts
/// that touch ePHI — this screen is the user-facing surface.
class MfaSetupScreen extends StatefulWidget {
  const MfaSetupScreen({super.key, @visibleForTesting this.totpOverride});

  /// Tests can inject a deterministic [TotpService]; production
  /// constructs one with `Random.secure()`.
  final TotpService? totpOverride;

  @override
  State<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

enum MfaStep { idle, scan, verify, recovery, done }

/// Writes [value] to the clipboard, then schedules a wipe 60 s later
/// so MFA secrets / recovery codes do not linger on the system
/// clipboard for the next app to pick up.
Future<void> _copyWithAutoClear(String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  Future<void>.delayed(const Duration(seconds: 60), () async {
    final current = await Clipboard.getData(Clipboard.kTextPlain);
    if (current?.text == value) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  });
}

class _MfaSetupScreenState extends State<MfaSetupScreen> {
  late final TotpService _totp = widget.totpOverride ?? TotpService();
  final TextEditingController _codeCtl = TextEditingController();

  MfaStep _step = MfaStep.idle;
  String? _secret;
  List<String> _recoveryCodes = const [];
  String? _error;
  bool _verifying = false;

  @override
  void dispose() {
    _codeCtl.dispose();
    super.dispose();
  }

  String _accountLabel() {
    final email =
        FirebaseAuthService.instance.profile?.email ?? 'demo@psyclinicai.com';
    return email;
  }

  void _startEnrol() {
    setState(() {
      _secret = _totp.generateSecret();
      _step = MfaStep.scan;
      _error = null;
    });
    unawaited(TelemetryService.instance.capture('security.mfa_enrol_started'));
  }

  Future<void> _verifyCode() async {
    if (_secret == null) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    bool ok;
    try {
      ok = _totp.verify(secret: _secret!, code: _codeCtl.text.trim());
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error =
            'The stored secret could not be read. Restart the '
            'setup to regenerate one.';
      });
      return;
    }
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _verifying = false;
        _error =
            'That code did not match. Wait for the next window and '
            'try again.';
      });
      return;
    }
    final codes = _totp.generateRecoveryCodes();
    setState(() {
      _verifying = false;
      _recoveryCodes = codes;
      _step = MfaStep.recovery;
    });
    unawaited(TelemetryService.instance.capture('security.mfa_enrol_verified'));
  }

  Future<void> _finish() async {
    final uid = FirebaseAuthService.instance.profile?.userId ?? 'demo';
    try {
      await SecuritySettingsService.instance.markMfaEnrolled(uid);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'We verified the code but could not persist your '
            'enrolment. Try again from the recovery step.';
      });
      unawaited(
        TelemetryService.instance.capture('security.mfa_enrol_persist_failed'),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _step = MfaStep.done);
    unawaited(
      TelemetryService.instance.capture('security.mfa_enrol_completed'),
    );
  }

  void _restart() {
    setState(() {
      _step = MfaStep.idle;
      _secret = null;
      _recoveryCodes = const [];
      _codeCtl.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/settings',
      title: 'Two-factor authentication',
      subtitle: 'Add a second factor to your sign-in.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Two-factor authentication', null),
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _StatusCard(step: _step, cs: cs, theme: theme),
          const SizedBox(height: PsySpacing.xl),
          _StepIndicator(step: _step, cs: cs),
          const SizedBox(height: PsySpacing.lg),
          switch (_step) {
            MfaStep.idle => _IdlePane(onStart: _startEnrol),
            MfaStep.scan => _ScanPane(
              secret: _secret!,
              uri: _totp.provisioningUri(
                label: _accountLabel(),
                secret: _secret!,
              ),
              onContinue: () => setState(() => _step = MfaStep.verify),
              onCancel: _restart,
            ),
            MfaStep.verify => _VerifyPane(
              controller: _codeCtl,
              onVerify: _verifying ? null : _verifyCode,
              onBack: () => setState(() => _step = MfaStep.scan),
              error: _error,
              busy: _verifying,
            ),
            MfaStep.recovery => _RecoveryPane(
              codes: _recoveryCodes,
              onFinish: _finish,
            ),
            MfaStep.done => _DonePane(onReset: _restart),
          },
          const SizedBox(height: PsySpacing.huge),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.step,
    required this.cs,
    required this.theme,
  });
  final MfaStep step;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final enabled = step == MfaStep.done;
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PsySpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PsyRadius.md),
            ),
            child: Icon(
              enabled ? Icons.verified_user : Icons.shield_outlined,
              color: cs.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    PsyBadge(
                      label: enabled ? 'Enabled' : 'Not enabled',
                      tone: enabled
                          ? PsyBadgeTone.success
                          : PsyBadgeTone.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  enabled
                      ? 'TOTP enrolled on this device. Sign-ins now require a '
                            '6-digit code from your authenticator app.'
                      : 'Your account is currently protected by your password '
                            'and Firebase Auth session controls. HIPAA §164.312(d) '
                            'requires a second factor before storing ePHI.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.cs});
  final MfaStep step;
  final ColorScheme cs;

  static const _labels = ['Start', 'Scan QR', 'Verify', 'Recovery', 'Done'];

  int get _activeIndex {
    switch (step) {
      case MfaStep.idle:
        return 0;
      case MfaStep.scan:
        return 1;
      case MfaStep.verify:
        return 2;
      case MfaStep.recovery:
        return 3;
      case MfaStep.done:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: List.generate(_labels.length, (i) {
        final active = i <= _activeIndex;
        final isLast = i == _labels.length - 1;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active ? cs.primary : cs.surfaceContainerHigh,
                child: Text(
                  '${i + 1}',
                  style: t.labelSmall?.copyWith(
                    color: active ? cs.onPrimary : cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.xs),
              Flexible(
                child: Text(
                  _labels[i],
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active
                        ? cs.onSurface
                        : cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: PsySpacing.sm,
                    ),
                    color: active
                        ? cs.primary.withValues(alpha: 0.4)
                        : cs.surfaceContainerHigh,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _IdlePane extends StatelessWidget {
  const _IdlePane({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up an authenticator app',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'You will scan a QR code with Google Authenticator, Authy, '
            '1Password, or any RFC 6238 app, then enter the 6-digit code '
            'it shows you. Takes about 60 seconds.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PsySpacing.lg),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Start TOTP setup'),
          ),
        ],
      ),
    );
  }
}

class _ScanPane extends StatelessWidget {
  const _ScanPane({
    required this.secret,
    required this.uri,
    required this.onContinue,
    required this.onCancel,
  });
  final String secret;
  final String uri;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1 · Scan the QR code',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Open your authenticator app and scan this code. If you cannot '
            'scan, enter the secret manually.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PsySpacing.lg),
          Center(
            child: Container(
              padding: const EdgeInsets.all(PsySpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(PsyRadius.md),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: QrImageView(
                data: uri,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: PsySpacing.lg),
          Text(
            'Manual secret',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  _grouped(secret),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy secret (auto-clears in 60s)',
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => _copyWithAutoClear(secret),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.lg),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('I have scanned the code'),
              ),
              const SizedBox(width: PsySpacing.sm),
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
            ],
          ),
        ],
      ),
    );
  }

  String _grouped(String secret) {
    final out = StringBuffer();
    for (var i = 0; i < secret.length; i += 4) {
      if (i > 0) out.write(' ');
      out.write(secret.substring(i, (i + 4).clamp(0, secret.length)));
    }
    return out.toString();
  }
}

class _VerifyPane extends StatelessWidget {
  const _VerifyPane({
    required this.controller,
    required this.onVerify,
    required this.onBack,
    required this.error,
    required this.busy,
  });
  final TextEditingController controller;
  final VoidCallback? onVerify;
  final VoidCallback onBack;
  final String? error;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2 · Verify the 6-digit code',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Enter the current code from your authenticator. Codes refresh '
            'every 30 seconds — we accept the previous window if you are a '
            'little late.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PsySpacing.lg),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '6-digit code',
              hintText: '123 456',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onVerify?.call(),
          ),
          if (error != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: PsyColors.warning,
              ),
            ),
          ],
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onVerify,
                icon: busy
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Verify'),
              ),
              const SizedBox(width: PsySpacing.sm),
              TextButton(onPressed: onBack, child: const Text('Back')),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoveryPane extends StatelessWidget {
  const _RecoveryPane({required this.codes, required this.onFinish});
  final List<String> codes;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3 · Save your recovery codes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Each code can be used once if you lose access to your '
            'authenticator. Store them in a password manager — we only '
            'keep a one-way hash on our side.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PsySpacing.lg),
          Container(
            padding: const EdgeInsets.all(PsySpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(PsyRadius.md),
            ),
            child: Wrap(
              spacing: PsySpacing.lg,
              runSpacing: PsySpacing.sm,
              children: [
                for (final c in codes)
                  SelectableText(
                    c,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('I saved them — finish'),
              ),
              const SizedBox(width: PsySpacing.sm),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy all (auto-clears in 60s)'),
                onPressed: () => _copyWithAutoClear(codes.join('\n')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonePane extends StatelessWidget {
  const _DonePane({required this.onReset});
  final VoidCallback onReset;

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
              Icon(Icons.verified_user, color: cs.primary),
              const SizedBox(width: PsySpacing.sm),
              Text(
                'TOTP enabled on this device',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Your next sign-in will ask for the 6-digit code from your '
            'authenticator. Lost your phone? Use one of the recovery codes '
            'you just saved — each works once.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PsySpacing.md),
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
            label: const Text('Re-enrol (lost device)'),
          ),
        ],
      ),
    );
  }
}
