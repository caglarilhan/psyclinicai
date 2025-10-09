import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../utils/theme.dart';

class WebRTCSimpleSession extends StatefulWidget {
  const WebRTCSimpleSession({super.key});

  @override
  State<WebRTCSimpleSession> createState() => _WebRTCSimpleSessionState();
}

class _WebRTCSimpleSessionState extends State<WebRTCSimpleSession> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _pc;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };
    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRenderer.srcObject = _localStream;

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };
    _pc = await createPeerConnection(config);
    _pc!.addStream(_localStream!);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _pc?.close();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teleterapi (WebRTC - Demo)'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
          const Divider(height: 1),
          Expanded(child: RTCVideoView(_remoteRenderer)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Not: Signaling sunucusu eklenmedi; bu ekran yerel kamera/mikrofon test içindir.'),
          )
        ],
      ),
    );
  }
}


