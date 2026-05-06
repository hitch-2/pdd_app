import 'package:flutter/material.dart';
import 'services/db_helper.dart';
import 'models/question_model.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Гарантируем инициализацию всех систем Flutter перед запуском БД
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем БД и импортируем вопросы из JSON
  await DBHelper.instance.importQuestionsFromJson();

  runApp(const PDDApp());
}

class PDDApp extends StatelessWidget {
  const PDDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ПДД Диплом',
      theme: ThemeData(primarySwatch: Colors.blue),
      // В lib/main.dart
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  Question? currentQuestion;

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();
  }

  // Метод загрузки вопроса с использованием нашей умной логики
  void _loadNextQuestion() async {
    final questions = await DBHelper.instance.getSmartQuestions(1);
    if (questions.isNotEmpty) {
      setState(() {
        currentQuestion = questions.first;
      });
    }
  }

  void _checkAnswer(int index) async {
    bool isCorrect = index == currentQuestion!.correctOption;

    // Обновляем вес вопроса в базе данных (Инструкция 4)
    await DBHelper.instance.updateQuestionWeight(currentQuestion!.id!, isCorrect);

    // Показываем результат (кратко)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Правильно!" : "Ошибка!"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 500),
      ),
    );

    // Загружаем следующий вопрос
    _loadNextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Подготовка к ПДД")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              currentQuestion!.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Список вариантов ответов
            ...List.generate(currentQuestion!.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  onPressed: () => _checkAnswer(index),
                  child: Text(currentQuestion!.options[index]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}