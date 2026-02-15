import 'package:flutter/foundation.dart';

import '../../data/model/daily_state.dart';
import '../../data/repository/user_setting_repository.dart';
import '../state/state_judge_service.dart';
import '../state/app_state.dart';
import '../../data/repository/daily_state_repository.dart';

class AppStartService {
  final UserSettingRepository userSettingRepository;
  final StateJudgeService stateJudgeService;
  final DailyStateRepository repository;

  AppStartService(
    this.userSettingRepository,
    this.stateJudgeService,
    this.repository,
  );

  /// アプリ起動時の状態判定
  Future<AppState> decideAppState() async {
    debugPrint('[AppStart] ===== App Start =====');

    // ① 初回起動フラグ
    final isFirstLaunch = await userSettingRepository.isFirstLaunch();
    final DailyStateRepository dailyStateRepository = repository;
    debugPrint('[AppStart] 初回起動フラグ: ${!isFirstLaunch ? "完了済み" : "未完了"}');

    if (isFirstLaunch) {
      debugPrint('[AppStart] → 判定結果: S1 (チュートリアル)');
      return AppState.beforeNotification;
    }

    // ② 今日の日付
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 今日のDailyStateを取得。なければ新規作成して保存
    DailyState? dailyState = await dailyStateRepository.getByDate(today);

    if (dailyState == null) {
      debugPrint('[AppStart] 今日のDailyStateなし → 新規作成');

      dailyState = DailyState(
        date: today,
        notifyTime: now.add(const Duration(hours: 1)),
        feedbackCompleted: false,
      );

      await dailyStateRepository.save(dailyState);
    } else {
      debugPrint('[AppStart] 今日のDailyStateあり → 既存利用');
    }

    debugPrint('[AppStart] notifyTime: ${dailyState.notifyTime}');

    final appState = stateJudgeService.judge(now: now, dailyState: dailyState);

    debugPrint('[AppStart] 判定結果: $appState');
    debugPrint('[AppStart] =====================');

    return appState;
  }

  /// チュートリアル完了処理
  void completeTutorial() {
    debugPrint('[AppStart] チュートリアル完了 → フラグ更新');
    userSettingRepository.markFirstLaunchCompleted();
  }
}
