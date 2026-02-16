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

class EntryService {
  final AppStartService appStartService;
  final StateJudgeService stateJudgeService;

  EntryService(this.appStartService, this.stateJudgeService);

  Future<AppState> onAppStart() async {
    await appStartService.handleAppStart();
    return await stateJudgeService.judgeState();
  }
}

class _AppRootState extends State<AppRoot> {
  late EntryService entryService;
  late UserSettingRepository userSettingRepository;
  late DailyStateRepository dailyStateRepository;
  late InitialSetupService initialSetupService;

  AppState? _appState;
  bool _needTutorial = false;

  @override
  void initState() {
    super.initState();

    _initializeServices();
    _startApp();
  }

  /// サービスの初期化
  void _initializeServices() {
    // リポジトリを初期化
    userSettingRepository = UserSettingRepositoryImpl();
    dailyStateRepository = DailyStateRepository(AppDatabase.database);

    // 各サービスを作成
    final appStartService = AppStartService(
      userSettingRepository,
      dailyStateRepository,
    );

    final stateJudgeService = StateJudgeService(dailyStateRepository);

    initialSetupService = InitialSetupService(userSettingRepository);

    entryService = EntryService(appStartService, stateJudgeService);
  }

  /// アプリ起動時の処理
  Future<void> _startApp() async {
    final state = await entryService.onAppStart();

    setState(() {
      _appState = state;
    });

    await userSettingRepository.debugPrintUserSetting();
    await dailyStateRepository.debugPrintAll();
  }

  /// [暫定]チュートリアル完了を通知
  Future<void> _onTutorialCompleted() async {
    await userSettingRepository.markFirstLaunchCompleted();
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
