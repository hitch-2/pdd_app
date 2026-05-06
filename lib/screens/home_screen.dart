import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), // Светло-серый фон как в Figma
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/icons/ic_avatar_default.png'),
          ),
        ),
        title: const Text(
          "Главная",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildMenuCard(
            title: "Практические вопросы",
            iconPath: "assets/icons/ic_practice.png",
            color: const Color(0xFF4A69FF), // Синий
            onTap: () {},
          ),
          _buildMenuCard(
            title: "Тесты",
            iconPath: "assets/icons/ic_tests.png",
            color: const Color(0xFFFFC107), // Желтый
            onTap: () {},
          ),
          _buildMenuCard(
            title: "Дорожные знаки",
            iconPath: "assets/icons/ic_signs.png",
            color: const Color(0xFF38B48C), // Зеленый
            onTap: () {},
          ),
          _buildMenuCard(
            title: "Обучение",
            iconPath: "assets/icons/ic_education.png",
            color: const Color(0xFFFF5252), // Красный
            onTap: () {},
          ),
          _buildMenuCard(
            title: "История тестирования",
            iconPath: "assets/icons/ic_history.png",
            color: const Color(0xFFD4A373), // Коричневый
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Вспомогательный метод для создания карточек (Инструкция 5)
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), // Светлый фон для иконки
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(iconPath, width: 30, height: 30),
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