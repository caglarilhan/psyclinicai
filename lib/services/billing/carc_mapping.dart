/// CARC (Claim Adjustment Reason Code) → human reason + remediation
/// hint. Sprint 27 W2 completes the top-50 mental-health frequency
/// table so the insurance claim board can render a one-tap hint
/// chip on every denial row.
///
/// Source: CMS X12 835 standard CARC list. Selection covers the
/// fifty codes most frequently seen on mental-health claims
/// (group code CO/PR), curated against denial logs from the
/// pilot panel. Hints are written for a solo therapist —
/// concrete, actionable, jargon-free.
library;

class CarcEntry {
  const CarcEntry({
    required this.code,
    required this.reason,
    required this.hint,
    required this.category,
  });

  /// CARC code, e.g. `'CO-50'`. Group prefix is part of the key
  /// because some carriers reuse the numeric portion across groups.
  final String code;

  /// Short payer-facing reason text (one line).
  final String reason;

  /// Actionable remediation hint shown in the claim board chip.
  final String hint;

  /// High-level category — used to group filters in the board.
  final CarcCategory category;
}

enum CarcCategory {
  patientResponsibility,
  coding,
  authorization,
  eligibility,
  medicalNecessity,
  cob,
  timing,
  other,
}

const Map<String, CarcEntry> _entries = {
  // ── Patient responsibility ──────────────────────────────────────
  'CO-1': CarcEntry(
    code: 'CO-1',
    reason: 'Deductible amount',
    hint: 'Bill the patient. Confirm deductible has not since reset.',
    category: CarcCategory.patientResponsibility,
  ),
  'CO-2': CarcEntry(
    code: 'CO-2',
    reason: 'Coinsurance amount',
    hint: 'Bill the patient share. Verify plan coinsurance %.',
    category: CarcCategory.patientResponsibility,
  ),
  'CO-3': CarcEntry(
    code: 'CO-3',
    reason: 'Co-payment amount',
    hint: 'Collect copay at next visit. Update fee schedule.',
    category: CarcCategory.patientResponsibility,
  ),
  // ── Coding / format ─────────────────────────────────────────────
  'CO-4': CarcEntry(
    code: 'CO-4',
    reason: 'Procedure code inconsistent with modifier',
    hint: 'Add or correct CPT modifier (often -25 / -59 / GT).',
    category: CarcCategory.coding,
  ),
  'CO-5': CarcEntry(
    code: 'CO-5',
    reason: 'Procedure code inconsistent with place of service',
    hint: 'Verify POS-11 (office) vs POS-02 (telehealth) on the claim.',
    category: CarcCategory.coding,
  ),
  'CO-6': CarcEntry(
    code: 'CO-6',
    reason: 'Procedure code inconsistent with patient age',
    hint: 'Use age-appropriate CPT (e.g., 90837 vs 90832 for minors).',
    category: CarcCategory.coding,
  ),
  'CO-8': CarcEntry(
    code: 'CO-8',
    reason: 'Procedure code inconsistent with provider specialty',
    hint: 'Confirm provider taxonomy code on file matches the CPT.',
    category: CarcCategory.coding,
  ),
  'CO-11': CarcEntry(
    code: 'CO-11',
    reason: 'Diagnosis inconsistent with the procedure',
    hint: 'Re-pair CPT to a covered ICD-10 (F32.x / F41.x typically).',
    category: CarcCategory.coding,
  ),
  'CO-16': CarcEntry(
    code: 'CO-16',
    reason: 'Claim lacks information or has billing error',
    hint: 'Check the claim 277CA for the missing element and resubmit.',
    category: CarcCategory.coding,
  ),
  'CO-18': CarcEntry(
    code: 'CO-18',
    reason: 'Duplicate claim',
    hint: 'Confirm a paid copy exists. If not, appeal with original date.',
    category: CarcCategory.coding,
  ),
  'CO-125': CarcEntry(
    code: 'CO-125',
    reason: 'Submission / billing error',
    hint: 'Pull the 277CA report; usually a missing NPI or rev-code.',
    category: CarcCategory.coding,
  ),
  'CO-129': CarcEntry(
    code: 'CO-129',
    reason: 'Prior processing information appears incorrect',
    hint: 'Verify claim history; void a duplicate before resubmitting.',
    category: CarcCategory.coding,
  ),
  'CO-140': CarcEntry(
    code: 'CO-140',
    reason: 'Patient ID and name do not match',
    hint: 'Re-key member ID + DOB. Confirm name suffix (Jr/Sr).',
    category: CarcCategory.coding,
  ),
  'CO-146': CarcEntry(
    code: 'CO-146',
    reason: 'Diagnosis invalid for the date of service',
    hint: 'Replace deprecated ICD-10; use the version effective on DOS.',
    category: CarcCategory.coding,
  ),
  'CO-181': CarcEntry(
    code: 'CO-181',
    reason: 'Procedure code invalid on the date of service',
    hint: 'CPT may have been retired. Check the CPT year of service.',
    category: CarcCategory.coding,
  ),
  'CO-199': CarcEntry(
    code: 'CO-199',
    reason: 'Revenue code and procedure code do not match',
    hint: 'Update facility rev-code pairing on the UB-04 / 837I.',
    category: CarcCategory.coding,
  ),
  // ── Authorization ───────────────────────────────────────────────
  'CO-15': CarcEntry(
    code: 'CO-15',
    reason: 'Authorization number missing, invalid, or does not apply',
    hint: 'Look up the auth in the payer portal; resubmit with the ID.',
    category: CarcCategory.authorization,
  ),
  'CO-39': CarcEntry(
    code: 'CO-39',
    reason: 'Services denied at the time pre-cert was requested',
    hint: 'Pre-cert was denied — appeal with a fresh clinical packet.',
    category: CarcCategory.authorization,
  ),
  'CO-62': CarcEntry(
    code: 'CO-62',
    reason: 'Payment denied for absence of pre-certification',
    hint: 'Request retro-auth (most payers honour a 60-day window).',
    category: CarcCategory.authorization,
  ),
  'CO-95': CarcEntry(
    code: 'CO-95',
    reason: 'Plan procedures not followed',
    hint: 'Re-read the plan policy bulletin; common cause is missing referral.',
    category: CarcCategory.authorization,
  ),
  'CO-197': CarcEntry(
    code: 'CO-197',
    reason: 'Pre-certification / authorization absent',
    hint: 'Get prior auth before the next session and back-bill.',
    category: CarcCategory.authorization,
  ),
  'CO-252': CarcEntry(
    code: 'CO-252',
    reason: 'Attachment / documentation required to adjudicate',
    hint: 'Send the requested attachment via the payer portal within 30 days.',
    category: CarcCategory.authorization,
  ),
  // ── Eligibility ─────────────────────────────────────────────────
  'CO-26': CarcEntry(
    code: 'CO-26',
    reason: 'Expenses incurred prior to coverage',
    hint: 'Confirm coverage effective date with the payer.',
    category: CarcCategory.eligibility,
  ),
  'CO-27': CarcEntry(
    code: 'CO-27',
    reason: 'Expenses incurred after coverage terminated',
    hint: 'Bill the patient or COBRA carrier for post-term services.',
    category: CarcCategory.eligibility,
  ),
  'CO-31': CarcEntry(
    code: 'CO-31',
    reason: 'Patient cannot be identified as our insured',
    hint: 'Run real-time eligibility (270/271) and re-key member ID.',
    category: CarcCategory.eligibility,
  ),
  'CO-32': CarcEntry(
    code: 'CO-32',
    reason: 'Dependent not eligible',
    hint: 'Confirm dependent age / student status. Update enrolment.',
    category: CarcCategory.eligibility,
  ),
  'CO-204': CarcEntry(
    code: 'CO-204',
    reason: 'Service not covered under current benefit plan',
    hint: 'Check covered service list; consider a self-pay flow.',
    category: CarcCategory.eligibility,
  ),
  // ── Medical necessity ───────────────────────────────────────────
  'CO-49': CarcEntry(
    code: 'CO-49',
    reason: 'Non-covered routine / preventive service',
    hint: 'Re-code as treatment (90837 + active dx) if clinically supported.',
    category: CarcCategory.medicalNecessity,
  ),
  'CO-50': CarcEntry(
    code: 'CO-50',
    reason: 'Not deemed medically necessary',
    hint: 'Appeal with PHQ-9 / GAD-7 trend + failed first-line note.',
    category: CarcCategory.medicalNecessity,
  ),
  'CO-51': CarcEntry(
    code: 'CO-51',
    reason: 'Pre-existing condition',
    hint: 'Pull policy pre-ex clause; ACA plans usually waive this.',
    category: CarcCategory.medicalNecessity,
  ),
  'CO-55': CarcEntry(
    code: 'CO-55',
    reason: 'Experimental / investigational',
    hint: 'Cite peer-reviewed evidence; submit a level-2 appeal.',
    category: CarcCategory.medicalNecessity,
  ),
  'CO-150': CarcEntry(
    code: 'CO-150',
    reason: 'Documentation does not support this level of service',
    hint: 'Resubmit a fuller progress note; consider 90834 vs 90837.',
    category: CarcCategory.medicalNecessity,
  ),
  'CO-151': CarcEntry(
    code: 'CO-151',
    reason: 'Documentation does not support this frequency',
    hint: 'Justify session cadence in the treatment plan.',
    category: CarcCategory.medicalNecessity,
  ),
  'CO-152': CarcEntry(
    code: 'CO-152',
    reason: 'Documentation does not support this length of service',
    hint: 'Time-stamp the start/end; downcode to 90834 if appropriate.',
    category: CarcCategory.medicalNecessity,
  ),
  'CO-167': CarcEntry(
    code: 'CO-167',
    reason: 'Diagnosis is not covered',
    hint: 'Re-pair to a covered axis-I dx in line with the visit.',
    category: CarcCategory.medicalNecessity,
  ),
  // ── COB / coordination ──────────────────────────────────────────
  'CO-22': CarcEntry(
    code: 'CO-22',
    reason: 'May be covered by another payer (COB)',
    hint: 'File with the primary carrier first; attach the EOB.',
    category: CarcCategory.cob,
  ),
  'CO-23': CarcEntry(
    code: 'CO-23',
    reason: 'Impact of prior payer adjudication',
    hint: 'Attach the primary payer EOB and resubmit.',
    category: CarcCategory.cob,
  ),
  'CO-24': CarcEntry(
    code: 'CO-24',
    reason: 'Covered under capitation / managed care',
    hint: 'No further action — this is in the capitation contract.',
    category: CarcCategory.cob,
  ),
  'CO-100': CarcEntry(
    code: 'CO-100',
    reason: 'Payment made to patient',
    hint: 'Patient was paid directly — bill the patient.',
    category: CarcCategory.cob,
  ),
  'CO-109': CarcEntry(
    code: 'CO-109',
    reason: 'Claim not covered by this payer / contractor',
    hint: 'Re-route to the correct payer; double-check the member ID.',
    category: CarcCategory.cob,
  ),
  // ── Timing ──────────────────────────────────────────────────────
  'CO-29': CarcEntry(
    code: 'CO-29',
    reason: 'Time limit for filing has expired',
    hint: 'File a timely-filing appeal with the original 277CA proof.',
    category: CarcCategory.timing,
  ),
  'CO-119': CarcEntry(
    code: 'CO-119',
    reason: 'Benefit maximum reached',
    hint: 'Switch to self-pay or escalate to plan max appeal.',
    category: CarcCategory.timing,
  ),
  // ── Other coding / payment policy ───────────────────────────────
  'CO-45': CarcEntry(
    code: 'CO-45',
    reason: 'Charge exceeds fee schedule',
    hint: 'Write-off the excess per contract; resubmit at allowable.',
    category: CarcCategory.other,
  ),
  'CO-54': CarcEntry(
    code: 'CO-54',
    reason: 'Multiple physicians / assistants not covered',
    hint: 'Bill the rendering provider only; drop the assistant line.',
    category: CarcCategory.other,
  ),
  'CO-58': CarcEntry(
    code: 'CO-58',
    reason: 'Rendered in inappropriate place of service',
    hint: 'Update POS code; check telehealth-vs-office allowance.',
    category: CarcCategory.other,
  ),
  'CO-59': CarcEntry(
    code: 'CO-59',
    reason: 'Multiple / concurrent procedure rules',
    hint: 'Apply modifier -59 or unbundle per NCCI edits.',
    category: CarcCategory.other,
  ),
  'CO-60': CarcEntry(
    code: 'CO-60',
    reason: 'Outpatient charges denied during inpatient stay',
    hint: 'Confirm DOS bracket; rebill under inpatient claim if eligible.',
    category: CarcCategory.other,
  ),
  'CO-96': CarcEntry(
    code: 'CO-96',
    reason: 'Non-covered charges',
    hint: 'Read the remittance remark for the specific exclusion.',
    category: CarcCategory.other,
  ),
  'CO-97': CarcEntry(
    code: 'CO-97',
    reason: 'Benefit included in payment for another service',
    hint: 'Service is bundled; verify NCCI pair before appealing.',
    category: CarcCategory.other,
  ),
  'CO-185': CarcEntry(
    code: 'CO-185',
    reason: 'Rendering provider not eligible to perform service',
    hint: 'Confirm credentialing status; re-enrol if lapsed.',
    category: CarcCategory.other,
  ),
};

/// Returns the entry for `code` (case-insensitive, accepts `'CO50'`,
/// `'co-50'`, `'CO 50'`). `null` when unknown.
CarcEntry? carcLookup(String? code) {
  if (code == null || code.isEmpty) return null;
  final normalised = _normalise(code);
  return _entries[normalised];
}

String _normalise(String code) {
  final trimmed = code.trim().toUpperCase().replaceAll(' ', '');
  if (trimmed.contains('-')) return trimmed;
  final m = RegExp(r'^(CO|PR|OA|PI)(\d+)$').firstMatch(trimmed);
  if (m == null) return trimmed;
  return '${m.group(1)}-${m.group(2)}';
}

/// Total number of mapped codes.
int carcMappingSize() => _entries.length;

/// All entries — used by the admin denial-coverage report.
Iterable<CarcEntry> carcAllEntries() => _entries.values;
