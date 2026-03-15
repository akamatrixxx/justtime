import 'package:flutter/material.dart';
import '../../data/model/feedback.dart';

class NotificationTimeService {
  /// フィードバック後の次回通知時刻
  TimeOfDay calcNextTime({
    required TimeOfDay currentNotifyTime,
    required FeedbackType feedbackType,
  }) {
    TimeOfDay adjustedTime = currentNotifyTime;

    switch (feedbackType) {
      case FeedbackType.tooEarly:
        adjustedTime = _addToTimeOfDay(
          currentNotifyTime,
          const Duration(minutes: 30),
        );
        break;

      case FeedbackType.tooLate:
        adjustedTime = _addToTimeOfDay(
          currentNotifyTime,
          const Duration(minutes: -30),
        );
        break;

      case FeedbackType.goodTiming:
        break;
    }

    return adjustedTime;
  }

  TimeOfDay _addToTimeOfDay(TimeOfDay time, Duration delta) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final result = base.add(delta);
    return TimeOfDay(hour: result.hour, minute: result.minute);
  }
}
