import 'package:flutter/material.dart';

class UserSetting {
  final bool isFirstLaunch;
  final DateTime? lastUsedDate;

  final TimeOfDay workStart;
  final TimeOfDay workEnd;

  final TimeOfDay sleepStart;
  final TimeOfDay sleepEnd;

  UserSetting({
    required this.isFirstLaunch,
    required this.lastUsedDate,
    required this.workStart,
    required this.workEnd,
    required this.sleepStart,
    required this.sleepEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_first_launch': isFirstLaunch ? 1 : 0,
      'last_used_date': lastUsedDate?.toIso8601String().split('T').first,

      'work_start_hour': workStart.hour,
      'work_start_minute': workStart.minute,
      'work_end_hour': workEnd.hour,
      'work_end_minute': workEnd.minute,

      'sleep_start_hour': sleepStart.hour,
      'sleep_start_minute': sleepStart.minute,
      'sleep_end_hour': sleepEnd.hour,
      'sleep_end_minute': sleepEnd.minute,
    };
  }

  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      isFirstLaunch: map['is_first_launch'] == 1,
      lastUsedDate: map['last_used_date'] != null
          ? DateTime.parse(map['last_used_date'])
          : null,

      workStart: TimeOfDay(
        hour: map['work_start_hour'],
        minute: map['work_start_minute'],
      ),
      workEnd: TimeOfDay(
        hour: map['work_end_hour'],
        minute: map['work_end_minute'],
      ),

      sleepStart: TimeOfDay(
        hour: map['sleep_start_hour'],
        minute: map['sleep_start_minute'],
      ),
      sleepEnd: TimeOfDay(
        hour: map['sleep_end_hour'],
        minute: map['sleep_end_minute'],
      ),
    );
  }
}
