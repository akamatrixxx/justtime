import 'package:flutter/foundation.dart';
import 'dart:developer';
import '../../data/model/user_setting.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/model/daily_state.dart';
import '../../data/repository/daily_state_repository.dart';
import '../../data/db/app_database.dart';

class InitialSetupService {
  final UserSettingRepository userSettingRepository;
  InitialSetupService(this.userSettingRepository);
  final dailyStateRepository = DailyStateRepository(AppDatabase.database);

  Future<void> completeInitialSetup({
    required int workStartHour,
    required int workStartMinute,
    required int workEndHour,
    required int workEndMinute,
    required int sleepStartHour,
    required int sleepStartMinute,
    required int sleepEndHour,
    required int sleepEndMinute,
  }) async {
    final today = DateTime.now();
    final setting = UserSetting(
      isFirstLaunch: false,
      lastUsedDate: today,
      workStartHour: workStartHour,
      workStartMinute: workStartMinute,
      workEndHour: workEndHour,
      workEndMinute: workEndMinute,
      sleepStartHour: sleepStartHour,
      sleepStartMinute: sleepStartMinute,
      sleepEndHour: sleepEndHour,
      sleepEndMinute: sleepEndMinute,
    );

    await userSettingRepository.saveUserSetting(setting);

    // 就業時間帯中央値
    final start = workStartHour * 60 + workStartMinute;
    final end = workEndHour * 60 + workEndMinute;
    final mid = (start + end) ~/ 2;

    final midHour = mid ~/ 60;
    final midMinute = mid % 60;

    final state = DailyState(
      date: today,
      notifyTime: DateTime(
        today.year,
        today.month,
        today.day,
        midHour,
        midMinute,
      ),
      feedbackCompleted: false,
    );

    await dailyStateRepository.save(state);

    log(
      '初回通知時刻: '
      '${midHour.toString().padLeft(2, '0')}:'
      '${midMinute.toString().padLeft(2, '0')}',
    );

    debugPrint('=== Initial Setup ===');
    debugPrint(
      'Work: ${workStartHour.toString().padLeft(2, '0')}:${workStartMinute.toString().padLeft(2, '0')} - ${workEndHour.toString().padLeft(2, '0')}:${workEndMinute.toString().padLeft(2, '0')}',
    );
    debugPrint(
      'Sleep: ${sleepStartHour.toString().padLeft(2, '0')}:${sleepStartMinute.toString().padLeft(2, '0')} - ${sleepEndHour.toString().padLeft(2, '0')}:${sleepEndMinute.toString().padLeft(2, '0')}',
    );
    debugPrint(
      'Initial Notification Time: ${midHour.toString().padLeft(2, '0')}:${midMinute.toString().padLeft(2, '0')}',
    );
  }
}
