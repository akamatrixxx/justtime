class UserSetting {
  final int workStartHour;
  final int workStartMinute;
  final int workEndHour;
  final int workEndMinute;

  final int sleepStartHour;
  final int sleepStartMinute;
  final int sleepEndHour;
  final int sleepEndMinute;

  UserSetting({
    required this.workStartHour,
    required this.workStartMinute,
    required this.workEndHour,
    required this.workEndMinute,
    required this.sleepStartHour,
    required this.sleepStartMinute,
    required this.sleepEndHour,
    required this.sleepEndMinute,
  });
}
