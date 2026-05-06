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
    await DBHelper.instance.updateQuestionWeight(questions[currentIndex].id!, isCorrect);
    setState(() => isAnswered = true);
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        isAnswered = false;
      });
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
                      const SizedBox(height: 40),
                      _buildControlButtons(),
                    ],
                  ),
                ),
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

          // Анимированная панель прогресса (теперь опускается ниже — top: 140)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack, // Более приятная анимация "с отскоком"
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
                  "Practice Questions",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.notes, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
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
}