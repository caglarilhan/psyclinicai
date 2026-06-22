// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'PsyClinicAI';

  @override
  String get navHome => 'Start';

  @override
  String get navPatients => 'Patient:innen';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navTrustCenter => 'Trust Center';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionConfirm => 'Bestätigen';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionExport => 'Exportieren';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get consentDeniedTitle => 'AI assistance is not consented';

  @override
  String get consentDeniedBody =>
      'Update the intake form before drafting with AI.';

  @override
  String get consentDeniedAction => 'Open intake';

  @override
  String get imminentRiskHeadline => 'Imminent risk — act now';

  @override
  String get imminentRiskBody =>
      'Do not leave the patient alone. Conduct a full clinical risk assessment and arrange transfer to emergency services or an inpatient setting per protocol.';

  @override
  String get imminentRiskCta => 'Start safety plan now';

  @override
  String get imminentRiskDismiss => 'I\'ll handle this manually';

  @override
  String get dismissReasonHospitalized =>
      'Patient is on the way to / already at an inpatient setting';

  @override
  String get dismissReasonFamilyPresent =>
      'Family or trusted adult is with the patient and informed';

  @override
  String get dismissReasonSupervisorHandoff =>
      'Handed off to a supervisor / on-call psychiatrist';

  @override
  String get dismissReasonInSessionPlan =>
      'Completing a safety plan inside this session instead';

  @override
  String get dismissReasonOther => 'Other (documented in the session note)';

  @override
  String get crisisResources => 'Crisis resources';

  @override
  String crisisResourcesLastReviewed(String date) {
    return 'Last reviewed $date — verify before relying on a number in an emergency.';
  }

  @override
  String get dsarPortalTitle => 'Data export (DSAR)';

  @override
  String get dsarPortalSubtitle =>
      'GDPR Article 15 (access) + Article 20 (portability).';

  @override
  String get dsarPhiBanner =>
      'Sharing this file outside the chart is patient authorised under GDPR Art. 15/20. Treat the JSON as PHI.';

  @override
  String get dsarEmptyBundle =>
      'No patient records on file yet. Complete an intake or open a safety plan and the bundle will populate.';

  @override
  String get phiBadge => 'PHI';

  @override
  String get phiBannerWeb =>
      'Web build does not cache PHI on this device. Records read from and write to the server on every action.';

  @override
  String get supervisionQueueTitle => 'Supervision queue';

  @override
  String get supervisionQueueSubtitle =>
      'Trainee notes awaiting your approval, change request, or co-sign.';

  @override
  String get supervisionOpenSection => 'Open';

  @override
  String get supervisionClosedSection => 'Closed';

  @override
  String get supervisionEmptyOpen => 'No notes are waiting on you.';

  @override
  String get supervisionEmptyClosed => 'No decisions on the record yet.';

  @override
  String get supervisionActionApprove => 'Approve';

  @override
  String get supervisionActionChanges => 'Request changes';

  @override
  String get supervisionActionCoSign => 'Co-sign';

  @override
  String get supervisionCoSignDisclaimer =>
      'Co-sign here records the supervisor decision but is NOT yet a legally binding electronic signature. Cryptographic signing (TOTP/WebAuthn, eIDAS / HIPAA §164.312(c)(2)) lands in Sprint 10. Until then, keep a wet-signature archive for billable Medicaid notes.';

  @override
  String get portalTitle => 'Your portal';

  @override
  String get portalWelcome => 'Welcome';

  @override
  String get portalIntro =>
      'A private space connected to your clinic. Everything you do here is logged for your records and protected under GDPR and KVKK.';

  @override
  String get portalIntakeTitle => 'First-visit questionnaire';

  @override
  String get portalIntakeBody =>
      'Share history, current medications, and consent with your clinician before the first session.';

  @override
  String get portalPromTitle => 'Progress questionnaires';

  @override
  String get portalPromBody =>
      'PHQ-9, GAD-7, and other measures requested by your clinician.';

  @override
  String get portalSessionsTitle => 'Upcoming sessions';

  @override
  String get portalSessionsBody =>
      'See the appointments your clinician scheduled. Cancellations and reschedule requests notify your clinician automatically.';

  @override
  String get portalDsarTitle => 'Request your data';

  @override
  String get portalDsarBody =>
      'Get a copy of every record we hold for you. Delivered as a portable JSON archive.';

  @override
  String get portalDeleteTitle => 'Close your account';

  @override
  String get portalDeleteBody =>
      'Start a 30-day deletion. Your clinical record is pseudonymised after the grace window (replaced with an anonymous placeholder).';

  @override
  String get portalSecurityFooter =>
      'Sessions and notes between you and your clinician are held on EU servers. AI assistance only runs when you have explicitly opted in.';
}
