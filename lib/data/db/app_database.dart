import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'justtime.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_setting (
            id INTEGER PRIMARY KEY,
            is_first_launch INTEGER
          )
        ''');

        // 初期データ
        await db.insert('user_setting', {'id': 1, 'is_first_launch': 1});
      },
    );

    return _database!;
  }
}
