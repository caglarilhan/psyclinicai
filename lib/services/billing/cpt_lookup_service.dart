/// Mental Health CPT (Current Procedural Terminology) code lookup.
///
/// Covers the codes most commonly used by US/EU mental health practices for
/// outpatient psychotherapy, psychiatric diagnostic evaluation, family /
/// group therapy, and E/M codes. ~95% of solo / small-practice billing volume.
///
/// `nationalAverageUsd` values are 2025 CMS-published national averages,
/// rounded. Real reimbursement depends on payer + locality + modifiers.
class CptLookupService {
  CptLookupService._();
  static final CptLookupService instance = CptLookupService._();

  static const List<CptCode> _codes = [
    CptCode(
      code: '90791',
      shortLabel: 'Psychiatric Diagnostic Evaluation',
      description:
          'Psychiatric diagnostic evaluation without medical services.',
      typicalDurationMinutes: 60,
      nationalAverageUsd: 195,
      category: CptCategory.evaluation,
    ),
    CptCode(
      code: '90792',
      shortLabel: 'Psychiatric Eval (with medical)',
      description:
          'Psychiatric diagnostic evaluation with medical services.',
      typicalDurationMinutes: 60,
      nationalAverageUsd: 215,
      category: CptCategory.evaluation,
    ),
    CptCode(
      code: '90832',
      shortLabel: 'Psychotherapy 30 min',
      description: 'Psychotherapy, 30 minutes with patient.',
      typicalDurationMinutes: 30,
      nationalAverageUsd: 95,
      category: CptCategory.psychotherapy,
    ),
    CptCode(
      code: '90834',
      shortLabel: 'Psychotherapy 45 min',
      description: 'Psychotherapy, 45 minutes with patient.',
      typicalDurationMinutes: 45,
      nationalAverageUsd: 125,
      category: CptCategory.psychotherapy,
    ),
    CptCode(
      code: '90837',
      shortLabel: 'Psychotherapy 60 min',
      description: 'Psychotherapy, 60 minutes with patient.',
      typicalDurationMinutes: 60,
      nationalAverageUsd: 175,
      category: CptCategory.psychotherapy,
    ),
    CptCode(
      code: '90846',
      shortLabel: 'Family Psychotherapy (no patient)',
      description:
          'Family or couples psychotherapy, without patient present.',
      typicalDurationMinutes: 50,
      nationalAverageUsd: 130,
      category: CptCategory.familyGroup,
    ),
    CptCode(
      code: '90847',
      shortLabel: 'Family Psychotherapy (with patient)',
      description: 'Family or couples psychotherapy, with patient present.',
      typicalDurationMinutes: 50,
      nationalAverageUsd: 145,
      category: CptCategory.familyGroup,
    ),
    CptCode(
      code: '90853',
      shortLabel: 'Group Psychotherapy',
      description:
          'Group psychotherapy (other than of a multiple-family group).',
      typicalDurationMinutes: 60,
      nationalAverageUsd: 50,
      category: CptCategory.familyGroup,
    ),
    CptCode(
      code: '90839',
      shortLabel: 'Crisis Psychotherapy 60 min',
      description: 'Psychotherapy for crisis, first 60 minutes.',
      typicalDurationMinutes: 60,
      nationalAverageUsd: 200,
      category: CptCategory.crisis,
    ),
    CptCode(
      code: '90840',
      shortLabel: 'Crisis Add-on 30 min',
      description:
          'Psychotherapy for crisis, each additional 30 minutes (add-on to 90839).',
      typicalDurationMinutes: 30,
      nationalAverageUsd: 95,
      category: CptCategory.crisis,
    ),
    CptCode(
      code: '99213',
      shortLabel: 'E/M Established Patient (low)',
      description:
          'Office or other outpatient visit, established patient, low complexity (15 min).',
      typicalDurationMinutes: 15,
      nationalAverageUsd: 95,
      category: CptCategory.evaluation,
    ),
    CptCode(
      code: '99214',
      shortLabel: 'E/M Established Patient (moderate)',
      description:
          'Office or other outpatient visit, established patient, moderate complexity (25 min).',
      typicalDurationMinutes: 25,
      nationalAverageUsd: 140,
      category: CptCategory.evaluation,
    ),
  ];

  List<CptCode> all() => List.unmodifiable(_codes);

  List<CptCode> byCategory(CptCategory category) =>
      _codes.where((c) => c.category == category).toList(growable: false);

  CptCode? byCode(String code) {
    for (final c in _codes) {
      if (c.code == code) return c;
    }
    return null;
  }

  /// Suggests an individual psychotherapy CPT code from a session duration.
  CptCode? suggestForDuration(int minutes) {
    if (minutes <= 0) return null;
    if (minutes < 38) return byCode('90832'); // 30-min
    if (minutes < 53) return byCode('90834'); // 45-min
    return byCode('90837'); // 60-min
  }
}

enum CptCategory { evaluation, psychotherapy, familyGroup, crisis }

extension CptCategoryX on CptCategory {
  String get label => switch (this) {
        CptCategory.evaluation => 'Evaluation / E&M',
        CptCategory.psychotherapy => 'Psychotherapy',
        CptCategory.familyGroup => 'Family / Group',
        CptCategory.crisis => 'Crisis',
      };
}

class CptCode {
  const CptCode({
    required this.code,
    required this.shortLabel,
    required this.description,
    required this.typicalDurationMinutes,
    required this.nationalAverageUsd,
    required this.category,
  });

  final String code;
  final String shortLabel;
  final String description;
  final int typicalDurationMinutes;
  final double nationalAverageUsd;
  final CptCategory category;

  @override
  String toString() => '$code · $shortLabel';
}
