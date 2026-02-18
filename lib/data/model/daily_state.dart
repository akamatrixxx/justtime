import 'package:flutter/material.dart';

class DailyState {
  final DateTime date;
  final TimeOfDay notifyTime;
  final bool feedbackCompleted;

  DailyState({
    required this.date,
    required this.notifyTime,
    required this.feedbackCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T').first,
      'notify_hour': notifyTime.hour,
      'notify_minute': notifyTime.minute,
      'feedback_completed': feedbackCompleted ? 1 : 0,
    };
  }

  factory DailyState.fromMap(Map<String, dynamic> map) {
    return DailyState(
      date: DateTime.parse(map['date']),
      notifyTime: TimeOfDay(
        hour: map['notify_hour'],
        minute: map['notify_minute'],
      ),
      feedbackCompleted: map['feedback_completed'] == 1,
    );
  }
}
