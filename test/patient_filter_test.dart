import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/patient_filter.dart';

final _now = DateTime.utc(2026, 6, 10, 12);

PatientFilterRow _row({
  String id = 'p',
  String name = 'John Demo',
  PatientStatusFilter status = PatientStatusFilter.active,
  PatientRiskFilter risk = PatientRiskFilter.low,
  Duration sinceLastSeen = const Duration(hours: 4),
  String? insurer,
}) => PatientFilterRow(
  id: id,
  name: name,
  status: status,
  risk: risk,
  lastSeenAt: _now.subtract(sinceLastSeen),
  insurer: insurer,
);

void main() {
  group('PatientFilter', () {
    test('empty filter matches every row', () {
      const filter = PatientFilter.empty;
      expect(filter.isEmpty, isTrue);
      expect(filter.matches(_row(), _now), isTrue);
    });

    test('status filter narrows to selected statuses', () {
      final f = PatientFilter.empty.toggleStatus(PatientStatusFilter.active);
      expect(f.matches(_row(), _now), isTrue);
      expect(
        f.matches(_row(status: PatientStatusFilter.inactive), _now),
        isFalse,
      );
    });

    test('toggling the same status twice clears it', () {
      final f = PatientFilter.empty
          .toggleStatus(PatientStatusFilter.active)
          .toggleStatus(PatientStatusFilter.active);
      expect(f.statuses, isEmpty);
    });

    test('risk filter is set-based (multi-select)', () {
      final f = PatientFilter.empty
          .toggleRisk(PatientRiskFilter.high)
          .toggleRisk(PatientRiskFilter.medium);
      expect(f.risks, {PatientRiskFilter.high, PatientRiskFilter.medium});
      expect(f.matches(_row(), _now), isFalse);
    });

    test('lastSeen 24h excludes older rows', () {
      final f = PatientFilter.empty.withLastSeen(LastSeenFilter.within24h);
      expect(
        f.matches(_row(sinceLastSeen: const Duration(hours: 36)), _now),
        isFalse,
      );
      expect(
        f.matches(_row(sinceLastSeen: const Duration(hours: 12)), _now),
        isTrue,
      );
    });

    test('lastSeen 30d+ keeps only stale rows', () {
      final f = PatientFilter.empty.withLastSeen(LastSeenFilter.over30d);
      expect(
        f.matches(_row(sinceLastSeen: const Duration(days: 60)), _now),
        isTrue,
      );
      expect(
        f.matches(_row(sinceLastSeen: const Duration(days: 15)), _now),
        isFalse,
      );
    });

    test('query is case-insensitive substring match', () {
      final f = PatientFilter.empty.withQuery('JOHN');
      expect(f.matches(_row(), _now), isTrue);
      expect(f.matches(_row(name: 'Sarah Smith'), _now), isFalse);
    });

    test('insurer filter exact-matches', () {
      const f = PatientFilter(insurer: 'BCBS');
      expect(f.matches(_row(insurer: 'BCBS'), _now), isTrue);
      expect(f.matches(_row(insurer: 'Aetna'), _now), isFalse);
    });

    test('apply preserves order and drops non-matches', () {
      final rows = [
        _row(id: 'a', risk: PatientRiskFilter.high),
        _row(id: 'b'),
        _row(id: 'c', risk: PatientRiskFilter.high),
      ];
      final out = PatientFilter.empty
          .toggleRisk(PatientRiskFilter.high)
          .apply(rows, now: _now);
      expect(out.map((r) => r.id), ['a', 'c']);
    });
  });
}
