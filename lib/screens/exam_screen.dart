import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_model.dart';
import '../services/db_helper.dart';
import '../theme.dart';
import 'result_screen.dart';
import 'dart:convert';
import '../services/sync_service.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<Question> questions = [];
  int currentIndex = 0;

  // Словарь для хранения ответов пользователя: Ключ = индекс вопроса, Значение = индекс ответа
  Map<int, int> userAnswers = {};

  Timer? _timer;
  int _secondsRemaining = 40 * 60; // 40 минут

  @override
  void initState() {
    super.initState();
    _loadSession();
    _startTimer();
  }

  void _loadSession() async {
    final data = await DBHelper.instance.getTestSession(40);
    setState(() => questions = data);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _submitExam(); // Автоматическое завершение по истечении времени
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Логика завершения экзамена
  // Логика завершения экзамена
  void _submitExam() async {
    _timer?.cancel();
    int correctAnswers = 0;
    List<Map<String, dynamic>> detailedAnswers = []; // <-- Создаем список для деталей

    for (int i = 0; i < questions.length; i++) {
      bool isCorrect = userAnswers[i] == questions[i].correctOption;
      if (isCorrect) correctAnswers++;

      // Записываем, как ответил пользователь
      detailedAnswers.add({
        "question_text": questions[i].text,
        "user_answer": userAnswers[i] != null ? questions[i].options[userAnswers[i]!] : "Не ответил",
        "correct_answer": questions[i].options[questions[i].correctOption],
        "is_correct": isCorrect
      });

      await DBHelper.instance.updateQuestionWeight(questions[i].id!, isCorrect);
    }

    int timeSpentSeconds = (40 * 60) - _secondsRemaining;
    String formattedTime = "${(timeSpentSeconds ~/ 60).toString().padLeft(2, '0')}:${(timeSpentSeconds % 60).toString().padLeft(2, '0')}";
    bool isPassed = correctAnswers >= 32;

    // Превращаем список в строку JSON
    String answersJson = jsonEncode(detailedAnswers);

    await DBHelper.instance.saveTestResult(
      testType: "Экзамен",
      correctAnswers: correctAnswers,
      totalQuestions: questions.length,
      timeSpent: formattedTime,
      isPassed: isPassed,
      answersData: answersJson, // <-- ПЕРЕДАЕМ В БАЗУ
    );

    SyncService.syncTestHistory(showErrors: false).catchError((e) => debugPrint("Автосинхронизация: $e"));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          correctAnswers: correctAnswers,
          totalQuestions: questions.length,
          timeSpent: formattedTime,
          isExam: true, // Передаем флаг экзамена!
        ),
      ),
    );
  }

  String get _formattedTimer {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),

          // Скроллируемая область с вопросом
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Вопрос", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textMain)),
                        Text("${currentIndex + 1}/${questions.length}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      backgroundColor: AppColors.background,
                      color: const Color(0xFFF6CE63),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 30),

                    // Умный показ картинки
                    if (currentQuestion.image != null && currentQuestion.image!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: currentQuestion.image!.startsWith('http')
                                ? Image.network(currentQuestion.image!, height: 150, fit: BoxFit.contain)
                                : Image.asset('assets/images/${currentQuestion.image}', height: 150, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ],

                    Text(
                      currentQuestion.text,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 30),

                    ...List.generate(currentQuestion.options.length, (index) {
                      bool isSelected = userAnswers[currentIndex] == index;
                      return GestureDetector(
                        onTap: () => setState(() => userAnswers[currentIndex] = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF6CE63).withOpacity(0.2) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF6CE63) : Colors.grey.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            currentQuestion.options[index],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Фиксированная панель кнопок внизу
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: AppColors.background,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: currentIndex > 0 ? () => setState(() => currentIndex--) : null,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text("Назад", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textMain,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentIndex < questions.length - 1 ? () => setState(() => currentIndex++) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6CE63),
                          foregroundColor: AppColors.textMain,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Далее", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      // Стилизованное окно подтверждения
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text("Завершить экзамен?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          content: Text("Вы уверены? Неотвеченные вопросы будут засчитаны как ошибки.", style: GoogleFonts.poppins(color: Colors.black87)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Отмена", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600))
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF6CE63),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _submitExam();
                              },
                              child: Text("Завершить", style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.flag, color: Colors.grey),
                    label: Text(
                      "Завершить экзамен",
                      style: GoogleFonts.poppins(color: Colors.grey, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF6CE63), // Желтый цвет экзамена
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Экзамен",
                style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.black87, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    _formattedTimer,
                    style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}