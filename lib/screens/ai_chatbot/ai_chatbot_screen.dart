import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/copilot/chat_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_button.dart';

/// `/ai_chatbot` — real Anthropic Claude conversation. BYOK: nothing
/// goes through PsyClinicAI servers. Replaces the prior 12-pattern
/// hardcoded dummy.
class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final _chat = ChatService();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatTurn> _history = [];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _chat.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _history.add(ChatTurn(role: ChatRole.user, text: text));
      _input.clear();
      _sending = true;
      _error = null;
    });
    _scrollToBottom();
    try {
      final reply = await _chat.send(_history);
      if (!mounted) return;
      setState(() {
        _history.add(ChatTurn(role: ChatRole.assistant, text: reply));
        _sending = false;
      });
      _scrollToBottom();
    } on ChatException catch (e, st) {
      // Skip the noApiKey case (expected UX); capture everything
      // else so prod chat failures (network / parse / rate-limit)
      // are observable.
      if (e.code != ChatErrorCode.noApiKey) {
        unawaited(
          TelemetryService.instance.captureError(
            e,
            st,
            hint: 'ai_chatbot.send',
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _sending = false;
      });
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'ai_chatbot.unexpected',
        ),
      );
      if (!mounted) return;
      setState(() {
        _error = 'Unexpected error: $e';
        _sending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      unawaited(
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  void _newConversation() {
    setState(() {
      _history.clear();
      _error = null;
    });
  }

  void _useSuggestion(String text) {
    _input.text = text;
    unawaited(_send());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/ai_chatbot',
      title: 'AI Copilot',
      subtitle: 'Clinical reasoning assistant · Claude Haiku (BYOK)',
      primaryAction: TextButton.icon(
        onPressed: _history.isEmpty ? null : _newConversation,
        icon: const Icon(Icons.add_comment_outlined, size: 18),
        label: const Text('New chat'),
      ),
      scrollable: false,
      child: Column(
        children: [
          Expanded(
            child: _history.isEmpty
                ? _EmptyState(cs: cs, theme: theme, onSuggest: _useSuggestion)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      vertical: PsySpacing.xl,
                    ),
                    itemCount: _history.length + (_sending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_sending && i == _history.length) {
                        return _TypingBubble(cs: cs);
                      }
                      return _Bubble(turn: _history[i], cs: cs, theme: theme);
                    },
                  ),
          ),
          if (_error != null)
            Container(
              color: cs.error.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.xxl,
                vertical: PsySpacing.md,
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 18),
                  const SizedBox(width: PsySpacing.sm),
                  Expanded(
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _Composer(input: _input, cs: cs, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.cs,
    required this.theme,
    required this.onSuggest,
  });
  final ColorScheme cs;
  final ThemeData theme;
  final ValueChanged<String> onSuggest;

  static const _suggestions = <String>[
    'Summarise PHQ-9 severity bands and the clinical action for each.',
    'Compare DSM-5 criteria for MDD and persistent depressive disorder.',
    'List 5 CBT homework assignments for moderate anxiety.',
    'When should I escalate a patient with PHQ-9 item 9 endorsed?',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(PsySpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.psychology_outlined, color: cs.primary, size: 36),
              const SizedBox(height: PsySpacing.lg),
              Text(
                'Ask me anything clinical.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: PsySpacing.sm),
              Text(
                'I run on your own Anthropic key. Nothing is sent to '
                'PsyClinicAI servers. Replies cite DSM-5 / APA / NICE '
                'where relevant.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: PsySpacing.xxl),
              Text(
                'Try one of these:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              ..._suggestions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: PsySpacing.sm),
                  child: InkWell(
                    onTap: () => onSuggest(s),
                    borderRadius: BorderRadius.circular(PsyRadius.md),
                    child: Container(
                      padding: const EdgeInsets.all(PsySpacing.lg),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(PsyRadius.md),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bolt_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: PsySpacing.sm),
                          Expanded(
                            child: Text(s, style: theme.textTheme.bodyMedium),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.turn, required this.cs, required this.theme});
  final ChatTurn turn;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isUser = turn.role == ChatRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary,
              child: Icon(
                Icons.smart_toy_outlined,
                color: cs.onPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: PsySpacing.md),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 640),
              padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.xl,
                vertical: PsySpacing.lg,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? cs.primary.withValues(alpha: 0.10)
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(PsyRadius.lg),
                  topRight: const Radius.circular(PsyRadius.lg),
                  bottomLeft: Radius.circular(
                    isUser ? PsyRadius.lg : PsyRadius.xs,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? PsyRadius.xs : PsyRadius.lg,
                  ),
                ),
                border: Border.all(
                  color: isUser
                      ? cs.primary.withValues(alpha: 0.25)
                      : cs.outlineVariant,
                ),
              ),
              child: SelectableText(
                turn.text,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: PsySpacing.md),
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.surfaceContainerHigh,
              child: Icon(Icons.person_outline, color: cs.onSurface, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.primary,
            child: Icon(
              Icons.smart_toy_outlined,
              color: cs.onPrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: PsySpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.xl,
              vertical: PsySpacing.lg,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(PsyRadius.lg),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
                const SizedBox(width: PsySpacing.md),
                Text(
                  'Thinking…',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
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

class _Composer extends StatelessWidget {
  const _Composer({
    required this.input,
    required this.cs,
    required this.sending,
    required this.onSend,
  });
  final TextEditingController input;
  final ColorScheme cs;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.xxl,
        vertical: PsySpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: input,
              minLines: 1,
              maxLines: 6,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Ask anything clinical — Enter to send',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: PsySpacing.md),
          PsyButton(
            label: 'Send',
            icon: Icons.send,
            loading: sending,
            onPressed: sending ? null : onSend,
          ),
        ],
      ),
    );
  }
}
