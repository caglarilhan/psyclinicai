class AssessmentType {
  static const String phq9 = 'PHQ-9';
  static const String gad7 = 'GAD-7';
}

class AssessmentItem {
  final int index;
  final String question;
  final int answer; // 0..3

  const AssessmentItem({required this.index, required this.question, required this.answer});
}

class AssessmentResult {
  final String id; // timestamp based id
  final String type; // PHQ-9 | GAD-7
  final String clientName;
  final DateTime createdAt;
  final List<AssessmentItem> items;
  final int totalScore;

  const AssessmentResult({
    required this.id,
    required this.type,
    required this.clientName,
    required this.createdAt,
    required this.items,
    required this.totalScore,
  });
}

class AssessmentScoring {
  static int calculateTotal(List<int> answers) {
    int sum = 0;
    for (final v in answers) {
      if (v >= 0 && v <= 3) sum += v;
    }
    return sum;
  }

  static String phq9Severity(int total) {
    if (total <= 4) return 'Minimal';
    if (total <= 9) return 'Mild';
    if (total <= 14) return 'Moderate';
    if (total <= 19) return 'Moderately Severe';
    return 'Severe';
  }

  static String gad7Severity(int total) {
    if (total <= 4) return 'Minimal';
    if (total <= 9) return 'Mild';
    if (total <= 14) return 'Moderate';
    return 'Severe';
  }
}


