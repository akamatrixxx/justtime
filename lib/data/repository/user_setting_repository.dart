import '../model/user_setting.dart';

abstract class UserSettingRepository {
  /// 初回起動かどうか
  Future<bool> isFirstLaunch();

  /// 初回起動完了を保存
  Future<void> markFirstLaunchCompleted();

  /// ユーザー設定を保存
  Future<void> saveUserSetting(UserSetting setting);

  /// ユーザー設定を読み込み
  Future<UserSetting?> loadUserSetting();

  /// 最終使用日を取得
  Future<DateTime?> getLastUsedDate();

  /// 最終使用日を更新
  Future<void> setLastUsedDate(DateTime date);

  /// デバッグ用: user_settingテーブルの内容を表示
  Future<void> debugPrintUserSetting();
}

abstract class UserSettingInMemory {
  /// 初回起動かどうか
  bool isFirstLaunch();

  /// 初回起動完了を保存
  void markFirstLaunchCompleted();
}
