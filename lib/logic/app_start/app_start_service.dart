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

    debugPrint('[AppStart] 初回起動フラグ: ${!isFirstLaunch ? "完了済み" : "未完了"}');

    if (isFirstLaunch) {
      debugPrint('[AppStart] → 判定結果: S1 (チュートリアル)');
      return AppState.beforeNotification;
    }

    // ② 今日の日付
    final now = DateTime.now();

    // ③ 今日の DailyState（今は仮）
    final dailyState = DailyState(
      date: DateTime(now.year, now.month, now.day),
      notifyTime: now.add(const Duration(hours: 1)),
      feedbackCompleted: false,
    );

    // Stateを保存
    await repository.save(dailyState);

    // ④ 状態判定
    final appState = stateJudgeService.judge(now: now, dailyState: dailyState);

    final today = await repository.getByDate(DateTime.now());
    debugPrint('[AppStart] 今日の DailyState: $today');
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
