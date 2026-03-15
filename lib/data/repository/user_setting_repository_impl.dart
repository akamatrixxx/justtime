import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../model/user_setting.dart';
import 'user_setting_repository.dart';

// SQLiteを使った実装
class UserSettingRepositoryImpl implements UserSettingRepository {
  @override
  Future<bool> isFirstLaunch() async {
    try {
      final db = await AppDatabase.database;

      final result = await db.query('user_setting');

      if (result.isEmpty) {
        return true;
      }

      return result.first['is_first_launch'] == 1;
    } catch (e) {
      debugPrint('[UserSettingRepository] isFirstLaunch failed: $e');
      return true;
    }
  }

  @override
  Future<void> markFirstLaunchCompleted() async {
    try {
      final db = await AppDatabase.database;

      await db.update(
        'user_setting',
        {'is_first_launch': 0},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      debugPrint('[UserSettingRepository] markFirstLaunchCompleted failed: $e');
    }
  }

  @override
  Future<void> saveUserSetting(UserSetting setting) async {
    try {
      final db = await AppDatabase.database;

      await db.insert(
        'user_setting',
        setting.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[UserSettingRepository] saveUserSetting failed: $e');
    }
  }

  @override
  Future<UserSetting?> loadUserSetting() async {
    try {
      final db = await AppDatabase.database;

      final result = await db.query('user_setting', limit: 1);

      if (result.isEmpty) return null;

      return UserSetting.fromMap(result.first);
    } catch (e) {
      debugPrint('[UserSettingRepository] loadUserSetting failed: $e');
      return null;
    }
  }

  @override
  Future<DateTime?> getLastUsedDate() async {
    try {
      final db = await AppDatabase.database;

      final result = await db.query(
        'user_setting',
        where: 'id = ?',
        whereArgs: [1],
      );

      if (result.isEmpty) return null;

      final value = result.first['last_used_date'];
      if (value == null) return null;

      return DateTime.parse(value as String);
    } catch (e) {
      debugPrint('[UserSettingRepository] getLastUsedDate failed: $e');
      return null;
    }
  }

  @override
  Future<void> setLastUsedDate(DateTime date) async {
    try {
      final db = await AppDatabase.database;

      await db.update(
        'user_setting',
        {'last_used_date': date.toIso8601String().split('T').first},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      debugPrint('[UserSettingRepository] setLastUsedDate failed: $e');
    }
  }

  // デバッグ用: user_settingテーブルの内容を表示
  @override
  Future<void> debugPrintUserSetting() async {
    try {
      debugPrint('====[user_setting]====');
      final db = await AppDatabase.database;

      final result = await db.query('user_setting');

      if (result.isEmpty) {
        debugPrint('user_setting: データなし');
        return;
      }

      final row = result.first;

      final isFirstLaunch = row['is_first_launch'] == 1;
      final lastUsedDate = row['last_used_date'] as String?;

      String fmtTime(String hourKey, String minuteKey) {
        final hour = row[hourKey];
        final minute = row[minuteKey];
        if (hour == null || minute == null) return 'null';
        return 'TimeOfDay(hour: $hour, minute: $minute)';
      }

      debugPrint('-isFirstLaunch: $isFirstLaunch,');
      debugPrint('-lastUsedDate: ${lastUsedDate ?? 'null'},');
      debugPrint(
        '-workStart: ${fmtTime('work_start_hour', 'work_start_minute')},',
      );
      debugPrint('-workEnd: ${fmtTime('work_end_hour', 'work_end_minute')},');
      debugPrint(
        '-sleepStart: ${fmtTime('sleep_start_hour', 'sleep_start_minute')},',
      );
      debugPrint('-sleepEnd: ${fmtTime('sleep_end_hour', 'sleep_end_minute')},');
      debugPrint('=====================');
    } catch (e) {
      debugPrint('[UserSettingRepository] debugPrintUserSetting failed: $e');
    }
  }
}

// 簡易的なInMemory実装（動作確認用）
class InMemoryUserSettingRepository implements UserSettingInMemory {
  bool _firstLaunch = true;

  @override
  bool isFirstLaunch() {
    return _firstLaunch;
  }

  @override
  void markFirstLaunchCompleted() {
    _firstLaunch = false;
  }
}
