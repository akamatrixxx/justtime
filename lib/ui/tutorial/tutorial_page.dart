import 'package:flutter/cupertino.dart';
import '../../logic/initial_setup/initial_setup_service.dart';
import '../widgets/time_range_input.dart';

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
  int workStartHour = 18;
  int workStartMinute = 0;
  int workEndHour = 20;
  int workEndMinute = 0;

  int sleepStartHour = 23;
  int sleepStartMinute = 0;
  int sleepEndHour = 7;
  int sleepEndMinute = 0;

  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('初期設定'),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'あなたの一日を教えてください',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '通知のタイミングを決めるのに使います',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _submitting ? null : _completeTutorial,
                  child: const Text(
                    '完了',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTutorial() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
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
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
