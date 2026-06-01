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
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    // Compact bottom strip (was: a large boxed card that covered ~30% of
    // the mobile viewport and hid the hero CTA). Single row, full-bleed,
    // ~56–72px tall. Same consent semantics, less obstruction.
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Material(
          elevation: 6,
          color: cs.surface,
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isPhone ? 16 : 24,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(Icons.cookie_outlined, size: 18, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Session cookie only — no third-party analytics.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/privacy'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: cs.primary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  child: const Text('Details'),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: _answer,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
