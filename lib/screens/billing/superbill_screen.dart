import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/denial_risk.dart';
import '../../models/superbill_prefill.dart';
import '../../services/billing/cpt_lookup_service.dart';
import '../../services/billing/denial_shield_service.dart';
import '../../services/billing/icd10_lookup_service.dart';
import '../../services/billing/superbill_pdf_service.dart';
import '../../services/copilot/compliance_check_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_repository.dart';
import '../../services/data/superbill_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../widgets/app_shell.dart';
import 'superbill_chrome.dart';
import 'superbill_denial_card.dart';
import 'superbill_pickers.dart';

/// Builds a superbill (CPT + ICD-10 + provider + patient) and renders/prints
/// the PDF. Material 3 design, two-column on wide layouts.
class SuperbillScreen extends StatefulWidget {
  const SuperbillScreen({super.key, this.prefill});

  /// Optional billing hints extracted from a session note (diagnosis + CPT).
  /// When present, the form starts from these instead of demo defaults.
  final SuperbillPrefill? prefill;

  @override
  State<SuperbillScreen> createState() => _SuperbillScreenState();
}

class _SuperbillScreenState extends State<SuperbillScreen> {
  final _pdfService = SuperbillPdfService();
  final _icdService = Icd10LookupService.instance;
  final _cptService = CptLookupService.instance;

  // Provider (defaults are demo data — clinician overwrites)
  final _providerName = TextEditingController(text: 'Dr. Sarah Johnson');
  final _providerCreds = TextEditingController(text: 'LCSW, PhD');
  final _providerNpi = TextEditingController(text: '1234567890');
  final _providerTaxId = TextEditingController(text: '12-3456789');
  final _providerPhone = TextEditingController(text: '+1 (555) 123-4567');
  final _providerEmail = TextEditingController(text: 'sarah@example.com');
  final _providerAddr = TextEditingController(text: '500 5th Ave, Suite 200');
  final _providerAddr2 = TextEditingController(text: 'New York, NY 10110');

  // Patient
  final _patientName = TextEditingController(text: 'John Demo');
  final _patientMemberId = TextEditingController(text: 'BCBS-INS-001');
  final _patientInsurer = TextEditingController(text: 'Blue Cross Blue Shield');
  DateTime? _patientDob = DateTime(1989, 5, 14);
  final _patientAddr = TextEditingController(text: '123 Main St, Apt 4B');
  final _patientAddr2 = TextEditingController(text: 'New York, NY 10001');

  // Invoice
  final _invoiceNumber = TextEditingController(
    text: 'PSY-${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
  );
  DateTime _serviceDate = DateTime.now();

  final List<Icd10Code> _diagnoses = [];
  final List<ServiceLine> _lines = [];

  bool _generating = false;

  // Denial Shield — computed when launched from a session note.
  final _compliance = ComplianceCheckService();
  Payer _payer = Payer.medicare;
  DenialRisk? _denial;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;

    // Patient + service date from the note, when provided.
    if (prefill?.patientName != null && prefill!.patientName!.isNotEmpty) {
      _patientName.text = prefill.patientName!;
    }
    if (prefill?.serviceDate != null) _serviceDate = prefill!.serviceDate!;

    // Diagnoses: resolve documented ICD-10 codes; fall back to demo defaults.
    final resolved = <Icd10Code>[];
    for (final code in prefill?.icd10Codes ?? const <String>[]) {
      final icd = _icdService.byCode(code);
      if (icd != null) resolved.add(icd);
    }
    if (resolved.isNotEmpty) {
      _diagnoses.addAll(resolved);
    } else {
      _diagnoses.add(_icdService.byCode('F41.1')!);
      _diagnoses.add(_icdService.byCode('F32.1')!);
    }

