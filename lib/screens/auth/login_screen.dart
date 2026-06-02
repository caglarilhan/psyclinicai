import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/build_config.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/firestore_schema.dart';
import '../../services/data/onboarding_service.dart';
import '../../services/data/security_settings_service.dart';
import '../../services/data/telemetry_service.dart';

enum _Mode { signIn, signUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  ClinicianRole _role = ClinicianRole.therapist;
  _Mode _mode = _Mode.signIn;
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  bool get _backendReady => PsyFirebase.isReady;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    if (!_backendReady) {
      if (!BuildConfig.isDemo) {
        // Release build with no working backend is a misconfiguration — never
        // silently grant unauthenticated access.
        setState(() {
          _loading = false;
          _error = 'Service is temporarily unavailable. Please try again later.';
        });
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 600));
      // Demo mode: returning visitors skip the wizard — first-timers see it.
      final done =
          await OnboardingService.instance.isOnboarded('demo');
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacementNamed(done ? '/dashboard' : '/onboarding');
      return;
    }

    final auth = FirebaseAuthService.instance;
    final result = _mode == _Mode.signIn
        ? await auth.signIn(
            email: _email.text,
            password: _password.text,
          )
        : await auth.signUp(
            email: _email.text,
            password: _password.text,
            fullName: _fullName.text,
            role: _role,
          );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      final email = _email.text.trim();
      TelemetryService.instance.capture(
        _mode == _Mode.signIn
            ? TelemetryEvents.signInCompleted
            : TelemetryEvents.signUpCompleted,
        properties: {'mode': _mode.name},
      );
      // Identify on a SHA-256 fingerprint so analytics never sees a raw
      // PHI-adjacent identifier (GDPR Art. 25 — privacy by design).
      final emailFingerprint =
          sha256.convert(utf8.encode(email.toLowerCase())).toString();
      TelemetryService.instance
          .identify(emailFingerprint, traits: {'email_hash': emailFingerprint});
      // Post-sign-in interceptor (HIPAA §164.312(d)).
      // The UID source MUST match the one the MFA wizard wrote under
      // (`mfa_setup_screen._finish` uses `userId ?? "demo"`). Email-
      // derived keys collide and let attackers bypass MFA.
      final uid = auth.profile?.userId ?? 'demo';
      String route;
      try {
        final mfaOk =
            await SecuritySettingsService.instance.isMfaEnrolled(uid);
        if (!mounted) return;
        if (_mode == _Mode.signUp || !mfaOk) {
          route = '/settings/mfa';
        } else {
          final done =
              await OnboardingService.instance.isCurrentUserOnboarded();
          if (!mounted) return;
          route = done ? '/dashboard' : '/onboarding';
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error =
              'We signed you in but could not check your security '
              'settings. Please retry — we will route you to MFA setup '
              'if it is needed.';
        });
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      setState(() => _error = result.error ?? 'Unknown error');
    }
  }

  void _resetPassword() {
    // Hand off to the dedicated reset screen so the clinician gets a
    // confirmation state (and a chance to fix typos) instead of guessing
    // what a snackbar meant. The current email seeds the form.
    Navigator.of(context).pushNamed(
      '/auth/password_reset',
      arguments: _email.text.trim().isEmpty ? null : _email.text.trim(),
    );
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _passwordValidator(String? v) {
    if ((v ?? '').isEmpty) return 'Password is required';
    if (_mode == _Mode.signUp && v!.length < 8) {
      return 'Minimum 8 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSignUp = _mode == _Mode.signUp;

    return Scaffold(
      // Clean clinical surface — not a gradient app screen — and a compact
      // header so the back button sits close to the card.
      backgroundColor: cs.surfaceContainerLow,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: cs.onSurface,
        toolbarHeight: 44,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: cs.surfaceContainerLow),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      // Errors update as the user types (not before they touch
                      // anything), instead of staying red across a blank form.
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Logo(cs: cs),
                          const SizedBox(height: 18),
                          Text(
                            'PsyClinicAI',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSignUp
                                ? 'Create your clinician account'
                                : 'Sign in to continue',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Demo helper is for developers only — visitors
                          // arriving from the landing page should see a clean
                          // sign-in, not a yellow "debug" callout.
                          if (!_backendReady && kDebugMode)
                            _backendBanner(cs),
                          if (!_backendReady) const SizedBox(height: 14),
                          _segmented(),
                          const SizedBox(height: 20),
                          if (isSignUp) ...[
                            TextFormField(
                              controller: _fullName,
                              textCapitalization: TextCapitalization.words,
                              decoration: _decoration(
                                  'Full name', Icons.badge_outlined),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Full name is required'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<ClinicianRole>(
                              initialValue: _role,
                              decoration: _decoration(
                                  'Role', Icons.work_outline_outlined),
                              items: ClinicianRole.values
                                  .map((r) => DropdownMenuItem(
                                        value: r,
                                        child: Text(r.label),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() =>
                                  _role = v ?? ClinicianRole.therapist),
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration:
                                _decoration('Email', Icons.email_outlined),
                            validator: _emailValidator,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: !_showPassword,
                            autofillHints: const [AutofillHints.password],
                            decoration: _decoration(
                                    'Password', Icons.lock_outline)
                                .copyWith(
                              suffixIcon: IconButton(
                                tooltip: _showPassword
                                    ? 'Hide password'
                                    : 'Show password',
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                                icon: Icon(_showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                            validator: _passwordValidator,
                          ),
                          if (!isSignUp)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _resetPassword,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 4),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                child: const Text('Forgot password?'),
                              ),
                            ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            // Announce auth/validation errors to screen readers.
                            Semantics(
                              liveRegion: true,
                              child: _errorBanner(_error!),
                            ),
                          ],
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed: _loading ? null : _submit,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Text(
                                    isSignUp ? 'Create account' : 'Sign in',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Two-factor authentication is '
                                    'required for HIPAA accounts. '
                                    'Enrol after signing in — Settings '
                                    '› Two-factor authentication.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _segmented() {
    final cs = Theme.of(context).colorScheme;
    return SegmentedButton<_Mode>(
      // Drop the leading ✓ — on a narrow phone width it pushes the segment
      // group ~0.7 px past the card and Flutter paints a debug "OVERFLOWED"
      // stripe between the logo and the form.
      showSelectedIcon: false,
      // Selected segment reads clearly as the active state.
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? cs.primary : cs.surface),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? cs.onPrimary
                : cs.onSurfaceVariant),
        textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600)),
      ),
      segments: const [
        ButtonSegment(value: _Mode.signIn, label: Text('Sign in')),
        ButtonSegment(value: _Mode.signUp, label: Text('Sign up')),
      ],
      selected: {_mode},
      onSelectionChanged: (s) => setState(() {
        _mode = s.first;
        _error = null;
      }),
    );
  }

  InputDecoration _decoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  Widget _backendBanner(ColorScheme cs) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Demo mode — sign in with any email + 8+ char password '
                '(e.g. demo@psyclinicai.com / demo1234) to enter the app. '
                'Real accounts require `flutterfire configure`.',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.8),
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _errorBanner(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
        ),
      );
}

class _Logo extends StatelessWidget {
  const _Logo({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    // Solid teal tile + Icons.psychology — same icon the landing AppBar uses,
    // so the brand reads consistently from landing → login.
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.psychology,
            color: cs.onPrimary, size: 34),
      ),
    );
  }
}
