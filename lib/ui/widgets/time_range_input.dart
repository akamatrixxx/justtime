import 'package:flutter/cupertino.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeWheel(
                value: startHour,
                max: 23,
                onChanged: (h) => onStartChanged(h, startMinute),
              ),
              const _Colon(),
              _TimeWheel(
                value: startMinute,
                max: 59,
                onChanged: (m) => onStartChanged(startHour, m),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('〜', style: TextStyle(fontSize: 18)),
              ),
              _TimeWheel(
                value: endHour,
                max: 23,
                onChanged: (h) => onEndChanged(h, endMinute),
              ),
              const _Colon(),
              _TimeWheel(
                value: endMinute,
                max: 59,
                onChanged: (m) => onEndChanged(endHour, m),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(':', style: TextStyle(fontSize: 18)),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _TimeWheel({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 130,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: value),
        itemExtent: 32,
        onSelectedItemChanged: onChanged,
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
          background: CupertinoColors.activeBlue.withAlpha(30),
        ),
        children: List.generate(
          max + 1,
          (i) => Center(
            child: Text(
              i.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
