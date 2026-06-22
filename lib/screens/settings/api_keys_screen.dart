import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/copilot/api_key_storage.dart';
import '../../widgets/app_shell.dart';

/// Settings page where clinicians provide their own AI provider API keys
/// (BYOK — Bring Your Own Key).
class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final _storage = ApiKeyStorage.instance;
  final _anthropicCtl = TextEditingController();
  final _openAiCtl = TextEditingController();

  bool _loading = true;
  bool _anthropicVisible = false;
  bool _openAiVisible = false;
  bool _hasAnthropic = false;
  bool _hasOpenAi = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_hydrate());
  }

  Future<void> _hydrate() async {
    final a = await _storage.getAnthropicKey();
    final o = await _storage.getOpenAIKey();
    if (!mounted) return;
    setState(() {
      _hasAnthropic = (a ?? '').isNotEmpty;
      _hasOpenAi = (o ?? '').isNotEmpty;
      _anthropicCtl.text = a ?? '';
      _openAiCtl.text = o ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final anthropic = _anthropicCtl.text.trim();
    final openai = _openAiCtl.text.trim();
    try {
      if (anthropic.isEmpty) {
        await _storage.clearAnthropic();
      } else {
        await _storage.setAnthropicKey(anthropic);
      }
      if (openai.isEmpty) {
        await _storage.clearOpenAI();
      } else {
        await _storage.setOpenAIKey(openai);
      }
      if (!mounted) return;
      setState(() {
        _hasAnthropic = anthropic.isNotEmpty;
        _hasOpenAi = openai.isNotEmpty;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API keys saved securely on device'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  void dispose() {
    _anthropicCtl.dispose();
    _openAiCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/settings',
      title: 'API keys',
      subtitle: 'Bring-your-own keys — stored encrypted on this device only.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('API keys', null),
      ],
      scrollable: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _SecurityBanner(cs: cs),
                const SizedBox(height: 24),
                _ProviderCard(
                  title: 'Anthropic Claude',
                  subtitle:
                      'Used for AI session notes (SOAP / DAP / BIRP), risk flagging, and treatment plan suggestions.',
                  pricing:
                      'Pay-as-you-go, ~\$0.001 per 5-minute session on '
                      'Claude Haiku 4.5. Model picker (Sonnet 4.6 / Opus '
                      '4.7) lands with the server-side LLM proxy in '
                      'Sprint 19.',
                  helpUrl: 'console.anthropic.com → API Keys → Create Key',
                  controller: _anthropicCtl,
                  visible: _anthropicVisible,
                  onToggleVisibility: () =>
                      setState(() => _anthropicVisible = !_anthropicVisible),
                  configured: _hasAnthropic,
                  cs: cs,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _ProviderCard(
                  title: 'OpenAI (optional)',
                  subtitle:
                      'Reserved for future GPT-based features. Not required today.',
                  pricing: 'Optional.',
                  helpUrl: 'platform.openai.com → API Keys',
                  controller: _openAiCtl,
                  visible: _openAiVisible,
                  onToggleVisibility: () =>
                      setState(() => _openAiVisible = !_openAiVisible),
                  configured: _hasOpenAi,
                  cs: cs,
                  theme: theme,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_outline, size: 18),
                    label: Text(_saving ? 'Saving…' : 'Save'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: cs.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your keys never leave this device',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PsyClinicAI uses BYOK (Bring Your Own Key). Keys are stored '
                  'encrypted in your operating system keychain. The Anthropic '
                  'API is called directly from your browser — no key passes '
                  'through PsyClinicAI servers.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trade-off: direct-browser calls mean we cannot rate-limit '
                  'misuse or log AI usage for your audit trail. A server-side '
                  'LLM proxy with KMS-wrapped keys, PHI redaction, per-tenant '
                  'cost meter and full audit logging is on the Sprint 19 '
                  'roadmap — track it on /changelog.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
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

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.title,
    required this.subtitle,
    required this.pricing,
    required this.helpUrl,
    required this.controller,
    required this.visible,
    required this.onToggleVisibility,
    required this.configured,
    required this.cs,
    required this.theme,
  });

  final String title;
  final String subtitle;
  final String pricing;
  final String helpUrl;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final bool configured;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (configured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Arch M3 fix (audit 2026-06-21): Colors.green is
                    // light-mode tuned and disappears against the
                    // dark-mode surface. Use a brightness-aware
                    // success swatch with adequate WCAG-AA contrast
                    // for both themes.
                    color:
                        (theme.brightness == Brightness.dark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF15803D))
                            .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF15803D),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Configured',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pricing,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            obscureText: !visible,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'sk-ant-…',
              hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.35)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: visible ? 'Hide' : 'Show',
                    icon: Icon(
                      visible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                  IconButton(
                    tooltip: 'Paste',
                    icon: const Icon(Icons.content_paste),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        controller.text = data!.text!.trim();
                      }
                    },
                  ),
                ],
              ),
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Get a key at $helpUrl',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
