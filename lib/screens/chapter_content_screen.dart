import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ChapterContentScreen extends StatefulWidget {
  final String chapterTitle;
  final List<Map<String, String>> contentBlocks;
  final Color headerColor; // <-- ТЕПЕРЬ ЦВЕТ ПЕРЕДАЕТСЯ ИЗВНЕ!

  const ChapterContentScreen({
    super.key,
    required this.chapterTitle,
    required this.contentBlocks,
    required this.headerColor,
  });

  @override
  State<ChapterContentScreen> createState() => _ChapterContentScreenState();
}

class _ChapterContentScreenState extends State<ChapterContentScreen> {
  double _fontSize = 15.0; // Для зума текста
  bool _isTitleExpanded = false; // Для раскрытия заголовка

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Шапка
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: widget.headerColor, // Используем переданный цвет
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isTitleExpanded = !_isTitleExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          // Анимация раскрытия
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            alignment: Alignment.topCenter,
                            child: Text(
                              widget.chapterTitle,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: _isTitleExpanded ? null : 2,
                              overflow: _isTitleExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Кнопки зума текста
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.text_increase, color: Colors.white),
                          onPressed: () { if (_fontSize < 30) setState(() => _fontSize += 2); },
                        ),
                        IconButton(
                          icon: const Icon(Icons.text_decrease, color: Colors.white),
                          onPressed: () { if (_fontSize > 10) setState(() => _fontSize -= 2); },
                        ),
                      ],
                    ),
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
                  children: widget.contentBlocks.map((block) {
                    if (block['type'] == 'text') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          block['content']!,
                          style: GoogleFonts.poppins(fontSize: _fontSize, color: AppColors.textMain, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                      );
                    } else if (block['type'] == 'image') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              // <-- ОТКРЫТИЕ ФОТО НА ВЕСЬ ЭКРАН С ЗУМОМ
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenImage(imagePath: 'assets/images/${block['content']}'),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/${block['content']}',
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
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

// Виджет для полноэкранного просмотра картинок
class FullScreenImage extends StatelessWidget {
  final String imagePath;
  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0, // Увеличение в 4 раза
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}