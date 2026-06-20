/// Sprint 32+33 — Multi-jurisdiction legal engine, EU Phase 2.
///
/// Sister service to [StateLawService] (US Phase 1). Where US uses
/// per-state law, the EU model maps per-country regulation against a
/// shared GDPR ceiling — so each country row carries Berufsgeheimnis /
/// professional-secrecy variants plus the national criminal-code
/// references that differ across member states.
///
/// First slice covers Germany, the United Kingdom (post-Brexit but
/// still EEA-aligned for our DPA purposes), and Austria — three EU /
/// EEA target markets for the Wave B pilot. EU expansion (FR, NL, ES,
/// IT, IE) lands in Sprint 34 once we have native-clinician review.
///
/// Skill-panel coverage: gdpr-dsgvo-expert (Art. 9 + national health
/// codes), healthcare-cdss-patterns (alert UX), intl-expansion
/// (country selector wiring), senior-fullstack (data shape).
library;

import 'state_law_service.dart' show JurisdictionAlert, AlertCategory, AlertSeverity;

export 'state_law_service.dart' show JurisdictionAlert, AlertCategory, AlertSeverity;

/// Public surface. Stateless; safe to instantiate at the call site.
class EuCountryLawService {
  const EuCountryLawService();

  static const Set<String> supportedCountries = {'DE', 'UK', 'AT'};

