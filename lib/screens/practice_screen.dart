import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/question_model.dart';
import '../services/db_helper.dart';
import '../services/sync_service.dart';
import '../theme.dart';
import 'result_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<Map<String, dynamic>> detailedAnswers = [];
  List<Question> questions = [];
  int currentIndex = 0;
  int? selectedIndex;
  bool isAnswered = false;
  bool showProgress = false;
  bool isLoading = true;

  int correctAnswers = 0;
  int wrongAnswers = 0;
  DateTime? startTime;

  List<BoxShadow> get _softShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
  ];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _loadQuestions(); // Вызываем новый умный метод
  }

  // УМНАЯ ЗАГРУЗКА ИЗ ОБЛАЧНОГО КЭША (Исправляет баг бесконечной загрузки)
  Future<void> _loadQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('cache_questions');

      String response;
      if (cachedData != null) {
        response = cachedData;
      } else {
        response = await rootBundle.loadString('assets/data/questions.json');
      }

      final List<dynamic> data = json.decode(response);
      List<Question> loadedQuestions = [];

      for (var q in data) {
        // Умная разбивка вариантов ответов
        List<String> parsedOptions = [];
        if (q['options'] is String) {
          parsedOptions = (q['options'] as String).split('|');
        } else {
          parsedOptions = List<String>.from(q['options']);
        }

        loadedQuestions.add(Question(
          id: q['id'], // Обязательно берем ID для весов
          text: q['text'] ?? '',
          image: q['image'],
          options: parsedOptions,
          correctOption: q['correct_option'] ?? 0,
          explanation: q['explanation'] ?? '',
        ));
      }

      loadedQuestions.shuffle(); // Перемешиваем базу
      // Берем только 40 вопросов для практики (или сколько тебе нужно)
      if (loadedQuestions.length > 40) {
        loadedQuestions = loadedQuestions.sublist(0, 40);
      }

      if (!mounted) return;
      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Ошибка загрузки вопросов: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _checkAnswer() async {
    if (selectedIndex == null || isAnswered) return;
    bool isCorrect = selectedIndex == questions[currentIndex].correctOption;

    if (isCorrect) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    detailedAnswers.add({
      "question_text": questions[currentIndex].text,
      "user_answer": questions[currentIndex].options[selectedIndex!],
      "correct_answer": questions[currentIndex].options[questions[currentIndex].correctOption],
      "is_correct": isCorrect
    });

    if (questions[currentIndex].id != null) {
      await DBHelper.instance.updateQuestionWeight(questions[currentIndex].id!, isCorrect);
    }
    setState(() => isAnswered = true);
  }

  Future<void> _nextQuestion() async {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        isAnswered = false;
      });
    } else {
      final duration = DateTime.now().difference(startTime!);
      String formattedTime = "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";

      bool isPassed = correctAnswers >= 32;
      String answersJson = jsonEncode(detailedAnswers);

      await DBHelper.instance.saveTestResult(
        testType: "Практический тест",
        correctAnswers: correctAnswers,
        totalQuestions: questions.length,
        timeSpent: formattedTime,
        isPassed: isPassed,
        answersData: answersJson,
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
            isExam: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (questions.isEmpty) return const Scaffold(body: Center(child: Text("Вопросы не найдены")));

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    children: [
                      _buildQuestionCard(currentQuestion),
                      const SizedBox(height: 30),
                      ...List.generate(currentQuestion.options.length, (index) {
                        return _buildOptionCard(index, currentQuestion);
                      }),
                      if (isAnswered && currentQuestion.explanation != null && currentQuestion.explanation!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentQuestion.explanation!,
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMain),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                color: AppColors.background,
                child: _buildControlButtons(),
              ),
            ],
          ),
          if (showProgress) GestureDetector(onTap: () => setState(() => showProgress = false), child: AnimatedContainer(duration: const Duration(milliseconds: 300), color: Colors.black.withOpacity(0.2))),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500), curve: Curves.easeOutBack, top: showProgress ? 140 : -300, left: 0, right: 0, child: _buildProgressPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
              GestureDetector(
                onTap: () => setState(() => showProgress = !showProgress),
                child: Text("Практический тест", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              IconButton(icon: Image.asset('assets/icons/ic_filter.png', width: 24, color: Colors.white), onPressed: () => setState(() => showProgress = !showProgress)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: _softShadow),
      child: Column(
        children: [
          Text("${currentIndex + 1}. ${question.text}", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
          if (question.image != null && question.image!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: question.image!.startsWith('http')
                      ? Image.network(question.image!, height: 150, fit: BoxFit.contain)
                      : Image.asset('assets/images/${question.image}', height: 150, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, Question question) {
    bool isSelected = selectedIndex == index;
    Color cardColor = Colors.white;
    Color textColor = AppColors.textMain;

    if (isAnswered) {
      if (index == question.correctOption) {
        cardColor = const Color(0xFF52B788); textColor = Colors.white;
      } else if (isSelected) {
        cardColor = const Color(0xFFEF5350); textColor = Colors.white;
      }
    } else if (isSelected) {
      cardColor = AppColors.primaryBlue.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () { if (!isAnswered) setState(() => selectedIndex = index); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: isAnswered ? [] : _softShadow,
          border: Border.all(color: (isSelected && !isAnswered) ? AppColors.primaryBlue : Colors.transparent, width: 2),
        ),
        child: Text(question.options[index], textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), boxShadow: (isAnswered || selectedIndex == null) ? [] : _softShadow),
            child: ElevatedButton(
              onPressed: (isAnswered || selectedIndex == null) ? null : _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: AppColors.primaryBlue, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: BorderSide(color: (selectedIndex != null && !isAnswered) ? AppColors.primaryBlue : Colors.transparent)),
              ),
              child: Text("Ответить", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isAnswered ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAnswered ? AppColors.primaryBlue : AppColors.primaryBlue.withOpacity(0.4), elevation: isAnswered ? 4 : 0, padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text((currentIndex == questions.length - 1) ? "Завершить" : "Далее", style: GoogleFonts.poppins(color: Colors.white.withOpacity(isAnswered ? 1.0 : 0.7), fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressPanel() {
    double progress = questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 20))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ваш прогресс", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18)),
              IconButton(icon: const Icon(Icons.close, size: 22), onPressed: () => setState(() => showProgress = false))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBadge("Верно: $correctAnswers", const Color(0xFF52B788)),
              _buildStatBadge("Ошибок: $wrongAnswers", const Color(0xFFEF5350)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: AppColors.background, valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue))),
          const SizedBox(height: 12),
          Text("Вопрос ${currentIndex + 1} из ${questions.length}", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}