class Question {
  final int? id;
  final String text;
  final String? image;
  final List<String> options;
  final int correctOption;
  final int weight; // Вес для умного повторения

  Question({
    this.id,
    required this.text,
    this.image,
    required this.options,
    required this.correctOption,
    this.weight = 1, // По умолчанию вес 1
  });

  // Превращаем данные из БД (Map) в объект
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      image: map['image'],
      options: map['options'].toString().split('|'), // Храним варианты через разделитель
      correctOption: map['correct_option'],
      weight: map['weight'],
    );
  }
}