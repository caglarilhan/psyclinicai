import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/incident_severity.dart';
import 'package:psyclinicai/services/ops/incident_comms_templates.dart';

void main() {
  group('IncidentCommsTemplates — catalog invariants', () {
    test('catalog is non-empty', () {
      expect(IncidentCommsTemplates.entries, isNotEmpty);
    });

    test('every (severity, stage) pair is unique', () {
      final keys = IncidentCommsTemplates.entries
          .map((t) => '${t.severity.name}|${t.stage.name}')
          .toList();
      expect(
        keys.toSet().length,
        keys.length,
        reason: 'duplicate (severity, stage) pairs',
      );
    });

    test('byStage resolves every pinned entry + null for unpinned', () {
      for (final t in IncidentCommsTemplates.entries) {
        expect(IncidentCommsTemplates.byStage(t.severity, t.stage), same(t));
      }
      expect(
        IncidentCommsTemplates.byStage(
          IncidentSeverity.p4,
          IncidentLifecycleStage.acknowledged,
        ),
        isNull,
      );
    });

    test('P0 has acknowledged + identified + resolved templates', () {
      const required = [
        IncidentLifecycleStage.acknowledged,
        IncidentLifecycleStage.identified,
        IncidentLifecycleStage.resolved,
      ];
      for (final stage in required) {
        expect(
          IncidentCommsTemplates.byStage(IncidentSeverity.p0, stage),
          isNotNull,
          reason: 'P0 must have a pinned template for ${stage.name}',
        );
      }
    });

    test('every template has non-empty fields', () {
      for (final t in IncidentCommsTemplates.entries) {
        final key = '${t.severity.name}/${t.stage.name}';
        expect(t.statusPageHeadline, isNotEmpty, reason: key);
        expect(t.statusPageBody, isNotEmpty, reason: key);
        expect(t.emailSubject, isNotEmpty, reason: key);
        expect(t.emailBody, isNotEmpty, reason: key);
        expect(t.internalSummary, isNotEmpty, reason: key);
        expect(t.requiredPlaceholders, isNotEmpty, reason: key);
      }
    });
  });

  group('IncidentCommsTemplates — placeholder hygiene', () {
    test('every requiredPlaceholders entry appears somewhere in the copy', () {
      for (final t in IncidentCommsTemplates.entries) {
        final blob = [
          t.statusPageHeadline,
          t.statusPageBody,
          t.emailSubject,
          t.emailBody,
          t.internalSummary,
        ].join(' || ');
        final allTokens = placeholdersIn(blob).toSet();
        for (final required in t.requiredPlaceholders) {
          expect(
            allTokens,
            contains(required),
            reason:
                '${t.severity.name}/${t.stage.name}: required placeholder '
                '`$required` is declared but never appears in any rendered '
                'field — a copy edit dropped it.',
          );
        }
      }
    });

    test('public-facing copy uses no internal-only tokens', () {
      const internalOnly = [
        'commander',
        'ticket',
        'capa_id',
        'pm_owner',
        'eta_minutes',
      ];
      for (final t in IncidentCommsTemplates.entries) {
        final public = [
          t.statusPageHeadline,
          t.statusPageBody,
          t.emailSubject,
          t.emailBody,
        ].join(' || ');
        final tokens = placeholdersIn(public).toSet();
        for (final internal in internalOnly) {
          expect(
            tokens,
            isNot(contains(internal)),
            reason:
                '${t.severity.name}/${t.stage.name}: internal-only token '
                '`$internal` leaked into public-facing copy.',
          );
        }
      }
    });

    test('resolved-stage templates always carry resolved_at_utc', () {
      for (final t in IncidentCommsTemplates.entries.where(
        (t) => t.stage == IncidentLifecycleStage.resolved,
      )) {
        expect(
          t.requiredPlaceholders,
          contains('resolved_at_utc'),
          reason:
              '${t.severity.name}: resolved-stage template must declare '
              'resolved_at_utc.',
        );
      }
    });

    test('P0 resolved copy references the post-mortem publication path', () {
      final p0Resolved = IncidentCommsTemplates.byStage(
        IncidentSeverity.p0,
        IncidentLifecycleStage.resolved,
      )!;
      expect(p0Resolved.statusPageBody, contains('post-mortem'));
      expect(p0Resolved.statusPageBody, contains('5 working days'));
    });

    test(
      'pre-identified copy stays investigative — no premature fix claims',
      () {
        for (final t in IncidentCommsTemplates.entries.where(
          (t) =>
              t.stage == IncidentLifecycleStage.acknowledged ||
              t.stage == IncidentLifecycleStage.investigating,
        )) {
          final blob = [t.statusPageBody, t.emailBody].join(' ').toLowerCase();
          for (final banned in const ['fixed', 'resolved', 'over now']) {
            expect(
              blob,
              isNot(contains(banned)),
              reason:
                  '${t.severity.name}/${t.stage.name}: copy contains "$banned" '
                  'before identified — premature resolution claim.',
            );
          }
        }
      },
    );
  });

  group('placeholdersIn helper', () {
    test('extracts the inner token names', () {
      expect(
        placeholdersIn('hello {{world}} {{a_b_c}}').toList(),
        equals(['world', 'a_b_c']),
      );
    });

    test('ignores partial / malformed braces', () {
      expect(placeholdersIn('hi {single} or {{nope').toList(), isEmpty);
    });
  });
}
