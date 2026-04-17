import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../../data/model/user_setting.dart';
import '../../logic/settings/settings_service.dart';
import '../widgets/time_range_input.dart';

class SettingsPage extends StatefulWidget {
  final SettingsService settingsService;

  const SettingsPage({super.key, required this.settingsService});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserSetting? _initial;
  bool _loading = true;
  bool _saving = false;

  late int workStartHour;
  late int workStartMinute;
  late int workEndHour;
  late int workEndMinute;
  late int sleepStartHour;
  late int sleepStartMinute;
  late int sleepEndHour;
  late int sleepEndMinute;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await widget.settingsService.load();
    if (!mounted) return;
    setState(() {
      _initial = s;
      workStartHour = s?.workStart.hour ?? 18;
      workStartMinute = s?.workStart.minute ?? 0;
      workEndHour = s?.workEnd.hour ?? 20;
      workEndMinute = s?.workEnd.minute ?? 0;
      sleepStartHour = s?.sleepStart.hour ?? 23;
      sleepStartMinute = s?.sleepStart.minute ?? 0;
      sleepEndHour = s?.sleepEnd.hour ?? 7;
      sleepEndMinute = s?.sleepEnd.minute ?? 0;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.settingsService.updateTimes(
        workStart: TimeOfDay(hour: workStartHour, minute: workStartMinute),
        workEnd: TimeOfDay(hour: workEndHour, minute: workEndMinute),
        sleepStart: TimeOfDay(hour: sleepStartHour, minute: sleepStartMinute),
        sleepEnd: TimeOfDay(hour: sleepEndHour, minute: sleepEndMinute),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('時間設定'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _loading || _saving ? null : _save,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  if (_initial == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '設定が見つからなかったので初期値を表示しています',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ),
                  TimeRangeInput(
                    title: '終業時刻',
                    startHour: workStartHour,
                    startMinute: workStartMinute,
                    endHour: workEndHour,
                    endMinute: workEndMinute,
                    onStartChanged: (h, m) => setState(() {
                      workStartHour = h;
                      workStartMinute = m;
                    }),
                    onEndChanged: (h, m) => setState(() {
                      workEndHour = h;
                      workEndMinute = m;
                    }),
                  ),
                  const SizedBox(height: 14),
                  TimeRangeInput(
                    title: '就寝時刻',
                    startHour: sleepStartHour,
                    startMinute: sleepStartMinute,
                    endHour: sleepEndHour,
                    endMinute: sleepEndMinute,
                    onStartChanged: (h, m) => setState(() {
                      sleepStartHour = h;
                      sleepStartMinute = m;
                    }),
                    onEndChanged: (h, m) => setState(() {
                      sleepEndHour = h;
                      sleepEndMinute = m;
                    }),
                  ),
                ],
              ),
      ),
    );
  }
}
