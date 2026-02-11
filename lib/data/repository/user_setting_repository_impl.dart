import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import 'user_setting_repository.dart';

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

// SQLiteを使った実装
class UserSettingRepositoryImpl implements UserSettingRepository {
  @override
  Future<bool> isFirstLaunch() async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'user_setting',
      where: 'id = ?',
      whereArgs: [1],
    );

    final value = result.first['is_first_launch'] as int;
    return value == 1;
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
}
