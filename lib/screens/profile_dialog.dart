import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/db_helper.dart'; // Подключили БД
import '../theme.dart';

class ProfileDialog extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const ProfileDialog({super.key, required this.onProfileUpdated});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  String _userName = "Студент";
  String? _imagePath;
  final TextEditingController _nameController = TextEditingController();

  double _readinessPercent = 0.0; // Реальный процент

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadStatistics(); // Загружаем стату при открытии
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Студент";
      _imagePath = prefs.getString('user_image');
      _nameController.text = _userName;
    });
  }

  // ВЫСЧИТЫВАЕМ РЕАЛЬНУЮ СТАТИСТИКУ ИЗ БАЗЫ
  Future<void> _loadStatistics() async {
    final history = await DBHelper.instance.getTestHistory();
    if (history.isEmpty) return;

    int totalCorrect = 0;
    int totalQuestions = 0;

    for (var item in history) {
      totalCorrect += (item['correct_answers'] as int);
      totalQuestions += (item['total_questions'] as int);
    }

    if (totalQuestions > 0) {
      setState(() {
        _readinessPercent = totalCorrect / totalQuestions;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image', image.path);
      setState(() {
        _imagePath = image.path;
      });
      widget.onProfileUpdated();
    }
  }

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() {
      _userName = name;
    });
    widget.onProfileUpdated();
  }

  @override
  Widget build(BuildContext context) {
    int displayPercent = (_readinessPercent * 100).toInt();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Профиль", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                    child: _imagePath == null ? const Icon(Icons.person, size: 50, color: AppColors.primaryBlue) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "Ваше имя",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _saveName,
            ),
            const SizedBox(height: 30),

            Text("Готовность к экзамену", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: _readinessPercent, // ДИНАМИЧЕСКОЕ ЗНАЧЕНИЕ
                    strokeWidth: 10,
                    backgroundColor: AppColors.background,
                    color: const Color(0xFF52B788),
                  ),
                ),
                Text("$displayPercent%", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}