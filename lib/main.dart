import 'package:flutter/material.dart';

import 'logic/app_start/app_start_service.dart';
import 'logic/state/state_judge_service.dart';
import 'logic/state/app_state.dart';
import 'data/repository/user_setting_repository_impl.dart';
import 'data/repository/user_setting_repository.dart';

import 'ui/tutorial/tutorial_page.dart';
import 'ui/message/message_page.dart';
import 'ui/feedback/feedback_page.dart';

void main() {
  runApp(const JustTimeApp());
}

class JustTimeApp extends StatelessWidget {
  const JustTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppState? _appState;

  late final UserSettingRepository userSettingRepository;
  late final AppStartService appStartService;

  @override
  void initState() {
    super.initState();

    // Repository
    userSettingRepository = InMemoryUserSettingRepository();

    // Service
    appStartService = AppStartService(
      userSettingRepository,
      StateJudgeService(),
    );

    _startApp();
  }

  void _startApp() {
    final result = appStartService.decideAppState();

    setState(() {
      _appState = result;
    });
  }

  void _onTutorialCompleted() {
    // チュートリアル完了処理
    appStartService.completeTutorial();

    // 状態再判定
    final newState = appStartService.decideAppState();
    setState(() {
      _appState = newState;
    });
  }

  void _onFeedbackCompleted() {
    setState(() {
      _appState = AppState.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔵 起動中
    if (_appState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔵 チュートリアル未完了
    if (userSettingRepository.isFirstLaunch()) {
      return TutorialPage(onCompleted: _onTutorialCompleted);
    }

    // 🔵 状態別表示
    switch (_appState!) {
      case AppState.beforeNotification:
        return const MessagePage(message: 'まだまだ頑張りましょう！');

      case AppState.waitingFeedback:
        return FeedbackPage(onFeedbackSubmitted: _onFeedbackCompleted);

      case AppState.completed:
        return const MessagePage(message: '今日もお疲れさまでした');
    }
  }
}
