import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../model/notification_log.dart';

class NotificationLogRepository {
  final Future<Database> database;

  NotificationLogRepository(this.database);

  Future<void> insert(NotificationLog log) async {
    final db = await database;
    await db.insert('notification_log', log.toMap());
  }

  Future<List<NotificationLog>> loadAll() async {
    final db = await database;
    final rows = await db.query('notification_log', orderBy: 'timestamp ASC');
    return rows.map(NotificationLog.fromMap).toList();
  }

  Future<void> debugPrintAll() async {
    final db = await database;
    final rows = await db.query('notification_log', orderBy: 'timestamp ASC');
    debugPrint('====[notification_log]====');
    for (final row in rows) {
      debugPrint('ROW: $row');
    }
    debugPrint('==========================');
  }
}
