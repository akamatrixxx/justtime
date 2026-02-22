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
      debugPrint('Update LastUsedDate: ${now.month}/${now.day}');
      await userSettingRepository.setLastUsedDate(now);
    }
  }

  bool _isDateChanged(DateTime? lastUsed, DateTime now) {
    if (lastUsed == null) return true;
    debugPrint(
      'LastUsedDay: ${lastUsed.month}/${lastUsed.day}, Today: ${now.month}/${now.day}',
    );

    return lastUsed.year != now.year ||
        lastUsed.month != now.month ||
        lastUsed.day != now.day;
  }

  Future<void> _processDateChange(DateTime now) async {
    debugPrint('[P2] ===== Date Changed Process =====');
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));

    // 未利用日判定
    final DailyStateRepository repository;
    DailyState newState;
    repository = DailyStateRepository(AppDatabase.database);
    final yesterdayState = await repository.getByDate(yesterday);
    final today = DateTime(now.year, now.month, now.day);

    /// 未利用日がある場合は、最終利用日まで遡ってデータを探索し、
    /// 見つかったデータと同じ通知時刻で今日の状態を作成する。
    if (yesterdayState == null) {
      final lastUsed = await userSettingRepository.getLastUsedDate();

      TimeOfDay lastNotifyTime = const TimeOfDay(
        hour: 20,
        minute: 0,
      ); // デフォルトの通知時刻

      if (lastUsed != null) {
        // 日付部分だけを比較するために時刻を切り捨て
        final lastUsedDateOnly = DateTime(
          lastUsed.year,
          lastUsed.month,
          lastUsed.day,
        );

        DateTime searchDate = yesterday;
        DailyState? found;

        // yesterday から lastUsedDateOnly まで遡る（lastUsed を含む）
        while (!searchDate.isBefore(lastUsedDateOnly)) {
          final s = await repository.getByDate(searchDate);
          if (s != null) {
            found = s;
            break;
          }
          searchDate = searchDate.subtract(const Duration(days: 1));
        }

        if (found != null) {
          lastNotifyTime = found.notifyTime;
        }
      }

      newState = DailyState(
        date: today,
        notifyTime: lastNotifyTime,
        feedbackCompleted: false,
        feedbackType: null,
      );
      await repository.save(newState);

      return;
    }

    final todayState = await repository.getByDate(today);
    if (todayState != null && todayState.feedbackCompleted) {
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
