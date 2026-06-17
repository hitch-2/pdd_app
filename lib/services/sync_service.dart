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
      // ИСПОЛЬЗУЕМ maybeSingle(), чтобы не было ошибки "0 rows"
      final response = await _supabase.from('app_metadata').select('data_version').eq('id', 1).maybeSingle();

      if (response == null) {
        debugPrint('Таблица версий пуста или недоступна.');
        return false;
      }

      int serverVersion = response['data_version'] as int;

      if (serverVersion > localVersion) {
        final questions = await _supabase.from('questions').select();
        final rules = await _supabase.from('rules').select();
        final signs = await _supabase.from('signs').select();

        await prefs.setString('cache_questions', jsonEncode(questions));
        await prefs.setString('cache_rules', jsonEncode(rules));
        await prefs.setString('cache_signs', jsonEncode(signs));

        await prefs.setInt('data_version', serverVersion);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Ошибка скачивания обновлений: $e');
      throw Exception('Не удалось проверить обновления. Проверьте интернет.');
    }
  }

  // 2. Синхронизация истории (С параметром тихой фоновой работы)
  static Future<void> syncTestHistory({bool showErrors = true}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (showErrors) throw Exception("Сначала войдите в аккаунт");
      return; // Если вызвано автоматом после теста — просто молча выходим
    }

    try {
      final localHistory = await DBHelper.instance.getTestHistory();

      for (var item in localHistory) {
        final exists = await _supabase
            .from('test_history')
            .select('id')
            .eq('date', item['date'])
            .eq('user_id', user.id)
            .maybeSingle();

        if (exists == null) {
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
      if (showErrors) throw Exception('Не удалось синхронизировать историю.');
    }
  }
}