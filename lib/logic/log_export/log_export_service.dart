import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';

import '../../data/model/notification_log.dart';
import '../../data/repository/notification_log_repository.dart';

class LogExportService {
  final NotificationLogRepository notificationLogRepository;

  LogExportService(this.notificationLogRepository);

  /// 通知ログを CSV 化し、Android の Download フォルダ（iOS はファイルアプリ）
  /// に保存する。保存先のパス or ファイル名を返す。
  Future<String> exportToDownloads() async {
    final logs = await notificationLogRepository.loadAll();
    final csv = _buildCsv(logs);

    // Excel が UTF-8 を正しく認識できるよう BOM を付与
    final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);

    final now = DateTime.now();
    final stamp =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_'
        '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final baseName = 'notification_log_$stamp';

    final result = await FileSaver.instance.saveAs(
      name: baseName,
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
    debugPrint('[LogExportService] Saved as: $result');
    return result ?? '$baseName.csv';
  }

  String _buildCsv(List<NotificationLog> logs) {
    final buffer = StringBuffer();
    buffer.writeln('id,event_type,timestamp,notify_time,feedback_type,note');
    for (final log in logs) {
      final notifyTime = log.notifyTime == null
          ? ''
          : '${_pad(log.notifyTime!.hour)}:${_pad(log.notifyTime!.minute)}';
      buffer.writeln(
        [
          log.id ?? '',
          log.eventType.name,
          log.timestamp.toIso8601String(),
          notifyTime,
          log.feedbackType?.name ?? '',
          log.note ?? '',
        ].map(_escape).join(','),
      );
    }
    return buffer.toString();
  }

  String _escape(Object field) {
    final s = field.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
