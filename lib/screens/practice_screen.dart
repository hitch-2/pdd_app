import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_model.dart';
import '../services/db_helper.dart';
import '../theme.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<Question> questions = [];
  int currentIndex = 0;
  int? selectedIndex;
  bool isAnswered = false;
  bool showProgress = false;

  int correctAnswers = 0;
  int wrongAnswers = 0;

  // Та самая "дымка" (мягкая тень для объема)
  List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  void _loadSession() async {
    final data = await DBHelper.instance.getTestSession(40);
    setState(() => questions = data);
  }

  void _checkAnswer() async {
    if (selectedIndex == null || isAnswered) return;
    bool isCorrect = selectedIndex == questions[currentIndex].correctOption;

    // Считаем стату
    if (isCorrect) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    await DBHelper.instance.updateQuestionWeight(questions[currentIndex].id!, isCorrect);
    setState(() => isAnswered = true);
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      // Если вопросы еще есть — переключаем на следующий
      setState(() {
        currentIndex++;
        selectedIndex = null;
        isAnswered = false;
      });
    } else {
      // Если это был последний вопрос — показываем окно завершения
      showDialog(
        context: context,
        barrierDismissible: false, // Чтобы нельзя было закрыть кликом мимо
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
              "Тренировка завершена! 🎉",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
          ),
          content: Text(
            "Ты ответил на все ${questions.length} вопросов. Результаты сохранены для умного алгоритма.",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context); // Закрываем диалоговое окно
                Navigator.pop(context); // Возвращаемся в Главное меню
              },
              child: Text("В меню", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),

              // Область со скроллом (Вопрос + Варианты + Объяснение)
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

                      // Объяснение ответа (если ответил)
                      if (isAnswered && currentQuestion.explanation != null) ...[
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
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMain,
                                  ),
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

              // Фиксированная панель с кнопками внизу
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), // Отступ снизу чуть больше для красоты
                decoration: BoxDecoration(
                  color: AppColors.background,
                  // Можно добавить легкую тень сверху, чтобы отделить скролл, если хочешь:
                  // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: _buildControlButtons(),
              ),
            ],
          ),

          // Затемнение фона
          if (showProgress)
            GestureDetector(
              onTap: () => setState(() => showProgress = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black.withOpacity(0.2),
              ),
            ),

          // Анимированная панель прогресса
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            top: showProgress ? 140 : -300,
            left: 0,
            right: 0,
            child: _buildProgressPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              GestureDetector(
                onTap: () => setState(() => showProgress = !showProgress),
                child: Text(
                  "Практический тест", // <-- Поменяли название
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // <-- Заменили иконку на картинку
              IconButton(
                icon: Image.asset('assets/icons/ic_filter.png', width: 24, color: Colors.white),
                onPressed: () {}, // Можно добавить открытие фильтров в будущем
              ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow, // Добавили дымку
      ),
      child: Column(
        children: [
          Text(
            question.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          if (question.image != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/${question.image}',
                errorBuilder: (c, e, s) => Container(
                  height: 150,
                  color: AppColors.background,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
        cardColor = const Color(0xFF52B788);
        textColor = Colors.white;
      } else if (isSelected) {
        cardColor = const Color(0xFFEF5350);
        textColor = Colors.white;
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
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isAnswered ? [] : _softShadow, // Дымка только у неактивных
          border: Border.all(
            color: (isSelected && !isAnswered) ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          question.options[index],
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        // Кнопка "Ответить" — Белая с синим текстом и дымкой
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: (isAnswered || selectedIndex == null) ? [] : _softShadow,
            ),
            child: ElevatedButton(
              onPressed: (isAnswered || selectedIndex == null) ? null : _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                elevation: 0, // Тень мы сделали через Container выше
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(
                      color: (selectedIndex != null && !isAnswered)
                          ? AppColors.primaryBlue
                          : Colors.transparent
                  ),
                ),
              ),
              child: Text("Ответить", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Кнопка "Далее" — Синяя, тусклая пока не ответили
        Expanded(
          child: ElevatedButton(
            onPressed: isAnswered ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAnswered
                  ? AppColors.primaryBlue
                  : AppColors.primaryBlue.withOpacity(0.4), // Тусклый цвет
              elevation: isAnswered ? 4 : 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
                "Далее",
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(isAnswered ? 1.0 : 0.7),
                    fontWeight: FontWeight.w600
                )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressPanel() {
    double progress = questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 20)
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ваш прогресс", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => setState(() => showProgress = false),
              )
            ],
          ),

          // --- НОВЫЙ БЛОК СО СТАТИСТИКОЙ ---
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBadge("Верно: $correctAnswers", const Color(0xFF52B788)),
              _buildStatBadge("Ошибок: $wrongAnswers", const Color(0xFFEF5350)),
            ],
          ),
          // ---------------------------------

          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 12),
          Text(
              "Вопрос ${currentIndex + 1} из ${questions.length}",
              style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }

  // Вспомогательный виджет для красивых "плашек" статистики
  Widget _buildStatBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}