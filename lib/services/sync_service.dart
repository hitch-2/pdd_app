import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db_helper.dart';


class SyncService {
  static final _supabase = Supabase.instance.client;

  // 1. Проверка и скачивание обновлений ПДД
  static Future<bool> checkAndDownloadUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    int localVersion = prefs.getInt('data_version') ?? 0;

    try {
      // Смотрим, какая версия базы сейчас в облаке
      final response = await _supabase.from('app_metadata').select('data_version').eq('id', 1).single();
      int serverVersion = response['data_version'] as int;

      if (serverVersion > localVersion) {
        // Версия в облаке новее! Качаем всё из БД
        final questions = await _supabase.from('questions').select();
        final rules = await _supabase.from('rules').select();
        final signs = await _supabase.from('signs').select();

        // Сохраняем скачанное как текст в кэш телефона
        await prefs.setString('cache_questions', jsonEncode(questions));
        await prefs.setString('cache_rules', jsonEncode(rules));
        await prefs.setString('cache_signs', jsonEncode(signs));

        // Запоминаем новую версию
        await prefs.setInt('data_version', serverVersion);
        return true; // Обновление прошло успешно
      }
      return false; // Обновлений нет, у нас и так свежая база
    } catch (e) {
      debugPrint('Ошибка скачивания обновлений: $e');
      throw Exception('Не удалось проверить обновления. Проверьте интернет.');
    }
  }

  // 2. Синхронизация истории (Берем из телефона -> Кидаем в облако)
  static Future<void> syncTestHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Сначала войдите в аккаунт");

    try {
      final localHistory = await DBHelper.instance.getTestHistory();

      for (var item in localHistory) {
        // Проверяем по дате, есть ли уже этот тест в облаке (чтобы не дублировать)
        final exists = await _supabase
            .from('test_history')
            .select('id')
            .eq('date', item['date'])
            .eq('user_id', user.id)
            .maybeSingle();

        if (exists == null) {
          // Если в облаке его нет — загружаем!
          await _supabase.from('test_history').insert({
            'user_id': user.id,
            'test_type': item['test_type'],
            'correct_answers': item['correct_answers'],
            'total_questions': item['total_questions'],
            'time_spent': item['time_spent'],
            'is_passed': item['is_passed'],
            'date': item['date'],
            'answers_data': item['answers_data'],
          });
        }
      }
    } catch (e) {
      debugPrint('Ошибка синхронизации истории: $e');
      throw Exception('Не удалось синхронизировать историю.');
    }
  }
}