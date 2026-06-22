import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/firestore_schema.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/profile` — clinician profile editor.
///
/// Captures the fields that flow into the superbill (full name, NPI,
/// tax id, credentials) plus the licence information the dashboard uses
/// to warn the clinician before a credential lapses. Identity fields
/// (`email`, `role`) stay read-only — those go through admin tooling.
class ClinicianProfileScreen extends StatefulWidget {
  const ClinicianProfileScreen({super.key});

  @override
  State<ClinicianProfileScreen> createState() => _ClinicianProfileScreenState();
}

class _ClinicianProfileScreenState extends State<ClinicianProfileScreen> {
  final _fullName = TextEditingController();
  final _credentials = TextEditingController();
  final _npi = TextEditingController();
  final _taxId = TextEditingController();
  final _specialty = TextEditingController();
  final _licenseNumber = TextEditingController();
  DateTime? _licenseExpiry;
  bool _saving = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    final p = FirebaseAuthService.instance.profile;
    if (p != null) {
      _fullName.text = p.fullName;
      _credentials.text = p.credentials;
      _npi.text = p.npi;
      _taxId.text = p.taxId;
      _specialty.text = p.specialty;
      _licenseNumber.text = p.licenseNumber;
      _licenseExpiry = p.licenseExpiry;
    } else {
      _fullName.text = 'Dr. Jordan Demo';
      _credentials.text = 'PsyD';
      _npi.text = '1234567890';
      _taxId.text = '12-3456789';
      _specialty.text = 'Adult clinical psychology';
      _licenseNumber.text = 'PSY-DEMO-001';
      _licenseExpiry = DateTime.now().add(const Duration(days: 280));
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _credentials.dispose();
    _npi.dispose();
    _taxId.dispose();
    _specialty.dispose();
    _licenseNumber.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _licenseExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'License expiry',
    );
    if (picked != null) setState(() => _licenseExpiry = picked);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _status = null;
    });
    final result = await FirebaseAuthService.instance.updateProfile(
      fullName: _fullName.text.trim(),
      credentials: _credentials.text.trim(),
      npi: _npi.text.trim(),
      taxId: _taxId.text.trim(),
      specialty: _specialty.text.trim(),
      licenseNumber: _licenseNumber.text.trim(),
      licenseExpiry: _licenseExpiry,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _status = result.success
          ? 'Profile saved.'
          : result.error ?? 'Could not save profile.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = FirebaseAuthService.instance.profile;
    final expiringSoon = profile?.licenseExpiringSoon == true;

    return AppShell(
      routeName: '/settings',
      title: 'Profile',
      subtitle:
          'Identity, credentials, and license — flows into the '
          'superbill and audit log.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Profile', null),
      ],
      primaryAction: FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save profile'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (profile == null) ...[
            PsyCard(
              tinted: true,
              child: Text(
                'Showing demo credentials — sign in to load your live '
                'profile. Edits below are not persisted in demo mode.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
            const SizedBox(height: PsySpacing.xl),
          ] else ...[
            PsyCard(
              tinted: true,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primary,
                    child: Icon(Icons.person, color: cs.onPrimary, size: 24),
                  ),
                  const SizedBox(width: PsySpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.email,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Role: ${profile.role.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (expiringSoon)
                    const PsyBadge(
                      label: 'License expiring',
                      tone: PsyBadgeTone.warning,
                    ),
                ],
              ),
            ),
            const SizedBox(height: PsySpacing.xl),
          ],
          _section(theme, 'Identity'),
          PsyCard(
            child: Column(
              children: [
                _field(
                  'Full legal name',
                  _fullName,
                  hint: 'Appears on superbills and PDF exports',
                ),
                _field(
                  'Credentials',
                  _credentials,
                  hint: 'e.g. LCSW, PsyD, MD',
                ),
                _field(
                  'Specialty / modalities',
                  _specialty,
                  hint: 'e.g. CBT, EMDR, trauma-focused',
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          _section(theme, 'Billing'),
          PsyCard(
            child: Column(
              children: [
                _field(
                  'NPI',
                  _npi,
                  hint: '10-digit US National Provider Identifier',
                ),
                _field('Tax ID', _taxId, hint: 'Employer or individual SSN'),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          _section(theme, 'License'),
          PsyCard(
            child: Column(
              children: [
                _field(
                  'License number',
                  _licenseNumber,
                  hint: 'State / national identifier',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
                  child: InkWell(
                    onTap: _pickExpiry,
                    borderRadius: BorderRadius.circular(PsyRadius.md),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'License expiry',
                        border: OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      child: Text(
                        _licenseExpiry == null
                            ? 'Tap to pick'
                            : '${_licenseExpiry!.year}-${_licenseExpiry!.month.toString().padLeft(2, '0')}-'
                                  '${_licenseExpiry!.day.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                if (expiringSoon)
                  Padding(
                    padding: const EdgeInsets.only(top: PsySpacing.sm),
                    child: Text(
                      'License expires within 60 days. Renew and update '
                      'this field before continuing to bill.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: PsySpacing.lg),
            Container(
              padding: const EdgeInsets.all(PsySpacing.md),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(PsyRadius.md),
                border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
              ),
              child: Text(
                _status!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
          const SizedBox(height: PsySpacing.huge),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme, String title) => Padding(
    padding: const EdgeInsets.only(bottom: PsySpacing.sm),
    child: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget _field(
    String label,
    TextEditingController c, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
