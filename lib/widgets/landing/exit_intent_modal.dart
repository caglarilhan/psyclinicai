import 'package:flutter/material.dart';

/// Shown once when the pointer approaches the top of the viewport
/// (proxy for "tab close" intent on web). Single field, one purpose:
/// capture the email so we can ping when the demo video drops.
class ExitIntentModal extends StatefulWidget {
  const ExitIntentModal({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  static Future<void> show(
      BuildContext context, ValueChanged<String> onSubmit) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => ExitIntentModal(onSubmit: onSubmit),
    );
  }

  @override
  State<ExitIntentModal> createState() => _ExitIntentModalState();
}

class _ExitIntentModalState extends State<ExitIntentModal> {
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
    Navigator.of(context).pop();
    widget.onSubmit(v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 56,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(28, 22, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: cs.primary),
                  const SizedBox(width: 8),
                  Text('Wait — one quick thing',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'We drop the 90-second demo video in two weeks. Want us '
                'to email it the moment it goes live? No spam, one note.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'you@clinic.com',
                  errorText: _err,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Notify me'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
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
