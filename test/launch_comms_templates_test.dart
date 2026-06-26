import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/launch_comms_templates.dart';

void main() {
  group('LaunchCommsTemplates — catalog invariants', () {
    test('catalog is non-empty', () {
      expect(LaunchCommsTemplates.entries, isNotEmpty);
    });

    test('every template has a unique id', () {
      final ids = LaunchCommsTemplates.entries.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final t in LaunchCommsTemplates.entries) {
        expect(LaunchCommsTemplates.byId(t.id), same(t));
      }
      expect(LaunchCommsTemplates.byId('does-not-exist'), isNull);
    });

    test('every template has populated fields', () {
      for (final t in LaunchCommsTemplates.entries) {
        expect(t.subject, isNotEmpty, reason: t.id);
        expect(t.body, isNotEmpty, reason: t.id);
        expect(t.requiredPlaceholders, isNotEmpty, reason: t.id);
      }
    });

    test('byMilestone + byAudience slice correctly', () {
      for (final m in LaunchMilestone.values) {
        for (final t in LaunchCommsTemplates.byMilestone(m)) {
          expect(t.milestone, m);
        }
      }
      for (final a in LaunchAudience.values) {
        for (final t in LaunchCommsTemplates.byAudience(a)) {
          expect(t.audience, a);
        }
      }
    });
  });

  group('placeholder hygiene', () {
    test('every required placeholder resolves in the rendered copy', () {
      for (final t in LaunchCommsTemplates.entries) {
        final tokens = placeholdersIn('${t.subject} || ${t.body}').toSet();
        for (final required in t.requiredPlaceholders) {
          expect(
            tokens,
            contains(required),
            reason:
                '${t.id}: required placeholder `$required` declared but '
                'never appears in subject or body — copy edit dropped it',
          );
        }
      }
    });
  });

  group('brand voice + compliance enforcement', () {
    test('every template uses the plural voice (flag === true)', () {
      for (final t in LaunchCommsTemplates.entries) {
        expect(
          t.usesPluralVoice,
          isTrue,
          reason:
              '${t.id}: brand voice is plural across every template; '
              'first-person singular is never the company voice',
        );
      }
    });

    test('no template body contains first-person singular pronouns', () {
      for (final t in LaunchCommsTemplates.entries) {
        expect(
          containsFirstPersonSingular(t.body),
          isFalse,
          reason:
              '${t.id}: body contains an "I/my" pronoun — replace with '
              '"we / our team / the platform"',
        );
      }
    });

    test('press + social + community templates embed the AI disclaimer', () {
      const mustDisclaim = [
        LaunchAudience.pressJournalists,
        LaunchAudience.socialPublic,
        LaunchAudience.communityChannels,
      ];
      for (final t in LaunchCommsTemplates.entries) {
        if (!mustDisclaim.contains(t.audience)) continue;
        expect(
          t.embedsAiDisclaimer,
          isTrue,
          reason:
              '${t.id}: ${t.audience.name} audience requires the '
              '"decision-support only" disclaimer (FDA / EU AI Act)',
        );
        expect(
          t.body.toLowerCase(),
          contains('decision-support'),
          reason: '${t.id}: the disclaimer string must literally appear',
        );
      }
    });

    test('press + social + community templates embed EU positioning', () {
      const mustEu = [
        LaunchAudience.pressJournalists,
        LaunchAudience.socialPublic,
        LaunchAudience.communityChannels,
      ];
      for (final t in LaunchCommsTemplates.entries) {
        if (!mustEu.contains(t.audience)) continue;
        expect(
          t.embedsEuPositioning,
          isTrue,
          reason:
              '${t.id}: ${t.audience.name} audience requires explicit '
              'EU-based positioning',
        );
        expect(
          t.body.toLowerCase(),
          contains('eu'),
          reason: '${t.id}: the EU positioning must literally appear in body',
        );
      }
    });

    test('investor update template lists month-1 metrics', () {
      final t = LaunchCommsTemplates.byId('paid-ga-investor-update')!;
      const must = [
        'mrr_eur',
        'paying_clinics',
        'active_clinicians',
        'w4_retention_pct',
        'headline_risk',
        'next_milestone',
      ];
      for (final token in must) {
        expect(
          t.requiredPlaceholders,
          contains(token),
          reason:
              'investor template must surface $token so the update '
              'reflects the standard board-deck schema',
        );
      }
    });

    test('public-beta press drop offers press_kit_url', () {
      final t = LaunchCommsTemplates.byId('public-beta-press')!;
      expect(t.requiredPlaceholders, contains('press_kit_url'));
    });
  });

  group('placeholdersIn helper', () {
    test('extracts the inner token names', () {
      expect(
        placeholdersIn('hi {{first_name}} on {{launch_date_utc}}').toList(),
        equals(['first_name', 'launch_date_utc']),
      );
    });

    test('ignores partial / malformed braces', () {
      expect(placeholdersIn('hi {single} or {{nope').toList(), isEmpty);
    });
  });

  group('containsFirstPersonSingular helper', () {
    test('true on "I am" / "my team"', () {
      expect(containsFirstPersonSingular('I am the founder'), isTrue);
      expect(containsFirstPersonSingular('my team built this'), isTrue);
    });

    test('false on plural-voice copy', () {
      expect(
        containsFirstPersonSingular('Our team shipped the platform'),
        isFalse,
      );
      expect(
        containsFirstPersonSingular('We have launched the public beta'),
        isFalse,
      );
    });
  });
}
