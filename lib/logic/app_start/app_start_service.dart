import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';
import '../../data/model/daily_state.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/repository/daily_state_repository.dart';
import '../state/state_judge_service.dart';
import '../../data/model/app_state.dart';
import '../notification_time/notification_time_service.dart';

class AppStartService {
  final UserSettingRepository userSettingRepository;

  AppStartService(this.userSettingRepository);

  /// P2: 起動時処理（状態は返さない）
  Future<void> handleDateChange() async {
    debugPrint('[P2] ===== handleDateChange =====');
    final now = DateTime.now();

    final lastUsed = await userSettingRepository.getLastUsedDate();

    if (_isDateChanged(lastUsed, now)) {
      await _processDateChange(now);
    }

    await userSettingRepository.setLastUsedDate(now);
  }

  bool _isDateChanged(DateTime? lastUsed, DateTime now) {
    if (lastUsed == null) return true;

    return lastUsed.year != now.year ||
        lastUsed.month != now.month ||
        lastUsed.day != now.day;
  }

  Future<void> _processDateChange(DateTime now) async {
    debugPrint('[P2] ===== Date Changed Detected =====');
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final DailyStateRepository repository;
    repository = DailyStateRepository(AppDatabase.database);
    DailyState newState;
    final yesterdayState = await repository.getByDate(yesterday);
    final today = DateTime(now.year, now.month, now.day);

    /// [暫定] 昨日のデータがない場合は、適当に今日の状態を作る（通知時刻は20:00固定）
    if (yesterdayState == null) {
      newState = DailyState(
        date: today,
        notifyTime: TimeOfDay(hour: 20, minute: 0),
        feedbackCompleted: false,
        feedbackType: null,
      );
      await repository.save(newState);

      return;
    }

    if (yesterdayState.feedbackCompleted) {
      /// フィードバック完了 → 通知時刻は作成済みなのでなにもしない
    } else {
      /// フィードバック未完了 → 昨日と同じ通知時刻で新しい状態を作成

      newState = DailyState(
        date: today,
        notifyTime: yesterdayState.notifyTime,
        feedbackCompleted: false,
        feedbackType: null,
      );
      await repository.save(newState);
    }
  }
}
