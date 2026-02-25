import 'package:flutter/material.dart';
import '../../data/model/feedback.dart';
import '../../logic/notification_service/notification_service.dart';

class NotificationTimeService {
  final NotificationService notificationService;

  NotificationTimeService(this.notificationService);

  /// フィードバック後の次回通知時刻
  Future<TimeOfDay> calcNextTime({
    required TimeOfDay currentNotifyTime,
    required FeedbackType feedbackType,
  }) async {
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
    // スケジュールを更新
    await notificationService.scheduler.scheduleDaily(adjustedTime);

    return adjustedTime;
  }

  TimeOfDay _addToTimeOfDay(TimeOfDay time, Duration delta) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final result = base.add(delta);
    return TimeOfDay(hour: result.hour, minute: result.minute);
  }

  Future<void> updateDailyNotification(TimeOfDay time) async {
    await notificationService.scheduler.scheduleDaily(time);
  }
}
