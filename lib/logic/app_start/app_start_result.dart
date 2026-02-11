// lib/logic/app_start/app_start_result.dart
import '../../logic/state/app_state.dart';

class AppStartResult {
  final bool needTutorial;
  final AppState appState;

  AppStartResult({required this.needTutorial, required this.appState});
}
