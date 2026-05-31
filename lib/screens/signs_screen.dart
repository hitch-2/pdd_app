import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'chapter_content_screen.dart';

class SignsScreen extends StatefulWidget {
  const SignsScreen({super.key});

  @override
  State<SignsScreen> createState() => _SignsScreenState();
}

class _SignsScreenState extends State<SignsScreen> {
  List<Map<String, dynamic>> signsChapters = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    try {
      final String response = await rootBundle.loadString('assets/data/signs.json');
      final data = json.decode(response);

      if (!mounted) return;

      setState(() {
        signsChapters = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      debugPrint("ОШИБКА ЗАГРУЗКИ ЗНАКОВ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color headerColor = Color(0xFF38B48C); // Зеленый цвет знаков

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Зеленый заголовок
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: headerColor,
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
                      "Дорожные знаки",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Контент
          Expanded(
            child: _buildBodyContent(headerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(Color headerColor) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: headerColor));
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "Ошибка загрузки данных!\n\n$errorMessage",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      );
    }

    if (signsChapters.isEmpty) {
      return Center(
        child: Text("База знаков пуста.", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: signsChapters.length,
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
                  contentBlocks = (signsChapters[index]["content"] as List)
                      .map((item) => Map<String, String>.from(item as Map))
                      .toList();
                } catch (e) {
                  debugPrint("Ошибка парсинга контента знаков: $e");
                }

                // Переиспользуем наш крутой экран читалки!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterContentScreen(
                      chapterTitle: signsChapters[index]["title"] ?? "Глава",
                      contentBlocks: contentBlocks,
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
                        color: headerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Иконка треугольного знака
                      child: Icon(Icons.warning_amber_rounded, color: headerColor, size: 34),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        signsChapters[index]["title"] ?? "Категория",
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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