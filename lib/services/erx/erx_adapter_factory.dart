import '../../models/prescription.dart';
import 'ehdsi_adapter.dart';
import 'erx_adapter.dart';
import 'medula_adapter.dart';

/// Adapter resolver — `forMarket(rx.market)` is the only path the
/// UI / repository layer should ever take. Direct construction of
/// `EhdsiAdapter` / `MedulaAdapter` is reserved for the unit test
/// suite (where a market enum is fixed in the table).
///
/// Constructor injection is supported so tests can swap in a fake
/// adapter map without monkey-patching the static factory.
class ErxAdapterFactory {
  const ErxAdapterFactory({
    Map<PrescriptionMarket, ErxAdapter> overrides = const {},
  }) : _overrides = overrides;

  final Map<PrescriptionMarket, ErxAdapter> _overrides;

  /// Canonical adapter for the given market. Throws when no adapter
  /// is registered — refusing to transmit beats silently routing the
  /// wrong payload to MEDULA.
  ErxAdapter forMarket(PrescriptionMarket market) {
    final override = _overrides[market];
    if (override != null) return override;
    switch (market) {
      case PrescriptionMarket.eu:
        return const EhdsiAdapter();
      case PrescriptionMarket.tr:
        return const MedulaAdapter();
      case PrescriptionMarket.us:
        throw StateError(
          'US market adapter not yet registered (SureScripts integration '
          'is Sprint 16 backlog).',
        );
    }
  }
}
