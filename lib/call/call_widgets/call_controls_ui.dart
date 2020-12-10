import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:huna/call/calltransfer/call_transfer.dart';
import 'package:huna/contacts/contacts.dart';
import 'package:huna/libraries/sip_ua/rtc_session.dart';
import 'package:huna/libraries/sip_ua/sip_ua.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/utils/show.dart';
import 'package:responsive_widgets/responsive_widgets.dart';

import '../../constant.dart';


class CallControlsUI extends StatefulWidget {


  final Map<String, dynamic> map;
  final bool voiceOnly;
  final SIPUAHelper helper;

  final CallControlCallback onButtonPress;

  CallControlsUI({this.onButtonPress,this.voiceOnly,this.map, this.helper});

  var controlsUIStateState  = new ControlsUIStateState();

  @override
  ControlsUIStateState createState() => controlsUIStateState ;

}

class ControlsUIStateState extends State<CallControlsUI> {

  Map<String, dynamic> get map => widget.map;

  var isMore = false;
  var speakerOn = false;
  var audioMuted = false;
  var screenShare = false;
  var videoMuted = false;
  var visible = true;

  var callTransferUIVisible = false;

  //
  // map['isMore'] = isMore;
  // map['audioMuted'] = audioMuted;
  // map['videoMuted'] = videoMuted;
  // map['speakerOn'] = speakerOn;
  // map['inScreenShareMode'] = inScreenShareMode;
  // map['inCameraStreamMode'] = inCameraStreamMode;
  //

  @override
  void initState() {

    super.initState();
    isMore = map['isMore'];
    speakerOn = map['speakerOn'];
    audioMuted = map['audioMuted'];
    screenShare = map['screenShare'];
    videoMuted = map['videoMuted'];

  }
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

   return Visibility(
     visible: visible,
     child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RepaintBoundary(
            child:  SizedBox(
              child:  audioVideoControlUi(widget.voiceOnly),
            ),
          ),
        ],
      ),
   );

  }

  // Call Control UI
  audioVideoControlUi(isAudioCall) {

    return Column(
      children: <Widget>[

    Expanded(
      child: callTransferUIVisible ? _callTransferUi() : Container(),),
        Container(
            width: isAudioCall ? 250 : 305,
            height: 60,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            padding: const EdgeInsets.all(15.0),

            decoration: new BoxDecoration(
              //you can get rid of below line also
              borderRadius: new BorderRadius.circular(10.0),
              //below line is for rectangular shape
              shape: BoxShape.rectangle,
              //you can change opacity with color here(I used black) for rect
              color: Colors.black.withOpacity(0.5),
              //I added some shadow, but you can remove boxShadow also.
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  offset: new Offset(5.0, 5.0),
                ),
              ],
            ),
            child: isMore ? getMoreVideoControls() : getBasicControls(isAudioCall))
      ],
    );
  }

  getBasicControls(isAudioCall) {

    double marginLeft = 12, marginRight = 12, iconSize = 30;

    return Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            isAudioCall ? Container() : Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: videoMuted
                    ? Icon(Icons.videocam_off,
                    color: Colors.white, size: iconSize)
                    : Icon(Icons.videocam, color: Colors.white, size: iconSize),

                onTap: () {
                  setState(() {
                    videoMuted = !videoMuted;
                  });
                  widget.onButtonPress("MuteVideo");
                },
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: audioMuted
                    ? Icon(Icons.mic_off, color: Colors.white, size: iconSize)
                    : Icon(Icons.mic, color: Colors.white, size: iconSize),
                onTap: () {
                  setState(() {
                    audioMuted = !audioMuted;
                  });
                  widget.onButtonPress("MuteAudio");
                },
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: speakerOn
                    ? Icon(Icons.volume_up, color: Colors.white, size: iconSize)
                    : Icon(Icons.volume_down,
                    color: Colors.white, size: iconSize),
                onTap: () {

                  setState(() {
                    speakerOn = !speakerOn;
                  });
                  widget.onButtonPress("Speaker");
                },
              ),
            ),

            isAudioCall ?    Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: callTransferUIVisible
                    ? Icon(Icons.close, color: Colors.white, size: iconSize)
                    : Icon(Icons.call_made,
                    color: Colors.white, size: iconSize),
                onTap: () {
                  setState(() {
                    callTransferUIVisible = !callTransferUIVisible;
                  });

                },
              ),
            ) : Container(),
            isAudioCall ? Container() :  Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child:
                Icon(Icons.more_horiz, color: Colors.white, size: iconSize),
                onTap: () {
                  setState(() {
                    isMore = true;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: Icon(Icons.call_end, color: Colors.red, size: iconSize),
                onTap: () {
                  widget.onButtonPress("Hangup");
                },
              ),
            )
          ],
        ));

  }

  getMoreVideoControls() {
    double marginLeft = 12, marginRight = 12, iconSize = 30;

    return Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: Icon(Icons.camera, color: Colors.white, size: iconSize),
                onTap: () {
                  widget.onButtonPress("Snap");
                },
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: screenShare
                    ? Icon(Icons.stop_screen_share, color: Colors.white, size: iconSize)
                    : Icon(Icons.screen_share, color: Colors.white, size: iconSize),
                onTap: () {
                  setState(() {
                    screenShare = !screenShare;
                  });

                  widget.onButtonPress("ScreenShare");
                },
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: Icon(Icons.fiber_manual_record,
                    color: Colors.red, size: iconSize),
                onTap: () {
                  Show.showToast('Record Version 2', false);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: Icon(Icons.switch_video,
                    color: Colors.white, size: iconSize),
                onTap: () {
                  widget.onButtonPress("SwitchCamera");
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child:
                Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
                onTap: () {
                  setState(() {
                    isMore = false;
                  });
                },
              ),
            )
          ],
        ));
  }

  void hideUnHideView() {

    setState(() {
      visible = !visible;
    });
  }


  _callTransferUi() {

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 80, 0, 20),
      child: Container(
        width:MediaQuery.of(context).size.width,
        decoration: new BoxDecoration(
          //you can get rid of below line also
          borderRadius: new BorderRadius.circular(0.0),
          //below line is for rectangular shape
          shape: BoxShape.rectangle,
          //you can change opacity with color here(I used black) for rect
          color: Colors.black.withOpacity(0.9),
          //I added some shadow, but you can remove boxShadow also.
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: new Offset(5.0, 5.0),
            ),
          ],
        ),
        child: CallTransfer(widget.helper),
      ),
    );
  }

}






