import '../../data/model/daily_state.dart';
import '../../data/model/feedback.dart';
import '../../data/model/app_state.dart';
import '../../data/repository/daily_state_repository.dart';
import '../state/state_judge_service.dart';

class FeedbackService {
  final DailyStateRepository repository;
  final StateJudgeService stateJudgeService;

  FeedbackService(this.repository, this.stateJudgeService);

  Future<void> submitFeedback(FeedbackType type) async {
    final today = await repository.getByDate(DateTime.now());

    final updated = DailyState(
      date: today!.date,
      notifyTime: today.notifyTime,
      feedbackCompleted: true,
      feedbackType: type,
    );

    await repository.save(updated);
  }

  /// FeedBack完了時
  Future<AppState> completeFeedback() async {
    // 初期設定完了後、通常フローへ
    return await stateJudgeService.judgeState();
  }
}
