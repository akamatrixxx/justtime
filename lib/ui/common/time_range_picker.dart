import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimeRangePickerCard extends StatelessWidget {
  final String title;
  final String? description;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final void Function(int h, int m) onStartChanged;
  final void Function(int h, int m) onEndChanged;

  const TimeRangePickerCard({
    super.key,
    required this.title,
    this.description,
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
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        )),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TimeTile(
                label: '開始',
                hour: startHour,
                minute: startMinute,
                onChanged: onStartChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
            ),
            Expanded(
              child: _TimeTile(
                label: '終了',
                hour: endHour,
                minute: endMinute,
                onChanged: onEndChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final int hour;
  final int minute;
  final void Function(int h, int m) onChanged;

  const _TimeTile({
    required this.label,
    required this.hour,
    required this.minute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTimePicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    var selectedHour = hour;
    var selectedMinute = minute;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      Text(
                        '$label時刻',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onChanged(selectedHour, selectedMinute);
                          Navigator.pop(context);
                        },
                        child: const Text('決定'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: DateTime(2000, 1, 1, hour, minute),
                    onDateTimeChanged: (dt) {
                      selectedHour = dt.hour;
                      selectedMinute = dt.minute;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
