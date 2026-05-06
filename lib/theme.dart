import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F5F5); // Цвет фона экрана
  static const Color primary = Color(0xFF2D5BD0);    // Основной синий (пример)
  static const Color accent = Color(0xFFFFD600);     // Акцентный, например для кнопок
  static const Color white = Colors.white;
  static const Color textMain = Color(0xFF1A1A1B);
}

class AppStyles {
  // Стиль для карточки вопроса
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Текстовый стиль заголовка
  static const TextStyle questionText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );
}