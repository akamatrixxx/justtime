import 'package:shared_preferences/shared_preferences.dart';
import 'user_setting_repository.dart';

class UserSettingRepositoryImpl implements UserSettingRepository {
  static const _tutorialKey = 'tutorial_completed';

  @override
  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialKey) ?? false;
  }

  @override
  Future<void> setTutorialCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, completed);
  }
}
