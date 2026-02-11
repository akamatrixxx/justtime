import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../model/user_setting.dart';
import 'user_setting_repository.dart';

// SQLiteを使った実装
class UserSettingRepositoryImpl implements UserSettingRepository {
  @override
  Future<bool> isFirstLaunch() async {
    final db = await AppDatabase.database;

    final result = await db.query('user_setting');

    // 🔵 1件も無い場合は「初回起動」
    if (result.isEmpty) {
      return true;
    }

    return result.first['is_first_launch'] == 1;
  }

  @override
  Future<void> markFirstLaunchCompleted() async {
    final db = await AppDatabase.database;

    await db.update(
      'user_setting',
      {'is_first_launch': 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  @override
  Future<void> saveUserSetting(UserSetting setting) async {
    final db = await AppDatabase.database;

    await db.insert(
      'user_setting',
      setting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserSetting?> loadUserSetting() async {
    final db = await AppDatabase.database;

    final result = await db.query('user_setting', limit: 1);

    if (result.isEmpty) return null;

    return UserSetting.fromMap(result.first);
  }

  // デバッグ用: user_settingテーブルの内容を表示
  @override
  Future<void> debugPrintUserSetting() async {
    final db = await AppDatabase.database;

    final result = await db.query('user_setting');

    if (result.isEmpty) {
      debugPrint('🔴 user_setting: データなし');
      return;
    }

    debugPrint('🟢 user_setting 内容:');
    debugPrint(result.first.toString());
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
