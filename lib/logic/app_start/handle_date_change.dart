import 'package:flutter/foundation.dart';
import 'package:justtime/data/repository/daily_state_repository.dart';
import '../../data/model/daily_state.dart';
import '../../data/repository/user_setting_repository.dart';

Future<void> _handleDateChange(DateTime? lastUsed, DateTime now) async {
  if (lastUsed == null) return;

  final yesterday = await DailyStateRepository.getByDate(lastUsed);

  if (yesterday == null) return;

  DateTime newNotifyTime;

  if (yesterday.feedbackCompleted) {
    // フィードバックあり → 再計算
    newNotifyTime = notificationService.calcNextTime(yesterday.notifyTime);
  } else {
    // フィードバックなし → 同じ時刻を今日にコピー
    newNotifyTime = DateTime(
      now.year,
      now.month,
      now.day,
      yesterday.notifyTime.hour,
      yesterday.notifyTime.minute,
    );
  }

  final todayState = DailyState(
    date: _dateOnly(now),
    notifyTime: newNotifyTime,
    feedbackCompleted: false,
  );

  await DailyStateRepository.save(todayState);
}
