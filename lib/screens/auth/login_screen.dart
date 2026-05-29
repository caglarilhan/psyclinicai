import 'package:flutter/material.dart';

import '../../config/build_config.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/firestore_schema.dart';
import '../../services/data/onboarding_service.dart';
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
      if (!mounted) return;
      // Demo mode only: surface the wizard so new visitors still see the
      // "first 5 minutes" pitch even without Firebase configured.
      Navigator.of(context).pushReplacementNamed('/onboarding');
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
      TelemetryService.instance.identify(email, traits: {'email': email});
      // New sign-ups always run the wizard; returning sign-ins skip it
      // if they already completed it on any device.
      String route = '/onboarding';
      if (_mode == _Mode.signIn) {
        final done = await OnboardingService.instance
            .isCurrentUserOnboarded();
        route = done ? '/dashboard' : '/onboarding';
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      setState(() => _error = result.error ?? 'Unknown error');
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email first, then tap Reset.');
      return;
    }
    if (!_backendReady) {
      setState(() => _error = 'Password reset requires backend configuration.');
      return;
    }
    setState(() => _loading = true);
    final result =
        await FirebaseAuthService.instance.sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success
            ? 'Reset link sent to $email'
            : (result.error ?? 'Failed to send reset link')),
      ),
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, cs.secondary],
          ),
        ),
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
                          if (!_backendReady) _backendBanner(cs),
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
                          if (!isSignUp) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _resetPassword,
                                child: const Text('Forgot password?'),
                              ),
                            ),
                          ],
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
    return SegmentedButton<_Mode>(
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
                'Demo mode — Firebase not configured. Sign-in skips '
                'to dashboard. Run `flutterfire configure` to enable accounts.',
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
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.secondary],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.psychology_alt,
            color: Colors.white, size: 36),
      ),
    );
  }
}
