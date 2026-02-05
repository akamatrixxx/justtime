class AppStartService {
  bool _isFirstLaunch = true; // ← 今は仮。後でSQLiteにする

  bool isFirstLaunch() {
    return _isFirstLaunch;
  }

  void completeTutorial() {
    _isFirstLaunch = false;
  }
}
