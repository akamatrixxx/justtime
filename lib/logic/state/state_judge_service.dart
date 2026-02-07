import '../../data/model/daily_state.dart';
import 'app_state.dart';
import 'package:flutter/foundation.dart';

class StateJudgeService {
  AppState judge({required DateTime now, required DailyState dailyState}) {
    // ① 通知前？
    if (now.isBefore(dailyState.notifyTime)) {
      debugPrint('状態判定: beforeNotification');
      return AppState.beforeNotification; // S1
    }

    // ② 通知後 & FB未完了？
    if (!dailyState.feedbackCompleted) {
      debugPrint('状態判定: waitingFeedback');
      return AppState.waitingFeedback; // S2
    }

    // ③ FB完了済
    debugPrint('状態判定: completed');
    return AppState.completed; // S3
  }
}
