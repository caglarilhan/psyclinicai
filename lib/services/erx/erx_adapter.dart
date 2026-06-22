import '../../models/prescription.dart';

/// Outbound result of an adapter call.
class ErxTransmissionResult {
  const ErxTransmissionResult({
    required this.externalReference,
    required this.acknowledgedAt,
  });

  /// The national service's id (e.g. eHDSI message id, MEDULA reçete no).
  final String externalReference;
  final DateTime acknowledgedAt;
}

/// Common interface every market-specific e-Rx adapter implements.
///
/// Sprint 12 ships stub implementations that compose the payload and
/// return a synthetic acknowledgement; Sprint 13+ wires the real
/// SOAP / HL7-FHIR endpoints.
abstract class ErxAdapter {
  /// Identifier the routing layer matches `prescription.market` against.
  PrescriptionMarket get market;

  /// Validates the prescription is well-formed for this market BEFORE
  /// any network call. Returns null when ok, otherwise an error string.
  String? validateForMarket(Prescription rx);

  /// Build the canonical wire payload (string-encoded XML for SOAP
  /// adapters, JSON for FHIR-based ones). Exposed so unit tests can
  /// inspect the bytes without sending.
  String buildPayload(Prescription rx);

  /// Transmit the prescription. Must throw [StateError] if the row is
  /// not in [PrescriptionStatus.signed] or [validateForMarket] rejects it.
  Future<ErxTransmissionResult> transmit(Prescription rx);
}
