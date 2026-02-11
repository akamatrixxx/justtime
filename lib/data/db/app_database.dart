import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'justtime.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_setting(
            id INTEGER PRIMARY KEY,
            is_first_launch INTEGER,
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
      },
    );
  }
}
