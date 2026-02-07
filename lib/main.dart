import 'package:flutter/material.dart';
import 'logic/state/app_state.dart';
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

  // 今は強制的に S3
  AppState appState = AppState.completed;

  @override
  void initState() {
    super.initState();
    // 本来はここで AppStartService を呼ぶ
    // 今回は仮で何もしない
  }

  // Tutorial 完了コールバック
  void onTutorialCompleted() {
    setState(() {
      tutorialCompleted = true;
      appState = AppState.completed; // 強制S3
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
        return const FeedbackPage();

      case AppState.completed:
        return const MessagePage(message: '今日もお疲れさまでした');
    }
  }
}
