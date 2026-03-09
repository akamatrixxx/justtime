import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import '../../data/model/user_setting.dart';
import '../../data/repository/user_setting_repository.dart';
import '../../data/model/daily_state.dart';
import '../../data/repository/daily_state_repository.dart';
import '../../data/db/app_database.dart';
import '../notification_service/notification_service.dart';
import '../notification_time/notification_time_service.dart';

class InitialSetupService {
  final UserSettingRepository userSettingRepository;
  InitialSetupService(this.userSettingRepository, this.notificationService);
  final dailyStateRepository = DailyStateRepository(AppDatabase.database);
  final NotificationService notificationService;

  Future<void> _runInitialSetup() async {
    await notificationService.init();
    await notificationService.requestPermission();
  }

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

    // 通知許可リクエスト
    _runInitialSetup();

    // 現在時刻取得
    final today = DateTime.now();

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

    // 初回通知時刻算出（就業時間帯中央値）をNotificationTimeServiceへ移譲
    final notificationTimeService = NotificationTimeService(
      notificationService,
    );
    final initialNotifyTime = notificationTimeService.calcInitialNotifyTime(
      workStart: TimeOfDay(hour: workStartHour, minute: workStartMinute),
      workEnd: TimeOfDay(hour: workEndHour, minute: workEndMinute),
    );

    debugPrint(
      '[P1] Work: ${workStartHour.toString().padLeft(2, '0')}:${workStartMinute.toString().padLeft(2, '0')} - ${workEndHour.toString().padLeft(2, '0')}:${workEndMinute.toString().padLeft(2, '0')}',
    );
    debugPrint(
      '[P1] Sleep: ${sleepStartHour.toString().padLeft(2, '0')}:${sleepStartMinute.toString().padLeft(2, '0')} - ${sleepEndHour.toString().padLeft(2, '0')}:${sleepEndMinute.toString().padLeft(2, '0')}',
    );
    debugPrint(
      '[P1] Initial Notification Time: ${initialNotifyTime.hour.toString().padLeft(2, '0')}:${initialNotifyTime.minute.toString().padLeft(2, '0')}',
    );

    // 当日DailyState生成
    final state = DailyState(
      date: today,
      notifyTime: initialNotifyTime,
      feedbackCompleted: false,
      feedbackType: null,
    );
    debugPrint('[P1] Saving DailyState for today: $state');
    await dailyStateRepository.save(state);

    // 通知スケジュール設定
    await notificationService.scheduler.scheduleDaily(state.notifyTime);
  }
}
