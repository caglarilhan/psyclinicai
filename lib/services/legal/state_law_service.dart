/// Sprint 32 P2 — Multi-jurisdiction legal engine, US Phase 1.
///
/// Returns the per-state alerts a clinician must be aware of when they
/// start a session in a given jurisdiction. The first US slice covers
/// California, New York, and Texas — three high-volume states with
/// non-trivial regulatory deltas:
///
///   - mandatory-reporting thresholds (child + elder + dependent-adult),
///   - duty-to-warn / duty-to-protect (Tarasoff variant),
///   - telehealth licensure (cross-state restrictions),
///   - documentation retention requirements.
///
/// Skill-panel coverage: gdpr-dsgvo-expert (legal framing), healthcare-
/// cdss-patterns (alert UX), senior-fullstack (data shape), clinical-
/// safety (Tarasoff harm-reduction).
library;

/// A single per-jurisdiction obligation surfaced to the clinician
/// before they start a session.
class JurisdictionAlert {
  const JurisdictionAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.severity,
    this.citation,
  });

  /// Stable id `${stateCode}.${category}.${slug}` — telemetry friendly.
  final String id;
  final String title;
  final String body;
  final AlertCategory category;
  final AlertSeverity severity;

  /// Plain-text citation (statute, case, guideline). Optional because
  /// some alerts are operational rather than statutory.
  final String? citation;
}

enum AlertCategory {
  mandatoryReporting,
  dutyToWarn,
  telehealthLicensure,
  documentationRetention,
  consentToTreat,
}

enum AlertSeverity { info, warning, critical }

/// Public surface — `StateLawService().alertsForState(code)` returns
/// an immutable list. Stateless; safe to instantiate anywhere.
class StateLawService {
  const StateLawService();

  static const Set<String> supportedStates = {
    'CA',
    'NY',
    'TX',
    // Sprint 33 P3 — US Phase 2.
    'FL',
    'IL',
    'WA',
  };

