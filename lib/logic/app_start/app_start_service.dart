import '../../data/model/daily_state.dart';
import '../state/state_judge_service.dart';
import '../state/app_state.dart';
import 'app_start_result.dart';

class AppStartService {
  final StateJudgeService _stateJudge = StateJudgeService();

  AppStartResult onAppStart() {
    final now = DateTime.now();

    // 🔹 仮：通知時刻を「今から1分前」にする
    final notifyTime = now.subtract(const Duration(minutes: 1));

    final dailyState = DailyState(
      date: now,
      notifyTime: notifyTime,
      feedbackCompleted: false,
    );

    final appState = _stateJudge.judge(now: now, dailyState: dailyState);

    return AppStartResult(appState: appState, dailyState: dailyState);
  }
}
