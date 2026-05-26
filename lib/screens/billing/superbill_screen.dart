import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/billing/cpt_lookup_service.dart';
import '../../services/billing/icd10_lookup_service.dart';
import '../../services/billing/superbill_pdf_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_repository.dart';
import '../../services/data/superbill_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../widgets/app_shell.dart';

/// Builds a superbill (CPT + ICD-10 + provider + patient) and renders/prints
/// the PDF. Material 3 design, two-column on wide layouts.
class SuperbillScreen extends StatefulWidget {
  const SuperbillScreen({super.key});

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
      text: 'PSY-${DateTime.now().millisecondsSinceEpoch ~/ 1000}');
  DateTime _serviceDate = DateTime.now();

  final List<Icd10Code> _diagnoses = [];
  final List<ServiceLine> _lines = [];

  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _diagnoses.add(_icdService.byCode('F41.1')!);
    _diagnoses.add(_icdService.byCode('F32.1')!);
    final cpt = _cptService.byCode('90834')!;
    _lines.add(ServiceLine(
      date: _serviceDate,
      cpt: cpt,
      units: 1,
      chargePerUnit: cpt.nationalAverageUsd,
      diagnosisPointers: const [1],
    ));
  }

  @override
  void dispose() {
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
      TelemetryService.instance.capture(TelemetryEvents.superbillGenerated,
          properties: {'lines': _lines.length, 'dx': _diagnoses.length});
      await _persistToFirestore(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
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
    } catch (_) {
      // Local PDF already delivered — persistence best-effort.
    }
  }

  String _slug(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(
          RegExp(r'(^-|-$)'), '');

  Future<void> _pickDiagnosis() async {
    final picked = await showDialog<Icd10Code>(
      context: context,
      builder: (_) => _DiagnosisPicker(service: _icdService),
    );
    if (picked != null && !_diagnoses.any((d) => d.code == picked.code)) {
      setState(() => _diagnoses.add(picked));
    }
  }

  Future<void> _pickCptForLine() async {
    final picked = await showDialog<CptCode>(
      context: context,
      builder: (_) => _CptPicker(service: _cptService),
    );
    if (picked != null) {
      setState(() {
        _lines.add(ServiceLine(
          date: _serviceDate,
          cpt: picked,
          units: 1,
          chargePerUnit: picked.nationalAverageUsd,
          diagnosisPointers: const [1],
        ));
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
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.picture_as_pdf, size: 20),
        label: Text(_generating ? 'Generating…' : 'Generate PDF'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      scrollable: false,
      child: LayoutBuilder(
        builder: (ctx, c) {
          final wide = c.maxWidth > 980;
          return ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              _InvoiceMetaCard(
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
    return _SectionCard(
      title: 'Provider',
      cs: cs,
      theme: theme,
      child: Column(
        children: [
          _Field(controller: _providerName, label: 'Full name'),
          _Field(controller: _providerCreds, label: 'Credentials (e.g. LCSW, PhD)'),
          Row(children: [
            Expanded(child: _Field(controller: _providerNpi, label: 'NPI')),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _Field(controller: _providerTaxId, label: 'Tax ID / EIN')),
          ]),
          Row(children: [
            Expanded(child: _Field(controller: _providerPhone, label: 'Phone')),
            const SizedBox(width: 12),
            Expanded(child: _Field(controller: _providerEmail, label: 'Email')),
          ]),
          _Field(controller: _providerAddr, label: 'Address line 1'),
          _Field(controller: _providerAddr2, label: 'Address line 2'),
        ],
      ),
    );
  }

  Widget _buildPatientCard(ThemeData theme, ColorScheme cs) {
    return _SectionCard(
      title: 'Patient',
      cs: cs,
      theme: theme,
      child: Column(
        children: [
          _Field(controller: _patientName, label: 'Full name'),
          Row(children: [
            Expanded(
              child: _DateField(
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
                child:
                    _Field(controller: _patientMemberId, label: 'Member ID')),
          ]),
          _Field(controller: _patientInsurer, label: 'Insurer'),
          _Field(controller: _patientAddr, label: 'Address line 1'),
          _Field(controller: _patientAddr2, label: 'Address line 2'),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(ThemeData theme, ColorScheme cs) {
    return _SectionCard(
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
                    color: cs.onSurface.withValues(alpha: 0.55)),
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
                        child: Text('$idx',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(dx.code,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.primary,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(dx.label,
                              style: theme.textTheme.bodyMedium)),
                      IconButton(
                        tooltip: 'Remove',
                        icon: Icon(Icons.close,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.5)),
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
    return _SectionCard(
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
              child: Text('No service lines yet. Add a CPT code.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55))),
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(line.cpt.code,
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.primary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.cpt.shortLabel,
                              style: theme.textTheme.bodyMedium),
                          Text(
                            '${line.units} unit · ${DateFormat('yyyy-MM-dd').format(line.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text('\$${line.totalCharge.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: Icon(Icons.close,
                          size: 18,
                          color: cs.onSurface.withValues(alpha: 0.5)),
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
                  Text('Total: ',
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(width: 8),
                  Text('\$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.cs,
    required this.theme,
    this.trailing,
  });

  final String title;
  final Widget child;
  final ColorScheme cs;
  final ThemeData theme;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
        child: InkWell(
          onTap: onPick,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null
                      ? '—'
                      : DateFormat('yyyy-MM-dd').format(value!),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceMetaCard extends StatelessWidget {
  const _InvoiceMetaCard({
    required this.cs,
    required this.theme,
    required this.invoiceNumber,
    required this.serviceDate,
    required this.onPickDate,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final TextEditingController invoiceNumber;
  final DateTime serviceDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.4),
            cs.primaryContainer.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Superbill Draft',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Out-of-network insurance reimbursement receipt. '
                  'Provider must verify codes before submission.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 220,
            child: Column(
              children: [
                _Field(controller: invoiceNumber, label: 'Invoice #'),
                _DateField(
                  label: 'Service date',
                  value: serviceDate,
                  onPick: onPickDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosisPicker extends StatefulWidget {
  const _DiagnosisPicker({required this.service});
  final Icd10LookupService service;

  @override
  State<_DiagnosisPicker> createState() => _DiagnosisPickerState();
}

class _DiagnosisPickerState extends State<_DiagnosisPicker> {
  String _query = '';
  late List<Icd10Code> _results = widget.service.all();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 540,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick ICD-10 diagnosis',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() {
                  _query = v;
                  _results = widget.service.search(v);
                }),
                decoration: InputDecoration(
                  hintText: 'Search by code, label, or synonym…',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text('No diagnoses match "$_query"',
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.5))),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: cs.outlineVariant, height: 1),
                        itemBuilder: (_, i) {
                          final c = _results[i];
                          return ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(c.code,
                                  style: TextStyle(
                                      color: cs.primary,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ),
                            title: Text(c.label,
                                style: Theme.of(context).textTheme.bodyMedium),
                            subtitle: Text(c.category.label,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurface
                                        .withValues(alpha: 0.55))),
                            onTap: () => Navigator.of(context).pop(c),
                          );
                        },
                      ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CptPicker extends StatefulWidget {
  const _CptPicker({required this.service});
  final CptLookupService service;

  @override
  State<_CptPicker> createState() => _CptPickerState();
}

class _CptPickerState extends State<_CptPicker> {
  CptCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final codes = _filter == null
        ? widget.service.all()
        : widget.service.byCategory(_filter!);
    return Dialog(
      child: SizedBox(
        width: 620,
        height: 580,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick CPT code',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final c in CptCategory.values)
                    FilterChip(
                      label: Text(c.label),
                      selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: codes.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: cs.outlineVariant, height: 1),
                  itemBuilder: (_, i) {
                    final c = codes[i];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(c.code,
                            style: TextStyle(
                                color: cs.primary,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                      title: Text(c.shortLabel),
                      subtitle: Text(
                          '${c.typicalDurationMinutes} min · \$${c.nationalAverageUsd.toStringAsFixed(0)} avg'),
                      onTap: () => Navigator.of(context).pop(c),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
