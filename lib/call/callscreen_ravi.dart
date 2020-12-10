//import 'dart:async';
//import 'dart:io';
//import 'package:avatar_glow/avatar_glow.dart';
//import 'package:dio/dio.dart';
//import 'package:huna/call/call_singleton.dart';
//import 'package:huna/constant.dart';
//import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
//import 'package:huna/manager/preference.dart';
//import 'package:huna/manager/sound_player.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_webrtc/webrtc.dart';
//import 'package:flutter/services.dart';
//import 'package:huna/overlay_pip/overlay_handler.dart';
//import 'package:huna/utils/show.dart';
//import 'package:huna/utils/utils.dart';
//import 'package:huna/widgets/action_button_call.dart';
//import 'package:huna/widgets/action_button_call_options.dart';
//import 'package:overlay_support/overlay_support.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:provider/provider.dart';
//import 'package:responsive_widgets/responsive_widgets.dart';
//import 'package:screen/screen.dart';
//
//class CallScreenPage extends StatefulWidget {
//  final SIPUAHelper _helper;
//  final Call _call;
//
//  CallScreenPage(this._helper, this._call, {Key key}) : super(key: key);
//
//  @override
//  _MyCallScreenWidget createState() => _MyCallScreenWidget();
//}
//
//class _MyCallScreenWidget extends State<CallScreenPage>
//    implements SipUaHelperListener {
//  var callerName = " ";
//  var showVideoControl = true;
//  var firstTimeSpeakerOff = true;
//  var inPipMode = false;
//  double aspectRatio = 20 / 9;
//  var isMore = false;
//  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//  var firstTime = true;
//  double _localVideoHeight;
//  double _localVideoWidth;
//  MediaStream _localStream;
//  MediaStream _remoteStream;
//
//  bool _audioMuted = false;
//  bool _videoMuted = false;
//  bool _speakerOn = false;
//  bool _hold = false;
//  String _holdOriginator;
//  List temp = <int>[];
//
//  bool _isSnapUploading = false;
//
//  CallStateEnum _state = CallStateEnum.NONE;
//
//  SIPUAHelper get helper => widget._helper;
//
//  Call get call => widget._call;
//
//  bool get voiceOnly =>
//      (_localStream == null || _localStream.getVideoTracks().isEmpty) &&
//      (_remoteStream == null || _remoteStream.getVideoTracks().isEmpty);
//
//  String callingOrTimer = "Calling...";
//  Color callingOrTimerColor = Colors.white;
//  bool showAdvanceCallOptions = false;
//  bool canRestartTimer = false;
//  bool swapView = false;
//
//  Timer _timer;
//  String _timeLabel = '';
//
//  @override
//  initState() {
//    super.initState();
//    _initRenderers();
//    helper.addSipUaHelperListener(this);
//    _startTimer();
//
//    PreferencesManager().getCurrentCallerName().then((value) => {
//          this.setState(() {
//            callerName = value;
//          })
//        });
//
//    Screen.keepOn(true);
//  }
//
//  @override
//  deactivate() {
//    super.deactivate();
//    helper.removeSipUaHelperListener(this);
//    _disposeRenderers();
//  }
//
//  void _startTimer() {
//    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
//      Duration duration = Duration(seconds: timer.tick);
//      if (mounted) {
//        this.setState(() {
//          _timeLabel = [duration.inMinutes, duration.inSeconds]
//              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
//              .join(':');
//        });
//      } else {
//        _timer.cancel();
//      }
//    });
//  }
//
//  //Call States
//  @override
//  void callStateChanged(Call call, CallState callState) {
//    print("CALL_EVENT : " + callState.state.toString());
//
//    if (callState.state == CallStateEnum.HOLD ||
//        callState.state == CallStateEnum.UNHOLD) {
//      _hold = callState.state == CallStateEnum.HOLD;
//      _holdOriginator = callState.originator;
//      this.setState(() {});
//      return;
//    }
//
//    if (callState.state == CallStateEnum.MUTED) {
//      if (callState.audio) _audioMuted = true;
//      if (callState.video) _videoMuted = true;
//      this.setState(() {});
//      return;
//    }
//
//    if (callState.state == CallStateEnum.UNMUTED) {
//      if (callState.audio) _audioMuted = false;
//      if (callState.video) _videoMuted = false;
//      this.setState(() {});
//      return;
//    }
//
//    if (callState.state != CallStateEnum.STREAM) {
//      _state = callState.state;
//    }
//
//    switch (callState.state) {
//      case CallStateEnum.STREAM:
//        _handelStreams(callState);
//        break;
//
//      case CallStateEnum.ENDED:
//
//      case CallStateEnum.FAILED:
//        // _backToDialPad();
//        break;
//
//      case CallStateEnum.UNMUTED:
//      case CallStateEnum.MUTED:
//      case CallStateEnum.CONNECTING:
//      case CallStateEnum.PROGRESS:
//      case CallStateEnum.ACCEPTED:
//        setSpeakerOffFirstTime();
//        break;
//
//      case CallStateEnum.CONFIRMED:
//      case CallStateEnum.HOLD:
//      case CallStateEnum.UNHOLD:
//      case CallStateEnum.NONE:
//      case CallStateEnum.CALL_INITIATION:
//      case CallStateEnum.REFER:
//        print("CALL REFER");
//        break;
//    }
//  }
//
//  @override
//  void transportStateChanged(TransportState state) {}
//
//  @override
//  void registrationStateChanged(RegistrationState state) {}
//
//  //Back to Dial Screen
//  void _backToDialPad() {
//    Timer(Duration(seconds: 2), () {
//      if (Navigator.canPop(context)) {
//        Navigator.pop(context);
//      }
//    });
//  }
//
//  //Handle  call Stream
//  void _handelStreams(CallState event) async {
//
//    MediaStream stream = event.stream;
//    if (event.originator == 'local') {
//      if (_localRenderer != null) {
//        _localRenderer.srcObject = stream;
//        _remoteRenderer.objectFit =
//            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
//      }
//
//
//      .delayed(const Duration(milliseconds: 1000), () {
//        _localStream = stream;
//      });
//    }
//    if (event.originator == 'remote') {
//      if (_remoteRenderer != null) {
//          startHideControl();
//        _remoteRenderer.srcObject = stream;
//        _remoteRenderer.objectFit =
//            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
//      }
//      _remoteStream = stream;
//      print("LOCAL" + _remoteStream.getVideoTracks().length.toString());
//    }
//
//    //setSpeakerOffFirstTime();
//
//    this.setState(() {
//      _resizeLocalVideo();
//    });
//  }
//
//  //___________CALL FUNCTIONS-----------
//
//  //Hangup function
//  void _handleHangup() {
//    call.hangup();
//    _timer.cancel();
//    if (Navigator.canPop(context)) {
//      //  Navigator.pop(context);
//    }
//  }
//
//  //Accept Function
//  void _handleAccept() {
//    SoundPlayer.stopSound();
//    call.answer(helper.buildCallOptions());
//  }
//
//  //Mute Audio
//  void _muteAudio() {
//    if (_audioMuted) {
//      call.unmute(true, false);
//    } else {
//      call.mute(true, false);
//    }
//  }
//
//  //Mute Audio
//  void _transferCall() {
//    var target = "";
//    call.refer('600');
//  }
//
//  //Mute Video
//  void _muteVideo() {
//    if (_videoMuted) {
//      call.unmute(false, true);
//    } else {
//      call.mute(false, true);
//    }
//  }
//
//  //Hold
//  void _handleHold() {
//    if (_hold) {
//      call.unhold();
//    } else {
//      call.hold();
//    }
//  }
//
//  //Speaker
//  void _toggleSpeaker() {
//
//    _speakerOn = !_speakerOn;
//
//    if(_remoteStream !=null) {
//      if(_remoteStream.getAudioTracks().isNotEmpty) {
//        _remoteStream.getAudioTracks().first.enableSpeakerphone(_speakerOn);
//      }
//    }
//    if(_localStream !=null) {
//      if(_localStream.getAudioTracks().isNotEmpty) {
//        _localStream.getAudioTracks().first.enableSpeakerphone(_speakerOn);
//      }
//    }
//  }
//
//  //___________CALL FUNCTIONS-----------
//
//  //________VIDEO------------
//
//  void _initRenderers() async {
//    if (_localRenderer != null) {
//      await _localRenderer.initialize();
//    }
//    if (_remoteRenderer != null) {
//      await _remoteRenderer.initialize();
//    }
//  }
//
//  void _disposeRenderers() {
//    if (_localRenderer != null) {
//      _localRenderer.dispose();
//      _localRenderer = null;
//
//      try {
//        _localStream.dispose();
//      } catch (e) {
//        print(e);
//      }
//    }
//    if (_remoteRenderer != null) {
//      _remoteRenderer.dispose();
//      _remoteRenderer = null;
//
//      try {
//        _remoteStream.dispose();
//      } catch (e) {
//        print(e);
//      }
//    }
//  }
//
//  //Resize Local Video
//  void _resizeLocalVideo() {
//    _localVideoWidth =
//        _remoteStream != null ? 100 : MediaQuery.of(context).size.width;
//    _localVideoHeight =
//        _remoteStream != null ? 150 : MediaQuery.of(context).size.height;
//  }
//
//  //Switch Camera
//  void _switchCamera() {
//    if (_localStream != null) {
//      _localStream.getVideoTracks()[0].switchCamera();
//    }
//  }
//
//  //_______VIDEO-------------
//
//  //OUTGOING CALL UI [AVATAR, INFO, TIMER]__________
//  Widget _buildContentIncomingOutGoingCall(bool isVideo, bool isIncoming) {
//    callingOrTimer = isIncoming ? "Incoming Call..." : "Calling...";
//
//    switch (_state) {
//      case CallStateEnum.CONNECTING:
//        callingOrTimer = isIncoming ? "Incoming Call..." : "Calling...";
//        callingOrTimerColor = Colors.white;
//        break;
//      case CallStateEnum.CONFIRMED:
//        temp.add(1);
//
//        if (temp.length == 1) {
//          _timer.cancel();
//          _startTimer();
//          _timeLabel = '';
//        }
//
//        callingOrTimer = _timeLabel;
//        callingOrTimerColor = Colors.green[400];
//        break;
//    }
//
//    print("CALL_S" + _state.toString());
//
//    var stackWidgets = <Widget>[];
//
//    //Video Outgoing call
//    if (isVideo) {
//      stackWidgets.addAll([
//        Align(
//            alignment: Alignment.topCenter,
//            child: Container(
//                width: double.infinity,
//                height: double.infinity,
//                child: Align(
//                    alignment: Alignment.topCenter,
//                    child: Stack(
//                      children: <Widget>[
//                        Container(
//                          // margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//                          color: Colors.black54,
//                          width: MediaQuery.of(context).size.width,
//                          height: MediaQuery.of(context).size.height,
//                          child: Container(
//                              height: double.infinity,
//                              width: double.infinity,
//                              child: Stack(children: <Widget>[
//                                Center(
//                                  child: RTCVideoView(_remoteRenderer),
//                                ),
//                                InkWell(
//                                  onTap: () {
//                                    showHideVideoControl();
//                                    setState(() {
//                                      /*if(!swapView){
//                                    _remoteRenderer = _localRenderer;
//                                    _localRenderer = _remoteRenderer;
//                                     swapView = true;
//                                  }else{
//                                    _localRenderer = _remoteRenderer;
//                                    _remoteRenderer = _localRenderer;
//                                    swapView = false;
//                                  }*/
//                                    });
//                                  },
//                                  child: Container(
//                                    child: AnimatedContainer(
//                                      color: Colors.black,
//                                      padding: EdgeInsets.fromLTRB(
//                                          0.0, 0.0, 0.0, 0.0),
//                                      child: RTCVideoView(_localRenderer),
//                                      height: _localVideoHeight,
//                                      width: _localVideoWidth,
//                                      alignment: Alignment.topRight,
//                                      duration: Duration(milliseconds: 300),
//                                    ),
//                                    alignment: Alignment.topRight,
//                                  ),
//                                ),
//                              ])),
//                        ),
//                        showVideoControl ? Container(
//                          color: Colors.black26,
//                          height: 65,
//                          child: Column(
//                            children: [
//                              Padding(
//                                padding: const EdgeInsets.fromLTRB(
//                                    0.0, 36.0, 0.0, 0.0),
//                              ),
//                              Stack(
//                                children: <Widget>[
//                                  Padding(
//                                    padding: const EdgeInsets.fromLTRB(
//                                        20.0, 0.0, 20.0, 0.0),
//                                    child: InkWell(
//                                      onTap: () {
//                                        onBackPress();
//                                      },
//                                      child: Icon(Icons.arrow_back,
//                                          size: 25.0, color: Colors.white),
//                                    ),
//                                  ),
//                                  Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
//                                    children: [
//                                      Text(callerName,
//                                          style: TextStyle(
//                                              color: callingOrTimerColor,
//                                              fontSize: 15.0)),
//                                    ],
//                                  ),
//                                  Row(
//                                    mainAxisAlignment: MainAxisAlignment.end,
//                                    children: [
//                                      Text(callingOrTimer + "  ",
//                                          style: TextStyle(
//                                              color: Colors.white,
//                                              fontSize: 15.0)),
//                                    ],
//                                  ),
//                                ],
//                              ),
//                            ],
//                          ),
//                        ) : Container()
//                      ],
//                    ))))
//      ]);
//
//      /*if (!voiceOnly && _remoteStream != null) {
//          stackWidgets.add(Center(
//            child: RTCVideoView(_remoteRenderer),
//          ));
//        }
//
//        if (!voiceOnly && _localStream != null) {
//          stackWidgets.add(Container(
//            child: AnimatedContainer(
//              padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
//              child: RTCVideoView(_localRenderer),
//              height: _localVideoHeight,
//              width: _localVideoWidth,
//              alignment: Alignment.topRight,
//              duration: Duration(milliseconds: 300),
//              margin: _localVideoMargin,
//            ),
//            alignment: Alignment.topRight,
//          ));
//        }*/
//
//    } else {
//      // ext((voiceOnly ? 'INCOMING CALL' : 'INCOMING CALL') + (_hold ? ' PAUSED BY ${this._holdOriginator.toUpperCase()}'
//
//      stackWidgets.addAll([
//        Align(
//            alignment: Alignment.topCenter,
//            child: Container(
//                margin: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
//                width: double.infinity,
//                height: 325,
//                child: Align(
//                  alignment: Alignment.topCenter,
//                  child: Column(
//                    children: [
//                      Stack(
//                        children: <Widget>[
//                          Padding(
//                            padding:
//                                const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
//                            child: InkWell(
//                              onTap: () {
//                                onBackPress();
//                              },
//                              child: Icon(Icons.arrow_back,
//                                  size: 26.0, color: Colors.white),
//                            ),
//                          ),
//                          Row(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: [
//                              Icon(Icons.call,
//                                  size: 20.0, color: callingOrTimerColor),
//                              Padding(
//                                  padding:
//                                      EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0)),
//                              Text(callingOrTimer,
//                                  style: TextStyle(
//                                      color: callingOrTimerColor,
//                                      fontSize: 18.0)),
//                            ],
//                          ),
//                        ],
//                      ),
//                      Padding(
//                          padding:
//                              const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
//                          child: Text(callerName,
//                              style: TextStyle(
//                                color: Colors.white,
//                                fontSize: 26.0,
//                              ))),
//                      Padding(
//                          padding:
//                              const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//                          child: CircleAvatar(
//                            radius: 100,
//                            backgroundColor: Colors.transparent,
//                            child: ClipOval(
//                              child: AvatarGlow(
//                                glowColor: Colors.white,
//                                endRadius: 100.0,
//                                duration: Duration(milliseconds: 2000),
//                                repeat: true,
//                                animate: true,
//                                showTwoGlows: true,
//                                repeatPauseDuration:
//                                    Duration(milliseconds: 100),
//                                child: Material(
//                                  elevation: 8.0,
//                                  shape: CircleBorder(
//                                    side: BorderSide(
//                                        width: 2, color: Colors.white),
//                                  ),
//                                  child: CircleAvatar(
//                                    radius: 60,
//                                    backgroundColor: colorAccent,
//                                    child: Text(getFirstLetter(callerName),
//                                        style: TextStyle(
//                                            fontSize: 40,
//                                            fontWeight: FontWeight.normal,
//                                            color: Colors.white)),
//                                  ),
//                                ),
//                              ),
//                            ),
//                          ))
//                    ],
//                  ),
//                )))
//      ]);
//    }
//
//    return Stack(children: stackWidgets);
//  }
//
//  //__________OUTGOING CALL UI [AVATAR, INFO, TIMER]__________
//
//  //OUTGOING CALL UI [ACTION BUTTONS]__________
//
//  Widget _buildActionButtonsUpdate() {
//    var hangupBtn = ActionButtonCall(
//      title: "Hangup",
//      onPressed: () => _handleHangup(),
//      icon: Icons.call_end,
//      fillColor: Colors.red,
//    );
//
//    var buttonsBasic = <Widget>[];
//    var buttonsAdvance = <Widget>[];
//
//    if (voiceOnly) {
//      buttonsBasic.add(hangupBtn);
//
//      buttonsAdvance.add(ActionButtonCallOptions(
//        title: 'Mute',
//        icon: Icons.mic,
//        checked: _audioMuted,
//        onPressed: () => _muteAudio(),
//      ));
//
//      buttonsAdvance.add(ActionButtonCallOptions(
//        title: 'Transfer',
//        icon: Icons.call_made,
//        checked: false,
//        onPressed: () => _transferCall(),
//      ));
//
//      buttonsAdvance.add(ActionButtonCallOptions(
//        title: _speakerOn ? 'Speaker' : 'Speaker',
//        icon: Icons.volume_up,
//        checked: _speakerOn,
//        onPressed: () => _toggleSpeaker(),
//      ));
//
//      buttonsAdvance.add(ActionButtonCallOptions(
//        title: _hold ? 'Resume' : 'Hold',
//        icon: _hold ? Icons.play_arrow : Icons.pause,
//        checked: _hold,
//        onPressed: () => _handleHold(),
//      ));
//
//      /*buttonsAdvance.add(ActionButtonCallOptions(
//        title: "Record",
//        icon: Icons.fiber_manual_record,
//        onPressed: () => _startRecord(),
//      ));*/
//    } else {
//      showVideoControl ? videoControlUi(buttonsAdvance) : [];
//
////     // buttonsBasic.add(hangupBtn);
////
////      buttonsAdvance.add(ActionButtonCallOptions(
////        title: _audioMuted ? 'Mute' : 'Mute',
////        icon: Icons.mic,
////        checked: _audioMuted,
////        onPressed: () => _muteAudio(),
////      ));
////
////      buttonsAdvance.add(ActionButtonCallOptions(
////        title: _speakerOn ? 'Speaker' : 'Speaker',
////        icon: Icons.volume_up,
////        checked: _speakerOn,
////        onPressed: () => _toggleSpeaker(),
////      ));
////
////
////
////
////
////      buttonsAdvance.add(ActionButtonCallOptions(
////        title: _hold ? 'Resume' : 'Hold',
////        icon: _hold ? Icons.play_arrow : Icons.pause,
////        checked: _hold,
////        onPressed: () => _handleHold(),
////      ));
////
////
////
////        buttonsAdvance.add(ActionButtonCallOptions(
////        title: "Switch",
////        icon: Icons.switch_video,
////        onPressed: () => _switchCamera(),
////      ));
////
////      /* buttonsAdvance.add(ActionButtonCallOptions(
////         title: _videoMuted ? "Camera" : 'Camera',
////         icon: _videoMuted ? Icons.videocam : Icons.videocam_off,
////         checked: _videoMuted,
////         onPressed: () => _muteVideo(),
////      ));*/
////
////
////      buttonsAdvance.add(ActionButtonCallOptions(
////          title: "Snapshot",
////          icon: Icons.camera,
////          onPressed: () => onSnapShot()
////      ));
////
////      buttonsAdvance.add(hangupBtn);
//
//    }
//
//    switch (_state) {
//      case CallStateEnum.NONE:
//      case CallStateEnum.CONNECTING:
//        showAdvanceCallOptions = false;
//
//        if (call.direction == 'INCOMING') {
//          var temp = <Widget>[];
//
//          var declineButton = ActionButtonCall(
//            title: "Decline",
//            onPressed: () => _handleHangup(),
//            icon: Icons.call_end,
//            fillColor: Colors.red,
//          );
//
//          var answerButton = ActionButtonCall(
//            title: "Accept",
//            fillColor: Colors.green,
//            icon: Icons.phone,
//            onPressed: () => _handleAccept(),
//          );
//
//          temp.add(declineButton);
//          temp.add(answerButton);
//
//          buttonsBasic = temp;
//        }
//
//        break;
//      case CallStateEnum.ACCEPTED:
//      case CallStateEnum.CONFIRMED:
//        showAdvanceCallOptions = true;
//        break;
//      case CallStateEnum.FAILED:
//        break;
//      case CallStateEnum.ENDED:
//        try {} catch (e) {
//          print(e);
//        }
//        break;
//      case CallStateEnum.PROGRESS:
//        if (!buttonsBasic.contains(hangupBtn)) {
//          buttonsBasic.add(hangupBtn);
//        }
//        break;
//      default:
//        print('Other state => $_state');
//        break;
//    }
//
//    var actionWidgets = <Widget>[];
//
//    if (buttonsAdvance.isNotEmpty) {
//      actionWidgets.add(Padding(
//          padding: const EdgeInsets.all(0),
//          child: AnimatedOpacity(
//              // If the widget is visible, animate to 0.0 (invisible).
//              // If the widget is hidden, animate to 1.0 (fully visible).
//              opacity: showAdvanceCallOptions ? 1.0 : 0.0,
//              duration: Duration(milliseconds: 300),
//              // The green box must be a child of the AnimatedOpacity widget.
//              //use this as child
//              child: Row(
//                mainAxisSize: MainAxisSize.max,
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: buttonsAdvance,
//              ))));
//    }
//
//    if (voiceOnly) {
//      actionWidgets.add(Padding(
//          padding: const EdgeInsets.fromLTRB(3, 15, 3, 3),
//          child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: buttonsBasic)));
//    }
//
//    return Column(
//        crossAxisAlignment: CrossAxisAlignment.end,
//        mainAxisAlignment: MainAxisAlignment.end,
//        children: actionWidgets);
//  }
//
//  //_______OUTGOING CALL UI [ACTION BUTTONS]__________
//
//  @override
//  Widget build(BuildContext context) {
//    return WillPopScope(
//      onWillPop: () async {
//        onBackPress();
//      },
//      child: inPipMode
//          ? Scaffold(
//              appBar: null,
//              body: pipMode(),
//            )
//          : Scaffold(
//              appBar: null,
//              body: GestureDetector(
//                onTap: () {
//                  // onBackPress();
//                },
//                child: Container(
//                    height: MediaQuery.of(context).size.height,
//                    width: MediaQuery.of(context).size.width,
//                    decoration: BoxDecoration(
//                      gradient: LinearGradient(
//                          colors: [Colors.black54, colorAccent],
//                          begin: Alignment.topRight,
//                          end: Alignment.bottomLeft),
//                    ),
//                    //child: Container()
//                    child: directionOfCall()),
//              ),
//              floatingActionButtonLocation:
//                  FloatingActionButtonLocation.centerFloat,
//              floatingActionButton: Padding(
//                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
//                  child: Container(
//                      width: MediaQuery.of(context).size.width,
//                      child: _buildActionButtonsUpdate()
//                      //child: Container()
//                      ))),
//    );
//  }
//
//  //Direction Of Call
//  Widget directionOfCall() {
//    if (call.direction == "INCOMING") {
//      return _buildContentIncomingOutGoingCall(
//          !voiceOnly && _localStream != null, true);
//    } else {
//      return _buildContentIncomingOutGoingCall(
//          !voiceOnly && _localStream != null, false);
//    }
//  }
//
//  Widget pipMode() {
//    return InkWell(
//        onTap: () {
//          setState(() {
//            inPipMode = !inPipMode;
//            Provider.of<OverlayHandlerProvider>(context, listen: false)
//                .disablePip();
//          });
//        },
//        child: Container(
//          margin: const EdgeInsets.all(1.0),
//          padding: const EdgeInsets.all(3.0),
//          width: double.infinity,
//          height: double.infinity,
//          color: Colors.black26,
//          child: AvatarGlow(
//            glowColor: Colors.white,
//            endRadius: 70.0,
//            duration: Duration(milliseconds: 2000),
//            repeat: true,
//            animate: true,
//            showTwoGlows: true,
//            repeatPauseDuration: Duration(milliseconds: 100),
//            child: Material(
//              elevation: 2.0,
//              shape: CircleBorder(
//                side: BorderSide(width: 2, color: Colors.white),
//              ),
//              child: CircleAvatar(
//                radius: 35,
//                backgroundColor: colorAccent,
//                child: Text(getFirstLetter(callerName),
//                    style: TextStyle(
//                        fontSize: 28,
//                        fontWeight: FontWeight.normal,
//                        color: Colors.white)),
//              ),
//            ),
//          ),
//        ));
//  }
//
//  @override
//  void onNewMessage(SIPMessageRequest msg) {}
//
//  void _startRecord() {}
//
//  void onBackPress() {
//    setState(() {
//      inPipMode = !inPipMode;
//      Provider.of<OverlayHandlerProvider>(context, listen: false)
//          .enablePip(aspectRatio);
//    });
//  }
//
//  void onSnapShot() async {
//
//    if (!Platform.isAndroid) {
//      Show.showToast('For now This feature is available in Android only...', false);
//      return;
//    }
//
//
//    if (_isSnapUploading) {
//      Show.showToast('Snap uploading is already in progress...', false);
//      return;
//    }
//
//    _isSnapUploading = true;
//
//    Show.showToast('Snap uploading..', false);
//
//    var filePath = "";
//
//    if (Platform.isAndroid) {
//      final storagePath = await getTemporaryDirectory();
//      filePath = storagePath.path + '/test.jpg';
//    } else {
//      final storagePath = await getApplicationDocumentsDirectory();
//      filePath = storagePath.path + '/test.jpg';
//    }
//
//    if (_remoteStream != null) {
//      if (_remoteStream.getVideoTracks().isNotEmpty) {
//        await _remoteStream.getVideoTracks()[0].captureFrame(filePath);
//        if (filePath.isNotEmpty) {
//          sendFile(filePath, FILE_UPLOAD);
//        }
//
////        if (filePath.isNotEmpty) {
////          showDialog(
////              context: context,
////              builder: (context) => AlertDialog(
////                    content: Image.asset(filePath, height: 720, width: 1280),
////                    actions: <Widget>[
////                      FlatButton(
////                        child: Text("OK"),
////                        onPressed:
////                            Navigator.of(context, rootNavigator: true).pop,
////                      )
////                    ],
////                  ));
////        }
//
//      } else {
//        Show.showToast('Please wait...', false);
//        _isSnapUploading = false;
//      }
//    } else {
//      Show.showToast('Stream not available', false);
//      _isSnapUploading = false;
//    }
//  }
//
//  void sendFile(String filePath, String url) async {
//    var email = await PreferencesManager().getEmail();
//    var token = await PreferencesManager().getToken();
//
//    var formData = FormData.fromMap({
//      'imageDetail': '$email' + DateTime.now().toString(),
//      'imageFile': await MultipartFile.fromFile(filePath,
//          filename: DateTime.now().toString() + ".jpg")
//    });
//
//    var dio = Dio();
//    dio.options.headers[HttpHeaders.authorizationHeader] = token;
//    var response = new Response(); //Response from Dio
//    response = await dio.post(url, data: formData);
//    print(response);
//    print(response.data['response']);
//
//    if (response.data['response'] == "SUCCESS") {
//      _isSnapUploading = false;
//
//      showSimpleNotification(Text("Snap uploaded"),
//          background: Colors.cyan, key: Key('SNAP_UI'));
//    } else {
//      _isSnapUploading = false;
//
//      showSimpleNotification(Text("Snap uploading failed"),
//          background: Colors.red, key: Key('SNAP_UI'));
//    }
//  }
//
//  void videoControlUi(List<Widget> videoCallButtonsWidget) {
//    videoCallButtonsWidget.add(Container(
//        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
//        padding: const EdgeInsets.all(15.0),
//        decoration: new BoxDecoration(
//          //you can get rid of below line also
//          borderRadius: new BorderRadius.circular(10.0),
//          //below line is for rectangular shape
//          shape: BoxShape.rectangle,
//          //you can change opacity with color here(I used black) for rect
//          color: Colors.black.withOpacity(0.5),
//          //I added some shadow, but you can remove boxShadow also.
//          boxShadow: <BoxShadow>[
//            new BoxShadow(
//              color: Colors.black26,
//              blurRadius: 5.0,
//              offset: new Offset(5.0, 5.0),
//            ),
//          ],
//        ),
//        child: isMore ? getMoreVideoControls() : getVideoControls()));
//
//    return;
//  }
//
//  getVideoControls() {
//    print("LOVEEEEEEEEEEEEEEEE");
//
//    double marginLeft = 12, marginRight = 12, iconSize = 30;
//
//
//    return Padding(
//        padding: const EdgeInsets.all(1),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: _videoMuted
//                    ? Icon(Icons.videocam_off,
//                        color: Colors.white, size: iconSize)
//                    : Icon(Icons.videocam, color: Colors.white, size: iconSize),
//                onTap: () {
//                  _muteVideo();
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: _audioMuted
//                    ? Icon(Icons.mic_off, color: Colors.white, size: iconSize)
//                    : Icon(Icons.mic, color: Colors.white, size: iconSize),
//                onTap: () {
//                  _muteAudio();
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: _speakerOn
//                    ? Icon(Icons.volume_up, color: Colors.white, size: iconSize)
//                    : Icon(Icons.volume_down,
//                        color: Colors.white, size: iconSize),
//                onTap: () {
//                  _toggleSpeaker();
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child:
//                    Icon(Icons.more_horiz, color: Colors.white, size: iconSize),
//                onTap: () {
//                  print("more");
//                  setState(() {
//                    isMore = true;
//                  });
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: Icon(Icons.call_end, color: Colors.red, size: iconSize),
//                onTap: () {
//                  _handleHangup();
//                },
//              ),
//            )
//          ],
//        ));
//  }
//
//  getMoreVideoControls() {
//    double marginLeft = 12, marginRight = 12, iconSize = 30;
//
//    return Padding(
//        padding: const EdgeInsets.all(1),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: Icon(Icons.camera, color: Colors.white, size: iconSize),
//                onTap: () {
//                  onSnapShot();
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: Icon(Icons.open_in_browser,
//                    color: Colors.white, size: iconSize),
//                onTap: () {
//                  print("Hyy");
//                  onScreenShare();
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: Icon(Icons.fiber_manual_record,
//                    color: Colors.red, size: iconSize),
//                onTap: () {
//                  Show.showToast('Record Version 2', false);
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child: Icon(Icons.switch_video,
//                    color: Colors.white, size: iconSize),
//                onTap: () {
//                  _switchCamera();
//                },
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
//              child: InkWell(
//                child:
//                    Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
//                onTap: () {
//                  setState(() {
//                    isMore = false;
//                  });
//                },
//              ),
//            )
//          ],
//        ));
//  }
//
//  void onScreenShare() async {
//    Show.showToast('Screen share Version 2', false);
//
////    print("HEEEEEEEEYYYYYYYY");
////
////    if (_localRenderer != null) {
////      _localRenderer.dispose();
////      _localRenderer = null;
////      _localStream.dispose();
////      _localRenderer.initialize();
////    }
////
////
////    Timer(Duration(seconds: 1), () {
////      helper.startScreenShare(call);
////    });
//  }
//
//  void showHideVideoControl() {
//    this.setState(() {
//      showVideoControl = !showVideoControl;
//    });
//  }
//
//  void startHideControl() {
//
//
//    if(firstTime) {
//
//      Timer(Duration(seconds: 20), () {
//
//        if(showVideoControl == false) {
//          firstTime = ! firstTime;
//        }else {
//          setState(() {
//            showVideoControl = !showVideoControl;
//            firstTime = ! firstTime;
//          });
//        }
//
//      });
//
//    }
//  }
//
//  void setSpeakerOffFirstTime() {
//
//    print("ACCEEPT ACCEPT ACEPT");
//
//    if(firstTimeSpeakerOff) {
//
//      if(_remoteStream !=null) {
//        if(_remoteStream.getAudioTracks().isNotEmpty) {
//          _remoteStream.getAudioTracks().first.enableSpeakerphone(false);
//        }
//      }
//      if(_localStream !=null) {
//        if(_localStream.getAudioTracks().isNotEmpty) {
//          _localStream.getAudioTracks().first.enableSpeakerphone(false);
//        }
//      }
//
//      firstTimeSpeakerOff = false;
//    }
//  }
//}
