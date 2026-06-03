import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/email_template.dart';

void main() {
  group('EmailTemplate.render', () {
    EmailTemplate make(String body) => EmailTemplate(
          id: 't-1',
          kind: EmailTemplateKind.reminder24h,
          subject: 'See you tomorrow',
          bodyMarkdown: body,
        );

    test('substitutes known tokens', () {
      final out = make('Hi {{patient_first_name}}, see you at '
              '{{session_time}}.')
          .render({
        'patient_first_name': 'John',
        'session_time': '14:00',
      });
      expect(out, 'Hi John, see you at 14:00.');
    });

    test('unknown token surfaces as [unknown:name] so QA catches typos',
        () {
      final out = make('Hi {{patietn_first_name}}.').render({});
      expect(out, contains('[unknown:patietn_first_name]'));
    });

    test('missing value renders as empty string', () {
      final out = make('Hi {{patient_first_name}}').render({});
      expect(out, 'Hi ');
    });

    test('JSON round-trip preserves fields', () {
      final t = make('body').copyWith(enabled: false, abVariantId: 'B');
      final restored = EmailTemplate.fromJson(t.toJson());
      expect(restored.kind, EmailTemplateKind.reminder24h);
      expect(restored.enabled, isFalse);
      expect(restored.abVariantId, 'B');
    });
  });

  group('EmailSequence.isCanonicallyOrdered', () {
    test('true for monotonically increasing offsets', () {
      const seq = EmailSequence(
        id: 's-1',
        name: 'Appointment reminders',
        steps: [
          EmailSequenceStep(
            offset: Duration(hours: -72),
            kind: EmailTemplateKind.reminder72h,
          ),
          EmailSequenceStep(
            offset: Duration(hours: -24),
            kind: EmailTemplateKind.reminder24h,
          ),
          EmailSequenceStep(
            offset: Duration(hours: -2),
            kind: EmailTemplateKind.reminder2h,
          ),
        ],
      );
      expect(seq.isCanonicallyOrdered, isTrue);
    });

    test('false when a step is older than the previous', () {
      const seq = EmailSequence(
        id: 's-2',
        name: 'Mixed',
        steps: [
          EmailSequenceStep(
              offset: Duration(hours: -24),
              kind: EmailTemplateKind.reminder24h),
          EmailSequenceStep(
              offset: Duration(hours: -72),
              kind: EmailTemplateKind.reminder72h),
        ],
      );
      expect(seq.isCanonicallyOrdered, isFalse);
    });

    test('JSON round-trip preserves steps', () {
      const seq = EmailSequence(
        id: 's-3',
        name: 'Post-session',
        steps: [
          EmailSequenceStep(
              offset: Duration(hours: 2),
              kind: EmailTemplateKind.reviewRequest),
        ],
      );
      final restored = EmailSequence.fromJson(seq.toJson());
      expect(restored.steps.length, 1);
      expect(restored.steps.first.kind, EmailTemplateKind.reviewRequest);
      expect(restored.steps.first.offset, const Duration(hours: 2));
    });
  });
}
