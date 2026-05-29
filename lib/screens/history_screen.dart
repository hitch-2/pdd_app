import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert'; // Для расшифровки JSON
import '../services/db_helper.dart';
import '../theme.dart';
import 'history_details_screen.dart'; // Наш новый экран деталей

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final data = await DBHelper.instance.getTestHistory();
    setState(() {
      history = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color headerColor = Color(0xFFE88A4A); // Оранжевый из макета

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Оранжевый заголовок
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
                      "История тестов",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Список карточек
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                ? Center(child: Text("Вы еще не проходил тесты", style: GoogleFonts.poppins(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                bool isPassed = item['is_passed'] == 1;

                Color bgColor = isPassed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
                Color statusColor = isPassed ? const Color(0xFF38934A) : const Color(0xFFD34827);
                String statusText = isPassed ? "СДАН" : "НЕ СДАН";

                return GestureDetector(
                  onTap: () {
                    // 1. Достаем строку с ответами из базы (если её нет, берем пустой список "[]")
                    String rawData = item['answers_data'] ?? "[]";
                    List<dynamic> parsedAnswers = [];

                    try {
                      // 2. Превращаем строку обратно в список
                      parsedAnswers = jsonDecode(rawData);
                    } catch (e) {
                      debugPrint("Ошибка парсинга истории: $e");
                    }

                    // 3. Если ответы есть — открываем экран деталей
                    if (parsedAnswers.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryDetailsScreen(
                            testType: item['test_type'] ?? "Тест",
                            answers: parsedAnswers,
                          ),
                        ),
                      );
                    } else {
                      // Если ты проходил этот тест до того, как мы добавили детальное сохранение
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Детали для этого теста не найдены")),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        // Добавим легкую тень для объема
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4)
                          )
                        ]
                    ),
                    child: Column(
                      children: [
                        _buildHistoryRow("Статус теста", statusText, valueColor: statusColor, isBold: true),
                        const SizedBox(height: 12),
                        _buildHistoryRow("Тип", item['test_type'] ?? "Неизвестно"),
                        const SizedBox(height: 12),
                        _buildHistoryRow("Правильных ответов", "${item['correct_answers']}/${item['total_questions']}"),
                        const SizedBox(height: 12),
                        _buildHistoryRow("Затраченное время", "${item['time_spent']} мин"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: const Color(0xFF555555), fontSize: 14, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: valueColor ?? AppColors.textMain,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}