class NotificationTimeService {
  /// フィードバック後の次回通知時刻
  DateTime calcNextTime(DateTime previousNotifyTime) {
    // 前回より +1時間
    final next = previousNotifyTime.add(const Duration(hours: 1));

    return _roundToMinute(next);
  }

  DateTime _roundToMinute(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
  }
}
