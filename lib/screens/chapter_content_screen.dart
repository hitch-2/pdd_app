import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ChapterContentScreen extends StatelessWidget {
  final String chapterTitle;
  // Структура: {"type": "text" или "image", "content": "Текст" или "имя_файла.png"}
  final List<Map<String, String>> contentBlocks;

  const ChapterContentScreen({
    super.key,
    required this.chapterTitle,
    required this.contentBlocks,
  });

  @override
  Widget build(BuildContext context) {
    const Color studyColor = Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Красный заголовок
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              color: studyColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          chapterTitle,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // баланс
                  ],
                ),
              ),
            ),
          ),

          // Читалка
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contentBlocks.map((block) {
                    if (block['type'] == 'text') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          block['content']!,
                          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textMain, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                      );
                    } else if (block['type'] == 'image') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/${block['content']}',
                              fit: BoxFit.contain,
                              // Заглушка, если картинки пока нет в папке
                              errorBuilder: (c, e, s) => Container(
                                padding: const EdgeInsets.all(20),
                                color: AppColors.background,
                                child: Text("Тут будет картинка: ${block['content']}", style: GoogleFonts.poppins(color: Colors.grey)),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}