import 'package:flutter/material.dart';

import 'logic/app_start/app_start_service.dart';
import 'logic/state/app_state.dart';
import 'logic/state/state_judge_service.dart';
import 'data/repository/user_setting_repository_impl.dart';
import 'data/model/daily_state.dart';

import 'ui/tutorial/tutorial_page.dart';
import 'ui/feedback/feedback_page.dart';
import 'ui/message/message_page.dart';

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
  final _userSettingRepo = UserSettingRepositoryImpl();

  bool _tutorialCompleted = false;
  AppState? _appState;
  bool _loading = true;

  DailyState? _dailyState;

  final AppStartService _appStartService = AppStartService();

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  // 初期状態の確認
  Future<void> _loadInitialState() async {
    final completed = await _userSettingRepo.isTutorialCompleted();

    if (!completed) {
      setState(() {
        _tutorialCompleted = false;
        _loading = false;
      });
      return;
    }
    // チュートリアル済みの場合のみ状態判定
    final dailyState = DailyState(
      date: DateTime.now(),
      notifyTime: DateTime.now().add(const Duration(minutes: 1)),
    );

    final stateJudge = StateJudgeService();

    setState(() {
      _tutorialCompleted = true;
      _appState = stateJudge.judge(now: DateTime.now(), dailyState: dailyState);
      _loading = false;
    });
  }

  // チュートリアル完了
  void _onTutorialCompleted() async {
    await _userSettingRepo.setTutorialCompleted(true);

    final dailyState = DailyState(
      date: DateTime.now(),
      notifyTime: DateTime.now().subtract(const Duration(minutes: 1)),
    );

    final stateJudge = StateJudgeService();

    setState(() {
      _tutorialCompleted = true;
      _appState = stateJudge.judge(now: DateTime.now(), dailyState: dailyState);
    });
  }

  // FB送信完了
  void _onFeedbackSubmitted() {
    setState(() {
      _appState = AppState.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 読み込み中
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // チュートリアル
    if (!_tutorialCompleted) {
      return TutorialPage(onCompleted: _onTutorialCompleted);
    }

    switch (_appState!) {
      case AppState.beforeNotification:
        return const MessagePage(message: 'まだまだ頑張りましょう！');

      case AppState.waitingFeedback:
        return FeedbackPage(
          onFeedbackSubmitted: _onFeedbackSubmitted, // ← 修正ポイント
        );

      case AppState.completed:
        return const MessagePage(message: '今日もお疲れさまでした');
    }
  }
}
