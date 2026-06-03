import 'package:flutter/material.dart';

import '../../models/claim_submission.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/billing/claims` — ANSI X12 837P claim kanban.
class InsuranceClaimBoardScreen extends StatelessWidget {
  const InsuranceClaimBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final claims = _demoClaims();
    const lanes = [
      ClaimStatus.draft,
      ClaimStatus.submitted,
      ClaimStatus.accepted,
      ClaimStatus.denied,
      ClaimStatus.appealing,
      ClaimStatus.paid,
      ClaimStatus.writtenOff,
    ];
    final byStatus = <ClaimStatus, List<ClaimSubmission>>{};
    for (final lane in lanes) {
      byStatus[lane] = claims.where((c) => c.status == lane).toList();
    }
    return AppShell(
      routeName: '/billing/claims',
      title: 'Insurance claim board',
      subtitle: 'X12 837P submissions tracked through the payer '
          'lifecycle. Click a card to drill into the audit chain.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Billing', '/superbill'),
        Crumb('Claims', null),
      ],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final lane in lanes)
              _Lane(
                status: lane,
                claims: byStatus[lane] ?? const [],
                theme: theme,
                cs: cs,
              ),
          ],
        ),
      ),
    );
  }

  List<ClaimSubmission> _demoClaims() {
    final created = DateTime.utc(2026, 5, 28);
    return [
      ClaimSubmission(
        id: 'CLM-100',
        superbillId: 'INV-100',
        payerId: 'BCBS',
        subjectPatientId: 'demo-1',
        cptCodes: const ['90837'],
        icd10Codes: const ['F32.1'],
        amountCents: 14000,
        status: ClaimStatus.submitted,
        createdAt: created,
        submittedAt: created.add(const Duration(days: 1)),
      ),
      ClaimSubmission(
        id: 'CLM-101',
        superbillId: 'INV-101',
        payerId: 'Aetna',
        subjectPatientId: 'demo-2',
        cptCodes: const ['90834'],
        icd10Codes: const ['F33.1'],
        amountCents: 11000,
        status: ClaimStatus.denied,
        createdAt: created,
        submittedAt: created.add(const Duration(days: 1)),
        adjudicatedAt: created.add(const Duration(days: 7)),
        denialReasonCode: 'CO-50',
      ),
      ClaimSubmission(
        id: 'CLM-102',
        superbillId: 'INV-102',
        payerId: 'TK',
        subjectPatientId: 'demo-3',
        cptCodes: const ['90837', '90785'],
        icd10Codes: const ['F41.1'],
        amountCents: 16500,
        status: ClaimStatus.paid,
        createdAt: created,
        submittedAt: created.add(const Duration(days: 1)),
        adjudicatedAt: created.add(const Duration(days: 4)),
        refNumber: 'EOB-2026-0048',
      ),
      ClaimSubmission(
        id: 'CLM-103',
        superbillId: 'INV-103',
        payerId: 'BCBS',
        subjectPatientId: 'demo-1',
        cptCodes: const ['90791'],
        icd10Codes: const ['F32.0'],
        amountCents: 18000,
        status: ClaimStatus.draft,
        createdAt: created.add(const Duration(days: 5)),
      ),
    ];
  }
}

class _Lane extends StatelessWidget {
  const _Lane({
    required this.status,
    required this.claims,
    required this.theme,
    required this.cs,
  });
  final ClaimStatus status;
  final List<ClaimSubmission> claims;
  final ThemeData theme;
  final ColorScheme cs;

  PsyBadgeTone _tone() {
    switch (status) {
      case ClaimStatus.paid:
        return PsyBadgeTone.success;
      case ClaimStatus.denied:
        return PsyBadgeTone.danger;
      case ClaimStatus.appealing:
      case ClaimStatus.writtenOff:
        return PsyBadgeTone.warning;
      case ClaimStatus.draft:
      case ClaimStatus.submitted:
      case ClaimStatus.accepted:
        return PsyBadgeTone.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: PsySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
              child: Text(status.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            PsyBadge(label: '${claims.length}', tone: _tone()),
          ]),
          const SizedBox(height: PsySpacing.sm),
          for (final c in claims) ...[
            PsyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.id,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${c.payerId} · ${c.cptCodes.join(", ")}',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(c.amountCents / 100).toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: cs.primary),
                  ),
                  if (c.denialReasonCode != null) ...[
                    const SizedBox(height: 4),
                    Text('Denial · ${c.denialReasonCode}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.error)),
                  ],
                  if (c.refNumber != null) ...[
                    const SizedBox(height: 4),
                    Text('Ref · ${c.refNumber}',
                        style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PsySpacing.sm),
          ],
          if (claims.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: PsySpacing.lg),
              child: Text(
                'No ${status.label.toLowerCase()} claims.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}