  /// Returns the empty list for unsupported codes so callers can render
  /// "no alerts available for this jurisdiction" without exceptions.
  List<JurisdictionAlert> alertsForState(String stateCode) {
    final upper = stateCode.toUpperCase();
    switch (upper) {
      case 'CA':
        return const [
          JurisdictionAlert(
            id: 'CA.mandatoryReporting.child',
            title: 'California — mandatory child abuse reporting',
            body:
                'Reasonable suspicion of child abuse or neglect must be '
                'reported to the local Child Welfare Services or law '
                'enforcement within 36 hours. Failure to report is a '
                'misdemeanour.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: 'Cal. Penal Code §11166(a)',
          ),
          JurisdictionAlert(
            id: 'CA.mandatoryReporting.elder',
            title: 'California — mandatory elder + dependent adult reporting',
            body:
                'Reasonable suspicion of elder or dependent-adult abuse must '
                'be reported within 24 hours (immediate for physical or '
                'financial abuse) to Adult Protective Services + local law '
                'enforcement.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: 'Cal. Welf. & Inst. Code §15630(b)',
          ),
          JurisdictionAlert(
            id: 'CA.dutyToWarn.tarasoff',
            title: 'California — Tarasoff duty to warn AND protect',
            body:
                'When a patient communicates a serious threat of physical '
                'violence against a reasonably identifiable victim, the '
                'clinician must take reasonable steps both to warn the '
                'intended victim AND notify law enforcement.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.critical,
            citation: 'Cal. Civ. Code §43.92; Ewing v. Goldstein (2004)',
          ),
          JurisdictionAlert(
            id: 'CA.telehealthLicensure',
            title: 'California — telehealth licensure',
            body:
                'You must hold an active California license to provide '
                'telehealth to a patient physically located in California. '
                'Out-of-state licensees may treat existing CA patients up to '
                '30 days during temporary travel only.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation: 'Cal. Bus. & Prof. Code §2290.5',
          ),
          JurisdictionAlert(
            id: 'CA.documentationRetention',
            title: 'California — record retention',
            body:
                'Adult records: retain at least 7 years after the last '
                'service. Minor records: at least 1 year after the patient '
                'reaches 18 (so functionally until age 19), and never less '
                'than 7 years total.',
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: 'Cal. Bus. & Prof. Code §2919; 16 CCR §1356.1',
          ),
        ];
      case 'NY':
        return const [
          JurisdictionAlert(
            id: 'NY.mandatoryReporting.child',
            title: 'New York — mandatory child abuse reporting',
            body:
                'Reasonable cause to suspect child abuse or maltreatment must '
                'be reported immediately by phone to the Statewide Central '
                'Register (1-800-635-1522) and followed up in writing within '
                '48 hours.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: 'N.Y. Soc. Serv. Law §413; §415',
          ),
          JurisdictionAlert(
            id: 'NY.dutyToWarn.modified',
            title: 'New York — duty to warn (statutory immunity)',
            body:
                'No common-law Tarasoff duty, but Mental Hygiene Law §9.46 '
                'allows mental-health professionals to report a patient '
                'likely to engage in serious harm to the Statewide '
                'Integrated Database. Disclosure is permitted, not mandated.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.warning,
            citation: 'N.Y. Mental Hyg. Law §9.46 (SAFE Act 2013)',
          ),
          JurisdictionAlert(
            id: 'NY.telehealthLicensure',
            title: 'New York — telehealth licensure',
            body:
                'You must hold an active New York license to treat patients '
                'physically located in New York. NY does not currently '
                'participate in PSYPACT; out-of-state psychologists may not '
                'use telehealth to NY residents.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation: 'N.Y. Educ. Law §6512',
          ),
          JurisdictionAlert(
            id: 'NY.documentationRetention',
            title: 'New York — record retention',
            body:
                'Adult records: retain at least 6 years after the last '
                'service. Minor records: until the patient is 22 (6 years '
                'past age 18). Mental-health agency records may have longer '
                'requirements under OMH Title 14 NYCRR §501.4.',
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: 'N.Y. Educ. Law §6530(32); 14 NYCRR §501.4',
          ),
        ];
      case 'TX':
        return const [
          JurisdictionAlert(
            id: 'TX.mandatoryReporting.child',
            title: 'Texas — mandatory child abuse reporting',
            body:
                'Any person (no professional exemption) with cause to '
                'believe a child is being abused or neglected must report '
                'within 48 hours to the Texas Department of Family and '
                'Protective Services (1-800-252-5400) or law enforcement.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: 'Tex. Fam. Code §261.101',
          ),
          JurisdictionAlert(
            id: 'TX.dutyToWarn.thapar',
            title: 'Texas — Thapar v. Zezulka (no duty to warn)',
            body:
                'Texas has explicitly rejected a Tarasoff duty in Thapar v. '
                'Zezulka (1999). Disclosure to law enforcement or a '
                'medical professional may be made under Tex. Health & Safety '
                'Code §611.004(a)(2) when there is a probability of '
                'imminent physical injury, but is permissive only.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.warning,
            citation:
                'Thapar v. Zezulka, 994 S.W.2d 635 (Tex. 1999); '
                'Tex. Health & Safety Code §611.004',
          ),
          JurisdictionAlert(
            id: 'TX.telehealthLicensure',
            title: 'Texas — telehealth licensure + PSYPACT',
            body:
                'Texas is a PSYPACT state. Out-of-state PSYPACT-credentialed '
                'psychologists may treat Texas residents via telehealth '
                'without an additional Texas license. LPCs and LCSWs are '
                'not covered by PSYPACT — full TX licensure required.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation: 'Tex. Occ. Code §501.260; PSYPACT effective 2019',
          ),
          JurisdictionAlert(
            id: 'TX.documentationRetention',
            title: 'Texas — record retention',
            body:
                'Adult records: retain at least 7 years after the last '
                'service. Minor records: until the patient turns 21 (or '
                '7 years after last service, whichever is longer).',
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: 'Tex. Occ. Code §501.262; 22 TAC §465.22',
          ),
        ];
      case 'FL':
        return const [
          JurisdictionAlert(
            id: 'FL.mandatoryReporting.child',
            title: 'Florida — mandatory child abuse reporting',
            body:
                'Florida is a universal-reporter state. Any person with '
                'reasonable suspicion of child abuse, abandonment, or '
                'neglect must report immediately to the Florida Abuse '
                'Hotline (1-800-962-2873). No professional exemption.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: 'Fla. Stat. §39.201',
          ),
          JurisdictionAlert(
            id: 'FL.dutyToWarn.boynton',
            title: 'Florida — duty-to-warn ambiguity (Boynton)',
            body:
                'Florida has not adopted Tarasoff by statute. Boynton v. '
                'Burglass (Fla. Dist. Ct. App. 1992) rejected a common-law '
                'duty to warn. Disclosure is permitted under Fla. Stat. '
                '§456.059(4) when a patient communicates a specific threat '
                'to a specific identifiable target — permissive only.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.warning,
            citation:
                'Boynton v. Burglass, 590 So.2d 446 (Fla. 1992); '
                'Fla. Stat. §456.059(4)',
          ),
          JurisdictionAlert(
            id: 'FL.telehealthLicensure.outOfState',
            title: 'Florida — out-of-state telehealth registration',
            body:
                'Florida requires an out-of-state provider to register with '
                'the relevant Florida board (medical, psychology, mental-'
                'health counseling) before providing telehealth to a '
                'Florida-located patient. PSYPACT is recognised for '
                'psychologists.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation: 'Fla. Stat. §456.47',
          ),
          JurisdictionAlert(
            id: 'FL.mandatoryReporting.hiv',
            title: 'Florida — HIV reporting + disclosure exception',
            body:
                'Florida has named-HIV reporting (Fla. Stat. §381.0042) and '
                'specific consent requirements for disclosing HIV status, '
                'including a narrow exception for known-contact partner '
                'notification by the Department of Health.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.warning,
            citation: 'Fla. Stat. §§381.0042, 381.004',
          ),
          JurisdictionAlert(
            id: 'FL.documentationRetention',
            title: 'Florida — record retention',
            body:
                'Adult psychotherapy records: at least 7 years after the last '
                'service per Fla. Admin. Code 64B19-19.005. Minor records: at '
                'least 7 years after the patient reaches 18.',
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: 'Fla. Admin. Code 64B19-19.005',
          ),
        ];
      case 'IL':
        return const [
          JurisdictionAlert(
            id: 'IL.mandatoryReporting.child',
            title: 'Illinois — DCFS reporting (immediate)',
            body:
                'Mental-health professionals are mandated reporters under '
                'the Abused and Neglected Child Reporting Act. Suspected '
                'abuse / neglect must be reported immediately to the DCFS '
                'Hotline (1-800-25-ABUSE) and followed up in writing within '
                '48 hours.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: '325 ILCS 5/4',
          ),
          JurisdictionAlert(
            id: 'IL.dutyToWarn.mhddca',
            title:
                'Illinois — Mental Health and Developmental Disabilities '
                'Confidentiality Act',
            body:
                'The MHDDCA strictly limits disclosure of mental-health '
                'records. Disclosure to a third party threatened with '
                'imminent serious harm is permitted under § 11 only when '
                'the patient or therapist makes a "specific and immediate '
                'threat" — document the determination.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.warning,
            citation: '740 ILCS 110/11',
          ),
          JurisdictionAlert(
            id: 'IL.telehealthLicensure.psypact',
            title: 'Illinois — PSYPACT + LCSW licensure',
            body:
                'Illinois joined PSYPACT in 2022 — out-of-state PSYPACT '
                'psychologists may treat IL residents remotely. LCSWs and '
                'LPCs require full IL licensure; the IDFPR mental-health '
                'compact for these professions is pending.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation: '225 ILCS 15/3; PSYPACT IL effective 2022',
          ),
          JurisdictionAlert(
            id: 'IL.documentationRetention',
            title: 'Illinois — record retention',
            body:
                'Adult mental-health records: at least 5 years after the '
                'last service per MHDDCA § 7. Minor records: until the '
                'patient is 23 or 5 years after the last service, '
                'whichever is later.',
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: '740 ILCS 110/7; 225 ILCS 15/7',
          ),
        ];
      case 'WA':
        return const [
          JurisdictionAlert(
            id: 'WA.mandatoryReporting.child',
            title: 'Washington — mandatory child abuse reporting',
            body:
                'Mental-health professionals are mandated reporters under '
                'RCW 26.44.030. Reports must be made "at the first '
                'opportunity but in no case longer than 48 hours" to law '
                'enforcement or the Department of Children, Youth, and '
                'Families.',
            category: AlertCategory.mandatoryReporting,
            severity: AlertSeverity.critical,
            citation: 'RCW 26.44.030',
          ),
          JurisdictionAlert(
            id: 'WA.dutyToWarn.volk',
            title: 'Washington — duty to warn (Volk v. DeMeerleer)',
            body:
                'Washington recognises a broad duty to protect: clinicians '
                'must take reasonable precautions when a patient poses a '
                'foreseeable risk of serious harm to others — even when no '
                'specific victim is identified. Document risk assessment + '
                'protective steps in the chart.',
            category: AlertCategory.dutyToWarn,
            severity: AlertSeverity.critical,
            citation: 'Volk v. DeMeerleer, 386 P.3d 254 (Wash. 2016)',
          ),
          JurisdictionAlert(
            id: 'WA.telehealthLicensure.compact',
            title: 'Washington — PSYPACT + Counseling Compact',
            body:
                'Washington is a PSYPACT state effective 2023. Counselors '
                'travel through the Counseling Compact (effective 2024). '
                'LCSWs require full WA licensure; the Social Work Compact '
                'has not yet been enacted in Washington.',
            category: AlertCategory.telehealthLicensure,
            severity: AlertSeverity.warning,
            citation: 'RCW 18.83.200; PSYPACT WA effective 2023',
          ),
          JurisdictionAlert(
            id: 'WA.documentationRetention',
            title: 'Washington — record retention',
            body:
                'Adult mental-health records: at least 7 years after the '
                "last service. Minor records: until the patient's 21st "
                "birthday OR 7 years after the last service, whichever is "
                "later.",
            category: AlertCategory.documentationRetention,
            severity: AlertSeverity.info,
            citation: 'WAC 246-924-354',
          ),
        ];
      default:
        return const [];
    }
  }

  /// Convenience — every alert across the multi-state license set.
  /// Used by the settings screen to render a "select your states"
  /// preview block.
  List<JurisdictionAlert> alertsForMultipleStates(Iterable<String> stateCodes) {
    final out = <JurisdictionAlert>[];
    for (final code in stateCodes) {
      out.addAll(alertsForState(code));
    }
    return out;
  }

  /// Returns true if any alert in the bundle is a `critical` severity —
  /// the UI lights a red banner when this returns true.
  bool hasCriticalAlert(List<JurisdictionAlert> alerts) {
    return alerts.any((a) => a.severity == AlertSeverity.critical);
  }
}
