/// H3 — pins the analytics + error-routing contract for consent
/// flows. The taxonomy below is consumed by:
///   * Sentry alert routes ("kvkk.*audit_failed" pages the on-call),
///   * PostHog funnels ("kvkk_acik_riza.signed" anchors KVKK-md.6
///     conversion dashboards),
///   * the SIEM correlation rule that joins `audit_log.appended`
///     breadcrumbs against the forensic AuditLogRepository.
///
/// Renaming any pinned event or property silently breaks one of
/// those downstream consumers — so every rename must trip CI here
/// first and force the rename to be coordinated.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/services/data/audit_log_repository.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';
import 'package:psyclinicai/services/data/telemetry_service.dart';
import 'package:psyclinicai/widgets/consent/kvkk_intake_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ThrowingAuditRepo extends AuditLogRepository {
  _ThrowingAuditRepo()
    : super(
        storageBucket:
            'throwing_audit_${DateTime.now().microsecondsSinceEpoch}',
      );

  @override
  Future<AuditLogEntry> append(AuditLogEntry entry) async {
    throw StateError('forced audit failure for contract test');
  }
}

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final captured = <({String event, Map<String, Object?> properties})>[];
  final errors = <({Object error, String? hint})>[];

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    InMemoryConsentEntryRepository.instance.clearForTesting();
    final bucket =
        'telemetry_contract_${DateTime.now().microsecondsSinceEpoch}';
    AuditLogRepository.setInstanceForTest(
      AuditLogRepository(storageBucket: bucket),
    );
    captured.clear();
    errors.clear();
    TelemetryService.captureRecorderForTest = (event, props) {
      captured.add((event: event, properties: Map.of(props)));
    };
    TelemetryService.errorRecorderForTest = (error, stack, hint) {
      errors.add((error: error, hint: hint));
    };
  });

  tearDown(() {
    TelemetryService.captureRecorderForTest = null;
    TelemetryService.errorRecorderForTest = null;
    AuditLogRepository.setInstanceForTest(null);
  });

  Future<void> driveKvkkSign(WidgetTester tester) async {
    final boxes = find.byType(CheckboxListTile);
    await tester.tap(boxes.first);
    await tester.pump();
    await tester.tap(boxes.last);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Demo Hasta');
    await tester.pump();
    await tester.tap(find.byKey(const Key('kvkkAcikRiza.submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('kvkk_acik_riza.signed carries exactly {policy_version}', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const KvkkIntakeSlot(
          patientId: 'pat-tel',
          patientName: 'Demo',
          policyVersion: 'kvkk-aydinlatma-v2026.06',
        ),
      ),
    );
    await tester.pump();
    await driveKvkkSign(tester);

    final signed = captured
        .where((e) => e.event == 'kvkk_acik_riza.signed')
        .toList(growable: false);
    expect(signed, hasLength(1), reason: 'Event name must stay stable.');
    expect(
      signed.first.properties.keys.toSet(),
      {'policy_version'},
      reason:
          'Property keys are part of the analytics contract — add new '
          'keys behind a deliberate dashboard migration, not silently.',
    );
    expect(
      signed.first.properties['policy_version'],
      'kvkk-aydinlatma-v2026.06',
      reason: 'policy_version pins the aydınlatma metni revision.',
    );

    // PHI guard — patient identifiers must never ride a funnel event.
    for (final entry in captured) {
      expect(
        entry.properties.values.whereType<String>(),
        isNot(contains('pat-tel')),
        reason: 'patient_id leaked into funnel telemetry — PHI guard.',
      );
      expect(
        entry.properties.values.whereType<String>(),
        isNot(contains('Demo Hasta')),
        reason: 'patient name leaked into funnel telemetry — PHI guard.',
      );
    }
  });

  testWidgets('audit_log.appended carries exactly {kind, result}', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const KvkkIntakeSlot(
          patientId: 'pat-tel2',
          patientName: 'Demo',
          policyVersion: 'kvkk-aydinlatma-v2026.06',
        ),
      ),
    );
    await tester.pump();
    await driveKvkkSign(tester);

    final appended = captured
        .where((e) => e.event == 'audit_log.appended')
        .toList(growable: false);
    expect(
      appended,
      isNotEmpty,
      reason:
          'AuditLogRepository.append must emit `audit_log.appended` so '
          'the SIEM rule can correlate funnel + forensic streams.',
    );
    for (final row in appended) {
      expect(
        row.properties.keys.toSet(),
        {'kind', 'result'},
        reason:
            'audit_log.appended schema is `{kind, result}` — no `id`, '
            '`entity`, or `actor` (all carry PHI risk).',
      );
      expect(row.properties['kind'], 'consent');
      expect(row.properties['result'], 'success');
    }
  });

  testWidgets(
    'audit append failure routes through hint `kvkk.consent_granted.audit_failed`',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      AuditLogRepository.setInstanceForTest(_ThrowingAuditRepo());

      await tester.pumpWidget(
        _host(
          const KvkkIntakeSlot(
            patientId: 'pat-fail',
            patientName: 'Demo',
            policyVersion: 'kvkk-aydinlatma-v2026.06',
          ),
        ),
      );
      await tester.pump();
      await driveKvkkSign(tester);

      final hints = errors.map((e) => e.hint).toSet();
      expect(
        hints,
        contains('kvkk.consent_granted.audit_failed'),
        reason:
            'A throwing audit append must surface via the pinned hint so '
            'Sentry alert routing + on-call paging stays consistent.',
      );
    },
  );
}
