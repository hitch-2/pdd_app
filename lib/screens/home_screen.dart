import 'package:flutter/material.dart';
import 'package:pdd_app_172/screens/practice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF4A69FF); // Основной синий из Figma

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), // Светло-серый фон как в Figma
      body: Column(
        children: [
          // 1. Кастомный синий заголовок (вместо AppBar)
          Container(
            color: primaryBlue,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/icons/ic_avatar_default.png'),
                      radius: 20,
                    ),
                    const Expanded(
                      child: Text(
                        "Главная",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, // Белый текст
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white), // Белая иконка
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Список карточек
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildMenuCard(
                  title: "Практический тест",
                  iconPath: "assets/icons/ic_practice.png",
                  color: primaryBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PracticeScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: "Эгзамен",
                  iconPath: "assets/icons/ic_tests.png",
                  color: const Color(0xFFFFC107),
                  onTap: () {},
                ),
                _buildMenuCard(
                  title: "Дорожные знаки",
                  iconPath: "assets/icons/ic_signs.png",
                  color: const Color(0xFF38B48C),
                  onTap: () {},
                ),
                _buildMenuCard(
                  title: "Обучение",
                  iconPath: "assets/icons/ic_education.png",
                  color: const Color(0xFFFF5252),
                  onTap: () {},
                ),
                _buildMenuCard(
                  title: "История тестирования",
                  iconPath: "assets/icons/ic_history.png",
                  color: const Color(0xFFD4A373),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Исправленный метод для создания карточек (Инструкция 5)
  Widget _buildMenuCard({
    required String title,
    required String iconPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Увеличенные углы карточки
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          // --- ИСПРАВЛЕНИЯ ЗДЕСЬ ---
          padding: const EdgeInsets.all(4), // Уменьшили отступ рамки
          width: 50, // Увеличили общий размер контейнера
          height: 50,
          // --------------------------
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12), // Скругление рамки
          ),
          child: Image.asset(iconPath, fit: BoxFit.contain), // Иконка теперь больше внутри
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}