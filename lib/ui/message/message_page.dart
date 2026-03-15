import 'package:flutter/material.dart';
import '../common/app_drawer.dart';
import '../theme/app_theme.dart';
import '../../data/model/app_state.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/repository/daily_state_repository.dart';

class MessagePage extends StatelessWidget {
  final AppState appState;
  final UserSettingRepository userSettingRepository;
  final DailyStateRepository dailyStateRepository;

  const MessagePage({
    super.key,
    required this.appState,
    required this.userSettingRepository,
    required this.dailyStateRepository,
  });

  @override
  Widget build(BuildContext context) {
    final isWork = appState == AppState.beforeNotification;
    final gradient = isWork ? AppColors.workGradient : AppColors.restGradient;
    final message = isWork ? 'まだまだ頑張りましょう！' : '今日もお疲れさまでした';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        userSettingRepository: userSettingRepository,
        dailyStateRepository: dailyStateRepository,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
