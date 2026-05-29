/// ICD-10-CM lookup for mental health diagnoses.
///
/// Curated F-series, R-series, Z-series. Synonyms enable simple text-search
/// ("PTSD" -> F43.10, "depression" -> F32.9).
class Icd10LookupService {
  Icd10LookupService._();
  static final Icd10LookupService instance = Icd10LookupService._();

  static const List<Icd10Code> _codes = [
    // ---- Depressive / Mood ----
    Icd10Code(
      code: 'F32.0',
      label: 'Major depressive disorder, single episode, mild',
      synonyms: ['depression mild', 'mdd mild'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F32.1',
      label: 'Major depressive disorder, single episode, moderate',
      synonyms: ['depression moderate'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F32.2',
      label:
          'Major depressive disorder, single episode, severe without psychosis',
      synonyms: ['depression severe'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F32.9',
      label: 'Major depressive disorder, single episode, unspecified',
      synonyms: ['depression', 'mdd', 'major depression'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F33.0',
      label: 'Major depressive disorder, recurrent, mild',
      synonyms: ['recurrent depression mild'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F33.1',
      label: 'Major depressive disorder, recurrent, moderate',
      synonyms: ['recurrent depression moderate'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F33.2',
      label: 'Major depressive disorder, recurrent, severe without psychosis',
      synonyms: ['recurrent depression severe'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F34.1',
      label: 'Dysthymic disorder (persistent depressive disorder)',
      synonyms: ['dysthymia', 'persistent depression'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F31.81',
      label: 'Bipolar II disorder',
      synonyms: ['bipolar 2'],
      category: Icd10Category.mood,
    ),
    Icd10Code(
      code: 'F31.9',
      label: 'Bipolar disorder, unspecified',
      synonyms: ['bipolar'],
      category: Icd10Category.mood,
    ),

    // ---- Anxiety / OCD / Trauma ----
    Icd10Code(
      code: 'F41.1',
      label: 'Generalized anxiety disorder',
      synonyms: ['gad', 'generalized anxiety'],
      category: Icd10Category.anxiety,
    ),
    Icd10Code(
      code: 'F41.0',
      label: 'Panic disorder without agoraphobia',
      synonyms: ['panic'],
      category: Icd10Category.anxiety,
    ),
    Icd10Code(
      code: 'F40.10',
      label: 'Social phobia (social anxiety disorder), unspecified',
      synonyms: ['social anxiety'],
      category: Icd10Category.anxiety,
    ),
    Icd10Code(
      code: 'F40.00',
      label: 'Agoraphobia, unspecified',
      synonyms: ['agoraphobia'],
      category: Icd10Category.anxiety,
    ),
    Icd10Code(
      code: 'F42.2',
      label:
          'Obsessive-compulsive disorder, mixed obsessional thoughts and acts',
      synonyms: ['ocd'],
      category: Icd10Category.anxiety,
    ),
    Icd10Code(
      code: 'F43.10',
      label: 'Post-traumatic stress disorder, unspecified',
      synonyms: ['ptsd'],
      category: Icd10Category.trauma,
    ),
    Icd10Code(
      code: 'F43.0',
      label: 'Acute stress reaction',
      synonyms: ['acute stress'],
      category: Icd10Category.trauma,
    ),
    Icd10Code(
      code: 'F43.20',
      label: 'Adjustment disorder, unspecified',
      synonyms: ['adjustment disorder'],
      category: Icd10Category.trauma,
    ),
    Icd10Code(
      code: 'F43.21',
      label: 'Adjustment disorder with depressed mood',
      synonyms: ['adjustment depression'],
      category: Icd10Category.trauma,
    ),
    Icd10Code(
      code: 'F43.22',
      label: 'Adjustment disorder with anxiety',
      synonyms: ['adjustment anxiety'],
      category: Icd10Category.trauma,
    ),

    // ---- Substance use ----
    Icd10Code(
      code: 'F10.20',
      label: 'Alcohol dependence, uncomplicated',
      synonyms: ['alcohol use', 'aud'],
      category: Icd10Category.substance,
    ),
    Icd10Code(
      code: 'F11.20',
      label: 'Opioid dependence, uncomplicated',
      synonyms: ['oud'],
      category: Icd10Category.substance,
    ),
    Icd10Code(
      code: 'F12.20',
      label: 'Cannabis dependence, uncomplicated',
      synonyms: ['cannabis use'],
      category: Icd10Category.substance,
    ),

    // ---- Eating / Sleep ----
    Icd10Code(
      code: 'F50.0',
      label: 'Anorexia nervosa',
      synonyms: ['anorexia'],
      category: Icd10Category.other,
    ),
    Icd10Code(
      code: 'F50.2',
      label: 'Bulimia nervosa',
      synonyms: ['bulimia'],
      category: Icd10Category.other,
    ),
    Icd10Code(
      code: 'F51.01',
      label: 'Primary insomnia',
      synonyms: ['insomnia'],
      category: Icd10Category.other,
    ),

    // ---- Personality ----
    Icd10Code(
      code: 'F60.3',
      label: 'Borderline personality disorder',
      synonyms: ['bpd'],
      category: Icd10Category.personality,
    ),
    Icd10Code(
      code: 'F60.81',
      label: 'Narcissistic personality disorder',
      synonyms: ['npd'],
      category: Icd10Category.personality,
    ),

    // ---- Neurodevelopmental ----
    Icd10Code(
      code: 'F90.0',
      label: 'ADHD, predominantly inattentive type',
      synonyms: ['adhd inattentive', 'add'],
      category: Icd10Category.neurodevelopmental,
    ),
    Icd10Code(
      code: 'F90.2',
      label: 'ADHD, combined type',
      synonyms: ['adhd'],
      category: Icd10Category.neurodevelopmental,
    ),
    Icd10Code(
      code: 'F84.0',
      label: 'Autism spectrum disorder',
      synonyms: ['autism', 'asd'],
      category: Icd10Category.neurodevelopmental,
    ),

    // ---- Psychotic ----
    Icd10Code(
      code: 'F20.9',
      label: 'Schizophrenia, unspecified',
      synonyms: ['schizophrenia'],
      category: Icd10Category.psychotic,
    ),
    Icd10Code(
      code: 'F25.0',
      label: 'Schizoaffective disorder, bipolar type',
      synonyms: ['schizoaffective'],
      category: Icd10Category.psychotic,
    ),

    // ---- Z-codes ----
    Icd10Code(
      code: 'Z63.0',
      label: 'Problems in relationship with spouse or partner',
      synonyms: ['couples', 'relationship problem'],
      category: Icd10Category.zCode,
    ),
    Icd10Code(
      code: 'Z63.4',
      label: 'Disappearance and death of family member',
      synonyms: ['grief', 'bereavement'],
      category: Icd10Category.zCode,
    ),
    Icd10Code(
      code: 'Z73.0',
      label: 'Burn-out',
      synonyms: ['burnout'],
      category: Icd10Category.zCode,
    ),
  ];

  List<Icd10Code> all() => List.unmodifiable(_codes);

  List<Icd10Code> byCategory(Icd10Category category) =>
      _codes.where((c) => c.category == category).toList(growable: false);

  Icd10Code? byCode(String code) {
    for (final c in _codes) {
      if (c.code == code) return c;
    }
    return null;
  }

  /// Case-insensitive search across code, label, and synonyms.
  List<Icd10Code> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all();
    return _codes
        .where((c) {
          if (c.code.toLowerCase().contains(q)) return true;
          if (c.label.toLowerCase().contains(q)) return true;
          for (final s in c.synonyms) {
            if (s.contains(q)) return true;
          }
          return false;
        })
        .toList(growable: false);
  }
}

enum Icd10Category {
  mood,
  anxiety,
  trauma,
  substance,
  personality,
  psychotic,
  neurodevelopmental,
  other,
  zCode,
}

extension Icd10CategoryX on Icd10Category {
  String get label => switch (this) {
    Icd10Category.mood => 'Mood',
    Icd10Category.anxiety => 'Anxiety',
    Icd10Category.trauma => 'Trauma / Stress',
    Icd10Category.substance => 'Substance Use',
    Icd10Category.personality => 'Personality',
    Icd10Category.psychotic => 'Psychotic',
    Icd10Category.neurodevelopmental => 'Neurodevelopmental',
    Icd10Category.other => 'Other',
    Icd10Category.zCode => 'Z-codes',
  };
}

class Icd10Code {
  const Icd10Code({
    required this.code,
    required this.label,
    required this.category,
    this.synonyms = const [],
  });

  final String code;
  final String label;
  final Icd10Category category;
  final List<String> synonyms;

  @override
  String toString() => '$code · $label';
}
