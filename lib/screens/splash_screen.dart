import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';
import 'home_screen.dart'; // Путь к TrainingScreen или главному меню

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _carAnimation;

  @override
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Время в пути
      vsync: this,
    );

    // Машина едет справа (1.5) налево (-1.5)
    _carAnimation = Tween<double>(begin: 1.5, end: -1.5).animate(_controller);

    // Запускаем цикл анимации с паузой
    _runCarCycle();

    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  // Метод для создания цикла "проезд -> пауза -> проезд"
  void _runCarCycle() async {
    if (!mounted) return; // Проверка, что экран еще открыт
    _controller.forward(from: 0); // Запуск проезда
    await Future.delayed(const Duration(seconds: 4)); // 3 сек едет + 1 сек пауза
    _runCarCycle(); // Повтор
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