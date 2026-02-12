class DailyState {
  final DateTime date;
  final DateTime notifyTime;
  final bool feedbackCompleted;

  DailyState({
    required this.date,
    required this.notifyTime,
    required this.feedbackCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T').first,
      'notify_time': notifyTime.toIso8601String(),
      'feedback_completed': feedbackCompleted ? 1 : 0,
    };
  }

  factory DailyState.fromMap(Map<String, dynamic> map) {
    return DailyState(
      date: DateTime.parse(map['date']),
      notifyTime: DateTime.parse(map['notify_time']),
      feedbackCompleted: map['feedback_completed'] == 1,
    );
  }
}
