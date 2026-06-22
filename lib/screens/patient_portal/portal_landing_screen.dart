import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/data/auth_service.dart';
import '../../theme/tokens.dart';

/// `/portal` — patient-facing landing scaffold (Sprint 9).
///
/// Lives on the patient auth side, deliberately separated from the
/// clinician [AppShell]: a patient must never see clinician nav, and
/// the visual language should make that obvious at a glance.
///
/// Transparency-first content: every card tells the patient what the
/// clinic does with their data and which right that maps to (GDPR
/// Art. 15/17/20, KVKK Md. 11), even before they tap in. The
/// underlying actions land in Sprint 10 (PROM, DSAR self-service,
/// secure messaging, appointment self-view) once the patient auth
/// scope + early-access gate are in place.
class PortalLandingScreen extends StatelessWidget {
  const PortalLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // Auth gate: this is the patient surface. A clinician must never
    // browse into it from a logged-in session — that would let them
    // see (and eventually trigger) patient-facing DSAR / account
    // deletion controls on a patient's behalf. Sprint 10 added
    // `UserRole.patient` to the model layer (see `auth_models.dart`);
    // Sprint 11 will land a separate Patient auth scope and surface
    // the role explicitly. For now we keep the simpler rule: any
    // active clinician session is denied; the absence of one means
    // the visitor is either an authenticated patient (Sprint 11) or
    // an anonymous demo session.
    final clinicianProfile = FirebaseAuthService.instance.profile;
    if (clinicianProfile != null) {
      return _PortalAccessDenied(cs: cs, t: t);
    }

    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.portalTitle),
        backgroundColor: cs.surfaceContainerHigh,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PsySpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.portalWelcome, style: t.headlineSmall),
                  const SizedBox(height: 6),
                  Text(l.portalIntro, style: t.bodyMedium),
                  const SizedBox(height: PsySpacing.lg),
                  _PortalCard(
                    icon: Icons.assignment_outlined,
                    title: l.portalIntakeTitle,
                    body: l.portalIntakeBody,
                    rightLabel: 'GDPR Art. 7',
                    onTap: null,
                  ),
                  _PortalCard(
                    icon: Icons.assessment_outlined,
                    title: l.portalPromTitle,
                    body: l.portalPromBody,
                    rightLabel: 'Clinician-driven',
                    onTap: null,
                  ),
                  _PortalCard(
                    icon: Icons.event_outlined,
                    title: l.portalSessionsTitle,
                    body: l.portalSessionsBody,
                    rightLabel: 'Calendar',
                    onTap: null,
                  ),
                  _PortalCard(
                    icon: Icons.download_outlined,
                    title: l.portalDsarTitle,
                    body: l.portalDsarBody,
                    rightLabel: 'GDPR Art. 15 / 20 · KVKK Md. 11',
                    onTap: null,
                  ),
                  _PortalCard(
                    icon: Icons.delete_outline,
                    title: l.portalDeleteTitle,
                    body: l.portalDeleteBody,
                    rightLabel: 'GDPR Art. 17',
                    onTap: null,
                  ),
                  const SizedBox(height: PsySpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(PsySpacing.md),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(PsyRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: cs.onSecondaryContainer,
                        ),
                        const SizedBox(width: PsySpacing.sm),
                        Expanded(
                          child: Text(
                            l.portalSecurityFooter,
                            style: t.bodySmall?.copyWith(
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalAccessDenied extends StatelessWidget {
  const _PortalAccessDenied({required this.cs, required this.t});
  final ColorScheme cs;
  final TextTheme t;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your portal'),
        backgroundColor: cs.surfaceContainerHigh,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(PsySpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_person_outlined, size: 56, color: cs.primary),
                  const SizedBox(height: PsySpacing.md),
                  Text(
                    'This page is the patient portal',
                    style: t.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: PsySpacing.sm),
                  Text(
                    'You are signed in with a clinician account. The '
                    'patient portal is only available to the patient '
                    'themselves, on their own session, so a clinician '
                    'cannot trigger DSAR or account-deletion controls '
                    'on a patient\'s behalf.',
                    style: t.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: PsySpacing.lg),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushReplacementNamed('/dashboard'),
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Back to dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.rightLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String rightLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: PsySpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: cs.primary),
        title: Text(title, style: t.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body, style: t.bodySmall),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(PsyRadius.sm),
          ),
          child: Text(
            rightLabel,
            style: t.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