    // Service line: suggested CPT from the note, else the 90834 default.
    final cpt =
        (prefill?.cptCode != null
            ? _cptService.byCode(prefill!.cptCode!)
            : null) ??
        _cptService.byCode('90834')!;
    _lines.add(
      ServiceLine(
        date: _serviceDate,
        cpt: cpt,
        units: 1,
        chargePerUnit: cpt.nationalAverageUsd,
      ),
    );
    _computeDenial();
  }

  /// Runs the Denial Shield for the first service line against the source note
  /// (present only when launched from a session) + selected payer.
  void _computeDenial() {
    final note = widget.prefill?.noteText;
    if (note == null || note.trim().isEmpty || _lines.isEmpty) {
      _denial = null;
      return;
    }
    final audit = _compliance.check(note, hasActivePlan: true);
    _denial = const DenialShieldService().assess(
      note: note,
      cptCode: _lines.first.cpt.code,
      payer: _payer,
      audit: audit,
    );
  }

  Future<bool?> _confirmHighRisk() {
    final d = _denial!;
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.verified_user_outlined, color: cs.error),
        title: const Text('High denial risk'),
        content: Text(
          '${_payer.short} is likely to deny this ${d.cptCode} claim'
          '${d.revenueAtRisk != null ? ' (~\$${d.revenueAtRisk!.round()})' : ''}'
          '${d.reasons.isNotEmpty ? ': ${d.reasons.first.title}.' : '.'} '
          'Fix the note first, or generate anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Go back & fix'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Generate anyway'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _compliance.dispose();
    for (final c in [
      _providerName,
      _providerCreds,
      _providerNpi,
      _providerTaxId,
      _providerPhone,
      _providerEmail,
      _providerAddr,
      _providerAddr2,
      _patientName,
      _patientMemberId,
      _patientInsurer,
      _patientAddr,
      _patientAddr2,
      _invoiceNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _generate() async {
    // Denial Shield gate: warn before billing a high-risk claim.
    if (_denial?.level == DenialLevel.high) {
      final proceed = await _confirmHighRisk();
      if (proceed != true) return;
    }
    setState(() => _generating = true);
    try {
      final data = SuperbillData(
        invoiceNumber: _invoiceNumber.text.trim(),
        issuedAt: DateTime.now(),
        serviceDate: _serviceDate,
        provider: ProviderInfo(
          fullName: _providerName.text.trim(),
          credentials: _providerCreds.text.trim(),
          npi: _providerNpi.text.trim(),
          taxId: _providerTaxId.text.trim(),
          phone: _providerPhone.text.trim(),
          email: _providerEmail.text.trim(),
          addressLine1: _providerAddr.text.trim(),
          addressLine2: _providerAddr2.text.trim(),
        ),
        patient: PatientInfo(
          fullName: _patientName.text.trim(),
          dob: _patientDob,
          memberId: _patientMemberId.text.trim(),
          insurer: _patientInsurer.text.trim(),
          addressLine1: _patientAddr.text.trim(),
          addressLine2: _patientAddr2.text.trim(),
        ),
        diagnoses: List.of(_diagnoses),
        serviceLines: List.of(_lines),
      );
      await _pdfService.printOrShare(data);
      unawaited(
        TelemetryService.instance.capture(
          TelemetryEvents.superbillGenerated,
          properties: {'lines': _lines.length, 'dx': _diagnoses.length},
        ),
      );
      await _persistToFirestore(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _persistToFirestore(SuperbillData data) async {
    if (!PsyFirebase.isReady) return;
    final auth = FirebaseAuthService.instance;
    final profile = auth.profile;
    if (profile == null) return;
    try {
      final patientId = _slug(data.patient.fullName);
      await PatientRepository.instance.upsert(
        profile.clinicId,
        patientId,
        PatientDraft(
          fullName: data.patient.fullName,
          memberId: data.patient.memberId,
          insurer: data.patient.insurer,
          dob: data.patient.dob,
          addressLine1: data.patient.addressLine1,
          addressLine2: data.patient.addressLine2,
        ),
      );
      await SuperbillRepository.instance.save(
        clinicId: profile.clinicId,
        patientId: patientId,
        clinicianId: profile.userId,
        data: data,
      );
    } catch (e, st) {
      // Local PDF already delivered — persistence best-effort. We
      // still capture so a quietly-broken Firestore write surface
      // doesn't go undiagnosed; the clinician sees no UI change.
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'superbill.firestore_persist',
        ),
      );
    }
  }

  String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'(^-|-$)'), '');

  Future<void> _pickDiagnosis() async {
    final picked = await showDialog<Icd10Code>(
      context: context,
      builder: (_) => DiagnosisPicker(service: _icdService),
    );
    if (picked != null && !_diagnoses.any((d) => d.code == picked.code)) {
      setState(() => _diagnoses.add(picked));
    }
  }

  Future<void> _pickCptForLine() async {
    final picked = await showDialog<CptCode>(
      context: context,
      builder: (_) => CptPicker(service: _cptService),
    );
    if (picked != null) {
      setState(() {
        _lines.add(
          ServiceLine(
            date: _serviceDate,
            cpt: picked,
            units: 1,
            chargePerUnit: picked.nationalAverageUsd,
          ),
        );
      });
    }
  }

  Future<void> _pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _serviceDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/superbill',
      title: 'Superbill',
      subtitle: 'CPT + ICD-10 picker, CMS-1500-aligned PDF.',
      primaryAction: FilledButton.icon(
        onPressed: _generating ? null : _generate,
        icon: _generating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.picture_as_pdf, size: 20),
        label: Text(_generating ? 'Generating…' : 'Generate PDF'),
        style: FilledButton.styleFrom(
          // Tighter than the dashboard "New session" CTA — PDF generation
          // is the primary action here but it shouldn't dominate the
          // header band on a 390-wide phone.
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      scrollable: false,
      child: LayoutBuilder(
        builder: (ctx, c) {
          final wide = c.maxWidth > 980;
          return ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              if (_denial != null) ...[
                DenialShieldCard(
                  denial: _denial!,
                  payer: _payer,
                  onPayerChanged: (p) => setState(() {
                    _payer = p;
                    _computeDenial();
                  }),
                  theme: theme,
                  cs: cs,
                ),
                const SizedBox(height: 16),
              ],
              InvoiceMetaCard(
                cs: cs,
                theme: theme,
                invoiceNumber: _invoiceNumber,
                serviceDate: _serviceDate,
                onPickDate: _pickServiceDate,
              ),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildProviderCard(theme, cs)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPatientCard(theme, cs)),
                  ],
                )
              else ...[
                _buildProviderCard(theme, cs),
                const SizedBox(height: 16),
                _buildPatientCard(theme, cs),
              ],
              const SizedBox(height: 16),
              _buildDiagnosisCard(theme, cs),
              const SizedBox(height: 16),
              _buildServiceLinesCard(theme, cs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProviderCard(ThemeData theme, ColorScheme cs) {
    return SectionCard(
      title: 'Provider',
      cs: cs,
      theme: theme,
      child: Column(
        children: [
          SuperbillField(controller: _providerName, label: 'Full name'),
          SuperbillField(
            controller: _providerCreds,
            label: 'Credentials (e.g. LCSW, PhD)',
          ),
          Row(
            children: [
              Expanded(
                child: SuperbillField(controller: _providerNpi, label: 'NPI'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SuperbillField(
                  controller: _providerTaxId,
                  label: 'Tax ID / EIN',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SuperbillField(
                  controller: _providerPhone,
                  label: 'Phone',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SuperbillField(
                  controller: _providerEmail,
                  label: 'Email',
                ),
              ),
            ],
          ),
          SuperbillField(controller: _providerAddr, label: 'Address line 1'),
          SuperbillField(controller: _providerAddr2, label: 'Address line 2'),
        ],
      ),
    );
  }

  Widget _buildPatientCard(ThemeData theme, ColorScheme cs) {
    return SectionCard(
      title: 'Patient',
      cs: cs,
      theme: theme,
      child: Column(
        children: [
          SuperbillField(controller: _patientName, label: 'Full name'),
          Row(
            children: [
              Expanded(
                child: SuperbillDateField(
                  label: 'Date of birth',
                  value: _patientDob,
                  onPick: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _patientDob ?? DateTime(1990),
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _patientDob = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SuperbillField(
                  controller: _patientMemberId,
                  label: 'Member ID',
                ),
              ),
            ],
          ),
          SuperbillField(controller: _patientInsurer, label: 'Insurer'),
          SuperbillField(controller: _patientAddr, label: 'Address line 1'),
          SuperbillField(controller: _patientAddr2, label: 'Address line 2'),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(ThemeData theme, ColorScheme cs) {
    return SectionCard(
      title: 'Diagnoses',
      trailing: TextButton.icon(
        onPressed: _pickDiagnosis,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add ICD-10'),
      ),
      cs: cs,
      theme: theme,
      child: _diagnoses.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No diagnoses yet. Add an ICD-10 code to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            )
          : Column(
              children: _diagnoses.asMap().entries.map((e) {
                final idx = e.key + 1;
                final dx = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$idx',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dx.code,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dx.label,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        onPressed: () =>
                            setState(() => _diagnoses.removeAt(e.key)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildServiceLinesCard(ThemeData theme, ColorScheme cs) {
    final total = _lines.fold<double>(0, (s, l) => s + l.totalCharge);
    return SectionCard(
      title: 'Service lines',
      trailing: TextButton.icon(
        onPressed: _pickCptForLine,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add CPT'),
      ),
      cs: cs,
      theme: theme,
      child: Column(
        children: [
          if (_lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No service lines yet. Add a CPT code.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            )
          else
            ..._lines.asMap().entries.map((e) {
              final i = e.key;
              final line = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        line.cpt.code,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.primary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.cpt.shortLabel,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${line.units} unit · ${DateFormat('yyyy-MM-dd').format(line.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '\$${line.totalCharge.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () => setState(() => _lines.removeAt(i)),
                    ),
                  ],
                ),
              );
            }),
          if (_lines.isNotEmpty) ...[
            Divider(color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: ',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Layout widgets (SectionCard / SuperbillField / SuperbillDateField /
// InvoiceMetaCard) moved to superbill_chrome.dart.
// DiagnosisPicker + CptPicker moved to superbill_pickers.dart.
// (HIGH-4 god-file split, audit 2026-06-21.)
