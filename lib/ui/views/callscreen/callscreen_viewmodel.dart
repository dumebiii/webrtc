import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stacked/stacked.dart';
import 'package:webrtc/services/signalling_service.dart';

class CallscreenViewModel extends BaseViewModel {


// socket instance
  final socket = SignallingService.instance.socket;

  // videoRenderer for localPeer
  final RTCVideoRenderer localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final RTCVideoRenderer remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? localStream;

  // RTC peer connection
  RTCPeerConnection? rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCandidates = [];

  // media status
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  final String callerId, calleeId;
  final dynamic offer;

  CallscreenViewModel({required this.callerId, required this.calleeId, this.offer});

  // Initialize the video renderers and peer connection
  Future<void> initialize() async {
    await localRTCVideoRenderer.initialize();
    await remoteRTCVideoRenderer.initialize();

    // setup Peer Connection
    await _setupPeerConnection();
  }

  Future<void> _setupPeerConnection() async {
    rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302',
          ]
        }
      ]
    });

    // Listen for remotePeer mediaTrack event
    rtcPeerConnection!.onTrack = (event) {
      remoteRTCVideoRenderer.srcObject = event.streams[0];
      notifyListeners();
    };

    // Get localStream
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
          ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
          : false,
    });

    // Add mediaTrack to peerConnection
    localStream!.getTracks().forEach((track) {
      rtcPeerConnection!.addTrack(track, localStream!);
    });

    // Set source for local video renderer
    localRTCVideoRenderer.srcObject = localStream;
    notifyListeners();

    // Incoming Call logic
    if (offer != null) {
      await _handleIncomingCall();
    } else {
      await _handleOutgoingCall();
    }
  }

  Future<void> _handleIncomingCall() async {
    // Listen for remote IceCandidate
    socket!.on("IceCandidate", (data) {
      final candidate = data["iceCandidate"]["candidate"];
      final sdpMid = data["iceCandidate"]["id"];
      final sdpMLineIndex = data["iceCandidate"]["label"];

      rtcPeerConnection!.addCandidate(
        RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
      );
    });

    // Set SDP offer as remoteDescription
    await rtcPeerConnection!.setRemoteDescription(
      RTCSessionDescription(offer["sdp"], offer["type"]),
    );

    // Create SDP answer
    final answer = await rtcPeerConnection!.createAnswer();

    // Set SDP answer as localDescription
    rtcPeerConnection!.setLocalDescription(answer);

    // Send SDP answer to remote peer
    socket!.emit("answerCall", {
      "callerId": callerId,
      "sdpAnswer": answer.toMap(),
    });
  }

  Future<void> _handleOutgoingCall() async {
    // Listen for local iceCandidate
    rtcPeerConnection!.onIceCandidate =
        (RTCIceCandidate candidate) => rtcIceCandidates.add(candidate);

    // When call is accepted by remote peer
    socket!.on("callAnswered", (data) async {
      await rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(
          data["sdpAnswer"]["sdp"],
          data["sdpAnswer"]["type"],
        ),
      );

      // Send IceCandidates to remote peer
      for (final candidate in rtcIceCandidates) {
        socket!.emit("IceCandidate", {
          "calleeId": calleeId,
          "iceCandidate": {
            "id": candidate.sdpMid,
            "label": candidate.sdpMLineIndex,
            "candidate": candidate.candidate,
          }
        });
      }
    });

    // Create SDP offer
    final offer = await rtcPeerConnection!.createOffer();

    // Set SDP offer as localDescription
    await rtcPeerConnection!.setLocalDescription(offer);

    // Make a call to remote peer
    socket!.emit('makeCall', {
      "calleeId": calleeId,
      "sdpOffer": offer.toMap(),
    });
  }

  // Toggle microphone
  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    notifyListeners();
  }

  // Toggle camera
  void toggleCamera() {
    isVideoOn = !isVideoOn;
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    notifyListeners();
  }

  // Switch camera
  void switchCamera() {
    isFrontCameraSelected = !isFrontCameraSelected;
    localStream?.getVideoTracks().forEach((track) {
      track.switchCamera();
    });
    notifyListeners();
  }

  // Leave call
  void leaveCall() {
    localRTCVideoRenderer.dispose();
    remoteRTCVideoRenderer.dispose();
    localStream?.dispose();
    rtcPeerConnection?.dispose();
  }
}
