/// Server evaluation outcome of a submitted quiz.
class QuizResultModel {
  final String attemptId;
  final double score;
  final int passPercentage;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;

  const QuizResultModel({
    required this.attemptId,
    required this.score,
    required this.passPercentage,
    required this.passed,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      attemptId: json['attempt_id']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      passPercentage: (json['pass_percentage'] as num?)?.toInt() ?? 70,
      passed: json['passed'] as bool? ?? false,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correct_answers'] as num?)?.toInt() ?? 0,
    );
  }
}
