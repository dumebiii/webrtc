import 'package:flutter/material.dart';
// import 'package:webrtc/app/app.locator.dart';
// import 'package:webrtc/app/app.router.dart';
import 'package:webrtc/services/signalling_service.dart';
import 'package:stacked/stacked.dart';
// import 'package:stacked_services/stacked_services.dart';
import 'package:webrtc/ui/views/callscreen/callscreen_view.dart';

class HomeViewModel extends BaseViewModel {
  // final _navigationService = locator<NavigationService>();
  dynamic _incomingSDPOffer;
  final String _selfCallerId;
  final TextEditingController remoteCallerIdTextEditingController =
      TextEditingController();

  HomeViewModel(this._selfCallerId);

  dynamic get incomingSDPOffer => _incomingSDPOffer;
  String get selfCallerId => _selfCallerId;

  void initialize() {
  listenForIncomingCalls();
}

  // Listen for incoming video calls
  void listenForIncomingCalls() {
    SignallingService.instance.socket!.on("newCall", (data) {
      _incomingSDPOffer = data;
      notifyListeners();
    });
  }

  // Method to handle joining the call
  void joinCall({
    required BuildContext context,
    required String calleeId,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallscreenView(
          callerId: selfCallerId,
          calleeId: calleeId,
          offer: offer,
        ),
      ),
    );
  }

// Method to reject incoming calls
  void rejectCall() {
    _incomingSDPOffer = null;
    notifyListeners();
  }
}
