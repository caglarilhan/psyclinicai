import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';

/// Dedicated "forgot password" screen reached from the login screen. Calls
/// Firebase Auth's [FirebaseAuthService.sendPasswordReset]; on success
/// shows a confirmation state so the clinician knows to check their inbox.
///
/// Surfaces an explicit no-backend message instead of pretending to send
/// the email — a silent success on a misconfigured build would be worse
/// than telling the user to come back later.
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key, this.prefilledEmail});

  /// Optional email to seed the field with — supplied by the login screen
  /// so the clinician doesn't have to retype it.
  final String? prefilledEmail;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  bool _loading = false;
  bool _sent = false;
  String? _error;

  bool get _backendReady => PsyFirebase.isReady;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.prefilledEmail ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_backendReady) {
      setState(
        () => _error =
            'Password reset requires a configured backend. Contact your admin.',
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final started = DateTime.now();
    final result = await FirebaseAuthService.instance.sendPasswordReset(
      _email.text.trim(),
    );
    final elapsed = DateTime.now().difference(started);
    const floor = Duration(milliseconds: 800);
    if (elapsed < floor) {
      await Future<void>.delayed(floor - elapsed);
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success || _isEnumerationProbe(result.error)) {
      unawaited(
        TelemetryService.instance.capture(TelemetryEvents.passwordResetSent),
      );
      setState(() => _sent = true);
    } else {
      setState(() => _error = 'Could not send reset link. Try again.');
    }
  }

  bool _isEnumerationProbe(String? error) {
    if (error == null) return false;
    final lower = error.toLowerCase();
    return lower.contains('not found') ||
        lower.contains('no user') ||
        lower.contains('does not exist');
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.xl,
            vertical: PsySpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(PsySpacing.xl),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(PsyRadius.lg),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: _sent ? _buildSent(theme) : _buildForm(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    final cs = theme.colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reset your password',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Enter your email and we will send a reset link if an account '
            'exists for it. Either way you will see the same confirmation, '
            'so account existence is never disclosed.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: _validateEmail,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: PsySpacing.md),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(PsySpacing.md),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(PsyRadius.md),
                  border: Border.all(color: cs.error.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 18),
                    const SizedBox(width: PsySpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: PsySpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send reset link'),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).maybePop(),
              child: const Text('Back to sign in'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSent(ThemeData theme) {
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(PsySpacing.sm),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(PsyRadius.md),
          ),
          child: Icon(Icons.mark_email_read_outlined, color: cs.primary),
        ),
        const SizedBox(height: PsySpacing.md),
        Text(
          'Check your inbox',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        Text(
          'If an account exists for ${_email.text.trim()}, a reset link is '
          'on its way. The link expires in one hour. If it does not arrive '
          'within a few minutes, check spam or request another. Requests '
          'use a constant-time response so account presence cannot be '
          'inferred from timing.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: PsySpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            child: const Text('Back to sign in'),
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => setState(() => _sent = false),
            child: const Text('Use a different email'),
          ),
        ),
      ],
    );
  }
}
