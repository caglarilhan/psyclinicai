/// Pure time-formatting helpers. The codebase has 40+ places that
/// hand-roll a "5 min ago" / "yesterday" / "Mar 12" style; this
/// module is the canonical version every future consumer should
/// route through.
///
/// All inputs are normalised to UTC; the consumer is responsible
/// for converting back to the patient / clinician local timezone
/// at the call site (or via the `local` flag on the helpers
/// below).
library;

class TimeFormat {
  TimeFormat._();

  /// Canonical ISO-8601 UTC instant, e.g. `2026-06-24T14:30:00Z`.
  /// Matches the format the FHIR exporter (PR #47) uses, so the
  /// audit log + FHIR Bundle stay byte-identical for the same
  /// timestamp.
  static String isoUtc(DateTime t) {
    final u = t.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-'
        '${u.month.toString().padLeft(2, '0')}-'
        '${u.day.toString().padLeft(2, '0')}T'
        '${u.hour.toString().padLeft(2, '0')}:'
        '${u.minute.toString().padLeft(2, '0')}:'
        '${u.second.toString().padLeft(2, '0')}Z';
  }

  /// `YYYY-MM-DD` — the FHIR R4 birthDate format. Pure UTC date.
  static String isoDate(DateTime t) {
    final u = t.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-'
        '${u.month.toString().padLeft(2, '0')}-'
        '${u.day.toString().padLeft(2, '0')}';
  }

  /// Human-readable elapsed time. Buckets:
  ///   < 60s   → "just now"
  ///   < 60m   → "N min ago"
  ///   < 24h   → "N h ago"
  ///   < 7d    → "N d ago"
  ///   < 30d   → "N w ago"
  ///   < 365d  → "N mo ago"
  ///   else    → "N y ago"
  ///
  /// `now` defaults to `DateTime.now().toUtc()` but is overridable
  /// for tests.
  static String relative(DateTime t, {DateTime? now}) {
    final reference = (now ?? DateTime.now()).toUtc();
    final compared = t.toUtc();
    final delta = reference.difference(compared);
    final seconds = delta.inSeconds;
    if (seconds < 0) {
      // Future timestamp — express as "in N …".
      final swapped = relative(reference, now: compared);
      return 'in ${swapped.replaceAll(' ago', '')}';
    }
    if (seconds < 60) return 'just now';
    final minutes = delta.inMinutes;
    if (minutes < 60) return '$minutes min ago';
    final hours = delta.inHours;
    if (hours < 24) return '$hours h ago';
    final days = delta.inDays;
    if (days < 7) return '$days d ago';
    if (days < 30) return '${(days / 7).floor()} w ago';
    if (days < 365) return '${(days / 30).floor()} mo ago';
    return '${(days / 365).floor()} y ago';
  }

  /// Calendar-day comparison ignoring time + timezone.
  static bool isSameLocalDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  /// Returns `Today` / `Yesterday` / `Tomorrow` for nearby days,
  /// else `Jun 24` / `Jun 24, 2024` for older / future entries.
  /// Optionally pass [now] to make the test boundary deterministic.
  static String relativeDay(DateTime t, {DateTime? now}) {
    final today = (now ?? DateTime.now()).toLocal();
    final target = t.toLocal();
    final daysDelta = DateTime(
      target.year,
      target.month,
      target.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    if (daysDelta == 0) return 'Today';
    if (daysDelta == -1) return 'Yesterday';
    if (daysDelta == 1) return 'Tomorrow';
    final month = _shortMonth(target.month);
    final day = target.day.toString();
    if (target.year == today.year) return '$month $day';
    return '$month $day, ${target.year}';
  }

  /// 24-hour clock string `HH:MM` in the target's local timezone.
  /// Drops seconds because the contexts that consume this
  /// (appointment lists, audit log rows) never care about them and
  /// the extra precision invites alignment-thrash in tables.
  static String localClock(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  static String _shortMonth(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
}
