import 'package:flutter/material.dart';
import 'package:pdd_app_172/theme.dart';
import 'services/db_helper.dart';
import 'models/question_model.dart';
import 'screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ИНИЦИАЛИЗАЦИЯ SUPABASE (Вставь свои ключи сюда!)
  await Supabase.initialize(
    url: 'https://zktauezmxaycsydceoka.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprdGF1ZXpteGF5Y3N5ZGNlb2thIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0Mjg3NzEsImV4cCI6MjA5NzAwNDc3MX0.7g8OSKKFM1W-5XDWe7ele8hI5uv0VDxcxzccUFokWak',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ПДД РК',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class PDDApp extends StatelessWidget {
  const PDDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme, // Подключаем созданную тему
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