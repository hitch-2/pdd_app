import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'chapter_content_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<Map<String, dynamic>> chapters = [];
  bool isLoading = true;
  String? errorMessage; // Хранилище для текста ошибки

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      // 1. Загружаем текст из файла
      final String response = await rootBundle.loadString('assets/data/rules.json');

      // 2. Превращаем текст в JSON
      final data = json.decode(response);

      if (!mounted) return;

      setState(() {
        chapters = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Если что-то пошло не так, выводим ошибку на экран!
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      debugPrint("ОШИБКА ЗАГРУЗКИ ПДД: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color studyColor = Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Заголовок
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: studyColor,
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
                    Text(
                      "Обучение",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Контент (список или текст ошибки)
          Expanded(
            child: _buildBodyContent(studyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(Color studyColor) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: studyColor));
    }

    // ЕСЛИ ЕСТЬ ОШИБКА — ПОКАЗЫВАЕМ ЕЁ НА ЭКРАНЕ
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "Не удалось загрузить правила!\n\n$errorMessage",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      );
    }

    if (chapters.isEmpty) {
      return Center(
        child: Text("Список правил пуст.", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                List<Map<String, String>> contentBlocks = [];
                try {
                  contentBlocks = (chapters[index]["content"] as List)
                      .map((item) => Map<String, String>.from(item as Map))
                      .toList();
                } catch (e) {
                  debugPrint("Ошибка парсинга контента главы: $e");
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterContentScreen(
                      chapterTitle: chapters[index]["title"] ?? "Глава",
                      contentBlocks: contentBlocks,
                      headerColor: const Color(0xFFFF52520),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: studyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.menu_book, color: studyColor, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapters[index]["title"] ?? "Глава",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMain),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chapters[index]["time"] ?? "10 мин",
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}