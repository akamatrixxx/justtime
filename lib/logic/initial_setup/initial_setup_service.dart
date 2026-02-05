import 'package:flutter/foundation.dart';
import 'dart:developer';

class InitialSetupService {
  void completeInitialSetup({
    required int workStartHour,
    required int workStartMinute,
    required int workEndHour,
    required int workEndMinute,
    required int sleepStartHour,
    required int sleepStartMinute,
    required int sleepEndHour,
    required int sleepEndMinute,
  }) {
    // 就業時間帯中央値
    final start = workStartHour * 60 + workStartMinute;
    final end = workEndHour * 60 + workEndMinute;
    final mid = (start + end) ~/ 2;

    final midHour = mid ~/ 60;
    final midMinute = mid % 60;

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

    // TODO: Repository保存（次ステップ）
  }
}
