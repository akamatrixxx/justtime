import 'package:flutter/material.dart';
import '../../data/model/daily_state.dart';
import '../../data/model/feedback.dart';
import '../../data/model/app_state.dart';
import '../../data/repository/daily_state_repository.dart';
import '../state/state_judge_service.dart';
import '../notification_time/notification_time_service.dart';

class FeedbackService {
  final DailyStateRepository repository;
  final StateJudgeService stateJudgeService;
  final NotificationTimeService notificationTimeService;

  FeedbackService(
    this.repository,
    this.stateJudgeService,
    this.notificationTimeService,
  );

  Future<void> submitFeedback(FeedbackType type) async {
    DailyState? today = await repository.getByDate(DateTime.now());

    // データが存在しない場合はデフォルトの状態を作成（通知時刻は 20:00）
    if (today == null) {
      debugPrint(
        '[FeedbackService][ASSERT] No DailyState for today, creating default state.',
      );
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final defaultToday = DailyState(
        date: todayDate,
        notifyTime: TimeOfDay(hour: 20, minute: 0),
        feedbackCompleted: false,
        feedbackType: null,
      );
      await repository.save(defaultToday);
      today = defaultToday;
    }

    final nextTime = notificationTimeService.calcNextTime(
      currentNotifyTime: today.notifyTime,
      feedbackType: type,
    );
    final tomorrow = today.date.add(const Duration(days: 1));

    final nextDayState = DailyState(
      date: tomorrow,
      notifyTime: nextTime,
      feedbackCompleted: false,
      feedbackType: null,
    );

    final updatedToday = DailyState(
      date: today.date,
      notifyTime: today.notifyTime,
      feedbackCompleted: true,
      feedbackType: type,
    );
    debugPrint(
      '[FeedbackService] Feedback submitted: $type, next day notification: $nextTime.notifyTime',
    );
    await repository.save(updatedToday);
    await repository.save(nextDayState);
  }

  /// FeedBack完了時
  Future<AppState> completeFeedback() async {
    // 初期設定完了後、通常フローへ
    return await stateJudgeService.judgeState();
  }
}
