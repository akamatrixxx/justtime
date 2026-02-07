abstract class UserSettingRepository {
  Future<bool> isTutorialCompleted();
  Future<void> setTutorialCompleted(bool completed);
}
