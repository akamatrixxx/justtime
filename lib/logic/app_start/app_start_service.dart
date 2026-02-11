import 'package:flutter/foundation.dart';

import '../../data/model/daily_state.dart';
import '../../data/repository/user_setting_repository.dart';
import '../state/state_judge_service.dart';
import '../state/app_state.dart';

class AppStartService {
  final UserSettingRepository userSettingRepository;
  final StateJudgeService stateJudgeService;

  AppStartService(this.userSettingRepository, this.stateJudgeService);

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
    debugPrint('[AppStart] 現在時刻: $now');

    // ③ 今日の DailyState（今は仮）
    final dailyState = DailyState(
      date: DateTime(now.year, now.month, now.day),
      notifyTime: now.add(const Duration(hours: 1)),
    );

    debugPrint('[AppStart] DailyState.date: ${dailyState.date}');
    debugPrint('[AppStart] DailyState.notifyTime: ${dailyState.notifyTime}');

    // ④ 状態判定
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
