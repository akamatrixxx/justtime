import 'app_state.dart';

class StateJudgeService {
  AppState judgeAfterTutorial() {
    // 今回は問答無用でS3
    return AppState.messageS3;
  }
}
