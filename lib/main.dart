import 'package:flutter/material.dart';

import 'logic/app_start/app_start_service.dart';
import 'logic/state/state_judge_service.dart';
import 'logic/initial_setup/initial_setup_service.dart';
import 'logic/notification_time/notification_time_service.dart';
import 'logic/feedback/feedback_service.dart';

import 'data/repository/user_setting_repository_impl.dart';
import 'data/repository/user_setting_repository.dart';
import 'data/repository/daily_state_repository.dart';
import 'data/db/app_database.dart';
import 'data/model/app_state.dart';
import 'data/model/feedback.dart';

import 'ui/theme/app_theme.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class EntryService {
  final UserSettingRepository userSettingRepository;
  final AppStartService appStartService;
  final StateJudgeService stateJudgeService;

  EntryService({
    required this.userSettingRepository,
    required this.appStartService,
    required this.stateJudgeService,
  });

  /// アプリ起動時
  Future<AppState> onAppStart() async {
    debugPrint('[EntryService] onAppStart');
    final isFirstLaunch = await userSettingRepository.isFirstLaunch();

    if (isFirstLaunch) {
      return AppState.tutorial;
    }

    await appStartService.handleDateChange();
    return await stateJudgeService.judgeState();
  }

  /// チュートリアル完了時
  Future<AppState> completeTutorial() async {
    // 初期設定完了後、通常フローへ
    return await stateJudgeService.judgeState();
  }
}

class _AppRootState extends State<AppRoot> {
  late EntryService entryService;
  late FeedbackService feedbackService;
  late UserSettingRepository userSettingRepository;
  late DailyStateRepository dailyStateRepository;
  late InitialSetupService initialSetupService;

  AppState? _appState;

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
    initialSetupService = InitialSetupService(userSettingRepository, dailyStateRepository);
    final appStartService = AppStartService(userSettingRepository, dailyStateRepository);
    final stateJudgeService = StateJudgeService(dailyStateRepository);
    feedbackService = FeedbackService(
      dailyStateRepository,
      stateJudgeService,
      NotificationTimeService(),
    );

    entryService = EntryService(
      userSettingRepository: userSettingRepository,
      appStartService: appStartService,
      stateJudgeService: stateJudgeService,
    );
  }

  /// アプリ起動時の処理
  Future<void> _startApp() async {
    final state = await entryService.onAppStart();
    debugPrint('[EntryService] AppState: $state');

    setState(() {
      _appState = state;
    });

    await userSettingRepository.debugPrintUserSetting();
    await dailyStateRepository.debugPrintAll();
  }

  Widget _buildPage() {
    if (_appState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    switch (_appState!) {
      case AppState.tutorial:
        return TutorialPage(
          onCompleted: () {
            entryService.completeTutorial().then((state) {
              setState(() {
                _appState = state;
              });
            });
          },
          initialSetupService: initialSetupService,
        );
      case AppState.beforeNotification:
        return MessagePage(
          appState: AppState.beforeNotification,
          userSettingRepository: userSettingRepository,
          dailyStateRepository: dailyStateRepository,
        );

      case AppState.waitingFeedback:
        return FeedbackPage(
          onFeedbackSubmitted: (FeedbackType type) async {
            await feedbackService.submitFeedback(type);
            final state = await feedbackService.completeFeedback();
            setState(() {
              _appState = state;
            });
          },
          userSettingRepository: userSettingRepository,
          dailyStateRepository: dailyStateRepository,
        );

      case AppState.completed:
        return MessagePage(
          appState: AppState.completed,
          userSettingRepository: userSettingRepository,
          dailyStateRepository: dailyStateRepository,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(_appState),
        child: _buildPage(),
      ),
    );
  }
}
