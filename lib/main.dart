import 'package:flutter/material.dart';
import 'logic/app_start/app_start_service.dart';
import 'logic/state/state_judge_service.dart';
import 'logic/state/app_state.dart';
import 'ui/tutorial/tutorial_page.dart';
import 'ui/message/message_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appStartService = AppStartService();
  final stateJudgeService = StateJudgeService();

  AppState? _state;

  @override
  void initState() {
    super.initState();
    onAppStart();
  }

  void onAppStart() {
    if (appStartService.isFirstLaunch()) {
      setState(() {
        _state = AppState.tutorial;
      });
    } else {
      setState(() {
        _state = AppState.messageS3;
      });
    }
  }

  void onTutorialCompleted() {
    appStartService.completeTutorial();
    final nextState = stateJudgeService.judgeAfterTutorial();

    setState(() {
      _state = nextState;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_state == null) {
      return const MaterialApp(home: Scaffold());
    }

    switch (_state!) {
      case AppState.tutorial:
        return MaterialApp(
          home: TutorialPage(onCompleted: onTutorialCompleted),
        );

      case AppState.messageS3:
        return const MaterialApp(home: MessagePage(message: 'お疲れさまでした。'));
    }
  }
}
