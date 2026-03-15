import 'package:flutter/material.dart';
import '../../data/model/daily_state.dart';
import '../../data/model/feedback.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/repository/daily_state_repository.dart';
import '../settings/settings_page.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatefulWidget {
  final UserSettingRepository userSettingRepository;
  final DailyStateRepository dailyStateRepository;

  const AppDrawer({
    super.key,
    required this.userSettingRepository,
    required this.dailyStateRepository,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  DailyState? _todayState;
  List<DailyState> _allStates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final today = await widget.dailyStateRepository.getByDate(DateTime.now());
    final all = await widget.dailyStateRepository.getAll();
    if (mounted) {
      setState(() {
        _todayState = today;
        _allStates = all;
        _isLoading = false;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _feedbackLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.tooEarly:
        return 'まだ早い';
      case FeedbackType.goodTiming:
        return 'ちょうどいい';
      case FeedbackType.tooLate:
        return 'もっと早く';
    }
  }

  IconData _feedbackIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.tooEarly:
        return Icons.fast_forward;
      case FeedbackType.goodTiming:
        return Icons.thumb_up_outlined;
      case FeedbackType.tooLate:
        return Icons.fast_rewind;
    }
  }

  Color _feedbackColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.tooEarly:
        return Colors.orange;
      case FeedbackType.goodTiming:
        return Colors.green;
      case FeedbackType.tooLate:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: AppColors.primary, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'JustTime',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // 時間の設定
                  ListTile(
                    leading: const Icon(Icons.settings, color: AppColors.primary),
                    title: const Text('時間の設定'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            userSettingRepository: widget.userSettingRepository,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // 通知予定時刻
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      '通知予定時刻',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (_todayState != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        color: AppColors.workLight,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.notifications_outlined, color: AppColors.work),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '今日の通知',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.work,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(_todayState!.notifyTime),
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.work,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const Divider(height: 24),

                  // フィードバックログ
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'フィードバックログ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (_allStates.where((s) => s.feedbackCompleted).isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'まだフィードバックがありません',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  else
                    ..._allStates
                        .where((s) => s.feedbackCompleted && s.feedbackType != null)
                        .map((s) => _FeedbackLogTile(
                              date: _formatDate(s.date),
                              notifyTime: _formatTime(s.notifyTime),
                              feedbackLabel: _feedbackLabel(s.feedbackType!),
                              feedbackIcon: _feedbackIcon(s.feedbackType!),
                              feedbackColor: _feedbackColor(s.feedbackType!),
                            )),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}

class _FeedbackLogTile extends StatelessWidget {
  final String date;
  final String notifyTime;
  final String feedbackLabel;
  final IconData feedbackIcon;
  final Color feedbackColor;

  const _FeedbackLogTile({
    required this.date,
    required this.notifyTime,
    required this.feedbackLabel,
    required this.feedbackIcon,
    required this.feedbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            notifyTime,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(feedbackIcon, size: 16, color: feedbackColor),
          const SizedBox(width: 4),
          Text(
            feedbackLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: feedbackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
