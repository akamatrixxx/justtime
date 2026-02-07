class DailyState {
  final DateTime date;
  final DateTime notifyTime;
  bool feedbackCompleted;

  DailyState({
    required this.date,
    required this.notifyTime,
    this.feedbackCompleted = false,
  });
}
