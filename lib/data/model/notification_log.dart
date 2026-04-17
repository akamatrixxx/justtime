import 'package:flutter/material.dart';
import 'feedback.dart';

/// 通知まわりで発生したイベントの種別
enum NotificationEventType {
  scheduled, // 通知をOSに登録した
  fired, // OSから通知が発火した（タップ等で観測）
  cancelled, // 通知を取り消した
  feedbackSubmitted, // ユーザーがフィードバックを送信した
}

NotificationEventType _parseEventType(String raw) {
  return NotificationEventType.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => NotificationEventType.fired,
  );
}

class NotificationLog {
  final int? id;
  final NotificationEventType eventType;
  final DateTime timestamp;
  final TimeOfDay? notifyTime;
  final FeedbackType? feedbackType;
  final String? note;

  NotificationLog({
    this.id,
    required this.eventType,
    required this.timestamp,
    this.notifyTime,
    this.feedbackType,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'event_type': eventType.name,
      'timestamp': timestamp.toIso8601String(),
      'notify_hour': notifyTime?.hour,
      'notify_minute': notifyTime?.minute,
      'feedback_type': feedbackType?.index,
      'note': note,
    };
  }

  factory NotificationLog.fromMap(Map<String, dynamic> map) {
    final hour = map['notify_hour'] as int?;
    final minute = map['notify_minute'] as int?;
    return NotificationLog(
      id: map['id'] as int?,
      eventType: _parseEventType(map['event_type'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      notifyTime: (hour != null && minute != null)
          ? TimeOfDay(hour: hour, minute: minute)
          : null,
      feedbackType: map['feedback_type'] != null
          ? FeedbackType.values[map['feedback_type'] as int]
          : null,
      note: map['note'] as String?,
    );
  }
}
