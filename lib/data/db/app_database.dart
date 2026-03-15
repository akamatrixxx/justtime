import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDB();
    } catch (e) {
      debugPrint('[AppDatabase] Failed to initialize database: $e');
      rethrow;
    }
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'justtime.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        // user_setting テーブル
        await db.execute('''
        CREATE TABLE user_setting(
          id INTEGER PRIMARY KEY,
          is_first_launch INTEGER,
          last_used_date TEXT,
          work_start_hour INTEGER,
          work_start_minute INTEGER,
          work_end_hour INTEGER,
          work_end_minute INTEGER,
          sleep_start_hour INTEGER,
          sleep_start_minute INTEGER,
          sleep_end_hour INTEGER,
          sleep_end_minute INTEGER
        )
      ''');

        // daily_state テーブル
        await db.execute('''
          CREATE TABLE daily_state(
            date TEXT PRIMARY KEY,
            notify_hour INTEGER,
            notify_minute INTEGER,
            feedback_completed INTEGER,
            feedback_type INTEGER
          )
        ''');
      },

      // 既存ユーザー用アップグレード処理
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE daily_state(
              date TEXT PRIMARY KEY,
              notify_hour INTEGER,
              notify_minute INTEGER,
              feedback_completed INTEGER,
              feedback_type INTEGER
            )
          ''');
        }
      },
    );
  }
}
