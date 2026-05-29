import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class HistoryDetailsScreen extends StatelessWidget {
  final String testType;
  final List<dynamic> answers;

  const HistoryDetailsScreen({
    super.key,
    required this.testType,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    const Color headerColor = Color(0xFFE88A4A);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
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
                      testType,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: answers.length,
              itemBuilder: (context, index) {
                final item = answers[index];
                bool isCorrect = item['is_correct'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect ? const Color(0xFF52B788) : const Color(0xFFEF5350),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${index + 1}. ", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          Expanded(
                            child: Text(
                              item['question_text'],
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textMain),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAnswerRow("Твой ответ:", item['user_answer'], isCorrect ? const Color(0xFF52B788) : const Color(0xFFEF5350)),
                      if (!isCorrect) ...[
                        const SizedBox(height: 8),
                        _buildAnswerRow("Верный ответ:", item['correct_answer'], const Color(0xFF52B788)),
                      ]
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label ", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}