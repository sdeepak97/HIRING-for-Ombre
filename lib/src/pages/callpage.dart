import 'package:agora_rtc_engine/rtc_engine.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:streaming/src/utils/settings.dart';

class CallPage extends StatefulWidget {
  final ClientRole? role;

  CallPage({
    Key? key,
    this.role,
  }) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _user = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;
  bool video = false;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _user.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'App_id missing ,please provide your App-id in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    //!_intiAgoraRtcEngine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);

    //! _addAgoraEventHandlers
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = const VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(token, 'videocall', null, 0);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'Error:$code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = "join Channel: $channel,uid: $uid";
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add("leave Channel");
          _user.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = "user Joined:$uid";
          _infoStrings.add(info);
          _user.add(uid);
        });
      },
      userOffline: (uid, elapsed) async {
        setState(() {
          final info = "user Offline:$uid";
          _infoStrings.add(info);
          _user.remove(uid);
        });
        
        Navigator.pop(context);
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = "First remote video:$uid ${width}x$height";
          _infoStrings.add(info);
        });
      },
    ));
  }

  Widget _viewRows() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(const rtc_local_view.SurfaceView());
    }
    for (var uid in _user) {
      list.add(rtc_remote_view.SurfaceView(
        uid: uid,
        channelId: 'videocall',
      ));
    }
    final views = list;
    return Column(
      children:
          List.generate(views.length, (index) => Expanded(child: views[index])),
    );
  }

  Widget _panel() {
    return Visibility(
      visible: viewPanel,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: ListView.builder(
                  reverse: true,
                  itemCount: _infoStrings.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_infoStrings.isEmpty) {
                      return const Text("null");
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(_infoStrings[index],
                                style: const TextStyle(color: Colors.blueGrey)),
                          ))
                        ],
                      ),
                    );
                  })),
        ),
      ),
    );
  }

  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return const SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
      child: Row(
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 20,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              setState(() {
                video = !video;
              });
              _engine.enableLocalVideo(!video);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: video ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12),
            child: Icon(
              video ? Icons.videocam_off : Icons.videocam_off,
              color: video ? Colors.white : Colors.blueAccent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Stream"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      floatingActionButton: flatbutton(),
      body: Center(
          child: Stack(
        children: [_viewRows(), _panel(), _toolbar()],
      )),
    );
  }

  Widget flatbutton() {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      onPressed: () {
        setState(() {
          viewPanel = !viewPanel;
        });
      },
      child: const SizedBox(
        width: 30,
        height: 30,
        child: Icon(Icons.people),
      ),
    );
  }
}
