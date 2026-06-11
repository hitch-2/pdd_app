import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'practice_screen.dart';
import 'exam_screen.dart';
import 'history_screen.dart';
import 'study_screen.dart';
import 'signs_screen.dart';
import 'profile_dialog.dart'; // Наш новый файл профиля

// 1. Превратили экран в StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userImagePath;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  // Загружаем сохраненный путь к картинке профиля
  void _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userImagePath = prefs.getString('user_image');
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF4A69FF); // Основной синий из Figma

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), // Светло-серый фон как в Figma
      body: Column(
        children: [
          // Кастомный синий заголовок
          Container(
            color: primaryBlue,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    // --- ИНТЕРАКТИВНАЯ АВАТАРКА ---
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ProfileDialog(
                            onProfileUpdated: _loadAvatar, // Обновляем картинку при закрытии
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: _userImagePath != null ? FileImage(File(_userImagePath!)) : null,
                        // Если картинки нет, показываем иконку человечка
                        child: _userImagePath == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                    // ------------------------------

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
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            backgroundColor: Colors.white,
                            title: Text("О приложении", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Разработчик: Абилькасым (byabi)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 10),
                                Text("Дипломный проект по изучению ПДД Республики Казахстан.\nВерсия: 1.0.0", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Закрыть", style: GoogleFonts.poppins(color: const Color(0xFF4A69FF), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Список карточек
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
                  title: "Экзамен",
                  iconPath: "assets/icons/ic_tests.png",
                  color: const Color(0xFFFFC107),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExamScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: "Дорожные знаки",
                  iconPath: "assets/icons/ic_signs.png",
                  color: const Color(0xFF38B48C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignsScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: "Обучение",
                  iconPath: "assets/icons/ic_education.png",
                  color: const Color(0xFFFF5252),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudyScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: "История тестирования",
                  iconPath: "assets/icons/ic_history.png",
                  color: const Color(0xFFD4A373),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Метод для создания карточек
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
        borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.all(4),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(iconPath, fit: BoxFit.contain),
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