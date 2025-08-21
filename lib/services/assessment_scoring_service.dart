import 'package:flutter/foundation.dart';

class AssessmentScoringService extends ChangeNotifier {
  static final AssessmentScoringService _instance = AssessmentScoringService._internal();
  factory AssessmentScoringService() => _instance;
  AssessmentScoringService._internal();

  int scorePhq9(List<int> answers) {
    if (answers.length != 9) throw ArgumentError('PHQ-9 requires 9 answers');
    return answers.fold(0, (a, b) => a + b);
  }

  String interpretPhq9(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    if (score <= 19) return 'Moderately Severe';
    return 'Severe';
  }

  int scoreGad7(List<int> answers) {
    if (answers.length != 7) throw ArgumentError('GAD-7 requires 7 answers');
    return answers.fold(0, (a, b) => a + b);
  }

  String interpretGad7(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    return 'Severe';
  }
}
