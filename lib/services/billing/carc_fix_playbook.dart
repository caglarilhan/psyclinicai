/// CARC (Claim Adjustment Reason Code) → structured remediation
/// playbook. `carc_mapping.dart` already maps codes to a one-line
/// hint; this layer adds a step-by-step playbook the claim board
/// surfaces when the clinician opens a denied claim.
library;

import '../../models/denial_risk.dart';

/// Step the clinician should take next.
class CarcFixStep {
  const CarcFixStep({required this.label, required this.detail});
  final String label;
  final String detail;
}

class CarcFixEntry {
  const CarcFixEntry({
    required this.code,
    required this.immediateFix,
    required this.resubmitStep,
    required this.appealAngle,
    this.payerEmphasis = const {},
    this.cptSpecific = const {},
  });

  /// CARC code with group prefix (e.g. `CO-50`).
  final String code;

  final CarcFixStep immediateFix;
  final CarcFixStep resubmitStep;
  final CarcFixStep appealAngle;

  /// Optional per-payer angle override. Looked up before
  /// `appealAngle` so payer-specific wording wins.
  final Map<Payer, CarcFixStep> payerEmphasis;

  /// Optional per-CPT immediate-fix override.
  final Map<String, CarcFixStep> cptSpecific;

  /// Resolve the appeal angle for a given payer (with fallback).
  CarcFixStep appealAngleFor(Payer p) => payerEmphasis[p] ?? appealAngle;

  /// Resolve the immediate fix for a given CPT (with fallback).
  CarcFixStep immediateFixFor(String cptCode) =>
      cptSpecific[cptCode] ?? immediateFix;
}

class CarcFixPlaybook {
  const CarcFixPlaybook._();

  /// Lookup the playbook entry for [code]. Returns null when the
  /// code isn't in the curated playbook (the claim board falls
  /// back to the generic `carc_mapping.dart` hint).
  static CarcFixEntry? forCode(String code) => _entries[code];

  /// All entries.
  static Map<String, CarcFixEntry> get all => Map.unmodifiable(_entries);

