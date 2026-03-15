import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../model/daily_state.dart';

class DailyStateRepository {
  final Future<Database> database;

  DailyStateRepository(this.database);

  Future<DailyState?> getByDate(DateTime date) async {
    try {
      final db = await database;

      final result = await db.query(
        'daily_state',
        where: 'date = ?',
        whereArgs: [date.toIso8601String().split('T').first],
      );

      if (result.isEmpty) return null;

      return DailyState.fromMap(result.first);
    } catch (e) {
      debugPrint('[DailyStateRepository] getByDate failed: $e');
      return null;
    }
  }

  Future<void> save(DailyState state) async {
    try {
      final db = await database;

      await db.insert(
        'daily_state',
        state.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[DailyStateRepository] save failed: $e');
    }
  }

  Future<List<DailyState>> getAll() async {
    try {
      final db = await database;
      final result = await db.query('daily_state', orderBy: 'date DESC');
      return result.map((row) => DailyState.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[DailyStateRepository] getAll failed: $e');
      return [];
    }
  }

  Future<void> debugPrintAll() async {
    try {
      final db = await database;
      final result = await db.query('daily_state');
      debugPrint('====[daily_state dataset]====');
      for (var row in result) {
        debugPrint('ROW: $row');
      }
      debugPrint('====[end]====');
    } catch (e) {
      debugPrint('[DailyStateRepository] debugPrintAll failed: $e');
    }
  }
}
