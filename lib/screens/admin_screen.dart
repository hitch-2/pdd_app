import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _supabase = Supabase.instance.client;
  String _selectedTable = 'questions';
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from(_selectedTable).select().order('id', ascending: true);
      setState(() => _items = response);
    } catch (e) {
      debugPrint("Ошибка загрузки данных админки: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _bumpDatabaseVersion() async {
    try {
      final res = await _supabase.from('app_metadata').select('data_version').eq('id', 1).single();
      int currentVersion = res['data_version'] as int;
      await _supabase.from('app_metadata').update({'data_version': currentVersion + 1}).eq('id', 1);
    } catch (e) {
      debugPrint("Не удалось обновить версию БД: $e");
    }
  }

  void _showEditDialog(Map<String, dynamic>? item) {
    bool isNew = item == null;
    Map<String, dynamic> data = isNew ? {} : Map.from(item);

    // Подготовка контроллеров
    final textCtrl = TextEditingController(text: data['text'] ?? data['title'] ?? '');
    final contentCtrl = TextEditingController(text: isNew ? '' : jsonEncode(data['content'] ?? '[]'));

    // Специфично для вопросов
    final imageCtrl = TextEditingController(text: data['image'] ?? '');
    final correctCtrl = TextEditingController(text: data['correct_option']?.toString() ?? '0');

    // Разбиваем строку options на 4 варианта
    List<String> opts = (data['options'] ?? '|||').split('|');
    while(opts.length < 4) opts.add(''); // Защита от пустых значений
    final opt1Ctrl = TextEditingController(text: opts[0]);
    final opt2Ctrl = TextEditingController(text: opts[1]);
    final opt3Ctrl = TextEditingController(text: opts[2]);
    final opt4Ctrl = TextEditingController(text: opts[3]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isNew ? "Создать запись" : "Редактировать ID: ${data['id']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Текст (Вопрос или Название)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),

                // ЕСЛИ РЕДАКТИРУЕМ ВОПРОСЫ
                if (_selectedTable == 'questions') ...[
                  TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(labelText: "Картинка (Файл или ссылка http...)", border: OutlineInputBorder(), hintText: "Оставьте пустым, если фото нет"),
                  ),
                  const SizedBox(height: 12),
                  const Text("Варианты ответов:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: opt1Ctrl, decoration: const InputDecoration(labelText: "Вариант 1 (Индекс 0)", isDense: true, border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: opt2Ctrl, decoration: const InputDecoration(labelText: "Вариант 2 (Индекс 1)", isDense: true, border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: opt3Ctrl, decoration: const InputDecoration(labelText: "Вариант 3 (Индекс 2)", isDense: true, border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: opt4Ctrl, decoration: const InputDecoration(labelText: "Вариант 4 (Индекс 3)", isDense: true, border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                    controller: correctCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Номер верного ответа (от 0 до 3)", border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFE8F5E9)),
                  ),
                ],

                // ЕСЛИ РЕДАКТИРУЕМ ОБУЧЕНИЕ/ЗНАКИ
                if (_selectedTable != 'questions') ...[
                  TextField(
                    controller: contentCtrl,
                    maxLines: 10,
                    decoration: const InputDecoration(labelText: "Контент (в формате JSON)", border: OutlineInputBorder()),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A69FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              try {
                Map<String, dynamic> payload = {};

                if (_selectedTable == 'questions') {
                  // Склеиваем 4 варианта обратно в строку с разделителем "|"
                  String mergedOptions = [opt1Ctrl.text, opt2Ctrl.text, opt3Ctrl.text, opt4Ctrl.text].join('|');
                  payload = {
                    'text': textCtrl.text,
                    'image': imageCtrl.text.isEmpty ? null : imageCtrl.text,
                    'options': mergedOptions,
                    'correct_option': int.parse(correctCtrl.text),
                  };
                } else {
                  payload = {
                    'title': textCtrl.text,
                    'content': jsonDecode(contentCtrl.text),
                  };
                }

                if (isNew) {
                  await _supabase.from(_selectedTable).insert(payload);
                } else {
                  await _supabase.from(_selectedTable).update(payload).eq('id', data['id']);
                }

                await _bumpDatabaseVersion();
                Navigator.pop(context);
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Сохранено! Обновление выпущено."), backgroundColor: Colors.green));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка сохранения: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Сохранить", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), // Серо-синий фон
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A69FF),
        title: Text("Панель управления", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Вкладки переключения
          Container(
            color: const Color(0xFF4A69FF),
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                _buildTab('Вопросы', 'questions'),
                const SizedBox(width: 8),
                _buildTab('Обучение', 'rules'),
                const SizedBox(width: 8),
                _buildTab('Знаки', 'signs'),
              ],
            ),
          ),

          // Список карточек
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // Белоснежные плашки
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                        item['text'] ?? item['title'] ?? 'Без названия',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: const Color(0xFF333333))
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text("ID: ${item['id']}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(color: const Color(0xFFF2F5F9), borderRadius: BorderRadius.circular(8)),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF4A69FF)),
                        onPressed: () => _showEditDialog(item),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A69FF),
        onPressed: () => _showEditDialog(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Обновленный дизайн кнопок переключения (Tabs)
  Widget _buildTab(String label, String tableValue) {
    bool isActive = _selectedTable == tableValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTable = tableValue);
          _loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
              label,
              style: GoogleFonts.poppins(
                  color: isActive ? const Color(0xFF4A69FF) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
              )
          ),
        ),
      ),
    );
  }
}