  static const Map<String, CarcFixEntry> _entries = {
    'CO-11': CarcFixEntry(
      code: 'CO-11',
      immediateFix: CarcFixStep(
        label: 'Re-pair diagnosis with procedure',
        detail:
            'Update the ICD-10 pointer on the 837P so the diagnosis '
            'matches a mental-health code the billed CPT can claim '
            'against (e.g. F33.1 -> 90837).',
      ),
      resubmitStep: CarcFixStep(
        label: 'Corrected claim (Frequency Code 7)',
        detail:
            'Submit a corrected claim referencing the original claim '
            'control number; do not file a new claim.',
      ),
      appealAngle: CarcFixStep(
        label: 'Medical necessity narrative',
        detail:
            'Attach the progress note + treatment plan that show the '
            'diagnosis genuinely drives this CPT-level service.',
      ),
    ),

    'CO-50': CarcFixEntry(
      code: 'CO-50',
      immediateFix: CarcFixStep(
        label: 'Add explicit medical-necessity statement',
        detail:
            'Insert a sentence in the progress note tying the '
            'diagnosis to the intervention and the expected functional '
            'benefit.',
      ),
      resubmitStep: CarcFixStep(
        label: 'Corrected resubmission with updated note',
        detail:
            'Re-export the 837P + include the updated progress note '
            'as a documentation attachment if the payer accepts one.',
      ),
      appealAngle: CarcFixStep(
        label: 'Cite the treatment plan goal + measurable outcome',
        detail:
            'Attach the active SMART goal + the most recent outcome '
            'measure (PHQ-9 / GAD-7 / PCL-5).',
      ),
      payerEmphasis: {
        Payer.medicare: CarcFixStep(
          label: 'Cite the applicable LCD',
          detail:
              'Reference the LCD covering outpatient psychotherapy in '
              'your jurisdiction (and 1862(a)(1)(A)).',
        ),
        Payer.uhcOptum: CarcFixStep(
          label: 'Cite the Optum LOC criterion the patient meets',
          detail:
              'Map the documented presentation to a specific Optum '
              'Level of Care Guideline criterion.',
        ),
        Payer.medicaid: CarcFixStep(
          label: 'Cite the golden thread',
          detail:
              'Reference the treatment plan goal + functional-'
              'impairment domain the session targeted.',
        ),
      },
    ),

    'CO-96': CarcFixEntry(
      code: 'CO-96',
      immediateFix: CarcFixStep(
        label: "Confirm CPT is covered for the patient's benefit",
        detail:
            'Check the EOB / payer portal for an active benefit on the '
            'specific CPT. If not covered, switch to a covered code or '
            'write off the line.',
      ),
      resubmitStep: CarcFixStep(
        label: 'Switch CPT or write off',
        detail:
            'If a covered alternative exists (e.g. 90834 instead of '
            '90837), submit the corrected claim with the new code. '
            'Otherwise mark the claim writtenOff.',
      ),
      appealAngle: CarcFixStep(
        label: 'Argue benefit-level coverage with supporting notes',
        detail:
            'Cite the benefit summary + EOB language. When the issue '
            "is the patient's plan tier, only the patient can appeal "
            'via member services.',
      ),
    ),

    'CO-97': CarcFixEntry(
      code: 'CO-97',
      immediateFix: CarcFixStep(
        label: 'Add a modifier or split the encounter',
        detail:
            'Apply modifier 25 / 59 when a separately identifiable '
            'service truly occurred, or split into separate dates of '
            'service if the visit was distinct.',
      ),
      resubmitStep: CarcFixStep(
        label: 'Corrected claim with modifier',
        detail:
            'Submit a corrected claim with the appropriate NCCI-'
            'compatible modifier and the documentation supporting the '
            'distinct service.',
      ),
      appealAngle: CarcFixStep(
        label: 'Document the separately identifiable service',
        detail:
            'Attach the portion of the progress note that shows the '
            'second service was distinct in time, focus, or content.',
      ),
    ),

    'CO-151': CarcFixEntry(
      code: 'CO-151',
      immediateFix: CarcFixStep(
        label: 'Document frequency / duration support',
        detail:
            'Add a frequency-justification line to the treatment plan: '
            '"weekly 60-min sessions for 12 weeks given GAD-7 of 17 + '
            'functional decline".',
      ),
      resubmitStep: CarcFixStep(
        label: 'Corrected claim + revised treatment plan',
        detail:
            'Submit corrected claim with the updated treatment plan that '
            'justifies the frequency / duration billed.',
      ),
      appealAngle: CarcFixStep(
        label: 'Outcome trajectory',
        detail:
            'Attach the outcome-measure trend (PHQ-9 / GAD-7 weekly) '
            'showing the frequency is producing measurable change.',
      ),
    ),

    'CO-197': CarcFixEntry(
      code: 'CO-197',
      immediateFix: CarcFixStep(
        label: 'Obtain retro-authorization',
        detail:
            "Call the payer's prior-auth line within the appeal window "
            '(typically 60-90 days) and request retro-authorization '
            'citing clinical urgency.',
      ),
      resubmitStep: CarcFixStep(
        label: 'Resubmit with authorization number',
        detail:
            'Once retro-auth is granted, submit a corrected claim with '
            'the authorization number in the appropriate 837P loop.',
      ),
      appealAngle: CarcFixStep(
        label: 'Clinical urgency argument',
        detail:
            'Document why authorization could not be obtained in '
            'advance (e.g. acute risk presentation) and cite the '
            'safety rationale.',
      ),
    ),

    'PR-1': CarcFixEntry(
      code: 'PR-1',
      immediateFix: CarcFixStep(
        label: 'Bill the patient',
        detail:
            'Move the line to patient responsibility; do not appeal. '
            'Generate a patient statement for the deductible amount.',
      ),
      resubmitStep: CarcFixStep(
        label: 'No resubmission',
        detail:
            "Payment is correct per the patient's plan. The line "
            'belongs to the patient until the deductible is met.',
      ),
      appealAngle: CarcFixStep(
        label: 'Verify deductible math only',
        detail:
            'If the EOB math is wrong (the patient already met the '
            'deductible elsewhere), correct via the payer portal — not '
            'a clinical appeal.',
      ),
    ),
  };
}
