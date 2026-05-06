import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _carController;
  late AnimationController _rotateController;
  late Animation<double> _carAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Контроллер для машины
    _carController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Увеличиваем значения: от 2.5 (далеко справа) до -2.5 (далеко слева)
    // Это гарантирует, что машина полностью уйдет со сцены
    _carAnimation = Tween<double>(begin: 2.5, end: -2.5).animate(_carController);

    // 2. Контроллер для вращения логотипа
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Вращается бесконечно

    _runCarCycle();

    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  void _runCarCycle() async {
    if (!mounted) return;
    _carController.forward(from: 0);
    // Ждем 4 сек (проезд) + 1 сек пауза в "невидимости"
    await Future.delayed(const Duration(seconds: 5));
    _runCarCycle();
  }

  @override
  void dispose() {
    _carController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2FF),
      body: Stack(
        children: [
          // Верхняя часть: Название
          Positioned(
            top: 120, // Немного опустили
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                "DRIVE MASTER",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF8E94A3),
                ),
              ),
            ),
          ),

          // Город
          Align(
            alignment: Alignment.center,
            child: Image.asset('assets/icons/city.png', fit: BoxFit.contain),
          ),

          // Машина
          AnimatedBuilder(
            animation: _carAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment(_carAnimation.value, 0.25),
                child: Image.asset('assets/icons/car.png', width: 180),
              );
            },
          ),

          // Низ: Вращающееся лого вместо индикатора
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                RotationTransition(
                  turns: _rotateController,
                  child: Image.asset('assets/icons/logo.png', width: 60, height: 60),
                ),
                const SizedBox(height: 15),
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