import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GDPR-required cookie / data-collection notice. Shown once per device
/// at the bottom of the landing until the visitor makes a choice.
/// PsyClinicAI uses no third-party analytics by default; the banner
/// exists for transparency and EU regulatory compliance.
class CookieConsent extends StatefulWidget {
  const CookieConsent({super.key});

  static const _key = 'psy_cookie_consent_v1';

  @override
  State<CookieConsent> createState() => _CookieConsentState();
}

class _CookieConsentState extends State<CookieConsent> {
  bool _visible = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final answered = prefs.getBool(CookieConsent._key) ?? false;
    if (mounted && !answered) {
      setState(() {
        _checked = true;
        _visible = true;
      });
    } else {
      setState(() => _checked = true);
    }
  }

  Future<void> _answer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(CookieConsent._key, true);
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || !_visible) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: cs.surface,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cookie_outlined, color: cs.primary),
                        const SizedBox(width: 8),
                        Text('A note on cookies',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "PsyClinicAI doesn't use third-party analytics on "
                      'this landing — only a single browser session '
                      'cookie so the app can remember your sign-in. '
                      'Read the full notice at /privacy.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/privacy'),
                          child: const Text('Read full notice'),
                        ),
                        FilledButton(
                          onPressed: _answer,
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                          ),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
