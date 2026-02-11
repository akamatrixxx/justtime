import 'package:shared_preferences/shared_preferences.dart';
import 'user_setting_repository.dart';

class InMemoryUserSettingRepository implements UserSettingRepository {
  bool _firstLaunch = true;

  @override
  bool isFirstLaunch() {
    return _firstLaunch;
  }

  @override
  void markFirstLaunchCompleted() {
    _firstLaunch = false;
  }
}
