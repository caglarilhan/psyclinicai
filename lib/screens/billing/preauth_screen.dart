import 'package:flutter/material.dart';

import '../../models/insurance_preauth.dart';
import '../../services/data/preauth_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/billing/preauth` — payer pre-authorisation list + new-request form.
///
/// Sprint 7 ships the UI on top of an in-memory repository so the
/// flow is testable end-to-end. Sprint 8 swaps the repo for a
/// Firestore-backed one and adds the payer webhook listener that
/// updates [PreAuthStatus] without manual entry.
class PreAuthScreen extends StatefulWidget {
  const PreAuthScreen({super.key, this.patientId = 'demo-1'});

  final String patientId;

  @override
  State<PreAuthScreen> createState() => _PreAuthScreenState();
}

class _PreAuthScreenState extends State<PreAuthScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/billing/preauth',
      title: 'Insurance pre-auth',
      subtitle: 'Track payer approvals before billing — request, status, '
          'reference numbers.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Billing', null),
        Crumb('Pre-auth', null),
      ],
      primaryAction: FilledButton.icon(
        onPressed: _openNewDialog,
        icon: const Icon(Icons.add),
        label: const Text('New request'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
        ),
      ),
      child: AnimatedBuilder(
        animation: PreAuthRepository.instance,
        builder: (context, _) {
          final entries =
              PreAuthRepository.instance.forPatient(widget.patientId);
          if (entries.isEmpty) {
            return _EmptyState(theme: theme, cs: cs);
          }
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: PsySpacing.sm),
            itemBuilder: (_, i) =>
                _PreAuthCard(entry: entries[i], theme: theme, cs: cs),
          );
        },
      ),
    );
  }

  Future<void> _openNewDialog() async {
    final created = await showDialog<InsurancePreAuth>(
      context: context,
      builder: (_) => _NewPreAuthDialog(patientId: widget.patientId),
    );
    if (created != null) {
      PreAuthRepository.instance.add(created);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(children: [
          Icon(Icons.fact_check_outlined,
              size: 44, color: cs.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: PsySpacing.md),
          Text('No pre-authorisation requests yet',
              style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: PsySpacing.xs),
          Text(
              'Tap "New request" once the payer has been called or the '
              'portal has been submitted.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55))),
        ]),
      ),
    );
  }
}

class _PreAuthCard extends StatelessWidget {
  const _PreAuthCard(
      {required this.entry, required this.theme, required this.cs});
  final InsurancePreAuth entry;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(entry.payer,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            _statusBadge(entry.status),
          ]),
          const SizedBox(height: PsySpacing.xs),
          _kv('Member', entry.memberId),
          _kv('Service code', entry.serviceCode),
          _kv('Units', entry.requestedUnits.toString()),
          if (entry.referenceNumber != null)
            _kv('Reference', entry.referenceNumber!),
          if (entry.expiresAt != null)
            _kv('Expires', _date(entry.expiresAt!)),
          if (entry.denialReason != null && entry.denialReason!.isNotEmpty)
            _kv('Denial reason', entry.denialReason!),
          const SizedBox(height: 2),
          Text('Submitted ${_date(entry.requestedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _statusBadge(PreAuthStatus s) {
    switch (s) {
      case PreAuthStatus.submitted:
        return const PsyBadge(label: 'Submitted', tone: PsyBadgeTone.info);
      case PreAuthStatus.approved:
        return const PsyBadge(label: 'Approved', tone: PsyBadgeTone.success);
      case PreAuthStatus.denied:
        return const PsyBadge(label: 'Denied', tone: PsyBadgeTone.danger);
      case PreAuthStatus.expired:
        return const PsyBadge(label: 'Expired', tone: PsyBadgeTone.warning);
    }
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 120,
              child: Text(k,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600))),
          Expanded(
              child: Text(v,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.88)))),
        ]),
      );

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _NewPreAuthDialog extends StatefulWidget {
  const _NewPreAuthDialog({required this.patientId});
  final String patientId;

  @override
  State<_NewPreAuthDialog> createState() => _NewPreAuthDialogState();
}

class _NewPreAuthDialogState extends State<_NewPreAuthDialog> {
  final _payer = TextEditingController();
  final _memberId = TextEditingController();
  final _serviceCode = TextEditingController(text: '90837');
  final _units = TextEditingController(text: '12');

  @override
  void dispose() {
    _payer.dispose();
    _memberId.dispose();
    _serviceCode.dispose();
    _units.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _payer.text.trim().isNotEmpty &&
      _memberId.text.trim().isNotEmpty &&
      _serviceCode.text.trim().isNotEmpty &&
      (int.tryParse(_units.text) ?? 0) > 0;

  void _submit() {
    if (!_canSubmit) return;
    final entry = InsurancePreAuth(
      id: 'pa-${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.patientId,
      payer: _payer.text.trim(),
      memberId: _memberId.text.trim(),
      serviceCode: _serviceCode.text.trim(),
      requestedUnits: int.parse(_units.text.trim()),
      status: PreAuthStatus.submitted,
      requestedAt: DateTime.now().toUtc(),
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New pre-auth request'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Payer', _payer, hint: 'e.g. Aetna, Techniker Krankenkasse'),
            _field('Member ID', _memberId, hint: 'As printed on the card'),
            _field('Service code (CPT)', _serviceCode,
                hint: '90837 = 60-min psychotherapy'),
            _field('Requested units / sessions', _units,
                keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c,
      {String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
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
