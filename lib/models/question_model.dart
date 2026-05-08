class Question {
  final int? id;
  final String text;
  final String? image;
  final List<String> options;
  final int correctOption;
  final int weight;
  final String? explanation; // <-- НОВОЕ ПОЛЕ

  Question({
    this.id,
    required this.text,
    this.image,
    required this.options,
    required this.correctOption,
    this.weight = 1,
    this.explanation, // <-- НОВОЕ ПОЛЕ
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      image: map['image'],
      options: map['options'].toString().split('|'),
      correctOption: map['correct_option'],
      weight: map['weight'],
      explanation: map['explanation'], // <-- НОВОЕ ПОЛЕ
    );
  }
}