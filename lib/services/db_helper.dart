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
    _database = await _initDB('pdd_exam_v2,1.db'); // Версия 6
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

    // Таблица истории тестов
    await db.execute('''
      CREATE TABLE test_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        test_type TEXT,
        correct_answers INTEGER,
        total_questions INTEGER,
        time_spent TEXT,
        is_passed INTEGER,
        date TEXT,
        answers_data TEXT -- <-- НОВОЕ ПОЛЕ ДЛЯ ДЕТАЛЕЙ ОТВЕТОВ
      )
    ''');
  }

  // Метод импорта из JSON
  Future<void> importQuestionsFromJson() async {
    final db = await instance.database;

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

  // Алгоритм умного повторения
  Future<List<Question>> getSmartQuestions(int limit) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT * FROM questions 
      ORDER BY (weight * (RANDOM() % 100)) DESC 
      LIMIT ?
    ''', [limit]);

    return result.map((json) => Question.fromMap(json)).toList();
  }

  Future<List<Question>> getTestSession(int limit) async {
    final db = await instance.database;
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
      await db.execute('UPDATE questions SET weight = MAX(1, weight - 1) WHERE id = ?', [id]);
    } else {
      await db.execute('UPDATE questions SET weight = weight + 3 WHERE id = ?', [id]);
    }
  }

  // --- НОВЫЕ МЕТОДЫ ДЛЯ ИСТОРИИ ТЕСТОВ ---

  // Сохранение результата теста
  Future<void> saveTestResult({
    required String testType,
    required int correctAnswers,
    required int totalQuestions,
    required String timeSpent,
    required bool isPassed,
    required String answersData,
  }) async {
    final db = await instance.database;
    await db.insert('test_history', {
      'test_type': testType,
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'time_spent': timeSpent,
      'is_passed': isPassed ? 1 : 0,
      'date': DateTime.now().toIso8601String(),
      'answers_data': answersData,
    });
  }

  // Получение всей истории
  Future<List<Map<String, dynamic>>> getTestHistory() async {
    final db = await instance.database;
    return await db.query('test_history', orderBy: 'id DESC');
  }
}