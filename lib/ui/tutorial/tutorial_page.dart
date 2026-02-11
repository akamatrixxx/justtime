import 'package:flutter/material.dart';
import '../../logic/initial_setup/initial_setup_service.dart';

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
  int sleepEndHour = 24;
  int sleepEndMinute = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('初期設定')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TimeRangeInput(
              title: '終業時刻',
              startHour: workStartHour,
              startMinute: workStartMinute,
              endHour: workEndHour,
              endMinute: workEndMinute,
              onStartChanged: (h, m) =>
                  setState(() => {workStartHour = h, workStartMinute = m}),
              onEndChanged: (h, m) =>
                  setState(() => {workEndHour = h, workEndMinute = m}),
            ),
            const SizedBox(height: 24),
            TimeRangeInput(
              title: '就寝時刻',
              startHour: sleepStartHour,
              startMinute: sleepStartMinute,
              endHour: sleepEndHour,
              endMinute: sleepEndMinute,
              onStartChanged: (h, m) =>
                  setState(() => {sleepStartHour = h, sleepStartMinute = m}),
              onEndChanged: (h, m) =>
                  setState(() => {sleepEndHour = h, sleepEndMinute = m}),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _completeTutorial,
              child: const Text('完了'),
            ),
          ],
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

class _FinishPage extends StatelessWidget {
  const _FinishPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('お疲れさまでした。', style: TextStyle(fontSize: 24))),
    );
  }
}

class TimeWheel extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const TimeWheel({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 120,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: value),
        itemExtent: 32,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: max + 1,
          builder: (_, i) => Center(child: Text(i.toString().padLeft(2, '0'))),
        ),
      ),
    );
  }
}

class TimeRangeInput extends StatelessWidget {
  final String title;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final void Function(int h, int m) onStartChanged;
  final void Function(int h, int m) onEndChanged;

  const TimeRangeInput({
    super.key,
    required this.title,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeWheel(
              value: startHour,
              max: 24,
              onChanged: (h) => onStartChanged(h, startMinute),
            ),
            const Text(':'),
            TimeWheel(
              value: startMinute,
              max: 59,
              onChanged: (m) => onStartChanged(startHour, m),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('~'),
            ),
            TimeWheel(
              value: endHour,
              max: 24,
              onChanged: (h) => onEndChanged(h, endMinute),
            ),
            const Text(':'),
            TimeWheel(
              value: endMinute,
              max: 59,
              onChanged: (m) => onEndChanged(endHour, m),
            ),
          ],
        ),
      ],
    );
  }
}
