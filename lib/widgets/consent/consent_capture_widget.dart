import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/consent_models.dart';
import '../../services/consent_service.dart';
import '../../utils/theme.dart';

class ConsentCaptureWidget extends StatefulWidget {
  final String clientName;
  final String clientIdentifier;
  final String therapistName;
  final ConsentVersionedText consentText;
  const ConsentCaptureWidget({super.key, required this.clientName, required this.clientIdentifier, required this.therapistName, required this.consentText});

  @override
  State<ConsentCaptureWidget> createState() => _ConsentCaptureWidgetState();
}

class _ConsentCaptureWidgetState extends State<ConsentCaptureWidget> {
  bool _accepted = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.verified_user, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Onam', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Text(widget.consentText.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(child: Text(widget.consentText.body)),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _accepted,
            onChanged: (v) => setState(() => _accepted = v ?? false),
            title: const Text('Metni okudum ve kabul ediyorum'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: !_accepted || _saving ? null : _save,
              icon: _saving ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.check),
              label: Text(_saving ? 'Kaydediliyor...' : 'Onayla'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final record = ConsentRecord(
        consentId: DateTime.now().millisecondsSinceEpoch.toString(),
        versionTextId: widget.consentText.id,
        clientName: widget.clientName,
        clientIdentifier: widget.clientIdentifier,
        therapistName: widget.therapistName,
        signedAt: DateTime.now(),
        // Not: Basit placeholder imza verisi (gelecekte canvas imzası eklenebilir)
        signatureData: base64Encode(utf8.encode('SIGNED:${widget.clientName}:${DateTime.now().toIso8601String()}')),
        ipAddress: '0.0.0.0',
        userAgent: 'psyclinicai/web',
      );
      await ConsentService().saveConsent(record);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Onam kaydedildi')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}


