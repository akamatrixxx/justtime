import 'package:flutter/material.dart';

import 'data/model/daily_state.dart';

import 'logic/state/app_state.dart';
import 'logic/state/state_judge_service.dart';
import 'ui/tutorial/tutorial_page.dart';
import 'ui/message/message_page.dart';
import 'ui/feedback/feedback_page.dart';

// ===== main =====

void main() {
  runApp(const MyApp());
}

// ===== MyApp =====

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JustTime',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}

// ===== AppRoot =====
// アプリ全体の「状態 → 画面」を制御する

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool tutorialCompleted = false;

  late DailyState dailyState;
  late AppState appState;

  final StateJudgeService stateJudge = StateJudgeService();

  @override
  void initState() {
    super.initState();

    // 今日の仮状態を作る
    dailyState = DailyState(
      date: DateTime.now(),
      notifyTime: DateTime.now().subtract(const Duration(minutes: 1)),
      feedbackCompleted: false,
    );

    // 初回判定
    _judgeState();
  }

  /// 状態判定をまとめた関数
  void _judgeState() {
    appState = stateJudge.judge(now: DateTime.now(), dailyState: dailyState);
  }

  /// Tutorial 完了コールバック
  void onTutorialCompleted() {
    setState(() {
      tutorialCompleted = true;

      // 今回の仕様：Tutorial完了時はFB完了扱い
      dailyState.feedbackCompleted = false;

      _judgeState(); // ← 再判定
    });
  }

  void onFeedbackSubmitted() {
    setState(() {
      dailyState.feedbackCompleted = true;
      _judgeState();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ---- 初回起動 ----
    if (!tutorialCompleted) {
      return TutorialPage(onCompleted: onTutorialCompleted);
    }

    // ---- 状態による分岐 ----
    switch (appState) {
      case AppState.beforeNotification:
        return const MessagePage(message: 'まだまだ頑張りましょう！');

      case AppState.waitingFeedback:
        return FeedbackPage(onFeedbackSubmitted: onFeedbackSubmitted);

      case AppState.completed:
        return const MessagePage(message: '今日もお疲れさまでした');
    }
  }
}
