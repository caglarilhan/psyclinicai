// ignore_for_file: deprecated_member_use
// Radio.groupValue / onChanged deprecated after Flutter 3.32; the RadioGroup
// migration is tracked separately. See Sprint 27 chore.
import 'package:flutter/material.dart';

import '../models/prescription.dart';
import '../services/erx/erx_adapter_factory.dart';
import '../theme/tokens.dart';

/// Card that lets a clinician pick the prescription market (EU /
/// TR / US) and surfaces the adapter that will own transmission
/// (plan §12). Stateless: the parent holds the selected market and
/// rebuilds when [onChanged] fires.
class ErxMarketPickerCard extends StatelessWidget {
  const ErxMarketPickerCard({
    super.key,
    required this.selected,
    required this.onChanged,
    this.factory = const ErxAdapterFactory(),
  });

  final PrescriptionMarket selected;
  final ValueChanged<PrescriptionMarket> onChanged;
  final ErxAdapterFactory factory;

  String _label(PrescriptionMarket m) {
    switch (m) {
      case PrescriptionMarket.eu:
        return 'EU · eHDSI / NCPeH';
      case PrescriptionMarket.tr:
        return 'TR · Sağlık Bakanlığı MEDULA';
      case PrescriptionMarket.us:
        return 'US · SureScripts (Sprint 16+)';
    }
  }

  String _adapterStatus(PrescriptionMarket m) {
    try {
      final adapter = factory.forMarket(m);
      return 'adapter: ${adapter.runtimeType}';
    }
    // `factory.forMarket` throws StateError when no adapter is wired
    // for the given market. The StateError IS the value we surface to
    // the picker UI — it carries the human-readable "no adapter yet
    // for $market" message. The lint flags catching Errors; here it
    // is intentional because StateError is the contract.
    // ignore: avoid_catching_errors
    on StateError catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prescription market', style: t.titleSmall),
            const SizedBox(height: PsySpacing.sm),
            for (final m in PrescriptionMarket.values)
              RadioListTile<PrescriptionMarket>(
                contentPadding: EdgeInsets.zero,
                value: m,
                groupValue: selected,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                title: Text(_label(m)),
                subtitle: Text(
                  _adapterStatus(m),
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
