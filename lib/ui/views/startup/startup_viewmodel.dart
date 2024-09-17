import 'dart:math';
import 'package:stacked/stacked.dart';
import 'package:webrtc/app/app.locator.dart';
import 'package:webrtc/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webrtc/services/signalling_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  // signalling server url
  final String websocketUrl = "WEB_SOCKET_SERVER_URL";

  // generate callerID of local user
  final String selfCallerID =
      Random().nextInt(999999).toString().padLeft(6, '0');

  // Initialize the signalling service and navigate to home
  Future runStartupLogic() async {
    // Simulate a delay for startup
    await Future.delayed(const Duration(seconds: 3));

    // Initialize the signalling service
    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerID: selfCallerID,
    );

    // Navigate to home after initialization
    _navigationService.replaceWithHomeView();
  }
}
