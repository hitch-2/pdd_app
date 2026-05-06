import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart'; // Путь к TrainingScreen или главному меню

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _carAnimation;

  @override
  void initState() {
    super.initState();

    // Настройка анимации машины на 3 секунды
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Повторяем бесконечно

    // Анимация движения: от -1.5 (за левым краем) до 1.5 (за правым)
    _carAnimation = Tween<double>(begin: 1.5, end: -1.5).animate(_controller);

    // Таймер перехода на следующий экран (через 4 секунды)
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TrainingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2FF), // Цвет фона
      body: Stack(
        children: [
          // 1. Название приложения сверху
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/icons/logo.png', width: 100),
                const Text(
                  "DRIVE MASTER",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Color(0xFF8E94A3),
                  ),
                ),
              ],
            ),
          ),

          // 2. Статичный город (по центру/ниже центра)
          Align(
            alignment: Alignment.center,
            child: Image.asset('assets/icons/city.png', fit: BoxFit.contain),
          ),

          // 3. Анимированная машина
          AnimatedBuilder(
            animation: _carAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment(_carAnimation.value, 0.25), // Позиция машины
                child: Image.asset('assets/icons/car.png', width: 180),
              );
            },
          ),

          // 4. Индикатор загрузки и текст снизу
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 20),
                Text(
                  "Wait a second...",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}