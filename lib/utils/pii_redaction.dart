/// PII / PHI redaction helpers used everywhere a value leaves the
/// BAA-bound boundary (telemetry, SIEM exports, support emails).
///
/// Pure — no Flutter imports — so the same routine can run inside a
/// pre-commit hook that lint-scans new telemetry call sites.
library;

/// Masks the local-part of an email so an analytics platform never
/// sees the raw inbox. `'jane.doe@example.com'` → `'j***@example.com'`.
///
/// Returns `null` when [value] is null. Empty strings and non-email
/// shapes are returned untouched — the caller may be passing a
/// service-account name that should not be mangled.
String? redactEmail(String? value) {
  if (value == null) return null;
  final at = value.indexOf('@');
  if (at <= 1) return value;
  final localFirst = value[0];
  final domain = value.substring(at);
  return '$localFirst***$domain';
}

/// Masks the last two octets of an IPv4 address. Used to dampen the
/// fingerprintability of audit log exports without losing the network
/// neighbourhood (`'92.184.10.20'` → `'92.184.··.··'`).
///
/// Anything that does not look like dotted-quad IPv4 is returned
/// unchanged.
String? redactIpv4(String? ip) {
  if (ip == null) return null;
  if (ip.isEmpty) return ip;
  final parts = ip.split('.');
  if (parts.length != 4) return ip;
  return '${parts[0]}.${parts[1]}.··.··';
}

/// Trims a free-text string to [maxChars] with an ellipsis. Useful when
/// shipping audit `entity` fields to a SIEM that does not need the full
/// note title.
String truncateForExport(String value, {int maxChars = 24}) {
  if (value.length <= maxChars) return value;
  return '${value.substring(0, maxChars)}…';
}
