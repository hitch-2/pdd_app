import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String timeSpent;

  const ResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
  });

  @override
  Widget build(BuildContext context) {
    bool isPassed = correctAnswers >= 32;

    // Обновленный светло-оранжевый цвет
    Color mainColor = isPassed ? const Color(0xFF90D05E) : const Color(0xFFFEB504);
    Color secondaryColor = isPassed ? const Color(0xFF38934A) : const Color(0xFFD34827);
    Color progressBgColor = isPassed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);

    double percent = correctAnswers / totalQuestions;
    int percentInt = (percent * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // ВЕРХНИЙ ФОН: Поднят выше, угол острее
          ClipPath(
            clipper: TopDiagonalClipper(),
            child: Container(
              height: 180, // Сделали панель тоньше
              color: mainColor,
            ),
          ),

          // НИЖНИЙ ФОН: Опущен ниже, отзеркален, угол такой же острый
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomDiagonalClipper(),
              child: Container(
                height: 120, // Сделали панель тоньше
                color: secondaryColor,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Кнопка "Главная" (сделали крупнее)
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
                      label: Text("Главная", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)), // Увеличен шрифт
                    ),
                  ),
                ),

                // Spacer гибко заполняет пустоту, не давая элементам налезть на клипперы
                const Spacer(flex: 1),

                // Заголовок
                Text(
                  isPassed ? "Поздравляем!" : "Увы, к сожалению...",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
                ),

                const SizedBox(height: 30),

                // Круговой прогресс
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

                // Статус
                Text(
                  isPassed ? "Практический тест сдан" : "Практический тест не сдан",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C6B)),
                ),

                const SizedBox(height: 35),

                // Статистика (Результат и Время)
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

                const Spacer(flex: 2), // Отталкиваем кнопки от низа

                // Кнопки действий
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
                            // Пока возвращаемся на главную
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
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
                          onPressed: () {},
                          child: Text("Проверить результаты", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // Финальный отступ от самого низа
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Клиппер для верхнего фона
class TopDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 80); // Угол стал острее
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Клиппер для нижнего фона (теперь отзеркален!)
class BottomDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0); // Левый край ВЫШЕ
    path.lineTo(size.width, 80); // Правый край НИЖЕ
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}