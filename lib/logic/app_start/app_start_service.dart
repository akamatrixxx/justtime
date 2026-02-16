import 'package:flutter/foundation.dart';

import '../../data/model/daily_state.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/repository/daily_state_repository.dart';
import '../state/state_judge_service.dart';
import '../state/app_state.dart';
import '../notification_time/notification_time_service.dart';

class AppStartService {
  final UserSettingRepository userSettingRepository;
  final StateJudgeService stateJudgeService;
  final DailyStateRepository repository;
  final NotificationTimeService notificationService;

  AppStartService(
    this.userSettingRepository,
    this.stateJudgeService,
    this.repository,
    this.notificationService,
  );

  /// アプリ起動時の状態判定
  Future<AppState> decideAppState() async {
    debugPrint('[AppStart] ===== App Start =====');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ① 初回起動フラグ
    final isFirstLaunch = await userSettingRepository.isFirstLaunch();
    debugPrint('[AppStart] 初回起動: ${isFirstLaunch ? "未完了" : "完了済み"}');

    if (isFirstLaunch) {
      debugPrint('[AppStart] → S1 (チュートリアル)');
      return AppState.beforeNotification;
    }

    // ② 日付変更チェック
    final lastUsed = await userSettingRepository.getLastUsedDate();
    final isDateChanged = _isDateChanged(lastUsed, now);

    if (isDateChanged) {
      debugPrint('[AppStart] 日付変更検知');

      await _handleDateChange(lastUsed, now);
    }

    // ③ 今日のDailyState取得（必ず存在するはず）
    DailyState? dailyState = await repository.getByDate(today);

    if (dailyState == null) {
      debugPrint('[AppStart] 今日のDailyStateなし → 初期生成');

      dailyState = DailyState(
        date: today,
        notifyTime: now,
        feedbackCompleted: false,
      );

      await repository.save(dailyState);
    }

    debugPrint('[AppStart] notifyTime: ${dailyState.notifyTime}');

    // ④ lastUsedDate 更新
    await userSettingRepository.setLastUsedDate(now);

    final appState = stateJudgeService.judge(now: now, dailyState: dailyState);

    debugPrint('[AppStart] 判定結果: $appState');
    debugPrint('[AppStart] =====================');

    return appState;
  }

  /// 日付変更処理
  Future<void> _handleDateChange(DateTime? lastUsed, DateTime now) async {
    if (lastUsed == null) return;

    final yesterdayDate = DateTime(lastUsed.year, lastUsed.month, lastUsed.day);

    final yesterday = await repository.getByDate(yesterdayDate);

    if (yesterday == null) {
      debugPrint('[AppStart] 昨日のStateなし → スキップ');
      return;
    }

    final today = DateTime(now.year, now.month, now.day);

    DateTime newNotifyTime;

    if (yesterday.feedbackCompleted) {
      debugPrint('[AppStart] 昨日フィードバックあり → 再計算');
      newNotifyTime = notificationService.calcNextTime(yesterday.notifyTime);
    } else {
      debugPrint('[AppStart] 昨日フィードバックなし → 時刻踏襲');
      newNotifyTime = DateTime(
        today.year,
        today.month,
        today.day,
        yesterday.notifyTime.hour,
        yesterday.notifyTime.minute,
      );
    }

    final newState = DailyState(
      date: today,
      notifyTime: newNotifyTime,
      feedbackCompleted: false,
    );

    await repository.save(newState);
  }

  bool _isDateChanged(DateTime? last, DateTime now) {
    if (last == null) return true;

    return last.year != now.year ||
        last.month != now.month ||
        last.day != now.day;
  }

  /// チュートリアル完了処理
  Future<void> completeTutorial() async {
    debugPrint('[AppStart] チュートリアル完了');
    await userSettingRepository.markFirstLaunchCompleted();
    await userSettingRepository.setLastUsedDate(DateTime.now());
  }
}
