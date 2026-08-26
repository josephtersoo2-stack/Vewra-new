/// Public quiz question received from the server (without correct answer).
class QuizQuestionModel {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;
  final int? sourceTimestampSeconds;
  final String difficulty;

  const QuizQuestionModel({
    required this.id,
    required this.questionText,
    this.questionType = 'MULTIPLE_CHOICE',
    required this.options,
    this.sourceTimestampSeconds,
    this.difficulty = 'MEDIUM',
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id']?.toString() ?? '',
      questionText: json['question_text']?.toString() ?? '',
      questionType: json['question_type']?.toString() ?? 'MULTIPLE_CHOICE',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sourceTimestampSeconds:
          (json['source_timestamp_seconds'] as num?)?.toInt(),
      difficulty: json['difficulty']?.toString() ?? 'MEDIUM',
    );
  }
}
