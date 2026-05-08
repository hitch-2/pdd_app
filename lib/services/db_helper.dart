import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pdd_exam_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Получаем пачку из 40 умных вопросов для теста
  Future<List<Question>> getTestSession(int limit) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT * FROM questions 
    ORDER BY (weight * (RANDOM() % 100)) DESC 
    LIMIT ?
  ''', [limit]);

    return result.map((json) => Question.fromMap(json)).toList();
  }

  Future _createDB(Database db, int version) async {
    // Таблица вопросов
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        image TEXT,
        options TEXT NOT NULL,
        correct_option INTEGER NOT NULL,
        weight INTEGER DEFAULT 1,
        explanation TEXT
      )
    ''');

    // Таблица статистики (для истории ответов)
    await db.execute('''
      CREATE TABLE statistics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER,
        is_correct INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (question_id) REFERENCES questions (id)
      )
    ''');
  }

  // Метод импорта из JSON (Инструкция 6)
  Future<void> importQuestionsFromJson() async {
    final db = await instance.database;

    // Проверяем, не пуста ли база, чтобы не дублировать
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM questions'));
    if (count! > 0) return;

    final String response = await rootBundle.loadString('assets/data/questions.json');
    final List<dynamic> data = json.decode(response);

    for (var item in data) {
      await db.insert('questions', {
        'text': item['text'],
        'image': item['image'],
        'options': (item['options'] as List).join('|'),
        'correct_option': item['correct_option'],
        'weight': 1,
        'explanation': item['explanation'],
      });
    }
  }

  // Алгоритм умного повторения (Инструкция 4)
  // Выбираем вопросы, где вес больше, с помощью случайной сортировки по весу
  Future<List<Question>> getSmartQuestions(int limit) async {
    final db = await instance.database;
    // Логика: сортируем по (weight * random). Чем больше вес, тем выше шанс оказаться в топе.
    final result = await db.rawQuery('''
      SELECT * FROM questions 
      ORDER BY (weight * (RANDOM() % 100)) DESC 
      LIMIT ?
    ''', [limit]);

    return result.map((json) => Question.fromMap(json)).toList();
  }

  // Обновление веса при ответе
  Future<void> updateQuestionWeight(int id, bool isCorrect) async {
    final db = await instance.database;
    if (isCorrect) {
      // Если ответил верно — уменьшаем вес (минимум 1)
      await db.execute('UPDATE questions SET weight = MAX(1, weight - 1) WHERE id = ?', [id]);
    } else {
      // Если ошибся — увеличиваем вес, чтобы вопрос выпадал чаще
      await db.execute('UPDATE questions SET weight = weight + 3 WHERE id = ?', [id]);
    }
  }
}