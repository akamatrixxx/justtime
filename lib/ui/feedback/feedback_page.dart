import 'package:flutter/material.dart';
import '../../data/model/feedback.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/repository/daily_state_repository.dart';
import '../common/app_drawer.dart';
import '../theme/app_theme.dart';

class FeedbackPage extends StatelessWidget {
  final Function(FeedbackType) onFeedbackSubmitted;
  final UserSettingRepository userSettingRepository;
  final DailyStateRepository dailyStateRepository;

  const FeedbackPage({
    super.key,
    required this.onFeedbackSubmitted,
    required this.userSettingRepository,
    required this.dailyStateRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: AppDrawer(
        userSettingRepository: userSettingRepository,
        dailyStateRepository: dailyStateRepository,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.chat_bubble_outline,
                size: 56,
                color: AppColors.feedback,
              ),
              const SizedBox(height: 16),
              Text(
                '通知のタイミングは\nいかがでしたか？',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'フィードバックに応じて次回の通知時刻を調整します',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _FeedbackCard(
                icon: Icons.fast_forward,
                title: 'まだ早いよ',
                description: '次回の通知を30分遅くします',
                color: Colors.orange,
                onTap: () => onFeedbackSubmitted(FeedbackType.tooEarly),
              ),
              const SizedBox(height: 12),
              _FeedbackCard(
                icon: Icons.thumb_up_outlined,
                title: 'ちょうどいい！',
                description: '通知時刻を変更しません',
                color: Colors.green,
                onTap: () => onFeedbackSubmitted(FeedbackType.goodTiming),
              ),
              const SizedBox(height: 12),
              _FeedbackCard(
                icon: Icons.fast_rewind,
                title: 'もっと早く！',
                description: '次回の通知を30分早くします',
                color: Colors.blue,
                onTap: () => onFeedbackSubmitted(FeedbackType.tooLate),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final MaterialColor color;
  final VoidCallback onTap;

  const _FeedbackCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color[700], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
