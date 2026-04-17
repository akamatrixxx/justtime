import 'package:flutter/material.dart';
import '../../data/model/user_setting.dart';
import '../../data/repository/user_setting_repository.dart';

class SettingsService {
  final UserSettingRepository userSettingRepository;

  SettingsService(this.userSettingRepository);

  Future<UserSetting?> load() => userSettingRepository.loadUserSetting();

  Future<void> updateTimes({
    required TimeOfDay workStart,
    required TimeOfDay workEnd,
    required TimeOfDay sleepStart,
    required TimeOfDay sleepEnd,
  }) async {
    final current = await userSettingRepository.loadUserSetting();
    final updated = UserSetting(
      isFirstLaunch: false,
      lastUsedDate: current?.lastUsedDate ?? DateTime.now(),
      workStart: workStart,
      workEnd: workEnd,
      sleepStart: sleepStart,
      sleepEnd: sleepEnd,
    );
    await userSettingRepository.saveUserSetting(updated);
  }
}
