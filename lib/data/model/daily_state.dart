import 'package:flutter/material.dart';
import '../model/feedback.dart';

class DailyState {
  final DateTime date;
  final TimeOfDay notifyTime;
  final bool feedbackCompleted;
  final FeedbackType? feedbackType;

  DailyState({
    required this.date,
    required this.notifyTime,
    required this.feedbackCompleted,
    required this.feedbackType,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T').first,
      'notify_hour': notifyTime.hour,
      'notify_minute': notifyTime.minute,
      'feedback_completed': feedbackCompleted ? 1 : 0,
      'feedback_type': feedbackType != null ? feedbackType!.index : null,
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
      feedbackType: map['feedback_type'] != null
          ? FeedbackType.values[map['feedback_type']]
          : null,
    );
  }
}
