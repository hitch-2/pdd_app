import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdd_app_172/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/db_helper.dart';
import '../theme.dart';
import '../services/sync_service.dart';

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
  double _readinessPercent = 0.0;

  // --- ПЕРЕМЕННЫЕ ДЛЯ АВТОРИЗАЦИИ ---
  bool _isLoading = false;
  bool _isLoginMode = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Проверка, вошел ли пользователь в систему
  User? get _user => Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _loadProfileData();
      _loadStatistics();
    }
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Студент";
      _imagePath = prefs.getString('user_image');
      _nameController.text = _userName;
    });
  }

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
      setState(() => _readinessPercent = totalCorrect / totalQuestions);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image', image.path);
      setState(() => _imagePath = image.path);
      widget.onProfileUpdated();
    }
  }

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() => _userName = name);
    widget.onProfileUpdated();
  }

  // --- ЛОГИКА SUPABASE ---
  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Регистрация успешна! Теперь войдите.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      setState(() => _isLoginMode = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _loadProfileData();
      _loadStatistics();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка входа: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {}); // Перерисует интерфейс на форму входа
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _user == null ? _buildAuthView() : _buildProfileView(),
      ),
    );
  }

  // ВИДЖЕТ: ФОРМА ВХОДА И РЕГИСТРАЦИИ
  Widget _buildAuthView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_isLoginMode ? "Вход" : "Регистрация", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Email",
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Пароль (от 6 символов)",
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator(color: AppColors.primaryBlue)
        else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoginMode ? _signIn : _signUp,
              child: Text(_isLoginMode ? "Войти" : "Создать аккаунт", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
            child: Text(_isLoginMode ? "Нет аккаунта? Зарегистрироваться" : "Уже есть аккаунт? Войти", style: GoogleFonts.poppins(color: Colors.grey)),
          )
        ]
      ],
    );
  }

  // ВИДЖЕТ: ПРОФИЛЬ АВТОРИЗОВАННОГО ПОЛЬЗОВАТЕЛЯ
  Widget _buildProfileView() {
    int displayPercent = (_readinessPercent * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Профиль", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ],
        ),
        Text(_user!.email ?? "", style: GoogleFonts.poppins(fontSize: 12, color: Colors.green)), // Показываем email
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
        const SizedBox(height: 24),

        // НОВЫЕ КНОПКИ ДЛЯ СИНХРОНИЗАЦИИ (Логику напишем во 2-й части)
        OutlinedButton.icon(
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              await SyncService.syncTestHistory();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("История успешно сохранена в облаке!"), backgroundColor: Colors.green));
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
            }
            setState(() => _isLoading = false);
          },
          icon: const Icon(Icons.cloud_sync, color: AppColors.primaryBlue),
          label: const Text("Синхронизировать историю"),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue, minimumSize: const Size(double.infinity, 45)),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              bool wasUpdated = await SyncService.checkAndDownloadUpdates();
              if (mounted) {
                if (wasUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("База ПДД успешно обновлена!"), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("У вас установлена самая актуальная версия."), backgroundColor: Colors.blue));
                }
              }
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
            }
            setState(() => _isLoading = false);
          },
          icon: const Icon(Icons.system_update_alt, color: Colors.white),
          label: const Text("Проверить обновления ПДД"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF52B788), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45)),
        ),

        const SizedBox(height: 24),
        Text("Готовность к экзамену", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: _readinessPercent,
                strokeWidth: 8,
                backgroundColor: AppColors.background,
                color: const Color(0xFF52B788),
              ),
            ),
            Text("$displayPercent%", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          ],
        ),
        const SizedBox(height: 20),

        TextButton(
          onPressed: _signOut,
          child: Text("Выйти из аккаунта", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}