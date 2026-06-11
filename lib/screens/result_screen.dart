import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'practice_screen.dart';
import 'history_screen.dart';

class ResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String timeSpent;
  final bool isExam; // <-- НОВЫЙ ПАРАМЕТР

  const ResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    this.isExam = false, // По умолчанию это практика
  });

  @override
  Widget build(BuildContext context) {
    bool isPassed = correctAnswers >= 32;

    Color mainColor = isPassed ? const Color(0xFF90D05E) : const Color(0xFFFEB504);
    Color secondaryColor = isPassed ? const Color(0xFF38934A) : const Color(0xFFD34827);
    Color progressBgColor = isPassed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);

    double percent = correctAnswers / totalQuestions;
    int percentInt = (percent * 100).round();

    // Динамический текст в зависимости от режима
    String titleText = isPassed ? "Поздравляем!" : "Увы, к сожалению...";
    String statusText = isPassed
        ? (isExam ? "Экзамен сдан" : "Практический тест сдан")
        : (isExam ? "Экзамен не сдан" : "Практический тест не сдан");

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // ВЕРХНИЙ ФОН: Сделали тоньше (160) и угол острее
          ClipPath(
            clipper: TopDiagonalClipper(),
            child: Container(
              height: 160,
              color: mainColor,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomDiagonalClipper(),
              child: Container(
                height: 120,
                color: secondaryColor,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                      ),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                      label: Text("Главная", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                Text(
                  titleText,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
                ),

                const SizedBox(height: 30),

                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15)),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: percent,
                        strokeWidth: 14,
                        backgroundColor: progressBgColor,
                        color: mainColor,
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Text(
                          "$percentInt%",
                          style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C6B)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  statusText,
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C6B)),
                ),

                const SizedBox(height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("$correctAnswers/$totalQuestions", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Результат", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                      Column(
                        children: [
                          Text(timeSpent, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Время", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6CE63),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            // Если это был экзамен, запускаем экзамен, иначе практику
                            if (isExam) {
                              // Сюда добавим переход на ExamScreen позже
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PracticeScreen()));
                            }
                          },
                          child: Text("Начать новый тест", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            // <-- ТЕПЕРЬ ОНА ПЕРЕКИДЫВАЕТ В ИСТОРИЮ
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HistoryScreen())
                            );
                          },
                          child: Text("Проверить результаты", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 100); // <-- УГОЛ СТАЛ ЕЩЕ ОСТРЕЕ
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 80);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}