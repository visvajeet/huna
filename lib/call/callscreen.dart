import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:huna/call/call_widgets/call_controls_ui.dart';
import 'package:huna/call/call_widgets/top_ui.dart';
import 'package:huna/libraries/sip_ua/constants.dart';
import 'package:huna/libraries/sip_ua/enum_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/main_screen/action_button.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/overlay_pip/overlay_handler.dart';
import 'package:huna/utils/show.dart';
import 'package:huna/utils/utils.dart';
import 'package:huna/widgets/action_button_call.dart';
import 'package:huna/widgets/action_button_call_options.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screen_keep_on/screen_keep_on.dart';
import '../constant.dart';
import 'call_widgets/audio_call_ui.dart';
import 'call_widgets/incoming_outgoing_ui.dart';
import 'call_widgets/timer_ui.dart';

class CallScreenPage extends StatefulWidget {
  final SIPUAHelper _helper;
  final Call _call;
  final String callerName;
  CallScreenPage(this._helper, this._call,this.callerName);
  @override
  _CallScreenWidget createState() => _CallScreenWidget();
}

class _CallScreenWidget extends State<CallScreenPage>
    implements SipUaHelperListener {
  
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  CallControlsUI callControlsUI;
  TopUI topUI;
  double _localVideoHeight;
  double _localVideoWidth;
  var isSnapUploading = false;
  EdgeInsetsGeometry localVideoContainerMargin;

  var inPipMode = false;
  MediaStream _localStream;
  MediaStream _remoteStream;
  double aspectRatio = 20 / 9;
  var isMore = false;
  String callingOrTimer = "Calling...";
  double  fullScreenHeight = 0 ;
  double  fullScreenWidth = 0 ;
  String get callerName => widget.callerName;
  bool audioMuted = false;
  bool videoMuted = false;
  bool speakerOn = false;
  bool screenShare = false;
  bool inScreenShareMode = false;
  bool inCameraStreamMode = true;
  bool _hold = false;
  String _holdOriginator;
  Color callingOrTimerColor = Colors.white;


  SIPUAHelper get helper => widget._helper;

  bool get voiceOnly =>
      (_localStream == null || _localStream
          .getVideoTracks()
          .isEmpty) &&
          (_remoteStream == null || _remoteStream
              .getVideoTracks()
              .isEmpty);

  String get remote_identity => call.remote_identity;

  String get direction => call.direction;

  Call get call => widget._call;

  var callStart = false;

  @override
  initState() {
    super.initState();
    _initRenderers();
    helper.addSipUaHelperListener(this);
    ScreenKeepOn.turnOn(true);

  }


  initOtherWidgetClasses() {

    topUI = TopUI(onButtonPress: (button) {
      handelEvent(button);
    }, isOnOverlay: false);

    callControlsUI = CallControlsUI(onButtonPress: (button) {
      handelEvent(button);
    }, voiceOnly: voiceOnly,map: getMap() , helper: helper, );

  }

  setRenders() {

    fullScreenHeight  =  MediaQuery.of(context).size.height;

    fullScreenWidth  =  MediaQuery
        .of(context)
        .size
        .width;


    _localVideoHeight = fullScreenHeight;
    _localVideoWidth = fullScreenWidth;


  }

  @override
  deactivate() {
    super.deactivate();
    startingSecondsTimer = 0;
    helper.removeSipUaHelperListener(this);
    _disposeRenderers();
  }

  void _initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer.initialize();
      // for full screen
      _localRenderer.objectFit =
          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer.initialize();
      _remoteRenderer.objectFit =
          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
    }

    setRenders();
  }

  void _disposeRenderers() {
    if (_localRenderer != null) {
      _localRenderer.dispose();
      _localRenderer = null;
    }
    if (_remoteRenderer != null) {
      _remoteRenderer.dispose();
      _remoteRenderer = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return inPipMode
        ? Scaffold(
      appBar: null,
      body: pipMode(),
    )
        : Scaffold(
        appBar: null,
        body: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black54, colorAccent],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft),
            ),
            child: Stack(
              children: <Widget>[
                callStart ? callConfirmed() : initiationUI(),
                callStart ? topUI : Container()
              ],
            )

        ),

        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
            child: Container(
              child: callStart ? showControls() : Container(),
            )
        ));
  }

  showControls() {
   // Show.showToast("Mai 1 bar hi Chalunga", false);
    return  callControlsUI;
  }


  Widget pipMode() {

    return InkWell(
        onTap: () {

          initOtherWidgetClasses();

          setState(() {

            inPipMode = !inPipMode;
            Provider.of<OverlayHandlerProvider>(context, listen: false)
                .disablePip();
          });
        },
        child: Container(
            margin: const EdgeInsets.all(1.0),
            padding: const EdgeInsets.all(3.0),
            width: fullScreenWidth,
            height: fullScreenHeight,
            color: Colors.black26,

            child: Stack(
              children: <Widget>[

                AvatarGlow(
                  glowColor: Colors.white,
                  endRadius: 70.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  animate: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Material(
                    elevation: 2.0,
                    shape: CircleBorder(
                      side: BorderSide(width: 2, color: Colors.white),
                    ),

                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: colorAccent,
                      child: Text(getFirstLetter(callerName),
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.normal,
                              color: Colors.white)),
                    ),
                  ),
                ),

                TopUI(onButtonPress: (button) {
                  handelEvent(button);
                }, isOnOverlay: true,)

              ],
            )

        ));
  }


  // basic functions

  void _handleAccept() {
    SoundPlayer.stopSound();
    call.answer(helper.buildCallOptions());
  }

  void _handleHangup() {
    call.hangup();
  }


  // all advance functions

  /* String _tansfer_target;
  void _handleTransfer() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter target to transfer.'),
          content: TextField(
            onChanged: (String text) {
              setState(() {
                _tansfer_target = text;
              });
            },
            decoration: InputDecoration(
              hintText: 'URI or Username',
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                call.refer(_tansfer_target);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  //Hold
  void _handleHold() {
    if (_hold) {
      call.unhold();
    } else {
      call.hold();
    }
  }



  void _startRecord() {}


 void startHideControl() {
    if (firstTime) {
      Timer(Duration(seconds: 20), () {
        if (showVideoControl == false) {
          firstTime = !firstTime;
        } else {
          if (mounted) {
            setState(() {
              showVideoControl = !showVideoControl;
              firstTime = !firstTime;
            });
          }
        }
      });
    }
  }

  void setSpeakerOffFirstTime() {

    if(firstTimeSpeakerOff) {

      if(_remoteStream !=null) {
        if(_remoteStream.getAudioTracks().isNotEmpty) {
          _remoteStream.getAudioTracks().first.enableSpeakerphone(false);
        }
      }
      if(_localStream !=null) {

        if(_localStream.getAudioTracks().isNotEmpty) {
          _localStream.getAudioTracks().first.enableSpeakerphone(false);
        }
      }
      firstTimeSpeakerOff = false;
    }
  }*/


  /*//Mute Audio
  void muteAudio() {

    audioMuted = !audioMuted;

    if (audioMuted) {
      call.unmute(true, false);
    } else {
      call.mute(true, false);
    }
  }*/

  //Mute Audio

  void muteAudio() {

    audioMuted = !audioMuted;

    if(audioMuted) {
      call.mute(true, false);

    }else {
      call.unmute(true,false);
    }

  }

  /*//Speaker
  void toggleSpeaker() {

    speakerOn = !speakerOn;

    if (_localStream != null) {
      if (_localStream
          .getAudioTracks()
          .isNotEmpty) {
        _localStream
            .getAudioTracks()
            .first
            .enableSpeakerphone(speakerOn);
      }
    }

    if (_remoteStream != null) {
      if (_remoteStream
          .getAudioTracks()
          .isNotEmpty) {
        _remoteStream
            .getAudioTracks()
            .first
            .enableSpeakerphone(speakerOn);
      }
    }

  }*/

  void toggleSpeaker() {

    speakerOn = !speakerOn;

    if (_localStream != null) {

      if (_localStream

          .getAudioTracks()

          .isNotEmpty) {

        _localStream

            .getAudioTracks()

            .first

            .enableSpeakerphone(speakerOn);

      }

    }

    if (_remoteStream != null) {

      if (_remoteStream

          .getAudioTracks()

          .isNotEmpty) {

        _remoteStream

            .getAudioTracks()

            .first

            .enableSpeakerphone(speakerOn);

      }

    }

  }


  //Mute Video
  void muteVideo() {

    videoMuted = !videoMuted;

    if (videoMuted) {
      call.unmute(false, true);
    } else {
      call.mute(false, true);
    }

  }

  //Switch Camera
  void switchCamera() {
    if (_localStream != null) {
      _localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void onSnapShot() async {

    if (isSnapUploading) {
      Show.showToast('Snap uploading is already in progress...', false);
      return;
    }

    isSnapUploading = true;

    Show.showToast('Snap uploading..', false);

    var filePath = "";

    if (Platform.isAndroid) {
      final storagePath = await getTemporaryDirectory();
      filePath = storagePath.path + '/test.jpg';
    } else {
      final storagePath = await getApplicationDocumentsDirectory();
      filePath = storagePath.path + '/test.jpg';
    }

    if (_remoteStream != null) {
      if (_remoteStream.getVideoTracks().isNotEmpty) {
        await _remoteStream.getVideoTracks()[0].captureFrame(filePath);
        if (filePath.isNotEmpty) {
          sendFile(filePath, FILE_UPLOAD);
        }else{
          Show.showToast('Failed', false);
        }

        //show capture image in  Dialog
        /*if (filePath.isNotEmpty) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Image.asset(filePath, height: 720, width: 1280),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed:
                    Navigator.of(context, rootNavigator: true).pop,
                  )
                ],
              ));
        }*/

      } else {
        Show.showToast('Please wait...', false);
        isSnapUploading = false;
      }
    } else {
      Show.showToast('Stream not available', false);
      isSnapUploading = false;
    }
  }

  void sendFile(String filePath, String url) async {
    var email = await PreferencesManager().getEmail();
    var token = await PreferencesManager().getToken();

    var formData = FormData.fromMap({
      'imageDetail': '$email' + DateTime.now().toString(),
      'imageFile': await MultipartFile.fromFile(filePath,
          filename: DateTime.now().toString() + ".jpg")
    });

    var dio = Dio();
    dio.options.headers[HttpHeaders.authorizationHeader] = token;
    var response = new Response(); //Response from Dio
    response = await dio.post(url, data: formData);
    print(response);
    print(response.data['response']);

    if (response.data['response'] == "SUCCESS") {
      isSnapUploading = false;

      showSimpleNotification(Text("Snap uploaded"),
          background: Colors.cyan, key: Key('SNAP_UI'));
    } else {
      isSnapUploading = false;

      showSimpleNotification(Text("Snap uploading failed"),
          background: Colors.red, key: Key('SNAP_UI'));
    }
  }

  void onScreenShare(useScreen) async {

    screenShare = !screenShare;

    if (screenShare) {

      this._localRenderer.srcObject = null;
      this._localStream.dispose();
      // RTCSession

      call.session.startShareVideo(useScreen);

    } else {
      call.session.stopShareVideo(false);

    }


  }

  @override
  void callStateChanged(Call call, CallState callState) {

    callAnnouncementHandler(call,callState);

    if (callState.state == CallStateEnum.HOLD ||
        callState.state == CallStateEnum.UNHOLD) {
      _hold = callState.state == CallStateEnum.HOLD;
      _holdOriginator = callState.originator;
     // this.setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.MUTED) {
      if (callState.audio) audioMuted = true;
      if (callState.video) videoMuted = true;
     // this.setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.UNMUTED) {
      if (callState.audio) audioMuted = false;
      if (callState.video) videoMuted = false;
     // this.setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.CONFIRMED) {


      if (callStart == false) {
        initOtherWidgetClasses();
        setState(() {
          callStart = true;
        });
      }
    }

    if (callState.state == CallStateEnum.STREAM) {
       _handelStreams(callState);
    }
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  void _handelStreams(CallState event) async {

    MediaStream stream = event.stream;

    if (event.originator == 'local') {

      if (_localRenderer != null) {
        _localRenderer.srcObject = stream;
      }
      _localStream = stream;

      resizeLocalVideo();
    }
    if (event.originator == 'remote') {
      if (_remoteRenderer != null) {
        _remoteRenderer.srcObject = stream;
      }

      _remoteStream = stream;
      resizeLocalVideo();
    }
    //setSpeakerOffFirstTime();
  }

  void resizeLocalVideo() {

    setState(() {
      if(_remoteStream != null ) {
        _localVideoWidth = 100;
        _localVideoHeight = 130;
        localVideoContainerMargin = EdgeInsets.fromLTRB(10, 50, 10, 0);
      }
    });


  }

  flipVideo() {

    if(_remoteStream == null ) {
      Show.showToast("Remote User is not Ready ", false);
      return;
    }

     setState(() {

       if(_localVideoWidth == fullScreenWidth) {

         _localVideoWidth = 100;
         _localVideoHeight = 150;
         localVideoContainerMargin = EdgeInsets.fromLTRB(10, 50, 10, 0);

       }else {
         _localVideoWidth =  fullScreenWidth;
         _localVideoHeight =  fullScreenHeight;
         localVideoContainerMargin = EdgeInsets.fromLTRB(0, 0, 0, 0);
       }

     });

  }

  void onBackPress() {
    setState(() {
      inPipMode = !inPipMode;
      Provider.of<OverlayHandlerProvider>(context, listen: false)
          .enablePip(aspectRatio);
    });
  }

  void handelEvent(String button) {
    if (button == "Accept") {
      _handleAccept();
    }

    if (button == "Hangup") {
      _handleHangup();
    }

    if (button == "onBackPip") {
      onBackPress(); //Press();
    }

    if (button == "Snap") {
       onSnapShot();
    }

    if (button == "ScreenShare") {
        onScreenShare(true);
    }

    if (button == "SwitchCamera") {
      switchCamera();
    }

    if (button == "MuteVideo") {
      muteVideo();
    }

    if (button == "MuteAudio") {
      muteAudio();
    }

    if (button == "Speaker") {
      toggleSpeaker();
    }

  }

   initiationUI() {
    if (direction == 'INCOMING') {
      return IncomingOutGoingUI(onButtonPress: (button) {
        handelEvent(button);
      }, name: callerName, isOutGoing: false);
    } else {
      return IncomingOutGoingUI(onButtonPress: (button) {
        handelEvent(button);
      }, name: callerName, isOutGoing: true);
    }
  }


  Widget callConfirmed() {
    if (voiceOnly) { // returning StateLess Widget because voice call view never change
      return AudioCallUI(name: callerName);
    } else {
      // show video call ui
      return getVideoCallUI();
      // return AudioCallUI( onButtonPress: (String button) {handelEvent(button);},name: _name,voiceOnly: voiceOnly);
    }
  }



  Widget getVideoCallUI() {
    return  Container(
        width:MediaQuery.of(context).size.width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: Stack(
            alignment: Alignment.topRight,
            children: <Widget>[

              InkWell(
                onTap: () {
                  hideControls();
                },
                child: Container(
                  color: Colors.transparent,
                  child:  RTCVideoView(_remoteRenderer),
                    height: fullScreenHeight,
                    width: fullScreenWidth,
                  ),

              ),

              InkWell(
                onTap: () {
                  // flipVideo();
                  //showHideVideoControl();
                },
                child: Container(
                  color: Colors.transparent,
                  height: _localVideoHeight,
                  width: _localVideoWidth,
                  margin: localVideoContainerMargin,
                  child: AnimatedContainer(
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(
                        0.0, 0.0, 0.0, 0.0),
                    child: RTCVideoView(_localRenderer),
                    height: _localVideoHeight,
                    width: _localVideoWidth,
                    alignment: Alignment.centerRight,
                    duration: Duration(milliseconds: 300),
                  ),
                  alignment: Alignment.topRight,
                ),
              ),



            ] ));


  }

  void hideControls() {
    callControlsUI.controlsUIStateState.hideUnHideView();
    topUI.topUIState.hideUnHideView();
  }

  Map<String, dynamic> getMap() {

    var map = Map<String, dynamic>();
    map['inPipMode'] = inPipMode;
    map['isMore'] = isMore;
    map['audioMuted'] = audioMuted;
    map['videoMuted'] = videoMuted;
    map['speakerOn'] = speakerOn;
    map['screenShare'] = screenShare;
    map['inScreenShareMode'] = inScreenShareMode;
    map['inCameraStreamMode'] = inCameraStreamMode;

    return map;
  }

  void callAnnouncementHandler(Call call, CallState callState) {

    print("callAnnouncementHandler");
    try {
      if (callState.state == CallStateEnum.CONNECTING) {
        SoundPlayer.playOutgoingSound();
      }

      if (callState.state == CallStateEnum.CONFIRMED) {
        SoundPlayer.stopSound();
      }

      if (callState.state == CallStateEnum.ACCEPTED) {
        SoundPlayer.stopSound();
      }

      if (callState.state == CallStateEnum.ENDED) {
        SoundPlayer.stopSound();
      }
      if (callState.state == CallStateEnum.FAILED) {
        SoundPlayer.stopSound();
        if (callState.cause.cause == Causes.REJECTED ||
            callState.cause.cause == Causes.UNAVAILABLE) {
          if (direction != 'INCOMING') {
            SoundPlayer.playBusySound();
          }
        }
        if (callState.cause.cause == Causes.NOT_FOUND) {
          SoundPlayer.playNotFoundTone(speakerOn);
        }
      }
    }
    catch (e) {}
  }




}



