import '../../data/model/daily_state.dart';
import 'app_state.dart';

class StateJudgeService {
  AppState judge({required DateTime now, required DailyState dailyState}) {
    // ① 通知前？
    if (now.isBefore(dailyState.notifyTime)) {
      return AppState.beforeNotification; // S1
    }

    // ② 通知後 & FB未完了？
    if (!dailyState.feedbackCompleted) {
      return AppState.waitingFeedback; // S2
    }

    // ③ FB完了済
    return AppState.completed; // S3
  }
}
