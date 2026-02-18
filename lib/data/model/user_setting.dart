class UserSetting {
  final bool isFirstLaunch;
  final DateTime? lastUsedDate;

  final int workStartHour;
  final int workStartMinute;
  final int workEndHour;
  final int workEndMinute;

  final int sleepStartHour;
  final int sleepStartMinute;
  final int sleepEndHour;
  final int sleepEndMinute;

  UserSetting({
    required this.isFirstLaunch,
    required this.lastUsedDate,
    required this.workStartHour,
    required this.workStartMinute,
    required this.workEndHour,
    required this.workEndMinute,
    required this.sleepStartHour,
    required this.sleepStartMinute,
    required this.sleepEndHour,
    required this.sleepEndMinute,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_first_launch': isFirstLaunch ? 1 : 0,
      'last_used_date': lastUsedDate?.toIso8601String().split('T').first,
      'work_start_hour': workStartHour,
      'work_start_minute': workStartMinute,
      'work_end_hour': workEndHour,
      'work_end_minute': workEndMinute,
      'sleep_start_hour': sleepStartHour,
      'sleep_start_minute': sleepStartMinute,
      'sleep_end_hour': sleepEndHour,
      'sleep_end_minute': sleepEndMinute,
    };
  }

  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      isFirstLaunch: map['is_first_launch'] == 1,
      lastUsedDate: map['last_used_date'] != null
          ? DateTime.parse(map['last_used_date'])
          : null,
      workStartHour: map['work_start_hour'],
      workStartMinute: map['work_start_minute'],
      workEndHour: map['work_end_hour'],
      workEndMinute: map['work_end_minute'],
      sleepStartHour: map['sleep_start_hour'],
      sleepStartMinute: map['sleep_start_minute'],
      sleepEndHour: map['sleep_end_hour'],
      sleepEndMinute: map['sleep_end_minute'],
    );
  }
}
