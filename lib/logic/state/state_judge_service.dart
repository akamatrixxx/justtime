import 'package:flutter/foundation.dart';

import '../../data/repository/daily_state_repository.dart';
import 'app_state.dart';

class StateJudgeService {
  final DailyStateRepository repository;

  StateJudgeService(this.repository);

  Future<AppState> judgeState() async {
    debugPrint('[P3] ===== judgeState =====');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dailyState = await repository.getByDate(today);

    if (dailyState == null) {
      return AppState.beforeNotification;
    }

    /// 通知前：フィードバック未完了かつ通知時刻前
    if (!dailyState.feedbackCompleted && now.isBefore(dailyState.notifyTime)) {
      return AppState.beforeNotification;
    }

    /// FB待ち状態：フィードバック未完了かつ通知時刻後
    if (!dailyState.feedbackCompleted && now.isAfter(dailyState.notifyTime)) {
      return AppState.waitingFeedback;
    }

    /// 完了状態：フィードバック完了
    return AppState.completed;
  }
}
