import 'package:flutter/material.dart';
import '../../logic/initial_setup/initial_setup_service.dart';
import '../common/time_range_picker.dart';
import '../theme/app_theme.dart';

class TutorialPage extends StatefulWidget {
  final VoidCallback onCompleted;
  final InitialSetupService initialSetupService;

  const TutorialPage({
    super.key,
    required this.onCompleted,
    required this.initialSetupService,
  });

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  // 終業時間帯（デフォルト）
  int workStartHour = 18;
  int workStartMinute = 0;
  int workEndHour = 20;
  int workEndMinute = 0;

  // 就寝時間帯（デフォルト）
  int sleepStartHour = 23;
  int sleepStartMinute = 0;
  int sleepEndHour = 23;
  int sleepEndMinute = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Header
              Center(
                child: Icon(
                  Icons.access_time_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'JustTimeへようこそ！',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'あなたの生活リズムに合わせて\n通知時刻を最適化します',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              // Work time section
              _SectionHeader(
                icon: Icons.work_outline,
                title: '終業時刻',
                color: AppColors.work,
              ),
              const SizedBox(height: 12),
              TimeRangePickerCard(
                title: '終業時間帯',
                description: '仕事が終わる時間帯を設定します',
                startHour: workStartHour,
                startMinute: workStartMinute,
                endHour: workEndHour,
                endMinute: workEndMinute,
                onStartChanged: (h, m) =>
                    setState(() { workStartHour = h; workStartMinute = m; }),
                onEndChanged: (h, m) =>
                    setState(() { workEndHour = h; workEndMinute = m; }),
              ),
              const SizedBox(height: 32),
              // Sleep time section
              _SectionHeader(
                icon: Icons.nightlight_round,
                title: '就寝時刻',
                color: AppColors.rest,
              ),
              const SizedBox(height: 12),
              TimeRangePickerCard(
                title: '就寝時間帯',
                description: '寝る時間帯を設定します',
                startHour: sleepStartHour,
                startMinute: sleepStartMinute,
                endHour: sleepEndHour,
                endMinute: sleepEndMinute,
                onStartChanged: (h, m) =>
                    setState(() { sleepStartHour = h; sleepStartMinute = m; }),
                onEndChanged: (h, m) =>
                    setState(() { sleepEndHour = h; sleepEndMinute = m; }),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeTutorial,
                  child: const Text('設定を完了する'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _completeTutorial() async {
    await widget.initialSetupService.completeInitialSetup(
      workStartHour: workStartHour,
      workStartMinute: workStartMinute,
      workEndHour: workEndHour,
      workEndMinute: workEndMinute,
      sleepStartHour: sleepStartHour,
      sleepStartMinute: sleepStartMinute,
      sleepEndHour: sleepEndHour,
      sleepEndMinute: sleepEndMinute,
    );

    widget.onCompleted();
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
