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
    debugPrint('[P5] ==== calcNextTime ====');
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
    //[TODO] スケジュールを更新(呼び元の責務で行う)
    await notificationService.scheduler.scheduleDaily(adjustedTime);

    return adjustedTime;
  }

  /// 初回通知時刻算出
  /// [ToDo] 初回通知時刻が既に現在時刻を過ぎている場合の対応（当日通知はスキップし、翌日通知時刻を算出するなど）
  TimeOfDay calcInitialNotifyTime({
    required TimeOfDay workStart,
    required TimeOfDay workEnd,
  }) {
    final start = workStart.hour * 60 + workStart.minute;
    final end = workEnd.hour * 60 + workEnd.minute;
    final mid = (start + end) ~/ 2;
    final midHour = mid ~/ 60;
    final midMinute = mid % 60;

    debugPrint(
      '[P5] Initial Notification Time: ${midHour.toString().padLeft(2, '0')}:${midMinute.toString().padLeft(2, '0')}',
    );

    return TimeOfDay(hour: midHour, minute: midMinute);
  }

  TimeOfDay _addToTimeOfDay(TimeOfDay time, Duration delta) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final result = base.add(delta);
    return TimeOfDay(hour: result.hour, minute: result.minute);
  }

  //[TODO] スケジュールを更新(呼び元の責務で行う)
  Future<void> updateDailyNotification(TimeOfDay time) async {
    await notificationService.scheduler.scheduleDaily(time);
  }
}
