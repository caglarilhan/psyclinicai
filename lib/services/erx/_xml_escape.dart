/// Minimal XML-attribute / text escape for the e-Rx adapters.
///
/// We do not want to pull in `package:xml` for the synthetic Sprint 12
/// stubs — but string interpolation directly into a SOAP envelope is
/// an injection sink the moment a clinician name contains a quote
/// or an apostrophe. This helper covers the five XML predefined
/// entities and nothing else; replace it with a real DOM builder
/// the day we wire the real eHDSI / MEDULA endpoints.
library;

String xmlEscape(Object? value) {
  if (value == null) return '';
  final s = value.toString();
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
