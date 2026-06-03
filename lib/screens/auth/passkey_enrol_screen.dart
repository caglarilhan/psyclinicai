import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/passkey.dart';
import '../../services/auth/passkey_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/security/passkeys` — WebAuthn / FIDO2 passkey enrolment hub.
///
/// Lists every passkey bound to the current account (active + revoked
/// for the audit trail), lets the user add a new one, and supports
/// revoking lost-device credentials.
///
/// HIPAA §164.312(d) "person or entity authentication" and SOC 2
/// CC6.1 both benefit from FIDO2 hardware-bound credentials over
/// TOTP, which is phishable.
class PasskeyEnrolScreen extends StatefulWidget {
  const PasskeyEnrolScreen({super.key, required this.service});

  final PasskeyService service;

  @override
  State<PasskeyEnrolScreen> createState() => _PasskeyEnrolScreenState();
}

class _PasskeyEnrolScreenState extends State<PasskeyEnrolScreen> {
  final _labelController = TextEditingController();
  bool _enrolling = false;
  String? _flash;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onServiceChanged);
    unawaited(widget.service.refresh());
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceChanged);
    _labelController.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _enrol() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _flash = 'Give this device a label first.');
      return;
    }
    setState(() {
      _enrolling = true;
      _flash = null;
    });
    final outcome = await widget.service.enrol(deviceLabel: label);
    if (!mounted) return;
    setState(() {
      _enrolling = false;
      _flash = switch (outcome) {
        PasskeyOutcome.ok => 'Passkey added.',
        PasskeyOutcome.unsupportedPlatform =>
          'This browser/device does not support passkeys.',
        PasskeyOutcome.userCancelled => 'Cancelled.',
        PasskeyOutcome.challengeExpired => 'Took too long — try again.',
        PasskeyOutcome.networkError => 'Network error — try again.',
        PasskeyOutcome.serverRejected =>
          'Server rejected the credential — try a different authenticator.',
        PasskeyOutcome.busy => 'Already in progress — please wait.',
      };
      if (outcome == PasskeyOutcome.ok) _labelController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final passkeys = widget.service.credentials;
    return AppShell(
      routeName: '/security/passkeys',
      title: 'Passkeys',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PsyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in without a password',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: PsySpacing.sm),
                const Text(
                  'Passkeys bind your account to this device using a '
                  'hardware-backed key. They cannot be phished and they '
                  'replace your password for sign-in on this browser.',
                ),
                const SizedBox(height: PsySpacing.md),
                if (!widget.service.isPlatformSupported) ...[
                  const PsyBadge(
                    label: 'Browser not supported',
                    tone: PsyBadgeTone.warning,
                  ),
                  const SizedBox(height: PsySpacing.xs),
                  const Text(
                    'Open this page on a supported browser to enrol.',
                  ),
                ],
                const SizedBox(height: PsySpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _labelController,
                        decoration: const InputDecoration(
                          labelText: 'Device label',
                          hintText: 'MacBook Touch ID',
                        ),
                        maxLength: 80,
                      ),
                    ),
                    const SizedBox(width: PsySpacing.md),
                    FilledButton.icon(
                      key: const Key('passkey_add_button'),
                      onPressed: _enrolling ||
                              !widget.service.isPlatformSupported
                          ? null
                          : _enrol,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(_enrolling ? 'Adding…' : 'Add a passkey'),
                    ),
                  ],
                ),
                if (_flash != null) ...[
                  const SizedBox(height: PsySpacing.sm),
                  Text(_flash!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.lg),
          Text('Enrolled keys',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: PsySpacing.sm),
          if (passkeys.isEmpty)
            const PsyCard(
              child: Text(
                'No passkeys yet. Add your first one above.',
              ),
            )
          else
            ...passkeys.map((c) => _PasskeyRow(
                  cred: c,
                  onRemove: () => widget.service.revoke(c.credentialId),
                )),
        ],
      ),
    );
  }
}

class _PasskeyRow extends StatelessWidget {
  const _PasskeyRow({required this.cred, required this.onRemove});
  final PasskeyCredential cred;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final subtitleBits = <String>[
      'Added ${cred.createdAt.toIso8601String().substring(0, 10)}',
      if (cred.lastUsedAt != null)
        'last used ${cred.lastUsedAt!.toIso8601String().substring(0, 10)}',
      if (cred.transports.isNotEmpty) cred.transports.join(' · '),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.sm),
      child: PsyCard(
        child: Row(
          children: [
            const Icon(Icons.key),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cred.deviceLabel,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitleBits.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (!cred.isActive)
              const PsyBadge(
                  label: 'Revoked', tone: PsyBadgeTone.warning)
            else
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
          ],
        ),
      ),
    );
  }
}
