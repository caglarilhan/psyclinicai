/// Section slot used inside the intake form (and any other host that
/// captures KVKK md. 6 açık rıza). Wraps [KvkkAcikRizaForm] in a
/// PsyCard, collapses to a confirmation tile once signed, and writes
/// the signed [ConsentEntry] into [InMemoryConsentEntryRepository]
/// on submit.
///
/// Lifted out of [IntakeFormScreen] so widget tests can exercise the
/// sign + collapse contract without dragging in the full intake
/// form's repository + Provider chain.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/audit_log_entry.dart';
import '../../models/consent_entry.dart';
import '../../services/data/audit_log_repository.dart';
import '../../services/data/consent_entry_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../ds/psy_card.dart';
import '../ds/psy_snack.dart';
import 'kvkk_acik_riza_form.dart';

class KvkkIntakeSlot extends StatefulWidget {
  const KvkkIntakeSlot({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.policyVersion,
    this.initiallySigned = false,
    this.onSigned,
  });

  final String patientId;
  final String patientName;

  /// Aydınlatma metni revision the form is anchored to; pinned in
  /// the audit trail.
  final String policyVersion;

  /// Whether the host already detected an active KVKK consent —
  /// renders the confirmation tile straight away when true.
  final bool initiallySigned;

  /// Fired after the host persists the signed [ConsentEntry] so the
  /// parent screen can flip any of its own flags. Optional.
  final VoidCallback? onSigned;

  @override
  State<KvkkIntakeSlot> createState() => _KvkkIntakeSlotState();
}

class _KvkkIntakeSlotState extends State<KvkkIntakeSlot> {
  late bool _signed = widget.initiallySigned;

  void _persist(ConsentEntry entry) {
    InMemoryConsentEntryRepository.instance.record(entry);
    setState(() => _signed = true);
    unawaited(
      TelemetryService.instance.capture(
        'kvkk_acik_riza.signed',
        properties: {'policy_version': entry.policyVersion},
      ),
    );
    // Audit trail entry — KVKK md. 12 + GDPR Art. 30 expect every
    // special-category consent action to be reconstructible. Telemetry
    // is for dashboards; the audit log is the forensic record.
    unawaited(_appendAuditEntry(entry));
    widget.onSigned?.call();
    if (!mounted) return;
    PsySnack.show(
      context,
      'KVKK md. 6 açık rıza kaydedildi.',
      level: PsySnackLevel.success,
      hint: 'kvkk.acik_riza.recorded',
    );
  }

  Future<void> _appendAuditEntry(ConsentEntry entry) async {
    try {
      final repo = AuditLogRepository.instance;
      await repo.initialize();
      await repo.append(
        AuditLogEntry(
          id: 'audit-kvkk-${entry.id}',
          kind: 'consent',
          action: 'kvkk.consent_granted',
          actor: widget.patientId,
          entity:
              'patient:${widget.patientId} '
              'entry:${entry.id} '
              'policy:${entry.policyVersion}',
          timestampUtc: DateTime.now().toUtc(),
          result: AuditResult.success,
        ),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'kvkk.consent_granted.audit_failed',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_signed) {
      return PsyCard(
        tinted: true,
        child: Padding(
          padding: const EdgeInsets.all(PsySpacing.md),
          child: Row(
            children: [
              Icon(Icons.verified_user, color: theme.colorScheme.primary),
              const SizedBox(width: PsySpacing.sm),
              Expanded(
                child: Text(
                  'Açık rıza imzalandı — KVKK md. 6 kapsamındaki sağlık '
                  "verisi işleme rızası audit trail'e kaydedildi.",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return PsyCard(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: KvkkAcikRizaForm(
          patientId: widget.patientId,
          patientName: widget.patientName,
          policyVersion: widget.policyVersion,
          onSign: _persist,
        ),
      ),
    );
  }
}