  /// Empty list for unsupported codes — caller renders the
  /// "no alerts available" empty state.
  List<JurisdictionAlert> alertsForCountry(String countryCode) {
    final upper = countryCode.toUpperCase();
    switch (upper) {
      case 'DE':
        return const [
          JurisdictionAlert(
            id: 'DE.consentToTreat.dsgvo',
            title: 'Germany — DSGVO Art. 9(2)(h) processing basis',
            body:
                'Mental-health data is special-category. The lawful basis for '
                'routine therapy is Art. 9(2)(h) DSGVO plus § 22 BDSG. Treat '
                'consent (Art. 9(2)(a)) as a fallback only when the necessity '
                'condition under (h) is not met.',
            category: AlertCategory.consentToTreat,
            severity: AlertSeverity.warning,
            citation: 'Art. 9(2)(h) DSGVO; § 22 BDSG',
          ),
          JurisdictionAlert(
            id: 'DE.dutyToWarn.bgh',
            title: 'Germany — Berufsgeheimnis vs duty to warn',
            body:
                'Professional secrecy under § 203 StGB is strict. The BGH has '
                'recognised a rechtfertigender Notstand (§ 34 StGB) defence '
                'that permits — and at times requires — disclosure to police '
                'or a third party when serious harm is imminent. Document '
                'the Notstand reasoning before disclosing.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.critical,
            citation: '§§ 203, 34 StGB; BGH 8.10.1993 - 1 StR 320/93',
          ),
          JurisdictionAlert(
            id: 'DE.mandatoryReporting.child',
            title: 'Germany — BKiSchG mandatory escalation',
            body:
                'Under § 4 BKiSchG, when there is reasonable cause to suspect '
                'child endangerment, you must first attempt to resolve via '
                'family + a kinderschutzfachkraft, and only escalate to the '
                'Jugendamt when intervention is insufficient. There is no '
                '24/48-hour clock equivalent to US states — the duty is '
                'risk-graded.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.warning,
            citation: '§ 4 BKiSchG; § 8a SGB VIII',
          ),
          JurisdictionAlert(
            id: 'DE.telehealthLicensure.eheilg',
            title: 'Germany — Approbation + remote-treatment rules',
            body:
                'You need an active German Approbation (psychotherapeut or '
                'arzt) to bill via Telematikinfrastruktur. The Fernbehandlungs'
                '-verbot has been relaxed since 2018 (§ 7 Abs. 4 MBO-Ä); '
                'remote-only sessions are permitted when clinically '
                'justifiable.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation:
                '§ 7 Abs. 4 MBO-Ä; § 11 PsychThG; Telematikinfrastruktur',
          ),
          JurisdictionAlert(
            id: 'DE.documentationRetention.psychthg',
            title: 'Germany — record retention 10 years',
            body:
                'Therapy records: minimum 10 years after end of treatment '
                'per § 9 Abs. 4 PsychThG and § 630f BGB. Tax-relevant '
                'invoices: 10 years per § 147 AO. Longer if a regulatory '
                'or civil claim is pending.',
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: '§ 9 Abs. 4 PsychThG; § 630f BGB; § 147 AO',
          ),
        ];
      case 'UK':
        return const [
          JurisdictionAlert(
            id: 'UK.consentToTreat.gdpr',
            title: 'United Kingdom — UK GDPR Art. 9 + DPA 2018 Sch 3',
            body:
                'Special-category data processing under UK GDPR Art. 9 requires '
                'a Sch 3 DPA 2018 condition — typically condition 2 (health) '
                'with an appropriate-policy document. Do not rely on consent '
                'where you can rely on Sch 3.',
            category: AlertCategory.consentToTreat,
            severity: AlertSeverity.warning,
            citation: 'UK GDPR Art. 9; DPA 2018 Sch 3 condition 2',
          ),
          JurisdictionAlert(
            id: 'UK.dutyToWarn.tarasoff',
            title: 'United Kingdom — no Tarasoff, public-interest disclosure',
            body:
                'No common-law Tarasoff-equivalent duty. Disclosure of a '
                'serious risk of harm to an identifiable third party is '
                'permitted under the GMC Confidentiality guidance (paras 63-'
                '70) and may be required where the public interest in '
                'disclosure outweighs the duty of confidentiality.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.warning,
            citation:
                'GMC Confidentiality 2017 paras 63-70; W v Egdell [1990] Ch 359',
          ),
          JurisdictionAlert(
            id: 'UK.mandatoryReporting.fgm',
            title: 'United Kingdom — FGM mandatory reporting',
            body:
                'Section 5B Female Genital Mutilation Act 2003 requires any '
                'regulated health, social-care, or teaching professional to '
                'report a known case of FGM in a person under 18 to police '
                "as soon as practicable, ideally within 24 hours.",
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: 'FGM Act 2003 s.5B',
          ),
          JurisdictionAlert(
            id: 'UK.mandatoryReporting.children',
            title: 'United Kingdom — child safeguarding (Working Together)',
            body:
                "Working Together to Safeguard Children 2018 expects an "
                "immediate referral to local-authority Children's Social Care "
                'when a child is at risk of significant harm. There is no '
                'single statutory criminal-penalty mandate but failure to '
                'refer is a fitness-to-practise issue with the regulator.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.warning,
            citation: 'Working Together to Safeguard Children 2018, ch 1',
          ),
          JurisdictionAlert(
            id: 'UK.telehealthLicensure.gmc',
            title: 'United Kingdom — GMC remote-prescribing guidance',
            body:
                'For doctors: GMC Good Medical Practice + Remote Consultations '
                'guidance applies. Out-of-UK clinicians may treat UK patients '
                'remotely only with appropriate registration; HCPC + BPS '
                'have parallel rules for psychologists.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation:
                'GMC Remote Consultations 2020; HCPC + BPS practice guidelines',
          ),
          JurisdictionAlert(
            id: 'UK.documentationRetention.nhsx',
            title: 'United Kingdom — NHSX records management code',
            body:
                'Adult mental-health records: minimum 20 years from last '
                "contact (or 8 years after the patient's death). CYP "
                "records: until the patient's 26th birthday. NHS Records "
                'Management Code of Practice 2021.',
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: 'NHS Records Management Code of Practice 2021',
          ),
        ];
      case 'AT':
        return const [
          JurisdictionAlert(
            id: 'AT.consentToTreat.dsg',
            title: 'Austria — DSG + GDPR Art. 9 health data',
            body:
                'Health data is processed under Art. 9(2)(h) GDPR plus '
                '§§ 13-14 DSG (Datenschutzgesetz). Explicit consent (Art. '
                '9(2)(a)) is the fallback for non-clinical processing such '
                'as research outside the immediate treatment relationship.',
            category: AlertCategory.consentToTreat,
            severity: AlertSeverity.warning,
            citation: 'Art. 9(2)(h) GDPR; §§ 13-14 DSG',
          ),
          JurisdictionAlert(
            id: 'AT.dutyToWarn.stgb121',
            title: 'Austria — § 121 StGB professional confidentiality',
            body:
                'Disclosure outside the treatment relationship is a criminal '
                'offence under § 121 StGB unless a statutory exception applies. '
                'For imminent serious harm, the rechtfertigender Notstand '
                '(§ 10 StGB) is the operative defence — document the '
                'proportionality reasoning before disclosing.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.critical,
            citation: '§§ 121, 10 StGB',
          ),
          JurisdictionAlert(
            id: 'AT.mandatoryReporting.child',
            title: 'Austria — § 37 B-KJHG child welfare notification',
            body:
                'Health professionals must report a concrete suspicion of '
                'child endangerment to the local Kinder- und Jugendhilfe '
                'träger. Withholding such a notification is a discipline '
                'matter under § 49 ÄrzteG and parallel professional codes.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: '§ 37 B-KJHG 2013; § 49 ÄrzteG',
          ),
          JurisdictionAlert(
            id: 'AT.telehealthLicensure.eheilg',
            title: 'Austria — ELGA + telemedicine framework',
            body:
                'You must hold an Austrian Berufsberechtigung to bill via '
                'ELGA. The Telemedicine Framework (2020 ÖÄK / BMSGPK '
                'guidance) permits remote treatment when the patient is '
                'physically in Austria and a documented in-person follow-up '
                'is possible if clinically required.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation: 'ELGA-Gesetz; ÖÄK Telemedizin-Richtlinie 2020',
          ),
          JurisdictionAlert(
            id: 'AT.documentationRetention.aerzteg',
            title: 'Austria — record retention 10 years',
            body:
                'Patient records: minimum 10 years after the end of '
                'treatment under § 51 ÄrzteG. Records relating to a minor: '
                "minimum 10 years past the patient's 18th birthday.",
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: '§ 51 ÄrzteG',
          ),
        ];
      default:
        return const [];
    }
  }

  /// Bundle alerts across a multi-country license set.
  List<JurisdictionAlert> alertsForMultipleCountries(
      Iterable<String> countryCodes) {
    final out = <JurisdictionAlert>[];
    for (final code in countryCodes) {
      out.addAll(alertsForCountry(code));
    }
    return out;
  }

  /// True when any alert in the bundle is `critical`. UI lights the red
  /// banner accordingly.
  bool hasCriticalAlert(List<JurisdictionAlert> alerts) {
    return alerts.any((a) => a.severity == AlertSeverity.critical);
  }
}
