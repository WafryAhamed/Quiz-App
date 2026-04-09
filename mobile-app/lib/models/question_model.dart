class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String difficulty;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      difficulty: (json['difficulty'] as String?) ?? 'medium',
    );
  }
}
