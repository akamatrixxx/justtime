import 'package:flutter/material.dart';
import '../../data/model/user_setting.dart';
import '../../data/repository/user_setting_repository.dart';
import '../common/time_range_picker.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  final UserSettingRepository userSettingRepository;

  const SettingsPage({super.key, required this.userSettingRepository});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int workStartHour = 18;
  int workStartMinute = 0;
  int workEndHour = 20;
  int workEndMinute = 0;

  int sleepStartHour = 23;
  int sleepStartMinute = 0;
  int sleepEndHour = 23;
  int sleepEndMinute = 30;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final setting = await widget.userSettingRepository.loadUserSetting();
    if (setting != null) {
      setState(() {
        workStartHour = setting.workStart.hour;
        workStartMinute = setting.workStart.minute;
        workEndHour = setting.workEnd.hour;
        workEndMinute = setting.workEnd.minute;
        sleepStartHour = setting.sleepStart.hour;
        sleepStartMinute = setting.sleepStart.minute;
        sleepEndHour = setting.sleepEnd.hour;
        sleepEndMinute = setting.sleepEnd.minute;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final setting = UserSetting(
      isFirstLaunch: false,
      lastUsedDate: DateTime.now(),
      workStart: TimeOfDay(hour: workStartHour, minute: workStartMinute),
      workEnd: TimeOfDay(hour: workEndHour, minute: workEndMinute),
      sleepStart: TimeOfDay(hour: sleepStartHour, minute: sleepStartMinute),
      sleepEnd: TimeOfDay(hour: sleepEndHour, minute: sleepEndMinute),
    );

    await widget.userSettingRepository.saveUserSetting(setting);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('設定を保存しました')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                onPressed: _saveSettings,
                child: const Text('保存'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
