import 'package:json_annotation/json_annotation.dart';

// ===== ORTAK ENUM'LAR =====

enum AlertType {
  @JsonValue('mood_drop')
  moodDrop,
  @JsonValue('mood_elevation')
  moodElevation,
  @JsonValue('symptom_increase')
  symptomIncrease,
  @JsonValue('medication_missed')
  medicationMissed,
  @JsonValue('crisis_risk')
  crisisRisk,
  @JsonValue('financial_alert')
  financialAlert,
  @JsonValue('system_alert')
  systemAlert,
  @JsonValue('security_alert')
  securityAlert,
  @JsonValue('compliance_alert')
  complianceAlert,
  @JsonValue('integration_alert')
  integrationAlert,
}

enum AlertSeverity {
  @JsonValue('info')
  info,
  @JsonValue('warning')
  warning,
  @JsonValue('error')
  error,
  @JsonValue('critical')
  critical,
}

enum IntegrationStatus {
  @JsonValue('active')
  active,
  @JsonValue('partial')
  partial,
  @JsonValue('inactive')
  inactive,
  @JsonValue('error')
  error,
  @JsonValue('maintenance')
  maintenance,
}

enum IntegrationType {
  @JsonValue('fhir')
  fhir,
  @JsonValue('hl7')
  hl7,
  @JsonValue('api')
  api,
  @JsonValue('direct')
  direct,
  @JsonValue('hybrid')
  hybrid,
}
