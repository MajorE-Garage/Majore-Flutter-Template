import '../../core/presentation/navigation/app_navigator.dart';
import '../../core/presentation/ui_components/overlays/app_toast_widget.dart';
import '../../main/environment_config.dart';

mixin CustomWillPopScopeMixin {
  static bool _secondBack = false;
  static const secondTapDurationSpace = Duration(seconds: 2);
  void onSecondBackPop(bool didPop, _) async {
    if (didPop) return;
    if (!_secondBack) {
      AppToast.info('Press back again to close ${EnvironmentConfig.appName}').show();
      _secondBack = true;
      Future.delayed(secondTapDurationSpace, () => _secondBack = false);
    } else {
      AppNavigator.main.pop();
    }
  }

  void delayAndPop(bool didPop, _) async {
    AppToast.info('Closing ${EnvironmentConfig.appName}').show();
    Future.delayed(secondTapDurationSpace, () => AppNavigator.main.pop());
  }
}
