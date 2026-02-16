import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/model/daily_state.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/repository/daily_state_repository.dart';
import '../state/state_judge_service.dart';
import '../state/app_state.dart';
import '../notification_time/notification_time_service.dart';

class AppStartService {
  final UserSettingRepository userSettingRepository;
  final DailyStateRepository repository;

  AppStartService(this.userSettingRepository, this.repository);

  /// P2: 起動時処理（状態は返さない）
  Future<void> handleAppStart() async {
    debugPrint('[P2] ===== handleAppStart =====');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ① 初回起動チェック
    final isFirstLaunch = await userSettingRepository.isFirstLaunch();

    if (isFirstLaunch) {
      debugPrint('[P2] 初回起動 → 初期セットアップ');
      return;
    }

    // ② 日付変更チェック
    final lastUsed = await userSettingRepository.getLastUsedDate();
    final isDateChanged = _isDateChanged(lastUsed, now);

    if (isDateChanged) {
      debugPrint('[P2] 日付変更検知');
      await _handleDateChange(lastUsed, now);
    }

    debugPrint('[P2] ===========================');
  }

  bool _isDateChanged(DateTime? lastUsed, DateTime now) {
    if (lastUsed == null) return true;
    return lastUsed.year != now.year ||
        lastUsed.month != now.month ||
        lastUsed.day != now.day;
  }

  Future<void> _handleDateChange(DateTime? lastUsed, DateTime now) async {
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));

    DailyState newState;
    final yesterdayState = await repository.getByDate(yesterday);
    final today = DateTime(now.year, now.month, now.day);

    /// [暫定] 昨日のデータがない場合は、適当に今日の状態を作る（通知時刻は20:00固定）
    if (yesterdayState == null) {
      newState = DailyState(
        date: today,
        notifyTime: DateTime(today.year, today.month, today.day, 20, 0),
        feedbackCompleted: false,
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
      );
      await repository.save(newState);
    }

    // ③ 最終利用日更新
    await userSettingRepository.setLastUsedDate(now);
  }

  /// チュートリアル完了処理
  Future<void> completeTutorial() async {
    debugPrint('[AppStart] チュートリアル完了');
    await userSettingRepository.markFirstLaunchCompleted();
    await userSettingRepository.setLastUsedDate(DateTime.now());
  }
}
