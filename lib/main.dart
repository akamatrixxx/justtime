import 'package:flutter/material.dart';

import 'logic/app_start/app_start_service.dart';
import 'logic/state/state_judge_service.dart';
import 'logic/initial_setup/initial_setup_service.dart';
import 'logic/state/app_state.dart';
import 'logic/notification_time/notification_time_service.dart';
import 'data/repository/user_setting_repository_impl.dart';
import 'data/repository/user_setting_repository.dart';
import 'data/repository/daily_state_repository.dart';
import 'data/db/app_database.dart';

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
  late final UserSettingRepository userSettingRepository;
  late final InitialSetupService initialSetupService;
  late final AppStartService appStartService;
  late final DailyStateRepository dailyStateRepository;
  late final NotificationTimeService notificationService;

  AppState? _appState;
  bool _needTutorial = false;

  @override
  void initState() {
    super.initState();

    final database = AppDatabase.database;

    userSettingRepository = UserSettingRepositoryImpl();
    initialSetupService = InitialSetupService(userSettingRepository);
    dailyStateRepository = DailyStateRepository(database);

    appStartService = AppStartService(
      userSettingRepository,
      StateJudgeService(),
      dailyStateRepository,
      NotificationTimeService(),
    );

    _startApp();
  }

  Future<void> _startApp() async {
    final isFirstLaunch = await userSettingRepository.isFirstLaunch();

    if (isFirstLaunch) {
      setState(() {
        _needTutorial = true;
      });
      return;
    }

    final state = await appStartService.decideAppState();

    setState(() {
      _appState = state;
    });

    // デバッグ表示
    await userSettingRepository.debugPrintUserSetting();
    await dailyStateRepository.debugPrintAll();
  }

  Future<void> _onTutorialCompleted() async {
    await userSettingRepository.markFirstLaunchCompleted();

    final state = await appStartService.decideAppState();

    setState(() {
      _needTutorial = false;
      _appState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔵 起動中
    if (_needTutorial == false && _appState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔵 チュートリアル
    if (_needTutorial) {
      return TutorialPage(
        onCompleted: _onTutorialCompleted,
        initialSetupService: initialSetupService,
      );
    }

    // 🔵 状態別画面
    switch (_appState!) {
      case AppState.beforeNotification:
        return const MessagePage(message: 'まだまだ頑張りましょう！');

      case AppState.waitingFeedback:
        return FeedbackPage(onFeedbackSubmitted: () {});

      case AppState.completed:
        return const MessagePage(message: '今日もお疲れさまでした');
    }
  }
}
