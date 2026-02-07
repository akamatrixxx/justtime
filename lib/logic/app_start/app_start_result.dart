import '../../data/model/daily_state.dart';
import '../state/app_state.dart';

class AppStartResult {
  final AppState appState;
  final DailyState dailyState;

  AppStartResult({required this.appState, required this.dailyState});
}
