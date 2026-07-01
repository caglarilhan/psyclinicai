import 'package:flutter/material.dart';

import '../../services/byok/byok_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/byok-llm` — BYOK ("Bring Your Own Key") settings for the
/// PILAR 1 / 4 LLM stack (Firestore-backed).
///
/// **Coexists with** `lib/screens/settings/api_keys_screen.dart`,
/// which uses `flutter_secure_storage` for on-device BYOK (mobile
/// only; web build blocked). This screen is the **Firestore-backed**
/// alternative — works on web, makes the keys available to the CF
/// handler resolver so PILAR 1 + 4 actually use them.
class ByokKeysScreen extends StatefulWidget {
  const ByokKeysScreen({
    super.key,
    required this.uid,
    required this.repository,
  });

  final String uid;
  final ByokRepository repository;

  @override
  State<ByokKeysScreen> createState() => _ByokKeysScreenState();
}

class _ByokKeysScreenState extends State<ByokKeysScreen> {
  final TextEditingController _anthropic = TextEditingController();
  final TextEditingController _groq = TextEditingController();
  final TextEditingController _gemini = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  ByokKeys _current = const ByokKeys();

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  @override
  void dispose() {
    _anthropic.dispose();
    _groq.dispose();
    _gemini.dispose();
    super.dispose();
  }

  Future<void> _loadKeys() async {
    try {
      final k = await widget.repository.load(widget.uid);
      if (!mounted) return;
      setState(() {
        _current = k;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final next = ByokKeys(
        anthropicKey: _anthropic.text.trim().isEmpty
            ? _current.anthropicKey
            : _anthropic.text.trim(),
        groqKey: _groq.text.trim().isEmpty
            ? _current.groqKey
            : _groq.text.trim(),
        geminiKey: _gemini.text.trim().isEmpty
            ? _current.geminiKey
            : _gemini.text.trim(),
      );
      await widget.repository.save(widget.uid, next);
      if (!mounted) return;
      setState(() {
        _current = next;
        _anthropic.clear();
        _groq.clear();
        _gemini.clear();
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keys saved')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  Future<void> _onClear() async {
    setState(() => _saving = true);
    try {
      await widget.repository.clear(widget.uid);
      if (!mounted) return;
      setState(() {
        _current = const ByokKeys();
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keys cleared')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/settings/byok-llm',
      title: 'BYOK LLM keys',
      subtitle:
          'Paste your own Anthropic / Groq / Gemini key to override the '
          'platform default. Without keys the assistant runs on the '
          'free-tier demo chain.',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('BYOK LLM keys', null),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BaaBanner(theme: theme, cs: cs),
                const SizedBox(height: PsySpacing.md),
                _CurrentStatusCard(theme: theme, current: _current),
                const SizedBox(height: PsySpacing.md),
                _KeyEditorCard(
                  theme: theme,
                  cs: cs,
                  anthropic: _anthropic,
                  groq: _groq,
                  gemini: _gemini,
                  saving: _saving,
                  onSave: _onSave,
                  onClear: _onClear,
                  error: _error,
                ),
              ],
            ),
    );
  }
}

class _BaaBanner extends StatelessWidget {
  const _BaaBanner({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: cs.onPrimaryContainer),
          const SizedBox(width: PsySpacing.sm),
          Expanded(
            child: Text(
              'When you paste an Anthropic key here, you sign the HIPAA '
              'BAA directly with Anthropic. We are not a covered entity '
              'on the demo tier.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({required this.theme, required this.current});
  final ThemeData theme;
  final ByokKeys current;

  Widget _row(String label, String? key) {
    final tail = ByokKeys.lastFourOf(key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          if (key == null)
            const PsyBadge(label: 'not set', tone: PsyBadgeTone.neutral)
          else
            PsyBadge(label: 'set · $tail', tone: PsyBadgeTone.success),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Current keys', style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.sm),
          _row('Anthropic', current.anthropicKey),
          _row('Groq', current.groqKey),
          _row('Gemini', current.geminiKey),
        ],
      ),
    );
  }
}

class _KeyEditorCard extends StatelessWidget {
  const _KeyEditorCard({
    required this.theme,
    required this.cs,
    required this.anthropic,
    required this.groq,
    required this.gemini,
    required this.saving,
    required this.onSave,
    required this.onClear,
    required this.error,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final TextEditingController anthropic;
  final TextEditingController groq;
  final TextEditingController gemini;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onClear;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Paste a new key', style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Leave a field blank to keep the current value. Use Clear all '
            'to wipe every stored key.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: PsySpacing.md),
          TextField(
            controller: anthropic,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Anthropic API key',
              hintText: 'sk-ant-...',
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          TextField(
            controller: groq,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Groq API key',
              hintText: 'gsk_...',
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          TextField(
            controller: gemini,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Gemini API key',
              hintText: 'AIza...',
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              TextButton(
                onPressed: saving ? null : onClear,
                child: const Text('Clear all'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(saving ? 'Saving…' : 'Save keys'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
