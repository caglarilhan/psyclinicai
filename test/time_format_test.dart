/// Coverage for TimeFormat — ISO instant, ISO date, relative-time
/// bucketing across the full set of thresholds, future-timestamp
/// handling, calendar-day comparison, relativeDay buckets, and the
/// HH:MM local clock.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/time_format.dart';

void main() {
  group('TimeFormat.isoUtc', () {
    test('emits canonical YYYY-MM-DDTHH:MM:SSZ for a UTC instant', () {
      expect(
        TimeFormat.isoUtc(DateTime.utc(2026, 6, 24, 14, 30, 5)),
        '2026-06-24T14:30:05Z',
      );
    });

    test('normalises non-UTC input to UTC before formatting', () {
      final local = DateTime.utc(2026, 1, 7, 9).toLocal();
      expect(TimeFormat.isoUtc(local), '2026-01-07T09:00:00Z');
    });

    test('pads single-digit fields to two digits', () {
      expect(
        TimeFormat.isoUtc(DateTime.utc(2026, 1, 7, 9, 5, 4)),
        '2026-01-07T09:05:04Z',
      );
    });
  });

  group('TimeFormat.isoDate', () {
    test('emits YYYY-MM-DD for a UTC instant', () {
      expect(TimeFormat.isoDate(DateTime.utc(2026, 6, 24)), '2026-06-24');
    });
  });

  group('TimeFormat.relative', () {
    final now = DateTime.utc(2026, 6, 24, 14);

    test('< 60s collapses to "just now"', () {
      expect(
        TimeFormat.relative(
          now.subtract(const Duration(seconds: 30)),
          now: now,
        ),
        'just now',
      );
    });

    test('< 60m → "N min ago"', () {
      expect(
        TimeFormat.relative(
          now.subtract(const Duration(minutes: 12)),
          now: now,
        ),
        '12 min ago',
      );
    });

    test('< 24h → "N h ago"', () {
      expect(
        TimeFormat.relative(now.subtract(const Duration(hours: 5)), now: now),
        '5 h ago',
      );
    });

    test('< 7d → "N d ago"', () {
      expect(
        TimeFormat.relative(now.subtract(const Duration(days: 3)), now: now),
        '3 d ago',
      );
    });

    test('< 30d → "N w ago"', () {
      expect(
        TimeFormat.relative(now.subtract(const Duration(days: 15)), now: now),
        '2 w ago',
      );
    });

    test('< 365d → "N mo ago"', () {
      expect(
        TimeFormat.relative(now.subtract(const Duration(days: 90)), now: now),
        '3 mo ago',
      );
    });

    test('>= 365d → "N y ago"', () {
      expect(
        TimeFormat.relative(now.subtract(const Duration(days: 400)), now: now),
        '1 y ago',
      );
    });

    test('future timestamp prefixed with "in"', () {
      expect(
        TimeFormat.relative(now.add(const Duration(hours: 2)), now: now),
        'in 2 h',
      );
    });
  });

  group('TimeFormat.isSameLocalDay', () {
    test('same calendar day returns true', () {
      expect(
        TimeFormat.isSameLocalDay(
          DateTime(2026, 6, 24, 1),
          DateTime(2026, 6, 24, 23),
        ),
        isTrue,
      );
    });

    test('different calendar day returns false', () {
      expect(
        TimeFormat.isSameLocalDay(
          DateTime(2026, 6, 24, 23),
          DateTime(2026, 6, 25, 1),
        ),
        isFalse,
      );
    });
  });

  group('TimeFormat.relativeDay', () {
    final today = DateTime(2026, 6, 24, 14);

    test('today → "Today"', () {
      expect(
        TimeFormat.relativeDay(DateTime(2026, 6, 24, 9), now: today),
        'Today',
      );
    });

    test('yesterday → "Yesterday"', () {
      expect(
        TimeFormat.relativeDay(DateTime(2026, 6, 23, 9), now: today),
        'Yesterday',
      );
    });

    test('tomorrow → "Tomorrow"', () {
      expect(
        TimeFormat.relativeDay(DateTime(2026, 6, 25, 9), now: today),
        'Tomorrow',
      );
    });

    test('older entry same year → "Mon D"', () {
      expect(
        TimeFormat.relativeDay(DateTime(2026, 3, 12), now: today),
        'Mar 12',
      );
    });

    test('older entry prior year → "Mon D, YYYY"', () {
      expect(
        TimeFormat.relativeDay(DateTime(2024, 3, 12), now: today),
        'Mar 12, 2024',
      );
    });
  });

  group('TimeFormat.localClock', () {
    test('emits HH:MM with zero padding', () {
      expect(TimeFormat.localClock(DateTime(2026, 6, 24, 9, 5)), '09:05');
    });

    test('uses 24-hour clock for afternoon', () {
      expect(TimeFormat.localClock(DateTime(2026, 6, 24, 14, 30)), '14:30');
    });
  });
}
