abstract class UserSettingRepository {
  /// 初回起動かどうか
  Future<bool> isFirstLaunch();

  /// 初回起動完了を保存
  Future<void> markFirstLaunchCompleted();
}

abstract class UserSettingInMemory {
  /// 初回起動かどうか
  bool isFirstLaunch();

  /// 初回起動完了を保存
  void markFirstLaunchCompleted();
}
