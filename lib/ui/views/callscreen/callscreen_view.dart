import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stacked/stacked.dart';

import 'callscreen_viewmodel.dart';

class CallscreenView extends StackedView<CallscreenViewModel> {
  final String callerId, calleeId;
  final dynamic offer;
  const CallscreenView({
    Key? key,
    this.offer,
    required this.callerId,
    required this.calleeId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CallscreenViewModel viewModel,
    Widget? child,
  ) {
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("P2P Call App")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  RTCVideoView(
                    viewModel.remoteRTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: SizedBox(
                      height: 150,
                      width: 120,
                      child: RTCVideoView(
                        viewModel.localRTCVideoRenderer,
                        mirror: viewModel.isFrontCameraSelected,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(viewModel.isAudioOn ? Icons.mic : Icons.mic_off),
                    onPressed: viewModel.toggleMic,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end),
                    iconSize: 30,
                    onPressed: () {
                      viewModel.leaveCall();
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch),
                    onPressed: viewModel.switchCamera,
                  ),
                  IconButton(
                    icon: Icon(viewModel.isVideoOn
                        ? Icons.videocam
                        : Icons.videocam_off),
                    onPressed: viewModel.toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  CallscreenViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CallscreenViewModel(callerId: callerId, calleeId: calleeId, offer: offer);
  @override
  void onViewModelReady(CallscreenViewModel viewModel) {
    // Initialize video renderers and setup peer connection when ViewModel is ready
    viewModel.initialize();
  }
}
