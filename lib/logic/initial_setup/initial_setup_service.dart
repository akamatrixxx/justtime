import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    debugPrint('[P1] === Completing Initial Setup ===');
    // [未対応] 通知許可リクエスト

    // 現在時刻取得
    final today = DateTime.now();

    // 初回通知時刻算出（就業時間帯中央値）
    final start = workStartHour * 60 + workStartMinute;
    final end = workEndHour * 60 + workEndMinute;
    final mid = (start + end) ~/ 2;

    final midHour = mid ~/ 60;
    final midMinute = mid % 60;

    // ユーザ設定保存
    final setting = UserSetting(
      isFirstLaunch: false,
      lastUsedDate: today,
      workStart: TimeOfDay(hour: workStartHour, minute: workStartMinute),
      workEnd: TimeOfDay(hour: workEndHour, minute: workEndMinute),
      sleepStart: TimeOfDay(hour: sleepStartHour, minute: sleepStartMinute),
      sleepEnd: TimeOfDay(hour: sleepEndHour, minute: sleepEndMinute),
    );

    await userSettingRepository.saveUserSetting(setting);

    // 当日DailyState生成
    final state = DailyState(
      date: today,
      notifyTime: TimeOfDay(hour: midHour, minute: midMinute),
      feedbackCompleted: false,
    );

    await dailyStateRepository.save(state);

    debugPrint(
      '[P1] Work: ${workStartHour.toString().padLeft(2, '0')}:${workStartMinute.toString().padLeft(2, '0')} - ${workEndHour.toString().padLeft(2, '0')}:${workEndMinute.toString().padLeft(2, '0')}',
    );
    debugPrint(
      '[P1] Sleep: ${sleepStartHour.toString().padLeft(2, '0')}:${sleepStartMinute.toString().padLeft(2, '0')} - ${sleepEndHour.toString().padLeft(2, '0')}:${sleepEndMinute.toString().padLeft(2, '0')}',
    );
    debugPrint(
      '[P1] Initial Notification Time: ${midHour.toString().padLeft(2, '0')}:${midMinute.toString().padLeft(2, '0')}',
    );
  }
}
