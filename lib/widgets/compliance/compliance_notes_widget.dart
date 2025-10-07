import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ComplianceNotesWidget extends StatelessWidget {
  const ComplianceNotesWidget({super.key});

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
            Icon(Icons.gavel, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('ABD/EU Uyum Notları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          _bullet(context, 'HIPAA: audit log, erişim kontrolü ve minimum gerekli ilkesine uygunluk.'),
          _bullet(context, 'GDPR/KVKK: onam kayıtları, silme/anonimleştirme (right to be forgotten).'),
          _bullet(context, 'Veri saklama: politika ile süre sınırları; düzenli imha/anonimleştirme.'),
          _bullet(context, 'E-reçete: ilaç etkileşim kontrolü, klinik karar destek uyarıları.'),
          _bullet(context, 'Teleterapi: bekleme odası ve şifre koruması, erişim logları.'),
        ],
      ),
    );
  }

  Widget _bullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}


