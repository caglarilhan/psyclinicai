/// Patient list filter (plan §19).
///
/// Pure data + matcher so the UI chip bar in
/// `patient_list_screen.dart` can `where(...)` against a single
/// `PatientFilter` object instead of carrying scattered booleans.
///
/// `PatientFilter.empty` matches every row; chip taps return a new
/// `PatientFilter` with one field toggled.
library;

enum PatientStatusFilter {
  active('active'),
  stable('stable'),
  followUp('follow_up'),
  inactive('inactive');

  const PatientStatusFilter(this.id);
  final String id;
}

enum PatientRiskFilter {
  high('high'),
  medium('medium'),
  low('low');

  const PatientRiskFilter(this.id);
  final String id;
}

enum LastSeenFilter {
  within24h('24h'),
  within7d('7d'),
  within30d('30d'),
  over30d('30d+');

  const LastSeenFilter(this.id);
  final String id;
}

class PatientFilterRow {
  const PatientFilterRow({
    required this.id,
    required this.name,
    required this.status,
    required this.risk,
    required this.lastSeenAt,
    this.insurer,
  });

  final String id;
  final String name;
  final PatientStatusFilter status;
  final PatientRiskFilter risk;
  final DateTime lastSeenAt;
  final String? insurer;
}

class PatientFilter {
  const PatientFilter({
    this.statuses = const {},
    this.risks = const {},
    this.lastSeen,
    this.insurer,
    this.query = '',
  });

  /// Empty filter — matches every row.
  static const empty = PatientFilter();

  final Set<PatientStatusFilter> statuses;
  final Set<PatientRiskFilter> risks;
  final LastSeenFilter? lastSeen;
  final String? insurer;

  /// Free-text search (debounced upstream, case-insensitive match).
  final String query;

  bool get isEmpty =>
      statuses.isEmpty &&
      risks.isEmpty &&
      lastSeen == null &&
      (insurer == null || insurer!.isEmpty) &&
      query.trim().isEmpty;

  bool matches(PatientFilterRow row, DateTime now) {
    if (statuses.isNotEmpty && !statuses.contains(row.status)) return false;
    if (risks.isNotEmpty && !risks.contains(row.risk)) return false;
    if (insurer != null && insurer!.isNotEmpty && row.insurer != insurer) {
      return false;
    }
    if (lastSeen != null && !_matchesLastSeen(row, now)) return false;
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      if (!row.name.toLowerCase().contains(q)) return false;
    }
    return true;
  }

  bool _matchesLastSeen(PatientFilterRow row, DateTime now) {
    final delta = now.difference(row.lastSeenAt);
    switch (lastSeen!) {
      case LastSeenFilter.within24h:
        return delta <= const Duration(hours: 24);
      case LastSeenFilter.within7d:
        return delta <= const Duration(days: 7);
      case LastSeenFilter.within30d:
        return delta <= const Duration(days: 30);
      case LastSeenFilter.over30d:
        return delta > const Duration(days: 30);
    }
  }

  /// Apply the filter to a roster, returning the visible subset in
  /// the order of the input.
  List<PatientFilterRow> apply(
    List<PatientFilterRow> rows, {
    required DateTime now,
  }) =>
      rows.where((r) => matches(r, now)).toList(growable: false);

  PatientFilter toggleStatus(PatientStatusFilter s) {
    final next = {...statuses};
    if (!next.add(s)) next.remove(s);
    return _withStatuses(next);
  }

  PatientFilter toggleRisk(PatientRiskFilter r) {
    final next = {...risks};
    if (!next.add(r)) next.remove(r);
    return _withRisks(next);
  }

  PatientFilter withLastSeen(LastSeenFilter? value) => PatientFilter(
        statuses: statuses,
        risks: risks,
        lastSeen: value,
        insurer: insurer,
        query: query,
      );

  PatientFilter withQuery(String value) => PatientFilter(
        statuses: statuses,
        risks: risks,
        lastSeen: lastSeen,
        insurer: insurer,
        query: value,
      );

  PatientFilter _withStatuses(Set<PatientStatusFilter> next) => PatientFilter(
        statuses: next,
        risks: risks,
        lastSeen: lastSeen,
        insurer: insurer,
        query: query,
      );

  PatientFilter _withRisks(Set<PatientRiskFilter> next) => PatientFilter(
        statuses: statuses,
        risks: next,
        lastSeen: lastSeen,
        insurer: insurer,
        query: query,
      );
}
