/// KVKK md. 6/2 + 6/3 açık rıza (explicit consent) form widget.
///
/// **Why a separate form**: KVKK draws a hard line between general
/// processing consent (md. 5) and special-category health-data
/// consent (md. 6). The latter must be captured separately with
/// explicit + unambiguous opt-in language; bundling it into a
/// blanket "accept all" checkbox is non-compliant.
///
/// **What this widget is NOT**: it is not the aydınlatma metni —
/// that lives at `/legal/kvkk` (PR #79) as a unilateral notice.
/// This form is the **rıza** the patient (or clinician on their
/// behalf, with documented authority) signs after reading the
/// notice.
///
/// The widget yields a [ConsentEntry] via [onSign]; the host is
/// responsible for persisting it through
/// [`ConsentEntryRepository`].
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../models/consent_entry.dart';
import '../../theme/tokens.dart';

class KvkkAcikRizaForm extends StatefulWidget {
  const KvkkAcikRizaForm({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.policyVersion,
    required this.onSign,
    this.signatureHint =
        'Hasta adı ve soyadı (kendi el yazısı yerine '
        'klinisyen tarafından tanık edildiğinde tip et)',
    this.onPolicyTap,
  });

  /// Patient the consent record is for.
  final String patientId;

  /// Display name surfaced in the consent text.
  final String patientName;

  /// Aydınlatma metni version this consent applies to — e.g.
  /// `kvkk-aydinlatma-v2026.06`. The repository pins this so an
  /// audit can answer "which notice text did the patient see?".
  final String policyVersion;

  /// Called with the signed [ConsentEntry] when the patient (or
  /// witnessing clinician) submits.
  final void Function(ConsentEntry entry) onSign;

  /// Placeholder for the signature field — defaults to Turkish.
  final String signatureHint;

  /// Override for the inline `/legal/kvkk` deep-link tap. Production
  /// uses [Navigator.pushNamed]; tests inject a closure that records
  /// the navigation without booting the route table.
  final VoidCallback? onPolicyTap;

  @override
  State<KvkkAcikRizaForm> createState() => _KvkkAcikRizaFormState();
}

class _KvkkAcikRizaFormState extends State<KvkkAcikRizaForm> {
  bool _consentChecked = false;
  bool _ackChecked = false;
  final TextEditingController _signature = TextEditingController();

  /// Two stable recognizers — one for the lede span and one for the
  /// ack-checkbox span. Both fire [_openPolicy]. Built once in
  /// initState so build() doesn't accumulate orphaned recognizers.
  late final TapGestureRecognizer _ledePolicyTap = TapGestureRecognizer()
    ..onTap = _openPolicy;
  late final TapGestureRecognizer _ackPolicyTap = TapGestureRecognizer()
    ..onTap = _openPolicy;

  @override
  void dispose() {
    _signature.dispose();
    _ledePolicyTap.dispose();
    _ackPolicyTap.dispose();
    super.dispose();
  }

  /// Navigates to the aydınlatma metni page. Test seam:
  /// [widget.onPolicyTap] bypasses the Navigator.
  void _openPolicy() {
    if (widget.onPolicyTap != null) {
      widget.onPolicyTap!();
      return;
    }
    unawaited(Navigator.of(context).pushNamed('/legal/kvkk'));
  }

  bool get _canSign =>
      _consentChecked && _ackChecked && _signature.text.trim().isNotEmpty;

  void _submit() {
    final entry = ConsentEntry(
      id: 'kvkk-${widget.patientId}-${DateTime.now().toUtc().millisecondsSinceEpoch}',
      patientId: widget.patientId,
      kind: ConsentKind.kvkkSpecialCategoryHealth,
      policyVersion: widget.policyVersion,
      signature: _signature.text.trim(),
    );
    widget.onSign(entry);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KVKK md. 6 — Açık Rıza Beyanı',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: PsySpacing.sm),
        Text.rich(
          TextSpan(
            style: t.bodyMedium,
            children: [
              TextSpan(
                text:
                    'PsyClinicAI olarak, ${widget.patientName} adlı veri '
                    'öznesinin KVKK md. 6 kapsamındaki özel nitelikli '
                    'sağlık verisinin aşağıdaki amaçlarla işlenmesine '
                    'açık rıza göstermesini talep ederiz. Bu rıza, ',
              ),
              TextSpan(
                text: '/legal/kvkk',
                style: TextStyle(
                  color: cs.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: _ledePolicyTap,
              ),
              const TextSpan(
                text:
                    ' adresindeki aydınlatma metnini okuduğunuzu ve '
                    'anladığınızı varsayar.',
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        _bullet(
          context,
          'Klinik karar destek hizmeti için seans notu, ölçek skoru ve '
          'tedavi planı kayıtlarının saklanması.',
        ),
        _bullet(
          context,
          'Klinisyen iş akışını desteklemek üzere belirli AI özetlerinin '
          'üretilmesi; bu özetler ham ses kaydı içermez ve istek üzerine '
          'kapatılabilir.',
        ),
        _bullet(
          context,
          'Yasal yükümlülüklerin yerine getirilmesi (vergi, sağlık '
          'mevzuatı, denetim izleri).',
        ),
        const SizedBox(height: PsySpacing.md),
        Text(
          'Açık rıza istediğiniz an, /settings/data adresinden veya '
          'legal@psyclinicai.com aracılığıyla geri alınabilir; KVKK md. 7 '
          'kapsamında veri silme prosedürü tetiklenir.',
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: PsySpacing.lg),
        CheckboxListTile(
          value: _consentChecked,
          onChanged: (v) => setState(() => _consentChecked = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Açık rıza veriyorum (KVKK md. 6/2 ve md. 6/3).'),
        ),
        CheckboxListTile(
          value: _ackChecked,
          onChanged: (v) => setState(() => _ackChecked = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '/legal/kvkk',
                  style: TextStyle(
                    color: cs.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: _ackPolicyTap,
                ),
                const TextSpan(
                  text: ' adresindeki aydınlatma metnini okudum, anladım.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        TextField(
          controller: _signature,
          decoration: InputDecoration(
            labelText: 'İmza',
            hintText: widget.signatureHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: PsySpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            key: const Key('kvkkAcikRiza.submit'),
            onPressed: _canSign ? _submit : null,
            icon: const Icon(Icons.check),
            label: const Text('İmzala ve kaydet'),
          ),
        ),
      ],
    );
  }

  Widget _bullet(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
