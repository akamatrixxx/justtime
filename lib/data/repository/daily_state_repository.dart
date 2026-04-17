import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../model/daily_state.dart';

class DailyStateRepository {
  final Future<Database> database;

  DailyStateRepository(this.database);

  Future<DailyState?> getByDate(DateTime date) async {
    final db = await database;

    final result = await db.query(
      'daily_state',
      where: 'date = ?',
      whereArgs: [date.toIso8601String().split('T').first],
    );

    if (result.isEmpty) return null;

    return DailyState.fromMap(result.first);
  }

  Future<void> save(DailyState state) async {
    final db = await database;

    await db.insert(
      'daily_state',
      state.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> debugPrintAll() async {
    final db = await database;
    final result = await db.query('daily_state');
    debugPrint('====[daily_state dataset]====');
    for (var row in result) {
      debugPrint('ROW: $row');
    }
    debugPrint('====[end]====');
  }
}
